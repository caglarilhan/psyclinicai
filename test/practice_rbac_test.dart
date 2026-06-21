import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/auth/practice_rbac.dart';

void main() {
  group('PracticeRbac matrix', () {
    test('admin has every permission', () {
      for (final perm in PracticePermission.values) {
        expect(
          PracticeRbac.has(PracticeRole.admin, perm),
          isTrue,
          reason: 'admin should have $perm',
        );
      }
    });

    test('intern cannot sign a progress note (supervision wedge)', () {
      expect(
        PracticeRbac.has(PracticeRole.intern, PracticePermission.signProgressNote),
        isFalse,
      );
      // But interns can draft + submit AI requests — that is the
      // supervision touchpoint.
      expect(
        PracticeRbac.has(PracticeRole.intern, PracticePermission.editClinicalNote),
        isTrue,
      );
      expect(
        PracticeRbac.has(PracticeRole.intern, PracticePermission.submitAiRequest),
        isTrue,
      );
    });

    test('biller cannot edit clinical notes (PHI minimisation)', () {
      expect(
        PracticeRbac.has(
          PracticeRole.biller,
          PracticePermission.editClinicalNote,
        ),
        isFalse,
      );
      // But biller has the financial + claim permissions.
      expect(
        PracticeRbac.has(PracticeRole.biller, PracticePermission.submitBilling),
        isTrue,
      );
      expect(
        PracticeRbac.has(PracticeRole.biller, PracticePermission.viewFinancials),
        isTrue,
      );
    });

    test('clinician does NOT see all patients (caseload-scoped)', () {
      expect(
        PracticeRbac.has(
          PracticeRole.clinician,
          PracticePermission.viewAllPatients,
        ),
        isFalse,
      );
      // But supervisor + admin + biller do.
      expect(
        PracticeRbac.has(
          PracticeRole.supervisor,
          PracticePermission.viewAllPatients,
        ),
        isTrue,
      );
    });

    test('only supervisor + admin sign supervision reports', () {
      expect(
        PracticeRbac.has(
          PracticeRole.supervisor,
          PracticePermission.signSupervisionReport,
        ),
        isTrue,
      );
      expect(
        PracticeRbac.has(
          PracticeRole.admin,
          PracticePermission.signSupervisionReport,
        ),
        isTrue,
      );
      for (final r in [
        PracticeRole.clinician,
        PracticeRole.intern,
        PracticeRole.biller,
      ]) {
        expect(
          PracticeRbac.has(r, PracticePermission.signSupervisionReport),
          isFalse,
          reason: '$r should NOT sign supervision reports',
        );
      }
    });

    test('only admin can manage users + view audit log + run DSAR', () {
      for (final perm in [
        PracticePermission.manageUsers,
        PracticePermission.viewAuditLog,
        PracticePermission.runDsarExport,
        PracticePermission.manageBilling,
      ]) {
        for (final r in PracticeRole.values) {
          final allowed = r == PracticeRole.admin;
          expect(
            PracticeRbac.has(r, perm),
            allowed,
            reason: '$r vs $perm should be $allowed',
          );
        }
      }
    });

    test('maybeHas returns false for a null role', () {
      expect(
        PracticeRbac.maybeHas(null, PracticePermission.submitAiRequest),
        isFalse,
      );
    });

    test('permissionsOf returns an unmodifiable view', () {
      final perms = PracticeRbac.permissionsOf(PracticeRole.clinician);
      expect(perms, contains(PracticePermission.editClinicalNote));
      expect(
        () => perms.add(PracticePermission.manageUsers),
        throwsUnsupportedError,
      );
    });
  });

  group('PracticeRbac.fromWireName', () {
    test('round-trips every enum value via name', () {
      for (final role in PracticeRole.values) {
        expect(PracticeRbac.fromWireName(role.name), role);
      }
    });

    test('returns null for unknown / empty inputs', () {
      expect(PracticeRbac.fromWireName(null), isNull);
      expect(PracticeRbac.fromWireName(''), isNull);
      expect(PracticeRbac.fromWireName('superuser'), isNull);
      expect(
        PracticeRbac.fromWireName('ADMIN'),
        isNull,
        reason: 'wire format is lowercase enum.name',
      );
    });
  });

  // Patient-safety invariant: PHI-write operations must be gated by
  // at least one fully-enumerated role. Locks the matrix so future
  // edits can't accidentally orphan a permission.
  test(
      'every permission is granted to at least one role (no orphan permissions)',
      () {
    for (final perm in PracticePermission.values) {
      final grantedTo = PracticeRole.values
          .where((r) => PracticeRbac.has(r, perm))
          .toList();
      expect(
        grantedTo,
        isNotEmpty,
        reason: 'permission $perm is granted to nobody',
      );
    }
  });
}
