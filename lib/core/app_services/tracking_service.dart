// ignore_for_file: unused_field

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  bool _isInitialized = false;

  double _totalDistance = 0.0;
  bg.Location? _lastLocation;
  final List<LatLng> _locations = [];

  final StreamController<List<LatLng>> _locationController =
      StreamController.broadcast();

  Stream<List<LatLng>> get locationStream => _locationController.stream;

  double get totalKm => _totalDistance / 1000;

  List<LatLng> get restoredPoints => _locations;

  // ================= INITIALIZE =================
  Future<void> initialize() async {
    if (_isInitialized) return;

    bg.BackgroundGeolocation.onLocation(_onLocation);

    await bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 20,

        stopOnTerminate: false, //Handling on termination of APP
        startOnBoot: true,
        enableHeadless: true,
        foregroundService: true,
        showsBackgroundLocationIndicator: true,
        backgroundPermissionRationale: bg.PermissionRationale(
          title: "Allow Background Location.",
          message:
              "Please make sure that your device has granted the background location permission",
        ),

        autoSync: true,
        batchSync: true,
        maxBatchSize: 10,

        heartbeatInterval: 60,
        debug: false,
        logLevel: bg.Config.LOG_LEVEL_OFF,

        notification: bg.Notification(
          title: "Tracking Active",
          text: "Location tracking running",
        ),
      ),
    );

    _isInitialized = true;

    bg.BackgroundGeolocation.onLocation(
      (bg.Location location) {
        debugPrint(
          "LOCATION => "
          "${location.coords.latitude}, "
          "${location.coords.longitude}",
        );
      },
      (bg.LocationError error) {
        debugPrint("LOCATION ERROR => ${error.code} ${error.message}");
      },
    );
  }

  // ================= LOCATION CALLBACK =================
  void _onLocation(bg.Location location) async {
    final point = LatLng(location.coords.latitude, location.coords.longitude);

    // distance calculation
    if (_locations.isNotEmpty) {
      final last = _locations.last;

      double distance = _calculateDistance(
        last.latitude,
        last.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance > 5 && distance < 200) {
        _totalDistance += distance;
      }
    }

    _lastLocation = location;

    _locations.add(point);

    _saveLocation(location);

    _locationController.add(List.from(_locations));
  }

  // ================= START =================
  Future<void> startTracking() async {
    await initialize();

    bg.State state = await bg.BackgroundGeolocation.state;

    if (state.enabled) return;

    _totalDistance = 0;
    _lastLocation = null;
    _locations.clear();

    _locationController.add([]);

    await bg.BackgroundGeolocation.start();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isTracking", true);

    debugPrint("Tracking STARTED");

    debugPrint("ENABLED=${state.enabled}");
    debugPrint("IS_MOVING=${state.isMoving}");
  }

  // ================= STOP =================
  Future<double> stopTracking() async {
    bg.State state = await bg.BackgroundGeolocation.state;

    if (state.enabled) {
      await bg.BackgroundGeolocation.stop();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isTracking", false);
    debugPrint("state after stopping: ENABLED=${state.enabled}");
    debugPrint("Tracking STOPPED");

    return _totalDistance / 1000;
  }

  // ================= SAVE LOCATION =================
  Future<void> _saveLocation(bg.Location location) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> stored = prefs.getStringList("route") ?? [];

    stored.add("${location.coords.latitude},${location.coords.longitude}");

    await prefs.setStringList("route", stored);
  }

  // ================= RESTORE ROUTE =================
  Future<void> restoreRoute() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> stored = prefs.getStringList("route") ?? [];

    _locations.clear();

    _locations.addAll(
      stored.map((e) {
        final parts = e.split(",");

        return LatLng(double.parse(parts[0]), double.parse(parts[1]));
      }).toList(),
    );

    _locationController.add(List.from(_locations));
  }

  // ================= CLEAR ROUTE =================
  Future<void> clearStoredRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("route");
  }

  // ================= DISTANCE =================
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371000;

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  void dispose() {
    _locationController.close();
  }
}
