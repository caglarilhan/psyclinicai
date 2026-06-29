import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/support_escalation_matrix.dart';

void main() {
  group('SupportEscalationMatrix — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(SupportEscalationMatrix.entries, isNotEmpty);
    });

    test('matrix is complete: 3 tiers × 4 severities = 12 entries', () {
      expect(SupportEscalationMatrix.entries.length, 12);
      for (final tier in SupportTier.values) {
        for (final severity in TicketSeverity.values) {
          expect(
            () => SupportEscalationMatrix.forTierAndSeverity(tier, severity),
            returnsNormally,
            reason:
                'matrix missing ${tier.name}/${severity.name} — every '
                '(tier × severity) pair MUST be pinned',
          );
        }
      }
    });

    test('every (tier, severity) pair is unique', () {
      final keys = SupportEscalationMatrix.entries
          .map((e) => '${e.tier.name}|${e.severity.name}')
          .toList();
      expect(
        keys.toSet().length,
        keys.length,
        reason: 'duplicate (tier, severity) pairs',
      );
    });

    test('every entry has all fields populated', () {
      for (final e in SupportEscalationMatrix.entries) {
        expect(e.firstResponseHours, greaterThan(0));
        expect(e.resolutionTargetHours, greaterThan(0));
        expect(e.escalationOwner, isNotEmpty);
        expect(e.contactChannel, isNotEmpty);
      }
    });

    test(
      'enterprise > pilot > free for first-response speed within each severity',
      () {
        for (final s in TicketSeverity.values) {
          final ent = SupportEscalationMatrix.forTierAndSeverity(
            SupportTier.enterprise,
            s,
          );
          final pilot = SupportEscalationMatrix.forTierAndSeverity(
            SupportTier.pilot,
            s,
          );
          final free = SupportEscalationMatrix.forTierAndSeverity(
            SupportTier.free,
            s,
          );
          expect(
            ent.firstResponseHours,
            lessThan(pilot.firstResponseHours),
            reason:
                'enterprise/${s.name} first-response (${ent.firstResponseHours}h) '
                'must be faster than pilot/${s.name} (${pilot.firstResponseHours}h)',
          );
          expect(
            pilot.firstResponseHours,
            lessThan(free.firstResponseHours),
            reason:
                'pilot/${s.name} first-response (${pilot.firstResponseHours}h) '
                'must be faster than free/${s.name} (${free.firstResponseHours}h)',
          );
        }
      },
    );

    test('urgent first-response is the fastest within each tier', () {
      for (final t in SupportTier.values) {
        final urgent = SupportEscalationMatrix.forTierAndSeverity(
          t,
          TicketSeverity.urgent,
        );
        for (final s in TicketSeverity.values) {
          if (s == TicketSeverity.urgent) continue;
          final other = SupportEscalationMatrix.forTierAndSeverity(t, s);
          expect(
            urgent.firstResponseHours,
            lessThanOrEqualTo(other.firstResponseHours),
            reason:
                '${t.name}/urgent (${urgent.firstResponseHours}h) must be '
                '≤ ${t.name}/${s.name} (${other.firstResponseHours}h)',
          );
        }
      }
    });

    test('resolution target ≥ first-response in every cell', () {
      for (final e in SupportEscalationMatrix.entries) {
        expect(
          e.resolutionTargetHours,
          greaterThanOrEqualTo(e.firstResponseHours),
          reason:
              '${e.tier.name}/${e.severity.name}: resolution must not be '
              'tighter than first-response',
        );
      }
    });

    test('after-hours coverage on enterprise urgent + high', () {
      final entHigh = SupportEscalationMatrix.forTierAndSeverity(
        SupportTier.enterprise,
        TicketSeverity.high,
      );
      final entUrgent = SupportEscalationMatrix.forTierAndSeverity(
        SupportTier.enterprise,
        TicketSeverity.urgent,
      );
      expect(entUrgent.afterHoursCoverage, isTrue);
      expect(entHigh.afterHoursCoverage, isTrue);
    });

    test('free tier never includes after-hours coverage', () {
      for (final s in TicketSeverity.values) {
        final free = SupportEscalationMatrix.forTierAndSeverity(
          SupportTier.free,
          s,
        );
        expect(
          free.afterHoursCoverage,
          isFalse,
          reason: 'free/${s.name}: after-hours coverage is a paid-tier benefit',
        );
      }
    });

    test('enterprise urgent reaches the on-call via pager', () {
      final entUrgent = SupportEscalationMatrix.forTierAndSeverity(
        SupportTier.enterprise,
        TicketSeverity.urgent,
      );
      expect(entUrgent.escalationOwner, 'on_call');
      expect(entUrgent.contactChannel, 'pager');
    });
  });

  group('isFirstResponseBreached', () {
    test('returns false when window has not elapsed', () {
      final sla = SupportEscalationMatrix.forTierAndSeverity(
        SupportTier.enterprise,
        TicketSeverity.urgent,
      );
      final opened = DateTime.parse('2026-06-26T10:00:00Z');
      final now = opened.add(const Duration(minutes: 30));
      expect(
        isFirstResponseBreached(sla: sla, openedAt: opened, now: now),
        isFalse,
      );
    });

    test('returns true once the window elapses', () {
      final sla = SupportEscalationMatrix.forTierAndSeverity(
        SupportTier.enterprise,
        TicketSeverity.urgent,
      );
      final opened = DateTime.parse('2026-06-26T10:00:00Z');
      final now = opened.add(const Duration(hours: 2));
      expect(
        isFirstResponseBreached(sla: sla, openedAt: opened, now: now),
        isTrue,
      );
    });
  });
}
