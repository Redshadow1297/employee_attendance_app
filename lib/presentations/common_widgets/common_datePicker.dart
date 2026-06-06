// // ignore_for_file: file_names, deprecated_member_use

// import 'package:flutter/material.dart';

// class CommonDatePicker {
//   static Future<DateTime?> pickDate({
//     required BuildContext context,
//     DateTime? initialDate,
//     DateTime? firstDate,
//     DateTime? lastDate,
//   }) async {
//     final DateTime now = DateTime.now();
//     final theme = Theme.of(context);

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? now,
//       firstDate: firstDate ?? DateTime(2000),
//       lastDate: lastDate ?? DateTime(2100),
//       helpText: "Select Date",
//       cancelText: "Cancel",
//       confirmText: "Select",
//       builder: (context, child) {
//         return Theme(
//           data: theme.copyWith(
//             useMaterial3: true,
//             colorScheme: theme.colorScheme,
//             dialogTheme: DialogThemeData(
//               backgroundColor: theme.cardColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     return picked;
//   }
// }

//New UI
// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS (consistent with all screens)
// ─────────────────────────────────────────────────────────────
const Color _brandStart = Color(0xFF14B8A6);
const Color _brandDeep  = Color(0xFF0F766E);

class CommonDatePicker {
  static Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now  = DateTime.now();
    final bool isDark   = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate:   firstDate   ?? DateTime(2000),
      lastDate:    lastDate    ?? DateTime(2100),
      helpText:    "Select Date",
      cancelText:  "Cancel",
      confirmText: "Select",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            useMaterial3: true,
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary:          _brandStart,
                    onPrimary:        Colors.white,
                    surface:          Color(0xFF1E293B),
                    onSurface:        Colors.white,
                    secondaryContainer: Color(0xFF0D9488),
                    onSecondaryContainer: Colors.white,
                  )
                : const ColorScheme.light(
                    primary:          _brandStart,
                    onPrimary:        Colors.white,
                    surface:          Colors.white,
                    onSurface:        Color(0xFF0F172A),
                    secondaryContainer: Color(0xFFCCFBF1),
                    onSecondaryContainer: _brandDeep,
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _brandStart,
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    return picked;
  }
}