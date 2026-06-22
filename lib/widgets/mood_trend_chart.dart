import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// One day on the mood timeline. Scores are 0–10 (UI contract).
class MoodSample {
  const MoodSample({
    required this.day,
    required this.mood,
    required this.sleep,
    required this.anxiety,
  });

  final DateTime day;
  final int mood;
  final int sleep;
  final int anxiety;
}

/// Pure roll-up used by the chart header. Computed outside the
/// widget so the test can assert the numbers without spinning up
/// the chart.
class MoodTrendSummary {
  const MoodTrendSummary({
    required this.sevenDayMoodAvg,
    required this.thirtyDayMoodAvg,
    required this.deltaVsPrev30d,
    required this.sampleCount,
  });

  final double sevenDayMoodAvg;
  final double thirtyDayMoodAvg;

  /// `current 30d avg - previous 30d avg`. Positive = improving
  /// (higher mood is better); negative = worsening.
  final double deltaVsPrev30d;

  final int sampleCount;
}

class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key, required this.samples, required this.now});

  final List<MoodSample> samples;
  final DateTime now;

  static MoodTrendSummary summarise(List<MoodSample> samples, DateTime now) {
    if (samples.isEmpty) {
      return const MoodTrendSummary(
        sevenDayMoodAvg: 0,
        thirtyDayMoodAvg: 0,
        deltaVsPrev30d: 0,
        sampleCount: 0,
      );
    }
    final last7 = samples
        .where((s) => now.difference(s.day).inDays <= 7)
        .toList(growable: false);
    final last30 = samples
        .where((s) => now.difference(s.day).inDays <= 30)
        .toList(growable: false);
    final prev30 = samples
        .where((s) {
          final d = now.difference(s.day).inDays;
          return d > 30 && d <= 60;
        })
        .toList(growable: false);
    double avg(List<MoodSample> rows) => rows.isEmpty
        ? 0.0
        : rows.map((r) => r.mood).reduce((a, b) => a + b) / rows.length;
    return MoodTrendSummary(
      sevenDayMoodAvg: avg(last7),
      thirtyDayMoodAvg: avg(last30),
      deltaVsPrev30d: prev30.isEmpty ? 0.0 : avg(last30) - avg(prev30),
      sampleCount: samples.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (samples.length < 7) {
      return _Empty(style: t.bodyMedium);
    }
    final summary = summarise(samples, now);
    final sorted = [...samples]..sort((a, b) => a.day.compareTo(b.day));

    FlSpot toSpot(MoodSample s, int v) =>
        FlSpot(s.day.millisecondsSinceEpoch.toDouble(), v.toDouble());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Stats(summary: summary, t: t),
        const SizedBox(height: PsySpacing.md),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 10,
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                _bar(
                  sorted.map((s) => toSpot(s, s.mood)).toList(),
                  PsyColors.success,
                ),
                _bar(
                  sorted.map((s) => toSpot(s, s.sleep)).toList(),
                  PsyColors.info,
                ),
                _bar(
                  sorted.map((s) => toSpot(s, s.anxiety)).toList(),
                  PsyColors.warning,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PsySpacing.sm),
        const _Legend(),
      ],
    );
  }

  LineChartBarData _bar(List<FlSpot> spots, Color color) => LineChartBarData(
    spots: spots,
    isCurved: true,
    color: color,
    barWidth: 2,
    dotData: const FlDotData(show: false),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.style});
  final TextStyle? style;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(PsySpacing.lg),
      child: Text(
        'Add more check-ins to see trends — at least 7 days required.',
        style: style,
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.summary, required this.t});
  final MoodTrendSummary summary;
  final TextTheme t;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: '7-day avg mood',
            value: summary.sevenDayMoodAvg.toStringAsFixed(1),
            t: t,
          ),
        ),
        Expanded(
          child: _Stat(
            label: '30-day avg mood',
            value: summary.thirtyDayMoodAvg.toStringAsFixed(1),
            t: t,
          ),
        ),
        Expanded(
          child: _Stat(
            label: 'vs prev 30d',
            value:
                '${summary.deltaVsPrev30d >= 0 ? '+' : ''}'
                '${summary.deltaVsPrev30d.toStringAsFixed(1)}',
            t: t,
            valueColor: summary.deltaVsPrev30d >= 0
                ? PsyColors.success
                : PsyColors.warning,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.t,
    this.valueColor,
  });
  final String label;
  final String value;
  final TextTheme t;
  final Color? valueColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.labelMedium),
        Text(value, style: t.titleLarge?.copyWith(color: valueColor)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: PsyColors.success, label: 'mood', t: t),
        const SizedBox(width: PsySpacing.md),
        _LegendDot(color: PsyColors.info, label: 'sleep', t: t),
        const SizedBox(width: PsySpacing.md),
        _LegendDot(color: PsyColors.warning, label: 'anxiety', t: t),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, required this.t});
  final Color color;
  final String label;
  final TextTheme t;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: t.labelSmall),
      ],
    );
  }
}
