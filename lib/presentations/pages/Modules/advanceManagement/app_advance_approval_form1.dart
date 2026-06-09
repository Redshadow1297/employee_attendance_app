// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ApprovalFormScreen extends StatefulWidget {
//   final int transId;
//   final int empPk;
//   final String companyGroup;

//   const ApprovalFormScreen({
//     super.key,
//     required this.transId,
//     required this.empPk,
//     required this.companyGroup,
//   });

//   @override
//   State<ApprovalFormScreen> createState() => _ApprovalFormScreenState();
// }

// class _ApprovalFormScreenState extends State<ApprovalFormScreen> {
//   Map<String, dynamic>? data;
//   String? _downloadedFilePath;
//   bool _isDownloading = false;
//   double _downloadProgress = 0.0;
//   bool isLoading = true;
//   int? emppk;
//   int? isSuperAdmin;
//   String? empcode;

//   final TextEditingController approvalReasonController =
//       TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     getPrefsData().then((_) => fetchAdvanceDetails());
//   }

//   /// ---------------- Safe Date Parser ----------------
//   /// Handles multiple API date formats:
//   /// "Apr 10, 2026"  → MMM d, yyyy
//   /// "Apr 10, 2026"  → MMM dd, yyyy  (intl is lenient with 'd' for both)
//   /// "10 Apr, 2026"  → dd MMM, yyyy
//   /// "10/04/2026"    → dd/MM/yyyy
//   String _parseToApiDate(String? raw) {
//     if (raw == null || raw.isEmpty) return '';
//     final formats = [
//       DateFormat("MMM d, yyyy"),   // "Apr 10, 2026"  ← actual API format
//       DateFormat("MMM dd, yyyy"),  // fallback
//       DateFormat("dd MMM, yyyy"),  // "10 Apr, 2026"
//       DateFormat("dd/MM/yyyy"),    // "10/04/2026"
//       DateFormat("dd/MM/yy"),      // "10/04/26"
//     ];
//     for (final fmt in formats) {
//       try {
//         final parsed = fmt.parseStrict(raw.trim());
//         return DateFormat("dd/MM/yyyy").format(parsed);
//       } catch (_) {}
//     }
//     debugPrint("Date parse failed for: $raw");
//     return raw; // return as-is if all formats fail
//   }

//   ///////Prefs Data...
//   Future<void> getPrefsData() async {
//     final prefs = await SharedPreferences.getInstance();
//     emppk = prefs.getInt('emppk');
//     empcode = prefs.getString('employeecode');
//     isSuperAdmin = int.tryParse(prefs.getString('issuperadmin') ?? '0') ?? 0;
//     debugPrint('Loaded EmpPk - $emppk');
//   }

//   /// ---------------- Fetch Advance Details ----------------
//   Future<void> fetchAdvanceDetails() async {
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.getAdvanceDetails,
//         data: {
//           "TransID": widget.transId,
//           "EmpPK": widget.empPk,
//           "CompanyGroup": widget.companyGroup,
//         },
//       );

//       final responseData = response.data is Map
//           ? Map<String, dynamic>.from(response.data)
//           : null;

//       setState(() {
//         data = responseData;
//         isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("DETAIL API ERROR $e");
//       setState(() => isLoading = false);
//     }
//   }

//   ////Approve / Reject Advance application
//   Future<void> _approveAdvance() async {
//     String reason = approvalReasonController.text.trim();
//     if (reason.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter a reason for approval/rejection."),
//         ),
//       );
//       return;
//     }
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.approveAdvanceApplication,
//         data: {
//           "EmpPK": data?["EmpPK"],
//           "CompanyPK": data?["Companypk"],
//           "Status": "Approved",
//           "TransID": data?["TransID"],
//           "ApprovalReason": approvalReasonController.text,
//           "NoOfInstallments": null,
//           "EffectiveMonthYear": null,
//           "EndMonthYear": null,
//           "ApplicationDate": _parseToApiDate(data!["ApplicationDate"]?.toString()),
//           "AdvanceAmount": data?["AdvanceAmount"],
//           "IsFirstApprover": data?["IsFirstApprover"],
//           "IsSecondApprover": data?["IsSecondApprover"],
//           "IsFinalHRApprover": data?["IsFinalHRApprover"],
//           "ReportingPK": data?["Reportingpk"],
//           "Reason": data?["Reason"],
//           "CompanyGroup": data?["CompanyGroup"],
//         },
//       );

//       if (response.statusCode == 200) {
//         CommonSnackBar.show(
//           context: context,
//           title: "Success",
//           message: "Advance approved successfully.",
//           type: SnackBarType.success,
//         );
//         Navigator.pop(context, true);
//       } else {
//         CommonSnackBar.show(
//           context: context,
//           title: "Error",
//           message: "Failed to approve advance. Please try again.",
//           type: SnackBarType.error,
//         );
//       }
//     } catch (e) {
//       debugPrint("APPROVAL ERROR: $e");
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "An error occurred while processing your request.",
//         type: SnackBarType.error,
//       );
//     }
//   }

//   Future<void> _rejectAdvance() async {
//     String reason = approvalReasonController.text.trim();
//     if (reason.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter a reason for approval/rejection."),
//         ),
//       );
//       return;
//     }
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.approveAdvanceApplication,
//         data: {
//           "EmpPK": data?["EmpPK"],
//           "CompanyPK": data?["Companypk"],
//           "Status": "Rejected",
//           "TransID": data?["TransID"],
//           "ApprovalReason": approvalReasonController.text,
//           "NoOfInstallments": null,
//           "EffectiveMonthYear": null,
//           "EndMonthYear": null,
//           "ApplicationDate": _parseToApiDate(data?["ApplicationDate"]?.toString()),
//           "AdvanceAmount": data?["AdvanceAmount"],
//           "IsFirstApprover": data?["IsFirstApprover"],
//           "IsSecondApprover": data?["IsSecondApprover"],
//           "IsFinalHRApprover": data?["IsFinalHRApprover"],
//           "ReportingPK": data?["Reportingpk"],
//           "Reason": data?["Reason"],
//           "CompanyGroup": data?["CompanyGroup"],
//         },
//       );

//       if (response.statusCode == 200) {
//         CommonSnackBar.show(
//           context: context,
//           title: "Success",
//           message: "Advance rejected successfully.",
//           type: SnackBarType.success,
//         );
//         Navigator.pop(context, true);
//       } else {
//         CommonSnackBar.show(
//           context: context,
//           title: "Error",
//           message: "Failed to reject advance. Please try again.",
//           type: SnackBarType.error,
//         );
//       }
//     } catch (e) {
//       debugPrint("APPROVAL ERROR: $e");
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "An error occurred while processing your request.",
//         type: SnackBarType.error,
//       );
//     }
//   }

//   /// ---------------- DOWNLOAD FILE ----------------
//   Future<void> _downloadAndOpenFileFromBase64(
//     String base64FileString,
//     String fileName,
//   ) async {
//     try {
//       setState(() {
//         _isDownloading = true;
//         _downloadProgress = 0.3;
//       });

//       if (base64FileString.isEmpty) {
//         throw Exception("Empty file");
//       }

//       String cleanedBase64 = base64FileString.contains(',')
//           ? base64FileString.split(',').last
//           : base64FileString;

//       Uint8List bytes = base64Decode(cleanedBase64);

//       final dir = await getApplicationDocumentsDirectory();
//       String path = "${dir.path}/$fileName.pdf";

//       File file = File(path);
//       await file.writeAsBytes(bytes);

//       setState(() {
//         _downloadedFilePath = path;
//         _isDownloading = false;
//         _downloadProgress = 1.0;
//       });

//       await OpenFile.open(path);
//     } catch (e) {
//       setState(() => _isDownloading = false);
//       debugPrint("Download Error: $e");
//     }
//   }

//   /// ---------------- OPEN FILE ----------------
//   Future<void> _openDownloadedFile() async {
//     if (_downloadedFilePath == null) return;
//     await OpenFile.open(_downloadedFilePath!);
//   }

//   /// ---------------- UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey[100],
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _header(),
//             isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : data == null
//                 ? Center(
//                     child: Text(
//                       "No Data Found",
//                       style: TextStyle(
//                         color: isDark ? Colors.white54 : Colors.black54,
//                       ),
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     padding: const EdgeInsets.all(8),
//                     child: Column(
//                       children: [
//                         _infoCard(data!, isDark: isDark),
//                         _documentCard(data!, isDark: isDark),
//                         _actionCard(isDark: isDark),
//                       ],
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }

//   ////------------Header----------------
//   Widget _header() {
//     return Container(
//       height: 100,
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color.fromARGB(255, 232, 70, 145),
//             Color.fromARGB(255, 167, 9, 83),
//           ],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(12),
//           bottomRight: Radius.circular(12),
//         ),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: CircleAvatar(
//               backgroundColor: Colors.white.withOpacity(0.2),
//               child: const Icon(Icons.arrow_back, color: Colors.white),
//             ),
//           ),
//           const SizedBox(width: 12),
//           const Text(
//             "Advance Approval Details",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ---------------- INFO CARD ----------------
//   Widget _infoCard(Map<String, dynamic> data, {bool isDark = false}) {
//     return _card(
//       isDark: isDark,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Employee Details",
//             style: AppTextStyles.headingSmall.copyWith(
//               //      Theme-aware heading
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _row("Name", data["EmployeeName"], isDark: isDark),
//           _row("Code", data["EmployeeCode"], isDark: isDark),
//           _row("Company", data["CompanyName"], isDark: isDark),
//           _row("Department", data["DepartmentName"], isDark: isDark),
//           _row("Location", data["LocationName"], isDark: isDark),
//           _row("Salary", data["GrossSalary"], isDark: isDark),
//           Divider(
//             color: isDark ? Colors.white12 : Colors.grey.shade300,
//           ),
//           Text(
//             "Advance Details",
//             style: AppTextStyles.headingSmall.copyWith(
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _row("Amount", "₹${data["AdvanceAmount"] ?? "0"}", isDark: isDark),
//           _row("Reason", data["Reason"], isDark: isDark),
//           _row("Date", data["ApplicationDate"], isDark: isDark),
//           _row("Status", data["ApprovalStatus"], isDark: isDark),
//         ],
//       ),
//     );
//   }

//   Widget _row(String title, dynamic value, {bool isDark = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 4,
//             child: Text(
//               title,
//               style: AppTextStyles.labelMedium.copyWith(
//                 color: isDark ? Colors.white38 : Colors.grey[600],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 6,
//             child: Text(
//               value?.toString() ?? "-",
//               style: AppTextStyles.labelMedium.copyWith(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// ---------------- DOCUMENT CARD ----------------
//   Widget _documentCard(Map<String, dynamic> data, {bool isDark = false}) {
//     final base64 = data["PathnameBase64"];

//     return _card(
//       isDark: isDark,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Document",
//             style: AppTextStyles.headingSmall.copyWith(
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 10),
//           (base64 != null && base64.toString().isNotEmpty)
//               ? Column(
//                   children: [
//                     if (_isDownloading)
//                       LinearProgressIndicator(value: _downloadProgress),
//                     const SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CommonButton(
//                             width: 100,
//                             height: 45,
//                             color: const Color(0xFF4A90E2),
//                             label: "⬇ Download",
//                             onPressed: () {
//                               _downloadAndOpenFileFromBase64(
//                                 base64.toString(),
//                                 "Advance_${widget.transId}",
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         if (_downloadedFilePath != null)
//                           Expanded(
//                             child: CommonButton(
//                               height: 45,
//                               color: const Color(0xFF27AE60),
//                               label: "📂 Open",
//                               onPressed: _openDownloadedFile,
//                               width: 100,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ],
//                 )
//               : Text(
//                   "No document available",
//                   style: TextStyle(
//                     color: isDark ? Colors.white38 : Colors.grey,
//                   ),
//                 ),
//         ],
//       ),
//     );
//   }

//   /// ---------------- ACTION CARD ----------------
//   Widget _actionCard({bool isDark = false}) {
//     return _card(
//       isDark: isDark,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Action",
//             style: AppTextStyles.headingSmall.copyWith(
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: approvalReasonController,
//             maxLines: 3,
//             style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//             decoration: InputDecoration(
//               hintText: "Enter approval/reject reason...",
//               hintStyle: TextStyle(
//                 color: isDark ? Colors.white38 : Colors.grey,
//               ),
//               filled: true,
//               fillColor: isDark
//                   ? const Color(0xFF1E293B)
//                   : Colors.grey.shade100,
//               contentPadding: const EdgeInsets.all(14),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide: BorderSide.none,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white12 : Colors.transparent,
//                 ),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(14),
//                 borderSide: BorderSide(
//                   color: isDark
//                       ? const Color.fromARGB(255, 232, 70, 145)
//                       : const Color.fromARGB(255, 167, 9, 83),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: CommonButton(
//                   width: double.infinity,
//                   height: 48,
//                   color: Colors.green,
//                   label: "Approve",
//                   onPressed: _approveAdvance,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: CommonButton(
//                   width: double.infinity,
//                   height: 48,
//                   color: const Color(0xFFE74C3C),
//                   label: "Reject",
//                   onPressed: _rejectAdvance,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// ---------------- COMMON CARD ----------------
//   Widget _card({required Widget child, bool isDark = false}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isDark ? Colors.white12 : Colors.grey.shade200,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.4)
//                 : Colors.black.withOpacity(0.04),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   @override
//   void dispose() {
//     approvalReasonController.dispose();
//     super.dispose();
//   }
// }

// ignore: dangling_library_doc_comments
///NEW UI

// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────

class _DS {
  static const Color brandStart = Color(0xFF14B8A6);
  static const Color brandMid = Color(0xFF0D9488);
  static const Color brandDeep = Color(0xFF0F766E);

  static const Color green = Color(0xFF10B981);
  static const Color greenDeep = Color(0xFF059669);
  static const Color red = Color(0xFFEF4444);
  static const Color redDeep = Color(0xFFDC2626);
  static const Color blue = Color(0xFF3B82F6);

  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color inputDark = Color(0xFF263244);

  static const double r12 = 12;
  // static const double r16 = 16;
  static const double r20 = 20;
  // static const double r24 = 24;
}


class ApprovalFormScreen extends StatefulWidget {
  final int transId;
  final int empPk;
  final String companyGroup;

  const ApprovalFormScreen({
    super.key,
    required this.transId,
    required this.empPk,
    required this.companyGroup,
  });

  @override
  State<ApprovalFormScreen> createState() => _ApprovalFormScreenState();
}

class _ApprovalFormScreenState extends State<ApprovalFormScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? data;
  String? _downloadedFilePath;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool isLoading = true;
  int? emppk;
  int? isSuperAdmin;
  String? empcode;

  final TextEditingController approvalReasonController =
      TextEditingController();

  // Fade animation
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  // ── LOGIC (all unchanged) ────────────────────────────────
  @override
  void initState() {
    super.initState();
    getPrefsData().then((_) => fetchAdvanceDetails());
  }

  @override
  void dispose() {
    approvalReasonController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  String _parseToApiDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final formats = [
      DateFormat("MMM d, yyyy"),
      DateFormat("MMM dd, yyyy"),
      DateFormat("dd MMM, yyyy"),
      DateFormat("dd/MM/yyyy"),
      DateFormat("dd/MM/yy"),
    ];
    for (final fmt in formats) {
      try {
        return DateFormat("dd/MM/yyyy").format(fmt.parseStrict(raw.trim()));
      } catch (_) {}
    }
    return raw;
  }

  Future<void> getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk = prefs.getInt('emppk');
    empcode = prefs.getString('employeecode');
    isSuperAdmin = int.tryParse(prefs.getString('issuperadmin') ?? '0') ?? 0;
  }

  Future<void> fetchAdvanceDetails() async {
    try {
      final response = await ApiClient.post(
        ApiConstants.getAdvanceDetails,
        data: {
          "TransID": widget.transId,
          "EmpPK": widget.empPk,
          "CompanyGroup": widget.companyGroup,
        },
      );
      final responseData = response.data is Map
          ? Map<String, dynamic>.from(response.data)
          : null;
      setState(() {
        data = responseData;
        isLoading = false;
      });
      _fadeCtrl.forward();
    } catch (e) {
      debugPrint("DETAIL API ERROR $e");
      setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _buildApprovalPayload(String status) => {
    "EmpPK": data?["EmpPK"],
    "CompanyPK": data?["Companypk"],
    "Status": status,
    "TransID": data?["TransID"],
    "ApprovalReason": approvalReasonController.text,
    "NoOfInstallments": null,
    "EffectiveMonthYear": null,
    "EndMonthYear": null,
    "ApplicationDate": _parseToApiDate(data?["ApplicationDate"]?.toString()),
    "AdvanceAmount": data?["AdvanceAmount"],
    "IsFirstApprover": data?["IsFirstApprover"],
    "IsSecondApprover": data?["IsSecondApprover"],
    "IsFinalHRApprover": data?["IsFinalHRApprover"],
    "ReportingPK": data?["Reportingpk"],
    "Reason": data?["Reason"],
    "CompanyGroup": data?["CompanyGroup"],
  };

  bool _validateReason() {
    if (approvalReasonController.text.trim().isEmpty) {
      CommonSnackBar.show(
        context: context,
        title: "Warning",
        message: "Please enter a reason for approval/rejection.",
        type: SnackBarType.warning,
      );
      return false;
    }
    return true;
  }

//APPROVE ADVANCE
  Future<void> _approveAdvance() async {
    if (!_validateReason()) return;
    try {
      final response = await ApiClient.post(
        ApiConstants.approveAdvanceApplication,
        data: _buildApprovalPayload("Approved"),
      );
      if (response.statusCode == 200) {
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: "Advance approved successfully.",
          type: SnackBarType.success,
        );
        Navigator.pop(context, true);
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Error",
          message: "Failed to approve advance.",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "An error occurred.",
        type: SnackBarType.error,
      );
    }
  }


//REJECT ADVANCE
  Future<void> _rejectAdvance() async {
    if (!_validateReason()) return;
    try {
      final response = await ApiClient.post(
        ApiConstants.approveAdvanceApplication,
        data: _buildApprovalPayload("Rejected"),
      );
      if (response.statusCode == 200) {
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: "Advance rejected successfully.",
          type: SnackBarType.success,
        );
        Navigator.pop(context, true);
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Error",
          message: "Failed to reject advance.",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "An error occurred.",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _downloadAndOpenFileFromBase64(
    String base64FileString,
    String fileName,
  ) async {
    try {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.3;
      });
      if (base64FileString.isEmpty) throw Exception("Empty file");
      String cleanedBase64 = base64FileString.contains(',')
          ? base64FileString.split(',').last
          : base64FileString;
      Uint8List bytes = base64Decode(cleanedBase64);
      final dir = await getApplicationDocumentsDirectory();
      String path = "${dir.path}/$fileName.pdf";
      File file = File(path);
      await file.writeAsBytes(bytes);
      setState(() {
        _downloadedFilePath = path;
        _isDownloading = false;
        _downloadProgress = 1.0;
      });
      await OpenFile.open(path);
    } catch (e) {
      setState(() => _isDownloading = false);
      debugPrint("Download Error: $e");
    }
  }

  Future<void> _openDownloadedFile() async {
    if (_downloadedFilePath == null) return;
    await OpenFile.open(_downloadedFilePath!);
  }

  //  BUILD
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _DS.surfaceDark : _DS.surfaceLight,
      body: Column(
        children: [
          _header(isDark),
          Expanded(
            child: isLoading
                ? _loadingState()
                : data == null
                ? _emptyState(isDark)
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _infoCard(isDark),
                          const SizedBox(height: 14),
                          _documentCard(isDark),
                          const SizedBox(height: 14),
                          _actionCard(isDark),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ─── PREMIUM HEADER ──────────────────────────────────────
  Widget _header(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_DS.brandStart, _DS.brandMid, _DS.brandDeep],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: _decorCircle(120, Colors.white.withOpacity(0.06)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Advance Approval",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        "Review & Take Action",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.70),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ─── INFO CARD ───────────────────────────────────────────
  Widget _infoCard(bool isDark) {
    final d = data!;
    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader(
          "Employee Details",
          Icons.person_outline_rounded,
          const Color(0xFF3B82F6),
          isDark,
        ),
        const SizedBox(height: 14),
        _infoRow("Name", d["EmployeeName"], isDark),
        _infoRow("Code", d["EmployeeCode"], isDark),
        _infoRow("Company", d["CompanyName"], isDark),
        _infoRow("Department", d["DepartmentName"], isDark),
        _infoRow("Location", d["LocationName"], isDark),
        _infoRow("Salary", d["GrossSalary"], isDark),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            color: isDark ? _DS.borderDark : _DS.borderLight,
            height: 1,
          ),
        ),

        _sectionHeader(
          "Advance Details",
          Icons.account_balance_wallet_rounded,
          _DS.brandStart,
          isDark,
        ),
        const SizedBox(height: 14),
        _infoRow(
          "Amount",
          "₹${d["AdvanceAmount"] ?? "0"}",
          isDark,
          valueColor: _DS.brandStart,
        ),
        _infoRow("Reason", d["Reason"], isDark),
        _infoRow("Date", d["ApplicationDate"], isDark),
        _infoRow(
          "Status",
          d["ApprovalStatus"],
          isDark,
          valueColor: _approvalColor(d["ApprovalStatus"]?.toString() ?? ""),
        ),
      ],
    );
  }

  Widget _infoRow(
    String label,
    dynamic value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white38 : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? "—",
              style: TextStyle(
                color:
                    valueColor ??
                    (isDark ? Colors.white : const Color(0xFF0F172A)),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _approvalColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('approved')) return _DS.green;
    if (lower.contains('rejected')) return _DS.red;
    return const Color(0xFFF59E0B);
  }

  // ─── DOCUMENT CARD ───────────────────────────────────────
  Widget _documentCard(bool isDark) {
    final base64 = data?["PathnameBase64"];
    final hasDoc = base64 != null && base64.toString().isNotEmpty;

    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader(
          "Document",
          Icons.attach_file_rounded,
          const Color(0xFF8B5CF6),
          isDark,
        ),
        const SizedBox(height: 14),

        if (!hasDoc)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(_DS.r12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_off_outlined,
                  color: isDark ? Colors.white38 : Colors.black26,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "No document available",
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

        if (hasDoc) ...[
          if (_isDownloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _downloadProgress,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : Colors.black38,
                valueColor: const AlwaysStoppedAnimation(_DS.brandStart),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _downloadAndOpenFileFromBase64(
                    base64.toString(),
                    "Advance_${widget.transId}",
                  ),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_DS.blue, Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(_DS.r12),
                      boxShadow: [
                        BoxShadow(
                          color: _DS.blue.withOpacity(0.35),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Download",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_downloadedFilePath != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openDownloadedFile,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_DS.green, _DS.greenDeep],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(_DS.r12),
                        boxShadow: [
                          BoxShadow(
                            color: _DS.green.withOpacity(0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Open File",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // ─── ACTION CARD ─────────────────────────────────────────
  Widget _actionCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader(
          "Take Action",
          Icons.gavel_rounded,
          const Color(0xFFF59E0B),
          isDark,
        ),
        const SizedBox(height: 14),

        TextField(
          controller: approvalReasonController,
          maxLines: 3,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: "Enter reason for approval or rejection…",
            hintStyle: TextStyle(
              color: isDark ? Colors.white30 : Colors.black26,
              fontSize: 12,
            ),
            filled: true,
            fillColor: isDark ? _DS.inputDark : const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.r12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.r12),
              borderSide: BorderSide(
                color: isDark ? _DS.borderDark : _DS.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_DS.r12),
              borderSide: const BorderSide(color: _DS.brandStart, width: 1.8),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            // Approve
            Expanded(
              child: GestureDetector(
                onTap: _approveAdvance,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_DS.green, _DS.greenDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(_DS.r12),
                    boxShadow: [
                      BoxShadow(
                        color: _DS.green.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Approve",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Reject
            Expanded(
              child: GestureDetector(
                onTap: _rejectAdvance,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_DS.red, _DS.redDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(_DS.r12),
                    boxShadow: [
                      BoxShadow(
                        color: _DS.red.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Reject",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── SECTION CARD ────────────────────────────────────────
  Widget _sectionCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r20),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ─── STATES ──────────────────────────────────────────────
  Widget _loadingState() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: _DS.brandStart, strokeWidth: 2.5),
        SizedBox(height: 14),
        Text(
          "Loading details…",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    ),
  );

  Widget _emptyState(bool isDark) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _DS.brandStart.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: _DS.brandStart,
            size: 32,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "No Data Found",
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black38,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
