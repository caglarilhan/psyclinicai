import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/crisis_resource.dart';
import 'package:psyclinicai/services/assessments/phq9_item9_router.dart';
import 'package:psyclinicai/services/assessments/risk_escalation_chain.dart';
import 'package:psyclinicai/widgets/risk_escalation_modal.dart';

const _trigger = Phq9Item9Recommendation(
  severity: Phq9Item9Severity.nearlyEveryDay,
  primaryAction: Phq9Item9Action.showCrisisModal,
  secondaryActions: [Phq9Item9Action.openCssrs, Phq9Item9Action.openSafetyPlan],
  reason: 'Daily ideation reported',
);

final _chain = RiskEscalationChain(
  patientId: 'p-1',
  encounterId: 'enc-1',
  startedAt: DateTime.utc(2026, 6, 2, 10),
  trigger: _trigger,
);

const _crisis = [
  CrisisResource(
    id: 'us-988',
    region: 'US',
    name: '988 Suicide & Crisis Lifeline',
    displayNumber: '988',
    kind: CrisisResourceKind.hotline,
    availability: '24/7 · free',
    description: 'US national suicide + crisis support.',
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  RiskEscalationChain? chain,
  VoidCallback? onCssrs,
  VoidCallback? onSafety,
  VoidCallback? onAck,
}) async {
  tester.view.physicalSize = const Size(1400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: RiskEscalationModal(
          trigger: _trigger,
          chain: chain ?? _chain,
          crisisResources: _crisis,
          onOpenCssrs: onCssrs ?? () {},
          onOpenSafetyPlan: onSafety ?? () {},
          onAcknowledge: onAck ?? () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RiskEscalationModal', () {
    testWidgets('renders the critical headline + reason + crisis number', (
      tester,
    ) async {
      await _pump(tester);
      expect(find.text('Imminent safety concern detected'), findsOneWidget);
      expect(find.text('Daily ideation reported'), findsOneWidget);
      expect(find.text('988'), findsOneWidget);
    });

    testWidgets('Open C-SSRS CTA fires the callback', (tester) async {
      var pressed = false;
      await _pump(tester, onCssrs: () => pressed = true);
      await tester.tap(find.text('Open C-SSRS'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('completed CSSRS step disables its CTA', (tester) async {
      final advanced = _chain.advance(
        RiskEscalationEvent(
          kind: RiskEscalationEventKind.cssrsAdministered,
          at: DateTime.utc(2026, 6, 2, 10, 5),
          clinicianId: 'doc-1',
        ),
      );
      await _pump(tester, chain: advanced);
      final btn = tester
          .widgetList<Widget>(find.byWidgetPredicate((w) => w is FilledButton))
          .whereType<FilledButton>()
          .firstWhere(
            (b) => b.child is Text && (b.child as Text).data == 'Open C-SSRS',
          );
      expect(btn.onPressed, isNull);
    });

    testWidgets('audit footer message is present', (tester) async {
      await _pump(tester);
      expect(
        find.textContaining('immutable entry to the risk-escalation chain'),
        findsOneWidget,
      );
    });
  });
}
