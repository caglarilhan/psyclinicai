/// Coverage for AiDisclaimer — three variants render the right
/// text + Semantics label carries the surface id so the telemetry
/// coverage audit can trace it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/copilot/ai_disclaimer.dart';

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(800, 600));
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('compact ribbon renders single-line disclaimer', (tester) async {
    await _pump(tester, AiDisclaimer.compact(surface: 'test_surface'));
    expect(
      find.text('AI decision support — review clinically before acting.'),
      findsOneWidget,
    );
  });

  testWidgets('full card uses default label when none provided', (
    tester,
  ) async {
    await _pump(tester, AiDisclaimer.full(surface: 'soap_note'));
    expect(find.text('AI-drafted content'), findsOneWidget);
    expect(
      find.textContaining('decision support, not a diagnosis'),
      findsOneWidget,
    );
  });

  testWidgets('full card surfaces draftedLabel override', (tester) async {
    await _pump(
      tester,
      AiDisclaimer.full(
        surface: 'soap_note',
        draftedLabel: 'AI-drafted SOAP note',
      ),
    );
    expect(find.text('AI-drafted SOAP note'), findsOneWidget);
  });

  testWidgets('footer variant renders quiet footnote', (tester) async {
    await _pump(tester, AiDisclaimer.footer(surface: 'live_ai_panel'));
    expect(
      find.text('AI-assisted. Clinician retains full responsibility.'),
      findsOneWidget,
    );
  });

  testWidgets('Semantics label carries surface id for every variant', (
    tester,
  ) async {
    for (final variant in [
      AiDisclaimer.compact(surface: 'one'),
      AiDisclaimer.full(surface: 'two'),
      AiDisclaimer.footer(surface: 'three'),
    ]) {
      await _pump(tester, variant);
      expect(
        find.bySemanticsLabel(
          RegExp(r'AI decision support .* for (one|two|three)'),
        ),
        findsOneWidget,
      );
    }
  });
}
