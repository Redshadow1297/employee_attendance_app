// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_design_demo/core/constants/theme_helper.dart';
import 'package:new_design_demo/routes/appRoutes_generator.dart';
import 'package:new_design_demo/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    /// Register Headless Task
    bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);

    runApp(const MyApp());
  }, (error, stackTrace) {
    debugPrint('Unhandled Error: $error');
    debugPrint(stackTrace.toString());
  });
}

/// Headless Task
@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent event) async {
  try {
    switch (event.name) {
      case bg.Event.LOCATION:
        final bg.Location location = event.event;

        debugPrint(
          'Headless Location : '
          '${location.coords.latitude}, '
          '${location.coords.longitude}',
        );
        break;

      case bg.Event.MOTIONCHANGE:
        debugPrint('Motion Change Detected');
        break;

      case bg.Event.TERMINATE:
        debugPrint('App Terminated - Tracking Continues');
        break;

      case bg.Event.HEARTBEAT:
        debugPrint('Heartbeat Received');
        break;

      default:
        debugPrint('Unknown Event : ${event.name}');
    }

    final dynamic data = event;
    final int? taskId = data.taskId;

    if (taskId != null) {
      bg.BackgroundGeolocation.finish(taskId);
    }
  } catch (e, stackTrace) {
    debugPrint('Headless Task Error : $e');
    debugPrint(stackTrace.toString());
  }
}

/// App Entry Point
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'New Design Demo',

          /// Routing
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.generateRoute,

          /// Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}