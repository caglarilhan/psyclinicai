import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/backup_recovery_plan.dart';

void main() {
  group('BackupCatalog pinned invariants', () {
    test('catalog is non-empty', () {
      expect(BackupCatalog.entries, isNotEmpty);
    });

    test('every target has a unique id', () {
      final ids = BackupCatalog.entries.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final t in BackupCatalog.entries) {
        expect(BackupCatalog.byId(t.id), same(t));
      }
      expect(BackupCatalog.byId('does-not-exist'), isNull);
    });

    test('every PHI-bearing target encrypts at rest', () {
      const phiClasses = {
        BackupDataClass.clinicalRecords,
        BackupDataClass.auditChain,
        BackupDataClass.consentRecords,
      };
      for (final t in BackupCatalog.entries) {
        if (phiClasses.contains(t.dataClass)) {
          expect(
            t.encryptionAtRest,
            isTrue,
            reason: '${t.id} carries PHI but does not encrypt at rest',
          );
        }
      }
    });

    test('schedule + retention + RPO + RTO are positive', () {
      for (final t in BackupCatalog.entries) {
        expect(t.scheduleHours, greaterThan(0), reason: t.id);
        expect(t.retentionDays, greaterThan(0), reason: t.id);
        expect(t.rpoMinutes, greaterThan(0), reason: t.id);
        expect(t.rtoMinutes, greaterThan(0), reason: t.id);
      }
    });

    test('audit chain retention >= 7 years (HIPAA §164.316(b)(2)(i))', () {
      final chain = BackupCatalog.byId('clinic_audit_logs_weekly_cold');
      expect(chain, isNotNull);
      expect(chain!.retentionDays, greaterThanOrEqualTo(2555));
    });

    test('consent records retention >= 7 years (KVKK md. 7 trail)', () {
      final consent = BackupCatalog.byId('consent_records_daily');
      expect(consent, isNotNull);
      expect(consent!.retentionDays, greaterThanOrEqualTo(2555));
    });

    test('every target cites at least one regulatory anchor', () {
      for (final t in BackupCatalog.entries) {
        expect(t.regulatoryRefs, isNotEmpty, reason: t.id);
      }
    });

    test('schedule cadence is finer than or equal to RPO budget', () {
      for (final t in BackupCatalog.entries) {
        final scheduleMinutes = t.scheduleHours * 60;
        expect(
          scheduleMinutes,
          lessThanOrEqualTo(t.rpoMinutes),
          reason:
              '${t.id}: schedule (${t.scheduleHours}h) coarser than '
              'RPO (${t.rpoMinutes}m) — backups cannot meet RPO',
        );
      }
    });
  });

  group('recoveryStepsFor', () {
    test('returns non-empty step list for every target', () {
      for (final t in BackupCatalog.entries) {
        expect(recoveryStepsFor(t), isNotEmpty, reason: t.id);
      }
    });

    test('every step has owner + positive target minutes + action', () {
      for (final t in BackupCatalog.entries) {
        for (final s in recoveryStepsFor(t)) {
          expect(s.ownerRole, isNotEmpty, reason: '${t.id} / ${s.label}');
          expect(
            s.targetMinutes,
            greaterThan(0),
            reason: '${t.id} / ${s.label}',
          );
          expect(s.action, isNotEmpty, reason: '${t.id} / ${s.label}');
        }
      }
    });

    test('audit chain target gets the chain-verify step', () {
      final chain = BackupCatalog.byId('clinic_audit_logs_weekly_cold')!;
      final verify = recoveryStepsFor(
        chain,
      ).firstWhere((s) => s.label == 'Verify integrity');
      expect(verify.action, contains('auditChainVerify'));
    });

    test('non-audit targets get the smoke-test verify step', () {
      final fs = BackupCatalog.byId('firestore_default_daily')!;
      final verify = recoveryStepsFor(
        fs,
      ).firstWhere((s) => s.label == 'Verify integrity');
      expect(verify.action, contains('Smoke-test'));
    });

    test('projectedRestoreMinutes <= RTO for every target', () {
      for (final t in BackupCatalog.entries) {
        final projected = projectedRestoreMinutes(t);
        expect(
          projected,
          lessThanOrEqualTo(t.rtoMinutes),
          reason:
              '${t.id}: projected restore (${projected}m) > RTO '
              '(${t.rtoMinutes}m) — runbook cannot meet SLA',
        );
      }
    });
  });
}
