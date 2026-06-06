// // ignore_for_file: duplicate_ignore, deprecated_member_use

// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   Map<String, dynamic>? userData;
//   bool isLoading = true;
//   int? emppk;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     emppk = prefs.getInt('emppk');
//     getUserDetails();
//   }

//   Future<void> getUserDetails() async {
//     try {
//       final response = await ApiClient.get(
//         ApiConstants.getUserProfile,
//         query: {"Emp_PK": emppk},
//       );

//       final data = response.data;

//       if (data != null && data is List && data.isNotEmpty) {
//         setState(() {
//           userData = data[0];
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       debugPrint("API Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : userData == null
//           ? Center(
//               child: Text(
//                 "No Data Found",
//                 style: TextStyle(color: theme.colorScheme.onSurface),
//               ),
//             )
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   _buildHeader(context),
//                   const SizedBox(height: 20),
//                   _buildSection(
//                     context: context,
//                     title: "Employment Details",
//                     icon: Icons.work_outline,
//                     children: [
//                       profileRow(
//                         context,
//                         "Employee Code",
//                         userData!['Employee_Code'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "Department",
//                         userData!['Dept_Name'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "Designation",
//                         userData!['Designation_Title'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "Join Date",
//                         userData!['Join_Date'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "Location",
//                         userData!['Location_Name'] ?? '',
//                       ),
//                     ],
//                   ),

//                   _buildSection(
//                     context: context,
//                     title: "Personal Details",
//                     icon: Icons.person_outline,
//                     children: [
//                       profileRow(
//                         context,
//                         "Date of Birth",
//                         userData!['Birth_Date'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "Blood Group",
//                         userData!['BloodGroupCode'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "UID Number",
//                         userData!['UID_NUMBER'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "PAN Number",
//                         userData!['PAN_No'] ?? '',
//                       ),
//                     ],
//                   ),

//                   _buildSection(
//                     context: context,
//                     title: "Contact Information",
//                     icon: Icons.phone_outlined,
//                     children: [
//                       profileRow(
//                         context,
//                         "Mobile Number",
//                         userData!['Mobile_Number'] ?? '',
//                       ),
//                       profileRow(
//                         context,
//                         "Phone Number",
//                         userData!['Phone_Number'] ?? '',
//                       ),
//                       profileRow(context, "Email", userData!['EmailID'] ?? ''),
//                     ],
//                   ),

//                   const SizedBox(height: 30),

//                   _buildSection(
//                     context: context,
//                     title: "Other Details",
//                     icon: Icons.info_outline,
//                     children: userData!.entries.map((entry) {
//                       final key = entry.key;
//                       final value = entry.value?.toString() ?? '';

//                       // Skip already shown fields + photo
//                       final hiddenFields = [
//                         'photo',
//                         'Name',
//                         'Employee_Code',
//                         'Dept_Name',
//                         'Designation_Title',
//                         'Join_Date',
//                         'Location_Name',
//                         'Birth_Date',
//                         'BloodGroupCode',
//                         'UID_NUMBER',
//                         'PAN_No',
//                         'Mobile_Number',
//                         'Phone_Number',
//                         'EmailID',
//                       ];

//                       if (hiddenFields.contains(key) || value.trim().isEmpty) {
//                         return const SizedBox.shrink();
//                       }

//                       return profileRow(
//                         context,
//                         key.replaceAll('_', ' '),
//                         value,
//                       );
//                     }).toList(),
//                   ),

//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//     );
//   }

//   ImageProvider<Object> buildBase64Image(String base64String) {
//     try {
//       Uint8List bytes = base64Decode(base64String);
//       return MemoryImage(bytes);
//     } catch (e) {
//       return const AssetImage('lib/resources/icons/userpro.jpg');
//     }
//   }

//   Widget _buildHeader(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.only(top: 60, bottom: 40),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           // colors: [Color(0xff5B4DFF), Color(0xff3E2DCC)],
//           colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
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
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(18, 1, 0, 0),
//                 child: InkWell(
//                   onTap: () => Navigator.pop(context),
//                   child: CircleAvatar(
//                     backgroundColor: Colors.white.withOpacity(0.15),
//                     child: const Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           CircleAvatar(
//             radius: 50,
//             backgroundColor: theme.colorScheme.surface,
//             child: CircleAvatar(
//               radius: 45,
//               backgroundImage: buildBase64Image(userData!['photo'] ?? ""),
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             userData!['Name'] ?? '',
//             style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             userData!['Designation_Title'] ?? '',
//             style: AppTextStyles.labelMedium.copyWith(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSection({
//     required BuildContext context,
//     required String title,
//     required IconData icon,
//     required List<Widget> children,
//   }) {
//     final theme = Theme.of(context);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.15),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: theme.colorScheme.primary),
//               const SizedBox(width: 8),
//               Text(
//                 title,
//                 style: AppTextStyles.headingSmall.copyWith(
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget profileRow(BuildContext context, String title, String value) {
//     final theme = Theme.of(context);

//     if (value.trim().isEmpty) return const SizedBox();

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: AppTextStyles.labelSmall.copyWith(
//               color: theme.colorScheme.onSurface.withOpacity(0.6),
//               fontSize: 12,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: AppTextStyles.labelMedium.copyWith(
//               color: theme.colorScheme.onSurface,
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Divider(color: theme.dividerColor),
//         ],
//       ),
//     );
//   }
// }





// New UI

// ignore_for_file: duplicate_ignore, deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  DESIGN TOKENS
// ─────────────────────────────────────────────────────────────
class _DS {
  static const Color brandStart = Color(0xFF14B8A6);
  static const Color brandMid   = Color(0xFF0D9488);
  static const Color brandDeep  = Color(0xFF0F766E);

  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color borderLight  = Color(0xFFE2E8F0);

  static const Color surfaceDark  = Color(0xFF0F172A);
  static const Color cardDark     = Color(0xFF1E293B);
  static const Color borderDark   = Color(0xFF334155);

  // static const double r16 = 16;
  static const double r20 = 20;
  // static const double r24 = 24;
}

// ─── SECTION CONFIG ──────────────────────────────────────────
class _SectionConfig {
  final String   title;
  final IconData icon;
  final Color    color;
  const _SectionConfig(this.title, this.icon, this.color);
}

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int? emppk;

  late final AnimationController _animCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

  // ── LOGIC (unchanged) ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    emppk = prefs.getInt('emppk');
    getUserDetails();
  }

  Future<void> getUserDetails() async {
    try {
      final response = await ApiClient.get(
        ApiConstants.getUserProfile,
        query: {"Emp_PK": emppk},
      );
      final data = response.data;
      if (data != null && data is List && data.isNotEmpty) {
        setState(() {
          userData  = data[0];
          isLoading = false;
        });
        _animCtrl.forward();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("API Error: $e");
    }
  }

  ImageProvider<Object> buildBase64Image(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      return MemoryImage(bytes);
    } catch (_) {
      return const AssetImage('lib/resources/icons/userpro.jpg');
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
      body: isLoading
          ? _loadingState()
          : userData == null
              ? _emptyState(isDark)
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _premiumSliverHeader(isDark),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: Column(
                            children: [
                              _infoStrip(isDark),
                              const SizedBox(height: 20),
                              _section(
                                isDark: isDark,
                                cfg: const _SectionConfig(
                                  "Employment Details",
                                  Icons.work_outline_rounded,
                                  Color(0xFF3B82F6),
                                ),
                                rows: [
                                  _Row("Employee Code",  userData!['Employee_Code']      ?? ''),
                                  _Row("Department",     userData!['Dept_Name']           ?? ''),
                                  _Row("Designation",    userData!['Designation_Title']   ?? ''),
                                  _Row("Join Date",      userData!['Join_Date']           ?? ''),
                                  _Row("Location",       userData!['Location_Name']       ?? ''),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _section(
                                isDark: isDark,
                                cfg: const _SectionConfig(
                                  "Personal Details",
                                  Icons.person_outline_rounded,
                                  Color(0xFF8B5CF6),
                                ),
                                rows: [
                                  _Row("Date of Birth", userData!['Birth_Date']      ?? ''),
                                  _Row("Blood Group",   userData!['BloodGroupCode']   ?? ''),
                                  _Row("UID Number",    userData!['UID_NUMBER']       ?? ''),
                                  _Row("PAN Number",    userData!['PAN_No']           ?? ''),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _section(
                                isDark: isDark,
                                cfg: const _SectionConfig(
                                  "Contact Information",
                                  Icons.phone_outlined,
                                  Color(0xFF10B981),
                                ),
                                rows: [
                                  _Row("Mobile",  userData!['Mobile_Number'] ?? ''),
                                  _Row("Phone",   userData!['Phone_Number']  ?? ''),
                                  _Row("Email",   userData!['EmailID']       ?? ''),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _otherDetailsSection(isDark),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // ─── LOADING / EMPTY ─────────────────────────────────────
  Widget _loadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: _DS.brandStart, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text("Loading profile…",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _DS.brandStart.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_off_outlined,
                color: _DS.brandStart, size: 40),
          ),
          const SizedBox(height: 16),
          Text("No Profile Data",
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
                fontSize: 15, fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  // ─── SLIVER HEADER ───────────────────────────────────────
  Widget _premiumSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: _DS.brandDeep,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 16),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          children: [
            // Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_DS.brandStart, _DS.brandMid, _DS.brandDeep],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Decor circles
            Positioned(right: -40, top: -40,
              child: _decorCircle(180, Colors.white.withOpacity(0.06))),
            Positioned(left: -20, bottom: 40,
              child: _decorCircle(100, Colors.white.withOpacity(0.04))),
            Positioned(right: 80, bottom: 20,
              child: _decorCircle(60, Colors.white.withOpacity(0.05))),

            // Content
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20, offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      backgroundImage: buildBase64Image(userData!['photo'] ?? ""),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Name
                  Text(
                    userData!['Name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Designation chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      userData!['Designation_Title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  // ─── INFO STRIP (quick stats below header) ───────────────
  Widget _infoStrip(bool isDark) {
    final dept   = userData!['Dept_Name']       ?? '—';
    final code   = userData!['Employee_Code']   ?? '—';
    final loc    = userData!['Location_Name']   ?? '—';

    return Container(
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
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _stripTile(Icons.badge_outlined,         "Code",       code,   const Color(0xFF3B82F6), isDark)),
          _stripDivider(isDark),
          Expanded(child: _stripTile(Icons.corporate_fare_rounded, "Department", dept,   const Color(0xFF8B5CF6), isDark)),
          _stripDivider(isDark),
          Expanded(child: _stripTile(Icons.location_on_outlined,   "Location",   loc,    const Color(0xFF10B981), isDark)),
        ],
      ),
    );
  }

  Widget _stripTile(IconData icon, String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _stripDivider(bool isDark) => Container(
    width: 1, height: 44,
    color: isDark ? Colors.white10 : Colors.black38,
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );

  // ─── SECTION CARD ────────────────────────────────────────
  Widget _section({
    required bool isDark,
    required _SectionConfig cfg,
    required List<_Row> rows,
  }) {
    final filtered = rows.where((r) => r.value.trim().isNotEmpty).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r20),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.05),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: cfg.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cfg.color.withOpacity(0.2)),
                  ),
                  child: Icon(cfg.icon, color: cfg.color, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  cfg.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(color: cfg.color, shape: BoxShape.circle),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: isDark ? _DS.borderDark : _DS.borderLight),

          // Rows
          ...filtered.asMap().entries.map((e) {
            final isLast = e.key == filtered.length - 1;
            return _profileRow(e.value.label, e.value.value, isDark, isLast);
          }),
        ],
      ),
    );
  }

  Widget _profileRow(String label, String value, bool isDark, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 130,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16, endIndent: 16,
            color: isDark ? _DS.borderDark : _DS.borderLight,
          ),
      ],
    );
  }

  // ─── OTHER DETAILS SECTION ───────────────────────────────
  Widget _otherDetailsSection(bool isDark) {
    const hiddenFields = [
      'photo', 'Name', 'Employee_Code', 'Dept_Name', 'Designation_Title',
      'Join_Date', 'Location_Name', 'Birth_Date', 'BloodGroupCode',
      'UID_NUMBER', 'PAN_No', 'Mobile_Number', 'Phone_Number', 'EmailID',
    ];

    final others = userData!.entries
        .where((e) => !hiddenFields.contains(e.key) &&
            (e.value?.toString() ?? '').trim().isNotEmpty)
        .map((e) => _Row(e.key.replaceAll('_', ' '), e.value?.toString() ?? ''))
        .toList();

    if (others.isEmpty) return const SizedBox.shrink();

    return _section(
      isDark: isDark,
      cfg: const _SectionConfig(
        "Other Details",
        Icons.info_outline_rounded,
        Color(0xFFF59E0B),
      ),
      rows: others,
    );
  }
}

// ─── DATA HELPERS ─────────────────────────────────────────────
class _Row {
  final String label;
  final String value;
  const _Row(this.label, this.value);
}