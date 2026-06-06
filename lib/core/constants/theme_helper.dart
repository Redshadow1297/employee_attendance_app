import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
    shadowColor: Colors.black26,

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF7C3AED),
      surface: Colors.white,
      onSurface: Color(0xFF0F172A),
      onPrimary: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF020617),
    cardColor: const Color(0xFF0F172A),
    shadowColor: Colors.black54,

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFFA78BFA),
      surface: Color(0xFF0F172A),
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),
  );
}