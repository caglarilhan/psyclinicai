import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/billing/cpt_lookup_service.dart';

/// Billing-correctness: the time-band boundaries decide which CPT code (and
/// thus which reimbursement: $95 / $125 / $175) surfaces on the superbill. An
/// off-by-one here is a real money/denial bug, so the boundaries are pinned.
void main() {
  final svc = CptLookupService.instance;

  group('suggestForDuration time bands', () {
    test('non-positive duration yields no suggestion', () {
      expect(svc.suggestForDuration(0), isNull);
      expect(svc.suggestForDuration(-5), isNull);
    });

    test('1..37 min -> 90832 (30-min)', () {
      expect(svc.suggestForDuration(1)?.code, '90832');
      expect(svc.suggestForDuration(37)?.code, '90832');
    });

    test('38..52 min -> 90834 (45-min) — the off-by-one boundary', () {
      expect(svc.suggestForDuration(38)?.code, '90834');
      expect(svc.suggestForDuration(45)?.code, '90834');
      expect(svc.suggestForDuration(52)?.code, '90834');
    });

    test('53+ min -> 90837 (60-min)', () {
      expect(svc.suggestForDuration(53)?.code, '90837');
      expect(svc.suggestForDuration(90)?.code, '90837');
    });
  });

  group('lookup', () {
    test('byCode returns the right code with its CMS average, null when absent',
        () {
      expect(svc.byCode('90837')?.nationalAverageUsd, 175);
      expect(svc.byCode('90834')?.nationalAverageUsd, 125);
      expect(svc.byCode('90832')?.nationalAverageUsd, 95);
      expect(svc.byCode('00000'), isNull);
    });

    test('byCategory(crisis) returns exactly the crisis pair', () {
      final crisis = svc.byCategory(CptCategory.crisis);
      expect(crisis.map((c) => c.code).toSet(), {'90839', '90840'});
    });

    test('all() exposes the full curated set and is unmodifiable', () {
      expect(svc.all(), hasLength(12));
      expect(() => svc.all().add(svc.all().first), throwsUnsupportedError);
    });
  });
}
