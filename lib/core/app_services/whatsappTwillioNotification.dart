// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';


Future<void> sendWhatsAppDirect(String msg) async {
  final String accountSid = "";
  final String authToken = "";

  final dio = Dio();

  final String url =
      "https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json";

  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken'));

  try {
    final response = await dio.post(
      url,
      data: {
        "From": "whatsapp:+14155238886",
        "To": "whatsapp:+919730028611",
        "Body": msg
      },
      
      options: Options(
        headers: {
          "Authorization": basicAuth,
        },
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    debugPrint("Twilio Success: ${response.data}");
  } catch (e) {
    if (e is DioException) {
      debugPrint("Twilio Error: ${e.response?.data}");
    }
  }
}