// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:flutter_screenutil/flutter_screenutil.dart'; //for adjusting UI as per different screen sizes
import 'package:new_design_demo/core/constants/theme_helper.dart';
import 'package:new_design_demo/presentations/pages/app_splash.dart';
import 'package:new_design_demo/routes/appRoutes_generator.dart';
import 'package:new_design_demo/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
  runApp(const MyApp());
}

///Headless TAsk Handler for background events when app is terminated or in background
@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent event) async {
  switch (event.name) {

    case bg.Event.LOCATION:
      final bg.Location location = event.event;
      debugPrint(
        "Headless location: ${location.coords.latitude}, ${location.coords.longitude}",
      );
      break;

    case bg.Event.MOTIONCHANGE:
      debugPrint("Motion change detected");
      break;

    case bg.Event.TERMINATE:
      debugPrint("App terminated but tracking still running");
      break;

    case bg.Event.HEARTBEAT:
      debugPrint("Heartbeat received");
      break;
  }

  final dynamic data = event;
  final int? taskId = data.taskId;

  if (taskId != null) {
    bg.BackgroundGeolocation.finish(taskId);
  }
}




////Entry
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        360,
        690,
      ), ////LayoutAsPerDevices like Android/TAbs/Iphones
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: RouteGenerator.generateRoute,
          title: 'Flutter Demo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        );
      },
    );
  }
}
