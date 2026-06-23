// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

///TEMP USING THE HARDCODED VALUES FOR THE AUTH_TOKEN AND PHONE_NUMBER_ID
Future<void> sendWhatsAppMessage(
  String phoneNumber,
  String tmplateType,
  Map dataToWhtsap,
) async {
  String token = "";     //AddTOKEN
  String phoneNumberId = "";    //AddPHONENUMBERID

  final url = "https://graph.facebook.com/v19.0/$phoneNumberId/messages";

  debugPrint(
    "WHATSAPP MSG URL :::: $url",
  );

  try {
    final response = await Dio().post(
      url,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ),
      data: {
        "MESSEGIN_PRODUCT": "WHATSAPP",
        "to": phoneNumber, //country code is must when sending the phone number
        "type": tmplateType,
        "template": dataToWhtsap,
      },
    );
    final dataToSend = {
      "MESSEGIN_PRODUCT": "WHATSAPP",
      "to": phoneNumber, 
      "type": tmplateType,
      "template": dataToWhtsap,
    };
    debugPrint("Data To Send WahtsAppp ::::  $dataToSend");
    debugPrint("WhatsApp Status Code: ${response.statusCode}");
    debugPrint("WhatsApp Response: ${response.data}");
  } catch (e) {
    debugPrint("WhatsApp MSG Sending Error: $e");
  }
}
