import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/clinical_scales.dart';
import 'package:psyclinicai/services/assessments/cssrs_escalation_service.dart';

/// These tests pin the C-SSRS escalation policy. The mapping is clinical:
/// every change here must be reviewed before shipping.
void main() {
  final service = CssrsEscalationService();
  const scale = ClinicalScales.cssrs;

  group('CssrsEscalationService.evaluate', () {
    test('all-no screener is none / no risk / no action required', () {
      final result = scale.score(List.filled(6, 0));
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.none);
      expect(e.hasAnyRisk, isFalse);
      expect(e.requiresImmediateAction, isFalse);
      expect(e.requiresSafetyPlan, isFalse);
      expect(e.blockPatientRelease, isFalse);
    });

    test('death-wish only (item 1) is monitor — flag, no immediate action',
        () {
      final result = scale.score([1, 0, 0, 0, 0, 0]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.monitor);
      expect(e.hasAnyRisk, isTrue);
      expect(e.requiresImmediateAction, isFalse);
      expect(e.requiresSafetyPlan, isFalse);
      expect(e.blockPatientRelease, isFalse);
    });

    test('active ideation (item 2) is monitor — flag, no plan required', () {
      final result = scale.score([0, 1, 0, 0, 0, 0]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.monitor);
      expect(e.requiresImmediateAction, isFalse);
      expect(e.requiresSafetyPlan, isFalse);
    });

    test('ideation with method (item 3) is initiate-safety-plan', () {
      final result = scale.score([0, 0, 1, 0, 0, 0]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.initiateSafetyPlan);
      expect(e.requiresSafetyPlan, isTrue);
      expect(e.requiresImmediateAction, isFalse,
          reason: 'Method alone does not block release.');
      expect(e.blockPatientRelease, isFalse);
    });

    test('ideation with intent (item 4) is immediate + blocks release', () {
      final result = scale.score([0, 0, 0, 1, 0, 0]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.immediate);
      expect(e.requiresImmediateAction, isTrue);
      expect(e.requiresSafetyPlan, isTrue);
      expect(e.blockPatientRelease, isTrue);
    });

    test('ideation with plan (item 5) is immediate + blocks release', () {
      final result = scale.score([0, 0, 0, 0, 1, 0]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.immediate);
      expect(e.requiresImmediateAction, isTrue);
      expect(e.blockPatientRelease, isTrue);
    });

    test('suicidal behavior (item 6) is imminent — top tier', () {
      final result = scale.score([0, 0, 0, 0, 0, 1]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.imminent);
      expect(e.requiresImmediateAction, isTrue);
      expect(e.requiresSafetyPlan, isTrue);
      expect(e.blockPatientRelease, isTrue);
      expect(e.supervisorHint, isNotEmpty);
    });

    test('mixed positive answers escalate to the highest tier endorsed', () {
      // Items 1, 3, and 6 all positive → behavior wins.
      final result = scale.score([1, 0, 1, 0, 0, 1]);
      final e = service.evaluate(result);

      expect(e.tier, CssrsEscalationTier.imminent);
      expect(e.blockPatientRelease, isTrue);
    });

    test('headline and guidance are populated for every tier', () {
      for (final answers in <List<int>>[
        List.filled(6, 0),
        [1, 0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0],
        [0, 0, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 1],
      ]) {
        final e = service.evaluate(scale.score(answers));
        expect(e.headline, isNotEmpty,
            reason: 'tier ${e.tier} must have a headline');
        expect(e.guidance, isNotEmpty,
            reason: 'tier ${e.tier} must have guidance text');
      }
    });
  });

  group('CssrsEscalationService.recordEscalation', () {
    test('does not throw for the no-risk tier', () {
      final e = service.evaluate(scale.score(List.filled(6, 0)));
      // Telemetry is wired to the real singleton; with no DSN it's a no-op.
      // The call must complete synchronously without throwing.
      expect(() => service.recordEscalation(e), returnsNormally);
    });

    test('does not throw for the highest tier', () {
      final e = service.evaluate(scale.score([0, 0, 0, 0, 0, 1]));
      expect(() => service.recordEscalation(e), returnsNormally);
    });

    test('initiated + dismissed recorders are safe to call', () {
      final e = service.evaluate(scale.score([0, 0, 0, 1, 0, 0]));
      expect(() => service.recordSafetyPlanInitiated(e), returnsNormally);
      expect(() => service.recordModalDismissed(e, reason: 'test'),
          returnsNormally);
    });
  });
}
