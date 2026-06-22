// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/ds_color_handler.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // EMI fields
  final installmentController = TextEditingController();
  final TextEditingController approvalReasonController = TextEditingController();
  DateTime? startDate;
  List<Map<String, dynamic>> emiList = [];

  // Fade animation
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    getPrefsData().then((_) => fetchAdvanceDetails());
  }

  @override
  void dispose() {
    approvalReasonController.dispose();
    installmentController.dispose();
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
        "NoOfInstallments": installmentController.text.trim(),
        "EffectiveMonthYear": startDate != null
            ? DateFormat('dd/MM/yyyy').format(startDate!)
            : null,
        "EndMonthYear": null,
        "ApplicationDate":
            _parseToApiDate(data?["ApplicationDate"]?.toString()),
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

  Future<void> _approveAdvance() async {
    if (!_validateReason()) return;
    try {
      setState(() => isLoading = true);
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _rejectAdvance() async {
    if (!_validateReason()) return;
    try {
      setState(() => isLoading = true);
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _downloadAndOpenFileFromBase64(
      String base64FileString, String fileName) async {
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

  void generateEmiChart() {
    emiList.clear();
    final amount =
        double.tryParse(data?["AdvanceAmount"]?.toString() ?? "0") ?? 0;
    final installments = int.tryParse(installmentController.text.trim()) ?? 0;
    if (installments <= 0 || startDate == null) return;
    final emi = amount / installments;
    double balance = amount;
    for (int i = 1; i <= installments; i++) {
      balance -= emi;
      emiList.add({
        "no": i,
        "date": DateFormat("dd-MM-yyyy").format(
          DateTime(
              startDate!.year, startDate!.month + (i - 1), startDate!.day),
        ),
        "emi": emi.toStringAsFixed(0),
        "balance": balance <= 0 ? "0" : balance.toStringAsFixed(0),
      });
    }
    setState(() {});
  }

  // ─────────────────────────────── BUILD ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DS.surfaceDark : const Color(0xFFFDF4F8),
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
                              _emiCard(isDark),
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

  // ─────────────────────────────── HEADER ───────────────────────────────
  Widget _header(bool isDark) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DS.brandStart, DS.brandMid, DS.brandDeep],
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

  // ─────────────────────────────── INFO CARD ───────────────────────────────
  Widget _infoCard(bool isDark) {
    final d = data!;
    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader(
            "Employee Details", Icons.person_outline_rounded, const Color(0xFF3B82F6), isDark),
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
              color: isDark ? DS.borderDark : DS.borderLight, height: 1),
        ),
        _sectionHeader(
            "Advance Details", Icons.account_balance_wallet_rounded, DS.brandStart, isDark),
        const SizedBox(height: 14),
        _infoRow("Amount", "₹${d["AdvanceAmount"] ?? "0"}", isDark,
            valueColor: DS.brandStart),
        _infoRow("Reason", d["Reason"], isDark),
        _infoRow("Date", d["ApplicationDate"], isDark),
        _infoRow("Status", d["ApprovalStatus"], isDark,
            valueColor: _approvalColor(d["ApprovalStatus"]?.toString() ?? "")),
      ],
    );
  }

  Widget _infoRow(String label, dynamic value, bool isDark,
      {Color? valueColor}) {
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
                color: valueColor ??
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
    if (lower.contains('approved')) return DS.green;
    if (lower.contains('rejected')) return DS.red;
    return const Color(0xFFF59E0B);
  }

  // ─────────────────────────────── DOCUMENT CARD ───────────────────────────────
  Widget _documentCard(bool isDark) {
    final base64 = data?["PathnameBase64"];
    final hasDoc = base64 != null && base64.toString().isNotEmpty;

    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader("Document", Icons.attach_file_rounded,
            const Color(0xFF8B5CF6), isDark),
        const SizedBox(height: 14),
        if (!hasDoc)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(DS.r12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined,
                    color: isDark ? Colors.white38 : Colors.black26, size: 20),
                const SizedBox(width: 8),
                Text(
                  "No document available",
                  style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                      fontSize: 13),
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
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: const AlwaysStoppedAnimation(DS.brandStart),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _downloadAndOpenFileFromBase64(
                      base64.toString(), "Advance_${widget.transId}"),
                  child: _gradientButton(
                    label: "Download",
                    icon: Icons.download_rounded,
                    colors: [DS.blue, const Color(0xFF2563EB)],
                    shadowColor: DS.blue,
                  ),
                ),
              ),
              if (_downloadedFilePath != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openDownloadedFile,
                    child: _gradientButton(
                      label: "Open File",
                      icon: Icons.folder_open_rounded,
                      colors: [DS.green, DS.greenDeep],
                      shadowColor: DS.green,
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

  // ─────────────────────────────── EMI CARD ───────────────────────────────
  Widget _emiCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader("EMI Schedule", Icons.calendar_month_rounded,
            const Color(0xFFF59E0B), isDark),
        const SizedBox(height: 14),

        // Installments input
        TextField(
          controller: installmentController,
          keyboardType: TextInputType.number,
          style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 13),
          decoration: _inputDecoration("No. of Installments", isDark),
        ),
        const SizedBox(height: 12),

        // Date picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => startDate = picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? DS.inputDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(DS.r12),
              border: Border.all(
                  color: isDark ? DS.borderDark : DS.borderLight),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded,
                    size: 17,
                    color: isDark ? Colors.white38 : const Color(0xFF64748B)),
                const SizedBox(width: 10),
                Text(
                  startDate == null
                      ? "Select Start Date"
                      : DateFormat("dd-MM-yyyy").format(startDate!),
                  style: TextStyle(
                    fontSize: 13,
                    color: startDate == null
                        ? (isDark ? Colors.white30 : Colors.black38)
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Generate button
        GestureDetector(
          onTap: generateEmiChart,
          child: _gradientButton(
            label: "Generate EMI Chart",
            icon: Icons.auto_graph_rounded,
            colors: [DS.brandStart, DS.brandDeep],
            shadowColor: DS.brandStart,
          ),
        ),

        // EMI Table
        if (emiList.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(color: isDark ? DS.borderDark : DS.borderLight, height: 1),
          const SizedBox(height: 12),
          // Header row
          Row(
            children: [
              _emiHeaderCell("#", isDark, flex: 1),
              _emiHeaderCell("Date", isDark, flex: 3),
              _emiHeaderCell("EMI (₹)", isDark, flex: 2),
              _emiHeaderCell("Balance (₹)", isDark, flex: 2),
            ],
          ),
          const SizedBox(height: 6),
          ...emiList.map((e) => _emiRow(e, isDark)),
        ],
      ],
    );
  }

  Widget _emiHeaderCell(String label, bool isDark, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emiRow(Map<String, dynamic> e, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : const Color(0xFFFDF4F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text("${e["no"]}",
                  style: _emiCellStyle(isDark))),
          Expanded(
              flex: 3,
              child:
                  Text(e["date"], style: _emiCellStyle(isDark))),
          Expanded(
              flex: 2,
              child:
                  Text(e["emi"], style: _emiCellStyle(isDark, bold: true))),
          Expanded(
              flex: 2,
              child: Text(e["balance"],
                  style: _emiCellStyle(isDark,
                      color: DS.brandStart))),
        ],
      ),
    );
  }

  TextStyle _emiCellStyle(bool isDark,
      {bool bold = false, Color? color}) {
    return TextStyle(
      color: color ?? (isDark ? Colors.white70 : const Color(0xFF0F172A)),
      fontSize: 12,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
  }

  // ─────────────────────────────── ACTION CARD ───────────────────────────────
  Widget _actionCard(bool isDark) {
    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader("Take Action", Icons.gavel_rounded,
            const Color(0xFFF59E0B), isDark),
        const SizedBox(height: 14),
        TextField(
          controller: approvalReasonController,
          maxLines: 3,
          style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 13),
          decoration: _inputDecoration(
              "Enter reason for approval or rejection…", isDark),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _approveAdvance,
                child: _gradientButton(
                  label: "Approve",
                  icon: Icons.check_circle_outline_rounded,
                  colors: [DS.green, DS.greenDeep],
                  shadowColor: DS.green,
                  height: 48,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _rejectAdvance,
                child: _gradientButton(
                  label: "Reject",
                  icon: Icons.cancel_outlined,
                  colors: [DS.red, DS.redDeep],
                  shadowColor: DS.red,
                  height: 48,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────── SHARED WIDGETS ───────────────────────────────
  Widget _sectionCard({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DS.cardDark : DS.cardLight,
        borderRadius: BorderRadius.circular(DS.r20),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
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
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(
      String title, IconData icon, Color color, bool isDark) {
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

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required Color shadowColor,
    double height = 44,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(DS.r12),
        boxShadow: [
          BoxShadow(
              color: shadowColor.withOpacity(0.35), blurRadius: 10)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.black26, fontSize: 12),
      filled: true,
      fillColor: isDark ? DS.inputDark : const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r12),
          borderSide:
              BorderSide(color: isDark ? DS.borderDark : DS.borderLight)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r12),
          borderSide: const BorderSide(color: DS.brandStart, width: 1.8)),
    );
  }

  // ─────────────────────────────── STATES ───────────────────────────────
  Widget _loadingState() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
                color: DS.brandStart, strokeWidth: 2.5),
            SizedBox(height: 14),
            Text("Loading details…",
                style:
                    TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
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
                color: DS.brandStart.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.info_outline_rounded,
                  color: DS.brandStart, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              "No Data Found",
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}