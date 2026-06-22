import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/assessments/assessment_result_screen.dart';
import 'package:psyclinicai/services/assessments/assessment_severity_engine.dart';

Future<void> _pump(WidgetTester tester, AssessmentResultScreenArgs args) async {
  await tester.pumpWidget(
    MaterialApp(home: AssessmentResultScreen(args: args)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AssessmentResultScreen', () {
    testWidgets('renders score + band + recommendations', (tester) async {
      await _pump(
        tester,
        const AssessmentResultScreenArgs(
          instrument: AssessmentInstrument.phq9,
          score: 12,
        ),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('moderate'), findsAtLeastNWidgets(1));
      expect(find.textContaining('item 9'), findsOneWidget);
    });

    testWidgets('improving delta surfaces the trending-down chip', (
      tester,
    ) async {
      await _pump(
        tester,
        const AssessmentResultScreenArgs(
          instrument: AssessmentInstrument.phq9,
          score: 9,
          previousScore: 14,
        ),
      );
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('non-concern bands show routine monitoring recommendation', (
      tester,
    ) async {
      await _pump(
        tester,
        const AssessmentResultScreenArgs(
          instrument: AssessmentInstrument.audit,
          score: 3,
        ),
      );
      expect(find.textContaining('routine monitoring'), findsOneWidget);
    });

    testWidgets('PCL-5 boundary score renders the boundary band', (
      tester,
    ) async {
      await _pump(
        tester,
        const AssessmentResultScreenArgs(
          instrument: AssessmentInstrument.pcl5,
          score: 31,
        ),
      );
      expect(find.textContaining('boundary'), findsAtLeastNWidgets(1));
    });
  });
}
