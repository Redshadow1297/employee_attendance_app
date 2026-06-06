// // lib/presentations/common_widgets/modern_punch_dialog.dart
// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'package:flutter/material.dart';

// enum PunchDialogType { checkIn, checkOut, locationOff, savedOffline }

// extension _PunchDialogConfig on PunchDialogType {
//   IconData get icon {
//     switch (this) {
//       case PunchDialogType.checkIn:
//         return Icons.login_rounded;
//       case PunchDialogType.checkOut:
//         return Icons.logout_rounded;
//       case PunchDialogType.locationOff:
//         return Icons.location_off_rounded;
//       case PunchDialogType.savedOffline:
//         return Icons.cloud_done_rounded;
//     }
//   }

//   Color get accentColor {
//     switch (this) {
//       case PunchDialogType.checkIn:
//         return const Color(0xFF43A047);
//       case PunchDialogType.checkOut:
//         return const Color(0xFFE53935);
//       case PunchDialogType.locationOff:
//         return const Color(0xFFFF8F00);
//       case PunchDialogType.savedOffline:
//         return const Color(0xFF2F6BFF);
//     }
//   }

//   Color get iconBg => accentColor.withOpacity(0.12);

//   String get title {
//     switch (this) {
//       case PunchDialogType.checkIn:
//         return "Confirm Check In";
//       case PunchDialogType.checkOut:
//         return "Confirm Check Out";
//       case PunchDialogType.locationOff:
//         return "Location Required";
//       case PunchDialogType.savedOffline:
//         return "Saved Offline";
//     }
//   }

//   String get message {
//     switch (this) {
//       case PunchDialogType.checkIn:
//         return "Are you sure you want to punch in now?";
//       case PunchDialogType.checkOut:
//         return "Are you sure you want to punch out now?";
//       case PunchDialogType.locationOff:
//         return "Location services are off. Please enable GPS.";
//       case PunchDialogType.savedOffline:
//         return "Attendance saved offline. It will sync automatically.";
//     }
//   }

//   String get confirmLabel {
//     switch (this) {
//       case PunchDialogType.checkIn:
//         return "Yes, Check In";
//       case PunchDialogType.checkOut:
//         return "Yes, Check Out";
//       case PunchDialogType.locationOff:
//         return "Enable Location";
//       case PunchDialogType.savedOffline:
//         return "OK";
//     }
//   }

//   bool get showCancel => this != PunchDialogType.savedOffline;
// }

// class ModernPunchDialog {
//   ModernPunchDialog._();

//   static Future<void> show({
//     required BuildContext context,
//     required PunchDialogType type,
//     required VoidCallback onConfirmed,
//     VoidCallback? onCancelled,
//   }) {
//     return showGeneralDialog(
//       context: context,
//       barrierDismissible: type.showCancel,
//       barrierLabel: '',
//       barrierColor: Colors.black54,
//       transitionDuration: const Duration(milliseconds: 280),
//       transitionBuilder: (_, anim, __, child) {
//         return ScaleTransition(
//           scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
//           child: FadeTransition(opacity: anim, child: child),
//         );
//       },
//       pageBuilder: (ctx, _, __) => _ModernPunchDialogWidget(
//         type: type,
//         onConfirmed: onConfirmed,
//         onCancelled: onCancelled,
//       ),
//     );
//   }
// }

// class _ModernPunchDialogWidget extends StatelessWidget {
//   final PunchDialogType type;
//   final VoidCallback onConfirmed;
//   final VoidCallback? onCancelled;

//   const _ModernPunchDialogWidget({
//     required this.type,
//     required this.onConfirmed,
//     this.onCancelled,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final accent = type.accentColor;

//     return Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 32),
//           decoration: BoxDecoration(
//             color: theme.cardColor,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: theme.shadowColor.withOpacity(0.18),
//                 blurRadius: 30,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 68,
//                   height: 68,
//                   decoration: BoxDecoration(
//                     color: type.iconBg,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(type.icon, color: accent, size: 32),
//                 ),

//                 const SizedBox(height: 18),

//                 Text(
//                   type.title,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.w700,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 Text(
//                   type.message,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 13.5,
//                     color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     height: 1.5,
//                   ),
//                 ),

//                 const SizedBox(height: 28),

//                 Row(
//                   children: [
//                     if (type.showCancel) ...[
//                       Expanded(
//                         child: _OutlineBtn(
//                           label: "Cancel",
//                           color: theme.colorScheme.onSurface,
//                           onTap: () {
//                             Navigator.of(context).pop();
//                             onCancelled?.call();
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                     ],
//                     Expanded(
//                       child: _FilledBtn(
//                         label: type.confirmLabel,
//                         color: accent,
//                         onTap: () {
//                           Navigator.of(context).pop();
//                           onConfirmed();
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FilledBtn extends StatelessWidget {
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _FilledBtn({
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 46,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 13.5,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _OutlineBtn extends StatelessWidget {
//   final String label;
//   final Color color;
//   final VoidCallback onTap;

//   const _OutlineBtn({
//     required this.label,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 46,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.35),
//             width: 1.5,
//           ),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           label,
//           style: TextStyle(
//             color: color,
//             fontSize: 13.5,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }





// ignore_for_file: dangling_library_doc_comments

////NEW UI 


// lib/presentations/common_widgets/modern_punch_dialog.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';

const Color _brandStart = Color(0xFF14B8A6);
const Color _brandDeep  = Color(0xFF0F766E);

enum PunchDialogType { checkIn, checkOut, locationOff, savedOffline }

extension _PunchDialogConfig on PunchDialogType {
  IconData get icon {
    switch (this) {
      case PunchDialogType.checkIn:       return Icons.login_rounded;
      case PunchDialogType.checkOut:      return Icons.logout_rounded;
      case PunchDialogType.locationOff:   return Icons.location_off_rounded;
      case PunchDialogType.savedOffline:  return Icons.cloud_done_rounded;
    }
  }

  // Per-type accent + gradient
  Color get accentColor {
    switch (this) {
      case PunchDialogType.checkIn:       return const Color(0xFF10B981);
      case PunchDialogType.checkOut:      return const Color(0xFFEF4444);
      case PunchDialogType.locationOff:   return const Color(0xFFF59E0B);
      case PunchDialogType.savedOffline:  return _brandStart;
    }
  }

  List<Color> get gradient {
    switch (this) {
      case PunchDialogType.checkIn:      return [const Color(0xFF10B981), const Color(0xFF059669)];
      case PunchDialogType.checkOut:     return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case PunchDialogType.locationOff:  return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case PunchDialogType.savedOffline: return [_brandStart, _brandDeep];
    }
  }

  String get title {
    switch (this) {
      case PunchDialogType.checkIn:       return "Confirm Check In";
      case PunchDialogType.checkOut:      return "Confirm Check Out";
      case PunchDialogType.locationOff:   return "Location Required";
      case PunchDialogType.savedOffline:  return "Saved Offline";
    }
  }

  String get message {
    switch (this) {
      case PunchDialogType.checkIn:       return "Are you sure you want to punch in now?";
      case PunchDialogType.checkOut:      return "Are you sure you want to punch out now?";
      case PunchDialogType.locationOff:   return "Location services are off. Please enable GPS to continue.";
      case PunchDialogType.savedOffline:  return "Attendance saved offline. It will sync automatically when online.";
    }
  }

  String get confirmLabel {
    switch (this) {
      case PunchDialogType.checkIn:       return "Yes, Check In";
      case PunchDialogType.checkOut:      return "Yes, Check Out";
      case PunchDialogType.locationOff:   return "Enable Location";
      case PunchDialogType.savedOffline:  return "Got It";
    }
  }

  bool get showCancel => this != PunchDialogType.savedOffline;
}

// ─────────────────────────────────────────────────────────────
//  PUBLIC API (unchanged)
// ─────────────────────────────────────────────────────────────
class ModernPunchDialog {
  ModernPunchDialog._();

  static Future<void> show({
    required BuildContext context,
    required PunchDialogType type,
    required VoidCallback onConfirmed,
    VoidCallback? onCancelled,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: type.showCancel,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.60),
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => _PunchDialogWidget(
        type: type,
        onConfirmed: onConfirmed,
        onCancelled: onCancelled,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  DIALOG WIDGET
// ─────────────────────────────────────────────────────────────
class _PunchDialogWidget extends StatelessWidget {
  final PunchDialogType type;
  final VoidCallback    onConfirmed;
  final VoidCallback?   onCancelled;

  const _PunchDialogWidget({
    required this.type,
    required this.onConfirmed,
    this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final accent  = type.accentColor;
    final grads   = type.gradient;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.20),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 10),
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
                  gradient: LinearGradient(colors: grads),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon with glow ring
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [
                          accent.withOpacity(0.22),
                          accent.withOpacity(0.05),
                        ]),
                        border: Border.all(
                            color: accent.withOpacity(0.30), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.28),
                            blurRadius: 18, spreadRadius: 2,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(type.icon, color: accent, size: 32),
                    ),

                    const SizedBox(height: 18),

                    // ── Title
                    Text(
                      type.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ── Message
                    Text(
                      type.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ── Buttons
                    Row(
                      children: [
                        if (type.showCancel) ...[
                          Expanded(
                            child: _CancelBtn(
                              isDark: isDark,
                              onTap: () {
                                Navigator.of(context).pop();
                                onCancelled?.call();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: _ConfirmBtn(
                            label:  type.confirmLabel,
                            colors: grads,
                            accent: accent,
                            onTap: () {
                              Navigator.of(context).pop();
                              onConfirmed();
                            },
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BUTTONS
// ─────────────────────────────────────────────────────────────
class _ConfirmBtn extends StatelessWidget {
  final String       label;
  final List<Color>  colors;
  final Color        accent;
  final VoidCallback onTap;

  const _ConfirmBtn({
    required this.label,
    required this.colors,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.38),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _CancelBtn extends StatelessWidget {
  final bool         isDark;
  final VoidCallback onTap;

  const _CancelBtn({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "Cancel",
          style: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF475569),
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}