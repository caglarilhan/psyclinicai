import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/patient_filter.dart';
import 'package:psyclinicai/widgets/patient_list_filter_bar.dart';

Future<PatientFilter?> _pumpAndCapture(
  WidgetTester tester, {
  required PatientFilter initial,
  required Future<void> Function(WidgetTester) act,
}) async {
  PatientFilter? captured;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PatientListFilterBar(
          filter: initial,
          onChanged: (f) => captured = f,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await act(tester);
  return captured;
}

void main() {
  group('PatientListFilterBar', () {
    testWidgets('renders one chip per status / risk / lastSeen value',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatientListFilterBar(
              filter: PatientFilter.empty,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('High risk'), findsOneWidget);
      expect(find.text('Seen ≤ 24h'), findsOneWidget);
    });

    testWidgets('tapping a status chip emits a new filter with that set',
        (tester) async {
      final out = await _pumpAndCapture(
        tester,
        initial: PatientFilter.empty,
        act: (t) async {
          await t.tap(find.text('Active'));
          await t.pumpAndSettle();
        },
      );
      expect(out!.statuses, contains(PatientStatusFilter.active));
    });

    testWidgets('Clear filters chip only renders when filter is non-empty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatientListFilterBar(
              filter: PatientFilter.empty,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Clear filters'), findsNothing);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatientListFilterBar(
              filter: PatientFilter.empty
                  .toggleRisk(PatientRiskFilter.high),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Clear filters'), findsOneWidget);
    });
  });
}
