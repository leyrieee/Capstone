// providers/alerts_provider.dart
import 'package:flutter/foundation.dart';
import '../services/backend_service.dart';
import '../models/alert.dart';
import 'package:intl/intl.dart';

class AlertsProvider with ChangeNotifier {
  final BackendService _backendService;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Alert> _alerts = [];
  List<Map<String, dynamic>> _recentReadings = List.generate(
    20,
    (_) => {'probability': 0.0, 'timestamp': DateTime.now().toIso8601String()},
  );
  double _latestProbability = 0.0;
  DateTime _lastUpdateTime = DateTime.now();

  // Getters
  List<Alert> get alerts => _alerts;
  List<Map<String, dynamic>> get recentReadings => _recentReadings;
  double get latestProbability => _latestProbability;
  String get lastUpdateTime =>
      DateFormat('MMM d, h:mm a').format(_lastUpdateTime);

  AlertsProvider(this._backendService) {
    // Initial data load
    refreshData();

    // Set up periodic refresh (every 30 seconds)
    Future.delayed(Duration.zero, () {
      _setupPeriodicRefresh();
    });
  }

  void update(BackendService backendService) {
    // This method is called when the BackendService is updated
  }

  void _setupPeriodicRefresh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      await refreshData();
      return true; // Keep repeating
    });
  }

  Future<void> refreshData() async {
    _isLoading = true;
    try {
      await Future.wait([
        _fetchLatestProbability(),
        _fetchRecentReadings(),
        _fetchAlerts(),
      ]);

      _lastUpdateTime = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
    } finally {
      // Set loading to false when done, regardless of success or failure
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLatestProbability() async {
    final probability = await _backendService.getLatestProbability();
    _latestProbability = probability;
  }

  Future<void> _fetchRecentReadings() async {
    final readings = await _backendService.getRecentReadings();
    _recentReadings = readings;
  }

  Future<void> _fetchAlerts() async {
    final alerts = await _backendService.getAlertHistory();
    _alerts = alerts;
  }

  Future<bool> acknowledgeAlert(String alertId) async {
    final success = await _backendService.acknowledgeAlert(alertId);

    if (success) {
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        final updatedAlert = Alert(
          id: _alerts[index].id,
          probability: _alerts[index].probability,
          timestamp: _alerts[index].timestamp,
          alertLevel: _alerts[index].alertLevel,
          acknowledged: true,
        );

        _alerts[index] = updatedAlert;
        notifyListeners();
      }
    }

    return success;
  }
}
