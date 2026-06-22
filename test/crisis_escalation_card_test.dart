import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/clinical_scales.dart';
import 'package:psyclinicai/services/assessments/cssrs_escalation_service.dart';
import 'package:psyclinicai/services/crisis/crisis_resource_registry.dart';
import 'package:psyclinicai/widgets/crisis_escalation_card.dart';

void main() {
  final service = CssrsEscalationService();
  const scale = ClinicalScales.cssrs;

  Future<void> pump(
    WidgetTester tester,
    CssrsEscalation escalation, {
    VoidCallback? onInitiate,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CrisisEscalationCard(
              escalation: escalation,
              resources: CrisisResourceRegistry.forCountry('US'),
              onInitiateSafetyPlan: onInitiate ?? () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders nothing when there is no risk', (tester) async {
    final e = service.evaluate(scale.score(List.filled(6, 0)));
    await pump(tester, e);

    expect(find.byType(CrisisEscalationCard), findsOneWidget);
    expect(find.text('Start safety plan now'), findsNothing);
    expect(find.text('Build safety plan with the client'), findsNothing);
    expect(find.text('Crisis resources'), findsNothing);
  });

  testWidgets('initiate-safety-plan tier shows non-urgent CTA', (tester) async {
    final e = service.evaluate(scale.score([0, 0, 1, 0, 0, 0]));
    await pump(tester, e);

    expect(find.text('Build safety plan with the client'), findsOneWidget);
    expect(find.text('Start safety plan now'), findsNothing);
    expect(find.text('Crisis resources'), findsOneWidget);
    // 988 should render as a resource tile in the US locale set.
    expect(find.text('988'), findsOneWidget);
  });

  testWidgets('imminent tier shows urgent CTA and dispatches callback', (
    tester,
  ) async {
    final e = service.evaluate(scale.score([0, 0, 0, 0, 0, 1]));
    var initiated = false;
    await pump(tester, e, onInitiate: () => initiated = true);

    expect(find.text('Start safety plan now'), findsOneWidget);
    // The headline communicates urgency.
    expect(find.textContaining('Imminent'), findsOneWidget);

    await tester.tap(find.text('Start safety plan now'));
    await tester.pumpAndSettle();
    expect(initiated, isTrue);
  });

  testWidgets('monitor tier shows the card but no safety-plan CTA', (
    tester,
  ) async {
    final e = service.evaluate(scale.score([1, 0, 0, 0, 0, 0]));
    await pump(tester, e);

    // No CTA because monitor does not auto-require a safety plan, but the
    // crisis resources panel must still be visible so the clinician can
    // surface a hotline if the conversation warrants it.
    expect(find.text('Start safety plan now'), findsNothing);
    expect(find.text('Build safety plan with the client'), findsNothing);
    expect(find.text('Crisis resources'), findsOneWidget);
  });
}
