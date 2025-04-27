// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProbabilityChart extends StatefulWidget {
  final List<Map<String, dynamic>> recentReadingsData;

  const ProbabilityChart({super.key, required this.recentReadingsData});

  @override
  State<ProbabilityChart> createState() => _ProbabilityChartState();
}

class _ProbabilityChartState extends State<ProbabilityChart> {
  String _selectedTimeRange = 'day';
  List<Map<String, dynamic>> _filteredReadings = [];
  late DateTime _referenceStart;

  @override
  void initState() {
    super.initState();
    _filterReadings();
  }

  String getAlertLevel(double probability) {
    if (probability <= 0.5) return "low";
    if (probability <= 0.8) return "medium";
    return "high";
  }

  Color getAlertColor(double probability) {
    final level = getAlertLevel(probability);
    switch (level) {
      case "low":
        return Colors.green;
      case "medium":
        return Colors.amber;
      case "high":
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  DateTime _parseTimestamp(dynamic rawTimestamp) {
    if (rawTimestamp == null) return DateTime.now().toUtc();

    try {
      if (rawTimestamp is String) {
        return DateTime.parse(rawTimestamp).toUtc();
      } else if (rawTimestamp is Map && rawTimestamp.containsKey('_seconds')) {
        return DateTime.fromMillisecondsSinceEpoch(
          (rawTimestamp['_seconds'] as int) * 1000,
          isUtc: true,
        );
      }
    } catch (_) {}
    return DateTime.now().toUtc();
  }

  void _filterReadings() {
    final now = DateTime.now().toUtc();
    Duration difference = const Duration(days: 1);

    switch (_selectedTimeRange) {
      case 'day':
        difference = const Duration(days: 1);
        break;
      case 'week':
        difference = const Duration(days: 7);
        break;
      case 'month':
        difference = const Duration(days: 30);
        break;
      case 'year':
        difference = const Duration(days: 365);
        break;
      case 'max':
        _filteredReadings = List.from(widget.recentReadingsData);
        break;
      default:
        difference = const Duration(days: 1);
    }

    if (_selectedTimeRange != 'max') {
      final cutoff = now.subtract(difference);
      _filteredReadings = widget.recentReadingsData.where((item) {
        final timestamp = _parseTimestamp(item['timestamp']);
        return timestamp.isAfter(cutoff);
      }).toList();
    }

    _filteredReadings.sort((a, b) => _parseTimestamp(a['timestamp'])
        .compareTo(_parseTimestamp(b['timestamp'])));

    _referenceStart = _filteredReadings.isNotEmpty
        ? _parseTimestamp(_filteredReadings.first['timestamp'])
        : DateTime.now().toUtc();

    setState(() {});
  }

  double _getXValue(DateTime timestamp) {
    switch (_selectedTimeRange) {
      case 'day':
        return timestamp.difference(_referenceStart).inMinutes / 60.0;
      case 'week':
        return timestamp.difference(_referenceStart).inHours / 24.0;
      case 'month':
        return timestamp.difference(_referenceStart).inDays.toDouble();
      case 'year':
        return timestamp.difference(_referenceStart).inDays / 30.0;
      case 'max':
        return timestamp.difference(_referenceStart).inDays.toDouble();
      default:
        return 0;
    }
  }

  double calculateOptimalXInterval(double minX, double maxX) {
    final range = maxX - minX;
    switch (_selectedTimeRange) {
      case 'day':
        return (range / 6).clamp(2.0, 4.0);
      case 'week':
        return (range / 7).clamp(1.0, 2.0);
      case 'month':
        return (range / 6).clamp(5.0, 7.0);
      case 'year':
        return (range / 6).clamp(1.0, 3.0);
      case 'max':
        return range / 6;
      default:
        return range / 6;
    }
  }

  String _getXAxisLabel(double x) {
    DateTime date;
    switch (_selectedTimeRange) {
      case 'day':
        date = _referenceStart.add(Duration(minutes: (x * 60).toInt()));
        return DateFormat('HH:mm').format(date.toLocal());
      case 'week':
        date = _referenceStart.add(Duration(hours: (x * 24).toInt()));
        return DateFormat('EEE').format(date.toLocal());
      case 'month':
        date = _referenceStart.add(Duration(days: x.toInt()));
        return DateFormat('d MMM').format(date.toLocal());
      case 'year':
        date = _referenceStart.add(Duration(days: (x * 30).toInt()));
        return DateFormat('MMM').format(date.toLocal());
      case 'max':
        date = _referenceStart.add(Duration(days: x.toInt()));
        return x > 365
            ? DateFormat('MMM yy').format(date.toLocal())
            : DateFormat('d MMM').format(date.toLocal());
      default:
        return '';
    }
  }

  List<LineChartBarData> getLineBarsData(
      List<FlSpot> spots, double minX, double maxX) {
    List<LineChartBarData> bars = [
      LineChartBarData(
        spots: [FlSpot(minX, 0.5), FlSpot(maxX, 0.5)],
        isCurved: false,
        color: Colors.amber.withOpacity(0.5),
        barWidth: 1,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5],
      ),
      LineChartBarData(
        spots: [FlSpot(minX, 0.8), FlSpot(maxX, 0.8)],
        isCurved: false,
        color: Colors.red.withOpacity(0.5),
        barWidth: 1,
        dotData: const FlDotData(show: false),
        dashArray: [5, 5],
      ),
    ];

    if (spots.isEmpty) return bars;

    spots.sort((a, b) => a.x.compareTo(b.x));

    List<List<FlSpot>> segments = [];
    String currentLevel = getAlertLevel(spots.first.y);
    List<FlSpot> currentSegment = [spots.first];

    for (int i = 1; i < spots.length; i++) {
      final level = getAlertLevel(spots[i].y);

      if (level == currentLevel) {
        currentSegment.add(spots[i]);
      } else {
        segments.add(List.from(currentSegment));
        currentLevel = level;
        currentSegment = [spots[i - 1], spots[i]];
      }
    }

    if (currentSegment.isNotEmpty) segments.add(currentSegment);

    for (var segment in segments) {
      if (segment.isNotEmpty) {
        final color = getAlertColor(segment.last.y);
        bars.add(
          LineChartBarData(
            spots: segment,
            isCurved: false,
            color: color,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
              color: color.withOpacity(0.2),
            ),
          ),
        );
      }
    }

    bars.add(
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: Colors.blue.withOpacity(0.3),
        barWidth: 1,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ),
    );

    return bars;
  }

  Widget _buildProbabilityChart() {
    if (widget.recentReadingsData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No data available.'),
      );
    }

    if (_filteredReadings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No data for the selected time range.'),
      );
    }

    final spots = _filteredReadings
        .map((entry) {
          if (entry['probability'] == null || entry['timestamp'] == null) {
            return const FlSpot(-1, -1);
          }
          final timestamp = _parseTimestamp(entry['timestamp']);
          return FlSpot(
            _getXValue(timestamp),
            entry['probability'] as double,
          );
        })
        .where((spot) => spot.x != -1 && spot.y != -1)
        .toList();

    if (spots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Insufficient data to display the chart.'),
      );
    }

    final minX = spots.first.x;
    final maxX = spots.last.x;
    final interval = calculateOptimalXInterval(minX, maxX);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final label = _getXAxisLabel(spot.x);
                  final level = getAlertLevel(spot.y).toUpperCase();
                  return LineTooltipItem(
                    '$label\nProb: ${(spot.y * 100).toStringAsFixed(1)}%\nRisk: $level',
                    const TextStyle(color: Colors.white),
                    textAlign: TextAlign.left,
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(show: true, horizontalInterval: 0.1),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    _getXAxisLabel(value),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                reservedSize: 28,
              ),
              axisNameWidget: Text(
                _getXAxisTitle(),
                style: const TextStyle(fontSize: 12),
              ),
              axisNameSize: 22,
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.1,
                getTitlesWidget: (value, _) => Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(fontSize: 10),
                ),
                reservedSize: 32,
              ),
              axisNameWidget:
                  const Text('Probability', style: TextStyle(fontSize: 12)),
              axisNameSize: 22,
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true),
          minX: minX,
          maxX: maxX,
          minY: 0,
          maxY: 1,
          lineBarsData: getLineBarsData(spots, minX, maxX),
        ),
      ),
    );
  }

  String _getXAxisTitle() {
    switch (_selectedTimeRange) {
      case 'day':
        return 'Hours';
      case 'week':
        return 'Days';
      case 'month':
        return 'Date';
      case 'year':
        return 'Month';
      case 'max':
        return 'Date';
      default:
        return '';
    }
  }

  Widget _buildTimeRangeButtons() {
    const labels = ['day', 'week', 'month', 'year', 'max'];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: labels.map((label) {
        final isSelected = _selectedTimeRange == label;
        return SizedBox(
          height: 30,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedTimeRange = label;
                _filterReadings();
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
              foregroundColor: isSelected ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: Text(label.toUpperCase()),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTimeRangeButtons(),
        Expanded(child: _buildProbabilityChart()),
      ],
    );
  }
}
