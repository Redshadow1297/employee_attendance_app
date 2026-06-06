// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:new_design_demo/core/constants/app_color.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_button.dart';

// enum DialogType { success, error, warning, info }

// void showModernDialog({
//   required BuildContext context,
//   required String title,
//   required String message,
//   required String confirmText,
//   required VoidCallback onConfirm,
//   String cancelText = "Cancel",
//   DialogType type = DialogType.success,
// }) {
//   final theme = Theme.of(context);
//   final colorScheme = theme.colorScheme;
//   final isDark = theme.brightness == Brightness.dark;

//   IconData icon;
//   Color color;

//   switch (type) {
//     case DialogType.success:
//       icon = Icons.check_circle;
//       color = AppColors.success;
//       break;

//     case DialogType.error:
//       icon = Icons.cancel;
//       color = colorScheme.error;
//       break;

//     case DialogType.warning:
//       icon = Icons.warning;
//       color = Colors.orange;
//       break;

//     case DialogType.info:
//       icon = Icons.info;
//       color = colorScheme.primary;
//       break;
//   }

//   showGeneralDialog(
//     context: context,
//     barrierDismissible: false,
//     barrierLabel: "Dialog",
//     barrierColor: Colors.black54,
//     transitionDuration: const Duration(milliseconds: 300),

//     pageBuilder: (_, __, ___) => const SizedBox(),

//     transitionBuilder: (
//       context,
//       animation,
//       secondaryAnimation,
//       child,
//     ) {
//       final curvedValue =
//           Curves.easeOutBack.transform(animation.value);

//       return Transform.scale(
//         scale: curvedValue,
//         child: Opacity(
//           opacity: animation.value,
//           child: Center(
//             child: Dialog(
//               elevation: 0,
//               backgroundColor: colorScheme.surface,
//               insetPadding:
//                   const EdgeInsets.symmetric(horizontal: 40),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),

//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 18,
//                   vertical: 20,
//                 ),

//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     /// Icon Container
//                     Container(
//                       padding: const EdgeInsets.all(12),

//                       decoration: BoxDecoration(
//                         color: color.withValues(alpha: 0.12),
//                         shape: BoxShape.circle,

//                         boxShadow: [
//                           BoxShadow(
//                             color: isDark
//                                 ? Colors.black.withValues(alpha: 0.3)
//                                 : Colors.grey.withValues(alpha: 0.15),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),

//                       child: Icon(
//                         icon,
//                         color: color,
//                         size: 30,
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     /// Title
//                     Text(
//                       title,
//                       textAlign: TextAlign.center,
//                       style: AppTextStyles.headingMedium.copyWith(
//                         fontSize: 17,
//                         fontWeight: FontWeight.w600,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     /// Message
//                     Text(
//                       message,
//                       textAlign: TextAlign.center,
//                       style: AppTextStyles.headingSmall.copyWith(
//                         fontSize: 13,
//                         height: 1.4,
//                         color: colorScheme.onSurface
//                             .withValues(alpha: 0.7),
//                       ),
//                     ),

//                     const SizedBox(height: 22),

//                     /// Buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: SizedBox(
//                             height: 42,

//                             child: CommonButton(
//                               width: 36,
//                               height: 30,
//                               icon: null,

//                               label: cancelText,

//                               color: isDark
//                                   ? colorScheme.surfaceContainerHighest
//                                   : Colors.grey.shade200,

//                               textColor:
//                                   colorScheme.onSurface,

//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         Expanded(
//                           child: SizedBox(
//                             height: 42,

//                             child: CommonButton(
//                               width: 36,
//                               height: 30,
//                               icon: null,

//                               label: confirmText,
//                               color: color,

//                               onPressed: () {
//                                 Navigator.pop(context);
//                                 onConfirm();
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// ignore: dangling_library_doc_comments
///NEW UI


// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

enum DialogType { success, error, warning, info }

void showModernDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required VoidCallback onConfirm,
  String cancelText = "Cancel",
  DialogType type = DialogType.success,
}) {
  final theme       = Theme.of(context);
  // final colorScheme = theme.colorScheme;
  final isDark      = theme.brightness == Brightness.dark;

  // ── Token colours ──────────────────────────────────────────
  const Color brandStart = Color(0xFF14B8A6);
  const Color brandDeep  = Color(0xFF0F766E);

  IconData icon;
  Color    color;
  List<Color> gradientColors;

  switch (type) {
    case DialogType.success:
      icon           = Icons.check_circle_rounded;
      color          = const Color(0xFF10B981);
      gradientColors = [const Color(0xFF10B981), const Color(0xFF059669)];
      break;
    case DialogType.error:
      icon           = Icons.cancel_rounded;
      color          = const Color(0xFFEF4444);
      gradientColors = [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      break;
    case DialogType.warning:
      icon           = Icons.warning_amber_rounded;
      color          = const Color(0xFFF59E0B);
      gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      break;
    case DialogType.info:
      icon           = Icons.info_rounded;
      color          = brandStart;
      gradientColors = [brandStart, brandDeep];
      break;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Dialog",
    barrierColor: Colors.black.withOpacity(0.60),
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const SizedBox(),
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return ScaleTransition(
        scale: curved,
        child: FadeTransition(
          opacity: animation,
          child: Center(
            child: Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 32),
              child: _DialogContent(
                isDark: isDark,
                icon: icon,
                color: color,
                gradientColors: gradientColors,
                title: title,
                message: message,
                cancelText: cancelText,
                confirmText: confirmText,
                onConfirm: onConfirm,
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────
//  DIALOG CONTENT WIDGET
// ─────────────────────────────────────────────────────────────
class _DialogContent extends StatelessWidget {
  final bool           isDark;
  final IconData       icon;
  final Color          color;
  final List<Color>    gradientColors;
  final String         title;
  final String         message;
  final String         cancelText;
  final String         confirmText;
  final VoidCallback   onConfirm;

  const _DialogContent({
    required this.isDark,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.50)
                : color.withOpacity(0.15),
            blurRadius: 32,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon with glow ring
                Container(
                  width: 68, height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withOpacity(0.20),
                        color.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(color: color.withOpacity(0.30), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 16, spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 32),
                ),

                const SizedBox(height: 18),

                // ── Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 44,
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
                          alignment: Alignment.center,
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : const Color(0xFF475569),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Confirm
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.40),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            confirmText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}