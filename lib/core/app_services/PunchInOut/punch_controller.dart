// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, non_constant_identifier_names, unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/app_services/PunchInOut/punch_service.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/presentations/common_widgets/punch_dialogue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/app_services/tracking_service.dart';

// ─────────────────────────────────────────────────────────────
//  OFFLINE RECORD MODEL

class OfflinePunchRecord {
  final int localId;
  final String locationPk;
  final String empPk;
  final String status;
  final String address;
  final String companyPk;
  final String attendanceDate;
  final String latitude;
  final String inOrOut; // "0" = in, "1" = out
  final String timeCard;
  final String applicationDate;
  final String longitude;
  final String allowTracking;
  final String inTime;
  final String outTime;
  final String deviceId;
  final String data; // "ONLINE" | "OFFLine"
  final String location; // "ON" | "OFF"
  final String battery;

  const OfflinePunchRecord({
    required this.localId,
    required this.locationPk,
    required this.empPk,
    required this.status,
    required this.address,
    required this.companyPk,
    required this.attendanceDate,
    required this.latitude,
    required this.inOrOut,
    required this.timeCard,
    required this.applicationDate,
    required this.longitude,
    required this.allowTracking,
    required this.inTime,
    required this.outTime,
    required this.deviceId,
    required this.data,
    required this.location,
    required this.battery,
  });
}

// ─────────────────────────────────────────────────────────────
//  PUNCH CONTROLLER

class PunchController {
  // ── Dependencies injected from parent widget ──
  final BuildContext context;

  /// Called whenever this controller changes state so the parent
  /// widget can call setState.
  final VoidCallback onStateChanged;

  /// Returns all locally-stored offline punch records.
  final Future<List<OfflinePunchRecord>> Function() getOfflineRecords;

  /// Deletes a locally-stored offline record by its row-id.
  final Future<void> Function(int id) deleteOfflineRecord;

  /// Persists a punch record locally when offline.
  final Future<void> Function(OfflinePunchRecord record) saveOfflineRecord;

  // ── User / session data (loaded via loadUserPrefs) ──
  String employeeCode = '';
  String employeename = '';
  int? emppk;
  int? companypk;
  int? locationpk;
  String emppk_str = '';
  String companypk_str = '';
  String locationpk_str = '';
  String isAllowTrackingValue = '';
  int? sharredTrackingValue;

  // ── Device data ──
  String _deviceId = '';
  int _batteryLevel = 0;
  String _latitude = '';
  String _longitude = '';
  String _address = '';

  // ── Punch state ──
  String inTimeVal = '';
  String outTimeVal = '';
  String currentDate = '';
  bool isOnline = true;
  bool isLocationOn = false;
  bool isPunchLoading = false;

  // ── Internal helpers ──
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  PunchController({
    required this.context,
    required this.onStateChanged,
    required this.getOfflineRecords,
    required this.deleteOfflineRecord,
    required this.saveOfflineRecord,
  });

  // ═══════════════════════════════════════════════════════════
  //  PUBLIC ENTRY POINT
  //  Call this when the user taps Punch In or Punch Out.

  Future<void> onPunchTapped({required bool isPunchIn}) async {
    if (isPunchLoading) return;

    //  get Data Load LocationPK and CompanyPk error
    await loadUserPrefs();
    //  Check connectivity
    await _checkConnectivity();

    //  Check location service
    isLocationOn = await Geolocator.isLocationServiceEnabled();

    if (!isLocationOn) {
      _showLocationMustBeOnDialog();
      return;
    }

    //  Show loader while resolve GPS / address
    _setLoading(true);

    //  Gather device data (GPS, address, battery, device ID)
    await _refreshDeviceData();

    //  Get current server/device date
    await _getCurrentDate();

    //  Sync any pending offline records first
    await _syncOfflineRecords();

    _setLoading(false);

    // Show confirmation dialog
    if (isPunchIn) {
      _showPunchConfirmDialog(title: "INPUNCH", onConfirmed: _performInPunch);
    } else {
      _showPunchConfirmDialog(title: "OUTPUNCH", onConfirmed: _performOutPunch);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  IN-PUNCH  ( _getInpuchOnlineData / offline path)
  // ═══════════════════════════════════════════════════════════

  Future<void> _performInPunch() async {
    final String nowTime = DateFormat("HH:mm").format(DateTime.now());

    final req = _buildRequest(inTime: nowTime, outTime: "", inOrOut: '0');

    if (isOnline) {
      try {
        final result = await PunchService.punchIn(req);

        // Immediately update UI
        inTimeVal = nowTime;
        outTimeVal = "";

        onStateChanged();

        if (isAllowTrackingValue == "1" && isLocationOn) {
          await TrackingService().startTracking();
        }

        // Wait for backend save
        await Future.delayed(const Duration(seconds: 2));

        if (emppk != null) {
          await getTodaysAttendanceState(emppk: emppk!);
        }

        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: result,
          type: SnackBarType.success,
        );
      } catch (e) {
        print("InPunch error => $e");

        CommonSnackBar.show(
          context: context,
          title: "Failed",
          message: "Check In Failed",
          type: SnackBarType.error,
        );
      }
    }
  }
  // ═══════════════════════════════════════════════════════════
  //  OUT-PUNCH  ( _getOutPunchOnlineData / offline path)
  // ═══════════════════════════════════════════════════════════

  Future<void> _performOutPunch() async {
    final String nowTime = DateFormat("HH:mm").format(DateTime.now());

    final req = _buildRequest(inTime: "", outTime: nowTime, inOrOut: '1');

    if (isOnline) {
      try {
        final result = await PunchService.punchOut(req);

        //  STOP TRACKING (ONLINE)
        double km = await TrackingService().stopTracking();
        print("Tracking STOPPED (ONLINE OUT-PUNCH) KM: $km");

        CommonSnackBar.show(
          context: context,
          title: "Success .",
          message: result,
          type: SnackBarType.success,
        );

        onStateChanged();
      } catch (e) {
        print("OutPunch online error: $e");
        CommonSnackBar.show(
          context: context,
          title: "Failed .",
          message: "Failed To Checked Out .",
          type: SnackBarType.error,
        );
      }
    } else {
      // OFFLINE
      final record = _buildOfflineRecord(
        inOrOut: "1",
        inTime: "",
        outTime: nowTime,
      );

      await saveOfflineRecord(record);
      await _showOfflineNotification(isInPunch: false);

      //  STOP TRACKING (OFFLINE)
      double km = await TrackingService().stopTracking();
      print("Tracking STOPPED (OFFLINE OUT-PUNCH) KM: $km");

      _showSavedDialog();
    }
  }
  // ═══════════════════════════════════════════════════════════
  //  OFFLINE SYNC
  //  Reads all local records and submits them online.
  // ═══════════════════════════════════════════════════════════

  Future<void> _syncOfflineRecords() async {
    if (!isOnline) return;

    final records = await getOfflineRecords();
    if (records.isEmpty) return;

    print("PunchController: syncing ${records.length} offline record(s)");

    for (final record in records) {
      try {
        final req = PunchRequestData(
          empPk: record.empPk,
          employeeCode: employeeCode,
          attendanceDate: record.attendanceDate,
          applicationDate: record.applicationDate,
          deviceId: record.deviceId,
          latitude: record.latitude,
          longitude: record.longitude,
          locationPk: record.locationPk,
          companyPk: record.companyPk,
          address: record.address,
          batteryLevel: record.battery,
          data: record.data,
          location: record.location,
          inTime: record.inTime,
          outTime: record.outTime,
          inOrOut: record.inOrOut,
        );

        await PunchService.syncOfflineRecord(
          req: req,
          inOrOut: record.inOrOut,
          localId: record.localId,
          onDeleteRecord: deleteOfflineRecord,
        );
      } catch (e) {
        print("PunchController: failed to sync record ${record.localId} – $e");
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  DEVICE DATA REFRESH


  Future<void> _refreshDeviceData() async {
    // Battery
    try {
      _batteryLevel = await _battery.batteryLevel;
      print("Battery: $_batteryLevel%");
    } catch (e) {
      print("Battery error: $e");
    }

    // Device ID
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfoPlugin.androidInfo;
        _deviceId = info.id;
      } else {
        final info = await _deviceInfoPlugin.iosInfo;
        _deviceId = info.identifierForVendor ?? '';
      }
      print("DeviceId: $_deviceId");
    } catch (e) {
      print("DeviceId error: $e");
    }

    // GPS + reverse geocoding
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _latitude = pos.latitude.toString();
        _longitude = pos.longitude.toString();
        print("Lat: $_latitude  Long: $_longitude");

        // Reverse geocode
        final marks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        if (marks.isNotEmpty) {
          final p = marks[0];
          _address =
              '${p.street}, ${p.subLocality}, ${p.locality}, ${p.postalCode}, ${p.country}';
          print("Address: $_address");
        }
      }
    } catch (e) {
      print("GPS error: $e");
      _latitude = '0.0';
      _longitude = '0.0';
      _address = 'Unknown';
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  CONNECTIVITY CHECK ═

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      isOnline = false;
    }
    print("PunchController: isOnline=$isOnline");
  }

  // ═══════════════════════════════════════════════════════════
  //  DATE HELPER 

  Future<void> _getCurrentDate() async {
    currentDate = DateFormat("dd/MM/yyyy").format(DateTime.now());
  }

  // ═══════════════════════════════════════════════════════════
  //  TODAY'S ATTENDANCE STATE
  //  Fetches InTime / OutTime from the API and updates state.

  Future<void> getTodaysAttendanceState({required int emppk}) async {
    try {
      await _getCurrentDate();

      final response = await ApiClient.post(
        ApiConstants.getTodaysAttendance,
        data: {"Emp_PK": emppk, "AttendanceDate": currentDate},
      );

      print("Attendance Response => ${response.data}");

      final result = response.data["TodaysAttendanceResult"];

      if (result != null && result is List && result.isNotEmpty) {
        final String apiInTime = result[0]["InTime"]?.toString() ?? "";

        final String apiOutTime = result[0]["OutTime"]?.toString() ?? "";

        inTimeVal = apiInTime;
        outTimeVal = apiOutTime;

        print("InTime => $inTimeVal");
        print("OutTime => $outTimeVal");

        if (inTimeVal.isNotEmpty && outTimeVal.isEmpty) {
          await TrackingService().startTracking();
        } else if (outTimeVal.isNotEmpty) {
          await TrackingService().stopTracking();
        }
      } else {
        print("Attendance not available yet. Keeping current values.");
        // DO NOTHING
        // inTimeVal = '';
        // outTimeVal = '';
      }

      onStateChanged();
    } catch (e) {
      print("getTodaysAttendanceState error: $e");
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  LOAD USER PREFERENCES

  Future<void> loadUserPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    employeeCode = prefs.getString('employeecode') ?? '';
    employeename = prefs.getString('employeename') ?? '';
    emppk = prefs.getInt('emppk');
    companypk = prefs.getInt('Company_PK');
    locationpk = prefs.getInt('Location_PK');
    isAllowTrackingValue = prefs.getString('IsAllowTracking') ?? '';
    sharredTrackingValue = prefs.getInt('SharredTrackingValueDash');
    emppk_str = emppk?.toString() ?? '';
    companypk = prefs.getInt('companypk');
    locationpk = prefs.getInt('locationpk');
  }

  // ═══════════════════════════════════════════════════════════
  //  BUILDERS

  PunchRequestData _buildRequest({
    required String inTime,
    required String outTime,
    required String inOrOut,
  }) => PunchRequestData(
    empPk: emppk_str,
    employeeCode: employeeCode,
    attendanceDate: currentDate,
    applicationDate: currentDate,
    deviceId: _deviceId,
    latitude: _latitude,
    longitude: _longitude,
    locationPk: locationpk.toString(),
    companyPk: companypk.toString(),
    address: _address,
    batteryLevel: _batteryLevel.toString(),
    data: isOnline ? "ONLINE" : "OFFLine",
    location: isLocationOn ? "ON" : "OFF",
    inTime: inTime,
    outTime: outTime,
    inOrOut: inOrOut,
  );

  OfflinePunchRecord _buildOfflineRecord({
    required String inOrOut,
    required String inTime,
    required String outTime,
  }) => OfflinePunchRecord(
    localId: 0, // DB will assign the real ID on insert
    locationPk: locationpk_str,
    empPk: emppk_str,
    status: '',
    address: _address,
    companyPk: companypk_str,
    attendanceDate: currentDate,
    latitude: _latitude,
    inOrOut: inOrOut,
    timeCard: "1",
    applicationDate: currentDate,
    longitude: _longitude,
    allowTracking: isAllowTrackingValue,
    inTime: inTime,
    outTime: outTime,
    deviceId: _deviceId,
    data: "OFFLine",
    location: isLocationOn ? "ON" : "OFF",
    battery: _batteryLevel.toString(),
  );

  // ═══════════════════════════════════════════════════════════
  //  DIALOGS  — all use the shared ModernPunchDialog

  /// Confirmation dialog before submitting a punch.
  void _showPunchConfirmDialog({
    required String title,
    required Future<void> Function() onConfirmed,
  }) {
    final bool isIn = title == "INPUNCH";
    ModernPunchDialog.show(
      context: context,
      type: isIn ? PunchDialogType.checkIn : PunchDialogType.checkOut,
      onConfirmed: () async {
        _setLoading(true);
        await onConfirmed();
        _setLoading(false);
      },
    );
  }

  /// "Location must be ON" dialog.
  void _showLocationMustBeOnDialog() {
    ModernPunchDialog.show(
      context: context,
      type: PunchDialogType.locationOff,
      onConfirmed: () => Geolocator.openLocationSettings(),
    );
  }

  /// Offline in-punch saved — optionally starts tracking. show the msg
  // void _showSavedDialogWithTracking({required bool startTracking}) {
  //   ModernPunchDialog.show(
  //     context: context,
  //     type: PunchDialogType.savedOffline,
  //     onConfirmed: () {
  //       if (startTracking) {
  //         TrackingService().startTracking();
  //         print("PunchController: tracking started");
  //       }
  //       onStateChanged();
  //     },
  //   );
  // }

  /// Offline out-punch saved — stops tracking. show the msg
  // void _showSavedDialogWithTrackingStop() {
  //   ModernPunchDialog.show(
  //     context: context,
  //     type: PunchDialogType.savedOffline,
  //     onConfirmed: () {
  //       TrackingService().stopTracking();
  //       print("PunchController: tracking stopped");
  //       onStateChanged();
  //     },
  //   );
  // }

  /// Generic offline saved (no tracking change).
  void _showSavedDialog() {
    ModernPunchDialog.show(
      context: context,
      type: PunchDialogType.savedOffline,
      onConfirmed: () => onStateChanged(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  LOCAL NOTIFICATIONS

  Future<void> _showOfflineNotification({required bool isInPunch}) async {
    final plugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const androidDetails = AndroidNotificationDetails(
      'punch_channel',
      'Punch Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notifDetails = NotificationDetails(android: androidDetails);

    await plugin.show(
      id: 0,
      title: 'Attendance',
      body: isInPunch ? 'Offline In-Punch Saved' : 'Offline Out-Punch Saved',
      notificationDetails: notifDetails,
      payload: 'punch',
    );
  }

  void _setLoading(bool value) {
    isPunchLoading = value;
    onStateChanged();
  }
}