import 'package:intl/intl.dart';

class Alert {
  final String id;
  final double probability;
  final DateTime timestamp;
  final String alertLevel;
  final bool acknowledged;

  Alert({
    required this.id,
    required this.probability,
    required this.timestamp,
    required this.alertLevel,
    this.acknowledged = false,
  });

  // Format the timestamp for display
  String get formattedTime =>
      DateFormat('MMM d, yyyy - h:mm a').format(timestamp);

  // Format the probability for display
  String get formattedProbability =>
      '${(probability * 100).toStringAsFixed(1)}%';

  // Get color based on alertLevel
  String get colorHex {
    switch (alertLevel) {
      case 'high':
        return '#f44336'; // Red
      case 'medium':
        return '#ff9800'; // Orange
      case 'low':
        return '#4caf50'; // Green
      default:
        return '#2196f3'; // Blue (default)
    }
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    // Parse timestamp correctly based on the actual data type
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();

      if (timestamp is Map) {
        // Handle Firestore timestamp format from JSON
        if (timestamp.containsKey('_seconds')) {
          final seconds = timestamp['_seconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        }

        // Handle another possible timestamp format
        if (timestamp.containsKey('seconds')) {
          final seconds = timestamp['seconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        }
      }

      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }

      return DateTime.now(); // Fallback
    }

    return Alert(
      id: json['id'],
      probability: (json['probability'] ?? 0.0).toDouble(),
      timestamp: parseTimestamp(json['alert_time']),
      alertLevel: json['alert_message'] ?? 'unknown',
      acknowledged: json['acknowledged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seizure_probability': probability,
      'timestamp': timestamp.toIso8601String(),
      'alert_level': alertLevel,
      'acknowledged': acknowledged,
    };
  }
}
