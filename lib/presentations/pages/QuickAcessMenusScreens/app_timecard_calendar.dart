// // ignore_for_file: deprecated_member_use, use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MyCalendarScreen extends StatefulWidget {
//   const MyCalendarScreen({super.key});

//   @override
//   State<MyCalendarScreen> createState() => _MyCalendarScreenState();
// }

// class _MyCalendarScreenState extends State<MyCalendarScreen> {
//   int? emppk;
//   String? empcode;
//   String? startDate;
//   String? endDate;
//   List<dynamic> newCalendarData = [];
//   DateTime selectedMonth = DateTime.now();
//   final days = [
//     "Sun",
//     "Mon",
//     "Tue",
//     "Wed",
//     "Thu",
//     "Fri",
//     "Sat",
//   ]; // For week day labels
//   int get firstWeekday {
//     return DateTime(selectedMonth.year, selectedMonth.month, 1).weekday % 7;
//   }

//   @override
//   void initState() {
//     super.initState();
//     final now = DateTime.now();
//     startDate = DateFormat(
//       'dd/MM/yyyy',
//     ).format(DateTime(now.year, now.month, 1));
//     endDate = DateFormat(
//       'dd/MM/yyyy',
//     ).format(DateTime(now.year, now.month + 1, 0));
//     _initialize();
//   }

//   void _initialize() {
//     _getPrefsData().then((_) => _fetchTimecardData());
//   }

//   ///fetch prefs Data // empcode and emppk
//   Future<void> _getPrefsData() async {
//     final prefs = await SharedPreferences.getInstance();
//     emppk = prefs.getInt("emppk");
//     empcode = prefs.getString("employeecode");
//   }

//   //Fetch timecard data
//   Future<void> _fetchTimecardData() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getTimeCardData,
//         query: {
//           "Emp_PK": emppk,
//           "strstartdate": startDate,
//           "strendate": endDate,
//         },
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           newCalendarData = response.data["GetTimeCardResult"];
//         });
//       } else {
//         debugPrint("Failed to fetch calendar data: ${response.statusCode}");
//       }
//     } catch (exp) {
//       debugPrint("Error fetching calendar data: $exp");
//     }
//   }

//   ///Status Count days
//   int getStatusCount(String status) {
//     return newCalendarData
//         .where((e) => (e["empstatus"] ?? "") == status)
//         .length;
//   }

//   ///Month Picker (For future enhancement)
//   Future<void> _selectMonth() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedMonth,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//       helpText: "Select Month",
//     );

//     if (picked != null) {
//       setState(() {
//         selectedMonth = picked;

//         startDate = DateFormat(
//           'dd/MM/yyyy',
//         ).format(DateTime(picked.year, picked.month, 1));

//         endDate = DateFormat(
//           'dd/MM/yyyy',
//         ).format(DateTime(picked.year, picked.month + 1, 0));
//       });

//       await _fetchTimecardData();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _header(isDark),
//           const SizedBox(height: 2),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: const Text(
//               "Your attendance status for the month",
//               style: AppTextStyles.labelMedium,
//             ),
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 _weekDaysHeader(isDark),

//                 Expanded(child: _calendarUI(isDark)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 2),
//           Column(children: [Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: _attendanceSummary(isDark),
//           )]),
//         ],
//       ),
//     );
//   }

//   // ── Header ──
//   Widget _header(bool isDark) {
//     return Container(
//       height: 110,
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFC9A646), Color(0xFFDBA717)],
//         ),
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       child: Row(
//         children: [
//           IconButton(
//             icon: CircleAvatar(
//               radius: 18,
//               backgroundColor: Colors.white.withOpacity(0.2),
//               child: const Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),
//             onPressed: () => Navigator.of(context).push(
//               MaterialPageRoute(builder: (_) => const AppDashboardScreen()),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             "My Calendar",
//             style: AppTextStyles.headingLarge.copyWith(color: Colors.white),
//           ),
//           const Spacer(),
//           InkWell(
//             onTap: _selectMonth,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(.15),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.calendar_month, color: Colors.white),
//                   const SizedBox(width: 8),
//                   Text(
//                     DateFormat('MMMM yyyy').format(selectedMonth),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Calendar ──
//   Widget _calendarUI(bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xff1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(2),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.08),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: GridView.builder(
//         padding: const EdgeInsets.all(8),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 7,
//           crossAxisSpacing: 3,
//           mainAxisSpacing: 6,
//           childAspectRatio: 0.68,
//         ),
//         itemCount: firstWeekday + newCalendarData.length,
//         itemBuilder: (context, index) {
//           // Empty cells before first day of month
//           if (index < firstWeekday) {
//             return const SizedBox();
//           }

//           final item = newCalendarData[index - firstWeekday];

//           return _attendanceCard(item);
//         },
//       ),
//     );
//   }

//   //Att card widget
//   Widget _attendanceCard(Map<String, dynamic> item) {
//     final status = item["empstatus"] ?? "";
//     final dateString = item["scheduledateddmm"] ?? "";
//     bool isToday = false;

//     try {
//       final parts = dateString.split('/');

//       final cardDate = DateTime(
//         selectedMonth.year,
//         int.parse(parts[1]),
//         int.parse(parts[0]),
//       );

//       isToday = DateUtils.isSameDay(cardDate, DateTime.now());
//     } catch (_) {}

//     Color color;
//     Color bgColor;

//     switch (status) {
//       case "P":
//         color = Colors.green.shade700;
//         bgColor = Colors.green.shade50;
//         break;

//       case "A":
//         color = Colors.red.shade700;
//         bgColor = Colors.red.shade50;
//         break;

//       case "CL":
//       case "AB":
//         color = Colors.orange.shade700;
//         bgColor = Colors.orange.shade50;
//         break;

//       case "WO":
//         color = Colors.blueGrey.shade700;
//         bgColor = Colors.blueGrey.shade50;
//         break;

//       case "HL":
//         color = Colors.purple.shade700;
//         bgColor = Colors.purple.shade50;
//         break;

//       default:
//         color = Colors.grey.shade700;
//         bgColor = Colors.grey.shade100;
//     }

//     return Container(
//       padding: const EdgeInsets.all(14),

//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(4),

//         border: Border.all(
//           color: isToday ? const Color.fromARGB(255, 240, 95, 42) : color.withOpacity(.9),
//           width: isToday ? 2.5 : 1.2,
//         ),

//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(.10),
//             blurRadius: 2,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),

//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             (item["scheduledateddmm"] ?? "").split('/')[0],
//             style: AppTextStyles.labelMedium.copyWith(color: color),
//           ),
//           const Spacer(),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: color.withOpacity(.15),
//               borderRadius: BorderRadius.circular(30),
//             ),

//             child: Text(
//               status,
//               style: AppTextStyles.labelVSmall.copyWith(
//                 color: color,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Status Count Widget (Optional) ──
//   Widget _attendanceSummary(bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(child: _statusBox("P", getStatusCount("P"), Colors.green)),
//           const SizedBox(width: 4),

//           Expanded(child: _statusBox("A", getStatusCount("A"), Colors.red)),
//           const SizedBox(width: 4),

//           Expanded(
//             child: _statusBox("CL", getStatusCount("CL"), Colors.orange),
//           ),
//           const SizedBox(width: 4),

//           Expanded(child: _statusBox("WO", getStatusCount("WO"), Colors.blue)),
//         ],
//       ),
//     );
//   }

//   //Status box widget Helper
//   Widget _statusBox(String title, int count, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Text(
//             "$count",
//             style: AppTextStyles.headingMedium.copyWith(
//               color: color,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             title,
//             style: AppTextStyles.labelSmall.copyWith(
//               color: color,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   //// ── Future Enhancements ── Week Day Labels
//   Widget _weekDaysHeader(bool isDark) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         children: days.map((day) {
//           return Expanded(
//             child: Center(
//               child: Text(
//                 day,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white70 : Colors.grey.shade700,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }



//NEW UI
// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS  (mirrors app_dashboard_screen.dart)
// ─────────────────────────────────────────────────────────────
class _DS {
  static const Color brandStart  = Color(0xFF14B8A6);
  static const Color brandMid    = Color(0xFF0D9488);
  static const Color brandDeep   = Color(0xFF0F766E);

  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color borderLight  = Color(0xFFE2E8F0);

  static const Color surfaceDark  = Color(0xFF0F172A);
  static const Color cardDark     = Color(0xFF1E293B);
  static const Color borderDark   = Color(0xFF334155);

  // static const double r12 = 12;
  // static const double r16 = 16;
  static const double r20 = 20;
  // static const double r24 = 24;
}

// ─────────────────────────────────────────────────────────────
//  STATUS CONFIG
// ─────────────────────────────────────────────────────────────
class _StatusConfig {
  final Color color;
  final Color bgColor;
  final IconData icon;
  final String label;
  const _StatusConfig({
    required this.color,
    required this.bgColor,
    required this.icon,
    required this.label,
  });
}

_StatusConfig _statusConfig(String status, bool isDark) {
  switch (status) {
    case "P":
      return _StatusConfig(
        color: const Color(0xFF059669), bgColor: const Color(0xFFECFDF5),
        icon: Icons.check_circle_outline_rounded, label: "Present",
      );
    case "A":
      return _StatusConfig(
        color: const Color(0xFFDC2626), bgColor: const Color(0xFFFEF2F2),
        icon: Icons.cancel_outlined, label: "Absent",
      );
    case "CL":
    case "AB":
      return _StatusConfig(
        color: const Color(0xFFD97706), bgColor: const Color(0xFFFFFBEB),
        icon: Icons.beach_access_outlined, label: "Leave",
      );
    case "WO":
      return _StatusConfig(
        color: const Color(0xFF475569), bgColor: const Color(0xFFF1F5F9),
        icon: Icons.weekend_outlined, label: "Week Off",
      );
    case "HL":
      return _StatusConfig(
        color: const Color(0xFF7C3AED), bgColor: const Color(0xFFF5F3FF),
        icon: Icons.celebration_outlined, label: "Holiday",
      );
    default:
      return _StatusConfig(
        color: const Color(0xFF94A3B8), bgColor: const Color(0xFFF8FAFC),
        icon: Icons.remove_circle_outline, label: "—",
      );
  }
}

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class MyCalendarScreen extends StatefulWidget {
  const MyCalendarScreen({super.key});

  @override
  State<MyCalendarScreen> createState() => _MyCalendarScreenState();
}

class _MyCalendarScreenState extends State<MyCalendarScreen>
    with SingleTickerProviderStateMixin {
  int?    emppk;
  String? empcode;
  String? startDate;
  String? endDate;
  List<dynamic> newCalendarData = [];
  DateTime selectedMonth = DateTime.now();
  bool _loading = false;

  final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

  int get firstWeekday =>
      DateTime(selectedMonth.year, selectedMonth.month, 1).weekday % 7;

  // Fade-in animation
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 500),
  )..forward();
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

  // ── LOGIC (unchanged) ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateFormat('dd/MM/yyyy').format(DateTime(now.year, now.month, 1));
    endDate   = DateFormat('dd/MM/yyyy').format(DateTime(now.year, now.month + 1, 0));
    _initialize();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _initialize() {
    _getPrefsData().then((_) => _fetchTimecardData());
  }

  Future<void> _getPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk   = prefs.getInt("emppk");
    empcode = prefs.getString("employeecode");
  }

  Future<void> _fetchTimecardData() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get(
        ApiConstants.getTimeCardData,
        query: {"Emp_PK": emppk, "strstartdate": startDate, "strendate": endDate},
      );
      if (response.statusCode == 200) {
        setState(() {
          newCalendarData = response.data["GetTimeCardResult"];
          _loading = false;
        });
        _fadeCtrl
          ..reset()
          ..forward();
      } else {
        setState(() => _loading = false);
      }
    } catch (exp) {
      debugPrint("Error fetching calendar data: $exp");
      setState(() => _loading = false);
    }
  }

  int getStatusCount(String status) =>
      newCalendarData.where((e) => (e["empstatus"] ?? "") == status).length;

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: "Select Month",
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _DS.brandStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        startDate = DateFormat('dd/MM/yyyy').format(DateTime(picked.year, picked.month, 1));
        endDate   = DateFormat('dd/MM/yyyy').format(DateTime(picked.year, picked.month + 1, 0));
      });
      await _fetchTimecardData();
    }
  }

  // ─────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _DS.surfaceDark : _DS.surfaceLight,
      body: Column(
        children: [
          _header(isDark),
          const SizedBox(height: 16),
          _weekDaysHeader(isDark),
          const SizedBox(height: 8),
          Expanded(child: _loading ? _loadingState() : _calendarBody(isDark)),
          _attendanceSummaryBar(isDark),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─── PREMIUM HEADER ─────────────────────────────────────
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
          // Decorative circles
          Positioned(right: -30, top: -30,
            child: _decorCircle(140, Colors.white.withOpacity(0.06))),
          Positioned(right: 80, bottom: 0,
            child: _decorCircle(70, Colors.white.withOpacity(0.04))),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AppDashboardScreen()),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Calendar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Attendance status for the month",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Month picker chip
                  GestureDetector(
                    onTap: _selectMonth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM yyyy').format(selectedMonth),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70, size: 16),
                        ],
                      ),
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

  Widget _decorCircle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ─── WEEKDAY HEADER ─────────────────────────────────────
  Widget _weekDaysHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: days.map((day) {
          final isSun = day == "Sun";
          final isSat = day == "Sat";
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isSun || isSat
                      ? _DS.brandStart.withOpacity(0.8)
                      : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── LOADING STATE ───────────────────────────────────────
  Widget _loadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _DS.brandStart, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text("Loading attendance…",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ],
      ),
    );
  }

  // ─── CALENDAR BODY ───────────────────────────────────────
  Widget _calendarBody(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? _DS.cardDark : _DS.cardLight,
            borderRadius: BorderRadius.circular(_DS.r20),
            border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.30)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_DS.r20),
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 5,
                mainAxisSpacing: 6,
                childAspectRatio: 0.66,
              ),
              itemCount: firstWeekday + newCalendarData.length,
              itemBuilder: (context, index) {
                if (index < firstWeekday) return const SizedBox();
                final item = newCalendarData[index - firstWeekday];
                return _attendanceCard(item, isDark);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ─── ATTENDANCE CARD ─────────────────────────────────────
  Widget _attendanceCard(Map<String, dynamic> item, bool isDark) {
    final status     = item["empstatus"] ?? "";
    final dateString = item["scheduledateddmm"] ?? "";
    final cfg        = _statusConfig(status, isDark);
    bool isToday     = false;

    try {
      final parts   = dateString.split('/');
      final cardDate = DateTime(
        selectedMonth.year, int.parse(parts[1]), int.parse(parts[0]),
      );
      isToday = DateUtils.isSameDay(cardDate, DateTime.now());
    } catch (_) {}

    final dayNum = dateString.isNotEmpty ? dateString.split('/')[0] : "—";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark
            ? cfg.color.withOpacity(0.12)
            : cfg.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? const Color(0xFFF97316)
              : cfg.color.withOpacity(isDark ? 0.3 : 0.4),
          width: isToday ? 2.0 : 1.0,
        ),
        boxShadow: isToday
            ? [BoxShadow(color: const Color(0xFFF97316).withOpacity(0.25), blurRadius: 8)]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day number
          Text(
            dayNum,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday
                  ? const Color(0xFFF97316)
                  : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 5),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: cfg.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status.isEmpty ? "—" : status,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: cfg.color,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SUMMARY BAR ─────────────────────────────────────────
  Widget _attendanceSummaryBar(bool isDark) {
    final summaryItems = [
      _SummaryItem("Present", getStatusCount("P"),  const Color(0xFF059669), Icons.check_circle_outline_rounded),
      _SummaryItem("Absent",  getStatusCount("A"),  const Color(0xFFDC2626), Icons.cancel_outlined),
      _SummaryItem("Leave",   getStatusCount("CL"), const Color(0xFFD97706), Icons.beach_access_outlined),
      _SummaryItem("Week Off",getStatusCount("WO"), const Color(0xFF475569), Icons.weekend_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? _DS.cardDark : _DS.cardLight,
          borderRadius: BorderRadius.circular(_DS.r20),
          border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.30)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: summaryItems
              .map((item) => Expanded(child: _summaryTile(item, isDark)))
              .toList(),
        ),
      ),
    );
  }

  Widget _summaryTile(_SummaryItem item, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: item.color.withOpacity(0.25)),
          ),
          child: Icon(item.icon, color: item.color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          "${item.count}",
          style: TextStyle(
            color: item.color,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          style: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────
class _SummaryItem {
  final String  label;
  final int     count;
  final Color   color;
  final IconData icon;
  const _SummaryItem(this.label, this.count, this.color, this.icon);
}