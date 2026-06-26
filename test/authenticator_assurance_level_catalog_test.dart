import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/authenticator_assurance_level_catalog.dart';

void main() {
  group('AuthenticatorAssuranceLevelCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(AuthenticatorAssuranceLevelCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = AuthenticatorAssuranceLevelCatalog.records
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in AuthenticatorAssuranceLevelCatalog.records) {
        expect(AuthenticatorAssuranceLevelCatalog.byId(r.id), same(r));
      }
      expect(AuthenticatorAssuranceLevelCatalog.byId('does-not-exist'), isNull);
    });

    test('every UserRole has exactly one pinned record', () {
      for (final r in UserRole.values) {
        final matches = AuthenticatorAssuranceLevelCatalog.records
            .where((rec) => rec.role == r)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${r.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in AuthenticatorAssuranceLevelCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'patient MUST be AAL1 (single-factor — onboarding friction kills patient engagement)',
      () {
        final r = AuthenticatorAssuranceLevelCatalog.byRole(UserRole.patient)!;
        expect(r.minimumAal, AssuranceLevel.aal1);
        expect(
          r.acceptableSecondFactors,
          isEmpty,
          reason:
              'patient AAL1 means no second factor required; pinning options forces a UX expectation',
        );
      },
    );

    test('clinician + clinic-admin MUST be AAL2 (PHI handler floor)', () {
      for (final role in [UserRole.clinician, UserRole.clinicAdmin]) {
        final r = AuthenticatorAssuranceLevelCatalog.byRole(role)!;
        expect(
          aalAtLeast(r.minimumAal, AssuranceLevel.aal2),
          isTrue,
          reason:
              '${role.name}: PHI handler MUST be at least AAL2 per HIPAA §164.312(d) + NIST SP 800-63B',
        );
        expect(r.acceptableSecondFactors, isNotEmpty);
      }
    });

    test(
      'platform-admin + auditor MUST be AAL3 (phishing-resistant hardware only)',
      () {
        for (final role in [UserRole.platformAdmin, UserRole.auditor]) {
          final r = AuthenticatorAssuranceLevelCatalog.byRole(role)!;
          expect(
            r.minimumAal,
            AssuranceLevel.aal3,
            reason:
                '${role.name}: cross-tenant / audit-log access is the highest-risk surface — AAL3 hardware-backed mandatory',
          );
          expect(
            r.acceptableSecondFactors,
            [SecondFactorClass.hardwareKey],
            reason:
                '${role.name}: AAL3 = ONLY hardware key (no TOTP / push / platform authenticator phishing surface)',
          );
        }
      },
    );

    test(
      'every AAL2+ role MUST require re-auth for sensitive actions (EXCEPT auditor — read-only)',
      () {
        for (final r in AuthenticatorAssuranceLevelCatalog.records) {
          if (r.minimumAal == AssuranceLevel.aal1) continue;
          if (r.role == UserRole.auditor) {
            expect(
              r.requireReauthForSensitiveActions,
              isFalse,
              reason:
                  'auditor is read-only — pinning re-auth on every export is a check-the-box that burns auditor time',
            );
            continue;
          }
          expect(
            r.requireReauthForSensitiveActions,
            isTrue,
            reason:
                '${r.id}: PHI-modifying role must re-auth before sensitive actions (NIST SP 800-63B §4.1.1)',
          );
        }
      },
    );

    test(
      'AAL monotonicity across role hierarchy: patient < clinician <= clinicAdmin < platformAdmin',
      () {
        final patient = AuthenticatorAssuranceLevelCatalog.byRole(
          UserRole.patient,
        )!.minimumAal;
        final clinician = AuthenticatorAssuranceLevelCatalog.byRole(
          UserRole.clinician,
        )!.minimumAal;
        final clinicAdmin = AuthenticatorAssuranceLevelCatalog.byRole(
          UserRole.clinicAdmin,
        )!.minimumAal;
        final platformAdmin = AuthenticatorAssuranceLevelCatalog.byRole(
          UserRole.platformAdmin,
        )!.minimumAal;
        expect(
          aalAtLeast(clinician, patient),
          isTrue,
          reason: 'clinician AAL must be >= patient',
        );
        expect(
          aalAtLeast(clinicAdmin, clinician),
          isTrue,
          reason: 'clinic-admin AAL must be >= clinician',
        );
        expect(
          aalAtLeast(platformAdmin, clinicAdmin),
          isTrue,
          reason: 'platform-admin AAL must be >= clinic-admin',
        );
        expect(platformAdmin, AssuranceLevel.aal3);
      },
    );

    test('every record MUST cite NIST SP 800-63B (universal AAL anchor)', () {
      for (final r in AuthenticatorAssuranceLevelCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('NIST SP 800-63B'),
          isTrue,
          reason:
              '${r.id}: NIST SP 800-63B is the universal AAL definition anchor',
        );
      }
    });

    test('every role MUST cite HIPAA anchor', () {
      for (final role in UserRole.values) {
        final r = AuthenticatorAssuranceLevelCatalog.byRole(role)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA'),
          isTrue,
          reason: '${role.name}: needs a HIPAA anchor',
        );
      }
    });
  });

  group('aalAtLeast helper', () {
    test('AAL3 >= AAL3 >= AAL2 >= AAL1', () {
      expect(aalAtLeast(AssuranceLevel.aal3, AssuranceLevel.aal3), isTrue);
      expect(aalAtLeast(AssuranceLevel.aal3, AssuranceLevel.aal2), isTrue);
      expect(aalAtLeast(AssuranceLevel.aal3, AssuranceLevel.aal1), isTrue);
      expect(aalAtLeast(AssuranceLevel.aal2, AssuranceLevel.aal1), isTrue);
    });

    test('AAL1 < AAL2 < AAL3', () {
      expect(aalAtLeast(AssuranceLevel.aal1, AssuranceLevel.aal2), isFalse);
      expect(aalAtLeast(AssuranceLevel.aal1, AssuranceLevel.aal3), isFalse);
      expect(aalAtLeast(AssuranceLevel.aal2, AssuranceLevel.aal3), isFalse);
    });
  });
}
