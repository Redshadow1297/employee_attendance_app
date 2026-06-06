// // ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/app_services/whatsapp_business_API.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/alert_box.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_datePicker.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // Leave type categories
// const List<String> _kNormalLeaves = [
//   'PL',
//   'TL',
//   'SL',
//   'CL',
//   'PH',
//   'AL',
//   'WFH',
//   'ML/SPL',
//   'ESI',
//   'AB',
// ];

// // OD sub-types
// enum OdSubType { halfDay, oneMoreDay, shortOD }

// class LeaveScreen extends StatefulWidget {
//   const LeaveScreen({super.key});

//   @override
//   State<LeaveScreen> createState() => _LeaveScreenState();
// }

// class _LeaveScreenState extends State<LeaveScreen> {
//   int? emppk;
//   String? empcode;
//   int? companypk;
//   int? locationpk;
//   String? empname;
//   int? isSuperAdmin;

//   bool showApplyLeaveForm = false;
//   bool isLoading = false;

//   // ── Leave status list ────────────────────────────────────────────────────
//   List<Map<String, dynamic>> leaveStatusList = [];

//   final TextEditingController _leaveReasonController = TextEditingController();
//   final TextEditingController strtDateController = TextEditingController();
//   final TextEditingController endDateController = TextEditingController();

//   List<Map<String, dynamic>> leaveTypeList = [];
//   List<Map<String, dynamic>> leaveBalanceList = [];
//   List<Map<String, dynamic>> coffBalanceList = [];

//   int? selectedLeaveTypeId;
//   String? selectedLeaveCode;
//   String? selectedLeaveDesc;
//   String? selectedLeavePK;

//   DateTime? startDate;
//   DateTime? endDate;

//   /// Radio value (mirrors   `value`):
//   ///   0 = Half Day / On-Date  |  1 = One or More Days  |  2 = Short OD
//   int leaveDayRadio = 0;

//   // Full-day / Half-day toggle (for normal leaves)
//   String leaveDayStatus = "F"; // "F" or "H"
//   String? halfDayType; // "H1" or "H2"

//   // COFF
//   int? selectedCoffIndex;
//   String? selectedCoffScheduleDate;
//   String? selectedCoffType;

//   // OD / SH times
//   String? _selectedTimeFrom;
//   String? _selectedTimeTo;
//   int _pickerHour = 0;
//   int _pickerMinute = 0;

//   // Seaco flavour flag  (set appFlavor from your env / build config)
//   bool get isSeaco => const String.fromEnvironment('APP_FLAVOR') == 'seaco';

//   bool isAuthorizationScreen = false;
//   bool isAuthLoading = false;
//   List<Map<String, dynamic>> users = [];
//   Map<String, String> companyMap = {};
//   String? selectedComp;
//   List searchEmp = [];
//   String selEmpCode = "";
//   final TextEditingController empNameController = TextEditingController();
//   int selectedApprovalTab = 0;

//   final List<Color> cardColors = [
//     Colors.orange,
//     Colors.blue,
//     Colors.green,
//     Colors.red,
//     Colors.purple,
//     Colors.teal,
//   ];

//   // ── Date helpers ──
//   String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

//   String get _fromDateStr => startDate != null ? formatDate(startDate!) : '';
//   String get _toDateStr => endDate != null ? formatDate(endDate!) : '';

//   //   helper methods
//   String getLeaveDayType(int v) => v == 0 ? "H" : "F";

//   String getFromDayStatus(String v) {
//     if (v == "Full Day") return "F";
//     if (v == "First Half") return "H1";
//     if (v == "Second Half") return "H2";
//     return "F";
//   }

//   String getToDayStatus(String v) {
//     if (v == "Full Day") return "F";
//     if (v == "First Half") return "H1";
//     if (v == "Second Half") return "H2";
//     return "F";
//   }

//   String getToDayStatus_HalfDay(String? v) {
//     if (v == "H1") return "H1";
//     if (v == "H2") return "H2";
//     return "H1";
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     getCompanyList();
//   }

//   Future<void> _initializeData() async {
//     await _getPrefsData();
//     if (emppk == null) return;
//     await Future.wait([
//       loadLeaveStatus(),
//       fetchLeaveBalance(),
//       fetchCoffBalance(),
//       fetchLeaveTypes(),
//     ]);
//   }

//   Future<void> _getPrefsData() async {
//     final prefs = await SharedPreferences.getInstance();
//     emppk = prefs.getInt("emppk");
//     empcode = prefs.getString("employeecode");
//     companypk = prefs.getInt("companypk");
//     locationpk = prefs.getInt("locationpk");
//     empname = prefs.getString("employeename");
//     isSuperAdmin = int.tryParse(prefs.getString("issuperadmin") ?? "0") ?? 0;
//   }

//   @override
//   void dispose() {
//     _leaveReasonController.dispose();
//     strtDateController.dispose();
//     endDateController.dispose();
//     empNameController.dispose();
//     super.dispose();
//   }

//   // API calls
//   Future<void> loadLeaveStatus() async {
//     setState(() => isLoading = true);
//     leaveStatusList = await _getLeaveStatusList();
//     setState(() => isLoading = false);
//   }

//   ///Get Leave Application Status List
//   Future<List<Map<String, dynamic>>> _getLeaveStatusList() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getLeaveStatus,
//         query: {"Emp_PK": emppk},
//       );
//       final data = response.data;
//       if (data is List) return List<Map<String, dynamic>>.from(data);
//       if (data is Map && data["GetLeaveStatus_List"] != null) {
//         return List<Map<String, dynamic>>.from(data["GetLeaveStatus_List"]);
//       }
//     } catch (e) {
//       debugPrint("Leave Status Error: $e");
//     }
//     return [];
//   }

//   ////Fetch Leave Balance
//   Future<void> fetchLeaveBalance() async {
//     try {
//       final response = await ApiClient.get(
//         "Leave_Services.svc/GetLeaveBalance",
//         query: {
//           "Emp_PK": emppk,
//           "Leave_Code": "Leave",
//           "Location_PK": locationpk,
//         },
//       );
//       final data = response.data;
//       if (data != null && data["GetLeaveBalanceResult"] != null) {
//         setState(() {
//           leaveBalanceList = List<Map<String, dynamic>>.from(
//             (data["GetLeaveBalanceResult"] as List).where(
//               (e) => e["Flag"] != "C-OFF",
//             ),
//           );
//         });
//       }
//     } catch (e) {
//       debugPrint("Leave Balance Error: $e");
//     }
//   }

//   //Fetching COFF balance
//   Future<void> fetchCoffBalance() async {
//     try {
//       final response = await ApiClient.get(
//         "Leave_Services.svc/GetLeaveBalance",
//         query: {
//           "Emp_PK": emppk,
//           "Leave_Code": "C-OFF",
//           "Location_PK": locationpk,
//         },
//       );
//       final data = response.data;
//       if (data != null && data["GetLeaveBalanceResult"] != null) {
//         setState(() {
//           coffBalanceList = List<Map<String, dynamic>>.from(
//             (data["GetLeaveBalanceResult"] as List).where(
//               (e) => e["Flag"] == "C-OFF",
//             ),
//           );
//         });
//       }
//     } catch (e) {
//       debugPrint("COFF Balance Error: $e");
//     }
//   }

//   //Fetching leave Types
//   Future<void> fetchLeaveTypes() async {
//     try {
//       setState(() => isLoading = true);
//       final response = await ApiClient.get(
//         ApiConstants.getLeaveType,
//         query: {"Emp_PK": emppk},
//       );
//       final data = response.data;
//       if (data is Map && data["LeaveLists"] != null) {
//         setState(() {
//           leaveTypeList = List<Map<String, dynamic>>.from(data["LeaveLists"]);
//         });
//       }
//     } catch (e) {
//       debugPrint("Leave Type Error: $e");
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // ── Shift default times (OD) ───────
//   Future<void> _fetchShiftTime(String horF, String forS) async {
//     try {
//       final response = await ApiClient.get(ApiConstants.getShiftTime);
//       if (response.statusCode == 200) {
//         final start = DateFormat("HH:mm").parse(response.data['starttime']);
//         final end = DateFormat("HH:mm").parse(response.data['endtime']);
//         setState(() {
//           _selectedTimeFrom = DateFormat.jm().format(start);
//           _selectedTimeTo = DateFormat.jm().format(end);
//         });
//       }
//     } catch (e) {
//       debugPrint("ShiftTime Error: $e");
//     }
//   }

//   // Leave type selection
//   void _onLeaveTypeSelected(Map<String, dynamic> leave) {
//     setState(() {
//       selectedLeaveTypeId = int.tryParse(leave["Leave_PK"].toString());
//       selectedLeaveCode = leave["Leave_Code"]?.toString();
//       selectedLeaveDesc = leave["Leave_Description"]?.toString();
//       selectedLeavePK = leave["Leave_PK"].toString();

//       // Reset form
//       leaveDayRadio = 0;
//       leaveDayStatus = "F";
//       halfDayType = null;
//       startDate = null;
//       endDate = null;
//       strtDateController.clear();
//       endDateController.clear();
//       _leaveReasonController.clear();
//       selectedCoffIndex = null;
//       selectedCoffScheduleDate = null;
//       selectedCoffType = null;
//       _selectedTimeFrom = null;
//       _selectedTimeTo = null;

//       // OD: pre-load half-day shift times
//       if (selectedLeaveCode == "OD") {
//         _fetchShiftTime("H", "H1");
//       }
//     });
//   }

//   // Date pickers
//   bool get _isSingleDay =>
//       selectedLeaveCode == 'C-OFF' ||
//       selectedLeaveCode == 'C-Off' ||
//       leaveDayRadio == 0;

//   Future<void> _pickStartDate() async {
//     final picked = await CommonDatePicker.pickDate(context: context);
//     if (picked == null) return;
//     setState(() {
//       startDate = picked;
//       strtDateController.text = DateFormat('dd-MM-yyyy').format(picked);
//       if (_isSingleDay) {
//         endDate = picked;
//         endDateController.text = strtDateController.text;
//       } else if (endDate != null && endDate!.isBefore(picked)) {
//         endDate = null;
//         endDateController.clear();
//       }
//     });
//   }

//   ///Pick End Date
//   Future<void> _pickEndDate() async {
//     if (_isSingleDay) {
//       CommonSnackBar.show(
//         context: context,
//         title: "Info",
//         message: selectedLeaveCode == 'C-OFF'
//             ? "COFF can be applied for only one day"
//             : "Half day leave can be applied for only one day",
//         type: SnackBarType.warning,
//       );
//       return;
//     }
//     if (startDate == null) {
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "Please select start date first.",
//         type: SnackBarType.error,
//       );
//       return;
//     }
//     final picked = await CommonDatePicker.pickDate(
//       context: context,
//       initialDate: startDate,
//       firstDate: startDate,
//     );
//     if (picked == null) return;
//     setState(() {
//       endDate = picked;
//       endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
//     });
//   }

//   // Custom Time Picker
//   Future<void> _showTimePicker(String label) async {
//     int tempH = _pickerHour, tempM = _pickerMinute;
//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx, snap) => AlertDialog(
//           title: Text("Select $label"),
//           content: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _numberScroll(tempH, 0, 23, (v) => snap(() => tempH = v)),
//               const Text("  :  ", style: TextStyle(fontSize: 20)),
//               _numberScroll(tempM, 0, 59, (v) => snap(() => tempM = v)),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: const Text("Cancel"),
//               onPressed: () => Navigator.pop(ctx),
//             ),
//             TextButton(
//               child: const Text("OK"),
//               onPressed: () {
//                 final dt = DateTime(0, 1, 1, tempH, tempM);
//                 final formatted = DateFormat.jm().format(dt);
//                 setState(() {
//                   _pickerHour = tempH;
//                   _pickerMinute = tempM;
//                   if (label == "From Time") {
//                     _selectedTimeFrom = formatted;
//                   } else {
//                     _selectedTimeTo = formatted;
//                   }
//                 });
//                 Navigator.pop(ctx);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _numberScroll(
//     int current,
//     int min,
//     int max,
//     ValueChanged<int> onChanged,
//   ) {
//     return SizedBox(
//       width: 60,
//       height: 120,
//       child: ListWheelScrollView.useDelegate(
//         itemExtent: 40,
//         onSelectedItemChanged: onChanged,
//         controller: FixedExtentScrollController(initialItem: current - min),
//         childDelegate: ListWheelChildBuilderDelegate(
//           childCount: max - min + 1,
//           builder: (_, i) => Center(
//             child: Text(
//               (min + i).toString().padLeft(2, '0'),
//               style: const TextStyle(fontSize: 22),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Validation
//   bool _validate() {
//     final code = selectedLeaveCode ?? "";

//     if (selectedLeaveTypeId == null) {
//       _warn("Please select leave type.");
//       return false;
//     }
//     if (startDate == null) {
//       _warn("Please select start date.");
//       return false;
//     }
//     if (_leaveReasonController.text.trim().isEmpty) {
//       _warn("Please enter reason.");
//       return false;
//     }

//     // Normal half-day
//     if (_kNormalLeaves.contains(code) && leaveDayRadio == 0) {
//       if (halfDayType == null && !(isSeaco && code == "PL")) {
//         _warn("Please select First Half or Second Half.");
//         return false;
//       }
//     }

//     // COFF – user must pick a COFF record
//     if (code == "C-OFF" || code == "C-Off") {
//       if (selectedCoffScheduleDate == null) {
//         _warn("Please select a pending C-OFF record.");
//         return false;
//       }
//     }

//     // OD / SH – times required
//     if ((code == "OD" || code == "SH") &&
//         (_selectedTimeFrom == null || _selectedTimeTo == null)) {
//       _warn("Please select From Time and To Time.");
//       return false;
//     }

//     return true;
//   }

//   void _warn(String msg) => CommonSnackBar.show(
//     context: context,
//     title: "Warning",
//     message: msg,
//     type: SnackBarType.warning,
//   );

//   // Format time helper (mirrors   formatTime)
//   String _formatTimeTo24(String? t) {
//     if (t == null) return "00:00";
//     try {
//       final clean = t.replaceAll(RegExp(r'\u202f'), ' ').trim();
//       final parsed = DateFormat("hh:mm a").parse(clean);
//       return DateFormat("HH:mm").format(parsed);
//     } catch (_) {
//       return "00:00";
//     }
//   }

//   // Total days
//   double _totalDays() {
//     if (startDate == null || endDate == null) return 0;
//     final code = selectedLeaveCode ?? "";
//     // Short OD & SH = 0 days deducted
//     if (code == "SH" || (code == "OD" && leaveDayRadio == 2)) return 0;
//     if (leaveDayRadio == 0 && _kNormalLeaves.contains(code)) return 0.5;
//     return endDate!.difference(startDate!).inDays + 1;
//   }

//   // Submit Leave Application
//   Future<void> _submitLeave() async {
//     if (!_validate()) return;

//     setState(() => isLoading = true);
//     try {
//       final now = DateTime.now();
//       final code = selectedLeaveCode ?? "";
//       final from = _fromDateStr;
//       final to = _toDateStr.isNotEmpty ? _toDateStr : from;
//       final days = _totalDays();

//       Map<String, dynamic> payload;

//       if (code == "SH") {
//         // ── Short leave ────────────────────────────────────────────────────
//         payload = {
//           "SHDate": to,
//           "ShReason": _leaveReasonController.text.trim(),
//           "Emp_PK": emppk,
//           "FromTime": _formatTimeTo24(_selectedTimeFrom),
//           "ToTime": _formatTimeTo24(_selectedTimeTo),
//         };
//         final resp = await ApiClient.post(
//           ApiConstants.shortLeaveURL,
//           data: payload,
//         );
//         final msg = resp.data["ShortLeaveApplicationResult"]?.toString() ?? "";
//         _handleResponse(msg);
//         return;
//       }

//       if (code == "C-OFF" || code == "C-Off") {
//         // ── COFF ──────────────────────────────────────────────────────────
//         payload = _buildPayload(
//           now: now,
//           from: to, // COFF uses toDate as fromDate
//           to: to,
//           days: days,
//           offDate: selectedCoffScheduleDate ?? to,
//           coffDate: to,
//           fromStatus: leaveDayRadio == 0
//               ? getToDayStatus_HalfDay(halfDayType)
//               : getFromDayStatus("Full Day"),
//           toStatus: leaveDayRadio == 0
//               ? getToDayStatus_HalfDay(halfDayType)
//               : getToDayStatus("Full Day"),
//           fromTime: "00:00",
//           toTime: "00:00",
//           leaveDaySt: getLeaveDayType(leaveDayRadio),
//           extraFields: {"Cofftype": selectedCoffType},
//         );
//       } else if (code == "OD") {
//         // ── OD ────────────────────────────────────────────────────────────
//         if (leaveDayRadio == 0) {
//           // Half day OD
//           payload = _buildPayload(
//             now: now,
//             from: to,
//             to: to,
//             days: days,
//             offDate: to,
//             coffDate: to,
//             fromStatus: getToDayStatus_HalfDay(halfDayType),
//             toStatus: getToDayStatus_HalfDay(halfDayType),
//             fromTime: _formatTimeTo24(_selectedTimeFrom),
//             toTime: _formatTimeTo24(_selectedTimeTo),
//             leaveDaySt: getLeaveDayType(0),
//           );
//         } else if (leaveDayRadio == 1) {
//           // One or more days OD
//           payload = _buildPayload(
//             now: now,
//             from: from,
//             to: to,
//             days: days,
//             offDate: to,
//             coffDate: to,
//             fromStatus: getFromDayStatus("Full Day"),
//             toStatus: getToDayStatus("Full Day"),
//             fromTime: _formatTimeTo24(_selectedTimeFrom),
//             toTime: _formatTimeTo24(_selectedTimeTo),
//             leaveDaySt: getLeaveDayType(1),
//           );
//         } else {
//           // Short OD
//           payload = _buildPayload(
//             now: now,
//             from: to,
//             to: to,
//             days: days,
//             offDate: to,
//             coffDate: to,
//             fromStatus: getFromDayStatus("Full Day"),
//             toStatus: getToDayStatus("Full Day"),
//             fromTime: _formatTimeTo24(_selectedTimeFrom),
//             toTime: _formatTimeTo24(_selectedTimeTo),
//             leaveDaySt: "O",
//           );
//         }
//       } else if (leaveDayRadio == 0 &&
//           (_kNormalLeaves.contains(code) || code == "LWP" || code == "MRGL")) {
//         // ── Half day (normal leaves, LWP, MRGL) ───────────────────────────
//         payload = _buildPayload(
//           now: now,
//           from: to,
//           to: to,
//           days: days,
//           offDate: to,
//           coffDate: to,
//           fromStatus: getToDayStatus_HalfDay(halfDayType),
//           toStatus: getToDayStatus_HalfDay(halfDayType),
//           fromTime: _formatTimeTo24(_selectedTimeFrom),
//           toTime: _formatTimeTo24(_selectedTimeTo),
//           leaveDaySt: getLeaveDayType(0),
//         );
//       } else {
//         // ── One or more days (normal, LWP, ML, MRGL) ──────────────────────
//         payload = _buildPayload(
//           now: now,
//           from: from,
//           to: to,
//           days: days,
//           offDate: to,
//           coffDate: to,
//           fromStatus: getFromDayStatus("Full Day"),
//           toStatus: getToDayStatus("Full Day"),
//           fromTime: "00:00",
//           toTime: "00:00",
//           leaveDaySt: getLeaveDayType(1),
//         );
//       }

//       final resp = await ApiClient.post(
//         ApiConstants.submitLeaveApplication,
//         data: payload,
//       );
//       final msg = resp.data.toString();
//       _handleResponse(msg);
//     } catch (e) {
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "Failed to apply leave. $e",
//         type: SnackBarType.error,
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   Map<String, dynamic> _buildPayload({
//     required DateTime now,
//     required String from,
//     required String to,
//     required double days,
//     required String offDate,
//     required String coffDate,
//     required String fromStatus,
//     required String toStatus,
//     required String fromTime,
//     required String toTime,
//     required String leaveDaySt,
//     Map<String, dynamic>? extraFields,
//   }) {
//     final base = {
//       "Emp_PK": emppk,
//       "LeaveToDate": to,
//       "Leave_PK": selectedLeavePK,
//       "Created_On": now.toString(),
//       "Leave_Code": selectedLeaveCode,
//       "NoOfLeaves": days.toString(),
//       "OFFDate": offDate,
//       "ContinuePendingLeave": "No",
//       "Reason": _leaveReasonController.text.trim(),
//       "Updated_By": emppk,
//       "FromDateStatus": fromStatus,
//       "LeaveFromDate": from,
//       "ToDateStatus": toStatus,
//       "Location_PK": locationpk,
//       "LeaveApplicationDate": formatDate(now),
//       "COFFDate": coffDate,
//       "ToTime": toTime,
//       "Company_PK": companypk,
//       "LeaveDayStatus": leaveDaySt,
//       "Updated_On": now.toString(),
//       "Employee_Name": empname,
//       "Created_By": emppk,
//       "Employee_Code": empcode,
//       "FromTime": fromTime,
//     };
//     if (extraFields != null) base.addAll(extraFields);
//     return base;
//   }

//   void _handleResponse(String msg) {
//     if (msg.toLowerCase().contains("success") || msg.isNotEmpty) {
//       CommonSnackBar.show(
//         context: context,
//         title: msg.toLowerCase().contains("success") ? "Success" : "Info",
//         message: msg,
//         type: msg.toLowerCase().contains("success")
//             ? SnackBarType.success
//             : SnackBarType.warning,
//       );
//       if (msg.toLowerCase().contains("success")) sendWhatsAppMessage();
//     } else {
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "Something went wrong.",
//         type: SnackBarType.error,
//       );
//     }
//     _resetForm();
//     loadLeaveStatus();
//     fetchLeaveBalance();
//     fetchCoffBalance();
//   }

//   void _resetForm() {
//     setState(() {
//       showApplyLeaveForm = false;
//       selectedLeaveTypeId = null;
//       selectedLeaveCode = null;
//       selectedLeaveDesc = null;
//       selectedLeavePK = null;
//       startDate = null;
//       endDate = null;
//       leaveDayRadio = 0;
//       leaveDayStatus = "F";
//       halfDayType = null;
//       selectedCoffIndex = null;
//       selectedCoffScheduleDate = null;
//       selectedCoffType = null;
//       _selectedTimeFrom = null;
//       _selectedTimeTo = null;
//       strtDateController.clear();
//       endDateController.clear();
//       _leaveReasonController.clear();
//     });
//   }

//   // Self-reject
//   Future<void> _selfRejectLeave(Map<String, dynamic> leave) async {
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.leaveSelfReject,
//         data: {
//           "Leave_Code": leave["LeaveCode"],
//           "Emp_Pk": emppk,
//           "Trans_PK": leave["Trans_Pk"],
//         },
//       );
//       final data = jsonDecode(response.toString());
//       final msg = data["LeaveSelfRejectResult"] as String? ?? "Failed.";
//       CommonSnackBar.show(
//         context: context,
//         title: msg.isEmpty ? "Error" : "Success",
//         message: msg.isEmpty ? "Failed to reject." : msg,
//         type: msg.isEmpty ? SnackBarType.error : SnackBarType.success,
//       );
//       loadLeaveStatus();
//       fetchLeaveBalance();
//     } catch (_) {
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "Failed to reject leave.",
//         type: SnackBarType.error,
//       );
//     }
//   }

//   // Authorization helpers
//   Future<void> getCompanyList() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getCompanyGroupList,
//         query: {},
//       );
//       final data = response.data;
//       if (data is List) {
//         companyMap.clear();
//         for (final item in data) {
//           companyMap[item["Company_Name"].toString()] =
//               item["CompanyGroupDBName"].toString();
//         }
//         selectedComp = companyMap.values.first;
//         getLeaveAuthorizationList(0);
//       }
//     } catch (e) {
//       debugPrint("Company List Error: $e");
//     }
//   }

//   ////Get Leave Applications List for Authorization
//   Future<void> getLeaveAuthorizationList(int index) async {
//     selectedApprovalTab = index;
//     const statuses = ["Pending", "Approved", "Rejected"];
//     setState(() {
//       isAuthLoading = true;
//       users.clear();
//     });
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getLeaveAuthorization,
//         query: {
//           "Emp_PK": emppk,
//           "EmpCode": selEmpCode,
//           "Status": statuses[index],
//           "FromDate": "",
//           "ToDate": "",
//           "CompanyGroupDBName": selectedComp,
//         },
//       );
//       final data = response.data;
//       if (data is List) {
//         users = List<Map<String, dynamic>>.from(data);
//       } else if (data is Map && data["GetLeaveAuthorization_List"] != null) {
//         users = List<Map<String, dynamic>>.from(
//           data["GetLeaveAuthorization_List"],
//         );
//       } else {
//         users = [];
//       }
//     } catch (e) {
//       debugPrint("Authorization Error: $e");
//     }
//     setState(() => isAuthLoading = false);
//   }

//   /////Get Employee List for search Employeee
//   Future<void> getEmployeeNameSearch(int? pk) async {
//     setState(() {
//       isLoading = true;
//       searchEmp.clear();
//     });
//     try {
//       final company = selectedComp ?? "";
//       final response = await ApiClient.get(
//         "${ApiConstants.searchEmployeeNameCode}?Emp_PK=${pk ?? 0}"
//         "&Searchtxt=${empNameController.text}&CompanyGroupDBName=$company",
//       );
//       dynamic data = response.data;
//       if (data is String) data = jsonDecode(data);
//       final list = data["AutoCompleteData_LeaveReportingResult"] as List? ?? [];
//       final uniqueItems = <String>{};
//       searchEmp = list
//           .where((item) => uniqueItems.add(item.toString()))
//           .map<Map<String, dynamic>>((item) {
//             final parts = item.toString().split(":");
//             return {
//               "Employee_Code": parts.isNotEmpty ? parts[0] : "",
//               "EmpName": parts.length > 1 ? parts[1] : "",
//             };
//           })
//           .toList();
//     } catch (e) {
//       debugPrint("Emp Search Error: $e");
//     }
//     if (mounted) setState(() => isLoading = false);
//   }

//   void _resetAuthorizationFilters() {
//     empNameController.clear();
//     selEmpCode = "";
//     searchEmp.clear();
//     if (companyMap.isNotEmpty) selectedComp = companyMap.values.first;
//     selectedApprovalTab = 0;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return WillPopScope(
//       onWillPop: () async {
//         if (showApplyLeaveForm) {
//           setState(() => showApplyLeaveForm = false);
//           return false;
//         }
//         if (isAuthorizationScreen) {
//           setState(() {
//             _resetAuthorizationFilters();
//             isAuthorizationScreen = false;
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
//         body: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _header(isDark),
//                 const SizedBox(height: 80),
//                 if (isAuthorizationScreen) const SizedBox(height: 13),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
//                   child: Text(
//                     "Leave History",
//                     style: AppTextStyles.headingSmall.copyWith(
//                       color: isDark ? Colors.white : null,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: isAuthorizationScreen
//                       ? _leaveAuthorizationData(isDark: isDark)
//                       : Padding(
//                           padding: const EdgeInsets.all(8),
//                           child: isLoading
//                               ? const Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.blueGrey,
//                                   ),
//                                 )
//                               : leaveStatusList.isEmpty
//                               ? Center(
//                                   child: Text(
//                                     "No Leave History Found.",
//                                     style: TextStyle(
//                                       color: isDark ? Colors.white54 : null,
//                                     ),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   padding: const EdgeInsets.only(top: 10),
//                                   itemCount: leaveStatusList.length,
//                                   itemBuilder: (_, i) => _leaveCard(
//                                     leaveStatusList[i],
//                                     isDark: isDark,
//                                   ),
//                                 ),
//                         ),
//                 ),
//               ],
//             ),

//             // Balance cards overlay
//             Positioned(
//               top: 210,
//               left: 8,
//               right: 8,
//               child: _balanceCards(isDark: isDark),
//             ),

//             // Apply leave form overlay
//             if (showApplyLeaveForm)
//               Positioned(
//                 top: 200,
//                 left: 16,
//                 right: 16,
//                 child: _applyLeaveForm(isDark: isDark),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // HEADER
//   Widget _header(bool isDark) {
//     return Container(
//       height: 270,
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color.fromARGB(255, 238, 125, 44),
//             Color.fromARGB(255, 174, 74, 2),
//           ],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: () {
//               if (!isAuthorizationScreen) {
//                 Navigator.pop(context);
//               } else {
//                 setState(() {
//                   getLeaveAuthorizationList(0);
//                   isAuthorizationScreen = false;
//                 });
//               }
//             },
//             child: CircleAvatar(
//               backgroundColor: Colors.white.withOpacity(0.15),
//               child: const Icon(Icons.arrow_back, color: Colors.white),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Leave",
//                     style: AppTextStyles.headingLarge.copyWith(
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     "Management",
//                     style: AppTextStyles.headingLarge.copyWith(
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Manage Your Leave Requests.",
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   CommonButton(
//                     width: 145,
//                     height: 40,
//                     color: Colors.white,
//                     label: "Apply Leave",
//                     icon: const Icon(Icons.add, color: Colors.lightGreen),
//                     textColor: Colors.lightGreen,
//                     onPressed: () => setState(
//                       () => showApplyLeaveForm = !showApplyLeaveForm,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   if (!isAuthorizationScreen)
//                     CommonButton(
//                       width: 175,
//                       height: 42,
//                       color: Colors.white,
//                       label: "Authorization",
//                       icon: const Icon(
//                         Icons.verified_user,
//                         color: Colors.lightBlue,
//                         size: 19,
//                       ),
//                       textColor: Colors.lightGreen,
//                       onPressed: () {
//                         setState(() => isAuthorizationScreen = true);
//                         getLeaveAuthorizationList(0);
//                       },
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // BALANCE CARDS
//   Widget _balanceCards({bool isDark = false}) {
//     return SizedBox(
//       height: 145,
//       child: leaveBalanceList.isEmpty
//           ? Center(
//               child: Text(
//                 "No leave balance available",
//                 style: AppTextStyles.labelMedium.copyWith(color: Colors.grey),
//               ),
//             )
//           : ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: leaveBalanceList.length,
//               itemBuilder: (_, i) {
//                 final leave = leaveBalanceList[i];
//                 return Container(
//                   width: 104,
//                   height: 170,
//                   margin: const EdgeInsets.only(right: 12),
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: isDark
//                           ? Colors.white12
//                           : const Color.fromARGB(255, 242, 225, 220),
//                     ),
//                     color: isDark
//                         ? const Color(0xFF1E293B)
//                         : const Color.fromARGB(255, 248, 255, 254),
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [
//                       BoxShadow(
//                         color: isDark
//                             ? Colors.black.withOpacity(0.4)
//                             : Colors.black12,
//                         spreadRadius: 1,
//                         blurRadius: 4,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       Container(
//                         height: 4,
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: cardColors[i % cardColors.length],
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(12),
//                             topRight: Radius.circular(12),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 45),
//                       Column(
//                         children: [
//                           Text(
//                             leave["Leave_Title"].toString(),
//                             style: AppTextStyles.headingSmall.copyWith(
//                               color: isDark ? Colors.white54 : Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             leave["No_of_Leave"].toString(),
//                             style: AppTextStyles.headingMedium.copyWith(
//                               color: isDark ? Colors.white : null,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }

//   // APPLY LEAVE FORM
//   Widget _applyLeaveForm({bool isDark = false}) {
//     final code = selectedLeaveCode ?? "";

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.5) : Colors.black26,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Title ────────────────────────────────────────────────────
//             Text(
//               "Apply for Leave",
//               style: AppTextStyles.headingSmall.copyWith(
//                 color: isDark ? Colors.white : null,
//               ),
//             ),
//             const SizedBox(height: 14),

//             // ── Leave type grid (  style chips) ──────────────────────
//             _leaveTypeChips(isDark),
//             const SizedBox(height: 8),

//             // ── Show selected leave name ──────────────────────────────────
//             if (selectedLeaveDesc != null)
//               Text(
//                 selectedLeaveDesc!,
//                 style: const TextStyle(color: Colors.redAccent, fontSize: 15),
//               ),
//             const SizedBox(height: 10),

//             // ── Leave balance inline ──────────────────────────────────────
//             if (code.isEmpty ||
//                 _kNormalLeaves.contains(code) ||
//                 code == "LWP" ||
//                 code == "MRGL" ||
//                 code == "SH" ||
//                 code == "ML")
//               _inlineLeaveBalance(isDark),

//             // ── COFF pending records ──────────────────────────────────────
//             if (code == "C-OFF" || code == "C-Off")
//               _coffBalanceSelector(isDark),

//             if (code.isEmpty) ...[
//               const SizedBox(height: 10),
//               Center(
//                 child: Text(
//                   "First Select Leave Type...",
//                   style: TextStyle(
//                     color: isDark ? Colors.white70 : Colors.black54,
//                   ),
//                 ),
//               ),
//             ],

//             // ── Day radio buttons ─────────────────────────────────────────
//             if (code.isNotEmpty && code != "SH" && code != "ML")
//               _radioButtons(isDark, code),

//             const SizedBox(height: 8),

//             // ── Date section (varies by leave type) ──────────────────────
//             if (code.isNotEmpty) _datePicker(isDark, code),

//             const SizedBox(height: 8),

//             // ── Half-day selector ─────────────────────────────────────────
//             if (_shouldShowHalfDayDropdown(code)) _halfDayDropdown(isDark),

//             // ── OD / SH time picker ───────────────────────────────────────
//             if (code == "OD" || code == "SH") _timePickers(isDark),

//             const SizedBox(height: 12),

//             // ── Reason ────────────────────────────────────────────────────
//             if (code.isNotEmpty) ...[
//               Text(
//                 "Reason",
//                 style: AppTextStyles.labelMedium.copyWith(
//                   color: isDark ? Colors.white70 : null,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: _leaveReasonController,
//                 style: TextStyle(color: isDark ? Colors.white : null),
//                 decoration: InputDecoration(
//                   labelText: "Please enter reason.",
//                   labelStyle: TextStyle(color: isDark ? Colors.white54 : null),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: isDark ? Colors.white24 : Colors.grey,
//                     ),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(
//                       color: isDark ? Colors.white24 : Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],

//             // ── Buttons ───────────────────────────────────────────────────
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 CommonButton(
//                   width: 160,
//                   height: 40,
//                   color: const Color.fromARGB(255, 237, 86, 41),
//                   label: "Submit Request",
//                   onPressed: _submitLeave,
//                   textColor: Colors.white,
//                   icon: null,
//                 ),
//                 CommonButton(
//                   width: 160,
//                   height: 40,
//                   color: isDark
//                       ? const Color(0xFF334155)
//                       : const Color.fromARGB(255, 239, 235, 235),
//                   label: "Cancel",
//                   textColor: isDark ? Colors.white : Colors.black,
//                   onPressed: () => setState(() => showApplyLeaveForm = false),
//                   icon: null,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Leave type chip grid (matches   grid layout) ─────────────────────
//   Widget _leaveTypeChips(bool isDark) {
//     return Wrap(
//       spacing: 8,
//       runSpacing: 6,
//       children: leaveTypeList.map((leave) {
//         final pk = int.tryParse(leave["Leave_PK"].toString());
//         final isChosen = pk == selectedLeaveTypeId;
//         return OutlinedButton(
//           style: OutlinedButton.styleFrom(
//             side: BorderSide(color: isChosen ? Colors.green : Colors.grey),
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//           ),
//           onPressed: () => _onLeaveTypeSelected(leave),
//           child: Text(
//             leave["Leave_Title"] ?? "",
//             style: TextStyle(
//               color: isChosen
//                   ? Colors.green
//                   : (isDark ? Colors.white : Colors.black),
//               fontSize: 13,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // ── Inline leave balance row ──────────────────────────────────────────────
//   Widget _inlineLeaveBalance(bool isDark) {
//     if (leaveBalanceList.isEmpty) return const SizedBox();
//     return SizedBox(
//       height: 90,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: leaveBalanceList.length,
//         itemBuilder: (_, i) {
//           final item = leaveBalanceList[i];
//           return Card(
//             elevation: 3,
//             shadowColor: Colors.orange,
//             child: Column(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 45,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFFDD148),
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(10),
//                     ),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(item['No_of_Leave'].toString()),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   item['Leave_Title'].toString(),
//                   style: const TextStyle(fontSize: 11),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── COFF pending records (radio selection –   pattern) ────────────────
//   Widget _coffBalanceSelector(bool isDark) {
//     if (coffBalanceList.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         child: Text(
//           "No pending C-OFF records.",
//           style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
//         ),
//       );
//     }
//     return SizedBox(
//       height: 160,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: coffBalanceList.length,
//         itemBuilder: (_, i) {
//           final item = coffBalanceList[i];
//           return SizedBox(
//             width: 300,
//             child: Card(
//               elevation: 6,
//               shadowColor: Colors.orange,
//               child: RadioListTile<int>(
//                 value: i,
//                 groupValue: selectedCoffIndex,
//                 onChanged: (v) {
//                   setState(() {
//                     selectedCoffIndex = v;
//                     selectedCoffScheduleDate = item["ScheduleDate"]?.toString();
//                     selectedCoffType = item["CoffType"]?.toString();
//                   });
//                 },
//                 title: Text(
//                   item["ScheduleDate"]?.toString() ?? "",
//                   style: TextStyle(color: isDark ? Colors.white : null),
//                 ),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item["Status"]?.toString() ?? "",
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.black,
//                       ),
//                     ),
//                     Text(
//                       "Lapsed: ${item['LapsedDate'] ?? ''}",
//                       style: TextStyle(
//                         color: isDark ? Colors.white70 : Colors.black,
//                       ),
//                     ),
//                     Text(
//                       "IN: ${item['InTime']}  Out: ${item['OutTime']}",
//                       style: TextStyle(
//                         color: isDark ? Colors.white60 : Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       item["CoffType"]?.toString() ?? "",
//                       style: const TextStyle(color: Colors.green),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ── Radio buttons (Half Day / One or More Days / Short OD) ───────────────
//   Widget _radioButtons(bool isDark, String code) {
//     // OD has 3 options; others have 2 (with Seaco PL restriction)
//     final bool isOD = code == "OD";
//     final bool hidHalf = isSeaco && code == "PL";

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Wrap(
//         spacing: 8,
//         children: [
//           if (!hidHalf) _radioChip("Half Day", 0, isDark),
//           if (!hidHalf) const SizedBox(width: 4),
//           _radioChip("One or More Days", 1, isDark),
//           if (isOD) _radioChip("Short OD", 2, isDark),
//         ],
//       ),
//     );
//   }

//   Widget _radioChip(String label, int v, bool isDark) {
//     final selected = leaveDayRadio == v;
//     return OutlinedButton(
//       style: OutlinedButton.styleFrom(
//         side: BorderSide(color: selected ? Colors.green : Colors.grey),
//       ),
//       onPressed: () {
//         setState(() {
//           leaveDayRadio = v;
//           // If switching to half day – sync dates
//           if (v == 0 && startDate != null) {
//             endDate = startDate;
//             endDateController.text = strtDateController.text;
//           }
//           // Refresh shift times for OD
//           if (selectedLeaveCode == "OD") {
//             final horf = v == 0 ? "H" : "F";
//             _fetchShiftTime(horf, "H1");
//           }
//         });
//       },
//       child: Text(
//         label,
//         style: TextStyle(
//           color: selected
//               ? Colors.green
//               : (isDark ? Colors.white : Colors.black),
//         ),
//       ),
//     );
//   }

//   // ── Date row ─────────────────────────────────────────────────────────────
//   Widget _datePicker(bool isDark, String code) {
//     final bool singleDate =
//         _isSingleDay ||
//         code == "ML" || // ML = From Date only
//         code == "SH"; // SH = On Date only

//     if (singleDate) {
//       return _dateField("On Date", strtDateController, _pickStartDate, isDark);
//     }

//     // "One or more days" – show From + To
//     return Row(
//       children: [
//         Expanded(
//           child: _dateField(
//             "From Date",
//             strtDateController,
//             _pickStartDate,
//             isDark,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _dateField("To Date", endDateController, _pickEndDate, isDark),
//         ),
//       ],
//     );
//   }

//   Widget _dateField(
//     String label,
//     TextEditingController ctrl,
//     VoidCallback onTap,
//     bool isDark,
//   ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.labelMedium.copyWith(
//             color: isDark ? Colors.white70 : null,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextField(
//           controller: ctrl,
//           onTap: onTap,
//           readOnly: true,
//           style: TextStyle(color: isDark ? Colors.white : null),
//           decoration: InputDecoration(
//             suffixIcon: Icon(
//               Icons.calendar_month_outlined,
//               color: isDark ? Colors.white54 : null,
//             ),
//             labelText: "dd-mm-yyyy",
//             labelStyle: TextStyle(color: isDark ? Colors.white54 : null),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: isDark ? Colors.white24 : Colors.grey,
//               ),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: isDark ? Colors.white24 : Colors.grey,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Half-day dropdown ─────────────────────────────────────────────────────
//   bool _shouldShowHalfDayDropdown(String code) {
//     if (leaveDayRadio != 0) return false;
//     if (code == "SH" || code == "ML" || code == "OD") return false;
//     if (isSeaco && code == "PL") return false;
//     return true;
//   }

//   Widget _halfDayDropdown(bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: DropdownButtonFormField<String>(
//         value: halfDayType,
//         dropdownColor: isDark ? const Color(0xFF1E293B) : null,
//         style: TextStyle(color: isDark ? Colors.white : Colors.black),
//         decoration: InputDecoration(
//           hintText: "Select Half",
//           hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(
//               color: isDark ? Colors.white24 : Colors.grey,
//             ),
//           ),
//         ),
//         items: [
//           DropdownMenuItem(
//             value: "H1",
//             child: Text(
//               "First Half",
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//           ),
//           DropdownMenuItem(
//             value: "H2",
//             child: Text(
//               "Second Half",
//               style: TextStyle(color: isDark ? Colors.white : Colors.black),
//             ),
//           ),
//         ],
//         onChanged: (v) {
//           setState(() {
//             halfDayType = v;
//             if (selectedLeaveCode == "OD") {
//               _fetchShiftTime("H", v == "H2" ? "H2" : "H1");
//             }
//           });
//         },
//       ),
//     );
//   }

//   // ── Time pickers row (OD / SH) ────────────────────────────────────────────
//   Widget _timePickers(bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//             child: _timeField(
//               "From Time",
//               _selectedTimeFrom,
//               () => _showTimePicker("From Time"),
//               isDark,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _timeField(
//               "To Time",
//               _selectedTimeTo,
//               () => _showTimePicker("To Time"),
//               isDark,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _timeField(
//     String label,
//     String? value,
//     VoidCallback onTap,
//     bool isDark,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       child: InputDecorator(
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: isDark ? Colors.white54 : null),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(
//               color: isDark ? Colors.white24 : Colors.grey,
//             ),
//           ),
//           suffixIcon: Icon(
//             Icons.access_time,
//             color: isDark ? Colors.white54 : null,
//           ),
//         ),
//         child: Text(
//           value ?? "--:--",
//           style: TextStyle(
//             color: isDark ? Colors.white : Colors.black,
//             fontSize: 15,
//           ),
//         ),
//       ),
//     );
//   }

//   // =========================================================================
//   // LEAVE CARD
//   // =========================================================================
//   Widget _leaveCard(Map<String, dynamic> leave, {bool isDark = false}) {
//     final leaveCode = leave["LeaveCode"]?.toString() ?? "";
//     final leaveApplicationDate = leave["ApplicationDate"].toString();
//     final status = leave["Status"]?.toString() ?? "";
//     final approvalReason = leave["ApprovalReason"]?.toString() ?? "";
//     final leaveReason = leave["ApplicationReason"]?.toString() ?? "";
//     final fromDate = leave["fromDate"]?.toString() ?? "";
//     final toDate = leave["todate"]?.toString() ?? "";
//     final totalLeave =
//         double.tryParse(leave["totalleave"]?.toString() ?? "0") ?? 0;

//     Color statusColor;
//     switch (status) {
//       case "Approved":
//         statusColor = Colors.green;
//         break;
//       case "Rejected":
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.orange;
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       leaveCode,
//                       style: AppTextStyles.headingMedium.copyWith(
//                         color: isDark ? Colors.white : null,
//                       ),
//                     ),
//                     Text(
//                       leaveReason,
//                       style: AppTextStyles.headingSmall.copyWith(
//                         color: isDark ? Colors.white54 : Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           if (approvalReason.isNotEmpty) ...[
//             const SizedBox(height: 6),
//             Text(
//               approvalReason,
//               style: AppTextStyles.labelMedium.copyWith(
//                 color: isDark ? Colors.white70 : null,
//               ),
//             ),
//           ],
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Icon(
//                 Icons.calendar_today,
//                 size: 14,
//                 color: isDark ? Colors.white38 : Colors.grey,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   "$fromDate to $toDate",
//                   style: AppTextStyles.labelSmall.copyWith(
//                     color: isDark ? Colors.white54 : null,
//                   ),
//                 ),
//               ),
//               Text(
//                 "Total: ${totalLeave % 1 == 0 ? totalLeave.toInt() : totalLeave}",
//                 style: AppTextStyles.labelSmall.copyWith(
//                   color: isDark ? Colors.white54 : null,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Application Date: $leaveApplicationDate",
//             style: AppTextStyles.labelSmall.copyWith(
//               color: isDark ? Colors.white54 : null,
//             ),
//           ),
//           const SizedBox(height: 10),

//           if (status.toLowerCase() == "pending")
//             Align(
//               alignment: Alignment.centerRight,
//               child: CommonButton(
//                 height: 30,
//                 width: 120,
//                 color: const Color.fromARGB(255, 237, 89, 73),
//                 label: "Self Reject",
//                 icon: null,
//                 onPressed: () {
//                   showModernDialog(
//                     type: DialogType.warning,
//                     context: context,
//                     title: "Reject Leave",
//                     message: "Are you sure you want to reject this leave?",
//                     confirmText: "Confirm",
//                     onConfirm: () {
//                       Navigator.of(context).pop();
//                       _selfRejectLeave(leave);
//                     },
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // AUTHORIZATION

//   Widget _leaveAuthorizationData({bool isDark = false}) {
//     if (isAuthLoading)
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.blueGrey),
//       );

//     final filtered = users.where((item) {
//       final statuses = ["Pending", "Approved", "Rejected"];
//       return item["Status"] == statuses[selectedApprovalTab];
//     }).toList();

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           companyDropdown(isDark: isDark),
//           const SizedBox(height: 8),
//           employeeSearchField(isDark: isDark),
//           employeeSearchList(isDark: isDark),
//           const SizedBox(height: 10),
//           _authorizationTabs(isDark: isDark),
//           const SizedBox(height: 8),
//           Expanded(
//             child: filtered.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.assignment_ind_outlined,
//                           size: 30,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           "No Data Found",
//                           style: AppTextStyles.labelMedium.copyWith(
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: filtered.length,
//                     itemBuilder: (_, i) {
//                       final item = filtered[i];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 16),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? const Color(0xFF1E293B)
//                               : Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: isDark
//                                   ? Colors.black.withOpacity(0.4)
//                                   : Colors.black12,
//                               blurRadius: 6,
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     item["EmpName"] ?? "",
//                                     style: AppTextStyles.headingSmall.copyWith(
//                                       color: isDark ? Colors.white : null,
//                                     ),
//                                   ),
//                                 ),
//                                 _statusBadge(item["Status"] ?? ""),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Date: ${item['AttendanceDate'] ?? ''}",
//                               style: AppTextStyles.labelMedium.copyWith(
//                                 color: isDark ? Colors.white70 : null,
//                               ),
//                             ),
//                             Text(
//                               "Reason: ${item['Reason'] ?? ''}",
//                               style: AppTextStyles.labelMedium.copyWith(
//                                 color: isDark ? Colors.white70 : null,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Text(
//                                   "In: ${item['InTime'] ?? ''}",
//                                   style: AppTextStyles.labelSmall.copyWith(
//                                     color: isDark ? Colors.white54 : null,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 Text(
//                                   "Out: ${item['OutTime'] ?? ''}",
//                                   style: AppTextStyles.labelSmall.copyWith(
//                                     color: isDark ? Colors.white54 : null,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (selectedApprovalTab == 0)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 8),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     CommonButton(
//                                       width: 120,
//                                       height: 35,
//                                       icon: null,
//                                       color: Colors.green,
//                                       label: "Approve",
//                                       onPressed: () {},
//                                     ),
//                                     const SizedBox(width: 10),
//                                     CommonButton(
//                                       icon: null,
//                                       width: 120,
//                                       height: 35,
//                                       color: const Color.fromARGB(
//                                         255,
//                                         248,
//                                         74,
//                                         61,
//                                       ),
//                                       label: "Reject",
//                                       onPressed: () {},
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statusBadge(String status) {
//     Color color;
//     switch (status.toLowerCase()) {
//       case "approved":
//         color = Colors.green;
//         break;
//       case "rejected":
//         color = Colors.red;
//         break;
//       case "pending":
//         color = Colors.orange;
//         break;
//       default:
//         color = Colors.grey;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status,
//         style: AppTextStyles.labelSmall.copyWith(
//           color: color,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _authorizationTabs({bool isDark = false}) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
//       ),
//       child: Stack(
//         children: [
//           AnimatedAlign(
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             alignment: selectedApprovalTab == 0
//                 ? Alignment.centerLeft
//                 : selectedApprovalTab == 1
//                 ? Alignment.center
//                 : Alignment.centerRight,
//             child: Container(
//               width: MediaQuery.of(context).size.width / 3 - 24,
//               margin: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [
//                     Color.fromARGB(255, 238, 175, 75),
//                     Color.fromARGB(255, 236, 146, 3),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               _authTabItem("Pending", 0),
//               _authTabItem("Approved", 1),
//               _authTabItem("Rejected", 2),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _authTabItem(String title, int index) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => getLeaveAuthorizationList(index),
//         child: Center(
//           child: AnimatedDefaultTextStyle(
//             duration: const Duration(milliseconds: 300),
//             style: AppTextStyles.labelMedium.copyWith(
//               color: selectedApprovalTab == index ? Colors.white : Colors.grey,
//               fontWeight: FontWeight.bold,
//             ),
//             child: Text(title),
//           ),
//         ),
//       ),
//     );
//   }

// //COMAPNY DROPDOWN + EMPLOYEE SEARCH
//   Widget companyDropdown({bool isDark = false}) {
//     return DropdownButtonFormField<String>(
//       value: selectedComp,
//       dropdownColor: isDark ? const Color(0xFF1E293B) : null,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black),
//       decoration: InputDecoration(
//         labelText: "Select Company",
//         labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
//         border: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(18)),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: const BorderRadius.all(Radius.circular(18)),
//           borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey),
//         ),
//       ),
//       items: companyMap.entries
//           .map(
//             (e) => DropdownMenuItem<String>(
//               value: e.value,
//               child: Text(
//                 e.key,
//                 style: TextStyle(color: isDark ? Colors.white : Colors.black),
//               ),
//             ),
//           )
//           .toList(),
//       onChanged: (v) {
//         setState(() {
//           selectedComp = v;
//           empNameController.clear();
//           selEmpCode = "";
//           searchEmp.clear();
//         });
//         getEmployeeNameSearch(emppk);
//       },
//     );
//   }

// ///EMPLOYEE SEARCH FIELD
//   Widget employeeSearchField({bool isDark = false}) {
//     return TextField(
//       controller: empNameController,
//       style: TextStyle(color: isDark ? Colors.white : null), //
//       decoration: InputDecoration(
//         hintText: "Search Employee",
//         hintStyle: TextStyle(color: isDark ? Colors.white38 : null), //
//         border: OutlineInputBorder(
//           borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey),
//         ),
//       ),
//       onChanged: (value) {
//         selEmpCode = "";
//         if (value.length >= 2) {
//           getEmployeeNameSearch(emppk);
//         } else {
//           setState(() => searchEmp.clear());
//         }
//       },
//     );
//   }

//   //  EMPLOYEE SEARCH LIST
//   Widget employeeSearchList({bool isDark = false}) {
//     if (searchEmp.isEmpty) return const SizedBox();

//     return Container(
//       height: 150,
//       decoration: BoxDecoration(
//         //
//         color: isDark ? const Color(0xFF1E293B) : null,
//         border: Border.all(
//           color: isDark ? Colors.white24 : Colors.grey.shade300,
//         ),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListView.builder(
//         itemCount: searchEmp.length,
//         itemBuilder: (context, index) {
//           final emp = searchEmp[index];
//           return ListTile(
//             dense: true,
//             title: Text(
//               "${emp["Employee_Code"]} - ${emp["EmpName"]}",
//               style: AppTextStyles.labelMedium.copyWith(
//                 //
//                 color: isDark ? Colors.white70 : null,
//               ),
//             ),
//             onTap: () {
//               setState(() {
//                 empNameController.text = emp["EmpName"];
//                 selEmpCode = emp["Employee_Code"];
//                 searchEmp.clear();
//               });
//             },
//           );
//         },
//       ),
//     );
//   }
// }



//NEW UI 




// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/app_services/whatsapp_business_API.dart';
import 'package:new_design_demo/presentations/common_widgets/alert_box.dart';
import 'package:new_design_demo/presentations/common_widgets/common_datePicker.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _DS {
  static const Color brandStart  = Color(0xFF14B8A6);
  static const Color brandMid    = Color(0xFF0D9488);
  static const Color brandDeep   = Color(0xFF0F766E);

  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color borderLight  = Color(0xFFE2E8F0);
  static const Color green1       = Color(0xFF10B981);

  static const Color surfaceDark  = Color(0xFF0F172A);
  static const Color cardDark     = Color(0xFF1E293B);
  // static const Color innerDark    = Color(0xFF0F172A);
  static const Color borderDark   = Color(0xFF334155);
  static const Color inputDark    = Color(0xFF263244);

  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
}

// Leave type categories (unchanged)
const List<String> _kNormalLeaves = ['PL','TL','SL','CL','PH','AL','WFH','ML/SPL','ESI','AB'];

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});
  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with SingleTickerProviderStateMixin {

  // ── State (all unchanged) ────────────────────────────────
  int? emppk; String? empcode; int? companypk; int? locationpk;
  String? empname; int? isSuperAdmin;

  bool showApplyLeaveForm = false;
  bool isLoading          = false;

  List<Map<String, dynamic>> leaveStatusList  = [];
  List<Map<String, dynamic>> leaveTypeList    = [];
  List<Map<String, dynamic>> leaveBalanceList = [];
  List<Map<String, dynamic>> coffBalanceList  = [];

  final TextEditingController _leaveReasonController = TextEditingController();
  final TextEditingController strtDateController      = TextEditingController();
  final TextEditingController endDateController       = TextEditingController();

  int?    selectedLeaveTypeId;
  String? selectedLeaveCode;
  String? selectedLeaveDesc;
  String? selectedLeavePK;

  DateTime? startDate;
  DateTime? endDate;

  int    leaveDayRadio  = 0;
  String leaveDayStatus = "F";
  String? halfDayType;

  int?    selectedCoffIndex;
  String? selectedCoffScheduleDate;
  String? selectedCoffType;

  String? _selectedTimeFrom;
  String? _selectedTimeTo;
  int     _pickerHour   = 0;
  int     _pickerMinute = 0;

  bool get isSeaco => const String.fromEnvironment('APP_FLAVOR') == 'seaco';

  bool isAuthorizationScreen = false;
  bool isAuthLoading         = false;
  List<Map<String, dynamic>> users = [];
  Map<String, String>        companyMap = {};
  String? selectedComp;
  List   searchEmp   = [];
  String selEmpCode  = "";
  final TextEditingController empNameController = TextEditingController();
  int selectedApprovalTab = 0;

  // Balance card accent colors
  final List<Color> _accentColors = [
    const Color(0xFF3B82F6),
    const Color(0xFF8B5CF6),
    const Color(0xFF10B981),
    const Color(0xFFEF4444),
    const Color(0xFFF59E0B),
    const Color(0xFF06B6D4),
  ];

  // ── Fade animation ───────────────────────────────────────
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 500),
  )..forward();
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  // ── Date / time helpers (unchanged) ─────────────────────
  String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  String get _fromDateStr => startDate != null ? formatDate(startDate!) : '';
  String get _toDateStr   => endDate   != null ? formatDate(endDate!)   : '';

  String getLeaveDayType(int v)      => v == 0 ? "H" : "F";
  String getFromDayStatus(String v)  { if (v=="Full Day") return "F"; if (v=="First Half") return "H1"; if (v=="Second Half") return "H2"; return "F"; }
  String getToDayStatus(String v)    { if (v=="Full Day") return "F"; if (v=="First Half") return "H1"; if (v=="Second Half") return "H2"; return "F"; }
  String getToDayStatus_HalfDay(String? v) { if (v=="H1") return "H1"; if (v=="H2") return "H2"; return "H1"; }

  // ── LOGIC (all unchanged) ────────────────────────────────
  @override
  void initState() {
    super.initState();
    _initializeData();
    getCompanyList();
  }

  @override
  void dispose() {
    _leaveReasonController.dispose();
    strtDateController.dispose();
    endDateController.dispose();
    empNameController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _getPrefsData();
    if (emppk == null) return;
    await Future.wait([loadLeaveStatus(), fetchLeaveBalance(), fetchCoffBalance(), fetchLeaveTypes()]);
  }

  Future<void> _getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk        = prefs.getInt("emppk");
    empcode      = prefs.getString("employeecode");
    companypk    = prefs.getInt("companypk");
    locationpk   = prefs.getInt("locationpk");
    empname      = prefs.getString("employeename");
    isSuperAdmin = int.tryParse(prefs.getString("issuperadmin") ?? "0") ?? 0;
  }

  Future<void> loadLeaveStatus() async {
    setState(() => isLoading = true);
    leaveStatusList = await _getLeaveStatusList();
    setState(() => isLoading = false);
  }

  Future<List<Map<String, dynamic>>> _getLeaveStatusList() async {
    try {
      final response = await ApiClient.get(ApiConstants.getLeaveStatus, query: {"Emp_PK": emppk});
      final data = response.data;
      if (data is List) return List<Map<String, dynamic>>.from(data);
      if (data is Map && data["GetLeaveStatus_List"] != null) {
        return List<Map<String, dynamic>>.from(data["GetLeaveStatus_List"]);
      }
    } catch (e) { debugPrint("Leave Status Error: $e"); }
    return [];
  }

  Future<void> fetchLeaveBalance() async {
    try {
      final response = await ApiClient.get("Leave_Services.svc/GetLeaveBalance",
          query: {"Emp_PK": emppk, "Leave_Code": "Leave", "Location_PK": locationpk});
      final data = response.data;
      if (data != null && data["GetLeaveBalanceResult"] != null) {
        setState(() {
          leaveBalanceList = List<Map<String, dynamic>>.from(
              (data["GetLeaveBalanceResult"] as List).where((e) => e["Flag"] != "C-OFF"));
        });
      }
    } catch (e) { debugPrint("Leave Balance Error: $e"); }
  }

  Future<void> fetchCoffBalance() async {
    try {
      final response = await ApiClient.get("Leave_Services.svc/GetLeaveBalance",
          query: {"Emp_PK": emppk, "Leave_Code": "C-OFF", "Location_PK": locationpk});
      final data = response.data;
      if (data != null && data["GetLeaveBalanceResult"] != null) {
        setState(() {
          coffBalanceList = List<Map<String, dynamic>>.from(
              (data["GetLeaveBalanceResult"] as List).where((e) => e["Flag"] == "C-OFF"));
        });
      }
    } catch (e) { debugPrint("COFF Balance Error: $e"); }
  }

  Future<void> fetchLeaveTypes() async {
    try {
      setState(() => isLoading = true);
      final response = await ApiClient.get(ApiConstants.getLeaveType, query: {"Emp_PK": emppk});
      final data = response.data;
      if (data is Map && data["LeaveLists"] != null) {
        setState(() { leaveTypeList = List<Map<String, dynamic>>.from(data["LeaveLists"]); });
      }
    } catch (e) { debugPrint("Leave Type Error: $e"); }
    finally { setState(() => isLoading = false); }
  }

  Future<void> _fetchShiftTime(String horF, String forS) async {
    try {
      final response = await ApiClient.get(ApiConstants.getShiftTime);
      if (response.statusCode == 200) {
        final start = DateFormat("HH:mm").parse(response.data['starttime']);
        final end   = DateFormat("HH:mm").parse(response.data['endtime']);
        setState(() {
          _selectedTimeFrom = DateFormat.jm().format(start);
          _selectedTimeTo   = DateFormat.jm().format(end);
        });
      }
    } catch (e) { debugPrint("ShiftTime Error: $e"); }
  }

  void _onLeaveTypeSelected(Map<String, dynamic> leave) {
    setState(() {
      selectedLeaveTypeId = int.tryParse(leave["Leave_PK"].toString());
      selectedLeaveCode   = leave["Leave_Code"]?.toString();
      selectedLeaveDesc   = leave["Leave_Description"]?.toString();
      selectedLeavePK     = leave["Leave_PK"].toString();
      leaveDayRadio = 0; leaveDayStatus = "F"; halfDayType = null;
      startDate = null; endDate = null;
      strtDateController.clear(); endDateController.clear();
      _leaveReasonController.clear();
      selectedCoffIndex = null; selectedCoffScheduleDate = null; selectedCoffType = null;
      _selectedTimeFrom = null; _selectedTimeTo = null;
      if (selectedLeaveCode == "OD") _fetchShiftTime("H", "H1");
    });
  }

  bool get _isSingleDay =>
      selectedLeaveCode == 'C-OFF' || selectedLeaveCode == 'C-Off' || leaveDayRadio == 0;

  Future<void> _pickStartDate() async {
    final picked = await CommonDatePicker.pickDate(context: context);
    if (picked == null) return;
    setState(() {
      startDate = picked;
      strtDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      if (_isSingleDay) { endDate = picked; endDateController.text = strtDateController.text; }
      else if (endDate != null && endDate!.isBefore(picked)) { endDate = null; endDateController.clear(); }
    });
  }

  Future<void> _pickEndDate() async {
    if (_isSingleDay) {
      _warn(selectedLeaveCode == 'C-OFF'
          ? "COFF can be applied for only one day"
          : "Half day leave can be applied for only one day");
      return;
    }
    if (startDate == null) { _warn("Please select start date first."); return; }
    final picked = await CommonDatePicker.pickDate(context: context, initialDate: startDate, firstDate: startDate);
    if (picked == null) return;
    setState(() { endDate = picked; endDateController.text = DateFormat('dd-MM-yyyy').format(picked); });
  }

  Future<void> _showTimePicker(String label) async {
    int tempH = _pickerHour, tempM = _pickerMinute;
    await showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, snap) => AlertDialog(
          title: Text("Select $label"),
          content: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _numberScroll(tempH, 0, 23, (v) => snap(() => tempH = v)),
            const Text("  :  ", style: TextStyle(fontSize: 20)),
            _numberScroll(tempM, 0, 59, (v) => snap(() => tempM = v)),
          ]),
          actions: [
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
            TextButton(child: const Text("OK"), onPressed: () {
              final dt = DateTime(0, 1, 1, tempH, tempM);
              final formatted = DateFormat.jm().format(dt);
              setState(() {
                _pickerHour = tempH; _pickerMinute = tempM;
                if (label == "From Time") {
                  _selectedTimeFrom = formatted;
                } else {
                  _selectedTimeTo = formatted;
                }
              });
              Navigator.pop(ctx);
            }),
          ],
        ),
      ),
    );
  }

  Widget _numberScroll(int current, int min, int max, ValueChanged<int> onChanged) {
    return SizedBox(
      width: 60, height: 120,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40, onSelectedItemChanged: onChanged,
        controller: FixedExtentScrollController(initialItem: current - min),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: max - min + 1,
          builder: (_, i) => Center(child: Text(
            (min + i).toString().padLeft(2, '0'),
            style: const TextStyle(fontSize: 22),
          )),
        ),
      ),
    );
  }

  bool _validate() {
    final code = selectedLeaveCode ?? "";
    if (selectedLeaveTypeId == null) { _warn("Please select leave type."); return false; }
    if (startDate == null) { _warn("Please select start date."); return false; }
    if (_leaveReasonController.text.trim().isEmpty) { _warn("Please enter reason."); return false; }
    if (_kNormalLeaves.contains(code) && leaveDayRadio == 0) {
      if (halfDayType == null && !(isSeaco && code == "PL")) { _warn("Please select First Half or Second Half."); return false; }
    }
    if (code == "C-OFF" || code == "C-Off") {
      if (selectedCoffScheduleDate == null) { _warn("Please select a pending C-OFF record."); return false; }
    }
    if ((code == "OD" || code == "SH") && (_selectedTimeFrom == null || _selectedTimeTo == null)) {
      _warn("Please select From Time and To Time."); return false;
    }
    return true;
  }

  void _warn(String msg) => CommonSnackBar.show(context: context, title: "Warning", message: msg, type: SnackBarType.warning);

  String _formatTimeTo24(String? t) {
    if (t == null) return "00:00";
    try {
      final clean = t.replaceAll(RegExp(r'\u202f'), ' ').trim();
      final parsed = DateFormat("hh:mm a").parse(clean);
      return DateFormat("HH:mm").format(parsed);
    } catch (_) { return "00:00"; }
  }

  double _totalDays() {
    if (startDate == null || endDate == null) return 0;
    final code = selectedLeaveCode ?? "";
    if (code == "SH" || (code == "OD" && leaveDayRadio == 2)) return 0;
    if (leaveDayRadio == 0 && _kNormalLeaves.contains(code)) return 0.5;
    return endDate!.difference(startDate!).inDays + 1;
  }

  Future<void> _submitLeave() async {
    if (!_validate()) return;
    setState(() => isLoading = true);
    try {
      final now  = DateTime.now();
      final code = selectedLeaveCode ?? "";
      final from = _fromDateStr;
      final to   = _toDateStr.isNotEmpty ? _toDateStr : from;
      final days = _totalDays();
      Map<String, dynamic> payload;

      if (code == "SH") {
        payload = {"SHDate": to, "ShReason": _leaveReasonController.text.trim(), "Emp_PK": emppk,
          "FromTime": _formatTimeTo24(_selectedTimeFrom), "ToTime": _formatTimeTo24(_selectedTimeTo)};
        final resp = await ApiClient.post(ApiConstants.shortLeaveURL, data: payload);
        _handleResponse(resp.data["ShortLeaveApplicationResult"]?.toString() ?? ""); return;
      }

      if (code == "C-OFF" || code == "C-Off") {
        payload = _buildPayload(now: now, from: to, to: to, days: days, offDate: selectedCoffScheduleDate ?? to,
          coffDate: to, fromStatus: leaveDayRadio == 0 ? getToDayStatus_HalfDay(halfDayType) : getFromDayStatus("Full Day"),
          toStatus: leaveDayRadio == 0 ? getToDayStatus_HalfDay(halfDayType) : getToDayStatus("Full Day"),
          fromTime: "00:00", toTime: "00:00", leaveDaySt: getLeaveDayType(leaveDayRadio),
          extraFields: {"Cofftype": selectedCoffType});
      } else if (code == "OD") {
        if (leaveDayRadio == 0) {
          payload = _buildPayload(now: now, from: to, to: to, days: days, offDate: to, coffDate: to,
            fromStatus: getToDayStatus_HalfDay(halfDayType), toStatus: getToDayStatus_HalfDay(halfDayType),
            fromTime: _formatTimeTo24(_selectedTimeFrom), toTime: _formatTimeTo24(_selectedTimeTo), leaveDaySt: getLeaveDayType(0));
        } else if (leaveDayRadio == 1) {
          payload = _buildPayload(now: now, from: from, to: to, days: days, offDate: to, coffDate: to,
            fromStatus: getFromDayStatus("Full Day"), toStatus: getToDayStatus("Full Day"),
            fromTime: _formatTimeTo24(_selectedTimeFrom), toTime: _formatTimeTo24(_selectedTimeTo), leaveDaySt: getLeaveDayType(1));
        } else {
          payload = _buildPayload(now: now, from: to, to: to, days: days, offDate: to, coffDate: to,
            fromStatus: getFromDayStatus("Full Day"), toStatus: getToDayStatus("Full Day"),
            fromTime: _formatTimeTo24(_selectedTimeFrom), toTime: _formatTimeTo24(_selectedTimeTo), leaveDaySt: "O");
        }
      } else if (leaveDayRadio == 0 && (_kNormalLeaves.contains(code) || code == "LWP" || code == "MRGL")) {
        payload = _buildPayload(now: now, from: to, to: to, days: days, offDate: to, coffDate: to,
          fromStatus: getToDayStatus_HalfDay(halfDayType), toStatus: getToDayStatus_HalfDay(halfDayType),
          fromTime: _formatTimeTo24(_selectedTimeFrom), toTime: _formatTimeTo24(_selectedTimeTo), leaveDaySt: getLeaveDayType(0));
      } else {
        payload = _buildPayload(now: now, from: from, to: to, days: days, offDate: to, coffDate: to,
          fromStatus: getFromDayStatus("Full Day"), toStatus: getToDayStatus("Full Day"),
          fromTime: "00:00", toTime: "00:00", leaveDaySt: getLeaveDayType(1));
      }

      final resp = await ApiClient.post(ApiConstants.submitLeaveApplication, data: payload);
      _handleResponse(resp.data.toString());
    } catch (e) {
      CommonSnackBar.show(context: context, title: "Error", message: "Failed to apply leave. $e", type: SnackBarType.error);
    } finally { setState(() => isLoading = false); }
  }

  Map<String, dynamic> _buildPayload({required DateTime now, required String from, required String to,
    required double days, required String offDate, required String coffDate, required String fromStatus,
    required String toStatus, required String fromTime, required String toTime, required String leaveDaySt,
    Map<String, dynamic>? extraFields}) {
    final base = {"Emp_PK": emppk, "LeaveToDate": to, "Leave_PK": selectedLeavePK, "Created_On": now.toString(),
      "Leave_Code": selectedLeaveCode, "NoOfLeaves": days.toString(), "OFFDate": offDate, "ContinuePendingLeave": "No",
      "Reason": _leaveReasonController.text.trim(), "Updated_By": emppk, "FromDateStatus": fromStatus,
      "LeaveFromDate": from, "ToDateStatus": toStatus, "Location_PK": locationpk, "LeaveApplicationDate": formatDate(now),
      "COFFDate": coffDate, "ToTime": toTime, "Company_PK": companypk, "LeaveDayStatus": leaveDaySt,
      "Updated_On": now.toString(), "Employee_Name": empname, "Created_By": emppk,
      "Employee_Code": empcode, "FromTime": fromTime};
    if (extraFields != null) base.addAll(extraFields);
    return base;
  }

  void _handleResponse(String msg) {
    if (msg.toLowerCase().contains("success") || msg.isNotEmpty) {
      CommonSnackBar.show(context: context,
        title: msg.toLowerCase().contains("success") ? "Success" : "Info", message: msg,
        type: msg.toLowerCase().contains("success") ? SnackBarType.success : SnackBarType.warning);
      if (msg.toLowerCase().contains("success")) sendWhatsAppMessage();
    } else {
      CommonSnackBar.show(context: context, title: "Error", message: "Something went wrong.", type: SnackBarType.error);
    }
    _resetForm();
    loadLeaveStatus(); fetchLeaveBalance(); fetchCoffBalance();
  }

  void _resetForm() {
    setState(() {
      showApplyLeaveForm = false; selectedLeaveTypeId = null; selectedLeaveCode = null;
      selectedLeaveDesc = null; selectedLeavePK = null; startDate = null; endDate = null;
      leaveDayRadio = 0; leaveDayStatus = "F"; halfDayType = null; selectedCoffIndex = null;
      selectedCoffScheduleDate = null; selectedCoffType = null; _selectedTimeFrom = null; _selectedTimeTo = null;
      strtDateController.clear(); endDateController.clear(); _leaveReasonController.clear();
    });
  }

  Future<void> _selfRejectLeave(Map<String, dynamic> leave) async {
    try {
      final response = await ApiClient.post(ApiConstants.leaveSelfReject,
        data: {"Leave_Code": leave["LeaveCode"], "Emp_Pk": emppk, "Trans_PK": leave["Trans_Pk"]});
      final data = jsonDecode(response.toString());
      final msg  = data["LeaveSelfRejectResult"] as String? ?? "Failed.";
      CommonSnackBar.show(context: context, title: msg.isEmpty ? "Error" : "Success", message: msg.isEmpty ? "Failed to reject." : msg,
        type: msg.isEmpty ? SnackBarType.error : SnackBarType.success);
      loadLeaveStatus(); fetchLeaveBalance();
    } catch (_) {
      CommonSnackBar.show(context: context, title: "Error", message: "Failed to reject leave.", type: SnackBarType.error);
    }
  }

  Future<void> getCompanyList() async {
    try {
      final response = await ApiClient.get(ApiConstants.getCompanyGroupList, query: {});
      final data = response.data;
      if (data is List) {
        companyMap.clear();
        for (final item in data) {
          companyMap[item["Company_Name"].toString()] = item["CompanyGroupDBName"].toString();
        }
        selectedComp = companyMap.values.first;
        getLeaveAuthorizationList(0);
      }
    } catch (e) { debugPrint("Company List Error: $e"); }
  }

  Future<void> getLeaveAuthorizationList(int index) async {
    selectedApprovalTab = index;
    const statuses = ["Pending", "Approved", "Rejected"];
    setState(() { isAuthLoading = true; users.clear(); });
    try {
      final response = await ApiClient.get(ApiConstants.getLeaveAuthorization,
        query: {"Emp_PK": emppk, "EmpCode": selEmpCode, "Status": statuses[index],
          "FromDate": "", "ToDate": "", "CompanyGroupDBName": selectedComp});
      final data = response.data;
      if (data is List) { users = List<Map<String, dynamic>>.from(data); }
      else if (data is Map && data["GetLeaveAuthorization_List"] != null) {
        users = List<Map<String, dynamic>>.from(data["GetLeaveAuthorization_List"]);
      } else { users = []; }
    } catch (e) { debugPrint("Authorization Error: $e"); }
    setState(() => isAuthLoading = false);
  }

  Future<void> getEmployeeNameSearch(int? pk) async {
    setState(() { isLoading = true; searchEmp.clear(); });
    try {
      final company = selectedComp ?? "";
      final response = await ApiClient.get(
        "${ApiConstants.searchEmployeeNameCode}?Emp_PK=${pk ?? 0}&Searchtxt=${empNameController.text}&CompanyGroupDBName=$company");
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      final list = data["AutoCompleteData_LeaveReportingResult"] as List? ?? [];
      final uniqueItems = <String>{};
      searchEmp = list.where((item) => uniqueItems.add(item.toString())).map<Map<String, dynamic>>((item) {
        final parts = item.toString().split(":");
        return {"Employee_Code": parts.isNotEmpty ? parts[0] : "", "EmpName": parts.length > 1 ? parts[1] : ""};
      }).toList();
    } catch (e) { debugPrint("Emp Search Error: $e"); }
    if (mounted) setState(() => isLoading = false);
  }

  void _resetAuthorizationFilters() {
    empNameController.clear(); selEmpCode = ""; searchEmp.clear();
    if (companyMap.isNotEmpty) selectedComp = companyMap.values.first;
    selectedApprovalTab = 0;
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (showApplyLeaveForm) { setState(() => showApplyLeaveForm = false); return false; }
        if (isAuthorizationScreen) {
          setState(() { _resetAuthorizationFilters(); isAuthorizationScreen = false; }); return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? _DS.surfaceDark : _DS.surfaceLight,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(isDark),
                const SizedBox(height: 100),
                if (!showApplyLeaveForm) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(
                          color: _DS.brandStart, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 10),
                        Text("Leave History", style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 15, fontWeight: FontWeight.w700,
                        )),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: isAuthorizationScreen
                      ? _leaveAuthorizationData(isDark: isDark)
                      : isLoading
                          ? _loadingState()
                          : leaveStatusList.isEmpty
                              ? _emptyState("No Leave History Found.", Icons.event_busy_outlined, isDark)
                              : FadeTransition(
                                  opacity: _fadeAnim,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                    itemCount: leaveStatusList.length,
                                    itemBuilder: (_, i) => _leaveCard(leaveStatusList[i], isDark: isDark),
                                  ),
                                ),
                ),
              ],
            ),

            // ── Balance cards floating below header
            Positioned(
              top: 215,
              left: 12, right: 12,
              child: _balanceCards(isDark: isDark),
            ),

            // ── Apply leave form overlay
            if (showApplyLeaveForm)
              Positioned(
                top: 200, left: 12, right: 12, bottom: 0,
                child: _applyLeaveForm(isDark: isDark),
              ),
          ],
        ),
      ),
    );
  }

  // ─── PREMIUM HEADER ──────────────────────────────────────
  Widget _header(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_DS.brandStart, _DS.brandMid, _DS.brandDeep],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -40, child: _decorCircle(170, Colors.white.withOpacity(0.06))),
          Positioned(left: -20, bottom: 10, child: _decorCircle(100, Colors.white.withOpacity(0.04))),

          SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Back
              GestureDetector(
                onTap: () {
                  if (!isAuthorizationScreen) { Navigator.pop(context); }
                  else { setState(() { getLeaveAuthorizationList(0); isAuthorizationScreen = false; }); }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(height: 14),

              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Leave", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const Text("Management", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                    child: const Text("Manage Your Leave Requests", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                ])),

                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _headerBtn("Apply Leave", Icons.add_circle_outline_rounded, () => setState(() => showApplyLeaveForm = !showApplyLeaveForm)),
                  const SizedBox(height: 8),
                  if (!isAuthorizationScreen)
                    _headerBtn("Authorization", Icons.verified_user_outlined, () {
                      setState(() => isAuthorizationScreen = true);
                      getLeaveAuthorizationList(0);
                    }),
                ]),
              ]),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _headerBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _DS.brandDeep, size: 17),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: _DS.brandDeep, fontWeight: FontWeight.w700, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ─── BALANCE CARDS ───────────────────────────────────────
  Widget _balanceCards({bool isDark = false}) {
    if (leaveBalanceList.isEmpty) return const SizedBox(height: 90);
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: leaveBalanceList.length,
        itemBuilder: (_, i) {
          final leave = leaveBalanceList[i];
          final color = _accentColors[i % _accentColors.length];
          return Container(
            width: 88, height: 90,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: isDark ? _DS.cardDark : _DS.cardLight,
              borderRadius: BorderRadius.circular(_DS.r16),
              border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
              boxShadow: [BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.30) : color.withOpacity(0.10),
                blurRadius: 12, offset: const Offset(0, 4),
              )],
            ),
            child: Column(children: [
              Container(height: 4,
                decoration: BoxDecoration(color: color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(_DS.r16)))),
              const SizedBox(height: 10),
              Text(leave["No_of_Leave"].toString(),
                style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(leave["Leave_Title"].toString(),
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 9, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          );
        },
      ),
    );
  }

  // ─── APPLY LEAVE FORM ────────────────────────────────────
  Widget _applyLeaveForm({bool isDark = false}) {
    final code = selectedLeaveCode ?? "";
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(_DS.r24)),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.12),
          blurRadius: 24, offset: const Offset(0, -6),
        )],
      ),
      child: Column(children: [
        // Drag handle
        Center(child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 4),
          width: 36, height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.white24 : Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
        )),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Container(padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_DS.brandStart, _DS.brandDeep]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: _DS.brandStart.withOpacity(0.35), blurRadius: 8)],
                ),
                child: const Icon(Icons.event_note_rounded, color: Colors.white, size: 18)),
              const SizedBox(width: 12),
              Text("Apply for Leave", style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 16, fontWeight: FontWeight.w700,
              )),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => showApplyLeaveForm = false),
                child: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 16)),
              ),
            ]),
            const SizedBox(height: 16),

            _leaveTypeChips(isDark),
            const SizedBox(height: 8),

            if (selectedLeaveDesc != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _DS.brandStart.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _DS.brandStart.withOpacity(0.25)),
                ),
                child: Text(selectedLeaveDesc!,
                  style: const TextStyle(color: _DS.brandStart, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 8),

            if (code.isEmpty || _kNormalLeaves.contains(code) || code == "LWP" || code == "MRGL" || code == "SH" || code == "ML")
              _inlineLeaveBalance(isDark),

            if (code == "C-OFF" || code == "C-Off") _coffBalanceSelector(isDark),

            if (code.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(child: Text("First Select Leave Type…",
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13))),
              ),

            if (code.isNotEmpty && code != "SH" && code != "ML") _radioButtons(isDark, code),
            const SizedBox(height: 8),

            if (code.isNotEmpty) _datePicker(isDark, code),
            const SizedBox(height: 8),

            if (_shouldShowHalfDayDropdown(code)) _halfDayDropdown(isDark),
            if (code == "OD" || code == "SH") _timePickers(isDark),
            const SizedBox(height: 10),

            if (code.isNotEmpty) ...[
              _sectionLabel("Reason", isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _leaveReasonController,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
                decoration: _fieldDecoration("Please enter reason.", isDark),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: _submitLeave,
                  child: _gradientBtn("Submit Request", Icons.send_rounded),
                )),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () => setState(() => showApplyLeaveForm = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black38,
                      borderRadius: BorderRadius.circular(_DS.r12),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.close_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 16),
                      const SizedBox(width: 6),
                      Text("Cancel", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  ),
                )),
              ]),
            ],
          ]),
        )),
      ]),
    );
  }

  // ─── LEAVE TYPE CHIPS ────────────────────────────────────
  Widget _leaveTypeChips(bool isDark) {
    return Wrap(spacing: 8, runSpacing: 8, children: leaveTypeList.map((leave) {
      final pk       = int.tryParse(leave["Leave_PK"].toString());
      final isChosen = pk == selectedLeaveTypeId;
      return GestureDetector(
        onTap: () => _onLeaveTypeSelected(leave),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            gradient: isChosen ? const LinearGradient(colors: [_DS.brandStart, _DS.brandDeep]) : null,
            color: isChosen ? null : (isDark ? _DS.inputDark : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isChosen ? _DS.brandStart : (isDark ? _DS.borderDark : _DS.borderLight)),
            boxShadow: isChosen ? [BoxShadow(color: _DS.brandStart.withOpacity(0.30), blurRadius: 8)] : [],
          ),
          child: Text(leave["Leave_Title"] ?? "",
            style: TextStyle(
              color: isChosen ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF334155)),
              fontSize: 12, fontWeight: FontWeight.w600,
            )),
        ),
      );
    }).toList());
  }

  // ─── INLINE BALANCE ──────────────────────────────────────
  Widget _inlineLeaveBalance(bool isDark) {
    if (leaveBalanceList.isEmpty) return const SizedBox();
    return SizedBox(height: 72, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: leaveBalanceList.length,
      itemBuilder: (_, i) {
        final item  = leaveBalanceList[i];
        final color = _accentColors[i % _accentColors.length];
        return Container(
          width: 72, height: 72,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? _DS.inputDark : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(item['No_of_Leave'].toString(),
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(item['Leave_Title'].toString(),
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center, maxLines: 2),
          ]),
        );
      },
    ));
  }

  // ─── COFF SELECTOR ───────────────────────────────────────
  Widget _coffBalanceSelector(bool isDark) {
    if (coffBalanceList.isEmpty) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text("No pending C-OFF records.", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13)));
    }
    return SizedBox(height: 160, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: coffBalanceList.length,
      itemBuilder: (_, i) {
        final item     = coffBalanceList[i];
        final isChosen = selectedCoffIndex == i;
        return GestureDetector(
          onTap: () => setState(() {
            selectedCoffIndex = i;
            selectedCoffScheduleDate = item["ScheduleDate"]?.toString();
            selectedCoffType = item["CoffType"]?.toString();
          }),
          child: Container(
            width: 270,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? (isChosen ? _DS.brandDeep.withOpacity(0.15) : _DS.inputDark) : (isChosen ? _DS.brandStart.withOpacity(0.08) : Colors.white),
              borderRadius: BorderRadius.circular(_DS.r16),
              border: Border.all(color: isChosen ? _DS.brandStart : (isDark ? _DS.borderDark : _DS.borderLight), width: isChosen ? 1.8 : 1),
              boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black38, blurRadius: 8)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(isChosen ? Icons.radio_button_checked : Icons.radio_button_off, color: isChosen ? _DS.brandStart : Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(item["ScheduleDate"]?.toString() ?? "",
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6),
              Text("Status: ${item['Status'] ?? ''}", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
              Text("Lapsed: ${item['LapsedDate'] ?? ''}", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 11)),
              Text("IN: ${item['InTime']}  Out: ${item['OutTime']}", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11)),
              Text(item["CoffType"]?.toString() ?? "", style: const TextStyle(color: _DS.brandStart, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
        );
      },
    ));
  }

  // ─── RADIO BUTTONS ───────────────────────────────────────
  Widget _radioButtons(bool isDark, String code) {
    final bool isOD  = code == "OD";
    final bool hidHalf = isSeaco && code == "PL";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        if (!hidHalf) _radioChip("Half Day",        0, isDark),
        _radioChip("One or More Days", 1, isDark),
        if (isOD) _radioChip("Short OD",  2, isDark),
      ]),
    );
  }

  Widget _radioChip(String label, int v, bool isDark) {
    final selected = leaveDayRadio == v;
    return GestureDetector(
      onTap: () => setState(() {
        leaveDayRadio = v;
        if (v == 0 && startDate != null) { endDate = startDate; endDateController.text = strtDateController.text; }
        if (selectedLeaveCode == "OD") _fetchShiftTime(v == 0 ? "H" : "F", "H1");
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(colors: [_DS.brandStart, _DS.brandDeep]) : null,
          color: selected ? null : (isDark ? _DS.inputDark : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _DS.brandStart : (isDark ? _DS.borderDark : _DS.borderLight)),
          boxShadow: selected ? [BoxShadow(color: _DS.brandStart.withOpacity(0.30), blurRadius: 6)] : [],
        ),
        child: Text(label, style: TextStyle(
          color: selected ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF334155)),
          fontSize: 12, fontWeight: FontWeight.w600,
        )),
      ),
    );
  }

  // ─── DATE PICKER ─────────────────────────────────────────
  Widget _datePicker(bool isDark, String code) {
    final bool singleDate = _isSingleDay || code == "ML" || code == "SH";
    if (singleDate) return _dateField("On Date", strtDateController, _pickStartDate, isDark);
    return Row(children: [
      Expanded(child: _dateField("From Date", strtDateController, _pickStartDate, isDark)),
      const SizedBox(width: 8),
      Expanded(child: _dateField("To Date", endDateController, _pickEndDate, isDark)),
    ]);
  }

  Widget _dateField(String label, TextEditingController ctrl, VoidCallback onTap, bool isDark) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionLabel(label, isDark),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl, onTap: onTap, readOnly: true,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
        decoration: _fieldDecoration("dd-mm-yyyy", isDark, suffix: Icons.calendar_month_outlined),
      ),
    ]);
  }

  // ─── HALF-DAY DROPDOWN ───────────────────────────────────
  bool _shouldShowHalfDayDropdown(String code) {
    if (leaveDayRadio != 0) return false;
    if (code == "SH" || code == "ML" || code == "OD") return false;
    if (isSeaco && code == "PL") return false;
    return true;
  }

  Widget _halfDayDropdown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        value: halfDayType,
        dropdownColor: isDark ? _DS.cardDark : null,
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
        decoration: _fieldDecoration("Select Half", isDark),
        items: [
          DropdownMenuItem(value: "H1", child: Text("First Half",  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)))),
          DropdownMenuItem(value: "H2", child: Text("Second Half", style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)))),
        ],
        onChanged: (v) => setState(() {
          halfDayType = v;
          if (selectedLeaveCode == "OD") _fetchShiftTime("H", v == "H2" ? "H2" : "H1");
        }),
      ),
    );
  }

  // ─── TIME PICKERS ────────────────────────────────────────
  Widget _timePickers(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(child: _timeField("From Time", _selectedTimeFrom, () => _showTimePicker("From Time"), isDark)),
        const SizedBox(width: 8),
        Expanded(child: _timeField("To Time",   _selectedTimeTo,   () => _showTimePicker("To Time"),   isDark)),
      ]),
    );
  }

  Widget _timeField(String label, String? value, VoidCallback onTap, bool isDark) {
    return InkWell(onTap: onTap, child: InputDecorator(
      decoration: _fieldDecoration(label, isDark, suffix: Icons.access_time_rounded),
      child: Text(value ?? "--:--",
        style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w600)),
    ));
  }

  // ─── LEAVE CARD ──────────────────────────────────────────
  Widget _leaveCard(Map<String, dynamic> leave, {bool isDark = false}) {
    final leaveCode  = leave["LeaveCode"]?.toString()        ?? "";
    final appDate    = leave["ApplicationDate"]?.toString()  ?? "";
    final status     = leave["Status"]?.toString()           ?? "";
    final approvalReason = leave["ApprovalReason"]?.toString() ?? "";
    final leaveReason    = leave["ApplicationReason"]?.toString() ?? "";
    final fromDate   = leave["fromDate"]?.toString() ?? "";
    final toDate     = leave["todate"]?.toString()   ?? "";
    final totalLeave = double.tryParse(leave["totalleave"]?.toString() ?? "0") ?? 0;

    final _StatusInfo si = _approvalStatusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r20),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [BoxShadow(
          color: isDark ? Colors.black.withOpacity(0.28) : Colors.black.withOpacity(0.05),
          blurRadius: 16, offset: const Offset(0, 6),
        )],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: si.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: si.color.withOpacity(0.25)),
              ),
              child: Text(leaveCode, style: TextStyle(color: si.color, fontSize: 13, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(leaveReason,
                style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF475569), fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              if (approvalReason.isNotEmpty)
                Text(approvalReason, style: TextStyle(color: si.color, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            _statusBadge(status, si.color),
          ]),
        ),

        Divider(height: 1, color: isDark ? _DS.borderDark : _DS.borderLight),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.date_range_rounded, size: 14, color: isDark ? Colors.white38 : Colors.black38),
              const SizedBox(width: 6),
              Text("$fromDate  →  $toDate",
                style: TextStyle(color: isDark ? Colors.white60 : const Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _DS.brandStart.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${totalLeave % 1 == 0 ? totalLeave.toInt() : totalLeave} days",
                  style: const TextStyle(color: _DS.brandStart, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 13, color: isDark ? Colors.white30 : Colors.black26),
              const SizedBox(width: 5),
              Text("Applied: $appDate",
                style: TextStyle(color: isDark ? Colors.white30 : Colors.black38, fontSize: 11)),
            ]),

            if (status.toLowerCase() == "pending") ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => showModernDialog(
                  type: DialogType.warning, context: context,
                  title: "Reject Leave", message: "Are you sure you want to reject this leave?",
                  confirmText: "Confirm",
                  onConfirm: () { Navigator.of(context).pop(); _selfRejectLeave(leave); },
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(_DS.r12),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 15),
                    SizedBox(width: 6),
                    Text("Self Reject", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 12)),
                  ]),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  // ─── AUTHORIZATION DATA ──────────────────────────────────
  Widget _leaveAuthorizationData({bool isDark = false}) {
    if (isAuthLoading) return _loadingState();
    final statuses = ["Pending", "Approved", "Rejected"];
    final filtered = users.where((item) => item["Status"] == statuses[selectedApprovalTab]).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(children: [
        companyDropdown(isDark: isDark),
        const SizedBox(height: 8),
        employeeSearchField(isDark: isDark),
        employeeSearchList(isDark: isDark),
        const SizedBox(height: 10),
        _authorizationTabs(isDark: isDark),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState("No Data Found", Icons.assignment_ind_outlined, isDark)
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final item = filtered[i];
                    final si   = _approvalStatusInfo(item["Status"] ?? "");
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? _DS.cardDark : _DS.cardLight,
                        borderRadius: BorderRadius.circular(_DS.r20),
                        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
                        boxShadow: [BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.28) : Colors.black.withOpacity(0.05),
                          blurRadius: 16, offset: const Offset(0, 6),
                        )],
                      ),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                          child: Row(children: [
                            Expanded(child: Text(item["EmpName"] ?? "",
                              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14, fontWeight: FontWeight.w700))),
                            _statusBadge(item["Status"] ?? "", si.color),
                          ]),
                        ),
                        Divider(height: 1, color: isDark ? _DS.borderDark : _DS.borderLight),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _infoRow(Icons.calendar_today_outlined, "Date",   item["AttendanceDate"] ?? "", isDark),
                            const SizedBox(height: 4),
                            _infoRow(Icons.notes_rounded,           "Reason", item["Reason"]          ?? "", isDark),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: _timeColPremium("In Time",  item["InTime"]  ?? "--", _DS.green1, isDark)),
                              Container(width: 1, height: 36, color: isDark ? Colors.white10 : Colors.black38, margin: const EdgeInsets.symmetric(horizontal: 8)),
                              Expanded(child: _timeColPremium("Out Time", item["OutTime"] ?? "--", const Color(0xFFEF4444), isDark)),
                            ]),
                            if (selectedApprovalTab == 0) ...[
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: GestureDetector(
                                  onTap: () {},
                                  child: _gradientBtn("Approve", Icons.check_circle_outline_rounded),
                                )),
                                const SizedBox(width: 10),
                                Expanded(child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(_DS.r12),
                                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
                                    ),
                                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 16),
                                      SizedBox(width: 6),
                                      Text("Reject", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700, fontSize: 13)),
                                    ]),
                                  ),
                                )),
                              ]),
                            ],
                          ]),
                        ),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // ─── AUTH TABS ───────────────────────────────────────────
  Widget _authorizationTabs({bool isDark = false}) {
    return Container(
      height: 48, padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black38, blurRadius: 10)],
      ),
      child: Row(children: [
        _authPill("Pending",  0, const Color(0xFFF59E0B), isDark),
        _authPill("Approved", 1, _DS.green1,              isDark),
        _authPill("Rejected", 2, const Color(0xFFEF4444), isDark),
      ]),
    );
  }

  Widget _authPill(String label, int index, Color color, bool isDark) {
    final bool isSelected = selectedApprovalTab == index;
    return Expanded(child: GestureDetector(
      onTap: () => getLeaveAuthorizationList(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color.withOpacity(0.4)) : null,
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(
          color: isSelected ? color : (isDark ? Colors.white38 : Colors.black38),
          fontWeight: FontWeight.w700, fontSize: 12,
        )),
      ),
    ));
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────
  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(label, style: TextStyle(
      color: isDark ? Colors.white54 : const Color(0xFF64748B),
      fontSize: 12, fontWeight: FontWeight.w600,
    ));
  }

  Widget _gradientBtn(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_DS.brandStart, _DS.brandDeep]),
        borderRadius: BorderRadius.circular(_DS.r12),
        boxShadow: [BoxShadow(color: _DS.brandStart.withOpacity(0.35), blurRadius: 10)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ]),
    );
  }

  Widget _timeColPremium(String label, String value, Color color, bool isDark) {
    return Column(children: [
      Text(label, style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 10, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
      const SizedBox(height: 2),
      Container(width: 16, height: 2.5, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
    ]);
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 13, color: isDark ? Colors.white38 : Colors.black38),
      const SizedBox(width: 6),
      Text("$label: ", style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 11, fontWeight: FontWeight.w500)),
      Expanded(child: Text(value, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.w600))),
    ]);
  }

  Widget _loadingState() => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    CircularProgressIndicator(color: _DS.brandStart, strokeWidth: 2.5),
    SizedBox(height: 14),
    Text("Loading…", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
  ]));

  Widget _emptyState(String msg, IconData icon, bool isDark) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _DS.brandStart.withOpacity(0.10), shape: BoxShape.circle),
      child: Icon(icon, color: _DS.brandStart, size: 32)),
    const SizedBox(height: 14),
    Text(msg, style: TextStyle(color: isDark ? Colors.white54 : Colors.black38, fontSize: 14, fontWeight: FontWeight.w600)),
  ]));

  InputDecoration _fieldDecoration(String hint, bool isDark, {IconData? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26, fontSize: 12),
      suffixIcon: suffix != null ? Icon(suffix, color: isDark ? Colors.white38 : Colors.black38, size: 18) : null,
      filled: true,
      fillColor: isDark ? _DS.inputDark : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(_DS.r12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_DS.r12),
        borderSide: BorderSide(color: isDark ? _DS.borderDark : _DS.borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_DS.r12),
        borderSide: const BorderSide(color: _DS.brandStart, width: 1.8)),
    );
  }

  // ─── COMPANY + EMPLOYEE SEARCH (consistent with attendance) ─
  Widget companyDropdown({bool isDark = false}) {
    return DropdownButtonFormField<String>(
      value: selectedComp,
      dropdownColor: isDark ? _DS.cardDark : null,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
      decoration: _fieldDecoration("Select Company", isDark),
      items: companyMap.entries.map((e) => DropdownMenuItem<String>(
        value: e.value,
        child: Text(e.key, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13)),
      )).toList(),
      onChanged: (v) => setState(() { selectedComp = v; empNameController.clear(); selEmpCode = ""; searchEmp.clear(); }),
    );
  }

  Widget employeeSearchField({bool isDark = false}) {
    return TextField(
      controller: empNameController,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 13),
      decoration: _fieldDecoration("Search Employee", isDark).copyWith(
        prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white38 : Colors.black38, size: 20),
      ),
      onChanged: (v) {
        selEmpCode = "";
        if (v.length >= 2) {
          getEmployeeNameSearch(emppk);
        } else {
          setState(() => searchEmp.clear());
        }
      },
    );
  }

  Widget employeeSearchList({bool isDark = false}) {
    if (searchEmp.isEmpty) return const SizedBox();
    return Container(
      height: 150, margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r12),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [BoxShadow(color: isDark ? Colors.black26 : Colors.black38, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_DS.r12),
        child: ListView.separated(
          itemCount: searchEmp.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? _DS.borderDark : _DS.borderLight),
          itemBuilder: (context, index) {
            final emp = searchEmp[index];
            return ListTile(
              dense: true,
              leading: CircleAvatar(radius: 16,
                backgroundColor: _DS.brandStart.withOpacity(0.15),
                child: const Icon(Icons.person_outline, color: _DS.brandStart, size: 16)),
              title: Text("${emp["Employee_Code"]} — ${emp["EmpName"]}",
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF334155), fontSize: 12, fontWeight: FontWeight.w600)),
              onTap: () => setState(() { empNameController.text = emp["EmpName"]; selEmpCode = emp["Employee_Code"]; searchEmp.clear(); }),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  STATUS HELPERS
// ─────────────────────────────────────────────────────────────
class _StatusInfo {
  final String label; final Color color; final IconData icon;
  const _StatusInfo(this.label, this.color, this.icon);
}

_StatusInfo _approvalStatusInfo(String status) {
  switch (status.toLowerCase()) {
    case "approved": return const _StatusInfo("Approved", Color(0xFF10B981), Icons.check_circle_outline_rounded);
    case "rejected": return const _StatusInfo("Rejected", Color(0xFFEF4444), Icons.cancel_outlined);
    case "pending":  return const _StatusInfo("Pending",  Color(0xFFF59E0B), Icons.hourglass_empty_rounded);
    default:         return const _StatusInfo("—",        Colors.grey,       Icons.help_outline);
  }
}

// const _DS_green1 = Color(0xFF10B981);
// extension _DSExt on _DS { static const Color green1 = Color(0xFF10B981); }