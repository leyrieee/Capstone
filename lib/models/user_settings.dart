// models/user_settings.dart
class UserSettings {
  bool notificationsEnabled;
  bool darkModeEnabled;
  List<EmergencyContact> emergencyContacts;

  UserSettings({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.emergencyContacts,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkModeEnabled: json['darkModeEnabled'] ?? false,
      emergencyContacts: (json['emergencyContacts'] as List?)
              ?.map((e) => EmergencyContact.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'emergencyContacts': emergencyContacts.map((e) => e.toJson()).toList(),
    };
  }
}

class EmergencyContact {
  String name;
  String phoneNumber;
  bool autoCall;

  EmergencyContact({
    required this.name,
    required this.phoneNumber,
    this.autoCall = false,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      autoCall: json['autoCall'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'autoCall': autoCall,
    };
  }
}
