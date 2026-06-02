import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/differential_candidate.dart';
import 'package:psyclinicai/widgets/differential_candidate_card.dart';

DifferentialCandidate _candidate({double confidence = 0.7}) =>
    DifferentialCandidate(
      code: 'F32.1',
      name: 'Major depressive disorder, single episode, moderate',
      confidence: confidence,
      criteriaMet: const ['A.1 depressed mood', 'A.2 anhedonia'],
      criteriaMissing: const ['A.5 psychomotor agitation'],
      differentialFrom: const ['F33.1 recurrent MDD'],
    );

Future<void> _pump(
  WidgetTester tester,
  DifferentialCandidate c,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DifferentialCandidateCard(candidate: c),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DifferentialCandidateCard', () {
    testWidgets('renders code + name + confidence + clinician disclaimer',
        (tester) async {
      await _pump(tester, _candidate());
      expect(find.text('F32.1'), findsOneWidget);
      expect(
        find.textContaining('Major depressive disorder'),
        findsOneWidget,
      );
      expect(find.textContaining('70%'), findsOneWidget);
      expect(
        find.textContaining('clinician owns the final diagnosis'),
        findsOneWidget,
      );
    });

    testWidgets('criteria-met / -missing lists surface their headers',
        (tester) async {
      await _pump(tester, _candidate());
      expect(find.text('Criteria met'), findsOneWidget);
      expect(find.text('Still to clarify'), findsOneWidget);
    });

    testWidgets('rule-out row renders when differentialFrom is set',
        (tester) async {
      await _pump(tester, _candidate());
      expect(find.textContaining('Rule out'), findsOneWidget);
    });

    testWidgets('action row exposes Accept / Add / Reject CTAs',
        (tester) async {
      await _pump(tester, _candidate());
      expect(find.text('Accept as primary'), findsOneWidget);
      expect(find.text('Add to differential'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });
  });
}
