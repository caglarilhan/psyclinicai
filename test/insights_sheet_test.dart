/// Coverage that the session-insights bottom sheet renders the
/// standardized AI disclaimer footer (so the disclaimer coverage
/// audit at `ai_disclaimer.footer.shown` picks it up).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/session_insights_service.dart';
import 'package:psyclinicai/widgets/copilot/ai_disclaimer.dart';
import 'package:psyclinicai/widgets/copilot/insights_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Material(child: child)),
  );

  SessionInsights insights() => SessionInsights(
    alliance: 'Warm rapport — client engaged.',
    interventions: const ['Socratic questioning', 'Behavioural activation'],
    themes: const ['Self-criticism', 'Work overwhelm'],
    strengths: const ['Insight', 'Articulate'],
    suggestions: const ['Slow pacing in next session'],
    homework: const ['Daily mood log'],
  );

  testWidgets('renders the AiDisclaimer footer with the correct surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrap(InsightsSheet(insights: insights())));
    await tester.pumpAndSettle();

    final disclaimer = tester.widget<AiDisclaimer>(find.byType(AiDisclaimer));
    expect(disclaimer.variant, AiDisclaimerVariant.footer);
    expect(disclaimer.surface, 'session_insights');
  });

  testWidgets('renders the five labelled insight sections', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrap(InsightsSheet(insights: insights())));
    await tester.pumpAndSettle();

    expect(find.text('Session insights'), findsOneWidget);
    expect(find.text('Strengths'), findsOneWidget);
    expect(find.text('Interventions observed'), findsOneWidget);
    expect(find.text('Client themes'), findsOneWidget);
    expect(find.text('Suggestions for next time'), findsOneWidget);
    expect(find.text('Homework ideas'), findsOneWidget);
  });
}
