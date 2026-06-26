import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/dr_drill_schedule.dart';

// Known-good backup target ids — mirrors BackupCatalog.entries (N4,
// PR #121). Once #121 + this PR are both on main, a follow-up wires
// the test to import BackupCatalog directly so the parity stays
// self-maintaining.
const _knownBackupTargetIds = {
  'firestore_default_daily',
  'clinic_audit_logs_weekly_cold',
  'consent_records_daily',
  'app_secrets_kms_snapshot',
  'business_ops_daily',
};

void main() {
  group('DrDrillSchedule — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(DrDrillSchedule.drills, isNotEmpty);
    });

    test('every drill has a unique id', () {
      final ids = DrDrillSchedule.drills.map((d) => d.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final d in DrDrillSchedule.drills) {
        expect(DrDrillSchedule.byId(d.id), same(d));
      }
      expect(DrDrillSchedule.byId('does-not-exist'), isNull);
    });

    test(
      'parity with known backup targets — every drill points at a real id',
      () {
        for (final d in DrDrillSchedule.drills) {
          expect(
            _knownBackupTargetIds,
            contains(d.backupTargetId),
            reason:
                '${d.id}: backupTargetId `${d.backupTargetId}` is not in '
                'the known-good BackupCatalog id set — fix the parity',
          );
        }
      },
    );

    test('every known backup target has at least one drill', () {
      for (final id in _knownBackupTargetIds) {
        expect(
          DrDrillSchedule.drillsForTarget(id),
          isNotEmpty,
          reason:
              'backup target $id has no DR drill — adding a target requires '
              'adding its drill (HIPAA §164.308(a)(7)(ii)(D)).',
        );
      }
    });

    test('every drill has signOff fields + evidence path + anchors', () {
      for (final d in DrDrillSchedule.drills) {
        expect(d.signOffOwner, isNotEmpty, reason: d.id);
        expect(d.signOffSlaDays, greaterThan(0), reason: d.id);
        expect(d.evidencePathTemplate, startsWith('docs/'), reason: d.id);
        expect(d.evidencePathTemplate, endsWith('.MANUAL.md'), reason: d.id);
        expect(d.regulatoryRefs, isNotEmpty, reason: d.id);
      }
    });

    test('quarterly drills sign off within 7 days; slower ≤ 14', () {
      for (final d in DrDrillSchedule.drills) {
        if (d.cadence == DrillCadence.quarterly) {
          expect(
            d.signOffSlaDays,
            7,
            reason:
                '${d.id}: quarterly drills must sign off within 7 days '
                '(SOC 2 CC9.2 evidence window).',
          );
        } else {
          expect(
            d.signOffSlaDays,
            lessThanOrEqualTo(14),
            reason: '${d.id}: sign-off SLA cap is 14 days.',
          );
        }
      }
    });

    test('audit chain drill stays on semi-annual cadence (HIPAA 7y trail)', () {
      final chain = DrDrillSchedule.byId(
        'drill-clinic-audit-chain-semi-annual',
      );
      expect(chain, isNotNull);
      expect(chain!.cadence, DrillCadence.semiAnnual);
      expect(chain.scope, DrillScope.fullRestoreReconciliation);
    });

    test('owner roles span ≥ 3 (no bus factor 1)', () {
      final owners = DrDrillSchedule.drills.map((d) => d.signOffOwner).toSet();
      expect(
        owners.length,
        greaterThanOrEqualTo(3),
        reason:
            'all drills assigned to one role = bus factor 1; spread across '
            'CTO / CISO / CFO / compliance officer',
      );
    });

    test('evidence path templates use canonical date placeholders', () {
      const allowed = ['<YYYYqN>', '<YYYY-mm>', '<YYYY>'];
      for (final d in DrDrillSchedule.drills) {
        expect(
          allowed.any(d.evidencePathTemplate.contains),
          isTrue,
          reason:
              '${d.id}: evidencePathTemplate must contain one of '
              '<YYYYqN> / <YYYY-mm> / <YYYY>',
        );
      }
    });
  });

  group('drillsForTarget helper', () {
    test('returns every drill for a target', () {
      final drills = DrDrillSchedule.drillsForTarget('firestore_default_daily');
      expect(drills, isNotEmpty);
      for (final d in drills) {
        expect(d.backupTargetId, 'firestore_default_daily');
      }
    });

    test('returns empty list for an unknown target', () {
      expect(DrDrillSchedule.drillsForTarget('does-not-exist'), isEmpty);
    });
  });

  group('cronForDrillCadence', () {
    test('emits 5-field cron for every cadence', () {
      for (final c in DrillCadence.values) {
        final cron = cronForDrillCadence(c);
        expect(cron.split(' ').length, 5, reason: c.name);
      }
    });

    test('quarterly fires Jan / Apr / Jul / Oct at 02:00 UTC', () {
      expect(cronForDrillCadence(DrillCadence.quarterly), '0 2 1 1,4,7,10 *');
    });

    test('semiAnnual fires Jan + Jul', () {
      expect(cronForDrillCadence(DrillCadence.semiAnnual), '0 2 1 1,7 *');
    });

    test('annual fires Jan 1', () {
      expect(cronForDrillCadence(DrillCadence.annual), '0 2 1 1 *');
    });
  });
}
