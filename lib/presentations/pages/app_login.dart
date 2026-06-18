// // ignore_for_file: use_build_context_synchronously, deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:new_design_demo/core/app_services/app_permission_services.dart';
// import 'package:new_design_demo/core/app_services/auth_repo.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
// import 'package:new_design_demo/presentations/pages/app_dashboard.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     AppServices.checkInternet();
//     AppServices.checkNotificationPermission();
//   }

//   @override
//   void dispose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   void _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     bool success = await AuthRepo.login(
//       usernameController.text.trim(),
//       passwordController.text.trim(),
//     );

//     if (!mounted) return;

//     setState(() => _isLoading = false);

//     if (success) {
//       await AuthRepo.saveLoginStatus(true);

//       CommonSnackBar.show(
//         context: context,
//         title: "Login",
//         message: "Login Successful.",
//         type: SnackBarType.success,
//       );

//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const AppDashboardScreen()),
//       );
//     } else {
//       CommonSnackBar.show(
//         context: context,
//         title: "Login Failed",
//         message: "Invalid username or password",
//         type: SnackBarType.error,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return WillPopScope(
//       onWillPop: () async => true,
//       child: Scaffold(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildTopSection(context),
//               const SizedBox(height: 50),
//               _buildLoginCard(context),
//               const SizedBox(height: 20),
//               Text(
//                 "Version 1.0.0",
//                 style: AppTextStyles.labelSmall.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//               const SizedBox(height: 5),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopSection(BuildContext context) {
//     Theme.of(context);

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(top: 120, bottom: 70),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color.fromARGB(255, 91, 150, 244),
//             Color.fromARGB(255, 151, 113, 240),
//             Color.fromARGB(255, 231, 91, 161),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: CircleAvatar(
//               // backgroundColor: theme.colorScheme.surface,
//               backgroundColor: Colors.white,
//               radius: 65,
//               child: Image.asset(
//                 "lib/resources/images/People Scope Logo.png",
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "Attendance • Leaves • Updates",
//             style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoginCard(BuildContext context) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: theme.shadowColor.withOpacity(0.15),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Welcome Back!",
//                 style: AppTextStyles.headingMedium.copyWith(
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 "Sign in to continue",
//                 style: AppTextStyles.labelSmall.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               Text("Email Address", style: AppTextStyles.labelMedium),
//               const SizedBox(height: 6),

//               TextFormField(
//                 controller: usernameController,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Username is required";
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Enter Username",
//                   hintStyle: AppTextStyles.labelSmall,
//                   prefixIcon: const Icon(Icons.email_outlined),
//                   prefixIconColor: theme.colorScheme.onSurface,
//                   filled: true,
//                   fillColor: theme.brightness == Brightness.dark
//                       ? const Color(0xFF334155)
//                       : const Color(0xffF2F3F7),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               Text("Password", style: AppTextStyles.labelMedium),
//               const SizedBox(height: 6),

//               TextFormField(
//                 controller: passwordController,
//                 obscureText: _obscurePassword,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Password is required";
//                   }
//                   return null;
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Enter your password",
//                   hintStyle: AppTextStyles.labelSmall,
//                   prefixIcon: const Icon(Icons.lock_outline),
//                   prefixIconColor: theme.colorScheme.onSurface,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   filled: true,
//                   fillColor: theme.brightness == Brightness.dark
//                       ? const Color(0xFF334155)
//                       : const Color(0xffF2F3F7),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               SizedBox(
//                 width: double.infinity,
//                 height: 50.h,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _login,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           "Sign In",
//                           style: AppTextStyles.buttonText.copyWith(
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

///NEW UI

// ignore_for_file: dangling_library_doc_comments, use_build_context_synchronously, deprecated_member_use

// ignore: unnecessary_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:new_design_demo/core/app_services/app_permission_services.dart';
import 'package:new_design_demo/core/app_services/auth_repo.dart';
import 'package:new_design_demo/core/constants/ds_color_handler.dart';
import 'package:new_design_demo/presentations/common_widgets/common_snackbar.dart';
import 'package:new_design_demo/routes/app_routes.dart';



// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Entrance animation
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();
  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _animCtrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slideAnim = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

  // ── LOGIC (unchanged) ───────────────────────────────────────
  @override
  void initState() {
    super.initState();
    AppServices.checkInternet();
    AppServices.checkNotificationPermission();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    try {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _isLoading = true);

      bool success = await AuthRepo.login(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        await AuthRepo.saveLoginStatus(true);
        CommonSnackBar.show(
          context: context,
          title: "Login",
          message: "Login Successful.",
          type: SnackBarType.success,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      } else {
        CommonSnackBar.show(
          context: context,
          title: "Login Failed",
          message: "Invalid username or password",
          type: SnackBarType.error,
        );
      }
    } catch (ex) {
      CommonSnackBar.show(
        context: context,
        message: " Eception :: $ex",
        title: "ERROR",
        type: SnackBarType.error,
      );
      debugPrint("Exception Occurred During Login :: $ex");
    }
  }

  //  BUILD
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: isDark ? DS.surfaceDark : DS.surfaceLight,
        body: Stack(
          children: [
            // ── Full-screen teal gradient top half
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.52,
              child: _gradientBackground(),
            ),

            // ── Scrollable content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _topSection(isDark),
                    _loginCard(isDark),
                    const SizedBox(height: 24),
                    Text(
                      "Version 1.0.0",
                      style: TextStyle(
                        color: isDark ? Colors.white24 : Colors.black26,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GRADIENT BG ─────────────────────────────────────────
  Widget _gradientBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [DS.brandStart, DS.brandMid, DS.brandDeep],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        // Decorative circles
        Positioned(
          right: -50,
          top: -50,
          child: _decorCircle(220, Colors.white.withOpacity(0.06)),
        ),
        Positioned(
          left: -30,
          top: 80,
          child: _decorCircle(120, Colors.white.withOpacity(0.04)),
        ),
        Positioned(
          right: 60,
          bottom: 30,
          child: _decorCircle(80, Colors.white.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ── TOP SECTION (logo + tagline) ────────────────────────
  Widget _topSection(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
        child: Column(
          children: [
            // Logo avatar with glass ring
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    "lib/resources/icons/ic_launcher.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // App name
            const Text(
              "PeopleScope",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Tagline chips row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tagChip("Attendance"),
                const SizedBox(width: 6),
                _tagChip("Leaves"),
                const SizedBox(width: 6),
                _tagChip("Updates"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── LOGIN CARD ──────────────────────────────────────────
  Widget _loginCard(bool isDark) {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? DS.cardDark : DS.cardLight,
              borderRadius: BorderRadius.circular(DS.r24),
              border: Border.all(
                color: isDark ? DS.borderDark : DS.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.40)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DS.brandStart, DS.brandDeep],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: DS.brandStart.withOpacity(0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_open_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            "Sign in to continue",
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Username field
                  _fieldLabel("Username", isDark),
                  const SizedBox(height: 8),
                  _premiumField(
                    controller: usernameController,
                    hint: "Enter your username",
                    prefixIcon: Icons.person_outline_rounded,
                    isDark: isDark,
                    validator: (v) => (v == null || v.isEmpty)
                        ? "Username is required"
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  _fieldLabel("Password", isDark),
                  const SizedBox(height: 8),
                  _premiumField(
                    controller: passwordController,
                    hint: "Enter your password",
                    prefixIcon: Icons.lock_outline_rounded,
                    isDark: isDark,
                    obscure: _obscurePassword,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) => (v == null || v.isEmpty)
                        ? "Password is required"
                        : null,
                  ),

                  const SizedBox(height: 28),

                  // Sign In button
                  _signInButton(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: DS.brandStart,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF334155),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _premiumField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required bool isDark,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.black26,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          size: 20,
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: isDark ? DS.inputDark : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r14),
          borderSide: BorderSide(
            color: isDark ? DS.borderDark : DS.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r14),
          borderSide: const BorderSide(color: DS.brandStart, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DS.r14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
        ),
      ),
    );
  }

  Widget _signInButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading
              ? null
              : const LinearGradient(
                  colors: [DS.brandStart, DS.brandDeep],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isLoading ? (DS.brandStart.withOpacity(0.5)) : null,
          borderRadius: BorderRadius.circular(DS.r14),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: DS.brandStart.withOpacity(0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DS.r14),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.login_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
