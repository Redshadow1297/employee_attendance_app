// ignore_for_file: avoid_debugPrint, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/app_services/tracking_service.dart';
import 'package:new_design_demo/data/model/data_model_InOutPunch.dart';

//  PUNCH SERVICE

class PunchService {
  // ── Public helpers ──────────────────────────────────────────

  /// Sends an **In-Punch** request.
  static Future<String> punchIn(PunchRequestData req) async {
    await TrackingService().startTracking();  //Start Tracking At Punch in Time
    return _sendPunch(req, inOrOut: "0");
  }

  /// Sends an **Out-Punch** request.
  static Future<String> punchOut(PunchRequestData req) async {
    await TrackingService().stopTracking(); //Stop Tracking at PunchOut Time
    return _sendPunch(req, inOrOut: "1");
  }

  // ── Core punch sender  0 OR 1 ───────────────────────────────────────
  static Future<String> _sendPunch(
    PunchRequestData req, {
    required String inOrOut,
  }) async {
    final String url = ApiConstants.punchInOut;

    debugPrint("PunchService ▶ sending punch | InOrOUT=$inOrOut | url=$url");
  
    final response = await ApiClient.post(
      ApiConstants.punchInOut,
      data: req.toJson(overrideInOrOut: inOrOut),
    );
    final datatosend = req.toJson(overrideInOrOut: inOrOut);
    debugPrint(" PUNCH IN OR OUT DATA ::: $datatosend");
    debugPrint("PunchService ◀ status=${response.statusCode}");
    debugPrint("PunchService ◀ body=${response.toString()}");

    return _extractStatusMessage(response.toString());
  }

  //  OFFLINE PUNCH  –  for when the device has no internet

  /// Sends a **single** stored offline punch record to the server.
  /// caller can remove the row from the local database.
  static Future<void> syncOfflineRecord({
    required PunchRequestData req,
    required String inOrOut,
    required int localId,
    required Future<void> Function(int id) onDeleteRecord,
  }) async {
    final String url = ApiConstants.punchInOut;

    debugPrint(
      "PunchService ▶ syncing offline record id=$localId | InOrOUT=$inOrOut  | url=$url",
    );

    final response = await ApiClient.post(
      ApiConstants.punchInOut,
      data: req.toJson(overrideInOrOut: inOrOut),
    );

    debugPrint(response.data);

    final result = response.data["PunchInOutResult"]?.toString() ?? "";

    if (response.statusCode == 200 &&
        result.toLowerCase().contains("success")) {
      await onDeleteRecord(localId);

      debugPrint("Deleted Successfully");
    } else {
      debugPrint("Sync Failed");
      debugPrint(result);
    }
  }

  static String _extractStatusMessage(String rawResponse) {
    try {
      // Pattern from old code:
      //   responseStr.split(":").last  →  " Success}", then split on "}" → "Success"
      final parts = rawResponse.split(":");
      if (parts.length > 1) {
        final afterColon = parts.last;
        final statusParts = afterColon.split("}");
        return statusParts.first.trim();
      }
    } catch (e) {
      debugPrint("PunchService: could not parse status message – $e");
    }
    return rawResponse;
  }
}
