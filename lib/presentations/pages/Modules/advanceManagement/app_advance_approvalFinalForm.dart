// ignore_for_file: prefer_typing_uninitialized_variables, file_names, deprecated_member_use, use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/core/constants/ds_color_handler.dart';

class AdvanceEntryFormReporting2 extends StatefulWidget {
  final Map<String, dynamic> responseData;

  const AdvanceEntryFormReporting2({super.key, required this.responseData});

  @override
  State<AdvanceEntryFormReporting2> createState() =>
      _AdvanceEntryFormReporting2State();
}

class _AdvanceEntryFormReporting2State extends State<AdvanceEntryFormReporting2>
    with SingleTickerProviderStateMixin {
  //  Controllers (same as File 1) 
  final TextEditingController installmentsCtrl = TextEditingController();
  final TextEditingController fromMonthCtrl = TextEditingController();
  final TextEditingController toMonthCtrl = TextEditingController();
  final TextEditingController advanceAmountCtrl = TextEditingController();
  final TextEditingController noOfInstallmentsCtrl = TextEditingController();
  final TextEditingController approvalReasonController =
      TextEditingController();

  //  State (same as File 1) 
  bool isLoading = false;
  List<Map<String, String>> emiList = [];
  bool _isDownloading = false;
  final double _downloadProgress = 0.0;
  String? _downloadedFilePath;
  Dio dio = Dio();
  late final String advanceAmount;
  int emppk = 123;
  var abcd;
  String? formattedStartMonth;

  bool isFirstApprover = false;
  bool isSecondApprover = false;
  bool isFinalHRApprover = false;

  String? secondApproverInstallments;
  String? secondApproverFromMonth;
  String? secondApproverToMonth;
  String? secondApproverAdvanceAmount;

  //  Fade animation (same pattern as File 2) 
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  //  INIT 
  @override
  void initState() {
    super.initState();

    //  Exact logic from File 1 
    isFirstApprover = widget.responseData["IsFirstApprover"] ?? false;
    isSecondApprover = widget.responseData["IsSecondApprover"] ?? false;
    isFinalHRApprover = widget.responseData["IsFinalHRApprover"] ?? false;

    secondApproverInstallments = widget.responseData["NoOfInstallments"]
        ?.toString();
    secondApproverFromMonth = widget.responseData["EffectiveDate"]?.toString();
    secondApproverToMonth = widget.responseData["EndDate"]?.toString();
    secondApproverAdvanceAmount = widget.responseData["AdvanceAmount"]
        ?.toString();

    loadCounter().then((_) {
      _prefillFormFields();
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    installmentsCtrl.dispose();
    fromMonthCtrl.dispose();
    toMonthCtrl.dispose();
    advanceAmountCtrl.dispose();
    noOfInstallmentsCtrl.dispose();
    approvalReasonController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  //  LOGIC (unchanged from File 1) 

  void _prefillFormFields() {
    if (isFinalHRApprover) {
      if (secondApproverInstallments != null &&
          secondApproverInstallments!.isNotEmpty) {
        noOfInstallmentsCtrl.text = secondApproverInstallments!;
      }
      if (secondApproverFromMonth != null &&
          secondApproverFromMonth!.isNotEmpty) {
        fromMonthCtrl.text = secondApproverFromMonth!;
      }
      if (secondApproverToMonth != null && secondApproverToMonth!.isNotEmpty) {
        toMonthCtrl.text = secondApproverToMonth!;
      }
      if (secondApproverAdvanceAmount != null &&
          secondApproverAdvanceAmount!.isNotEmpty) {
        advanceAmountCtrl.text = secondApproverAdvanceAmount!;
      }
      if (noOfInstallmentsCtrl.text.isNotEmpty &&
          fromMonthCtrl.text.isNotEmpty) {
        _generateEmiTable();
      }
    } else if (isSecondApprover) {
      String? installments = widget.responseData["NoOfInstallments"]
          ?.toString();
      String? fromMonth =
          widget.responseData["EffectiveMonthYear"]?.toString() ??
          widget.responseData["EffectiveDate"]?.toString();
      String? toMonth =
          widget.responseData["EndMonthYear"]?.toString() ??
          widget.responseData["EndDate"]?.toString();
      String? advAmt = widget.responseData["AdvanceAmount"]?.toString();

      if (installments != null && installments.isNotEmpty) {
        noOfInstallmentsCtrl.text = installments;
      }
      if (fromMonth != null && fromMonth.isNotEmpty) {
        fromMonthCtrl.text = fromMonth;
      }
      if (toMonth != null && toMonth.isNotEmpty) {
        toMonthCtrl.text = toMonth;
      }
      if (advAmt != null && advAmt.isNotEmpty) {
        advanceAmountCtrl.text = advAmt;
      }
      if (noOfInstallmentsCtrl.text.isNotEmpty &&
          fromMonthCtrl.text.isNotEmpty) {
        _generateEmiTable();
      }
    }
  }

  Future<void> loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emppk = (prefs.getInt('emppk') ?? '') as int;
      abcd = emppk.toString();
    });
  }

  String get documentName {
    final String? pathname = widget.responseData["Pathname"];
    if (pathname != null && pathname.isNotEmpty) {
      return pathname.split(Platform.isWindows ? '\\' : '/').last;
    }
    return "No document attached";
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    DateTime now = DateTime.now();
    int selectedMonth = now.month;
    int selectedYear = now.year;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Select Month & Year"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<int>(
                    value: selectedMonth,
                    items: List.generate(12, (i) => i + 1)
                        .where(
                          (month) =>
                              selectedYear > now.year ||
                              (selectedYear == now.year && month >= now.month),
                        )
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(
                              DateFormat.MMMM().format(DateTime(0, month)),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() => selectedMonth = value);
                      }
                    },
                  ),
                  DropdownButton<int>(
                    value: selectedYear,
                    items: List.generate(20, (i) => DateTime.now().year + i)
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text("$year"),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          selectedYear = value;
                          if (selectedYear == now.year &&
                              selectedMonth < now.month) {
                            selectedMonth = now.month;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    formattedStartMonth =
                        "${selectedMonth.toString().padLeft(2, '0')}/$selectedYear";
                    fromMonthCtrl.text = formattedStartMonth!;
                    Navigator.pop(context);
                    Future.microtask(() => _generateEmiTable());
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generateEmiTable() {
    setState(() {
      emiList.clear();
      if (noOfInstallmentsCtrl.text.isEmpty || fromMonthCtrl.text.isEmpty) {
        return;
      }

      int installments = int.tryParse(noOfInstallmentsCtrl.text) ?? 0;
      DateFormat format = DateFormat("MM/yyyy");
      DateTime fromDate = format.parse(fromMonthCtrl.text);

      int amount =
          int.tryParse(
            advanceAmountCtrl.text.isNotEmpty
                ? advanceAmountCtrl.text.split(".").first
                : widget.responseData["AdvanceAmount"]
                          ?.toString()
                          .split(".")
                          .first ??
                      "0",
          ) ??
          0;

      int amountPerInstallment = amount ~/ installments;

      for (int i = 0; i < installments; i++) {
        DateTime emiMonth = DateTime(fromDate.year, fromDate.month + i, 1);
        emiList.add({
          "month": DateFormat("MMM-yyyy").format(emiMonth),
          "amount": "$amountPerInstallment",
          "paid": "No",
        });
      }

      DateTime lastMonth = DateTime(
        fromDate.year,
        fromDate.month + installments - 1,
        1,
      );
      toMonthCtrl.text = DateFormat("MM/yyyy").format(lastMonth);
    });
  }

  String _getFileName(String path) =>
      path.split(Platform.isWindows ? '\\' : '/').last;

  Future<void> _openDownloadedFile() async {
    if (_downloadedFilePath == null) return;
    try {
      final result = await OpenFile.open(_downloadedFilePath!);
      if (result.type != ResultType.done) {
        CommonSnackBar.show(
          context: context,
          title: "Error",
          message: "Could not open file: ${result.message}",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Error opening file: $e",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _downloadAndOpenFileFromBase64(
    String base64FileString,
    String fileName,
  ) async {
    try {
      setState(() => _isDownloading = true);

      if (base64FileString.contains(',')) {
        base64FileString = base64FileString.split(',').last;
      }
      Uint8List fileBytes = base64Decode(base64FileString);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String savePath = '${appDocDir.path}/$fileName';
      File file = File(savePath);
      await file.writeAsBytes(fileBytes, flush: true);

      setState(() {
        _isDownloading = false;
        _downloadedFilePath = savePath;
      });
      await OpenFile.open(savePath);
    } catch (e) {
      setState(() => _isDownloading = false);
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Error: $e",
        type: SnackBarType.error,
      );
    }
  }

  //  Approve / Reject 

  void onApprovePressed() {
    final advAmt = advanceAmountCtrl.text.trim();
    final installments = noOfInstallmentsCtrl.text.trim();
    final fromMonth = fromMonthCtrl.text.trim();
    final toMonth = toMonthCtrl.text.trim();
    final approvalReason = approvalReasonController.text.trim();

    if (advAmt.isEmpty || advAmt == "0") {
      _showError("Please enter a valid Advance Amount");
      return;
    }
    int? inst = int.tryParse(installments);
    if (inst == null) {
      _showError("Please enter valid number of installments");
      return;
    }
    if (inst <= 0) {
      _showError("Installments must be greater than 0");
      return;
    }
    if (fromMonth.isEmpty) {
      _showError("Please select Deduction From Month");
      return;
    }
    if (toMonth.isEmpty) {
      _showError(
        "Deduction To Month is missing. Please check installment calculation.",
      );
      return;
    }
    if (approvalReason.isEmpty) {
      _showError("Please enter Approval/Reject Reason");
      return;
    }

    dynamic advanceAmountValue;
    if (advanceAmountCtrl.text.isNotEmpty) {
      double? amount = double.tryParse(advanceAmountCtrl.text);
      advanceAmountValue = amount?.toInt();
    } else {
      String amountStr =
          widget.responseData["AdvanceAmount"]?.toString() ?? "0";
      double? amount = double.tryParse(amountStr);
      advanceAmountValue = amount?.toInt();
    }

    Map<String, dynamic> data = {
      "EmpPK": widget.responseData['EmpPK'],
      "CompanyPK": 1,
      "Status": "Approved",
      "TransID": widget.responseData["TransID"],
      "ApprovalReason": approvalReasonController.text,
      "NoOfInstallments": noOfInstallmentsCtrl.text.isNotEmpty
          ? int.tryParse(noOfInstallmentsCtrl.text)
          : widget.responseData["NoOfInstallments"],
      "EffectiveMonthYear": fromMonthCtrl.text,
      "EndMonthYear": toMonthCtrl.text,
      "EffectiveDate": fromMonthCtrl.text,
      "EndDate": toMonthCtrl.text,
      "ApplicationDate": DateFormat("dd/MM/yyyy").format(
        DateFormat(
          "MMM dd, yyyy",
        ).parse(widget.responseData["ApplicationDate"]),
      ),
      "AdvanceAmount": advanceAmountValue,
      "IsFirstApprover": isFirstApprover,
      "IsSecondApprover": isSecondApprover,
      "IsFinalHRApprover": isFinalHRApprover,
      "ReportingPK": widget.responseData["Reportingpk"],
      "Reason": widget.responseData["Reason"],
      "CompanyGroup": widget.responseData["CompanyGroup"],
    };

    approveAdvance(data);
  }

  void onRejectPressed() {
    final approvalReason = approvalReasonController.text.trim();
    if (approvalReason.isEmpty) {
      _showError("Please enter Approval/Reject Reason");
      return;
    }

    dynamic advanceAmountValue;
    if (advanceAmountCtrl.text.isNotEmpty) {
      double? amount = double.tryParse(advanceAmountCtrl.text);
      advanceAmountValue = amount?.toInt();
    } else {
      String amountStr =
          widget.responseData["AdvanceAmount"]?.toString() ?? "0";
      double? amount = double.tryParse(amountStr);
      advanceAmountValue = amount?.toInt();
    }

    Map<String, dynamic> data = {
      "EmpPK": widget.responseData['EmpPK'],
      "CompanyPK": 1,
      "Status": "Rejected",
      "TransID": widget.responseData["TransID"],
      "ApprovalReason": approvalReasonController.text,
      "NoOfInstallments": noOfInstallmentsCtrl.text.isNotEmpty
          ? int.tryParse(noOfInstallmentsCtrl.text)
          : widget.responseData["NoOfInstallments"],
      "EffectiveMonthYear": fromMonthCtrl.text,
      "EndMonthYear": toMonthCtrl.text,
      "EffectiveDate": fromMonthCtrl.text,
      "EndDate": toMonthCtrl.text,
      "ApplicationDate": DateFormat("dd/MM/yyyy").format(
        DateFormat(
          "MMM dd, yyyy",
        ).parse(widget.responseData["ApplicationDate"]),
      ),
      "AdvanceAmount": advanceAmountValue,
      "IsFirstApprover": isFirstApprover,
      "IsSecondApprover": isSecondApprover,
      "IsFinalHRApprover": isFinalHRApprover,
      "ReportingPK": widget.responseData["Reportingpk"],
      "Reason": widget.responseData["Reason"],
      "CompanyGroup": widget.responseData["CompanyGroup"],
    };

    approveAdvance(data);
  }

  Future<void> approveAdvance(Map<String, dynamic> advanceAppData) async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final response = await ApiClient.post(
        ApiConstants.approveAdvanceApplication,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: response.data.toString(),
          type: SnackBarType.success,
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        CommonSnackBar.show(
          context: context,
          title: "Error",
          message: "Error: ${response.statusMessage}",
          type: SnackBarType.error,
        );
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Error: $e",
        type: SnackBarType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    CommonSnackBar.show(
      context: context,
      title: "Warning",
      message: message,
      type: SnackBarType.warning,
    );
  }

  //  BUILD 

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
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _approverBadge(isDark),
                          const SizedBox(height: 14),
                          _employeeInfoCard(isDark),
                          const SizedBox(height: 14),
                          _advanceDetailsCard(isDark),
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

  //  HEADER 

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
                        "Advance Approval Form",
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

  //  Approver Badge 

  Widget _approverBadge(bool isDark) {
    String approverType = isFirstApprover
        ? "First Approver"
        : isSecondApprover
        ? "Second Approver"
        : isFinalHRApprover
        ? "Final HR Approver"
        : "Approver";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DS.brandStart.withOpacity(0.10),
        borderRadius: BorderRadius.circular(DS.r12),
        border: Border.all(color: DS.brandStart.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DS.brandStart.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: DS.brandStart,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "Viewing as: $approverType",
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  //  Employee Info Card 

  Widget _employeeInfoCard(bool isDark) {
    final d = widget.responseData;
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
        _infoRow("Application Date", d["ApplicationDate"] ?? "-", isDark),
        _infoRow("Employee Code", d["EmployeeCode"] ?? "-", isDark),
        _infoRow("Name", d["EmployeeName"] ?? "-", isDark),
        _infoRow("Company", d["CompanyName"] ?? "-", isDark),
        _infoRow("Location", d["LocationName"] ?? "-", isDark),
        _infoRow("Department", d["DepartmentName"] ?? "-", isDark),
        _infoRow("Gross Salary", d["GrossSalary"]?.toString() ?? "-", isDark),
      ],
    );
  }

  //  Advance Details Card (editable fields per approver role) 

  Widget _advanceDetailsCard(bool isDark) {
    final d = widget.responseData;
    final advAmt = d["AdvanceAmount"]?.toString() ?? "0";

    // Editable only for second approver or final HR approver
    final bool canEdit = isSecondApprover || isFinalHRApprover;

    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader(
          "Advance Details",
          Icons.account_balance_wallet_rounded,
          DS.brandStart,
          isDark,
        ),
        const SizedBox(height: 14),

        // Advance Amount
        _fieldRow(
          label: "Advance Amount",
          isDark: isDark,
          child: _styledTextField(
            controller: advanceAmountCtrl
              ..text = advanceAmountCtrl.text.isEmpty
                  ? advAmt
                  : advanceAmountCtrl.text,
            hint: advAmt,
            isDark: isDark,
            readOnly: !canEdit,
            onChanged: (_) => _generateEmiTable(),
          ),
        ),
        const SizedBox(height: 10),

        // No. of Installments
        _fieldRow(
          label: "No. of Installments",
          isDark: isDark,
          child: _styledTextField(
            controller: noOfInstallmentsCtrl,
            hint: "e.g. 6",
            isDark: isDark,
            readOnly: !canEdit,
            keyboardType: TextInputType.number,
            onChanged: (_) => _generateEmiTable(),
          ),
        ),
        const SizedBox(height: 10),

        // Deduction From Month
        _fieldRow(
          label: "Deduction From",
          isDark: isDark,
          child: GestureDetector(
            onTap: canEdit ? () => _selectMonthYear(context) : null,
            child: AbsorbPointer(
              absorbing: !canEdit,
              child: _styledTextField(
                controller: fromMonthCtrl,
                hint: "MM/yyyy",
                isDark: isDark,
                readOnly: true,
                suffixIcon: canEdit
                    ? Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: isDark
                            ? Colors.white38
                            : const Color(0xFF64748B),
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Deduction To Month (always read-only — calculated)
        _fieldRow(
          label: "Deduction To",
          isDark: isDark,
          child: _styledTextField(
            controller: toMonthCtrl,
            hint: "Auto calculated",
            isDark: isDark,
            readOnly: true,
          ),
        ),
        const SizedBox(height: 10),

        _infoRow("Reason", d["Reason"] ?? "-", isDark),
        _infoRow(
          "Approval Status",
          d["ApprovalStatus"] ?? "-",
          isDark,
          valueColor: _approvalColor(d["ApprovalStatus"]?.toString() ?? ""),
        ),
      ],
    );
  }

  //  Document Card 

  Widget _documentCard(bool isDark) {
    final String? base64File = widget.responseData["PathnameBase64"];
    final String? pathname = widget.responseData["Pathname"];
    final bool hasDocument = base64File != null && base64File.isNotEmpty;
    final String fileName = pathname != null && pathname.isNotEmpty
        ? _getFileName(pathname)
        : "AdvanceDocument.pdf";

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
        if (!hasDocument)
          _emptyPlaceholder(
            "No document attached",
            Icons.folder_off_outlined,
            isDark,
          )
        else ...[
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
                  onTap: () =>
                      _downloadAndOpenFileFromBase64(base64File, fileName),
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
          const SizedBox(height: 8),
          Text(
            fileName,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ],
    );
  }

  //  EMI Card 

  Widget _emiCard(bool isDark) {
    if (emiList.isEmpty) return const SizedBox.shrink();
    return _sectionCard(
      isDark: isDark,
      children: [
        _sectionHeader(
          "EMI Schedule",
          Icons.calendar_month_rounded,
          const Color(0xFFF59E0B),
          isDark,
        ),
        const SizedBox(height: 14),
        // Header row
        Row(
          children: [
            _emiHeaderCell("Month", isDark, flex: 3),
            _emiHeaderCell("Amount (₹)", isDark, flex: 2),
            _emiHeaderCell("Paid", isDark, flex: 1),
          ],
        ),
        const SizedBox(height: 6),
        ...emiList.map((e) => _emiRow(e, isDark)),
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

  Widget _emiRow(Map<String, String> e, bool isDark) {
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
            flex: 3,
            child: Text(e["month"]!, style: _emiCellStyle(isDark)),
          ),
          Expanded(
            flex: 2,
            child: Text(e["amount"]!, style: _emiCellStyle(isDark, bold: true)),
          ),
          Expanded(
            flex: 1,
            child: Text(
              e["paid"]!,
              style: _emiCellStyle(isDark, color: DS.brandStart),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _emiCellStyle(bool isDark, {bool bold = false, Color? color}) {
    return TextStyle(
      color: color ?? (isDark ? Colors.white70 : const Color(0xFF0F172A)),
      fontSize: 12,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
  }

  //  Action Card 

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
          decoration: _inputDecoration(
            "Enter reason for approval or rejection…",
            isDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onApprovePressed,
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
                onTap: onRejectPressed,
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

  //  SHARED UI HELPERS 

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
            width: 120,
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

  /// A label + arbitrary child (used for text-field rows)
  Widget _fieldRow({
    required String label,
    required Widget child,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
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
        Expanded(child: child),
      ],
    );
  }

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required bool readOnly,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.black26,
          fontSize: 12,
        ),
        filled: true,
        fillColor: readOnly
            ? (isDark
                  ? Colors.white.withOpacity(0.03)
                  : const Color(0xFFE8EDF2))
            : (isDark ? DS.inputDark : const Color(0xFFF1F5F9)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r12),
          borderSide: BorderSide(
            color: isDark ? DS.borderDark : DS.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r12),
          borderSide: const BorderSide(color: DS.brandStart, width: 1.8),
        ),
      ),
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
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(DS.r12),
        boxShadow: [
          BoxShadow(color: shadowColor.withOpacity(0.35), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black26,
        fontSize: 12,
      ),
      filled: true,
      fillColor: isDark ? DS.inputDark : const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DS.r12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DS.r12),
        borderSide: BorderSide(color: isDark ? DS.borderDark : DS.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DS.r12),
        borderSide: const BorderSide(color: DS.brandStart, width: 1.8),
      ),
    );
  }

  Widget _emptyPlaceholder(String message, IconData icon, bool isDark) {
    return Container(
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
          Icon(icon, color: isDark ? Colors.white38 : Colors.black26, size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
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

  Widget _loadingState() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: DS.brandStart, strokeWidth: 2.5),
        SizedBox(height: 14),
        Text(
          "Loading…",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    ),
  );
}
