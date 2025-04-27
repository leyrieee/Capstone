// screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alerts_provider.dart';
import '../models/alert.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsProvider = Provider.of<AlertsProvider>(context);
    final alerts = alertsProvider.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => alertsProvider.refreshData(),
          ),
        ],
      ),
      body: alertsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: alertsProvider.refreshData,
              child: alerts.isEmpty
                  ? const Center(child: Text('No alerts to display'))
                  : ListView.builder(
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return _buildAlertCard(context, alert, alertsProvider);
                      },
                    ),
            ),
    );
  }

  Widget _buildAlertCard(
      BuildContext context, Alert alert, AlertsProvider provider) {
    // Determine color based on alert level
    Color cardColor;
    switch (alert.alertLevel) {
      case 'high':
        cardColor = Colors.red.shade100;
        break;
      case 'medium':
        cardColor = Colors.orange.shade100;
        break;
      case 'low':
        cardColor = Colors.green.shade100;
        break;
      default:
        cardColor = Colors.blue.shade100;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: alert.acknowledged ? Colors.grey.shade50 : cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alert: ${alert.formattedProbability}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: alert.acknowledged ? Colors.grey : Colors.black,
              ),
            ),
            if (!alert.acknowledged)
              TextButton(
                onPressed: () => provider.acknowledgeAlert(alert.id),
                child: const Text('Acknowledge'),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Time: ${alert.formattedTime}'),
            const SizedBox(height: 4),
            Text('Level: ${alert.alertLevel.toUpperCase()}'),
            if (alert.acknowledged)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Chip(
                  label: Text('Acknowledged'),
                  backgroundColor: Colors.grey,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        onTap: () {
          // Show detailed alert view if needed
          _showAlertDetails(context, alert, provider);
        },
      ),
    );
  }

  void _showAlertDetails(
      BuildContext context, Alert alert, AlertsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alert Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              _detailRow('Probability', alert.formattedProbability),
              _detailRow('Time', alert.formattedTime),
              _detailRow('Alert Level', alert.alertLevel.toUpperCase()),
              _detailRow('Status',
                  alert.acknowledged ? 'Acknowledged' : 'Unacknowledged'),
              const SizedBox(height: 20),
              if (!alert.acknowledged)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.acknowledgeAlert(alert.id);
                      Navigator.pop(context);
                    },
                    child: const Text('Acknowledge Alert'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
