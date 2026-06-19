// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
// import 'package:new_design_demo/presentations/pages/app_login.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _mainController;
//   late AnimationController _floatingController;
//   late AnimationController _dotController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _floatingAnimation;
//   @override
// void initState() {
//   super.initState();
//   _initAnimations();
//   _navigate();
// }
// ///////////////Animation controlss
// void _initAnimations() {
//   _mainController =
//       AnimationController(vsync: this, duration: const Duration(seconds: 2));
//   _floatingController =
//       AnimationController(vsync: this, duration: const Duration(seconds: 3))
//         ..repeat(reverse: true);
//   _dotController =
//       AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
//         ..repeat();
//   _fadeAnimation =
//       CurvedAnimation(parent: _mainController, curve: Curves.easeIn);
//   _slideAnimation =
//       Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//     CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
//   );
//   _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
//     CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
//   );
//   _mainController.forward();
// }
// /////Navigation HAndles on LoggedInFlag
// Future<void> _navigate() async {
//   await Future.delayed(const Duration(seconds: 4));
//   final prefs = await SharedPreferences.getInstance();
//   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   if (!mounted) return;
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (_) =>
//           isLoggedIn ? const AppDashboardScreen() : const LoginScreen(),
//     ),
//   );
// }
//   @override
//   void dispose() {
//     _mainController.dispose();
//     _floatingController.dispose();
//     _dotController.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color(0xFF3B82F6), // Blue
//                   Color(0xFF8B5CF6), // Purple
//                   Color(0xFFEC4899), // Pink
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           const Positioned(
//             top: -80,
//             left: -50,
//             child: GlowCircle(size: 200, opacity: 0.15),
//           ),
//           const Positioned(
//             bottom: -60,
//             right: -40,
//             child: GlowCircle(size: 180, opacity: 0.15),
//           ),
//           Center(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Floating Icon
//                     AnimatedBuilder(
//                       animation: _floatingAnimation,
//                       builder: (context, child) {
//                         return Transform.translate(
//                           offset: Offset(0, _floatingAnimation.value),
//                           child: child,
//                         );
//                       },
//                       child: const AppIconWidget(),
//                     ),
//                     const SizedBox(height: 30),
//                     Text(
//                       "PeopleScope",
//                       style: AppTextStyles.headingLarge.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Enabling Work, Supporting Growth.",
//                       style: AppTextStyles.headingSmall.copyWith(
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     // Loading Dots
//                     BouncingDots(controller: _dotController),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Bottom Section
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: const [
//                 Text(
//                   "© 2026 PeopleScope ...",
//                   style: TextStyle(color: Colors.white54, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class GlowCircle extends StatefulWidget {
//   final double size;
//   final double opacity;
//   const GlowCircle({super.key, required this.size, required this.opacity});
//   @override
//   State<GlowCircle> createState() => _GlowCircleState();
// }
// class _GlowCircleState extends State<GlowCircle>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     )..repeat(reverse: true);
//   }
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Opacity(
//           opacity: widget.opacity + (_controller.value * 0.1),
//           child: Container(
//             width: widget.size.w,
//             height: widget.size.h,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
// class AppIconWidget extends StatelessWidget {
//   const AppIconWidget({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.15),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         width: 90.w,
//         height: 90.h,
//         child: GridView.count(
//           crossAxisCount: 2,
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 8,
//           physics: const NeverScrollableScrollPhysics(),
//           children: const [
//             IconTile(color: Colors.blue, icon: Icons.calendar_today),
//             IconTile(color: Colors.purple, icon: Icons.access_time),
//             IconTile(color: Colors.pink, icon: Icons.people),
//             IconTile(color: Colors.orange, icon: Icons.trending_up),
//           ],
//         ),
//       ),
//     );
//   }
// }
// class IconTile extends StatelessWidget {
//   final Color color;
//   final IconData icon;
//   const IconTile({super.key, required this.color, required this.icon});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(icon, color: Colors.white, size: 20),
//     );
//   }
// }
// class BouncingDots extends StatelessWidget {
//   final AnimationController controller;
//   const BouncingDots({super.key, required this.controller});
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (index) {
//             double delay = index * 0.2;
//             double value = sin((controller.value - delay) * 2 * pi).abs();
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//               width: 8.w,
//               height: 8.h + (value * 6),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

//NEW UI
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_design_demo/presentations/pages/app_dashboard.dart';
import 'package:new_design_demo/presentations/pages/app_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

//  DESIGN TOKENS

const Color _brandStart = Color(0xFF14B8A6);
const Color _brandMid = Color(0xFF0D9488);
const Color _brandDeep = Color(0xFF0F766E);

//  SPLASH SCREEN

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _dotCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigate();
  }

  void _initAnimations() {
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _fadeAnim = CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _mainCtrl, curve: Curves.easeOutCubic));
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 4));
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isLoggedIn ? const AppDashboardScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _floatCtrl.dispose();
    _dotCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  //  BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full-screen teal gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_brandStart, _brandMid, _brandDeep],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Decorative circles
          const Positioned(
            top: -80,
            left: -50,
            child: _GlowCircle(size: 220, opacity: 0.10),
          ),
          const Positioned(
            bottom: -70,
            right: -40,
            child: _GlowCircle(size: 200, opacity: 0.08),
          ),
          const Positioned(
            top: 140,
            right: -60,
            child: _GlowCircle(size: 130, opacity: 0.06),
          ),

          // ── Mesh dot pattern (top-right)
          Positioned(
            top: 60,
            right: 20,
            child: Opacity(
              opacity: 0.12,
              child: SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(painter: _DotGridPainter()),
              ),
            ),
          ),

          // ── Center content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating + pulsing logo
                    // AnimatedBuilder(
                    //   animation: Listenable.merge([_floatAnim, _pulseAnim]),
                    //   builder: (_, child) => Transform.translate(
                    //     offset: Offset(0, _floatAnim.value),
                    //     child: Transform.scale(
                    //       scale: _pulseAnim.value,
                    //       child: child,
                    //     ),
                    //   ),
                    //   child: const _AppIconWidget(),
                    // ),
                    Image(
                      image: AssetImage(
                        "lib/resources/icons/peoplescopeicon.png",
                      ),
                      alignment: AlignmentGeometry.center,
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),

                    // const SizedBox(height: 32),
                    // // App name
                    // const Text(
                    //   "PeopleScope",
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 30,
                    //     fontWeight: FontWeight.w800,
                    //     letterSpacing: -0.5,
                    //   ),
                    // ),
                    const SizedBox(height: 100),

                    // Tagline chips
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tagChip("Attendance"),
                        const SizedBox(width: 6),
                        _tagChip("Leaves"),
                        const SizedBox(width: 6),
                        _tagChip("Growth"),
                      ],
                    ),

                    const SizedBox(height: 36),

                    _BouncingDots(controller: _dotCtrl),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom copyright
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.only(bottom: 10),
                ),
                const Text(
                  "© 2026 PeopleScope. All rights reserved.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

//  GLOW CIRCLE (unchanged logic, cleaner)

class _GlowCircle extends StatefulWidget {
  final double size;
  final double opacity;
  const _GlowCircle({required this.size, required this.opacity});

  @override
  State<_GlowCircle> createState() => _GlowCircleState();
}

class _GlowCircleState extends State<_GlowCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: widget.opacity + (_ctrl.value * 0.08),
        child: Container(
          width: widget.size.w,
          height: widget.size.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

//  BOUNCING DOTS

class _BouncingDots extends StatelessWidget {
  final AnimationController controller;
  const _BouncingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.25;
            final val = sin((controller.value - delay) * 2 * pi).abs();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8.w,
              height: 8.h + (val * 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.50 + val * 0.50),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(val * 0.40),
                    blurRadius: 8,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

//  DOT GRID PAINTER

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const step = 16.0;
    const r = 2.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
