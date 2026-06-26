import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/scheduled_job_catalog.dart';

void main() {
  group('ScheduledJobCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(ScheduledJobCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = ScheduledJobCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in ScheduledJobCatalog.records) {
        expect(ScheduledJobCatalog.byId(r.id), same(r));
      }
      expect(ScheduledJobCatalog.byId('does-not-exist'), isNull);
    });

    test('every record id is kebab-case', () {
      final pattern = RegExp(r'^[a-z][a-z0-9-]*$');
      for (final r in ScheduledJobCatalog.records) {
        expect(
          pattern.hasMatch(r.id),
          isTrue,
          reason: '${r.id}: job ids are kebab-case for grep/log searchability',
        );
      }
    });

    test(
      'every record has populated fields + anchors + positive threshold',
      () {
        for (final r in ScheduledJobCatalog.records) {
          expect(r.description, isNotEmpty, reason: r.id);
          expect(r.cadenceLabel, isNotEmpty, reason: r.id);
          expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
          expect(
            r.maxConsecutiveFailuresBeforeP1,
            greaterThan(0),
            reason: r.id,
          );
        }
      },
    );
  });

  group('safety-critical invariants', () {
    test(
      'every record MUST be idempotent (runner needs to safely retry on transient failures)',
      () {
        for (final r in ScheduledJobCatalog.records) {
          expect(
            r.idempotent,
            isTrue,
            reason:
                '${r.id}: non-idempotent scheduled job + retry runner = double-charge or double-purge bugs; idempotency is a hard floor',
          );
        }
      },
    );

    test(
      'PHI-critical jobs MUST have alert threshold <= 2 (no silent multi-night skip)',
      () {
        for (final id in [
          'nightly-backup',
          'jwt-signing-key-rotation',
          'audit-log-hmac-rotation',
          'retention-purge-clinical-record',
          'cssrs-positive-followup-sweep',
        ]) {
          final r = ScheduledJobCatalog.byId(id)!;
          expect(
            r.maxConsecutiveFailuresBeforeP1,
            lessThanOrEqualTo(2),
            reason:
                '$id: PHI / key / clinical safety job — a 3rd consecutive failure must page someone',
          );
        }
      },
    );

    test('nightly-backup MUST page on first failure (RPO floor)', () {
      final r = ScheduledJobCatalog.byId('nightly-backup')!;
      expect(
        r.maxConsecutiveFailuresBeforeP1,
        1,
        reason:
            'one missed nightly backup already exceeds patient-care RPO; second miss = unrecoverable data loss window',
      );
    });

    test('every key-rotation job MUST be SRE-owned + page on first failure', () {
      for (final id in [
        'jwt-signing-key-rotation',
        'audit-log-hmac-rotation',
      ]) {
        final r = ScheduledJobCatalog.byId(id)!;
        expect(
          r.owner,
          JobOwner.sre,
          reason:
              '$id: key rotation is SRE-owned (compliance signs off but SRE runs)',
        );
        expect(
          r.maxConsecutiveFailuresBeforeP1,
          1,
          reason: '$id: a skipped rotation extends cryptoperiod beyond N20 cap',
        );
      }
    });

    test(
      'cssrs-positive-followup-sweep MUST cite Joint Commission NPSG 15.01.01',
      () {
        final r = ScheduledJobCatalog.byId('cssrs-positive-followup-sweep')!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(blob.contains('Joint Commission NPSG 15.01.01'), isTrue);
        expect(
          r.owner,
          JobOwner.clinicianOps,
          reason: 'suicide-risk sweep escalates to clinician ops, not SRE',
        );
      },
    );

    test('every record MUST cite at least one regulatory anchor', () {
      for (final r in ScheduledJobCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA') ||
              blob.contains('GDPR') ||
              blob.contains('SOC 2') ||
              blob.contains('ISO 27001') ||
              blob.contains('NIST') ||
              blob.contains('Joint Commission') ||
              blob.contains('FDA CDS'),
          isTrue,
          reason: '${r.id}: needs a regulatory anchor',
        );
      }
    });

    test(
      'cadence labels follow grep-able vocabulary (nightly/weekly/monthly/daily/every-)',
      () {
        final pattern = RegExp(r'^(nightly|weekly|monthly|daily|every)-');
        for (final r in ScheduledJobCatalog.records) {
          expect(
            pattern.hasMatch(r.cadenceLabel),
            isTrue,
            reason:
                '${r.id}: cadence label "${r.cadenceLabel}" must start with nightly/weekly/monthly/daily/every-',
          );
        }
      },
    );
  });

  group('byOwner + isSafeToRetry helpers', () {
    test('byOwner slices correctly', () {
      for (final o in JobOwner.values) {
        for (final r in ScheduledJobCatalog.byOwner(o)) {
          expect(r.owner, o);
        }
      }
    });

    test('isSafeToRetry true for every known job (catalog floor)', () {
      for (final r in ScheduledJobCatalog.records) {
        expect(isSafeToRetry(r.id), isTrue, reason: r.id);
      }
    });

    test('isSafeToRetry false for unknown job', () {
      expect(isSafeToRetry('does-not-exist'), isFalse);
    });
  });
}
