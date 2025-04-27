// services/backend_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackendService {
  // Get device ID from storage
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = prefs.getString('device_id') ?? 'device1';
    print('Retrieved device_id: $deviceId');
    return deviceId;
  }

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      final deviceId = await _getDeviceId();
      if (deviceId.isEmpty) {
        print('Error: Device ID is empty');
        return false;
      }

      // Simple test call to one of your endpoints
      final response = await http.get(
        Uri.parse('https://getlatestprobability-f6g3fpaieq-uc.a.run.app'),
      );

      print(
          'Test connection response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Test connection failed: $e');
      return false;
    }
  }

  // Update FCM token on backend
  Future<void> updateFcmToken(String token) async {
    print('Updating FCM token: $token');
    final deviceId = await _getDeviceId();
    if (deviceId.isEmpty) {
      print('Cannot update FCM token: device_id is empty');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://updatefcmtoken-f6g3fpaieq-uc.a.run.app'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': deviceId,
          'fcm_token': token,
        }),
      );

      print(
          'FCM token update response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        print('Failed to update FCM token: ${response.body}');
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Get latest probability reading
  Future<double> getLatestProbability() async {
    print('Fetching latest probability');
    final deviceId = await _getDeviceId();
    if (deviceId.isEmpty) {
      print('Cannot fetch probability: device_id is empty');
      return 0.0;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://getlatestprobability-f6g3fpaieq-uc.a.run.app?device_id=$deviceId'),
      );

      print(
          'Latest probability response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['probability'] as double;
      } else {
        print(
            'Failed to get latest probability: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching latest probability: $e');
    }

    return 0.0;
  }

  // Get historical alert data
  Future<List<Alert>> getAlertHistory({int limit = 50}) async {
    print('Fetching alert history');
    final deviceId = await _getDeviceId();
    if (deviceId.isEmpty) {
      print('Cannot fetch alert history: device_id is empty');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://getalerthistory-f6g3fpaieq-uc.a.run.app?device_id=$deviceId&limit=$limit'),
      );

      print(
          'Alert history response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Alert.fromJson(item)).toList();
      } else {
        print(
            'Failed to get alert history: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching alert history: $e');
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> getRecentReadings({int count = 20}) async {
    print('Fetching recent readings');
    final deviceId = await _getDeviceId();
    if (deviceId.isEmpty) {
      print('Cannot fetch recent readings: device_id is empty');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://getrecentreadings-f6g3fpaieq-uc.a.run.app?device_id=$deviceId&count=$count',
        ),
      );

      print(
          'Recent readings response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print(
            'Failed to get recent readings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching recent readings: $e');
    }

    return [];
  }

  // Acknowledge an alert
  Future<bool> acknowledgeAlert(String alertId) async {
    print('Acknowledging alert: $alertId');
    final deviceId = await _getDeviceId();
    if (deviceId.isEmpty) {
      print('Cannot acknowledge alert: device_id is empty');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('https://acknowledgealert-f6g3fpaieq-uc.a.run.app'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_id': deviceId, 'alert_id': alertId}),
      );

      print(
          'Acknowledge alert response: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error acknowledging alert: $e');
      return false;
    }
  }
}
