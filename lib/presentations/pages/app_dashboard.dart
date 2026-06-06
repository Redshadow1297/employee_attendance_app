// // ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, unused_local_variable

// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show Uint8List;
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/app_services/PunchInOut/punch_controller.dart';
// import 'package:new_design_demo/core/app_services/app_permission_services.dart';
// import 'package:new_design_demo/core/app_services/auth_repo.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/core/constants/modulesconfig.dart';
// import 'package:new_design_demo/presentations/common_widgets/alert_box.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
// import 'package:new_design_demo/presentations/pages/QuickAcessMenusScreens/app_timecard_calendar.dart';
// import 'package:new_design_demo/presentations/pages/app_login.dart';
// import 'package:new_design_demo/presentations/pages/app_profile.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AppDashboardScreen extends StatefulWidget {
//   const AppDashboardScreen({super.key});

//   @override
//   State<AppDashboardScreen> createState() => _AppDashboardScreenState();
// }

// class _AppDashboardScreenState extends State<AppDashboardScreen> {
//   String liveDayDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

//   // ── User
//   String employeeCode = '';
//   String employeename = '';
//   String welcomeName = '';
//   String profilePhoto = '';
//   int? emppk;
//   int? loginiddetails;
//   int? companypk;
//   int? locationpk;
//   Map<String, dynamic>? loginDetails;
//   String? lastLoginTime;
//   bool hasNewWallPost = false;
//   Timer? _wallPostTimer;
//   late final imageProvider = _buildBase64Image(profilePhoto);

//   // ── Module list
//   List<dynamic> moduleList = [];
//   bool isLoadingModules = false;

//   // ── PUNCH CONTROLLER
//   late PunchController _punchController;

//   @override
//   void initState() {
//     super.initState();
//     _punchController = PunchController(
//       context: context,
//       onStateChanged: () {
//         if (mounted) setState(() {});
//       },
//       getOfflineRecords: () async {
//         return [];
//       },
//       deleteOfflineRecord: (int id) async {},
//       saveOfflineRecord: (record) async {},
//     );

//     _initDashboard();

//     _wallPostTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
//       fetchWallPostData();
//     });
//   }

//   //Initial dashboard loading with permission checks
//   Future<void> _initDashboard() async {
//     /// Check permissions first
//     bool isValid = await AppServices.validatePunchRequirements();

//     if (!isValid) {
//       if (mounted) {
//         CommonSnackBar.show(
//           context: context,
//           title: "Permission Required",
//           message: "Please enable Location, Internet and Notifications",
//           type: SnackBarType.warning,
//         );
//       }
//       return;
//     }
//     await _loadUserData();
//     await _punchController.loadUserPrefs();
//     // await TrackingService().initialize();

//     if (emppk != null) {
//       await _punchController.getTodaysAttendanceState(emppk: emppk!);
//       await _fetchModules();
//       await _fetchLastLoginDetails();
//       await fetchWallPostData();
//     }
//   }

//   ///Load user data
//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     employeeCode = prefs.getString('employeecode') ?? '';
//     employeename = prefs.getString('employeename') ?? '';
//     welcomeName = prefs.getString('welcomeName') ?? '';
//     profilePhoto = prefs.getString('profileImage') ?? '';
//     emppk = prefs.getInt('emppk');
//     loginiddetails = prefs.getInt('loginid');
//     companypk = prefs.getInt('companypk');
//     locationpk = prefs.getInt('locationpk');
//   }

//   //Module fetching
//   Future<void> _fetchModules() async {
//     try {
//       setState(() => isLoadingModules = true);
//       final response = await ApiClient.get(
//         ApiConstants.getUserModules,
//         query: {"Emp_PK": emppk},
//       );
//       setState(() {
//         moduleList = response.data["ModuleList"] ?? [];
//         isLoadingModules = false;
//       });
//     } catch (e) {
//       setState(() => isLoadingModules = false);
//       debugPrint("Module error: $e");
//     }
//   }

//   ////Last login Info
//   Future<void> _fetchLastLoginDetails() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getLastLoginDetails,
//         query: {"LoginId": loginiddetails},
//       );
//       if (response.data is List && (response.data as List).isNotEmpty) {
//         setState(() {
//           loginDetails = response.data[0];
//           lastLoginTime = loginDetails?['LogDateTime'];
//         });
//       }
//     } catch (ex) {
//       debugPrint("LastLogin error: $ex");
//     }
//   }

//   ///Fetch Wall post data for checking any new notice is arrived  or not
//   Future<void> fetchWallPostData() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getWallPosts,
//         query: {"Emp_PK": emppk},
//       );

//       if (response.data is List) {
//         List<dynamic> wallPosts = response.data;

//         int newPostsCount = wallPosts
//             .where((post) => post['IsNew'] == true)
//             .length;

//         if (mounted) {
//           setState(() {
//             hasNewWallPost = newPostsCount > 0;
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Wall post error: $e");
//     }
//   }

//   // ── MODULE MAPPING ─────────────────────────────────────────
//   final Map<int, ModuleUIConfig> moduleUIMap = {
//     1: ModuleUIConfig(
//       icon: Icons.forum_outlined,
//       iconColor: Colors.lightBlueAccent,
//       iconBgColor: Color(0xFFE3F2FD),
//       subtitle: "Team updates",
//       route: "/wallpost",
//     ),
//     2: ModuleUIConfig(
//       icon: Icons.calendar_today_outlined,
//       iconColor: Colors.greenAccent,
//       iconBgColor: Color(0xFFE8F5E9),
//       subtitle: "Manage Your Leaves",
//       route: "/leave",
//     ),
//     3: ModuleUIConfig(
//       icon: Icons.description_outlined,
//       iconColor: Colors.deepOrangeAccent,
//       iconBgColor: Color(0xFFFFF3E0),
//       subtitle: "Track attendance",
//       route: "/attendance",
//     ),
//     5: ModuleUIConfig(
//       icon: Icons.receipt_long_outlined,
//       iconColor: Colors.purpleAccent,
//       iconBgColor: Color(0xFFF3E5F5),
//       subtitle: "View Payslips",
//       route: "/payslip",
//     ),
//     13: ModuleUIConfig(
//       icon: Icons.location_on_outlined,
//       iconColor: Colors.tealAccent,
//       iconBgColor: Color(0xFFE0F7FA),
//       subtitle: "Employee Tracking",
//       route: "/employeeTracking",
//     ),
//     18: ModuleUIConfig(
//       icon: Icons.fact_check_outlined,
//       iconColor: Colors.blueGrey,
//       iconBgColor: Color(0xFFECEFF1),
//       subtitle: "Supervisor Attendance",
//       route: "/supervisorAttendance",
//     ),
//     17: ModuleUIConfig(
//       icon: Icons.attach_money_outlined,
//       iconColor: Colors.greenAccent,
//       iconBgColor: const Color.fromARGB(255, 216, 112, 234).withOpacity(0.1),
//       subtitle: "Advance Management",
//       route: "/advance",
//     ),
//     19: ModuleUIConfig(
//       icon: Icons.assignment_outlined,
//       iconColor: Colors.indigoAccent,
//       iconBgColor: Color(0xFFE8EAF6),
//       subtitle: "Visit Report",
//       route: "/visitreport",
//     ),
//     20: ModuleUIConfig(
//       icon: Icons.badge_outlined,
//       iconColor: Colors.redAccent,
//       iconBgColor: Color(0xFFFFEBEE),
//       subtitle: "Visitor Management",
//       route: "/visitorManagement",
//     ),
//     29: ModuleUIConfig(
//       icon: Icons.request_quote_outlined,
//       iconColor: Colors.tealAccent,
//       iconBgColor: Color(0xFFE0F7FA),
//       subtitle: "ReImbursement",
//       route: "/reimbursement",
//     ),
//     16: ModuleUIConfig(
//       icon: Icons.directions_car_outlined,
//       iconColor: Colors.orangeAccent,
//       iconBgColor: Color(0xFFFFF8E1),
//       subtitle: "Vehicle Requisition",
//       route: "/vehicleRequisition",
//     ),
//   };

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return WillPopScope(
//       onWillPop: () async => true,
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(220),
//           child: Container(
//             padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 // colors: [Color(0xFFC9A646), Color(0xFFDBA717)],
//                 colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
//                 // colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
//               ),
//               borderRadius: BorderRadius.circular(18),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Profile + name
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () => Navigator.of(context).push(
//                             MaterialPageRoute(builder: (_) => ProfileScreen()),
//                           ),
//                           child: CircleAvatar(
//                             radius: 30,
//                             backgroundColor: Colors.white,
//                             child: null,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               welcomeName.isNotEmpty
//                                   ? welcomeName
//                                   : "Employee Name",
//                               style: AppTextStyles.headingMedium.copyWith(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Text(
//                               employeeCode.isNotEmpty
//                                   ? "Code: $employeeCode"
//                                   : "Employee Code",
//                               style: AppTextStyles.labelMedium.copyWith(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     // Actions
//                     Row(
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               hasNewWallPost = false;
//                             });

//                             Navigator.pushNamed(context, "/wallpost");
//                           },
//                           child: Stack(
//                             clipBehavior: Clip.none,
//                             children: [
//                               _circleIcon(Icons.notifications_none),

//                               if (hasNewWallPost)
//                                 Positioned(
//                                   right: 0,
//                                   top: 0,
//                                   child: Container(
//                                     width: 12,
//                                     height: 12,
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                       shape: BoxShape.circle,
//                                       border: Border.all(
//                                         color: Colors.white,
//                                         width: 2,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         InkWell(
//                           child: Center(child: _circleIcon(Icons.logout)),
//                           onTap: () {
//                             showModernDialog(
//                               type: DialogType.warning,
//                               context: context,
//                               title: "Signout !",
//                               message: "Are You Sure To Sign Out",
//                               confirmText: "Sign Out",
//                               onConfirm: () async {
//                                 await AuthRepo.saveLoginStatus(false);
//                                 Navigator.of(context).pushAndRemoveUntil(
//                                   MaterialPageRoute(
//                                     builder: (_) => const LoginScreen(),
//                                   ),
//                                   (route) => false,
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   liveDayDate,
//                   style: AppTextStyles.labelSmall.copyWith(
//                     color: Colors.white70,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   "Welcome Back!",
//                   style: AppTextStyles.headingMedium.copyWith(
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Expanded(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Last Login : $lastLoginTime",
//                         style: AppTextStyles.labelSmall.copyWith(
//                           color: const Color.fromARGB(255, 218, 214, 214),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _timeInOutCard(),
//               _leaveBalanceCard(),
//               _quickAccessElement(),
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
//                 child: Text(
//                   "Quick Access",
//                   style: AppTextStyles.labelSmall.copyWith(
//                     //
//                     color: isDark ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               //     isDark pass kela
//               _moduleGrid(isDark: isDark),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   //  PUNCH IN/OUT CARD
//   Widget _timeInOutCard() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final String inTimeDisplay = _punchController.inTimeVal.isNotEmpty
//         ? _punchController.inTimeVal
//         : "--:--";

//     final String outTimeDisplay = _punchController.outTimeVal.isNotEmpty
//         ? _punchController.outTimeVal
//         : "--:--";

//     final bool isCheckedIn =
//         _punchController.inTimeVal.isNotEmpty &&
//         _punchController.outTimeVal.isEmpty;

//     final bool isLoading = _punchController.isPunchLoading;
//     final bool isCheckedOut = _punchController.outTimeVal.isNotEmpty;

//     final Color actionColor = isCheckedIn ? Colors.red : Colors.green;

//     String statusText = "";
//     Color statusColor = Colors.blue;

//     //Showing time progress  like lunch break, tea break based on time and punch status
//     // final now = DateTime.now();
//     // final currentHour = now.hour;
//     // final currentMinute = now.minute;
//     // final currentTime = currentHour + (currentMinute / 60);
//     // if (currentTime >= 13 && currentTime < 14) {
//     //   statusText = "Lunch Break";
//     //   statusColor = Colors.orange;
//     // } else if (currentTime >= 16 && currentTime < 16.5) {
//     //   statusText = "Tea Break";
//     //   statusColor = Colors.brown;
//     // } else if (isCheckedOut) {
//     //   statusText = "Checked Out";
//     //   statusColor = Colors.red;
//     // } else if (isCheckedIn) {
//     //   statusText = "Working";
//     //   statusColor = Colors.green;
//     // } else {
//     //   statusText = "Not Checked In";
//     //   statusColor = Colors.grey;
//     // }

//     return Container(
//       margin: const EdgeInsets.fromLTRB(3, 10, 3, 12),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(18),
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: isDark
//               ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
//               : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
//         ),
//         border: Border.all(
//           color: isDark ? Colors.white10 : Colors.grey.shade200,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: isDark
//                 ? Colors.black.withOpacity(0.30)
//                 : Colors.grey.withOpacity(0.15),
//             blurRadius: 14,
//             spreadRadius: 1,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 12,
//                 height: 12,
//                 decoration: BoxDecoration(
//                   color: statusColor,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 statusText,
//                 style: AppTextStyles.labelMedium.copyWith(
//                   color: isDark ? Colors.white : Colors.black87,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               if (isLoading)
//                 const SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           GestureDetector(
//             onTap: isLoading
//                 ? null
//                 : () async {
//                     await _punchController.onPunchTapped(
//                       isPunchIn: !isCheckedIn,
//                     );

//                     await Future.delayed(const Duration(milliseconds: 1500));

//                     await _punchController.getTodaysAttendanceState(
//                       emppk: emppk!,
//                     );

//                     if (mounted) {
//                       setState(() {});
//                     }
//                   },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: actionColor.withOpacity(0.15),
//                 border: Border.all(color: actionColor, width: 3),
//                 boxShadow: [
//                   BoxShadow(
//                     color: actionColor.withOpacity(0.35),
//                     blurRadius: 18,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: Icon(Icons.fingerprint, size: 52, color: actionColor),
//             ),
//           ),

//           const SizedBox(height: 22),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 children: [
//                   Text(
//                     "Check In",
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: Colors.green,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     inTimeDisplay,
//                     style: AppTextStyles.headingSmall.copyWith(
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 width: 1,
//                 height: 40,
//                 color: isDark ? Colors.white24 : Colors.black12,
//               ),
//               Column(
//                 children: [
//                   Text(
//                     "Check Out",
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: Colors.red,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     outTimeDisplay,
//                     style: AppTextStyles.headingSmall.copyWith(
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 18),
//           // _attendanceStatusBar(isCheckedIn, isCheckedOut),
//         ],
//       ),
//     );
//   }

//   //  ATTENDANCE STATUS BAR //// Progress Bar for check in, lunch, tea and check out status
//   // Widget _attendanceStatusBar(bool isCheckedIn, bool isCheckedOut) {
//   //   final now = DateTime.now();
//   //   final currentTime = now.hour + (now.minute / 60);
//   //   final bool checkInActive = isCheckedIn || isCheckedOut;
//   //   final bool lunchActive = checkInActive && currentTime >= 13;
//   //   final bool teaActive = checkInActive && currentTime >= 16;
//   //   final bool checkOutActive = isCheckedOut;
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       _statusDot(
//   //         title: "Check In",
//   //         icon: Icons.login,
//   //         color: checkInActive ? Colors.green : Colors.grey,
//   //         active: checkInActive,
//   //       ),
//   //       Expanded(child: Divider(color: Colors.white24)),
//   //       _statusDot(
//   //         title: "1-2 Lunch",
//   //         icon: Icons.lunch_dining,
//   //         color: lunchActive ? Colors.orange : Colors.grey,
//   //         active: lunchActive,
//   //       ),
//   //       Expanded(child: Divider(color: Colors.white24)),
//   //       _statusDot(
//   //         title: "4-4:30 Tea",
//   //         icon: Icons.coffee,
//   //         color: teaActive ? Colors.blue : Colors.grey,
//   //         active: teaActive,
//   //       ),
//   //       Expanded(child: Divider(color: Colors.white24)),
//   //       _statusDot(
//   //         title: "Check Out",
//   //         icon: Icons.logout,
//   //         color: checkOutActive ? Colors.red : Colors.grey,
//   //         active: checkOutActive,
//   //       ),
//   //     ],
//   //   );
//   // }

//   // //  STATUS DOT
//   // Widget _statusDot({
//   //   required String title,
//   //   required IconData icon,
//   //   required Color color,
//   //   required bool active,
//   // }) {
//   //   final isDark = Theme.of(context).brightness == Brightness.dark;
//   //   return Column(
//   //     children: [
//   //       AnimatedContainer(
//   //         duration: const Duration(milliseconds: 400),
//   //         width: active ? 52 : 42,
//   //         height: active ? 52 : 42,
//   //         decoration: BoxDecoration(
//   //           color: active
//   //               ? color.withOpacity(0.18)
//   //               : (isDark ? Colors.white10 : Colors.grey.shade100),
//   //           shape: BoxShape.circle,
//   //           border: Border.all(color: color, width: active ? 2.5 : 0.7),
//   //           boxShadow: active
//   //               ? [
//   //                   BoxShadow(
//   //                     color: color.withOpacity(0.35),
//   //                     blurRadius: 10,
//   //                     spreadRadius: 1,
//   //                   ),
//   //                 ]
//   //               : [],
//   //         ),
//   //         child: Icon(icon, color: color, size: active ? 22 : 16),
//   //       ),
//   //       const SizedBox(height: 6),
//   //       SizedBox(
//   //         width: 70,
//   //         child: Text(
//   //           title,
//   //           textAlign: TextAlign.center,
//   //           style: TextStyle(
//   //             color: isDark ? Colors.white : Colors.black87,
//   //             fontSize: 10,
//   //             fontWeight: FontWeight.w500,
//   //           ),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   //  MODULE GRID
//   Widget _moduleGrid({required bool isDark}) {
//     if (isLoadingModules) {
//       return const Padding(
//         padding: EdgeInsets.all(20),
//         child: Center(child: CircularProgressIndicator(color: Colors.blueGrey)),
//       );
//     }
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: moduleList.length,
//       gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
//         maxCrossAxisExtent: 190,
//         crossAxisSpacing: 20,
//         mainAxisSpacing: 20,
//         childAspectRatio: 1 / 1.2,
//       ),
//       itemBuilder: (context, index) {
//         final module = moduleList[index];
//         final int pk = module["Module_PK"];
//         final config = moduleUIMap[pk];

//         return GestureDetector(
//           onTap: () {
//             if (config != null) Navigator.pushNamed(context, config.route);
//           },
//           child: Align(
//             child: Container(
//               width: 173,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 //          - card background
//                 color: isDark ? const Color(0xFF1E293B) : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     //          - shadow
//                     color: isDark
//                         ? Colors.black.withOpacity(0.4)
//                         : Colors.black12,
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       //          - icon background
//                       color: isDark
//                           ? (config?.iconColor ?? Colors.blueAccent)
//                                 .withOpacity(0.15)
//                           : (config?.iconBgColor ?? Colors.grey.shade200),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       config?.icon ?? Icons.help_outline,
//                       size: 24,
//                       //          - icon color stays vibrant in both
//                       color: config?.iconColor ?? Colors.blueAccent,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     module["Module_Name"],
//                     style: AppTextStyles.headingSmall.copyWith(
//                       //          - module name
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     config?.subtitle ?? "",
//                     style: AppTextStyles.labelSmall.copyWith(
//                       //          - subtitle
//                       color: isDark ? Colors.white54 : Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   //  HELPERS
//   ImageProvider<Object> _buildBase64Image(String base64String) {
//     try {
//       Uint8List bytes = base64Decode(base64String);
//       return MemoryImage(bytes);
//     } catch (_) {
//       return const AssetImage('assets/placeholder.png');
//     }
//   }

//   ///Leave Balance Card
//   Widget _leaveBalanceCard() {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final double totalLeaves = 24;
//     final double usedLeaves = 10;
//     final double remainingLeaves = totalLeaves - usedLeaves;
//     final double progress = usedLeaves / totalLeaves;

//     return Container(
//       margin: const EdgeInsets.fromLTRB(6, 0, 6, 16),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E293B) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: isDark ? Colors.black.withOpacity(0.35) : Colors.black12,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Icon(Icons.event_available, color: Colors.green),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   "Leave Balance",
//                   style: AppTextStyles.headingSmall.copyWith(
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//               ),
//               Text(
//                 "$remainingLeaves Days",
//                 style: AppTextStyles.headingSmall.copyWith(
//                   color: Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 18),

//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: LinearProgressIndicator(
//               value: progress,
//               minHeight: 10,
//               backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//             ),
//           ),

//           const SizedBox(height: 14),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _leaveStat(
//                 "Used",
//                 usedLeaves.toInt().toString(),
//                 Colors.orange,
//                 isDark,
//               ),
//               _leaveStat(
//                 "Remaining",
//                 remainingLeaves.toInt().toString(),
//                 Colors.green,
//                 isDark,
//               ),
//               _leaveStat(
//                 "Total",
//                 totalLeaves.toInt().toString(),
//                 Colors.blue,
//                 isDark,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   //Helper for leave balance card
//   Widget _leaveStat(String title, String value, Color color, bool isDark) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             color: color,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title,
//           style: TextStyle(
//             color: isDark ? Colors.white60 : Colors.grey,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _circleIcon(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.15),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(icon, color: Colors.white, size: 20),
//     );
//   }

//   //Quick Access  (Optional Development)
//   Widget _quickAccessElement() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(8, 0, 8, 14),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _quickAccessIcon(
//                 Icons.calendar_today,
//                 "My Calendar",
//                 Colors.orangeAccent,
//                 () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const MyCalendarScreen(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(width: 20),
//               _quickAccessIcon(
//                 Icons.notifications,
//                 "Team Updates",
//                 Colors.blueAccent,
//                 () {
//                   Navigator.of(context).pushNamed("/wallpost");
//                 },
//               ),
//               const SizedBox(width: 20),
//               _quickAccessIcon(
//                 Icons.group_outlined,
//                 "Team Members",
//                 const Color.fromARGB(255, 32, 149, 19),
//                 () {
//                  CommonSnackBar.show(
//                     context: context,
//                     title: "Sorry",
//                     message: "Development Under Progress !",
//                     type: SnackBarType.warning,
//                   );
//                 },
//               ),
//               const SizedBox(width: 20),
//               _quickAccessIcon(
//                 Icons.phone_outlined,
//                 "Contact HR",
//                 const Color.fromARGB(255, 19, 142, 149),
//                 () {
//                  CommonSnackBar.show(
//                     context: context,
//                     title: "Sorry",
//                     message: "Development Under Progress !",
//                     type: SnackBarType.warning,
//                   );
//                 },
//               ),
//               const SizedBox(width: 20),
//               _quickAccessIcon(
//                 Icons.group_outlined,
//                 "Reports & Analytics",
//                 const Color.fromARGB(255, 149, 19, 125),
//                 () {
//                  CommonSnackBar.show(
//                     context: context,
//                     title: "Sorry",
//                     message: "Development Under Progress !",
//                     type: SnackBarType.warning,
//                   );
//                 },
//               ),
//               const SizedBox(width: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   //Helper Quick Access Icons
//   Widget _quickAccessIcon(
//     IconData quickAccessIcon,
//     String quickAccessLabel,
//     Color color,
//     VoidCallback onSelect,
//   ) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: onSelect,
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(quickAccessIcon, color: color, size: 24),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           quickAccessLabel,
//           style: AppTextStyles.labelSmall.copyWith(color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   //Dispose
//   @override
//   void dispose() {
//     _wallPostTimer?.cancel();
//     super.dispose();
//   }
// }

// NEW UI????
// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Uint8List, SystemNavigator;
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/app_services/PunchInOut/punch_controller.dart';
import 'package:new_design_demo/core/app_services/app_permission_services.dart';
import 'package:new_design_demo/core/app_services/auth_repo.dart';
import 'package:new_design_demo/core/constants/modulesconfig.dart';
import 'package:new_design_demo/presentations/common_widgets/alert_box.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/presentations/pages/QuickAcessMenusScreens/app_timecard_calendar.dart';
import 'package:new_design_demo/presentations/pages/app_login.dart';
import 'package:new_design_demo/presentations/pages/app_profile.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  PREMIUM DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _DS {
  // Brand teal gradient (kept from original)
  static const Color brandStart = Color(0xFF14B8A6);
  // static const Color brandEnd    = Color(0xFF0D9488);
  // static const Color brandDeep   = Color(0xFF0F766E);

  // Accent
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentBlue = Color(0xFF3B82F6);

  // Surface – light
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Surface – dark
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  // static const Color cardDark2       = Color(0xFF263244);
  static const Color borderDark = Color(0xFF334155);

  // Radius
  // static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;

  // Header height
  static const double headerHeight = 230;
}

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class AppDashboardScreen extends StatefulWidget {
  const AppDashboardScreen({super.key});

  @override
  State<AppDashboardScreen> createState() => _AppDashboardScreenState();
}

class _AppDashboardScreenState extends State<AppDashboardScreen>
    with TickerProviderStateMixin {
  // ── Date
  String liveDayDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  String employeeCode = '';
  String employeename = '';
  String welcomeName = '';
  String profilePhoto = '';
  int? emppk;
  int? loginiddetails;
  int? companypk;
  int? locationpk;
  Map<String, dynamic>? loginDetails;
  String? lastLoginTime;
  bool hasNewWallPost = false;
  Timer? _wallPostTimer;
  late final imageProvider = _buildBase64Image(profilePhoto);
  List<dynamic> moduleList = [];
  bool isLoadingModules = false;

  late PunchController _punchController;

  // ── Animation controllers
  AnimationController? _headerAnim;
  AnimationController? _pulseAnim;
  Animation<double>? _headerFade;
  Animation<Offset>? _headerSlide;
  Animation<double>? _pulseScale;

  // ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    // Header entrance
    final headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _headerAnim = headerCtrl;
    _headerFade = CurvedAnimation(parent: headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: headerCtrl, curve: Curves.easeOut));

    // Pulse ring on punch button
    final pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = pulseCtrl;
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut));

    _punchController = PunchController(
      context: context,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      getOfflineRecords: () async => [],
      deleteOfflineRecord: (int id) async {},
      saveOfflineRecord: (record) async {},
    );

    _initDashboard();

    _wallPostTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchWallPostData();
    });
  }

  @override
  void dispose() {
    _headerAnim?.dispose();
    _pulseAnim?.dispose();
    _wallPostTimer?.cancel();
    super.dispose();
  }

  //InitDashboard
  Future<void> _initDashboard() async {
    bool isValid = await AppServices.validatePunchRequirements();
    if (!isValid) {
      if (mounted) {
        CommonSnackBar.show(
          context: context,
          title: "Permission Required",
          message: "Please enable Location, Internet and Notifications",
          type: SnackBarType.warning,
        );
      }
      return;
    }
    await _loadUserData();
    await _punchController.loadUserPrefs();
    if (emppk != null) {
      await _punchController.getTodaysAttendanceState(emppk: emppk!);
      await _fetchModules();
      await _fetchLastLoginDetails();
      await fetchWallPostData();
    }
  }

  //Prefs Data
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeCode = prefs.getString('employeecode') ?? '';
      employeename = prefs.getString('employeename') ?? '';
      welcomeName = prefs.getString('welcomeName') ?? '';
      profilePhoto = prefs.getString('profileImage') ?? '';
      emppk = prefs.getInt('emppk');
      loginiddetails = prefs.getInt('loginid');
      companypk = prefs.getInt('companypk');
      locationpk = prefs.getInt('locationpk');
    });
  }

  ///Fetch Modules
  Future<void> _fetchModules() async {
    try {
      setState(() => isLoadingModules = true);
      final response = await ApiClient.get(
        ApiConstants.getUserModules,
        query: {"Emp_PK": emppk},
      );
      setState(() {
        moduleList = response.data["ModuleList"] ?? [];
        isLoadingModules = false;
      });
    } catch (e) {
      setState(() => isLoadingModules = false);
    }
  }

  //Last Login Details
  Future<void> _fetchLastLoginDetails() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getLastLoginDetails,
        query: {"LoginId": loginiddetails},
      );
      if (response.data is List && (response.data as List).isNotEmpty) {
        setState(() {
          loginDetails = response.data[0];
          lastLoginTime = loginDetails?['LogDateTime'];
        });
      }
    } catch (_) {}
  }

  //Wallpost data
  Future<void> fetchWallPostData() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getWallPosts,
        query: {"Emp_PK": emppk},
      );
      if (response.data is List) {
        final count = (response.data as List)
            .where((p) => p['IsNew'] == true)
            .length;
        if (mounted) setState(() => hasNewWallPost = count > 0);
      }
    } catch (_) {}
  }


  // ── MODULE MAP
  final Map<int, ModuleUIConfig> moduleUIMap = {
    1: ModuleUIConfig(
      icon: Icons.forum_outlined,
      iconColor: Colors.lightBlueAccent,
      iconBgColor: Color(0xFFE3F2FD),
      subtitle: "Team updates",
      route: "/wallpost",
    ),
    2: ModuleUIConfig(
      icon: Icons.calendar_today_outlined,
      iconColor: Colors.greenAccent,
      iconBgColor: Color(0xFFE8F5E9),
      subtitle: "Manage Your Leaves",
      route: "/leave",
    ),
    3: ModuleUIConfig(
      icon: Icons.description_outlined,
      iconColor: Colors.deepOrangeAccent,
      iconBgColor: Color(0xFFFFF3E0),
      subtitle: "Track attendance",
      route: "/attendance",
    ),
    5: ModuleUIConfig(
      icon: Icons.receipt_long_outlined,
      iconColor: Colors.purpleAccent,
      iconBgColor: Color(0xFFF3E5F5),
      subtitle: "View Payslips",
      route: "/payslip",
    ),
    13: ModuleUIConfig(
      icon: Icons.location_on_outlined,
      iconColor: Colors.tealAccent,
      iconBgColor: Color(0xFFE0F7FA),
      subtitle: "Employee Tracking",
      route: "/employeeTracking",
    ),
    18: ModuleUIConfig(
      icon: Icons.fact_check_outlined,
      iconColor: Colors.blueGrey,
      iconBgColor: Color(0xFFECEFF1),
      subtitle: "Supervisor Attendance",
      route: "/supervisorAttendance",
    ),
    17: ModuleUIConfig(
      icon: Icons.attach_money_outlined,
      iconColor: Colors.greenAccent,
      iconBgColor: Color(0xFFF3E5F5),
      subtitle: "Advance Management",
      route: "/advance",
    ),
    19: ModuleUIConfig(
      icon: Icons.assignment_outlined,
      iconColor: Colors.indigoAccent,
      iconBgColor: Color(0xFFE8EAF6),
      subtitle: "Visit Report",
      route: "/visitreport",
    ),
    15: ModuleUIConfig(
      icon: Icons.badge_outlined,
      iconColor: Colors.redAccent,
      iconBgColor: Color(0xFFFFEBEE),
      subtitle: "Visitor Management",
      route: "/visitorManagement",
    ),
    29: ModuleUIConfig(
      icon: Icons.request_quote_outlined,
      iconColor: Colors.tealAccent,
      iconBgColor: Color(0xFFE0F7FA),
      subtitle: "ReImbursement",
      route: "/reimbursement",
    ),
    16: ModuleUIConfig(
      icon: Icons.directions_car_outlined,
      iconColor: Colors.orangeAccent,
      iconBgColor: Color(0xFFFFF8E1),
      subtitle: "Vehicle Requisition",
      route: "/vehicleRequisition",
    ),
  };

  // ─────────────────────────────────────────────────────────
  //  BUILD

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop(); // app minimize/close
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark ? _DS.surfaceDark : _DS.surfaceLight,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── HEADER
            SliverPersistentHeader(
              pinned: true,
              delegate: _PremiumHeaderDelegate(
                minHeight: 80,
                maxHeight: _DS.headerHeight,
                child: _buildHeader(isDark),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _timeInOutCard(isDark),
                    const SizedBox(height: 16),
                    _leaveBalanceCard(isDark),
                    const SizedBox(height: 20),
                    _quickAccessSection(isDark),
                    const SizedBox(height: 20),
                    _sectionLabel("All Modules", isDark),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── MODULE GRID
            _moduleGridSliver(isDark),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  HEADER


  Widget _buildHeader(bool isDark) {
    return FadeTransition(
      opacity: _headerFade ?? const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _headerSlide ?? const AlwaysStoppedAnimation(Offset.zero),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF14B8A6), Color(0xFF0D9488), Color(0xFF0F766E)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles (depth)
              Positioned(
                right: -40,
                top: -40,
                child: _decorCircle(180, Colors.white.withOpacity(0.06)),
              ),
              Positioned(
                right: 60,
                top: 20,
                child: _decorCircle(90, Colors.white.withOpacity(0.04)),
              ),
              Positioned(
                left: -30,
                bottom: -20,
                child: _decorCircle(130, Colors.white.withOpacity(0.04)),
              ),

              // Content
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProfileScreen(),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white38,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.white24,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Name / code
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  welcomeName.isNotEmpty
                                      ? welcomeName
                                      : "Employee Name",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    employeeCode.isNotEmpty
                                        ? "# $employeeCode"
                                        : "Code —",
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

                          // Actions
                          _headerAction(
                            icon: Icons.notifications_outlined,
                            badge: hasNewWallPost,
                            onTap: () {
                              setState(() => hasNewWallPost = false);
                              Navigator.pushNamed(context, "/wallpost");
                            },
                          ),
                          const SizedBox(width: 8),
                          _headerAction(
                            icon: Icons.power_settings_new_rounded,
                            onTap: () {
                              showModernDialog(
                                type: DialogType.warning,
                                context: context,
                                title: "Sign Out",
                                message: "Are you sure you want to sign out?",
                                confirmText: "Sign Out",
                                onConfirm: () async {
                                  await AuthRepo.saveLoginStatus(false);
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (r) => false,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Greeting
                      const Text(
                        "Good day!  👋",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Date + last login
                      Row(
                        children: [
                          _headerChip(Icons.today_outlined, liveDayDate),
                          const SizedBox(width: 8),
                          if (lastLoginTime != null)
                            _headerChip(
                              Icons.access_time_outlined,
                              "Last: $lastLoginTime",
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _headerAction({
    required IconData icon,
    bool badge = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
          if (badge)
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: _DS.accentRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SECTION LABEL


  Widget _sectionLabel(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _DS.brandStart,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  PUNCH IN/OUT CARD

  
  Widget _timeInOutCard(bool isDark) {
    final String inTimeDisplay = _punchController.inTimeVal.isNotEmpty
        ? _punchController.inTimeVal
        : "--:--";
    final String outTimeDisplay = _punchController.outTimeVal.isNotEmpty
        ? _punchController.outTimeVal
        : "--:--";
    final bool isCheckedIn =
        _punchController.inTimeVal.isNotEmpty &&
        _punchController.outTimeVal.isEmpty;
    final bool isCheckedOut = _punchController.outTimeVal.isNotEmpty;
    final bool isLoading = _punchController.isPunchLoading;
    final Color actionColor = isCheckedIn ? _DS.accentRed : _DS.accentGreen;
    final String actionLabel = isCheckedIn
        ? "Long press to Check Out"
        : "Long press to Check In";

    return _premiumCard(
      isDark: isDark,
      child: Column(
        children: [
          // Status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusPill(isCheckedIn, isCheckedOut),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _DS.brandStart,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 28),

          // Animated fingerprint ring
          ScaleTransition(
            scale: _pulseScale ?? const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onLongPress: isLoading
                  ? null
                  : () async {
                      await _punchController.onPunchTapped(
                        isPunchIn: !isCheckedIn,
                      );
                      await Future.delayed(const Duration(milliseconds: 1500));
                      await _punchController.getTodaysAttendanceState(
                        emppk: emppk!,
                      );
                      if (mounted) setState(() {});
                    },
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      actionColor.withOpacity(0.25),
                      actionColor.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(color: actionColor, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fingerprint_rounded,
                  size: 56,
                  color: actionColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            actionLabel,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white10 : Colors.black38, height: 1),
          const SizedBox(height: 20),

          // Check In / Out times
          Row(
            children: [
              Expanded(
                child: _timeColumn(
                  "Check In",
                  inTimeDisplay,
                  _DS.accentGreen,
                  isDark,
                ),
              ),
              Container(
                width: 1,
                height: 44,
                color: isDark ? Colors.white10 : Colors.black38,
              ),
              Expanded(
                child: _timeColumn(
                  "Check Out",
                  outTimeDisplay,
                  _DS.accentRed,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusPill(bool isCheckedIn, bool isCheckedOut) {
    final Color color;
    final String label;
    final IconData icon;
    if (isCheckedOut) {
      color = _DS.accentRed;
      label = "Checked Out";
      icon = Icons.logout_rounded;
    } else if (isCheckedIn) {
      color = _DS.accentGreen;
      label = "Working";
      icon = Icons.work_outline_rounded;
    } else {
      color = Colors.grey;
      label = "Absent";
      icon = Icons.remove_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeColumn(String label, String time, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          time,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  //  LEAVE BALANCE CARD


  Widget _leaveBalanceCard(bool isDark) {
    const double totalLeaves = 29;
    const double usedLeaves = 10;
    const double remainingLeaves = totalLeaves - usedLeaves;
    final double progress = usedLeaves / totalLeaves;

    return _premiumCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Leave Balance",
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "FY 2025–26",
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Big remaining badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  "${remainingLeaves.toInt()} Days",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Gradient progress bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _leaveStatTile(
                  "Used",
                  "${usedLeaves.toInt()}",
                  _DS.accentOrange,
                  Icons.arrow_upward_rounded,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _leaveStatTile(
                  "Remaining",
                  "${remainingLeaves.toInt()}",
                  _DS.accentGreen,
                  Icons.check_circle_outline,
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _leaveStatTile(
                  "Total",
                  "${totalLeaves.toInt()}",
                  _DS.accentBlue,
                  Icons.calendar_month_outlined,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leaveStatTile(
    String label,
    String value,
    Color color,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  QUICK ACCESS 


  Widget _quickAccessSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel("Quick Access", isDark),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _quickPill(
                Icons.calendar_today_rounded,
                "My Calendar",
                const Color(0xFFF59E0B),
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyCalendarScreen()),
                  );
                },
              ),
              _quickPill(
                Icons.campaign_rounded,
                "Team Updates",
                const Color(0xFF3B82F6),
                () {
                  Navigator.pushNamed(context, "/wallpost");
                },
              ),
              _quickPill(
                Icons.group_rounded,
                "Team Members",
                const Color(0xFF10B981),
                () {
                  CommonSnackBar.show(
                    context: context,
                    title: "Sorry",
                    message: "Development Under Progress !",
                    type: SnackBarType.warning,
                  );
                },
              ),
              _quickPill(
                Icons.support_agent_rounded,
                "Contact HR",
                const Color(0xFF06B6D4),
                () {
                  CommonSnackBar.show(
                    context: context,
                    title: "Sorry",
                    message: "Development Under Progress !",
                    type: SnackBarType.warning,
                  );
                },
              ),
              _quickPill(
                Icons.bar_chart_rounded,
                "Analytics",
                const Color(0xFFA855F7),
                () {
                  CommonSnackBar.show(
                    context: context,
                    title: "Sorry",
                    message: "Development Under Progress !",
                    type: SnackBarType.warning,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickPill(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  MODULE GRID 

  SliverWidget _moduleGridSliver(bool isDark) {
    if (isLoadingModules) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: _DS.brandStart,
                  strokeWidth: 2.5,
                ),
                const SizedBox(height: 14),
                Text(
                  "Loading modules…",
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 190,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1 / 1.18,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final module = moduleList[index];
          final int pk = module["Module_PK"];
          final config = moduleUIMap[pk];
          return _moduleCard(module, config, isDark);
        }, childCount: moduleList.length),
      ),
    );
  }

  Widget _moduleCard(dynamic module, ModuleUIConfig? config, bool isDark) {
    final Color iconColor = config?.iconColor ?? Colors.blueAccent;

    return GestureDetector(
      onTap: () {
        if (config != null) Navigator.pushNamed(context, config.route);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? _DS.cardDark : _DS.cardLight,
          borderRadius: BorderRadius.circular(_DS.r20),
          border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : iconColor.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with gradient bg
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withOpacity(isDark ? 0.25 : 0.18),
                      iconColor.withOpacity(isDark ? 0.10 : 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: iconColor.withOpacity(0.2)),
                ),
                child: Icon(
                  config?.icon ?? Icons.help_outline,
                  size: 24,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                module["Module_Name"],
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                config?.subtitle ?? "",
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // Arrow chip
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SHARED PREMIUM CARD WRAPPER
  // ─────────────────────────────────────────────────────────
  Widget _premiumCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r24),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── HELPERS
  ImageProvider<Object> _buildBase64Image(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (_) {
      return const AssetImage('assets/placeholder.png');
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  SLIVER HEADER DELEGATE
// ─────────────────────────────────────────────────────────────
class _PremiumHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const _PremiumHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_PremiumHeaderDelegate old) =>
      minHeight != old.minHeight ||
      maxHeight != old.maxHeight ||
      child != old.child;
}

// Typedef alias so the sliver grid return type works cleanly
typedef SliverWidget = Widget;
