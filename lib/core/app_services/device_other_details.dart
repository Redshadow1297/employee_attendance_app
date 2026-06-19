import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceInfoService {
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceDetails() async {
    String deviceId = "";
    String model = "";

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo android = await _deviceInfo.androidInfo;

        model = android.model;
        deviceId = android.id;

        debugPrint("ANDROID MODEL :: $model");
        debugPrint("ANDROID ID :: $deviceId");

      } else if (Platform.isIOS) {
        IosDeviceInfo ios = await _deviceInfo.iosInfo;

        model = ios.model;
        deviceId = ios.identifierForVendor ?? "";

        debugPrint("IOS MODEL :: $model");
        debugPrint("IOS ID :: $deviceId");
      }

    } catch (e) {
      debugPrint("DEVICE INFO ERROR :: $e");
    }


    int battery = await _battery.batteryLevel;


    return {
      "deviceId": deviceId,
      "model": model,
      "battery": "$battery%",
    };
  }
}