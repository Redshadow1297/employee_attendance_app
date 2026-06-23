// // ignore_for_file: use_build_context_synchronously, unused_local_variable, duplicate_ignore, deprecated_member_use
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:intl/intl.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/app_services/whatsappNotification.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/alert_box.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_button.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_timePicker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});
//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }
// class _AttendanceScreenState extends State<AttendanceScreen> {
//   int? emppk;
//   String? empcode;
//   int? companypk;
//   int? locationpk;
//   String? empname;
//   int? isSuperAdmin;
//   String? currentDtTime;
//   List<dynamic> timeCardList = [];
//   bool isLoading = true;
//   int selectedTab = 0;
//   int? expandedIndex;
//   List<dynamic> attStatusList = [];
//   bool showAttAuthorization = false;
//   List<dynamic> approvalList = [];
//   bool isAuthLoading = false;
//   bool isAuthorizationScreen = false;
//   String selectedApprovalStatus = "Pending";
//   int selectedApprovalTab = 0;
//   List<Map<String, dynamic>> users = [];
//   Map<String, String> companyMap = {};
//   String? selectedComp;
//   List searchEmp = [];
//   dynamic searchEmpData;
//   TextEditingController empNameController = TextEditingController();
//   String selEmpCode = "";
//   final TextEditingController _checkInController = TextEditingController();
//   final TextEditingController _checkOutController = TextEditingController();
//   final TextEditingController _reasonController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     _methodLoader();
//     _getPrefsData().then((_) {
//       _loadAttendanceStatusList();
//     });
//   }
//   void _methodLoader() async {
//     await getCompanyList();
//     await fetchCurrentDate();
//     await _loadAttendanceApprovalList();
//   }
//   Future<void> _getPrefsData() async {
//     final prefs = await SharedPreferences.getInstance();
//     emppk = prefs.getInt("emppk");
//     empcode = prefs.getString("employeecode");
//     companypk = prefs.getInt("companypk");
//     locationpk = prefs.getInt("locationpk");
//     empname = prefs.getString("employeename");
//     isSuperAdmin = int.tryParse(prefs.getString("issuperadmin") ?? "0") ?? 0;
//     await _loadTimeCard();
//   }
//   Future<void> _loadAttendanceApprovalList() async {
//     setState(() => isAuthLoading = true);
//     const statuses = ["Pending", "Approved", "Rejected"];
//     String status = statuses[selectedApprovalTab];
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.getAttendanceApprovalList,
//         data: {
//           "Emp_PK": emppk,
//           "EmpCode": selEmpCode,
//           "EmpName": empNameController.text,
//           "Status": status,
//           "AttDate": "",
//           "approval": "",
//           "CompanyGroupDBName": selectedComp ?? companyMap[companyMap.keys.first],
//         },
//       );
//       final result = response.data["GetAttendaceAppApprovalListResult"];
//       setState(() {
//         approvalList = result != null ? List.from(result) : [];
//       });
//     } catch (e) {
//       debugPrint("Approval Error: $e");
//       setState(() => approvalList = []);
//     }
//     setState(() => isAuthLoading = false);
//   }
//   Future<void> _loadTimeCard() async {
//     setState(() => isLoading = true);
//     DateTime fdate = DateTime.now().subtract(const Duration(days: 61));
//     DateTime ldate = DateTime.now();
//     try {
//       String startDate = DateFormat('dd/MM/yyyy').format(fdate);
//       String endDate = DateFormat('dd/MM/yyyy').format(ldate);
//       final response = await ApiClient.get(
//         ApiConstants.getTimeCardData,
//         query: {
//           "Emp_PK": emppk,
//           "strstartdate": startDate,
//           "strendate": endDate,
//         },
//       );
//       final result = response.data["GetTimeCardResult"];
//       setState(() {
//         timeCardList = result != null ? List.from(result) : [];
//         timeCardList.sort((a, b) {
//           DateTime dateA = DateFormat("MM/dd/yyyy hh:mm:ss a").parse(a['scheduledate']);
//           DateTime dateB = DateFormat("MM/dd/yyyy hh:mm:ss a").parse(b['scheduledate']);
//           return dateB.compareTo(dateA);
//         });
//       });
//     } catch (e) {
//       debugPrint("TimeCard Error: $e");
//    }
//     setState(() => isLoading = false);
//
//   Future<void> _loadAttendanceStatusList() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getAttendanceStatus,
//         query: {"Emp_pk": emppk},
//       );
//       final result = response.data["GetAttendanceStatusResult"];
//       setState(() {
//         attStatusList = result != null ? List.from(result) : [];
//         attStatusList.sort((a, b) {
//           DateTime dateA = DateFormat("MMM dd, yyyy").parse(a['AttendanceDate']);
//           DateTime dateB = DateFormat("MMM dd, yyyy").parse(b['AttendanceDate']);
//           return dateB.compareTo(dateA);
//         });
//       });
//     } catch (e) {
//       debugPrint("History Error: $e");
//       setState(() => attStatusList = []);
//     }
//     setState(() => isLoading = false);
//   }
//   Future<void> _submitAttApplicationTimecard(date) async {
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.submitAttendanceApplication,
//         data: {
//           "Emp_PK": emppk.toString(),
//           "InTime": _checkInController.text,
//           "AttendanceDate": date,
//           "OutTime": _checkOutController.text,
//           "ApplicationDate": currentDtTime,
//           "Reason": _reasonController.text,
//         },
//       );
//       final result = response.data["AttendaceApplicationResult"];
//       if (result.toString().toLowerCase().contains("success")) {
//         CommonSnackBar.show(
//           context: context,
//           title: "Done",
//           message: result,
//           type: SnackBarType.success,
//         );
//         String whatsappMessage = """
//          Attendance Application :
//         👤 Name: $empname
//         📅 From: ${_checkInController.text}
//         📅 To: ${_checkOutController.text}
//         📊 Attendance Date: $date
//         📝 Reason: ${_reasonController.text}
//         📊 Application Date : $currentDtTime
//         """;
//         try {
//           await sendWhatsAppDirect(whatsappMessage);
//         } catch (e) {
//           debugPrint("WhatsApp send Notification Error :: $e");
//        }
//         _checkInController.clear();
//         _checkOutController.clear();
//         _reasonController.clear();
//         setState(() => expandedIndex = null);
//       } else {
//         CommonSnackBar.show(
//           context: context,
//           title: "Warning",
//           message: result,
//           type: SnackBarType.warning,
//         );
//       }
//       if (result.toString().toLowerCase().contains("fail")) {
//         CommonSnackBar.show(
//           context: context,
//           title: "Failed",
//           message: result,
//           type: SnackBarType.error,
//         );
//       }
//     } catch (ex) {
//       debugPrint("Exception Occurred When Attendance Application ::: $ex");
//       CommonSnackBar.show(
//         context: context,
//         title: "Exception !",
//         message: "$ex",
//         type: SnackBarType.warning,
//       );
//     }
//   }
//   Future<void> _selfRejectAttendance(String transPk) async {
//     try {
//       final response = await ApiClient.post(
//         ApiConstants.selfRejectAttendance,
//         data: {
//           "Emp_PK": emppk.toString(),
//           "Trans_Pk": transPk,
//           // "ApprovalReason": "Self Rejected by Employee", //UpdatedO 21-02-26
//           "appliedby": "Android"
//         },
//       );
//       final result = response.data["AttendanceSelfRejectResult"];
//   ////Result is Application rejected On Success from API
//       if (result.toString().toLowerCase() == "application rejected") {
//         CommonSnackBar.show(
//           context: context,
//           title: "Success",
//           message: result,
//           type: SnackBarType.success,
//         );
//         _loadAttendanceStatusList();
//       } else {
//         CommonSnackBar.show(
//           context: context,
//           title: "Warning",
//           message: result,
//           type: SnackBarType.warning,
//         );
//       }
//     } catch (e) {
//       debugPrint("Self Reject Error: $e");
//       CommonSnackBar.show(
//         context: context,
//         title: "Error",
//         message: "Exception Occured : $e.",
//         type: SnackBarType.error,
//       );
//     }
//   }
// //Fetch Current Date from API
//   Future<void> fetchCurrentDate() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getCurrentDate,
//         query: {"Emp_pk": emppk},
//       );
//       final data = response.data["getSchedulerData"];
//       if (data != null && data.isNotEmpty) {
//         currentDtTime = data[0]["current_date"];
//       }
//     } catch (e) {
//       debugPrint("History Error: $e");
//     }
//   }
// ///Approve or rejetct the attendance application by athorizer
//   void _approveOrRejectAttApp(String upPk, String newStatus) async {
//     setState(() {
//       for (var item in approvalList) {
//         if (item["UP_PK"] == upPk) {
//           item["Status"] = newStatus;
//         }
//       }
//     });
//   }
// ///Get Employee Search List for Employee
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
//       if (data is String) data = jsonDecode(data);
//       final List list = data["AutoCompleteData_LeaveReportingResult"];
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
//     setState(() => isLoading = false);
//   }
// ///Get Company List for Dropdown in Authorization Screen
//   Future<void> getCompanyList() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getCompanyGroupList,
//         query: {},
//       );
//       final data = response.data;
//       if (data is List) {
//         companyMap.clear();
//         for (var item in data) {
//           String key = item["Company_Name"].toString();
//           String value = item["CompanyGroupDBName"].toString();
//           companyMap[key] = value;
//         }
//         selectedComp = companyMap.values.first;
//         _loadAttendanceApprovalList();
//       }
//     } catch (e) {
//       debugPrint("Company List Error: $e");
//     }
//   }
//   //  BUILD
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return WillPopScope(
//       onWillPop: () async {
//         if (isAuthorizationScreen) {
//           setState(() {
//             _clearAuthorizationFilters();
//             isAuthorizationScreen = false;
//           });
//           return false;
//         }
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
//         body: Column(
//           children: [
//             _header(),
//             if (!isAuthorizationScreen)
//               Row(
//                 children: [
//                   _tabButton("Time Card", 0, isDark: isDark),
//                   _tabButton("History", 1, isDark: isDark),
//                 ],
//               ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: isAuthorizationScreen
//                   ? _attAuthorizationData(isDark: isDark)
//                   : selectedTab == 0
//                   ? _timeCardList(isDark: isDark)
//                   : _attStatus(isDark: isDark),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   //  HEADER
//   Widget _header() {
//     return Container(
//       height: 230,
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF31D12B), Color(0xFF067E01)],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(16),
//           bottomRight: Radius.circular(16),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: () {
//               if (isAuthorizationScreen) {
//                 setState(() {
//                   _clearAuthorizationFilters();
//                   isAuthorizationScreen = false;
//                 });
//               } else {
//                 Navigator.pop(context);
//               }
//             },
//             child: CircleAvatar(
//               backgroundColor: Colors.white.withOpacity(0.15),
//               child: const Icon(Icons.arrow_back, color: Colors.white),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Text(
//                     isAuthorizationScreen
//                         ? "Attendance Authorization"
//                         : "Attendance Management",
//                     style: AppTextStyles.headingLarge.copyWith(
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     isAuthorizationScreen
//                         ? "Approve or Reject Requests"
//                         : "Track Your Attendance",
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               if (!isAuthorizationScreen)
//                 SizedBox(
//                   width: 170,
//                   height: 42,
//                   child: CommonButton(
//                     label: "Authorization",
//                     color: Colors.white,
//                     icon: const Icon(
//                       Icons.verified_user,
//                       color: Colors.lightBlue,
//                       size: 20,
//                     ),
//                     textColor: Colors.deepOrangeAccent,
//                     onPressed: () {
//                       setState(() {
//                         isAuthorizationScreen = true;
//                         _loadAttendanceApprovalList();
//                       });
//                     },
//                     width: 160,
//                     height: 42,
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   //  AUTHORIZATION TABS
//   Widget _authorizationTabs({bool isDark = false}) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         //
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
//                   colors: [Color.fromARGB(255, 69, 210, 65), Color(0xFF067E01)],
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
//     bool isSelected = selectedApprovalTab == index;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() => selectedApprovalTab = index);
//           _loadAttendanceApprovalList();
//         },
//         child: Center(
//           child: AnimatedDefaultTextStyle(
//             duration: const Duration(milliseconds: 300),
//             style: AppTextStyles.labelMedium.copyWith(
//               color: isSelected ? Colors.white : Colors.grey,
//               fontWeight: FontWeight.bold,
//             ),
//             child: Text(title),
//           ),
//         ),
//       ),
//     );
//   }
//   //  TAB BUTTON
//   Widget _tabButton(String text, int index, {bool isDark = false}) {
//     bool isSelected = selectedTab == index;
//     return Expanded(
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(30),
//             onTap: () async {
//               setState(() {
//                 selectedTab = index;
//                 expandedIndex = null;
//               });
//               if (index == 0) {
//                 await _loadTimeCard();
//               } else {
//                 await _loadAttendanceStatusList();
//               }
//             },
//             child: Container(
//               height: 47,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(30),
//                 border: Border.all(
//                   color: isSelected ? Colors.green : Colors.grey,
//                 ),
//                 gradient: isSelected
//                     ? const LinearGradient(
//                         colors: [
//                           Color.fromARGB(255, 60, 207, 55),
//                           Color(0xFF067E01),
//                         ],
//                       )
//                     : null,
//                 //        - unselected tab bg
//                 color: isSelected ? null : (isDark ? const Color(0xFF1E293B) : null),
//               ),
//               child: Text(
//                 text,
//                 style: AppTextStyles.labelMedium.copyWith(
//                   color: isSelected
//                       ? Colors.white
//                       : (isDark ? Colors.white60 : Colors.grey),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//   //  TIME CARD LIST
//   Widget _timeCardList({bool isDark = false}) {
//     if (isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.blueGrey),
//       );
//    }
//     if (timeCardList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.access_time, size: 30, color: Colors.grey),
//             const SizedBox(height: 12),
//             Text(
//               "No Time Card Data Found",
//               style: AppTextStyles.labelMedium.copyWith(color: Colors.grey),
//             ),
//           ],
//         ),
//       );
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: timeCardList.length,
//       itemBuilder: (context, index) {
//         return _timeCard(timeCardList[index], index, isDark: isDark);
//       },
//     );
//   }
//   //  TIME CARD ITEM
//   Widget _timeCard(dynamic item, int index, {bool isDark = false}) {
//     String empStatus = item['empstatus'] ?? '';
//     String date = item['scheduledateddmm'] ?? '';
//     String checkIn = item['intiming'] == "-" ? "--:--" : item['intiming'];
//     String checkOut = item['outtiming'] == "-" ? "--:--" : item['outtiming'];
//     String totalHours = item['Totalwork'] == "0.0" ? "--" : item['Totalwork'];
//     DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);
//     String weekday = DateFormat("EEEE").format(parsedDate);
//     Color statusColor;
//     String statusText;
//     switch (empStatus) {
//       case "P":
//         statusColor = Colors.green;
//         statusText = "Present";
//         break;
//       case "AB":
//         statusColor = Colors.red;
//         statusText = "Absent";
//         break;
//       case "WO":
//         statusColor = Colors.blue;
//         statusText = "Week Off";
//         break;
//       case "PH":
//         statusColor = Colors.orange;
//         statusText = "Holiday";
//         break;
//       default:
//         statusColor = Colors.grey;
//         statusText = empStatus;
//     }
//     bool showRegularize =
//         empStatus == "AB" ||
//         (empStatus == "P" &&
//             (item['intiming'] == "-" || item['outtiming'] == "-"));
//     bool isExpanded = expandedIndex == index;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         //        - card background
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
//             blurRadius: 6,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     weekday,
//                     style: AppTextStyles.headingSmall.copyWith(
//                       //
//                       color: isDark ? Colors.white : null,
//                     ),
//                   ),
//                   Text(
//                     date,
//                     style: AppTextStyles.labelMedium.copyWith(
//                       //
//                       color: isDark ? Colors.white70 : Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   statusText,
//                   style: AppTextStyles.labelSmall.copyWith(color: statusColor),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               //        - inner box
//               color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _timeColumn("Check In", checkIn, isDark: isDark),
//                 _timeColumn("Check Out", checkOut, isDark: isDark),
//                 _timeColumn("Total Hours", totalHours, isDark: isDark),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),
//           if (showRegularize && !isExpanded)
//             CommonButton(
//               width: 130,
//               height: 30,
//               color: const Color.fromARGB(255, 46, 209, 206),
//               label: "Regularize",
//               onPressed: () {
//                 setState(() => expandedIndex = index);
//               },
//               icon: null,
//             ),
//           if (isExpanded) _regularizeForm(index, date, isDark: isDark),
//         ],
//       ),
//     );
//   }
//   Widget _timeColumn(String title, String value, {bool isDark = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: AppTextStyles.labelMedium.copyWith(
//             //
//             color: isDark ? Colors.white70 : null,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: AppTextStyles.labelSmall.copyWith(
//             //
//             color: isDark ? Colors.white54 : null,
//           ),
//         ),
//       ],
//     );
//   }
//   //  REGULARIZE FORM
//   Widget _regularizeForm(int index, String date, {bool isDark = false}) {
//     return Container(
//       margin: const EdgeInsets.only(top: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         //
//         color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? Colors.white24 : Colors.black,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Regularize Attendance",
//             style: AppTextStyles.headingMedium.copyWith(
//               //
//               color: isDark ? Colors.white : null,
//             ),
//           ),
//           const SizedBox(height: 12),
//           TextField(
//             controller: _checkInController,
//             readOnly: true,
//             style: TextStyle(color: isDark ? Colors.white : null), //
//             decoration: InputDecoration(
//               labelText: "Check In Time",
//               labelStyle: TextStyle(color: isDark ? Colors.white70 : null), //
//               suffixIcon: Icon(
//                 Icons.access_time,
//                 color: isDark ? Colors.white54 : null, //
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.black,
//                 ),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//               ),
//             ),
//             onTap: () {
//               AppTimePicker.show(
//                 context: context,
//                 controller: _checkInController,
//               );
//             },
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             controller: _checkOutController,
//             readOnly: true,
//             style: TextStyle(color: isDark ? Colors.white : null), //
//             decoration: InputDecoration(
//               labelText: "Check Out Time",
//               labelStyle: TextStyle(color: isDark ? Colors.white70 : null), //
//               suffixIcon: Icon(
//                 Icons.access_time,
//                 color: isDark ? Colors.white54 : null, //
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//               ),
//             ),
//             onTap: () {
//               AppTimePicker.show(
//                 context: context,
//                 controller: _checkOutController,
//               );
//             },
//           ),
//           const SizedBox(height: 10),
//           TextField(
//             maxLines: 2,
//             controller: _reasonController,
//             style: TextStyle(color: isDark ? Colors.white : null), //
//             decoration: InputDecoration(
//               labelText: "Reason",
//               labelStyle: TextStyle(color: isDark ? Colors.white70 : null), //
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(
//                   color: isDark ? Colors.white24 : Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               CommonButton(
//                 width: 150,
//                 height: 40,
//                 color: Colors.deepOrangeAccent,
//                 label: "Submit",
//                 onPressed: () {
//                   if (_reasonController.text.isEmpty ||
//                       _checkInController.text.isEmpty ||
//                       _checkOutController.text.isEmpty) {
//                     CommonSnackBar.show(
//                       context: context,
//                       title: "All Fields Required",
//                       message: "Please fill in all fields to submit.",
//                       type: SnackBarType.warning,
//                     );
//                     return;
//                   }
//                   _submitAttApplicationTimecard(date);
//                   setState(() => expandedIndex = index);
//                 },
//                 icon: null,
//               ),
//               const SizedBox(width: 10),
//               CommonButton(
//                 width: 150,
//                 height: 40,
//                 color: Colors.grey,
//                 label: "Cancel",
//                 onPressed: () {
//                   setState(() {
//                     _checkInController.clear();
//                     _checkOutController.clear();
//                     _reasonController.clear();
//                     expandedIndex = null;
//                   });
//                 },
//                 icon: null,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   //  ATTENDANCE HISTORY / STATUS
//   Widget _attStatus({bool isDark = false}) {
//     if (isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.blueGrey),
//       );
//     }
//     if (attStatusList.isEmpty) {
//       return Center(
//         child: Text(
//           "No History Found",
//           style: TextStyle(color: isDark ? Colors.white54 : null), //
//         ),
//       );
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: attStatusList.length,
//       itemBuilder: (context, index) {
//         final item = attStatusList[index];
//         String attDate = item['AttendanceDate'] ?? '';
//         String checkIn = item['FromDate'] == "" ? "--:--" : item['FromDate'];
//         String checkOut = item['ToDate'] == "" ? "--:--" : item['ToDate'];
//         String status = item['Approval_Status'] ?? '';
//         Color statusColor;
//         switch (status.toLowerCase()) {
//           case "approved":
//             statusColor = Colors.green;
//             break;
//           case "rejected":
//             statusColor = Colors.red;
//             break;
//           case "pending":
//             statusColor = Colors.orange;
//             break;
//           default:
//             statusColor = Colors.grey;
//         }
//         return Container(
//           margin: const EdgeInsets.only(bottom: 16),
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             //        - card background
//             color: isDark ? const Color(0xFF1E293B) : Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: isDark ? Colors.black.withOpacity(0.4) : Colors.black12,
//                 blurRadius: 6,
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Attendance Date : $attDate",
//                         style: AppTextStyles.labelMedium.copyWith(
//                           fontWeight: FontWeight.bold,
//                           //
//                           color: isDark ? Colors.white : null,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       status,
//                       style: AppTextStyles.labelSmall.copyWith(
//                         color: statusColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   //        - inner box
//                   color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _timeColumn("Check In", checkIn, isDark: isDark),
//                     _timeColumn("Check Out", checkOut, isDark: isDark),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),
//               if (status.toLowerCase() == "pending") ...[
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: CommonButton(
//                     height: 30,
//                     color: const Color.fromARGB(255, 237, 89, 73),
//                     label: "Self Reject",
//                     onPressed: () {
//                       showModernDialog(
//                         type: DialogType.warning,
//                         context: context,
//                         title: "Reject Attendance",
//                         message: "Are you sure you want to reject this attendance record ?",
//                         confirmText: "Confirm",
//                         onConfirm: () {
//                           Navigator.of(context).pop();
//                           _selfRejectAttendance(item["Trans_Pk"].toString());
//                         },
//                       );
//                     },
//                     width: 121.7,
//                     icon: null,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }
//   //  AUTHORIZATION DATA
//   Widget _attAuthorizationData({bool isDark = false}) {
//     if (isAuthLoading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.blueGrey),
//       );
//     }
//     List filteredList = approvalList.where((item) {
//       if (selectedApprovalTab == 0) return item["Status"] == "Pending";
//       if (selectedApprovalTab == 1) return item["Status"] == "Approved";
//       return item["Status"] == "Rejected";
//     }).toList();
//     return Padding(
//       padding: const EdgeInsets.all(14),
//       child: Column(
//         children: [
//           companyDropdown(isDark: isDark),
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
//                     itemCount: filteredList.length,
//                     itemBuilder: (context, index) {
//                       final item = filteredList[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 16),
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           //        - authorization card
//                           color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
//                                       //
//                                       color: isDark ? Colors.white : null,
//                                     ),
//                                   ),
//                                 ),
//                                 _statusBadge(item["Status"]),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               "Date: ${item["AttendanceDate"] ?? ""}",
//                               style: AppTextStyles.labelMedium.copyWith(
//                                 //
//                                 color: isDark ? Colors.white70 : null,
//                               ),
//                             ),
//                             Text(
//                               "Reason: ${item["Reason"] ?? ""}",
//                               style: AppTextStyles.labelMedium.copyWith(
//                                 //
//                                 color: isDark ? Colors.white70 : null,
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Text(
//                                   "In: ${item["InTime"] ?? ""}",
//                                   style: AppTextStyles.labelSmall.copyWith(
//                                     //
//                                     color: isDark ? Colors.white54 : null,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 20),
//                                 Text(
//                                   "Out: ${item["OutTime"] ?? ""}",
//                                   style: AppTextStyles.labelSmall.copyWith(
//                                     //
//                                     color: isDark ? Colors.white54 : null,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             if (selectedApprovalTab == 0)
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 4),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     CommonButton(
//                                       width: 120,
//                                       icon: null,
//                                       height: 35,
//                                       color: Colors.green,
//                                       label: "Approve",
//                                       onPressed: () {
//                                         _approveOrRejectAttApp(
//                                           item["UP_PK"],
//                                           "Approved",
//                                         );
//                                       },
//                                     ),
//                                     const SizedBox(width: 10),
//                                     CommonButton(
//                                       icon: null,
//                                       width: 120,
//                                       height: 35,
//                                       color: const Color.fromARGB(255, 248, 74, 61),
//                                       label: "Reject",
//                                       onPressed: () {
//                                         _approveOrRejectAttApp(
//                                           item["UP_PK"],
//                                           "Rejected",
//                                         );
//                                       },
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
//   //  STATUS BADGE
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
//   //  COMPANY DROPDOWN
//   Widget companyDropdown({bool isDark = false}) {
//     return DropdownButtonFormField<String>(
//       value: selectedComp,
//       //        - dropdown styling
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
//           borderSide: BorderSide(
//             color: isDark ? Colors.white24 : Colors.grey,
//           ),
//         ),
//       ),
//       items: companyMap.keys.map((companyName) {
//         return DropdownMenuItem(
//           value: companyMap[companyName],
//           child: Text(
//             companyName,
//             style: TextStyle(color: isDark ? Colors.white : Colors.black),
//           ),
//         );
//       }).toList(),
//       onChanged: (value) {
//         setState(() => selectedComp = value);
//         _loadAttendanceApprovalList();
//         getEmployeeNameSearch(emppk);
//       },
//     );
//   }
//   //  EMPLOYEE SEARCH FIELD
//   Widget employeeSearchField({bool isDark = false}) {
//     return TextField(
//       controller: empNameController,
//       style: TextStyle(color: isDark ? Colors.white : null), //
//       decoration: InputDecoration(
//         hintText: "Search Employee",
//         hintStyle: TextStyle(color: isDark ? Colors.white38 : null), //
//         border: OutlineInputBorder(
//           borderSide: BorderSide(
//             color: isDark ? Colors.white24 : Colors.grey,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(
//             color: isDark ? Colors.white24 : Colors.grey,
//           ),
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
//   //  DISPOSE
//   @override
//   void dispose() {
//     _checkInController.dispose();
//     _checkOutController.dispose();
//     _reasonController.dispose();
//     super.dispose();
//   }
// //Clearing Filters on Authorization Tab
//   void _clearAuthorizationFilters() {
//     empNameController.clear();
//     selEmpCode = "";
//     searchEmp.clear();
//     if (companyMap.isNotEmpty) {
//       selectedComp = companyMap.values.first;
//     }
//     selectedApprovalTab = 0;
//   }
// }

//NEW UI
// ignore_for_file: use_build_context_synchronously, unused_local_variable, duplicate_ignore, deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/ds_color_handler.dart';
import 'package:new_design_demo/presentations/common_widgets/alert_box.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/presentations/common_widgets/common_timePicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

//  SCREEN

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  //  State
  int? emppk;
  String? empcode;
  int? companypk;
  int? locationpk;
  String? empname;
  int? isSuperAdmin;
  String? currentDtTime;

  List<dynamic> timeCardList = [];
  List<dynamic> attStatusList = [];
  List<dynamic> approvalList = [];
  bool isLoading = true;
  bool isAuthLoading = false;
  bool isAuthorizationScreen = false;
  int selectedTab = 0;
  int? expandedIndex;
  bool showAttAuthorization = false;
  String selectedApprovalStatus = "Pending";
  int selectedApprovalTab = 0;

  List<Map<String, dynamic>> users = [];
  Map<String, String> companyMap = {};
  String? selectedComp;
  List searchEmp = [];
  dynamic searchEmpData;
  TextEditingController empNameController = TextEditingController();
  String selEmpCode = "";

  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  //  Animation
  late final AnimationController _tabAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();
  late final Animation<double> _tabFade = CurvedAnimation(
    parent: _tabAnim,
    curve: Curves.easeOut,
  );

  //  LOGIC
  @override
  void initState() {
    super.initState();
    _methodLoader();
    _getPrefsData().then((_) => _loadAttendanceStatusList());
  }

  @override
  void dispose() {
    _checkInController.dispose();
    _checkOutController.dispose();
    _reasonController.dispose();
    empNameController.dispose();
    _tabAnim.dispose();
    super.dispose();
  }

  void _methodLoader() async {
    await getCompanyList();
    await fetchCurrentDate();
  }

  Future<void> _getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk = prefs.getInt("emppk");
    empcode = prefs.getString("employeecode");
    companypk = prefs.getInt("companypk");
    locationpk = prefs.getInt("locationpk");
    empname = prefs.getString("employeename");
    isSuperAdmin = int.tryParse(prefs.getString("issuperadmin") ?? "0") ?? 0;
    await _loadTimeCard();
  }

  Future<void> _loadAttendanceApprovalList() async {
    setState(() => isAuthLoading = true);
    const statuses = ["Pending", "Approved", "Rejected"];
    String status = statuses[selectedApprovalTab];
    try {
      final response = await ApiClient.post(
        ApiConstants.getAttendanceApprovalList,
        data: {
          "Emp_PK": emppk,
          "EmpCode": selEmpCode,
          "EmpName": empNameController.text,
          "Status": status,
          "AttDate": "",
          "approval": "",
          "CompanyGroupDBName":
              selectedComp ?? companyMap[companyMap.keys.first],
        },
      );
      final result = response.data["GetAttendaceAppApprovalListResult"];
      setState(() {
        approvalList = result != null ? List.from(result) : [];
      });
    } catch (e) {
      debugPrint("Approval Error: $e");
      setState(() => approvalList = []);
    }
    setState(() => isAuthLoading = false);
  }

  Future<void> _loadTimeCard() async {
    setState(() => isLoading = true);
    DateTime fdate = DateTime.now().subtract(const Duration(days: 32));
    DateTime ldate = DateTime.now();
    try {
      String startDate = DateFormat('dd/MM/yyyy').format(fdate);
      String endDate = DateFormat('dd/MM/yyyy').format(ldate);
      final response = await ApiClient.get(
        ApiConstants.getTimeCardData,
        query: {
          "Emp_PK": emppk,
          "strstartdate": startDate,
          "strendate": endDate,
        },
      );
      final result = response.data["GetTimeCardResult"];
      setState(() {
        timeCardList = result != null ? List.from(result) : [];
        timeCardList.sort((a, b) {
          DateTime dateA = DateFormat(
            "MM/dd/yyyy hh:mm:ss a",
          ).parse(a['scheduledate']);
          DateTime dateB = DateFormat(
            "MM/dd/yyyy hh:mm:ss a",
          ).parse(b['scheduledate']);
          return dateB.compareTo(dateA);
        });
      });
    } catch (e) {
      debugPrint("TimeCard Error: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _loadAttendanceStatusList() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiClient.get(
        ApiConstants.getAttendanceStatus,
        query: {"Emp_pk": emppk},
      );
      final result = response.data["GetAttendanceStatusResult"];
      setState(() {
        attStatusList = result != null ? List.from(result) : [];
        attStatusList.sort((a, b) {
          DateTime dateA = DateFormat(
            "MMM dd, yyyy",
          ).parse(a['AttendanceDate']);
          DateTime dateB = DateFormat(
            "MMM dd, yyyy",
          ).parse(b['AttendanceDate']);
          return dateB.compareTo(dateA);
        });
      });
    } catch (e) {
      debugPrint("History Error: $e");
      setState(() => attStatusList = []);
    }
    setState(() => isLoading = false);
  }

  Future<void> _submitAttApplicationTimecard(date) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.submitAttendanceApplication,
        data: {
          "Emp_PK": emppk.toString(),
          "InTime": _checkInController.text,
          "AttendanceDate": date,
          "OutTime": _checkOutController.text,
          "ApplicationDate": currentDtTime,
          "Reason": _reasonController.text,
        },
      );
      final result = response.data["AttendaceApplicationResult"];
      if (result.toString().toLowerCase().contains("success")) {
        CommonSnackBar.show(
          context: context,
          title: "Done",
          message: result,
          type: SnackBarType.success,
        );
        // String whatsappMessage =
        //     """Attendance Application :\n👤 Name: $empname\n📅 From: ${_checkInController.text}\n📅 To: ${_checkOutController.text}\n📊 Attendance Date: $date\n📝 Reason: ${_reasonController.text}\n📊 Application Date : $currentDtTime""";
        // try {
        //   await sendWhatsAppDirect(whatsappMessage);
        // } catch (e) {
        //   debugPrint("WhatsApp Error: $e");
        // }
        _checkInController.clear();
        _checkOutController.clear();
        _reasonController.clear();
        setState(() => expandedIndex = null);
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Warning",
          message: result,
          type: SnackBarType.warning,
        );
      }
      if (result.toString().toLowerCase().contains("fail")) {
        CommonSnackBar.show(
          context: context,
          title: "Failed",
          message: result,
          type: SnackBarType.error,
        );
      }
    } catch (ex) {
      CommonSnackBar.show(
        context: context,
        title: "Exception !",
        message: "$ex",
        type: SnackBarType.warning,
      );
    }
  }

  //Self Reject
  Future<void> _selfRejectAttendance(String transPk) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.selfRejectAttendance,
        data: {
          "Emp_PK": emppk.toString(),
          "Trans_Pk": transPk,
          "appliedby": "Android",
        },
      );
      final result = response.data["AttendanceSelfRejectResult"];
      if (result.toString().toLowerCase() == "application rejected" ||
          response.statusCode == 200) {
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: result,
          type: SnackBarType.success,
        );
        _loadAttendanceStatusList();
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Warning",
          message: result,
          type: SnackBarType.warning,
        );
      }
    } catch (e) {
      CommonSnackBar.show(
        context: context,
        title: "Error",
        message: "Exception: $e.",
        type: SnackBarType.error,
      );
    }
  }

  //Fetch Current Date
  Future<void> fetchCurrentDate() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getCurrentDate,
        query: {"Emp_pk": emppk},
      );
      final data = response.data["getSchedulerData"];
      if (data != null && data.isNotEmpty) {
        currentDtTime = data[0]["current_date"];
      }
    } catch (e) {
      debugPrint("fetchCurrentDate Error: $e");
    }
  }

  ///Approve or Reject the attendance Application.
  Future<void> _approveOrRejectAttApp(
    String upPk,
    String newStatus,
    empcode,
  ) async {
    try {
      final response = await ApiClient.post(
        ApiConstants.attendanceApplicationApproveORReject,
        data: {
          "InTime": "",
          "ApplicationDate": "",
          "Company_PK": "1", ////IN PS PRAVIN SENT 1
          "UP_PK": upPk,
          "Employee_Code": empcode,
          "OutTime": "",
          "Emp_PK": emppk.toString(),
          "Location_PK": locationpk,
          "TimeCard": "1", ////IN PS PRAVIN SENT 1
          "ApprovedReject": newStatus,
          "Reason": _reasonController.text,
          "AttendanceDate": "",
          "CompanyGroupDBName": selectedComp,
        },
      );

      if (response.statusCode == 200) {
        final result = response.data["ApprovedAttendaceApplicationResult"];
        CommonSnackBar.show(
          context: context,
          title: "Success",
          message: "$result",
          type: SnackBarType.success,
        );

        setState(() {
          _loadAttendanceApprovalList();
        });
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Error",
          message: "Failed to process request",
          type: SnackBarType.error,
        );
        debugPrint("Error Occurred during authorization att application");
      }
    } catch (exp) {
      debugPrint("Error to authorize attendace :  $exp");
    }
  }

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
      final List list = data["AutoCompleteData_LeaveReportingResult"];
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

  Future<void> getCompanyList() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getCompanyGroupList,
        query: {},
      );
      final data = response.data;
      if (data is List) {
        companyMap.clear();
        for (var item in data) {
          companyMap[item["Company_Name"].toString()] =
              item["CompanyGroupDBName"].toString();
        }
        selectedComp = companyMap.values.first;
        _loadAttendanceApprovalList();
      }
    } catch (e) {
      debugPrint("Company List Error: $e");
    }
  }

  void _clearAuthorizationFilters() {
    empNameController.clear();
    selEmpCode = "";
    searchEmp.clear();
    if (companyMap.isNotEmpty) selectedComp = companyMap.values.first;
    selectedApprovalTab = 0;
  }

  //  BUILD

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (isAuthorizationScreen) {
          setState(() {
            _clearAuthorizationFilters();
            isAuthorizationScreen = false;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? DS.surfaceDark : DS.surfaceLight,
        body: Column(
          children: [
            _header(isDark),
            if (!isAuthorizationScreen) ...[
              const SizedBox(height: 14),
              _tabRow(isDark),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: FadeTransition(
                opacity: _tabFade,
                child: isAuthorizationScreen
                    ? _attAuthorizationData(isDark: isDark)
                    : selectedTab == 0
                    ? _timeCardList(isDark: isDark)
                    : _attStatus(isDark: isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  PREMIUM HEADER
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
                  // Back / close
                  GestureDetector(
                    onTap: () {
                      if (isAuthorizationScreen) {
                        setState(() {
                          _clearAuthorizationFilters();
                          isAuthorizationScreen = false;
                        });
                      } else {
                        Navigator.pop(context);
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
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAuthorizationScreen
                                  ? "Attendance Auth."
                                  : "Attendance",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                              child: Text(
                                isAuthorizationScreen
                                    ? "Approve or Reject Requests"
                                    : "Track Your Attendance",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!isAuthorizationScreen)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isAuthorizationScreen = true;
                              _loadAttendanceApprovalList();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
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
                              children: const [
                                Icon(
                                  Icons.verified_user_rounded,
                                  color: DS.brandDeep,
                                  size: 17,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Authorization",
                                  style: TextStyle(
                                    color: DS.brandDeep,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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

  Widget _decorCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  //  PREMIUM TAB ROW
  Widget _tabRow(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? DS.cardDark : DS.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _tabPill("Time Card", 0, isDark),
            _tabPill("History", 1, isDark),
          ],
        ),
      ),
    );
  }

  Widget _tabPill(String label, int index, bool isDark) {
    final bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          setState(() {
            selectedTab = index;
            expandedIndex = null;
          });
          _tabAnim.forward(from: 0);
          if (index == 0) {
            await _loadTimeCard();
          } else {
            await _loadAttendanceStatusList();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [DS.brandStart, DS.brandDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: DS.brandStart.withOpacity(0.35),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.black38),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  //  AUTHORIZATION TABS
  Widget _authorizationTabs({bool isDark = false}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? DS.cardDark : DS.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _authPill("Pending", 0, isDark),
          _authPill("Approved", 1, isDark),
          _authPill("Rejected", 2, isDark),
        ],
      ),
    );
  }

  Widget _authPill(String label, int index, bool isDark) {
    final bool isSelected = selectedApprovalTab == index;
    final Color selColor = index == 0
        ? const Color(0xFFF59E0B)
        : index == 1
        ? DS.green1
        : const Color(0xFFEF4444);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedApprovalTab = index);
          _loadAttendanceApprovalList();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? selColor.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: selColor.withOpacity(0.4))
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? selColor
                  : (isDark ? Colors.white38 : Colors.black38),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  //  TIME CARD LIST
  Widget _timeCardList({bool isDark = false}) {
    if (isLoading) return _loadingState();
    if (timeCardList.isEmpty) {
      return _emptyState(
        "No Time Card Data Found",
        Icons.access_time_outlined,
        isDark,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: timeCardList.length,
      itemBuilder: (context, index) =>
          _timeCard(timeCardList[index], index, isDark: isDark),
    );
  }

  //  TIME CARD ITEM
  Widget _timeCard(dynamic item, int index, {bool isDark = false}) {
    String empStatus = item['empstatus'] ?? '';
    String date = item['scheduledateddmm'] ?? '';
    String checkIn = item['intiming'] == "-" ? "--:--" : item['intiming'];
    String checkOut = item['outtiming'] == "-" ? "--:--" : item['outtiming'];
    String totalHours = item['Totalwork'] == "0.0" ? "--" : item['Totalwork'];

    DateTime parsedDate = DateFormat("dd/MM/yyyy").parse(date);
    String weekday = DateFormat("EEEE").format(parsedDate);

    final _StatusInfo si = _statusInfo(empStatus);
    bool showRegularize =
        empStatus == "AB" ||
        (empStatus == "P" &&
            (item['intiming'] == "-" || item['outtiming'] == "-"));
    bool isExpanded = expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? DS.cardDark : DS.cardLight,
        borderRadius: BorderRadius.circular(DS.r20),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.30)
                : Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                // Date block
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: si.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: si.color.withOpacity(0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    parsedDate.day.toString(),
                    style: TextStyle(
                      color: si.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Weekday + date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                _statusBadge(si.label, si.color),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Time row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? DS.innerDark : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(DS.r12),
                border: Border.all(
                  color: isDark ? DS.borderDark : DS.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _timeColPremium(
                      "Check In",
                      checkIn,
                      DS.green1,
                      isDark,
                    ),
                  ),
                  _colDivider(isDark),
                  Expanded(
                    child: _timeColPremium(
                      "Check Out",
                      checkOut,
                      const Color(0xFFEF4444),
                      isDark,
                    ),
                  ),
                  _colDivider(isDark),
                  Expanded(
                    child: _timeColPremium(
                      "Total Hours",
                      totalHours,
                      const Color(0xFF3B82F6),
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Regularize button
          if (showRegularize && !isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: GestureDetector(
                onTap: () => setState(() => expandedIndex = index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [DS.brandStart, DS.brandDeep],
                    ),
                    borderRadius: BorderRadius.circular(DS.r12),
                    boxShadow: [
                      BoxShadow(
                        color: DS.brandStart.withOpacity(0.30),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_calendar_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Regularize Attendance",
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

          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _regularizeForm(index, date, isDark: isDark),
            ),
        ],
      ),
    );
  }

  Widget _colDivider(bool isDark) => Container(
    width: 1,
    height: 36,
    color: isDark ? Colors.white10 : Colors.black38,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );

  Widget _timeColPremium(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Container(
          width: 20,
          height: 2.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  //  REGULARIZE FORM
  Widget _regularizeForm(int index, String date, {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DS.innerDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(DS.r16),
        border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [DS.brandStart, DS.brandDeep],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Regularize Attendance",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _premiumTimeField("Check In Time", _checkInController, isDark),
          const SizedBox(height: 10),
          _premiumTimeField("Check Out Time", _checkOutController, isDark),
          const SizedBox(height: 10),
          _premiumTextField("Reason", _reasonController, isDark, maxLines: 2),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_reasonController.text.isEmpty ||
                        _checkInController.text.isEmpty ||
                        _checkOutController.text.isEmpty) {
                      CommonSnackBar.show(
                        context: context,
                        title: "All Fields Required",
                        message: "Please fill in all fields to submit.",
                        type: SnackBarType.warning,
                      );
                      return;
                    }
                    _submitAttApplicationTimecard(date);
                    setState(() {
                      expandedIndex = index;
                      _timeCardList(isDark: isDark);
                    });
                  },
                  child: _gradientBtn("Submit", Icons.send_rounded),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _checkInController.clear();
                    _checkOutController.clear();
                    _reasonController.clear();
                    expandedIndex = null;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black38,
                      borderRadius: BorderRadius.circular(DS.r12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          color: isDark ? Colors.white38 : Colors.black38,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Cancel",
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
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
    );
  }

  Widget _premiumTimeField(
    String label,
    TextEditingController ctrl,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 13,
      ),
      onTap: () => AppTimePicker.show(context: context, controller: ctrl),
      decoration: _fieldDecoration(
        label,
        isDark,
        suffix: Icons.access_time_rounded,
      ),
    );
  }

  Widget _premiumTextField(
    String label,
    TextEditingController ctrl,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: _fieldDecoration(label, isDark),
    );
  }

  InputDecoration _fieldDecoration(
    String label,
    bool isDark, {
    IconData? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 12,
      ),
      suffixIcon: suffix != null
          ? Icon(
              suffix,
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
  }

  Widget _gradientBtn(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
  }

  //  ATTENDANCE HISTORY
  Widget _attStatus({bool isDark = false}) {
    if (isLoading) return _loadingState();
    if (attStatusList.isEmpty) {
      return _emptyState("No History Found", Icons.history_outlined, isDark);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: attStatusList.length,
      itemBuilder: (context, index) {
        final item = attStatusList[index];
        String attDate = item['AttendanceDate'] ?? '';
        String checkIn = item['FromDate'] == "" ? "--:--" : item['FromDate'];
        String checkOut = item['ToDate'] == "" ? "--:--" : item['ToDate'];
        String status = item['Approval_Status'] ?? '';

        final _StatusInfo si = _approvalStatusInfo(status);

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
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: si.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: si.color.withOpacity(0.25)),
                      ),
                      child: Icon(si.icon, color: si.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        attDate,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _statusBadge(status, si.color),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? DS.borderDark : DS.borderLight,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _timeColPremium(
                        "Check In",
                        checkIn,
                        DS.green1,
                        isDark,
                      ),
                    ),
                    _colDivider(isDark),
                    Expanded(
                      child: _timeColPremium(
                        "Check Out",
                        checkOut,
                        const Color(0xFFEF4444),
                        isDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (status.toLowerCase() == "pending")
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: GestureDetector(
                    onTap: () => showModernDialog(
                      type: DialogType.warning,
                      context: context,
                      title: "Reject Attendance",
                      message: "Are you sure you want to reject this record?",
                      confirmText: "Confirm",
                      onConfirm: () {
                        Navigator.of(context).pop();
                        _selfRejectAttendance(item["Trans_Pk"].toString());
                      },
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(DS.r12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Color(0xFFEF4444),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "Self Reject",
                            style: TextStyle(
                              color: Color(0xFFEF4444),
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
        );
      },
    );
  }

  //  AUTHORIZATION DATA
  Widget _attAuthorizationData({bool isDark = false}) {
    if (isAuthLoading) return _loadingState();

    List filteredList = approvalList.where((item) {
      if (selectedApprovalTab == 0) return item["Status"] == "Pending";
      if (selectedApprovalTab == 1) return item["Status"] == "Approved";
      return item["Status"] == "Rejected";
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          companyDropdown(isDark: isDark),
          const SizedBox(height: 8),
          employeeSearchField(isDark: isDark),
          employeeSearchList(isDark: isDark),
          const SizedBox(height: 10),
          _authorizationTabs(isDark: isDark),
          const SizedBox(height: 12),
          Expanded(
            child: filteredList.isEmpty
                ? _emptyState(
                    "No Data Found",
                    Icons.assignment_ind_outlined,
                    isDark,
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final _StatusInfo si = _approvalStatusInfo(
                        item["Status"] ?? "",
                      );
                      return Container(
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
                                      item["EmpName"] ?? "",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  _statusBadge(item["Status"] ?? "", si.color),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: isDark ? DS.borderDark : DS.borderLight,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow(
                                    Icons.calendar_today_outlined,
                                    "Date",
                                    item["AttendanceDate"] ?? "",
                                    isDark,
                                  ),
                                  const SizedBox(height: 6),
                                  _infoRow(
                                    Icons.notes_rounded,
                                    "Reason",
                                    item["Reason"] ?? "",
                                    isDark,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _timeColPremium(
                                          "In Time",
                                          item["InTime"] ?? "--",
                                          DS.green1,
                                          isDark,
                                        ),
                                      ),
                                      _colDivider(isDark),
                                      Expanded(
                                        child: _timeColPremium(
                                          "Out Time",
                                          item["OutTime"] ?? "--",
                                          const Color(0xFFEF4444),
                                          isDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (selectedApprovalTab == 0)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _approveOrRejectAttApp(
                                          item["UP_PK"],
                                          "Approved",
                                          item["Employee_Code"],
                                        ),
                                        child: _gradientBtn(
                                          "Approve",
                                          Icons.check_circle_outline_rounded,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _approveOrRejectAttApp(
                                          item["UP_PK"],
                                          "Rejected",
                                          item["Employee_Code"],
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFEF4444,
                                            ).withOpacity(0.10),
                                            borderRadius: BorderRadius.circular(
                                              DS.r12,
                                            ),
                                            border: Border.all(
                                              color: const Color(
                                                0xFFEF4444,
                                              ).withOpacity(0.30),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.cancel_outlined,
                                                color: Color(0xFFEF4444),
                                                size: 16,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                "Reject",
                                                style: TextStyle(
                                                  color: Color(0xFFEF4444),
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
                              )
                            else
                              const SizedBox(height: 14),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  //  SHARED WIDGETS
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _loadingState() {
    return const Center(
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

  Widget _emptyState(String msg, IconData icon, bool isDark) {
    return Center(
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
  }

  //  COMPANY DROPDOWN
  Widget companyDropdown({bool isDark = false}) {
    return DropdownButtonFormField<String>(
      value: selectedComp,
      dropdownColor: isDark ? DS.cardDark : null,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: "Select Company",
        labelStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.business_outlined,
          color: isDark ? Colors.white38 : Colors.black38,
          size: 18,
        ),
        filled: true,
        fillColor: isDark ? DS.inputDark : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
      items: companyMap.keys
          .map(
            (name) => DropdownMenuItem(
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
      onChanged: (value) {
        setState(() => selectedComp = value);
        _loadAttendanceApprovalList();
        getEmployeeNameSearch(emppk);
      },
    );
  }

  //  EMPLOYEE SEARCH FIELD
  Widget employeeSearchField({bool isDark = false}) {
    return TextField(
      controller: empNameController,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: "Search Employee",
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.black26,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: isDark ? Colors.white38 : Colors.black38,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? DS.inputDark : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
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
      onChanged: (value) {
        selEmpCode = "";
        if (value.length >= 2) {
          getEmployeeNameSearch(emppk);
        } else {
          setState(() => searchEmp.clear());
        }
      },
    );
  }

  //  EMPLOYEE SEARCH LIST
  Widget employeeSearchList({bool isDark = false}) {
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
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
          itemBuilder: (context, index) {
            final emp = searchEmp[index];
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
  final String label;
  final Color color;
  final IconData icon;
  const _StatusInfo(this.label, this.color, this.icon);
}

_StatusInfo _statusInfo(String status) {
  switch (status) {
    case "P":
      return const _StatusInfo(
        "Present",
        Color(0xFF10B981),
        Icons.check_circle_outline_rounded,
      );
    case "AB":
      return const _StatusInfo(
        "Absent",
        Color(0xFFEF4444),
        Icons.cancel_outlined,
      );
    case "WO":
      return const _StatusInfo(
        "Week Off",
        Color(0xFF3B82F6),
        Icons.weekend_outlined,
      );
    case "PH":
      return const _StatusInfo(
        "Holiday",
        Color(0xFFF59E0B),
        Icons.celebration_outlined,
      );
    default:
      return _StatusInfo(
        status.isEmpty ? "—" : status,
        Colors.grey,
        Icons.help_outline,
      );
  }
}

_StatusInfo _approvalStatusInfo(String status) {
  switch (status.toLowerCase()) {
    case "approved":
      return const _StatusInfo(
        "Approved",
        Color(0xFF10B981),
        Icons.check_circle_outline_rounded,
      );
    case "rejected":
      return const _StatusInfo(
        "Rejected",
        Color(0xFFEF4444),
        Icons.cancel_outlined,
      );
    case "pending":
      return const _StatusInfo(
        "Pending",
        Color(0xFFF59E0B),
        Icons.hourglass_empty_rounded,
      );
    default:
      return const _StatusInfo("—", Colors.grey, Icons.help_outline);
  }
}
