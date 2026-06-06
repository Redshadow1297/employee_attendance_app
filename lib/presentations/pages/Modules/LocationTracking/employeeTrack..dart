// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_design_demo/core/app_services/tracking_service.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TrackingService _trackingService = TrackingService();

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _trackingService.startTracking();
      await _trackingService.restoreRoute();

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Live Tracking",
          style: AppTextStyles.headingMedium,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<LatLng>>(
       
              stream: _trackingService.locationStream,

              builder: (context, snapshot) {
                final livePoints = snapshot.data ?? [];

                final routePoints = [
                  ..._trackingService.restoredPoints,
                  ...livePoints,
                ];

                final current =
                    routePoints.isNotEmpty ? routePoints.last : null;

                if (current != null && _mapController != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLng(current),
                    );
                  });
                }

                return GoogleMap(
                  onMapCreated: (c) => _mapController = c,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(18.5204, 73.8567),
                    zoom: 14,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: routePoints,
                      width: 5,
                      color: Colors.blue,
                    )
                  },
                  markers: current != null
                      ? {
                          Marker(
                            markerId: const MarkerId("current"),
                            position: current,
                          )
                        }
                      : {},
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Distance: ${_trackingService.totalKm.toStringAsFixed(2)} KM",
            ),
          ),
        ],
      ),
    );
  }
}