import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/mood_trend_chart.dart';

final _now = DateTime.utc(2026, 6, 10);

MoodSample _sample({
  required int daysAgo,
  int mood = 5,
  int sleep = 6,
  int anxiety = 4,
}) => MoodSample(
  day: _now.subtract(Duration(days: daysAgo)),
  mood: mood,
  sleep: sleep,
  anxiety: anxiety,
);

void main() {
  group('MoodTrendChart.summarise', () {
    test('empty samples → zero summary', () {
      final s = MoodTrendChart.summarise(const [], _now);
      expect(s.sevenDayMoodAvg, 0);
      expect(s.thirtyDayMoodAvg, 0);
      expect(s.deltaVsPrev30d, 0);
      expect(s.sampleCount, 0);
    });

    test('separates 7d / 30d windows', () {
      final samples = <MoodSample>[
        for (var i = 0; i < 7; i++) _sample(daysAgo: i, mood: 8),
        for (var i = 8; i < 30; i++) _sample(daysAgo: i, mood: 4),
      ];
      final s = MoodTrendChart.summarise(samples, _now);
      expect(s.sevenDayMoodAvg, 8);
      expect(s.thirtyDayMoodAvg, closeTo(4.93, 0.1));
    });

    test('deltaVsPrev30d is positive when current 30d > previous 30d', () {
      final samples = <MoodSample>[
        for (var i = 0; i < 30; i++) _sample(daysAgo: i, mood: 7),
        for (var i = 31; i < 60; i++) _sample(daysAgo: i, mood: 4),
      ];
      final s = MoodTrendChart.summarise(samples, _now);
      expect(s.deltaVsPrev30d, greaterThan(0));
    });

    test('deltaVsPrev30d is zero when no prior window exists', () {
      final samples = <MoodSample>[
        for (var i = 0; i < 30; i++) _sample(daysAgo: i, mood: 7),
      ];
      final s = MoodTrendChart.summarise(samples, _now);
      expect(s.deltaVsPrev30d, 0);
    });
  });

  group('MoodTrendChart widget', () {
    testWidgets('< 7 samples → empty hint, no chart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodTrendChart(
              samples: [for (var i = 0; i < 3; i++) _sample(daysAgo: i)],
              now: _now,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Add more check-ins'), findsOneWidget);
    });

    testWidgets('≥ 7 samples → renders stats + legend', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MoodTrendChart(
              samples: [for (var i = 0; i < 14; i++) _sample(daysAgo: i)],
              now: _now,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('7-day avg mood'), findsOneWidget);
      expect(find.text('30-day avg mood'), findsOneWidget);
      expect(find.text('mood'), findsOneWidget);
      expect(find.text('sleep'), findsOneWidget);
      expect(find.text('anxiety'), findsOneWidget);
    });
  });
}
