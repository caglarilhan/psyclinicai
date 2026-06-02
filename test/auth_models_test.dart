import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/auth_models.dart';

void main() {
  group('UserRole.patient (Sprint 10)', () {
    test('parses a patient role from JSON', () {
      final user = User.fromJson({
        'id': 'u-1',
        'email': 'patient@example.com',
        'fullName': 'Sample Patient',
        'organizationId': 'org-1',
        'roles': ['patient'],
      });
      expect(user.roles, [UserRole.patient]);
    });

    test('round-trips with the rest of the roster intact', () {
      final user = User(
        id: 'u-2',
        email: 'mixed@example.com',
        fullName: 'Mixed Roster',
        roles: const [UserRole.admin, UserRole.patient],
        organizationId: 'org-1',
      );
      final round = User.fromJson(user.toJson());
      expect(round.roles, containsAll(<UserRole>[
        UserRole.admin,
        UserRole.patient,
      ]));
      expect(round.roles, hasLength(2));
    });

    test('UserRole.values still exposes every clinician role', () {
      // Defends against an accidental rename that would break stored
      // sessions for therapist / billing / auditor users.
      const expectedNames = {
        'admin',
        'therapist',
        'assistant',
        'billing',
        'auditor',
        'patient',
      };
      final names = UserRole.values.map((r) => r.name).toSet();
      expect(names, expectedNames);
    });
  });
}
