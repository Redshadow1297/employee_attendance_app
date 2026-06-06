// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';

// ─────────────────────────────────────────────────────────────
//  DATA MODEL  –  all fields needed by both In and Out punch
class PunchRequestData {
  final String empPk;
  final String employeeCode;
  final String attendanceDate;
  final String applicationDate;
  final String deviceId;
  final String latitude;
  final String longitude;
  final String locationPk;
  final String companyPk;
  final String address;
  final String batteryLevel;

  /// "ONLINE" | "OFFLine"
  final String data;

  /// "ON" | "OFF"  (whether GPS is enabled)
  final String location;

  final String inTime;
  final String outTime;

  /// "0" = in-punch, "1" = out-punch  (set internally by service)
  final String inOrOut;

  const PunchRequestData({
    required this.empPk,
    required this.employeeCode,
    required this.attendanceDate,
    required this.applicationDate,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.locationPk,
    required this.companyPk,
    required this.address,
    required this.batteryLevel,
    required this.data,
    required this.location,
    required this.inTime,
    required this.outTime,
    required this.inOrOut,
  });

  Map<String, dynamic> toJson({required String overrideInOrOut}) => {
        "Emp_PK": empPk,
        "Employee_Code": employeeCode,
        "Status": "",
        "AttendanceDate": attendanceDate,
        "DeviceID": deviceId,
        "Latitude": latitude,
        "Data": data,
        "InOrOUT": overrideInOrOut,
        "ApplicationDate": applicationDate,
        "Longitude": longitude,
        "Location_PK": locationPk,
        "Company_PK": companyPk,
        "batterylevel": batteryLevel,
        "TimeCard": 1,
        "Location": location,
        "Address": address,
        "InTime": inTime,
        "OutTime": outTime,
      };
}

// ─────────────────────────────────────────────────────────────
//  PUNCH SERVICE

class PunchService {

  // ── Public helpers ──────────────────────────────────────────

  /// Sends an **In-Punch** request.
  /// Returns a human-readable status string from the API.
  static Future<String> punchIn(PunchRequestData req) async {
    return _sendPunch(req, inOrOut: "0");
  }

  /// Sends an **Out-Punch** request.
  /// Returns a human-readable status string from the API.
  static Future<String> punchOut(PunchRequestData req) async {
    return _sendPunch(req, inOrOut: "1");
  }

  // ── Core punch sender ───────────────────────────────────────

  static Future<String> _sendPunch(
    PunchRequestData req, {
    required String inOrOut,
  }) async {
    final String url = ApiConstants.punchInOut;

    print("PunchService ▶ sending punch | InOrOUT=$inOrOut | url=$url");
    _logRequest(req, inOrOut);

    final response = await ApiClient.post(
      ApiConstants.punchInOut,
      data: req.toJson(overrideInOrOut: inOrOut),
    );

    print("PunchService ◀ status=${response.statusCode}");
    print("PunchService ◀ body=${response.toString()}");

    return _extractStatusMessage(response.toString());
  }

  // ─────────────────────────────────────────────────────────────
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

    print("PunchService ▶ syncing offline record id=$localId | InOrOUT=$inOrOut  | url=$url");

    final response = await ApiClient.post(
      ApiConstants.punchInOut,
      data: req.toJson(overrideInOrOut: inOrOut),
    );

    print("PunchService ◀ offline sync status=${response.statusCode}");

    if (response.statusCode == 200) {
      await onDeleteRecord(localId);
      print("PunchService ✓ offline record $localId deleted after sync");
    } else {
      print("PunchService ✗ server returned ${response.statusCode} for record $localId");
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
      print("PunchService: could not parse status message – $e");
    }
    return rawResponse;
  }

  //  LOGGING HELPER

  static void _logRequest(PunchRequestData req, String inOrOut) {
    print("  EmpPk        : ${req.empPk}");
    print("  EmployeeCode : ${req.employeeCode}");
    print("  AttendDate   : ${req.attendanceDate}");
    print("  DeviceId     : ${req.deviceId}");
    print("  Latitude     : ${req.latitude}");
    print("  Longitude    : ${req.longitude}");
    print("  LocationPk   : ${req.locationPk}");
    print("  CompanyPk    : ${req.companyPk}");
    print("  Battery      : ${req.batteryLevel}");
    print("  Data(conn)   : ${req.data}");
    print("  Location(gps): ${req.location}");
    print("  Address      : ${req.address}");
    print("  InTime       : ${req.inTime}");
    print("  OutTime      : ${req.outTime}");
    print("  InOrOUT      : $inOrOut");
  }
}