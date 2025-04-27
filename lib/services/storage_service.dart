// services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import 'dart:convert';

class StorageService {
  // Save user settings
  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_settings', jsonEncode(settings.toJson()));
  }

  // Load user settings
  Future<UserSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('user_settings');

    if (settingsJson != null) {
      return UserSettings.fromJson(jsonDecode(settingsJson));
    }

    // Return default settings if none exist
    return UserSettings(
      notificationsEnabled: true,
      darkModeEnabled: false,
      emergencyContacts: [],
    );
  }

  // Save device ID
  Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_id', deviceId);
  }

  // Get device ID
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_id') ?? '';
  }
}
