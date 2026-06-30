import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/noshow/noshow_feature_catalog.dart';

void main() {
  group('NoShowFeatureCatalog invariants', () {
    test('non-empty + unique keys', () {
      expect(NoShowFeatureCatalog.features, isNotEmpty);
      final seen = <String>{};
      for (final f in NoShowFeatureCatalog.features) {
        expect(seen.contains(f.key), isFalse,
            reason: '${f.key}: duplicate');
        seen.add(f.key);
      }
    });

    test('every feature has non-empty rationale', () {
      for (final f in NoShowFeatureCatalog.features) {
        expect(f.rationale.trim(), isNotEmpty);
      }
    });

    test('no feature has high PHI sensitivity', () {
      for (final f in NoShowFeatureCatalog.features) {
        expect(f.phiSensitivity, isNot(PhiSensitivity.high),
            reason: '${f.key}: high-PHI feature must not be in catalog');
      }
    });

    test('all three tiers have a playbook', () {
      for (final t in NoShowRiskTier.values) {
        final p = NoShowFeatureCatalog.playbookFor(t);
        expect(p.tier, t);
      }
    });

    test('high tier requires deposit + waitlist offer', () {
      final p = NoShowFeatureCatalog.playbookFor(NoShowRiskTier.high);
      expect(p.depositRequired, isTrue);
      expect(p.waitlistOfferOnCancel, isTrue);
    });

    test('low tier never spams (single 24h reminder, no deposit)', () {
      final p = NoShowFeatureCatalog.playbookFor(NoShowRiskTier.low);
      expect(p.depositRequired, isFalse);
      expect(p.confirmCadenceHours.length, 1);
    });

    test('confirmCadenceHours sorted DESCENDING (earliest reminder first)',
        () {
      for (final p in NoShowFeatureCatalog.playbooks) {
        final sorted = [...p.confirmCadenceHours]
          ..sort((a, b) => b.compareTo(a));
        expect(p.confirmCadenceHours, sorted,
            reason: '${p.tier}: cadence not sorted descending');
      }
    });

    test('outcomeLabels carries the canonical 5 labels', () {
      expect(
        NoShowFeatureCatalog.outcomeLabels.keys.toSet(),
        {'attended', 'noshow', 'late_cancel', 'on_time_cancel', 'rescheduled'},
      );
    });

    test('byKey throws for unknown', () {
      expect(() => NoShowFeatureCatalog.byKey('nope'), throwsStateError);
    });

    test('schemaVersion + lastReviewed shape', () {
      expect(NoShowFeatureCatalog.schemaVersion > 0, isTrue);
      expect(NoShowFeatureCatalog.lastReviewed,
          matches(RegExp(r'^\d{4}-\d{2}$')));
    });
  });

  group('tierForProbability', () {
    test('low band', () {
      expect(tierForProbability(0.0), NoShowRiskTier.low);
      expect(tierForProbability(0.14), NoShowRiskTier.low);
    });

    test('medium band', () {
      expect(tierForProbability(0.15), NoShowRiskTier.medium);
      expect(tierForProbability(0.39), NoShowRiskTier.medium);
    });

    test('high band', () {
      expect(tierForProbability(0.40), NoShowRiskTier.high);
      expect(tierForProbability(1.0), NoShowRiskTier.high);
    });
  });
}
