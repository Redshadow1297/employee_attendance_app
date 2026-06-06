// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Future<void> sendWhatsAppMessage() async {
  String token =
      "";
  String phoneNumberId = "";

  final url = "https://graph.facebook.com/v19.0/$phoneNumberId/messages";

  debugPrint(
    "WhatsApp msg URL = https://graph.facebook.com/v19.0/$phoneNumberId/messages",
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
        "messaging_product": "whatsapp",
         "to": "917057799118", // country code must
        // "to": "919730028611",
        "type": "template",
        "template": {
          "name": "Hello_Siraj_Bhaiii",
          "language": {"code": "en_US"},
        },
      },
    );

    debugPrint(
      "whatsapp data to send: ${{
        "messaging_product": "whatsapp",
          "to": "917057799118", // country code must
        // "to": "919730028611",
        "type": "template",
        "template": {
          "name": "Hello_Siraj_Bhaiii",
          "language": {"code": "en_US"},
        },
      }}",
    );
    debugPrint("WhatsApp Status Code: ${response.statusCode}");
    debugPrint("WhatsApp Response: ${response.data}");
  } catch (e) {
    debugPrint("WhatsApp Error: $e");
  }
}
