import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_location.dart';

class SavedLocationService {
  static const String _key = 'saved_locations';

  static Future<List<SavedLocation>> loadLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? jsonList = prefs.getStringList(_key);
      if (jsonList != null) {
        return jsonList.map((str) => SavedLocation.fromJson(jsonDecode(str))).toList();
      }
    } catch (e) {
      // Ignored
    }
    return [];
  }

  static Future<void> saveLocations(List<SavedLocation> locations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> jsonList = locations.map((l) => jsonEncode(l.toJson())).toList();
      await prefs.setStringList(_key, jsonList);
    } catch (e) {
      // Ignored
    }
  }
}

