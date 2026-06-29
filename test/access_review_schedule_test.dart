import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/access_review_schedule.dart';

void main() {
  group('AccessReviewSchedule — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(AccessReviewSchedule.scopes, isNotEmpty);
    });

    test('every scope has a unique id', () {
      final ids = AccessReviewSchedule.scopes.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final s in AccessReviewSchedule.scopes) {
        expect(AccessReviewSchedule.byId(s.id), same(s));
      }
      expect(AccessReviewSchedule.byId('does-not-exist'), isNull);
    });

    test('every scope has all fields populated + anchors cite a standard', () {
      const allowedStandards = ['SOC 2', 'HIPAA', 'ISO', 'GDPR', 'NIST', 'PCI'];
      for (final s in AccessReviewSchedule.scopes) {
        expect(s.name, isNotEmpty, reason: s.id);
        expect(s.reviewerRole, isNotEmpty, reason: s.id);
        expect(s.evidencePath, isNotEmpty, reason: s.id);
        expect(s.snapshotSource, isNotEmpty, reason: s.id);
        expect(s.regulatoryRefs, isNotEmpty, reason: s.id);
        final blob = s.regulatoryRefs.join(' | ');
        expect(
          allowedStandards.any(blob.contains),
          isTrue,
          reason: '${s.id}: regulatoryRefs cite no known standard',
        );
      }
    });

    test('quarterly sign-off SLA is 7 days; slower cadences ≤ 14', () {
      for (final s in AccessReviewSchedule.scopes) {
        if (s.cadence == ReviewCadence.quarterly) {
          expect(
            s.signOffSlaDays,
            7,
            reason:
                '${s.id}: quarterly review must sign off within 7 days '
                '(SOC 2 CC6.2 evidence window).',
          );
        } else {
          expect(
            s.signOffSlaDays,
            lessThanOrEqualTo(14),
            reason: '${s.id}: sign-off SLA cap is 14 days for any cadence.',
          );
        }
      }
    });

    test('annual cadence is allow-listed only', () {
      const justifiedAnnual = {'stripe_dashboard_team'};
      for (final s in AccessReviewSchedule.scopes) {
        if (s.cadence == ReviewCadence.annual) {
          expect(
            justifiedAnnual,
            contains(s.id),
            reason:
                '${s.id}: annual cadence requires explicit justification in '
                'the test allow-list.',
          );
        }
      }
    });

    test('clinicians_roster scope mirrors the existing Cloud Function', () {
      final clinicians = AccessReviewSchedule.byId('clinicians_roster');
      expect(clinicians, isNotNull);
      expect(clinicians!.cadence, ReviewCadence.quarterly);
      expect(clinicians.signOffSlaDays, 7);
      expect(clinicians.evidencePath, startsWith('firestore://'));
      expect(clinicians.snapshotSource, 'firestore://clinicians');
    });

    test('reviewer roles span beyond a single owner (no bus factor 1)', () {
      final roles = AccessReviewSchedule.scopes
          .map((s) => s.reviewerRole)
          .toSet();
      expect(
        roles.length,
        greaterThanOrEqualTo(3),
        reason:
            'all scopes assigned to a single role = bus factor 1; spread '
            'across CISO / CTO / CFO / compliance officer.',
      );
    });
  });

  group('cronForCadence', () {
    test('emits a 5-field cron for every cadence', () {
      for (final c in ReviewCadence.values) {
        final cron = cronForCadence(c);
        final parts = cron.split(' ');
        expect(parts.length, 5, reason: 'cron for ${c.name} is malformed');
      }
    });

    test('monthly runs on the 1st of every month', () {
      expect(cronForCadence(ReviewCadence.monthly), '0 6 1 * *');
    });

    test('quarterly runs Jan / Apr / Jul / Oct', () {
      expect(cronForCadence(ReviewCadence.quarterly), '0 6 1 1,4,7,10 *');
    });

    test('semiAnnual runs Jan + Jul', () {
      expect(cronForCadence(ReviewCadence.semiAnnual), '0 6 1 1,7 *');
    });

    test('annual runs first day of January', () {
      expect(cronForCadence(ReviewCadence.annual), '0 6 1 1 *');
    });
  });
}
