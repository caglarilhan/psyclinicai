/// Coverage for PatientSlug — encode determinism, tenant-salt
/// isolation, length + alphabet invariants, constant-time matcher,
/// and the empty-input guards.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/patient_slug.dart';

void main() {
  group('PatientSlug.encode', () {
    test('produces a 12-character slug', () {
      final slug = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      expect(slug, hasLength(12));
    });

    test('is deterministic for the same (id, salt) pair', () {
      final a = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      final b = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      expect(a, b);
    });

    test('differs when the tenant salt changes', () {
      final a = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      final b = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-B',
      );
      expect(a, isNot(b));
    });

    test('differs when the patient id changes', () {
      final a = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      final b = PatientSlug.encode(
        patientId: 'pat-002',
        tenantSalt: 'tenant-A',
      );
      expect(a, isNot(b));
    });

    test('only emits Crockford-lite uppercase alphabet (no I/O/L/0/1)', () {
      const allowed = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
      final slug = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      for (final ch in slug.split('')) {
        expect(allowed.contains(ch), isTrue, reason: '"$ch" not in alphabet');
      }
    });

    test('rejects empty patientId', () {
      expect(
        () => PatientSlug.encode(patientId: '', tenantSalt: 'tenant-A'),
        throwsArgumentError,
      );
    });

    test('rejects empty tenantSalt', () {
      expect(
        () => PatientSlug.encode(patientId: 'pat-001', tenantSalt: ''),
        throwsArgumentError,
      );
    });
  });

  group('PatientSlug.matches', () {
    test('returns true for the canonical slug', () {
      final slug = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      expect(
        PatientSlug.matches(
          slug: slug,
          patientId: 'pat-001',
          tenantSalt: 'tenant-A',
        ),
        isTrue,
      );
    });

    test('returns false when the slug is for a different patient', () {
      final slug = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      expect(
        PatientSlug.matches(
          slug: slug,
          patientId: 'pat-002',
          tenantSalt: 'tenant-A',
        ),
        isFalse,
      );
    });

    test('returns false when the salt is different', () {
      final slug = PatientSlug.encode(
        patientId: 'pat-001',
        tenantSalt: 'tenant-A',
      );
      expect(
        PatientSlug.matches(
          slug: slug,
          patientId: 'pat-001',
          tenantSalt: 'tenant-B',
        ),
        isFalse,
      );
    });

    test('returns false for length mismatch without throwing', () {
      expect(
        PatientSlug.matches(
          slug: 'TOOSHORT',
          patientId: 'pat-001',
          tenantSalt: 'tenant-A',
        ),
        isFalse,
      );
    });
  });

  group('uniqueness across a small population', () {
    test('1000 patient ids under one tenant produce 1000 distinct slugs', () {
      final seen = <String>{};
      for (var i = 0; i < 1000; i++) {
        seen.add(PatientSlug.encode(patientId: 'p-$i', tenantSalt: 'tenant-A'));
      }
      expect(seen, hasLength(1000));
    });
  });
}
