/// Coverage for PayerRulePack catalogue — every payer has a pack,
/// CPT filter + timeBasedOnly filter, rule id uniqueness within a
/// pack, DenialReason conversion preserves fields.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/denial_risk.dart';
import 'package:psyclinicai/services/billing/payer_rule_pack.dart';

void main() {
  group('PayerRulePacks catalogue', () {
    test('every Payer enum value has a pack', () {
      for (final p in Payer.values) {
        expect(
          PayerRulePacks.byPayer.containsKey(p),
          isTrue,
          reason: 'No pack for $p',
        );
      }
    });

    test('rule ids are unique inside each pack', () {
      for (final entry in PayerRulePacks.byPayer.entries) {
        final ids = entry.value.rules.map((r) => r.id).toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: 'Duplicate rule id in ${entry.key} pack',
        );
      }
    });

    test('every rule id is namespaced by payer prefix', () {
      for (final entry in PayerRulePacks.byPayer.entries) {
        for (final r in entry.value.rules) {
          expect(
            r.id.contains('.'),
            isTrue,
            reason: 'Rule "${r.id}" lacks a namespace dot',
          );
        }
      }
    });
  });

  group('PayerRulePack.rulesFor filter', () {
    test('timeBasedOnly rule fires only on time-based CPTs', () {
      final pack = PayerRulePacks.forPayer(Payer.medicare);
      final on90837 = pack.rulesFor('90837').map((r) => r.id).toList();
      final on90791 = pack.rulesFor('90791').map((r) => r.id).toList();
      expect(on90837, contains('medicare.time_in_out'));
      expect(on90791, isNot(contains('medicare.time_in_out')));
    });

    test('rule without appliesToCptCodes fires for every CPT', () {
      final pack = PayerRulePacks.forPayer(Payer.uhcOptum);
      // optum.measurable_goal has no appliesToCptCodes restriction.
      expect(
        pack.rulesFor('90837').map((r) => r.id),
        contains('optum.measurable_goal'),
      );
      expect(
        pack.rulesFor('90791').map((r) => r.id),
        contains('optum.measurable_goal'),
      );
    });
  });

  group('PayerRule.toDenialReason', () {
    test('preserves title / detail / fixSentence / suggestedInsert', () {
      final r = PayerRulePacks.forPayer(
        Payer.medicaid,
      ).rules.firstWhere((r) => r.id == 'medicaid.functional_impairment');
      final reason = r.toDenialReason();
      expect(reason.title, r.title);
      expect(reason.detail, r.detail);
      expect(reason.fixSentence, r.fixSentence);
      expect(reason.insertText, r.suggestedInsert);
    });

    test('critical flag is propagated', () {
      final critical = PayerRulePacks.forPayer(
        Payer.medicaid,
      ).rules.firstWhere((r) => r.critical).toDenialReason();
      expect(critical.critical, isTrue);
    });
  });

  test('forPayer returns the matching pack', () {
    final p = PayerRulePacks.forPayer(Payer.cigna);
    expect(p.payer, Payer.cigna);
    expect(p.rules, isNotEmpty);
  });
}
