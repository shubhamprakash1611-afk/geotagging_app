import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_data.dart';

class SettingsService {
  static const String _settingsKey = 'app_settings';

  static Future<SettingsData> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_settingsKey);
      if (jsonStr != null) {
        final Map<String, dynamic> json = jsonDecode(jsonStr);
        return SettingsData.fromJson(json);
      }
    } catch (e) {
      // Ignored
    }
    return SettingsData.defaultSettings;
  }

  static Future<void> saveSettings(SettingsData settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(settings.toJson());
      await prefs.setString(_settingsKey, jsonStr);
    } catch (e) {
      // Ignored
    }
  }
}

