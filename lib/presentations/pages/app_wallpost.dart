// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:new_design_demo/core/api/api_client.dart';
// import 'package:new_design_demo/core/api/api_constants.dart';
// import 'package:new_design_demo/core/constants/app_text_styles.dart';
// import 'package:new_design_demo/presentations/common_widgets/common_button.dart';

// class WallPostScreen extends StatefulWidget {
//   const WallPostScreen({super.key});

//   @override
//   State<WallPostScreen> createState() => _WallPostScreenState();
// }

// class _WallPostScreenState extends State<WallPostScreen> {
//   List<Map<String, dynamic>> posts = [];
//   bool isLoading = true;
//   bool showCreatePost = false;

//   final TextEditingController postController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     loadPosts();
//   }

//   @override
//   void dispose() {
//     postController.dispose();
//     super.dispose();
//   }

//   Future<List<Map<String, dynamic>>> getWallPosts() async {
//     try {
//       final response = await ApiClient.get(ApiConstants.getWallPosts);

//       final data = response.data;

//       if (data is List) {
//         return List<Map<String, dynamic>>.from(data);
//       }

//       return [];
//     } catch (e) {
//       debugPrint("Wall Posts Error: $e");
//       return [];
//     }
//   }

//   Future<void> loadPosts() async {
//     setState(() => isLoading = true);

//     final data = await getWallPosts();

//     setState(() {
//       posts = data;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               _header(context),
//               Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(top: showCreatePost ? 180 : 20),
//                   child: isLoading
//                       ? Center(
//                           child: CircularProgressIndicator(
//                             color: theme.colorScheme.primary,
//                           ),
//                         )
//                       : posts.isEmpty
//                           ? Center(
//                               child: Text(
//                                 "No WallPosts available",
//                                 style: AppTextStyles.labelMedium.copyWith(
//                                   color: theme.colorScheme.onSurface
//                                       .withOpacity(0.6),
//                                 ),
//                               ),
//                             )
//                           : RefreshIndicator(
//                               onRefresh: loadPosts,
//                               child: ListView.builder(
//                                 padding: const EdgeInsets.all(16),
//                                 itemCount: posts.length,
//                                 itemBuilder: (context, index) {
//                                   return _wallPostCard(context, posts[index]);
//                                 },
//                               ),
//                             ),
//                 ),
//               ),
//             ],
//           ),
//           if (showCreatePost)
//             Positioned(
//               top: 210,
//               left: 16,
//               right: 16,
//               child: _createPostCard(context),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _header(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
//       height: 220,
//       padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF5F7CE6), Color(0xFF1E3FD3)],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           InkWell(
//             onTap: () => Navigator.pop(context),
//             child: CircleAvatar(
//               backgroundColor: Colors.white.withOpacity(0.15),
//               child: const Icon(Icons.arrow_back, color: Colors.white),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Wall Posts",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Team Updates & Announcements",
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//               ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.surface,
//                   foregroundColor: theme.colorScheme.primary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     showCreatePost = !showCreatePost;
//                   });
//                 },
//                 icon: const Icon(Icons.add, size: 18),
//                 label: const Text("Post"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _wallPostCard(BuildContext context, Map<String, dynamic> post) {
//     final theme = Theme.of(context);

//     final name = post["Name"] ?? "";
//     final title = post["Title"] ?? "";
//     final postTime = post["ActualPostTime"] ?? "";
//     final postText = post["PostText"] ?? "";
//     final photo = post["photo"] ?? "";

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.15),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             name,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             title,
//             style: TextStyle(
//               color: theme.colorScheme.onSurface.withOpacity(0.7),
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             postTime,
//             style: TextStyle(
//               color: theme.colorScheme.onSurface.withOpacity(0.5),
//               fontSize: 11,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Html(data: postText),
//           if (photo.toString().isNotEmpty &&
//               photo.toString() != "System.Byte[]")
//             Padding(
//               padding: const EdgeInsets.only(top: 10),
//               child: Image.network(photo),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _createPostCard(BuildContext context) {
//     final theme = Theme.of(context);

//     return Container(
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
//           Text(
//             "Create Post",
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//               color: theme.colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             decoration: BoxDecoration(
//               color: theme.brightness == Brightness.dark
//                   ? const Color(0xFF334155)
//                   : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: theme.dividerColor),
//             ),
//             child: const TextField(
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: "This Feature is Under Development",
//                 border: InputBorder.none,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               const Spacer(),
//               CommonButton(
//                 width: 100.w,
//                 height: 40.h,
//                 color: theme.colorScheme.primary,
//                 label: "Publish",
//                 onPressed: () {
//                   setState(() {
//                     showCreatePost = false;
//                   });
//                 },
//               ),
//               const SizedBox(width: 8),
//               CommonButton(
//                 width: 100.w,
//                 height: 40.h,
//                 // color: theme.dividerColor,
//                 color: theme.colorScheme.primary,
//                 label: "Cancel",
//                 textColor: theme.colorScheme.onSurface,
//                 onPressed: () {
//                   setState(() {
//                     showCreatePost = false;
//                   });
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


// ////// New UI
// ignore_for_file: deprecated_member_use


import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:new_design_demo/core/api/api_client.dart';
import 'package:new_design_demo/core/api/api_constants.dart';

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
  static const Color inputDark    = Color(0xFF263244);

  // static const double r16 = 16;
  static const double r20 = 20;
  // static const double r24 = 24;
}

// ─────────────────────────────────────────────────────────────
//  SCREEN
// ─────────────────────────────────────────────────────────────
class WallPostScreen extends StatefulWidget {
  const WallPostScreen({super.key});

  @override
  State<WallPostScreen> createState() => _WallPostScreenState();
}

class _WallPostScreenState extends State<WallPostScreen>
    with SingleTickerProviderStateMixin {

  List<Map<String, dynamic>> posts = [];
  bool isLoading       = true;
  bool showCreatePost  = false;

  final TextEditingController postController = TextEditingController();

  // Slide animation for create-post panel
  late final AnimationController _panelCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 300),
  );
  late final Animation<Offset> _panelSlide = Tween<Offset>(
    begin: const Offset(0, -0.04), end: Offset.zero,
  ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOut));
  late final Animation<double> _panelFade =
      CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOut);

  // ── LOGIC (unchanged) ────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  @override
  void dispose() {
    postController.dispose();
    _panelCtrl.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> getWallPosts() async {
    try {
      final response = await ApiClient.get(ApiConstants.getWallPosts);
      final data = response.data;
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } catch (e) {
      debugPrint("Wall Posts Error: $e");
      return [];
    }
  }

  Future<void> loadPosts() async {
    setState(() => isLoading = true);
    final data = await getWallPosts();
    setState(() {
      posts     = data;
      isLoading = false;
    });
  }

  void _toggleCreatePost() {
    setState(() => showCreatePost = !showCreatePost);
    if (showCreatePost) {
      _panelCtrl.forward(from: 0);
    } else {
      _panelCtrl.reverse();
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
      body: Stack(
        children: [
          Column(
            children: [
              _header(isDark),
              // Create post panel (animated)
              if (showCreatePost)
                FadeTransition(
                  opacity: _panelFade,
                  child: SlideTransition(
                    position: _panelSlide,
                    child: _createPostPanel(isDark),
                  ),
                ),
              Expanded(child: _body(isDark)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── PREMIUM HEADER ──────────────────────────────────────
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
          // Decor circles
          Positioned(right: -40, top: -40,
            child: _decorCircle(160, Colors.white.withOpacity(0.06))),
          Positioned(left: -20, bottom: 10,
            child: _decorCircle(90, Colors.white.withOpacity(0.04))),
          Positioned(right: 70, bottom: 0,
            child: _decorCircle(60, Colors.white.withOpacity(0.04))),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
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
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Wall Posts",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Posts count chip
                            if (!isLoading)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.feed_outlined,
                                        color: Colors.white70, size: 12),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${posts.length} Team Updates",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // New Post button
                      GestureDetector(
                        onTap: _toggleCreatePost,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: showCreatePost
                                ? Colors.white.withOpacity(0.30)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10, offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                showCreatePost ? Icons.close_rounded : Icons.add_rounded,
                                size: 18,
                                color: showCreatePost
                                    ? Colors.white
                                    : _DS.brandDeep,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                showCreatePost ? "Cancel" : "New Post",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: showCreatePost
                                      ? Colors.white
                                      : _DS.brandDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

  // ─── CREATE POST PANEL ───────────────────────────────────
  Widget _createPostPanel(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r20),
        border: Border.all(color: isDark ? _DS.borderDark : _DS.borderLight),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : _DS.brandStart.withOpacity(0.12),
            blurRadius: 20, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_DS.brandStart, _DS.brandDeep],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _DS.brandStart.withOpacity(0.35), blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(Icons.edit_outlined,
                    color: Colors.white, size: 17),
              ),
              const SizedBox(width: 12),
              Text(
                "Create a Post",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 15, fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? _DS.inputDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: isDark ? _DS.borderDark : _DS.borderLight),
            ),
            child: TextField(
              controller: postController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: "This feature is under development…",
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontSize: 13,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionBtn(
                label: "Cancel",
                icon: Icons.close_rounded,
                color: isDark ? Colors.white24 : Colors.black12,
                textColor: isDark ? Colors.white54 : Colors.black45,
                onTap: _toggleCreatePost,
              ),
              const SizedBox(width: 10),
              _actionBtn(
                label: "Publish",
                icon: Icons.send_rounded,
                gradient: const LinearGradient(
                  colors: [_DS.brandStart, _DS.brandDeep],
                ),
                textColor: Colors.white,
                onTap: _toggleCreatePost,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color textColor,
    required VoidCallback onTap,
    Color? color,
    Gradient? gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: gradient != null
              ? [BoxShadow(
                  color: _DS.brandStart.withOpacity(0.30),
                  blurRadius: 10, offset: const Offset(0, 4),
                )]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: textColor),
            const SizedBox(width: 6),
            Text(label,
              style: TextStyle(
                color: textColor, fontSize: 13, fontWeight: FontWeight.w600,
              )),
          ],
        ),
      ),
    );
  }

  // ─── BODY (list / loading / empty) ───────────────────────
  Widget _body(bool isDark) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _DS.brandStart, strokeWidth: 2.5),
            SizedBox(height: 16),
            Text("Loading posts…",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
          ],
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _DS.brandStart.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.feed_outlined,
                  color: _DS.brandStart, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              "No posts yet",
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black38,
                fontSize: 15, fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Be the first to share an update!",
              style: TextStyle(
                color: isDark ? Colors.white30 : Colors.black26,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadPosts,
      color: _DS.brandStart,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: posts.length,
        itemBuilder: (context, index) =>
            _wallPostCard(posts[index], isDark, index),
      ),
    );
  }

  // ─── WALL POST CARD ──────────────────────────────────────
  Widget _wallPostCard(Map<String, dynamic> post, bool isDark, int index) {
    final name     = post["Name"]           ?? "";
    final title    = post["Title"]          ?? "";
    final postTime = post["ActualPostTime"] ?? "";
    final postText = post["PostText"]       ?? "";
    final photo    = post["photo"]          ?? "";
    final isNew    = post["IsNew"] == true;

    // Avatar initials
    final initials = name.isNotEmpty
        ? name.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase()
        : "?";

    // Color from index
    final avatarColors = [
      const Color(0xFF3B82F6), const Color(0xFF8B5CF6),
      const Color(0xFF10B981), const Color(0xFFF59E0B),
      const Color(0xFFEF4444), const Color(0xFF06B6D4),
    ];
    final avatarColor = avatarColors[index % avatarColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? _DS.cardDark : _DS.cardLight,
        borderRadius: BorderRadius.circular(_DS.r20),
        border: Border.all(
          color: isNew
              ? _DS.brandStart.withOpacity(0.5)
              : (isDark ? _DS.borderDark : _DS.borderLight),
          width: isNew ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : (isNew
                    ? _DS.brandStart.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05)),
            blurRadius: 16, offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [avatarColor.withOpacity(0.8), avatarColor],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: avatarColor.withOpacity(0.30), blurRadius: 8,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + title + time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 14, fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _DS.brandStart.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _DS.brandStart.withOpacity(0.4)),
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  color: _DS.brandStart,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (title.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          title,
                          style: TextStyle(
                            color: avatarColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11,
                              color: isDark ? Colors.white30 : Colors.black26),
                          const SizedBox(width: 4),
                          Text(
                            postTime,
                            style: TextStyle(
                              color: isDark ? Colors.white30 : Colors.black26,
                              fontSize: 11,
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

          // Divider
          Divider(height: 1,
              color: isDark ? _DS.borderDark : _DS.borderLight),

          // ── Post content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Html(
              data: postText,
              style: {
                "body": Style(
                  fontSize: FontSize(13),
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          ),

          // ── Attached image
          if (photo.toString().isNotEmpty &&
              photo.toString() != "System.Byte[]")
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(_DS.r20),
                bottomRight: Radius.circular(_DS.r20),
              ),
              child: Image.network(
                photo,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }
}
