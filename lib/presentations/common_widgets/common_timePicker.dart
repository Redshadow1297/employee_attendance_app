// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AppTimePicker {
//   static Future<void> show({
//     required BuildContext context,
//     required TextEditingController controller,
//     bool use24Hour = true,
//   }) async {
//     DateTime selectedTime = DateTime.now();

//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) {
//         return TweenAnimationBuilder(
//           duration: const Duration(milliseconds: 400),
//           tween: Tween(begin: 80.0, end: 0.0),
//           curve: Curves.easeOutBack,
//           builder: (context, value, child) {
//             return Transform.translate(
//               offset: Offset(0, value),
//               child: child,
//             );
//           },
//           child: Container(
//             height: 420,
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(28),
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xfff8f9ff),
//                   Color(0xffffffff),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(.08),
//                   blurRadius: 20,
//                   spreadRadius: 2,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: StatefulBuilder(
//               builder: (context, refresh) {
//                 return Column(
//                   children: [
//                     const SizedBox(height: 14),

//                     // Top Handle
//                     Container(
//                       width: 50,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     // Header
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 18),
//                       child: Row(
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                         children: [
//                           GestureDetector(
//                             onTap: () => Navigator.pop(context),
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade100,
//                                 borderRadius:
//                                     BorderRadius.circular(14),
//                               ),
//                               child: const Text(
//                                 "Cancel",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const Text(
//                             "Select Time",
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           GestureDetector(
//                             onTap: () {
//                               controller.text = DateFormat(
//                                 use24Hour
//                                     ? "HH:mm"
//                                     : "hh:mm a",
//                               ).format(selectedTime);

//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [
//                                     Color(0xff5B86E5),
//                                     Color(0xff36D1DC),
//                                   ],
//                                 ),
//                                 borderRadius:
//                                     BorderRadius.circular(14),
//                               ),
//                               child: const Text(
//                                 "Done",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 18),

//                     // Live Preview Time
//                     Text(
//                       DateFormat(
//                         use24Hour
//                             ? "HH:mm"
//                             : "hh:mm a",
//                       ).format(selectedTime),
//                       style: const TextStyle(
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xff222222),
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Container(
//                       width: 120,
//                       height: 3,
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(20),
//                         gradient: const LinearGradient(
//                           colors: [
//                             Color(0xff5B86E5),
//                             Color(0xff36D1DC),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     Divider(
//                       color: Colors.grey.shade200,
//                       height: 1,
//                     ),

//                     const SizedBox(height: 10),

//                     // Fixed height picker (FIXED)
//                     SizedBox(
//                       height: 230,
//                       child: CupertinoTheme(
//                         data: const CupertinoThemeData(
//                           brightness: Brightness.light,
//                         ),
//                         child: CupertinoDatePicker(
//                           mode:
//                               CupertinoDatePickerMode.time,
//                           use24hFormat: use24Hour,
//                           initialDateTime: selectedTime,
//                           minuteInterval: 1,
//                           onDateTimeChanged: (value) {
//                             selectedTime = value;
//                             refresh(() {});
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

//NEW UI

// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
const Color _brandStart = Color(0xFF14B8A6);
const Color _brandDeep = Color(0xFF0F766E);

class AppTimePicker {
  static Future<void> show({
    required BuildContext context,
    required TextEditingController controller,
    bool use24Hour = true,
  }) async {
    DateTime selectedTime = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 80.0, end: 0.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(0, value), child: child),
          child: Container(
            height: 420,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.50)
                      : _brandStart.withOpacity(0.12),
                  blurRadius: 28,
                  spreadRadius: 0,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, refresh) {
                final String timeLabel = DateFormat(
                  use24Hour ? "HH:mm" : "hh:mm a",
                ).format(selectedTime);

                return Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Cancel
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : const Color(0xFF475569),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          // Title
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _brandStart.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.access_time_rounded,
                                  color: _brandStart,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Select Time",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),

                          // Done
                          GestureDetector(
                            onTap: () {
                              controller.text = timeLabel;
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_brandStart, _brandDeep],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _brandStart.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Text(
                                "Done",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Live time preview
                    Text(
                      timeLabel,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ── Gradient underline
                    Container(
                      width: 80,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_brandStart, _brandDeep],
                        ),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: _brandStart.withOpacity(0.40),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),

                    const SizedBox(height: 8),

                    // ── Cupertino picker
                    Expanded(
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          brightness: isDark
                              ? Brightness.dark
                              : Brightness.light,
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: use24Hour,
                          initialDateTime: selectedTime,
                          minuteInterval: 1,
                          backgroundColor: Colors.transparent,
                          onDateTimeChanged: (value) {
                            selectedTime = value;
                            refresh(() {});
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
