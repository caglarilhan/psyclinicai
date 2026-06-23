/// Coverage for CarcFixPlaybook — entry lookup, payer-specific
/// appeal angle override, CPT-specific immediate fix override,
/// every entry exposes the three structured steps.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/denial_risk.dart';
import 'package:psyclinicai/services/billing/carc_fix_playbook.dart';

void main() {
  test('forCode returns null for unknown CARC', () {
    expect(CarcFixPlaybook.forCode('CO-99999'), isNull);
  });

  test('every shipped entry has immediateFix / resubmitStep / appealAngle', () {
    for (final entry in CarcFixPlaybook.all.values) {
      expect(entry.immediateFix.label, isNotEmpty);
      expect(entry.immediateFix.detail, isNotEmpty);
      expect(entry.resubmitStep.label, isNotEmpty);
      expect(entry.resubmitStep.detail, isNotEmpty);
      expect(entry.appealAngle.label, isNotEmpty);
      expect(entry.appealAngle.detail, isNotEmpty);
    }
  });

  test(
    'CO-50 has payer-specific appeal emphasis for Medicare / Optum / Medicaid',
    () {
      final entry = CarcFixPlaybook.forCode('CO-50')!;
      expect(entry.payerEmphasis.containsKey(Payer.medicare), isTrue);
      expect(entry.payerEmphasis.containsKey(Payer.uhcOptum), isTrue);
      expect(entry.payerEmphasis.containsKey(Payer.medicaid), isTrue);
    },
  );

  test(
    'appealAngleFor returns override for known payer, fallback otherwise',
    () {
      final entry = CarcFixPlaybook.forCode('CO-50')!;
      final medicareAngle = entry.appealAngleFor(Payer.medicare);
      final bcbsAngle = entry.appealAngleFor(Payer.bcbs);
      expect(medicareAngle.label, 'Cite the applicable LCD');
      // BCBS has no override on CO-50 → falls back to generic angle.
      expect(bcbsAngle.label, entry.appealAngle.label);
    },
  );

  test('immediateFixFor falls back when no CPT-specific override exists', () {
    final entry = CarcFixPlaybook.forCode('CO-11')!;
    expect(entry.immediateFixFor('90837').label, entry.immediateFix.label);
  });

  test('PR-1 carries the "bill the patient" guidance and no resubmission', () {
    final entry = CarcFixPlaybook.forCode('PR-1')!;
    expect(entry.immediateFix.label, contains('Bill'));
    expect(entry.resubmitStep.label, contains('No resubmission'));
  });

  test('catalogue covers the top denial codes', () {
    expect(
      CarcFixPlaybook.all.keys.toSet(),
      containsAll({
        'CO-11',
        'CO-50',
        'CO-96',
        'CO-97',
        'CO-151',
        'CO-197',
        'PR-1',
      }),
    );
  });
}
