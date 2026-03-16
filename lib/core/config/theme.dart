import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (Emerald/Forest Green Vibe)
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color darkBg = Color(0xFF111827);

  // --- LIGHT THEME ---
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: Color(0xFF059669),
      surface: Color(0xFFF3F4F6),
    ),
    inputDecorationTheme: _inputTheme(primaryGreen, Colors.grey.shade100),
    filledButtonTheme: _buttonTheme(primaryGreen),
  );

  // --- DARK THEME ---
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: Color(0xFF34D399),
      surface: Color(0xFF1F2937),
    ),
    inputDecorationTheme: _inputTheme(primaryGreen, const Color(0xFF1F2937)),
    filledButtonTheme: _buttonTheme(primaryGreen),
  );

  // Centralized Input Logic
  static InputDecorationTheme _inputTheme(Color brandColor, Color fillColor) => InputDecorationTheme(
    filled: true,
    fillColor: fillColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: brandColor, width: 2)),
  );

  // Centralized Button Logic
  static FilledButtonThemeData _buttonTheme(Color color) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white, // Text inside green buttons is always white
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}