// // ignore_for_file: use_build_context_synchronously, deprecated_member_use
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/app_services/whtsapp_launcher.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
// import 'package:new_design_demo/presentations/pages/Modules/advanceManagement/app_advance_approval_form1.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:file_picker/file_picker.dart';
// class AdvanceScreen extends StatefulWidget {
//   const AdvanceScreen({super.key});
//   @override
//   State<AdvanceScreen> createState() => AdvanceScreenState();
// }
// class AdvanceScreenState extends State<AdvanceScreen> {
//   int? emppk;
//   String? empcode;
//   int? companypk;
//   int? locationpk;
//   String? empname;
//   int? isSuperAdmin;
//   bool showApplyAdvanceForm = false;
//   bool isLoading = false;
//   List<Map<String, dynamic>> advanceStatusList = [];
//   // Form controllers
//   final TextEditingController advamountController = TextEditingController();
//   final TextEditingController reasonController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   File? selectedDocument;
//   String? documentName;
//   /////Reason fetching for dropdown
//   List<Map<String, dynamic>> reasonList = [];
//   Map<String, dynamic>? selectedReason;
//   // Authorization
//   bool isAuthorizationScreen = false;
//   bool isAuthLoading = false;
//   List<dynamic> advanceAuthorizationlistData = [];
//   String selectedApprovalStatus = 'Pending';
//   int selectedApprovalTab = 0; // 0: Pending, 1: Approved, 2: Rejected
//   List<Map<String, dynamic>> users = [];
//   Map<String, String> companyMap = {};
//   String? selectedComp;
//   List<dynamic> searchEmp = [];
//   TextEditingController empNameController = TextEditingController();
//   String selEmpCode = '';
//   @override
//   void initState() {
//     super.initState();
//     loadReasons();
//     initializeData();
//     getCompanyList();
//   }
//   Future<void> initializeData() async {
//     await getPrefsData();
//     if (emppk == null) {
//       debugPrint('EMPPK is NULL after prefs load');
//       return;
//     }
//     await loadAdvanceStatus();
//   }
//   // Load SharedPrefs Data
//   Future<void> getPrefsData() async {
//     final prefs = await SharedPreferences.getInstance();
//     emppk = prefs.getInt('emppk');
//     empcode = prefs.getString('employeecode');
//     companypk = prefs.getInt('companypk');
//     locationpk = prefs.getInt('locationpk');
//     empname = prefs.getString('employeename');
//     isSuperAdmin = int.tryParse(prefs.getString('issuperadmin') ?? '0') ?? 0;
//     debugPrint('Loaded EmpPk - $emppk');
//   }
//   // LoaderForStatusList
//   Future<void> loadAdvanceStatus() async {
//     setState(() => isLoading = true);
//     final data = await getAdvanceStatusList();
//     setState(() {
//       advanceStatusList = data;
//       isLoading = false;
//     });
//   }
//   /////-------------------------  Fetch Advance Reason List ----------------------------GET
//   Future<void> loadReasons() async {
//     try {
//       final response = await ApiClient.get(ApiConstants.getAdvanceReason);
//       final data = response.data;
//       List<Map<String, dynamic>> tempList = [];
//       if (data is List) {
//         tempList = List<Map<String, dynamic>>.from(data);
//       } else if (data is Map && data['GetAdvanceReasonsList'] != null) {
//         tempList = List<Map<String, dynamic>>.from(
//           data['GetAdvanceReasonsList'],
//         );
//       }
//       setState(() {
//         reasonList = tempList;
//       });
//       debugPrint("Reason List Loaded: $reasonList");
//     } catch (e) {
//       debugPrint("Load Reason Error: $e");
//     }
//   }
//   ////ConvertImageToBase64
//   Future<String> convertFileToBase64(File file) async {
//     try {
//       List<int> bytes = await file.readAsBytes();
//       return base64Encode(bytes).replaceAll("\n", "").replaceAll("\r", "");
//     } catch (e) {
//       debugPrint("Base64 Error: $e");
//       return '';
//     }
//   }
//   // Fetch Advance Status List
//   Future<List<Map<String, dynamic>>> getAdvanceStatusList() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getAdvanceStatus,
//         query: {'Emp_PK': emppk},
//       );
//       final data = response.data;
//       debugPrint('API RESPONSE $data');
//       if (data is List) {
//         return List<Map<String, dynamic>>.from(data).map((item) {
//           return {...item, 'Status': _getReadableStatus(item['Apps_Status'])};
//         }).toList();
//       } else if (data is Map && data['GetAdvanceStatusList'] != null) {
//         return List<Map<String, dynamic>>.from(data['GetAdvanceStatusList']);
//       }
//       return [];
//     } catch (e) {
//       debugPrint('Advance Status Error $e');
//       return [];
//     }
//   }
//   ////helper method to convert raw status to readable status
//   String _getReadableStatus(String? rawStatus) {
//     if (rawStatus == null || rawStatus.isEmpty) return 'Pending';
//     String lower = rawStatus.toLowerCase();
//     if (lower.contains('approved by')) {
//       return 'Approved by ${rawStatus.split(' by ').last}';
//     }
//     if (lower.contains('approved')) {
//       return 'Approved';
//     }
//     if (lower.contains('rejected')) {
//       return 'Rejected';
//     }
//     return 'Pending';
//   }
//   // Submit Advance Application
//   Future<void> submitAdvanceApplication() async {
//     if (advamountController.text.trim().isEmpty ||
//         selectedReason == null ||
//         descriptionController.text.trim().isEmpty ||
//         selectedDocument == null) {
//       CommonSnackBar.show(
//         context: context,
//         title: 'Warning',
//         message: 'Please fill all fields',
//         type: SnackBarType.warning,
//       );
//       return;
//     }
//     try {
//       setState(() => isLoading = true);
//       String base64Image = await convertFileToBase64(selectedDocument!);
//       String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
//       final response = await ApiClient.post(
//         ApiConstants.submitAdvanceApplication,
//         data: {
//           "EmpPK": emppk,
//           "AdvDate": formattedDate,
//           "AdvAmount": advamountController.text.trim(),
//           "AdvanceRemark": "Emergency case",
//           "Reason": selectedReason!['AdvanceReason_Description'],
//           "Description": descriptionController.text.trim(),
//           "Image": base64Image,
//         },
//       );
//       final message = response.data.toString();
//       if (message.toLowerCase().contains('success')) {
//         final String msg =
//             " Hello, The advance application for amount ${advamountController.text.trim()} with reason '${selectedReason!['AdvanceReason_Description']}' has been approved by $empname. Please review the application at your earliest convenience. Thank you.";
//         WhatsAppService.sendMessage(phoneNumber: "9730028611", message: msg);
//         CommonSnackBar.show(
//           context: context,
//           title: 'Success',
//           message: message,
//           type: SnackBarType.success,
//         );
//         resetAdvanceForm();
//         loadAdvanceStatus();
//       } else {
//         CommonSnackBar.show(
//           context: context,
//           title: 'Failed',
//           message: message,
//           type: SnackBarType.warning,
//         );
//       }
//     } catch (e) {
//       debugPrint("API ERROR: $e");
//       CommonSnackBar.show(
//         context: context,
//         title: 'Error',
//         message: 'Failed to apply advance.',
//         type: SnackBarType.error,
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//   /////Reset Advance Form
//   void resetAdvanceForm() {
//     advamountController.clear();
//     reasonController.clear();
//     descriptionController.clear();
//     selectedDocument = null;
//     documentName = null;
//     setState(() => showApplyAdvanceForm = false);
//   }
//   // Pick Document
//   Future<void> pickDocument() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//     );
//     if (result != null) {
//       File file = File(result.files.single.path!);
//       int size = await file.length();
//       if (size > 4 * 1024 * 1024) {
//         CommonSnackBar.show(
//           context: context,
//           title: "Error",
//           message: "File must be less than 4MB",
//           type: SnackBarType.error,
//         );
//         return;
//       }
//       setState(() {
//         selectedDocument = file;
//         documentName = result.files.single.name;
//       });
//     }
//   }
//   // Authorization Application List
//   Future<void> getAdvanceAuthorizationList(int index) async {
//     selectedApprovalTab = index;
//     const statuses = ['Pending', 'Approved', 'Rejected'];
//     String status = statuses[index];
//     setState(() => isAuthLoading = true);
//     users.clear();
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getAdvanceApprovalList,
//         query: {
//           'Emp_PK': emppk,
//           'ViewEmpCode': selEmpCode,
//           'ViewAppStatus': status,
//           'CompanyGroupDBName': selectedComp,
//         },
//       );
//       final data = response.data;
//       if (data is List) {
//         users = List<Map<String, dynamic>>.from(data).map((item) {
//           String rawStatus = item['Apps_Status']?.toString() ?? '';
//           return {...item, 'Status': _getReadableStatus(rawStatus)};
//         }).toList();
//       } else if (data is Map && data['GetAdvanceAuthorizationList'] != null) {
//         users =
//             List<Map<String, dynamic>>.from(
//               data['GetAdvanceAuthorizationList'],
//             ).map((item) {
//               return {...item, 'Status': item['Apps_Status']?.toString() ?? ''};
//             }).toList();
//       }
//     } catch (e) {
//       debugPrint('Authorization Error $e');
//     }
//     setState(() => isAuthLoading = false);
//   }
//   // Employee Name And Employee Code Search
//   Future<void> getEmployeeNameSearch(int? emppk) async {
//     setState(() {
//       isLoading = true;
//       searchEmp.clear();
//     });
//     try {
//       String company = selectedComp ?? "";
//       final response = await ApiClient.get(
//         "${ApiConstants.searchEmployeeNameCode}"
//         "?Emp_PK=${emppk ?? 0}"
//         "&Searchtxt=${empNameController.text}"
//         "&CompanyGroupDBName=$company",
//       );
//       dynamic data = response.data;
//       if (data is String) {
//         data = jsonDecode(data);
//       }
//       final List list =
//           data["AutoCompleteData_AttendanceApplicationResult"] ?? [];
//       searchEmp = list.map<Map<String, dynamic>>((item) {
//         final parts = item.split(":");
//         return {
//           "Employee_Code": parts[0],
//           "EmpName": parts.length > 1 ? parts[1] : "",
//         };
//       }).toList();
//       setState(() {});
//     } catch (e) {
//       debugPrint("Employee Search Error: $e");
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }
//   Future<void> getCompanyList() async {
//     try {
//       final response = await ApiClient.get(ApiConstants.getCompanyGroupList);
//       final data = response.data;
//       if (data is List) {
//         companyMap.clear();
//         for (var item in data) {
//           String key = item['Company_Name'].toString();
//           String value = item['CompanyGroupDBName'].toString();
//           companyMap[key] = value;
//         }
//         selectedComp = companyMap.values.first;
//       }
//     } catch (e) {
//       debugPrint('Company List Error $e');
//     }
//   }
//   /////Approve or Reject Advance Application
//   void onTapApplication(Map<String, dynamic> data) {
//     String status = (data["Apps_Status"] ?? "").toString().toLowerCase();
//     if (status.contains("approved by") || status.contains("pending")) {
//       openApprovalForm(data);
//     } else if (status.contains("approved")) {
//       CommonSnackBar.show(
//         context: context,
//         title: "Approved",
//         message: "Advance application already fully approved.",
//         type: SnackBarType.warning,
//       );
//     } else if (status.contains("rejected")) {
//       CommonSnackBar.show(
//         context: context,
//         title: "Rejected",
//         message: "Advance application already rejected.",
//         type: SnackBarType.warning,
//       );
//     } else {
//       openApprovalForm(data);
//     }
//   }
//   void openApprovalForm(Map<String, dynamic> data) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ApprovalFormScreen(
//           transId: int.tryParse(data["TransID"]?.toString() ?? "0") ?? 0,
//           empPk: int.tryParse(data["EmpPK"]?.toString() ?? "0") ?? 0,
//           companyGroup: selectedComp ?? "",
//         ),
//       ),
//     );
//     // debugPrint("FULL ITEM DATA: $data");
//   }
//   ////Reset Authorization Filter
//   void resetAuthorizationFilters() {
//     empNameController.clear();
//     selEmpCode = '';
//     searchEmp.clear();
//     if (companyMap.isNotEmpty) selectedComp = companyMap.values.first;
//     selectedApprovalTab = 0;
//   }
//   @override
//   Widget build(BuildContext context) {
//     //         — same as AppVisitorManagement
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return WillPopScope(
//       onWillPop: () async {
//         if (showApplyAdvanceForm) {
//           setState(() => showApplyAdvanceForm = false);
//           return false;
//         }
//         if (isAuthorizationScreen) {
//           setState(() {
//             resetAuthorizationFilters();
//             isAuthorizationScreen = false;
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         //
//         backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
//         body: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _header(isDark: isDark),
//                 if (isAuthorizationScreen) const SizedBox(height: 13),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
//                   child: Text(
//                     'Advance History',
//                     //
//                     style: AppTextStyles.headingSmall.copyWith(
//                       color: isDark ? Colors.white : null,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: isAuthorizationScreen
//                       ? _advanceAuthorizationData(isDark: isDark)
//                       : Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: isLoading
//                               ? const Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.blueGrey,
//                                   ),
//                                 )
//                               : advanceStatusList.isEmpty
//                               ? Center(
//                                   child: Text(
//                                     'No Advance History Found.',
//                                     //
//                                     style: TextStyle(
//                                       color: isDark
//                                           ? Colors.white54
//                                           : Colors.black54,
//                                     ),
//                                   ),
//                                 )
//                               : ListView.builder(
//                                   padding: const EdgeInsets.only(top: 10),
//                                   itemCount: advanceStatusList.length,
//                                   itemBuilder: (context, index) {
//                                     final advance = advanceStatusList[index];
//                                     return _advanceCard(
//                                       advance,
//                                       isDark: isDark,
//                                     );
//                                   },
//                                 ),
//                         ),
//                 ),
//               ],
//             ),
//             if (showApplyAdvanceForm)
//               Positioned(
//                 top: 200,
//                 left: 16,
//                 right: 16,
//                 child: _applyAdvanceForm(isDark: isDark),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _header({bool isDark = false}) {
//     return Container(
//       height: 270,
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
//       decoration: const BoxDecoration(
//         // Header gradient fixed — same as original
//         gradient: LinearGradient(
//           colors: [
//             Color.fromARGB(255, 232, 70, 145),
//             Color.fromARGB(255, 167, 9, 83),
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
//                   getAdvanceAuthorizationList(0);
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
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Advance',
//                     style: AppTextStyles.headingLarge.copyWith(
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     'Management',
//                     style: AppTextStyles.headingLarge.copyWith(
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Manage Your Advance & Requests.',
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   CommonButton(
//                     width: 170,
//                     height: 40,
//                     color: Colors.white,
//                     label: 'Apply Advance',
//                     icon: const Icon(Icons.add, color: Colors.lightGreen),
//                     textColor: Colors.lightGreen,
//                     onPressed: () => setState(
//                       () => showApplyAdvanceForm = !showApplyAdvanceForm,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   if (!isAuthorizationScreen)
//                     SizedBox(
//                       width: 175,
//                       height: 42,
//                       child: CommonButton(
//                         label: 'Authorization',
//                         color: Colors.white,
//                         icon: const Icon(
//                           Icons.verified_user,
//                           color: Colors.lightBlue,
//                           size: 19,
//                         ),
//                         textColor: Colors.lightGreen,
//                         onPressed: () {
//                           setState(() {
//                             isAuthorizationScreen = true;
//                             getAdvanceAuthorizationList(0);
//                           });
//                         },
//                         width: 100,
//                         height: 40,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _advanceAuthorizationData({bool isDark = false}) {
//     if (isAuthLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.blueGrey),
//       );
//     }
//    List filteredList = users;
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _companyDropdown(isDark: isDark),
//           const SizedBox(height: 8),
//           employeeSearchField(isDark: isDark),
//           employeeSearchList(isDark: isDark),
//           const SizedBox(height: 10),
//           _authorizationTabs(isDark: isDark),
//           Expanded(
//             child: filteredList.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.money_off_sharp,
//                           size: 30,
//                           //
//                           color: isDark ? Colors.white38 : Colors.grey,
//                         ),
//                         const SizedBox(height: 12),
//                         Text(
//                           'No Data Found',
//                           style: AppTextStyles.labelMedium.copyWith(
//                             //
//                             color: isDark ? Colors.white38 : Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: filteredList.length,
//                     itemBuilder: (context, index) {
//                       final item = filteredList[index];
//                       return InkWell(
//                         onTap: () => onTapApplication(item),
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 16),
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             //
//                             color: isDark
//                                 ? const Color(0xFF1E293B)
//                                 : Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: isDark
//                                     ? Colors.black.withOpacity(0.4)
//                                     : Colors.black12,
//                                 blurRadius: 6,
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       item['Name'] ?? '',
//                                       style: AppTextStyles.headingSmall
//                                           .copyWith(
//                                             //
//                                             color: isDark ? Colors.white : null,
//                                           ),
//                                     ),
//                                   ),
//                                   _statusBadge(item['Apps_Status'] ?? ''),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Date: ${item['AppsDate'] ?? ''}',
//                                 style: AppTextStyles.labelMedium.copyWith(
//                                   //
//                                   color: isDark ? Colors.white70 : null,
//                                 ),
//                               ),
//                               Text(
//                                 'Reason: ${item['Reason'] ?? ''}',
//                                 style: AppTextStyles.labelMedium.copyWith(
//                                   //
//                                   color: isDark ? Colors.white70 : null,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//   ///app status badges — no theme needed (colored badges look same in both)
//   Widget _statusBadge(String status) {
//     if (status.isEmpty) {
//       return const Text("No Status", style: TextStyle(color: Colors.red));
//     }
//     String lower = status.toLowerCase().trim();
//     Color color;
//     if (lower.contains('approved by')) {
//       color = Colors.orange;
//     } else if (lower.contains('approved')) {
//       color = Colors.green;
//     } else if (lower.contains('rejected')) {
//       color = Colors.red;
//     } else if (lower.contains('pending')) {
//       color = Colors.orange;
//     } else {
//       color = Colors.grey;
//     }
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: color,
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
//         ),
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
//   Widget _authorizationTabs({bool isDark = false}) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         //
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
//             blurRadius: 8,
//           ),
//         ],
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
//                     Color.fromARGB(255, 232, 70, 145),
//                     Color.fromARGB(255, 167, 9, 83),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               _authTabItem('Pending', 0, isDark: isDark),
//               _authTabItem('Approved', 1, isDark: isDark),
//               _authTabItem('Rejected', 2, isDark: isDark),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _authTabItem(String title, int index, {bool isDark = false}) {
//     bool isSelected = selectedApprovalTab == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => getAdvanceAuthorizationList(index),
//         child: Center(
//           child: AnimatedDefaultTextStyle(
//             duration: const Duration(milliseconds: 300),
//             style: AppTextStyles.labelMedium.copyWith(
//               color: isSelected
//                   ? Colors.white
//                   //         — unselected tab text
//                   : (isDark ? Colors.white38 : Colors.grey),
//               fontWeight: FontWeight.bold,
//             ),
//             child: Text(title),
//           ),
//         ),
//       ),
//     );
//   }
//   ///Company dropdown
//   Widget _companyDropdown({bool isDark = false}) {
//     return DropdownButtonFormField<String>(
//       value: selectedComp,
//       //
//       dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
//       style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
//       items: companyMap.keys.map((companyName) {
//         return DropdownMenuItem(
//           value: companyMap[companyName],
//           child: Text(
//             companyName,
//             style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//           ),
//         );
//       }).toList(),
//       onChanged: (value) async {
//         setState(() {
//           selectedComp = value;
//         });
//         await getAdvanceAuthorizationList(selectedApprovalTab);
//       },
//     );
//   }
//   // Employee Name Search Field
//   Widget employeeSearchField({bool isDark = false}) {
//     return TextField(
//       controller: empNameController,
//       //
//       style: TextStyle(color: isDark ? Colors.white : null),
//       decoration: InputDecoration(
//         hintText: "Search Employee",
//         hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
//         border: const OutlineInputBorder(),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.grey),
//         ),
//       ),
//       onChanged: (value) {
//         selEmpCode = "";
//         if (value.length >= 2) {
//           getEmployeeNameSearch(emppk);
//         } else {
//           setState(() {
//             searchEmp.clear();
//           });
//         }
//       },
//     );
//   }
//   // Employee Name Search List
//   Widget employeeSearchList({bool isDark = false}) {
//     if (searchEmp.isEmpty) {
//       return const SizedBox();
//     }
//     return Container(
//       height: 150,
//       decoration: BoxDecoration(
//         //
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
//   Widget _applyAdvanceForm({bool isDark = false}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         //
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.6) : Colors.black26,
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Apply for Advance',
//             style: AppTextStyles.headingSmall.copyWith(
//               //
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Amount',
//             style: AppTextStyles.labelMedium.copyWith(
//               //
//               color: isDark ? Colors.white70 : null,
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: advamountController,
//             keyboardType: TextInputType.number,
//             //
//             style: TextStyle(color: isDark ? Colors.white : null),
//             decoration: InputDecoration(
//               hintText: 'Enter amount',
//               hintStyle: TextStyle(color: isDark ? Colors.white38 : null),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Reason',
//             style: AppTextStyles.labelMedium.copyWith(
//               color: isDark ? Colors.white70 : null,
//             ),
//           ),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<Map<String, dynamic>>(
//             value: selectedReason,
//             //
//             dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
//             style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//             decoration: InputDecoration(
//               labelText: 'Select Reason',
//               labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//               ),
//             ),
//             items: reasonList.map((item) {
//               return DropdownMenuItem<Map<String, dynamic>>(
//                 value: item,
//                 child: Text(
//                   item['AdvanceReason_Description'],
//                   style: TextStyle(
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 selectedReason = value;
//                 reasonController.text =
//                     value?['AdvanceReason_Description'] ?? '';
//                 descriptionController.text =
//                     "Advance for ${value?['AdvanceReason_Description']}";
//               });
//             },
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Description',
//             style: AppTextStyles.labelMedium.copyWith(
//               color: isDark ? Colors.white70 : null,
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             controller: descriptionController,
//             maxLines: 3,
//             //
//             style: TextStyle(color: isDark ? Colors.white : null),
//             decoration: InputDecoration(
//               labelText: 'Enter description',
//               labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             'Upload Document',
//             style: AppTextStyles.labelMedium.copyWith(
//               color: isDark ? Colors.white70 : null,
//             ),
//           ),
//           const SizedBox(height: 8),
//           InkWell(
//             onTap: pickDocument,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 //
//                 border: Border.all(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.attach_file,
//                     //
//                     color: isDark ? Colors.white70 : Colors.black87,
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     documentName ?? 'Choose PDF/Image',
//                     style: TextStyle(
//                       //
//                       color: isDark ? Colors.white70 : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               CommonButton(
//                 width: 168,
//                 height: 40,
//                 color: const Color.fromARGB(255, 237, 86, 41),
//                 label: 'Submit Application',
//                 onPressed: () {
//                   submitAdvanceApplication();
//                 },
//                 icon: null,
//               ),
//               CommonButton(
//                 width: 160,
//                 height: 40,
//                 //         — cancel button bg
//                 color: isDark
//                     ? const Color(0xFF334155)
//                     : const Color.fromARGB(255, 239, 235, 235),
//                 label: 'Cancel',
//                 textColor: isDark ? Colors.white : Colors.black,
//                 onPressed: resetAdvanceForm,
//                 icon: null,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _advanceCard(Map<String, dynamic> advance, {bool isDark = false}) {
//     final String amount = advance['AdvanceAmount']?.toString() ?? '';
//     final String reason = advance['Reason']?.toString() ?? '';
//     final String status = advance['Status']?.toString() ?? '';
//     final String date = advance['ApplicationDate']?.toString() ?? '';
//     Color statusColor = Colors.orange;
//     if (status.toLowerCase().contains("approved by")) {
//       statusColor = Colors.orange;
//     } else if (status.toLowerCase().contains('approved') &&
//         !status.toLowerCase().contains('approved by')) {
//       statusColor = Colors.green;
//     } else if (status.toLowerCase().contains('rejected')) {
//       statusColor = Colors.red;
//     }
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         //
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
//             blurRadius: 6,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             reason,
//             style: AppTextStyles.headingSmall.copyWith(
//               //
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Date: $date',
//             style: AppTextStyles.labelMedium.copyWith(
//               //
//               color: isDark ? Colors.white70 : null,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'Amount: ₹$amount',
//             style: AppTextStyles.labelMedium.copyWith(
//               //
//               color: isDark ? Colors.white70 : null,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   ////Dispose controllers
//   @override
//   void dispose() {
//     advamountController.dispose();
//     reasonController.dispose();
//     descriptionController.dispose();
//     empNameController.dispose();
//     super.dispose();
//   }
// }

// ignore: dangling_library_doc_comments
///New UI
///

// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/app_services/whtsapp_launcher.dart';
import 'package:new_design_demo/core/constants/ds_color_handler.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/presentations/pages/Modules/advanceManagement/app_advance_approvalFinalForm.dart';
import 'package:new_design_demo/presentations/pages/Modules/advanceManagement/app_advance_approval_form1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

//  SCREEN

class AdvanceScreen extends StatefulWidget {
  const AdvanceScreen({super.key});
  @override
  State<AdvanceScreen> createState() => AdvanceScreenState();
}

class AdvanceScreenState extends State<AdvanceScreen>
    with SingleTickerProviderStateMixin {
  // ── State (all unchanged) ────────────────────────────────
  int? emppk;
  String? empcode;
  int? companypk;
  int? locationpk;
  String? empname;
  int? isSuperAdmin;

  bool showApplyAdvanceForm = false;
  bool isLoading = false;
  List<Map<String, dynamic>> advanceStatusList = [];

  final TextEditingController advamountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? selectedDocument;
  String? documentName;

  List<Map<String, dynamic>> reasonList = [];
  Map<String, dynamic>? selectedReason;

  bool isAuthorizationScreen = false;
  bool isAuthLoading = false;
  List<dynamic> advanceAuthorizationlistData = [];
  String selectedApprovalStatus = 'Pending';
  int selectedApprovalTab = 0;
  List<Map<String, dynamic>> users = [];
  Map<String, String> companyMap = {};
  String? selectedComp;
  List<dynamic> searchEmp = [];
  TextEditingController empNameController = TextEditingController();
  String selEmpCode = '';

  // Fade animation
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  // ── LOGIC (all unchanged) ────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadReasons();
    initializeData();
    getCompanyList();
  }

  @override
  void dispose() {
    advamountController.dispose();
    reasonController.dispose();
    descriptionController.dispose();
    empNameController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> initializeData() async {
    await getPrefsData();
    if (emppk == null) return;
    await loadAdvanceStatus();
  }

  Future<void> getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk = prefs.getInt('emppk');
    empcode = prefs.getString('employeecode');
    companypk = prefs.getInt('companypk');
    locationpk = prefs.getInt('locationpk');
    empname = prefs.getString('employeename');
    isSuperAdmin = int.tryParse(prefs.getString('issuperadmin') ?? '0') ?? 0;
  }

  Future<void> loadAdvanceStatus() async {
    setState(() => isLoading = true);
    final data = await getAdvanceStatusList();
    setState(() {
      advanceStatusList = data;
      isLoading = false;
    });
  }

  //FETCH REASON
  Future<void> loadReasons() async {
    try {
      final response = await ApiClient.get(ApiConstants.getAdvanceReason);
      final data = response.data;
      List<Map<String, dynamic>> tempList = [];
      if (data is List) {
        tempList = List<Map<String, dynamic>>.from(data);
      } else if (data is Map && data['GetAdvanceReasonsList'] != null) {
        tempList = List<Map<String, dynamic>>.from(
          data['GetAdvanceReasonsList'],
        );
      }
      setState(() {
        reasonList = tempList;
      });
    } catch (e) {
      debugPrint("Load Reason Error: $e");
    }
  }

  ////BASE 64
  Future<String> convertFileToBase64(File file) async {
    try {
      List<int> bytes = await file.readAsBytes();
      return base64Encode(bytes).replaceAll("\n", "").replaceAll("\r", "");
    } catch (e) {
      debugPrint("Base64 Error: $e");
      return '';
    }
  }

  //FETCH ADVANCE STATUS LIST
  Future<List<Map<String, dynamic>>> getAdvanceStatusList() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getAdvanceStatus,
        query: {'Emp_PK': emppk},
      );
      final data = response.data;
      if (data is List) {
        return List<Map<String, dynamic>>.from(data)
            .map(
              (item) => {
                ...item,
                'Status': _getReadableStatus(item['Apps_Status']),
              },
            )
            .toList();
      } else if (data is Map && data['GetAdvanceStatusList'] != null) {
        return List<Map<String, dynamic>>.from(data['GetAdvanceStatusList']);
      }
      return [];
    } catch (e) {
      debugPrint('Advance Status Error $e');
      return [];
    }
  }

  String _getReadableStatus(String? rawStatus) {
    if (rawStatus == null || rawStatus.isEmpty) return 'Pending';
    String lower = rawStatus.toLowerCase();
    if (lower.contains('approved by')) {
      return 'Approved by ${rawStatus.split(' by ').last}';
    }
    if (lower.contains('approved')) return 'Approved';
    if (lower.contains('rejected')) return 'Rejected';
    return 'Pending';
  }

  ///SUBMIT ADVANCE APPLICATION
  Future<void> submitAdvanceApplication() async {
    if (advamountController.text.trim().isEmpty ||
        selectedReason == null ||
        descriptionController.text.trim().isEmpty ||
        selectedDocument == null) {
      CommonSnackBar.show(
        context: context,
        title: 'Warning',
        message: 'Please fill all fields',
        type: SnackBarType.warning,
      );
      return;
    }
    try {
      setState(() => isLoading = true);
      String base64Image = await convertFileToBase64(selectedDocument!);
      String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      final response = await ApiClient.post(
        ApiConstants.submitAdvanceApplication,
        data: {
          "EmpPK": emppk,
          "AdvDate": formattedDate,
          "AdvAmount": advamountController.text.trim(),
          "AdvanceRemark": "Emergency case",
          "Reason": selectedReason!['AdvanceReason_Description'],
          "Description": descriptionController.text.trim(),
          "Image": base64Image,
        },
      );
      final message = response.data.toString();
      if (message.toLowerCase().contains('success')) {
        final String msg =
            " Hello, The advance application for amount ${advamountController.text.trim()} with reason '${selectedReason!['AdvanceReason_Description']}' has been approved by $empname.";
        WhatsAppService.sendMessage(phoneNumber: "9730028611", message: msg);
        CommonSnackBar.show(
          context: context,
          title: 'Success',
          message: message,
          type: SnackBarType.success,
        );
        resetAdvanceForm();
        loadAdvanceStatus();
      } else {
        CommonSnackBar.show(
          context: context,
          title: 'Failed',
          message: message,
          type: SnackBarType.warning,
        );
      }
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: 'Error',
        message: 'Failed to apply advance.',
        type: SnackBarType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resetAdvanceForm() {
    advamountController.clear();
    reasonController.clear();
    descriptionController.clear();
    selectedDocument = null;
    documentName = null;
    setState(() => showApplyAdvanceForm = false);
  }

  ///PICKS FILES OR DOCS>
  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      int size = await file.length();
      if (size > 4 * 1024 * 1024) {
        CommonSnackBar.show(
          context: context,
          title: "Error",
          message: "File must be less than 4MB",
          type: SnackBarType.error,
        );
        return;
      }
      setState(() {
        selectedDocument = file;
        documentName = result.files.single.name;
      });
    }
  }

  //FETCH ADVANCE AUTHORIZATION APPLICATIONS
  Future<void> getAdvanceAuthorizationList(int index) async {
    selectedApprovalTab = index;
    const statuses = ['Pending', 'Approved', 'Rejected'];
    setState(() {
      isAuthLoading = true;
      users.clear();
    });
    try {
      final response = await ApiClient.get(
        ApiConstants.getAdvanceApprovalList,
        query: {
          'Emp_PK': emppk,
          'ViewEmpCode': selEmpCode,
          'ViewAppStatus': statuses[index],
          'CompanyGroupDBName': selectedComp,
        },
      );
      final data = response.data;
      if (data is List) {
        users = List<Map<String, dynamic>>.from(data)
            .map(
              (item) => {
                ...item,
                'Status': _getReadableStatus(item['Apps_Status']?.toString()),
              },
            )
            .toList();
      } else if (data is Map && data['GetAdvanceAuthorizationList'] != null) {
        users =
            List<Map<String, dynamic>>.from(data['GetAdvanceAuthorizationList'])
                .map(
                  (item) => {
                    ...item,
                    'Status': item['Apps_Status']?.toString() ?? '',
                  },
                )
                .toList();
      }
    } catch (e) {
      debugPrint('Authorization Error $e');
    }
    setState(() => isAuthLoading = false);
  }

  ////FETCH EMPLOYEE NAME SEARCH LIST
  Future<void> getEmployeeNameSearch(int? emppk) async {
    setState(() {
      isLoading = true;
      searchEmp.clear();
    });
    try {
      String company = selectedComp ?? "";
      final response = await ApiClient.get(
        "${ApiConstants.searchEmployeeNameCode}?Emp_PK=${emppk ?? 0}&Searchtxt=${empNameController.text}&CompanyGroupDBName=$company",
      );
      dynamic data = response.data;
      if (data is String) data = jsonDecode(data);
      final List list =
          data["AutoCompleteData_AttendanceApplicationResult"] ?? [];
      searchEmp = list.map<Map<String, dynamic>>((item) {
        final parts = item.split(":");
        return {
          "Employee_Code": parts[0],
          "EmpName": parts.length > 1 ? parts[1] : "",
        };
      }).toList();
      setState(() {});
    } catch (e) {
      debugPrint("Employee Search Error: $e");
    }
    setState(() => isLoading = false);
  }

  //FETCH COMPANY LIST
  Future<void> getCompanyList() async {
    try {
      final response = await ApiClient.get(ApiConstants.getCompanyGroupList);
      final data = response.data;
      if (data is List) {
        companyMap.clear();
        for (var item in data) {
          companyMap[item['Company_Name'].toString()] =
              item['CompanyGroupDBName'].toString();
        }
        selectedComp = companyMap.values.first;
      }
    } catch (e) {
      debugPrint('Company List Error $e');
    }
  }

  void onTapApplication(Map<String, dynamic> data) {
    String status = (data["Apps_Status"] ?? "").toString().toLowerCase();
    if (status.contains("approved by") || status.contains("pending")) {
      openApprovalForm(data);
    } else if (status.contains("approved")) {
      CommonSnackBar.show(
        context: context,
        title: "Approved",
        message: "Advance application already fully approved.",
        type: SnackBarType.warning,
      );
    } else if (status.contains("rejected")) {
      CommonSnackBar.show(
        context: context,
        title: "Rejected",
        message: "Advance application already rejected.",
        type: SnackBarType.warning,
      );
    } else {
      openApprovalForm(data);
    }
  }

  // void openApprovalForm(Map<String, dynamic> data) {
  //   // "IsFinalHRApprover": false,"IsFirstApprover": true,"IsSecondApprover": false,      ConditionalForms
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => ApprovalFormScreen(
  //         transId: int.tryParse(data["TransID"]?.toString() ?? "0") ?? 0,
  //         empPk: int.tryParse(data["EmpPK"]?.toString() ?? "0") ?? 0,
  //         companyGroup: selectedComp ?? "",
  //       ),
  //     ),
  //   );
  // }
  void openApprovalForm(Map<String, dynamic> data) {
    bool isFinalHRApprover = data["IsFinalHRApprover"] ?? false;
    bool isFirstApprover = data["IsFirstApprover"] ?? false;
    bool isSecondApprover = data["IsSecondApprover"] ?? false;

    Widget screen;

    if (isFinalHRApprover) {
      // HR Final Approval Form
      screen = AdvanceEntryFormReporting2(
        transId: int.tryParse(data["TransID"]?.toString() ?? "0") ?? 0,

        empPk: int.tryParse(data["EmpPK"]?.toString() ?? "0") ?? 0,

        companyGroup: selectedComp ?? "",
        responseData: {},
      );
    } else if (isFirstApprover || isSecondApprover) {
      // Reporting Manager Approval Form
      screen = ApprovalFormScreen(
        transId: int.tryParse(data["TransID"]?.toString() ?? "0") ?? 0,

        empPk: int.tryParse(data["EmpPK"]?.toString() ?? "0") ?? 0,

        companyGroup: selectedComp ?? "",
      );
    } else {
      // Default
      screen = ApprovalFormScreen(
        transId: int.tryParse(data["TransID"]?.toString() ?? "0") ?? 0,

        empPk: int.tryParse(data["EmpPK"]?.toString() ?? "0") ?? 0,

        companyGroup: selectedComp ?? "",
      );
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void resetAuthorizationFilters() {
    empNameController.clear();
    selEmpCode = '';
    searchEmp.clear();
    if (companyMap.isNotEmpty) selectedComp = companyMap.values.first;
    selectedApprovalTab = 0;
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (showApplyAdvanceForm) {
          setState(() => showApplyAdvanceForm = false);
          return false;
        }
        if (isAuthorizationScreen) {
          setState(() {
            resetAuthorizationFilters();
            isAuthorizationScreen = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? DS.surfaceDark : DS.surfaceLight,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(isDark),
                if (!showApplyAdvanceForm) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: DS.brandStart,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Advance History",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: isAuthorizationScreen
                      ? _advanceAuthorizationData(isDark)
                      : isLoading
                      ? _loadingState()
                      : advanceStatusList.isEmpty
                      ? _emptyState(
                          "No Advance History Found.",
                          Icons.money_off_rounded,
                          isDark,
                        )
                      : FadeTransition(
                          opacity: _fadeAnim,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: advanceStatusList.length,
                            itemBuilder: (_, i) =>
                                _advanceCard(advanceStatusList[i], isDark),
                          ),
                        ),
                ),
              ],
            ),
            if (showApplyAdvanceForm)
              Positioned(
                top: 200,
                left: 12,
                right: 12,
                bottom: 0,
                child: _applyAdvanceForm(isDark),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DS.brandStart, DS.brandMid, DS.brandDeep],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: _decorCircle(170, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            left: -20,
            bottom: 10,
            child: _decorCircle(100, Colors.white.withOpacity(0.04)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isAuthorizationScreen) {
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          getAdvanceAuthorizationList(0);
                          isAuthorizationScreen = false;
                        });
                      }
                    },
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
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Advance",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              "Management",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Text(
                                "Manage Your Advance & Requests",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _headerBtn(
                            "Apply Advance",
                            Icons.add_circle_outline_rounded,
                            () => setState(
                              () =>
                                  showApplyAdvanceForm = !showApplyAdvanceForm,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!isAuthorizationScreen)
                            _headerBtn(
                              "Authorization",
                              Icons.verified_user_outlined,
                              () {
                                setState(() {
                                  isAuthorizationScreen = true;
                                  getAdvanceAuthorizationList(0);
                                });
                              },
                            ),
                        ],
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

  Widget _headerBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: DS.brandDeep, size: 17),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: DS.brandDeep,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ─── ADVANCE CARD ────────────────────────────────────────
  Widget _advanceCard(Map<String, dynamic> advance, bool isDark) {
    final String amount = advance['AdvanceAmount']?.toString() ?? '';
    final String reason = advance['Reason']?.toString() ?? '';
    final String status = advance['Status']?.toString() ?? '';
    final String date = advance['ApplicationDate']?.toString() ?? '';

    final _StatusInfo si = _advanceStatusInfo(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: si.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: si.color.withOpacity(0.25)),
                  ),
                  child: Icon(
                    Icons.currency_rupee_rounded,
                    color: si.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reason,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 11,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black38,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _statusBadge(status, si.color),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? DS.borderDark : DS.borderLight),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Icon(
                  Icons.currency_rupee_rounded,
                  size: 14,
                  color: DS.brandStart,
                ),
                const SizedBox(width: 4),
                Text(
                  "Amount: ",
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12,
                  ),
                ),
                Text(
                  "₹$amount",
                  style: const TextStyle(
                    color: DS.brandStart,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── APPLY ADVANCE FORM ──────────────────────────────────
  Widget _applyAdvanceForm(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DS.cardDark : DS.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(DS.r24)),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DS.brandStart, DS.brandDeep],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: DS.brandStart.withOpacity(0.35),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Apply for Advance",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: resetAdvanceForm,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _sectionLabel("Amount", isDark),
                  const SizedBox(height: 8),
                  TextField(
                    controller: advamountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                    decoration: _fieldDec(
                      "Enter amount",
                      isDark,
                      prefix: Icons.currency_rupee_rounded,
                    ),
                  ),

                  const SizedBox(height: 16),
                  _sectionLabel("Reason", isDark),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedReason,
                    dropdownColor: isDark ? DS.cardDark : null,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                    decoration: _fieldDec("Select Reason", isDark),
                    items: reasonList
                        .map(
                          (item) => DropdownMenuItem<Map<String, dynamic>>(
                            value: item,
                            child: Text(
                              item['AdvanceReason_Description'],
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      selectedReason = value;
                      reasonController.text =
                          value?['AdvanceReason_Description'] ?? '';
                      descriptionController.text =
                          "Advance for ${value?['AdvanceReason_Description']}";
                    }),
                  ),

                  const SizedBox(height: 16),
                  _sectionLabel("Description", isDark),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                    decoration: _fieldDec("Enter description", isDark),
                  ),

                  const SizedBox(height: 16),
                  _sectionLabel("Upload Document", isDark),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: pickDocument,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? DS.inputDark : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(DS.r12),
                        border: Border.all(
                          color: selectedDocument != null
                              ? DS.brandStart
                              : (isDark ? DS.borderDark : DS.borderLight),
                          width: selectedDocument != null ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: DS.brandStart.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              selectedDocument != null
                                  ? Icons.check_circle_rounded
                                  : Icons.attach_file_rounded,
                              color: selectedDocument != null
                                  ? DS.brandStart
                                  : (isDark ? Colors.white38 : Colors.black38),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              documentName ?? "Choose PDF / Image (max 4MB)",
                              style: TextStyle(
                                color: selectedDocument != null
                                    ? DS.brandStart
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: submitAdvanceApplication,
                          child: _gradientBtn(
                            "Submit Application",
                            Icons.send_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: resetAdvanceForm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black38,
                              borderRadius: BorderRadius.circular(DS.r12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.black38,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AUTHORIZATION DATA ──────────────────────────────────
  Widget _advanceAuthorizationData(bool isDark) {
    if (isAuthLoading) return _loadingState();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          _companyDropdown(isDark),
          const SizedBox(height: 8),
          employeeSearchField(isDark),
          employeeSearchList(isDark),
          const SizedBox(height: 10),
          _authorizationTabs(isDark),
          const SizedBox(height: 12),
          Expanded(
            child: users.isEmpty
                ? _emptyState("No Data Found", Icons.money_off_rounded, isDark)
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (_, i) {
                      final item = users[i];
                      final si = _advanceStatusInfo(item['Apps_Status'] ?? '');
                      return InkWell(
                        onTap: () => onTapApplication(item),
                        borderRadius: BorderRadius.circular(DS.r20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: isDark ? DS.cardDark : DS.cardLight,
                            borderRadius: BorderRadius.circular(DS.r20),
                            border: Border.all(
                              color: isDark ? DS.borderDark : DS.borderLight,
                            ),
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
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  14,
                                  16,
                                  12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['Name'] ?? '',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _statusBadge(
                                      item['Apps_Status'] ?? '',
                                      si.color,
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                height: 1,
                                color: isDark ? DS.borderDark : DS.borderLight,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  14,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow(
                                      Icons.calendar_today_outlined,
                                      "Date",
                                      item['AppsDate'] ?? '',
                                      isDark,
                                    ),
                                    const SizedBox(height: 4),
                                    _infoRow(
                                      Icons.notes_rounded,
                                      "Reason",
                                      item['Reason'] ?? '',
                                      isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─── AUTH TABS ───────────────────────────────────────────
  Widget _authorizationTabs(bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? DS.cardDark : DS.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black38,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          _authPill("Pending", 0, const Color(0xFFF59E0B), isDark),
          _authPill("Approved", 1, const Color(0xFF10B981), isDark),
          _authPill("Rejected", 2, const Color(0xFFEF4444), isDark),
        ],
      ),
    );
  }

  Widget _authPill(String label, int index, Color color, bool isDark) {
    final bool isSelected = selectedApprovalTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => getAdvanceAuthorizationList(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: color.withOpacity(0.4))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white38 : Colors.black38),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────
  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) => Text(
    label,
    style: TextStyle(
      color: isDark ? Colors.white54 : const Color(0xFF64748B),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _gradientBtn(String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(vertical: 13),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [DS.brandStart, DS.brandDeep]),
      borderRadius: BorderRadius.circular(DS.r12),
      boxShadow: [
        BoxShadow(color: DS.brandStart.withOpacity(0.35), blurRadius: 10),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
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

  Widget _infoRow(IconData icon, String label, String value, bool isDark) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF334155),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );

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

  Widget _emptyState(String msg, IconData icon, bool isDark) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DS.brandStart.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: DS.brandStart, size: 32),
        ),
        const SizedBox(height: 14),
        Text(
          msg,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black38,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  InputDecoration _fieldDec(
    String hint,
    bool isDark, {
    IconData? prefix,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDark ? Colors.white30 : Colors.black26,
      fontSize: 12,
    ),
    prefixIcon: prefix != null
        ? Icon(
            prefix,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 18,
          )
        : null,
    filled: true,
    fillColor: isDark ? DS.inputDark : Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  Widget _companyDropdown(bool isDark) => DropdownButtonFormField<String>(
    value: selectedComp,
    dropdownColor: isDark ? DS.cardDark : null,
    style: TextStyle(
      color: isDark ? Colors.white : const Color(0xFF0F172A),
      fontSize: 13,
    ),
    decoration: _fieldDec(
      "Select Company",
      isDark,
      prefix: Icons.business_outlined,
    ),
    items: companyMap.keys
        .map(
          (name) => DropdownMenuItem<String>(
            value: companyMap[name],
            child: Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13,
              ),
            ),
          ),
        )
        .toList(),
    onChanged: (v) async {
      setState(() => selectedComp = v);
      await getAdvanceAuthorizationList(selectedApprovalTab);
    },
  );

  Widget employeeSearchField(bool isDark) => TextField(
    controller: empNameController,
    style: TextStyle(
      color: isDark ? Colors.white : const Color(0xFF0F172A),
      fontSize: 13,
    ),
    decoration: _fieldDec("Search Employee", isDark).copyWith(
      prefixIcon: Icon(
        Icons.search_rounded,
        color: isDark ? Colors.white38 : Colors.black38,
        size: 20,
      ),
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

  Widget employeeSearchList(bool isDark) {
    if (searchEmp.isEmpty) return const SizedBox();
    return Container(
      height: 150,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? DS.cardDark : DS.cardLight,
        borderRadius: BorderRadius.circular(DS.r12),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black38,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DS.r12),
        child: ListView.separated(
          itemCount: searchEmp.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? DS.borderDark : DS.borderLight,
          ),
          itemBuilder: (_, i) {
            final emp = searchEmp[i];
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: DS.brandStart.withOpacity(0.15),
                child: const Icon(
                  Icons.person_outline,
                  color: DS.brandStart,
                  size: 16,
                ),
              ),
              title: Text(
                "${emp["Employee_Code"]} — ${emp["EmpName"]}",
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => setState(() {
                empNameController.text = emp["EmpName"];
                selEmpCode = emp["Employee_Code"];
                searchEmp.clear();
              }),
            );
          },
        ),
      ),
    );
  }
}

//  STATUS HELPERS

class _StatusInfo {
  final Color color;
  final IconData icon;
  const _StatusInfo(this.color, this.icon);
}

_StatusInfo _advanceStatusInfo(String status) {
  String lower = status.toLowerCase();
  if (lower.contains('approved by')) {
    return const _StatusInfo(Color(0xFFF59E0B), Icons.hourglass_empty_rounded);
  }
  if (lower.contains('approved') && !lower.contains('by')) {
    return const _StatusInfo(
      Color(0xFF10B981),
      Icons.check_circle_outline_rounded,
    );
  }
  if (lower.contains('rejected')) {
    return const _StatusInfo(Color(0xFFEF4444), Icons.cancel_outlined);
  }
  return const _StatusInfo(Color(0xFFF59E0B), Icons.hourglass_empty_rounded);
}
