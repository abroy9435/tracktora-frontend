import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  static late SharedPreferences _prefs;

  // Initialize in main.dart before runApp()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Generic JSON Save/Load ---
  static Future<void> _saveJson(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  static dynamic _getJson(String key) {
    String? data = _prefs.getString(key);
    return data != null ? jsonDecode(data) : null;
  }

  // --- User Profile ---
  static Future<void> setProfile(Map<String, dynamic> data) => _saveJson('cached_profile', data);
  static Map<String, dynamic>? getProfile() => _getJson('cached_profile') as Map<String, dynamic>?;

  // --- Dashboard Stats ---
  static Future<void> setStats(Map<String, dynamic> data) => _saveJson('cached_stats', data);
  static Map<String, dynamic>? getStats() => _getJson('cached_stats') as Map<String, dynamic>?;

  // --- NEW: Application List Cache ---
  static Future<void> setApplications(List<dynamic> apps) => _saveJson('cached_applications', apps);
  
  static List<dynamic>? getApplications() {
    final data = _getJson('cached_applications');
    return data != null ? (data as List<dynamic>) : null;
  }

  // --- Theme Preference ---
  static Future<void> setThemeMode(String mode) async => await _prefs.setString('theme_mode', mode);
  static String getThemeMode() => _prefs.getString('theme_mode') ?? 'system';

  // --- Clear on Logout ---
  static Future<void> clear() async => await _prefs.clear();
}