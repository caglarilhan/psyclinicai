import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/analytics/caseload_outcomes_metrics.dart';
import 'package:psyclinicai/widgets/outcomes/caseload_outcomes_panel.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('CaseloadOutcomesPanel', () {
    testWidgets('empty metrics — renders the not-enough-data state', (
      tester,
    ) async {
      const metrics = CaseloadOutcomeMetrics(
        patientCount: 0,
        avgFirstScore: 0,
        avgLastScore: 0,
        responseRate: 0,
      );
      await _pump(
        tester,
        const CaseloadOutcomesPanel(instrumentLabel: 'PHQ-9', metrics: metrics),
      );
      expect(find.textContaining('not enough datapoints'), findsOneWidget);
      // The 3-card grid must NOT render in the empty state.
      expect(find.text('Patients'), findsNothing);
      expect(find.text('Response rate'), findsNothing);
    });

    testWidgets('populated metrics — shows three cards + bipolar disclaimer', (
      tester,
    ) async {
      const metrics = CaseloadOutcomeMetrics(
        patientCount: 3,
        avgFirstScore: 18,
        avgLastScore: 8,
        responseRate: 0.66,
      );
      await _pump(
        tester,
        const CaseloadOutcomesPanel(
          instrumentLabel: 'PHQ-9 demo',
          metrics: metrics,
        ),
      );
      expect(find.text('Patients'), findsOneWidget);
      expect(find.text('Avg change'), findsOneWidget);
      expect(find.text('Response rate'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      // Disclaimer must surface so a clinician does not treat a PHQ-9
      // drop as bipolar recovery.
      expect(find.textContaining('bipolar spectrum'), findsOneWidget);
    });

    testWidgets('improving caseload shows a negative delta with sign', (
      tester,
    ) async {
      const metrics = CaseloadOutcomeMetrics(
        patientCount: 2,
        avgFirstScore: 20,
        avgLastScore: 12,
        responseRate: 0.5,
      );
      await _pump(
        tester,
        const CaseloadOutcomesPanel(instrumentLabel: 'PHQ-9', metrics: metrics),
      );
      expect(find.textContaining('-8.0 pts'), findsOneWidget);
    });
  });
}
