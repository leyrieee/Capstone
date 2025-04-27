// screens/home_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../models/probability_chart.dart';
import 'package:provider/provider.dart';
import '../providers/alerts_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertsProvider = Provider.of<AlertsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NeuroScope'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(context, alertsProvider),
                        const SizedBox(height: 20),
                        Text(
                          'Seizure Probability Trend',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 350, // Set a fixed height for the chart
                          child: ProbabilityChart(
                            recentReadingsData: alertsProvider.recentReadings,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLastUpdateInfo(alertsProvider),
                        if (alertsProvider.alerts.isNotEmpty &&
                            !alertsProvider.alerts.first.acknowledged)
                          _buildLatestAlertCard(context, alertsProvider),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AlertsProvider provider) {
    final latestProb = provider.latestProbability;
    final color = latestProb >= 0.8
        ? Colors.red
        : (latestProb >= 0.5 ? Colors.orange : Colors.green);

    return Card(
      elevation: 3,
      shadowColor: color.withOpacity(0.3),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Seizure Probability:',
                    style: TextStyle(fontSize: 14)),
                Text('${(latestProb * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdateInfo(AlertsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Text(
          'Last updated: ${provider.lastUpdateTime}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildLatestAlertCard(BuildContext context, AlertsProvider provider) {
    final latestAlert = provider.alerts.first;

    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text(
                      'Recent Alert',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    Text(latestAlert.formattedTime,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Probability: ${latestAlert.formattedProbability}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => provider.acknowledgeAlert(latestAlert.id),
                    icon: const Icon(Icons.check),
                    label: const Text('Acknowledge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
