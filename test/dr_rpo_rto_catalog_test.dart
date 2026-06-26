import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ops/dr_rpo_rto_catalog.dart';

void main() {
  group('DrRpoRtoCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(DrRpoRtoCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = DrRpoRtoCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in DrRpoRtoCatalog.records) {
        expect(DrRpoRtoCatalog.byId(r.id), same(r));
      }
      expect(DrRpoRtoCatalog.byId('does-not-exist'), isNull);
    });

    test('every DrServiceTier has exactly one pinned record', () {
      for (final t in DrServiceTier.values) {
        final matches = DrRpoRtoCatalog.records
            .where((r) => r.tier == t)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${t.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors + positive numbers', () {
      for (final r in DrRpoRtoCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.rpoMinutes, greaterThan(0), reason: r.id);
        expect(r.rtoMinutes, greaterThan(0), reason: r.id);
        expect(r.drillCadenceDays, greaterThan(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('patient-care RPO MUST be <= 5 minutes (clinical-safety floor)', () {
      final r = DrRpoRtoCatalog.byTier(DrServiceTier.patientCare)!;
      expect(
        r.rpoMinutes,
        lessThanOrEqualTo(5),
        reason:
            'patient-care RPO > 5 min risks losing an active session and degrading clinical safety',
      );
    });

    test('patient-care RTO MUST be <= 30 minutes (clinical-safety ceiling)', () {
      final r = DrRpoRtoCatalog.byTier(DrServiceTier.patientCare)!;
      expect(
        r.rtoMinutes,
        lessThanOrEqualTo(30),
        reason:
            'patient-care RTO > 30 min means a telehealth session window is gone',
      );
    });

    test('patient-care + clinician-admin MUST require backup drill', () {
      for (final t in [
        DrServiceTier.patientCare,
        DrServiceTier.clinicianAdmin,
      ]) {
        final r = DrRpoRtoCatalog.byTier(t)!;
        expect(
          r.requiresBackupDrill,
          isTrue,
          reason:
              '${t.name}: PHI-touching service must prove backups restore (untested backup = no backup)',
        );
      }
    });

    test('patient-care drill cadence MUST be <= 90 days (quarterly minimum)', () {
      final r = DrRpoRtoCatalog.byTier(DrServiceTier.patientCare)!;
      expect(
        r.drillCadenceDays,
        lessThanOrEqualTo(90),
        reason:
            'patient-care drill cadence > 90 days lets recovery skills degrade past auditor-defensibility',
      );
    });

    test(
      'RPO ladder monotonic: patient-care < clinician-admin <= tenant-onboarding <= observability',
      () {
        final pc = DrRpoRtoCatalog.byTier(
          DrServiceTier.patientCare,
        )!.rpoMinutes;
        final ca = DrRpoRtoCatalog.byTier(
          DrServiceTier.clinicianAdmin,
        )!.rpoMinutes;
        final to = DrRpoRtoCatalog.byTier(
          DrServiceTier.tenantOnboarding,
        )!.rpoMinutes;
        final ob = DrRpoRtoCatalog.byTier(
          DrServiceTier.observability,
        )!.rpoMinutes;
        expect(pc, lessThan(ca));
        expect(ca, lessThanOrEqualTo(to));
        expect(to, lessThanOrEqualTo(ob));
      },
    );

    test(
      'RTO ladder monotonic for clinical tiers: patient-care < clinician-admin <= tenant-onboarding',
      () {
        final pc = DrRpoRtoCatalog.byTier(
          DrServiceTier.patientCare,
        )!.rtoMinutes;
        final ca = DrRpoRtoCatalog.byTier(
          DrServiceTier.clinicianAdmin,
        )!.rtoMinutes;
        final to = DrRpoRtoCatalog.byTier(
          DrServiceTier.tenantOnboarding,
        )!.rtoMinutes;
        expect(pc, lessThan(ca));
        expect(ca, lessThanOrEqualTo(to));
      },
    );

    test('drill cadence ladder: patient-care < clinician-admin <= others', () {
      final pc = DrRpoRtoCatalog.byTier(
        DrServiceTier.patientCare,
      )!.drillCadenceDays;
      final ca = DrRpoRtoCatalog.byTier(
        DrServiceTier.clinicianAdmin,
      )!.drillCadenceDays;
      final to = DrRpoRtoCatalog.byTier(
        DrServiceTier.tenantOnboarding,
      )!.drillCadenceDays;
      final ob = DrRpoRtoCatalog.byTier(
        DrServiceTier.observability,
      )!.drillCadenceDays;
      final pm = DrRpoRtoCatalog.byTier(
        DrServiceTier.publicMarketing,
      )!.drillCadenceDays;
      expect(pc, lessThan(ca));
      expect(ca, lessThanOrEqualTo(to));
      expect(ca, lessThanOrEqualTo(ob));
      expect(ca, lessThanOrEqualTo(pm));
    });

    test(
      'patient-care + clinician-admin MUST cite HIPAA + ISO + SOC anchors',
      () {
        for (final t in [
          DrServiceTier.patientCare,
          DrServiceTier.clinicianAdmin,
        ]) {
          final r = DrRpoRtoCatalog.byTier(t)!;
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('HIPAA §164.308(a)(7)'),
            isTrue,
            reason: '${t.name}: needs HIPAA contingency-plan anchor',
          );
          expect(
            blob.contains('ISO 27001 A.17'),
            isTrue,
            reason: '${t.name}: needs ISO 27001 A.17 continuity anchor',
          );
          expect(
            blob.contains('SOC 2'),
            isTrue,
            reason: '${t.name}: needs SOC 2 anchor',
          );
        }
      },
    );

    test('every record MUST cite at least one ISO 27001 OR SOC 2 anchor', () {
      for (final r in DrRpoRtoCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('ISO 27001') || blob.contains('SOC 2'),
          isTrue,
          reason: '${r.id}: needs at least one ISO 27001 OR SOC 2 anchor',
        );
      }
    });
  });

  group('requiresBackupDrill helper', () {
    test('true ONLY for patient-care + clinician-admin', () {
      for (final t in DrServiceTier.values) {
        final expected =
            t == DrServiceTier.patientCare || t == DrServiceTier.clinicianAdmin;
        expect(requiresBackupDrill(t), expected, reason: t.name);
      }
    });
  });
}
