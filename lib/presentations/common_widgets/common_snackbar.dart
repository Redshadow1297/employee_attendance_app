// import 'package:flutter/material.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';

// enum SnackBarType { success, error, warning }

// class CommonSnackBar {
//   static void show({
//     required BuildContext context,
//     required String title,
//     required String message,
//     required SnackBarType type,
//   }) {
//     Color backgroundColor;
//     IconData icon;
//     Color iconColor;

//     switch (type) {
//       case SnackBarType.success:
//         backgroundColor = Colors.green;
//         icon = Icons.check_circle;
//         iconColor = const Color.fromARGB(255, 207, 233, 179);
//         break;

//       case SnackBarType.error:
//         backgroundColor = Colors.red;
//         icon = Icons.error;
//         iconColor = Colors.white70;
//         break;

//       case SnackBarType.warning:
//         backgroundColor = const Color.fromARGB(255, 244, 176, 16);
//         icon = Icons.warning;
//         iconColor = Colors.white;
//         break;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         elevation: 8,
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: iconColor, size: 20),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: AppTextStyles.headingSmall.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               message,
//               style: AppTextStyles.labelMedium.copyWith(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// ignore: dangling_library_doc_comments
///NEW UI

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning }

class CommonSnackBar {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required SnackBarType type,
  }) {
    // ── Type config ───────────────────────────────────────────
    final Color   bgColor;
    final Color   accentColor;
    final IconData icon;
    final List<Color> gradient;

    switch (type) {
      case SnackBarType.success:
        bgColor     = const Color(0xFF064E3B);   // deep green
        accentColor = const Color(0xFF10B981);
        icon        = Icons.check_circle_rounded;
        gradient    = [const Color(0xFF059669), const Color(0xFF047857)];
        break;
      case SnackBarType.error:
        bgColor     = const Color(0xFF450A0A);
        accentColor = const Color(0xFFEF4444);
        icon        = Icons.cancel_rounded;
        gradient    = [const Color(0xFFEF4444), const Color(0xFFDC2626)];
        break;
      case SnackBarType.warning:
        bgColor     = const Color(0xFF451A03);
        accentColor = const Color(0xFFF59E0B);
        icon        = Icons.warning_amber_rounded;
        gradient    = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: EdgeInsets.zero,
          content: _SnackContent(
            bgColor: bgColor,
            accentColor: accentColor,
            gradient: gradient,
            icon: icon,
            title: title,
            message: message,
          ),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────
//  CONTENT WIDGET
// ─────────────────────────────────────────────────────────────
class _SnackContent extends StatelessWidget {
  final Color        bgColor;
  final Color        accentColor;
  final List<Color>  gradient;
  final IconData     icon;
  final String       title;
  final String       message;

  const _SnackContent({
    required this.bgColor,
    required this.accentColor,
    required this.gradient,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.30)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Left accent bar
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradient,
              ),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            ),
          ),

          const SizedBox(width: 14),

          // ── Icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withOpacity(0.30)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accentColor, size: 19),
          ),

          const SizedBox(width: 12),

          // ── Text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.70),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── Dismiss X
          GestureDetector(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.40),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}