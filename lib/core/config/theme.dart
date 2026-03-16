import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors from the Cyberpunk Tiger logo
  static const Color darkBg = Color(0xFF111827);
  static const Color neonCrimson = Color(0xFFFB7185);
  static const Color accentCoral = Color(0xFFF43F5E);

  // --- DARK THEME ---
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: neonCrimson,
      secondary: accentCoral,
      surface: Color(0xFF1F2937),
    ),
    inputDecorationTheme: _inputTheme(neonCrimson),
    filledButtonTheme: _buttonTheme(neonCrimson),
  );

  // --- LIGHT THEME ---
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: accentCoral,
      secondary: neonCrimson,
      surface: Color(0xFFF3F4F6),
    ),
    inputDecorationTheme: _inputTheme(accentCoral),
    filledButtonTheme: _buttonTheme(accentCoral),
  );

  static InputDecorationTheme _inputTheme(Color color) => InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: color)),
  );

  static FilledButtonThemeData _buttonTheme(Color color) => FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}