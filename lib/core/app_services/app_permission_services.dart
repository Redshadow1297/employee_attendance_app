// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class AppServices {
  // ---------------- LOCATION ----------------
  static Future<bool> checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      /// Wait user to return
      await Future.delayed(const Duration(seconds: 3));

      /// Recheck again
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return false;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();

      return false;
    }

    return true;
  }

  // ---------------- NOTIFICATION ----------------
  static Future<bool> checkNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  // ---------------- INTERNET ----------------
  static Future<bool> checkInternet(BuildContext context) async {
    final connectivityResults = await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.none)) {
      if (context.mounted) {
        CommonSnackBar.show(
          title: "No Internet",
          message: "You are offline",
          type: SnackBarType.warning,
          context: context,
        );
      }
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  /////============================= AppServices result check  CombinedAllMethods ============================
  static Future<bool> validatePunchRequirements(BuildContext context) async {
    bool hasInternet = await AppServices.checkInternet(context);
    if (!hasInternet) return false;

    bool hasLocation = await AppServices.checkLocationService();
    if (!hasLocation) return false;

    bool hasNotification = await AppServices.checkNotificationPermission();
    if (!hasNotification) return false;

    return true; //when all permissions get granted then return true
  }
}
