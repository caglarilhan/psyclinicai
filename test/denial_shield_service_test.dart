import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/denial_risk.dart';
import 'package:psyclinicai/services/billing/denial_shield_service.dart';
import 'package:psyclinicai/services/copilot/compliance_check_service.dart';

void main() {
  const shield = DenialShieldService();

  // A rubric report where the listed ids fail; everything else passes.
  ComplianceReport report({Set<String> failing = const {}}) {
    const ids = [
      'diagnosis',
      'functional_impairment',
      'intervention',
      'response',
      'goal_linkage',
      'risk',
      'time',
      'plan',
    ];
    return ComplianceReport(
      source: ComplianceSource.heuristic,
      checks: [
        for (final id in ids)
          ComplianceCheck(
            id: id,
            label: id,
            status: failing.contains(id) ? CheckStatus.fail : CheckStatus.pass,
          ),
      ],
    );
  }

  test('90837 without a medical-necessity reason is high risk', () {
    final r = shield.assess(
      note: 'Provided therapy. 60 minute session.',
      cptCode: '90837',
      payer: Payer.bcbs,
      audit: report(),
    );
    expect(r.level, DenialLevel.high);
    expect(r.reasons.any((x) => x.title.contains('90837')), isTrue);
    expect(r.revenueAtRisk, 175); // CPT 90837 national average
  });

  test('90837 billed for a 45-minute session flags a downcode', () {
    final r = shield.assess(
      note: '45 minute session. Extended work was medically necessary.',
      cptCode: '90837',
      payer: Payer.aetna,
      audit: report(),
    );
    expect(r.level, DenialLevel.high);
    expect(r.reasons.any((x) => x.title.contains('does not support')), isTrue);
  });

  test('90834 for a 45-minute documented session with a clean note is low', () {
    final r = shield.assess(
      note:
          'Used cognitive restructuring; client engaged. 45 minute session. '
          'No SI/HI. Plan: weekly. Targeted goal 1.',
      cptCode: '90834',
      payer: Payer.aetna,
      audit: report(),
    );
    expect(r.level, DenialLevel.low);
    expect(r.isClean, isTrue);
    expect(r.revenueAtRisk, isNull);
  });

  test('Medicaid hard-fails when goal linkage is missing', () {
    final r = shield.assess(
      note: 'Used CBT. 45 minute session.',
      cptCode: '90834',
      payer: Payer.medicaid,
      audit: report(failing: {'goal_linkage'}),
    );
    expect(r.level, DenialLevel.high); // critical for Medicaid
    expect(r.reasons.any((x) => x.title.contains('goal linkage')), isTrue);
    expect(r.reasons.first.fixSentence, isNotEmpty);
  });

  test('payer emphasis differs: Aetna ignores goal linkage', () {
    final r = shield.assess(
      note: 'Used CBT; client engaged. 45 minute session.',
      cptCode: '90834',
      payer: Payer.aetna,
      audit: report(failing: {'goal_linkage'}),
    );
    // Aetna's critical set is intervention/response (both pass here) — so the
    // missing goal linkage is not a denial driver for Aetna.
    expect(r.isClean, isTrue);
  });

  test('every payer exposes a focus blurb', () {
    for (final p in Payer.values) {
      expect(DenialShieldService.payerFocus(p), isNotEmpty);
    }
  });
}
