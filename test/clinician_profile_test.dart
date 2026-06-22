import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/auth_service.dart';
import 'package:psyclinicai/services/data/firestore_schema.dart';

void main() {
  group('ClinicianProfile.licenseExpiringSoon', () {
    ClinicianProfile build({DateTime? expiry}) => ClinicianProfile(
      userId: 'u1',
      clinicId: 'c1',
      email: 'jane@example.com',
      fullName: 'Jane Doe',
      role: ClinicianRole.therapist,
      licenseExpiry: expiry,
    );

    test('is false when no expiry is on file', () {
      expect(build().licenseExpiringSoon, isFalse);
    });

    test('is false when expiry is more than 60 days away', () {
      final far = DateTime.now().add(const Duration(days: 365));
      expect(build(expiry: far).licenseExpiringSoon, isFalse);
    });

    test('is true within the 60-day warning window', () {
      final soon = DateTime.now().add(const Duration(days: 30));
      expect(build(expiry: soon).licenseExpiringSoon, isTrue);
    });

    test('is true when the license has already expired', () {
      final expired = DateTime.now().subtract(const Duration(days: 5));
      expect(build(expiry: expired).licenseExpiringSoon, isTrue);
    });

    test('boundary: exactly 60 days away counts as expiring soon', () {
      final boundary = DateTime.now().add(const Duration(days: 60));
      expect(build(expiry: boundary).licenseExpiringSoon, isTrue);
    });
  });

  group('ClinicianProfile.copyWith', () {
    test('updates only the supplied fields, preserving identity', () {
      final base = ClinicianProfile(
        userId: 'u1',
        clinicId: 'c1',
        email: 'jane@example.com',
        fullName: 'Jane Doe',
        role: ClinicianRole.therapist,
        credentials: 'LCSW',
        npi: '1234567890',
      );

      final next = base.copyWith(specialty: 'CBT, trauma');
      expect(next.userId, 'u1');
      expect(next.email, 'jane@example.com');
      expect(next.fullName, 'Jane Doe', reason: 'unchanged');
      expect(next.credentials, 'LCSW', reason: 'unchanged');
      expect(next.npi, '1234567890', reason: 'unchanged');
      expect(next.specialty, 'CBT, trauma');
    });

    test('updates license expiry independently of other fields', () {
      final base = ClinicianProfile(
        userId: 'u1',
        clinicId: 'c1',
        email: 'jane@example.com',
        fullName: 'Jane',
        role: ClinicianRole.therapist,
      );
      final exp = DateTime(2030);
      final next = base.copyWith(licenseExpiry: exp);
      expect(next.licenseExpiry, exp);
      expect(next.fullName, 'Jane');
    });
  });
}
