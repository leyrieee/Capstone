// providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../models/user_settings.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storageService;
  late UserSettings _settings;
  bool _loaded = false;

  SettingsProvider(this._storageService) {
    _loadSettings();
  }

  void update(StorageService storageService) {
    // This method is called when the StorageService is updated
  }

  // Getters
  bool get notificationsEnabled =>
      _loaded ? _settings.notificationsEnabled : true;
  bool get darkModeEnabled => _loaded ? _settings.darkModeEnabled : false;
  List<EmergencyContact> get emergencyContacts =>
      _loaded ? _settings.emergencyContacts : [];
  bool get isLoaded => _loaded;

  Future<void> _loadSettings() async {
    _settings = await _storageService.getSettings();
    _loaded = true;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _settings.notificationsEnabled = value;
    await _saveSettings();
  }

  Future<void> toggleDarkMode(bool value) async {
    _settings.darkModeEnabled = value;
    await _saveSettings();
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    _settings.emergencyContacts.add(contact);
    await _saveSettings();
  }

  Future<void> removeEmergencyContact(int index) async {
    if (index >= 0 && index < _settings.emergencyContacts.length) {
      _settings.emergencyContacts.removeAt(index);
      await _saveSettings();
    }
  }

  Future<void> updateEmergencyContact(
      int index, EmergencyContact contact) async {
    if (index >= 0 && index < _settings.emergencyContacts.length) {
      _settings.emergencyContacts[index] = contact;
      await _saveSettings();
    }
  }

  Future<void> _saveSettings() async {
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }
}
