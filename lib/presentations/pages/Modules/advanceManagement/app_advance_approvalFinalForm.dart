// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/app_text_styles.dart';
import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvanceApprovalForm2 extends StatefulWidget {
  final int transId;
  final int empPk;
  final String companyGroup;

  const AdvanceApprovalForm2({
    super.key,
    required this.transId,
    required this.empPk,
    required this.companyGroup,
  });

  @override
  State<AdvanceApprovalForm2> createState() => _AdvanceApprovalForm2State();
}

class _AdvanceApprovalForm2State extends State<AdvanceApprovalForm2> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  bool isDownloading = false;
  String? downloadedFilePath;
  int? emppk;

  final installmentController = TextEditingController();
  final approvalReasonController = TextEditingController();

  DateTime? startDate;
  List<Map<String, dynamic>> emiList = [];

  @override
  void initState() {
    super.initState();
    getPrefsData().then((_) => fetchAdvanceDetails());
  }

  Future<void> getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk = prefs.getInt('emppk');
  }

  ////--------------------------------- Fetch Advance Details ---------------------------------------
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

      setState(() {
        data = Map<String, dynamic>.from(response.data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  ///----------------------------------------- Approve / Reject Advance Application ---------------------------------------
  Future<void> approveReject(String status) async {
    if (approvalReasonController.text.trim().isEmpty) {
      CommonSnackBar.show(
        context: context,
        title: "Warning",
        message: "Enter reason first",
        type: SnackBarType.warning,
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final response = await ApiClient.post(
        ApiConstants.approveAdvanceApplication,
        data: {
          "TransID": widget.transId,
          "EmpPK": emppk,
          "Status": status, //HANDLE ON THE BUTTONS APROOVE OR REJECT
          "Reason": approvalReasonController.text.trim(),
          "Installments": installmentController.text.trim(),
          "StartDate": startDate != null
              ? DateFormat('dd/MM/yyyy').format(startDate!)
              : "",
        },
      );

      CommonSnackBar.show(
        context: context,
        title: "Success",
        message: response.data.toString(),
        type: SnackBarType.success,
      );

      Navigator.pop(context, true);
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Failed",
        type: SnackBarType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ---------------------------  Download nd Open attached File ------------------------------
  Future<void> downloadAndOpenFile(String base64String, String fileName) async {
    try {
      setState(() => isDownloading = true);

      String cleaned = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;

      Uint8List bytes = base64Decode(cleaned);

      final dir = await getApplicationDocumentsDirectory();
      final path = "${dir.path}/$fileName.pdf";

      final file = File(path);
      await file.writeAsBytes(bytes);

      downloadedFilePath = path;
      await OpenFile.open(path);

      setState(() => isDownloading = false);
    } catch (e) {
      setState(() => isDownloading = false);
    }
  }

  /////Generate EMI Chart
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
          DateTime(startDate!.year, startDate!.month + (i - 1), startDate!.day),
        ),
        "emi": emi.toStringAsFixed(0),
        "balance": balance <= 0 ? "0" : balance.toStringAsFixed(0),
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final base64 = data?["PathnameBase64"]; ////BASE-64 IMAGE PATH
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4F8),
      body: Column(
        children: [
          _header(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : data == null
                ? const Center(child: Text("No Data Found"))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Employee Details",
                                style: AppTextStyles.headingSmall,
                              ),
                              infoRow("Name", data!["EmployeeName"]),
                              infoRow("Code", data!["EmployeeCode"]),
                              infoRow("Amount", "₹${data!["AdvanceAmount"]}"),
                              infoRow("Reason", data!["Reason"]),
                              infoRow("Status", data!["ApprovalStatus"]),
                            ],
                          ),
                        ),
                        card(
                          child: CommonButton(
                            width: double.infinity,
                            height: 45,
                            color: const Color.fromARGB(255, 167, 9, 83),
                            label: isDownloading
                                ? "Downloading..."
                                : "Download Document",
                            onPressed: () {
                              if (base64 != null) {
                                downloadAndOpenFile(
                                  base64.toString(),
                                  "Advance_${widget.transId}",
                                );
                              }
                            },
                          ),
                        ),
                        card(
                          child: Column(
                            children: [
                              TextField(
                                controller: installmentController,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration("Installments"),
                              ),
                              const SizedBox(height: 12),

                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                  );

                                  if (picked != null) {
                                    setState(() {
                                      startDate = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF4F8),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    startDate == null
                                        ? "Select Start Date"
                                        : DateFormat(
                                            "dd-MM-yyyy",
                                          ).format(startDate!),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              CommonButton(
                                width: double.infinity,
                                height: 45,
                                color: const Color.fromARGB(255, 232, 70, 145),
                                label: "Generate EMI Chart",
                                onPressed: generateEmiChart,
                              ),
                            ],
                          ),
                        ),
                        card(
                          child: Column(
                            children: [
                              TextField(
                                controller: approvalReasonController,
                                maxLines: 3,
                                decoration: inputDecoration("Enter reason"),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      width: double.infinity,
                                      height: 45,
                                      color: Colors.green,
                                      label: "Approve",
                                      onPressed: () =>
                                          approveReject("Approved"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: CommonButton(
                                      width: double.infinity,
                                      height: 45,
                                      color: Colors.red,
                                      label: "Reject",
                                      onPressed: () =>
                                          approveReject("Rejected"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  //Header
  Widget _header() {
    return Container(
      height: 115,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 232, 70, 145),
            Color.fromARGB(255, 167, 9, 83),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            "Advance Approval",
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromARGB(40, 167, 9, 83)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFDF4F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  ///Info Row
  Widget infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    installmentController.dispose();
    approvalReasonController.dispose();
    super.dispose();
  }
}



// NEW UI 

