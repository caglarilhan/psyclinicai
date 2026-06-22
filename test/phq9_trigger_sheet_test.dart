import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/phq9_item9_router.dart';
import 'package:psyclinicai/widgets/phq9_trigger_sheet.dart';

Future<void> _pump(WidgetTester tester, Phq9Item9Recommendation rec) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Phq9TriggerSheet(recommendation: rec)),
    ),
  );
  await tester.pumpAndSettle();
}

const _router = Phq9Item9Router();

void main() {
  group('Phq9TriggerSheet', () {
    testWidgets('score 1 — shows the openCssrs primary CTA only', (
      tester,
    ) async {
      await _pump(tester, _router.evaluate({'phq9_9': 1}));
      expect(find.text('Open C-SSRS'), findsOneWidget);
      expect(find.text('Open safety plan'), findsNothing);
      expect(find.text('Show crisis resources'), findsNothing);
    });

    testWidgets('score 2 — adds the safety plan secondary CTA', (tester) async {
      await _pump(tester, _router.evaluate({'phq9_9': 2}));
      expect(find.text('Open C-SSRS'), findsOneWidget);
      expect(find.text('Open safety plan'), findsOneWidget);
    });

    testWidgets('score 3 — primary crisis modal + cascading CTAs', (
      tester,
    ) async {
      await _pump(tester, _router.evaluate({'phq9_9': 3}));
      expect(find.text('Show crisis resources'), findsOneWidget);
      expect(find.text('Open C-SSRS'), findsOneWidget);
      expect(find.text('Open safety plan'), findsOneWidget);
    });

    testWidgets('reason copy is rendered verbatim', (tester) async {
      final rec = _router.evaluate({'phq9_9': 1});
      await _pump(tester, rec);
      expect(find.text(rec.reason), findsOneWidget);
    });

    testWidgets('document-the-decision CTA is always shown', (tester) async {
      await _pump(tester, _router.evaluate({'phq9_9': 1}));
      expect(find.text('Document the decision'), findsOneWidget);
    });
  });
}
