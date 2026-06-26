import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/feature_flag_registry.dart';

void main() {
  group('FeatureFlagRegistry — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(FeatureFlagRegistry.flags, isNotEmpty);
    });

    test('every flag key is unique', () {
      final keys = FeatureFlagRegistry.flags.map((f) => f.key).toList();
      expect(keys.toSet().length, keys.length, reason: 'duplicate flag keys');
    });

    test('byKey resolves every entry', () {
      for (final f in FeatureFlagRegistry.flags) {
        expect(FeatureFlagRegistry.byKey(f.key), same(f));
      }
      expect(FeatureFlagRegistry.byKey('does-not-exist'), isNull);
    });

    test('every flag key is snake_case', () {
      final snake = RegExp(r'^[a-z][a-z0-9_]*$');
      for (final f in FeatureFlagRegistry.flags) {
        expect(
          snake.hasMatch(f.key),
          isTrue,
          reason: '${f.key}: flag key must be snake_case',
        );
      }
    });

    test('every flag has populated fields', () {
      for (final f in FeatureFlagRegistry.flags) {
        expect(f.description, isNotEmpty, reason: f.key);
        expect(f.owner, isNotEmpty, reason: f.key);
        expect(f.createdIso, isNotEmpty, reason: f.key);
        expect(f.expiresIso, isNotEmpty, reason: f.key);
      }
    });

    test('every createdIso + expiresIso parses + expires > created', () {
      for (final f in FeatureFlagRegistry.flags) {
        final c = DateTime.parse(f.createdIso);
        final e = DateTime.parse(f.expiresIso);
        expect(
          e.isAfter(c),
          isTrue,
          reason: '${f.key}: expiresIso must be after createdIso',
        );
      }
    });

    test('every kill-switch declares non-empty kill criteria', () {
      for (final f in FeatureFlagRegistry.killSwitches()) {
        expect(
          f.killCriteria,
          isNotEmpty,
          reason:
              '${f.key}: kill switches MUST document the observable signal '
              'that trips them — auditors need to see the trigger',
        );
      }
    });

    test('kill-switch keys start with the "kill_" prefix', () {
      for (final f in FeatureFlagRegistry.killSwitches()) {
        expect(
          f.key,
          startsWith('kill_'),
          reason:
              '${f.key}: kill switches use the "kill_" prefix so reviewers '
              'spot them at a glance',
        );
      }
    });

    test('progressive-rollout flags expire within 12 months of creation', () {
      for (final f in FeatureFlagRegistry.flags) {
        if (f.purpose != FlagPurpose.progressiveRollout) continue;
        final c = DateTime.parse(f.createdIso);
        final e = DateTime.parse(f.expiresIso);
        final spanDays = e.difference(c).inDays;
        expect(
          spanDays,
          lessThanOrEqualTo(366),
          reason:
              '${f.key}: progressive-rollout flags MUST expire within 1 '
              'year so they do not accumulate',
        );
      }
    });

    test('tenant-override flags expire within 6 months of creation', () {
      for (final f in FeatureFlagRegistry.flags) {
        if (f.purpose != FlagPurpose.tenantOverride) continue;
        final c = DateTime.parse(f.createdIso);
        final e = DateTime.parse(f.expiresIso);
        final spanDays = e.difference(c).inDays;
        expect(
          spanDays,
          lessThanOrEqualTo(183),
          reason:
              '${f.key}: tenant-overrides MUST shrink fast (≤ 6 months) — '
              'they are intentional drift from the standard product',
        );
      }
    });

    test('byStage slices correctly', () {
      for (final s in FlagStage.values) {
        for (final f in FeatureFlagRegistry.byStage(s)) {
          expect(f.stage, s);
        }
      }
    });

    test('killSwitches() returns only killSwitch purpose flags', () {
      for (final f in FeatureFlagRegistry.killSwitches()) {
        expect(f.purpose, FlagPurpose.killSwitch);
      }
    });

    test('owner roles span beyond a single owner (no bus factor 1)', () {
      final owners = FeatureFlagRegistry.flags.map((f) => f.owner).toSet();
      expect(
        owners.length,
        greaterThanOrEqualTo(3),
        reason:
            'all flags assigned to one owner = bus factor 1; spread across '
            'CTO / CISO / CFO / clinical_advisor',
      );
    });
  });

  group('daysUntilFlagExpiry + isFlagExpired', () {
    test('positive when expiry is in the future', () {
      final f = FeatureFlagRegistry.byKey('rollout_telehealth_video')!;
      // expires 2026-12-31; today 2026-11-01 → 60 days remain.
      final today = DateTime.parse('2026-11-01');
      expect(daysUntilFlagExpiry(f, today), 60);
      expect(isFlagExpired(f, today), isFalse);
    });

    test('zero on the expiry day itself', () {
      final f = FeatureFlagRegistry.byKey('rollout_telehealth_video')!;
      final today = DateTime.parse('2026-12-31');
      expect(daysUntilFlagExpiry(f, today), 0);
      expect(isFlagExpired(f, today), isFalse);
    });

    test('negative + expired one day past', () {
      final f = FeatureFlagRegistry.byKey('rollout_telehealth_video')!;
      final today = DateTime.parse('2027-01-01');
      expect(daysUntilFlagExpiry(f, today), -1);
      expect(isFlagExpired(f, today), isTrue);
    });

    test(
      'no pinned flag is already expired as of 2026-06-26 (lastReviewed)',
      () {
        final today = DateTime.parse('2026-06-26');
        for (final f in FeatureFlagRegistry.flags) {
          expect(
            isFlagExpired(f, today),
            isFalse,
            reason:
                '${f.key}: already past expiresIso as of catalog '
                'lastReviewed — bump expiresIso or remove the row',
          );
        }
      },
    );
  });
}
