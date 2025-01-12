import 'dart:convert'; // for jsonEncode dan jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

class VeinStorage {
  // Singleton instance
  static final VeinStorage _instance = VeinStorage._internal();

  factory VeinStorage() {
    return _instance;
  }

  VeinStorage._internal();

  late SharedPreferences _prefs;

  // Initialize the storage
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set value (key-value pair)
  Future<void> write(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else if (value is Map || value is List) {
      // Serialize Map or List to JSON String
      await _prefs.setString(key, jsonEncode(value));
    } else {
      throw Exception('Unsupported value type');
    }
  }

  // Read value
  dynamic read(String key) {
    String? storedValue = _prefs.getString(key);

    // Check if the value is a JSON string
    if (storedValue != null) {
      try {
        return jsonDecode(storedValue); // Decode JSON String to Map or List
      } catch (e) {
        return storedValue; // Return as string if not JSON
      }
    }

    // Return other types directly
    return _prefs.get(key);
  }

  // Remove value
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Clear all data
  Future<void> clear() async {
    await _prefs.clear();
  }

  // Check if a key exists
  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
}
