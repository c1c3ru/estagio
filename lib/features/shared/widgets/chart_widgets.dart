import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const StatsSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class WeeklyHoursBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const WeeklyHoursBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value['hours'].toDouble(),
                  color: Theme.of(context).primaryColor,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TimeSeriesLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const TimeSeriesLineChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value['value'].toDouble(),
                );
              }).toList(),
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class DonutChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const DonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data.map((item) {
            return PieChartSectionData(
              value: item['value'].toDouble(),
              title: item['label'],
              color: item['color'] ?? Theme.of(context).primaryColor,
            );
          }).toList(),
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final String subtitle;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
