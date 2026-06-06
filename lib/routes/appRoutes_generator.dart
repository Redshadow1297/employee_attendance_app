// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/pages/Modules/LocationTracking/employeeTrack..dart';
import 'package:new_design_demo/presentations/pages/Modules/advanceManagement/app_advance.dart';
import 'package:new_design_demo/presentations/pages/Modules/vehicleRequisition/app_vehicle_booking.dart';
import 'package:new_design_demo/presentations/pages/Modules/visitorManagement_Security/app_visitor_management.dart';
import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
import 'package:new_design_demo/presentations/pages/app_login.dart';
import 'package:new_design_demo/presentations/pages/app_splash.dart';
import 'package:new_design_demo/presentations/pages/app_wallpost.dart';
import 'package:new_design_demo/presentations/pages/Modules/attendanceManagement/app_attendance_mgt.dart';
import 'package:new_design_demo/presentations/pages/Modules/leaveManagement/app_leave_mgt.dart';
import 'package:new_design_demo/routes/app_routes.dart';

//A;l the Applications module Routes are here first declare the route in app_routes.dart and then add the case here in switch statement
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => AppDashboardScreen());

      case AppRoutes.wallPost:
        return MaterialPageRoute(builder: (_) => WallPostScreen());

      case AppRoutes.leave:
        return MaterialPageRoute(builder: (_) => LeaveScreen());

      case AppRoutes.attendance:
        return MaterialPageRoute(builder: (_) => AttendanceScreen());

      case AppRoutes.advance:
        return MaterialPageRoute(builder: (_) => AdvanceScreen());

      case AppRoutes.vehicleRequisition:
        return MaterialPageRoute(builder: (_) => VehicleBooking());

      case AppRoutes.visitorManagement:
        return MaterialPageRoute(builder: (_) => AppVisitorManagement());

      case AppRoutes.employeeTracking:
        return MaterialPageRoute(builder: (_) => TrackingScreen());

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 25,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Development Under Progress..",
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.15),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
