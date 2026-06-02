import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/patients/patient_chart_screen.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart'
    show PatientDetailArgs;

Future<void> _pump(
  WidgetTester tester, {
  PatientChartTab? initialTab,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PatientChartScreen(
        args: const PatientDetailArgs(id: 'demo-1', name: 'John Demo'),
        initialTab: initialTab,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PatientChartScreen', () {
    testWidgets('header renders name + initials + risk chip',
        (tester) async {
      await _pump(tester);
      expect(find.text('John Demo'), findsAtLeastNWidgets(1));
      expect(find.text('JD'), findsOneWidget);
      expect(find.text('Risk · medium'), findsOneWidget);
    });

    testWidgets('renders six tabs', (tester) async {
      await _pump(tester);
      for (final label in const [
        'Timeline',
        'Documents',
        'Notes',
        'Assessments',
        'Treatment plan',
        'Billing',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('default tab is Timeline — shows the signed-session row',
        (tester) async {
      await _pump(tester);
      expect(
        find.textContaining('Session signed'),
        findsOneWidget,
      );
    });

    testWidgets('initialTab respects the deep-link', (tester) async {
      await _pump(tester, initialTab: PatientChartTab.assessments);
      expect(find.textContaining('PHQ-9'), findsAtLeastNWidgets(1));
    });

    testWidgets('empty Documents tab shows the placeholder card',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      expect(find.text('No documents yet'), findsOneWidget);
    });
  });
}
