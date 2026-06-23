// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:new_design_demo/core/constants/ds_color_handler.dart';
import 'package:new_design_demo/data/model/ds_color_mode_calendarStatus.dart';
import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

StatusConfig statusConfig(String status, bool isDark) {
  switch (status) {
    case "P":
      return StatusConfig(
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFECFDF5),
        icon: Icons.check_circle_outline_rounded,
        label: "Present",
      );

    case "AB":
      return StatusConfig(
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
        icon: Icons.cancel_outlined,
        label: "Absent",
      );

    case "CL":
      return StatusConfig(
        color: const Color(0xFFEA580C),
        bgColor: const Color(0xFFFFF7ED),
        icon: Icons.event_busy_rounded,
        label: "Casual Leave",
      );

    case "OD":
      return StatusConfig(
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFFFBEB),
        icon: Icons.work_outline_rounded,
        label: "On Duty",
      );

    case "WO":
      return StatusConfig(
        color: const Color(0xFF475569),
        bgColor: const Color(0xFFF1F5F9),
        icon: Icons.weekend_outlined,
        label: "Week Off",
      );

    case "PH":
      return StatusConfig(
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFF5F3FF),
        icon: Icons.celebration_outlined,
        label: "Holiday",
      );

    case "LWP":
      return StatusConfig(
        color: const Color(0xFFB45309),
        bgColor: const Color(0xFFFFFBEB),
        icon: Icons.money_off_rounded,
        label: "LWP",
      );

    case "ML":
      return StatusConfig(
        color: const Color(0xFFDB2777),
        bgColor: const Color(0xFFFCE7F3),
        icon: Icons.child_care_rounded,
        label: "ML",
      );

    case "MRGL":
      return StatusConfig(
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        icon: Icons.medical_services_outlined,
        label: "MRGL",
      );

    case "SH":
      return StatusConfig(
        color: const Color(0xFF0891B2),
        bgColor: const Color(0xFFECFEFF),
        icon: Icons.schedule_rounded,
        label: "SH",
      );

    default:
      return StatusConfig(
        color: const Color(0xFF94A3B8),
        bgColor: const Color(0xFFF8FAFC),
        icon: Icons.remove_circle_outline,
        label: "—",
      );
  }
}

//  SCREEN
class MyCalendarScreen extends StatefulWidget {
  const MyCalendarScreen({super.key});

  @override
  State<MyCalendarScreen> createState() => _MyCalendarScreenState();
}

class _MyCalendarScreenState extends State<MyCalendarScreen>
    with SingleTickerProviderStateMixin {
  int? emppk;
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
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeCtrl,
    curve: Curves.easeOut,
  );

  //  LOGIC
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime(now.year, now.month, 1));
    endDate = DateFormat(
      'dd/MM/yyyy',
    ).format(DateTime(now.year, now.month + 1, 0));
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
    emppk = prefs.getInt("emppk");
    empcode = prefs.getString("employeecode");
  }

  Future<void> _fetchTimecardData() async {
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get(
        ApiConstants.getTimeCardData,
        query: {
          "Emp_PK": emppk,
          "strstartdate": startDate,
          "strendate": endDate,
        },
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

  ///Attendance Count Status And Leave
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
          colorScheme: const ColorScheme.light(primary: DS.brandStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        startDate = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime(picked.year, picked.month, 1));
        endDate = DateFormat(
          'dd/MM/yyyy',
        ).format(DateTime(picked.year, picked.month + 1, 0));
      });
      await _fetchTimecardData();
    }
  }

  //  BUILD

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? DS.surfaceDark : DS.surfaceLight,
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
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: _decorCircle(140, Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            right: 80,
            bottom: 0,
            child: _decorCircle(70, Colors.white.withOpacity(0.04)),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppDashboardScreen(),
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
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
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
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
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  //  WEEKDAY HEADER
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
                      ? DS.brandStart.withOpacity(0.8)
                      : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //  LOADING STATE
  Widget _loadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: DS.brandStart, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text(
            "Loading attendance…",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  //  CALENDAR BODY
  Widget _calendarBody(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? DS.cardDark : DS.cardLight,
            borderRadius: BorderRadius.circular(DS.r20),
            border: Border.all(color: isDark ? DS.borderDark : DS.borderLight),
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
            borderRadius: BorderRadius.circular(DS.r20),
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

  //  ATTENDANCE CARD
  Widget _attendanceCard(Map<String, dynamic> item, bool isDark) {
    final status = item["empstatus"] ?? "";
    final dateString = item["scheduledateddmm"] ?? "";
    final cfg = statusConfig(status, isDark);
    bool isToday = false;

    try {
      final parts = dateString.split('/');
      final cardDate = DateTime(
        selectedMonth.year,
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      isToday = DateUtils.isSameDay(cardDate, DateTime.now());
    } catch (_) {}

    final dayNum = dateString.isNotEmpty ? dateString.split('/')[0] : "—";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? cfg.color.withOpacity(0.12) : cfg.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? const Color(0xFFF97316)
              : cfg.color.withOpacity(isDark ? 0.3 : 0.4),
          width: isToday ? 2.0 : 1.0,
        ),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: const Color(0xFFF97316).withOpacity(0.25),
                  blurRadius: 8,
                ),
              ]
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

  //  SUMMARY BAR
  Widget _attendanceSummaryBar(bool isDark) {
    final summaryItems = [
      _SummaryItem(
        "Present",
        getStatusCount("P"),
        const Color(0xFF059669),
        Icons.check_circle_outline_rounded,
      ),
      _SummaryItem(
        "Absent",
        getStatusCount("AB"),
        const Color(0xFFDC2626),
        Icons.cancel_outlined,
      ),
      _SummaryItem(
        "Paid Leave",
        getStatusCount("PL"),
        const Color.fromARGB(255, 179, 176, 20),
        Icons.paid,
      ),
      _SummaryItem(
        "On Duty",
        getStatusCount("OD"),
        const Color(0xFFD97706),
        Icons.beach_access_outlined,
      ),
      _SummaryItem(
        "Week Off",
        getStatusCount("WO"),
        const Color(0xFF475569),
        Icons.weekend_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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

//  HELPERS
class _SummaryItem {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _SummaryItem(this.label, this.count, this.color, this.icon);
}
