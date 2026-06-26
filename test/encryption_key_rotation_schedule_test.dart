import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/encryption_key_rotation_schedule.dart';

void main() {
  group('EncryptionKeyRotationSchedule — pinned invariants', () {
    test('records is non-empty', () {
      expect(EncryptionKeyRotationSchedule.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = EncryptionKeyRotationSchedule.records
          .map((r) => r.id)
          .toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in EncryptionKeyRotationSchedule.records) {
        expect(EncryptionKeyRotationSchedule.byId(r.id), same(r));
      }
      expect(EncryptionKeyRotationSchedule.byId('does-not-exist'), isNull);
    });

    test('every KeyClass has at least one pinned record', () {
      final pinned = EncryptionKeyRotationSchedule.records
          .map((r) => r.keyClass)
          .toSet();
      for (final c in KeyClass.values) {
        expect(
          pinned,
          contains(c),
          reason: '${c.name}: no rotation policy pinned — coverage gap',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in EncryptionKeyRotationSchedule.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
        expect(r.rotationDays, greaterThan(0), reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('TLS server cert rotation MUST be <= 90 days (ACME automation)', () {
      final r = EncryptionKeyRotationSchedule.byKeyClass(
        KeyClass.tlsServerCert,
      )!;
      expect(
        r.rotationDays,
        lessThanOrEqualTo(90),
        reason:
            'TLS rotation > 90 days defeats short-lived-cert security posture; ACME defaults to 90',
      );
    });

    test('content-encryption keys MUST require re-encryption on rotation', () {
      for (final c in [KeyClass.dataAtRest, KeyClass.backupEncryption]) {
        final r = EncryptionKeyRotationSchedule.byKeyClass(c)!;
        expect(
          r.requiresReEncryption,
          isTrue,
          reason:
              '${c.name}: rotating a content-encryption key without re-encryption leaves data under the old key — defeats rotation',
        );
      }
    });

    test('signing keys MUST retain old key for verify-only window', () {
      for (final c in [
        KeyClass.jwtSigning,
        KeyClass.auditLogHmac,
        KeyClass.partnerApiToken,
      ]) {
        final r = EncryptionKeyRotationSchedule.byKeyClass(c)!;
        expect(
          r.retainOldKeyForVerify,
          isTrue,
          reason:
              '${c.name}: dropping old signing key invalidates in-flight signatures (JWTs, audit log entries, partner tokens)',
        );
      }
    });

    test(
      'content-encryption keys MUST NOT retain old key for verify (re-encryption supersedes)',
      () {
        for (final c in [KeyClass.dataAtRest, KeyClass.backupEncryption]) {
          final r = EncryptionKeyRotationSchedule.byKeyClass(c)!;
          expect(
            r.retainOldKeyForVerify,
            isFalse,
            reason:
                '${c.name}: after re-encryption the old content key is dead weight + audit surface',
          );
        }
      },
    );

    test(
      'every record MUST cite NIST SP 800-57 OR CA/Browser Forum baseline',
      () {
        for (final r in EncryptionKeyRotationSchedule.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('NIST SP 800-57') ||
                blob.contains('CA/Browser Forum'),
            isTrue,
            reason:
                '${r.id}: needs an industry cryptoperiod anchor (NIST SP 800-57 or CA/Browser Forum BR)',
          );
        }
      },
    );

    test('data-at-rest + backup + audit-log MUST cite HIPAA', () {
      for (final c in [
        KeyClass.dataAtRest,
        KeyClass.backupEncryption,
        KeyClass.auditLogHmac,
      ]) {
        final r = EncryptionKeyRotationSchedule.byKeyClass(c)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA'),
          isTrue,
          reason:
              '${c.name}: PHI-touching key class needs a HIPAA anchor (§164.312 / §164.316 / §164.308)',
        );
      }
    });

    test('rotationDays MUST be <= 730 (no key older than 2 years)', () {
      for (final r in EncryptionKeyRotationSchedule.records) {
        expect(
          r.rotationDays,
          lessThanOrEqualTo(730),
          reason:
              '${r.id}: NIST SP 800-57 caps content encryption key cryptoperiod at <= 2 years',
        );
      }
    });

    test(
      'content-encryption keys MUST have rotationDays <= 365 (NIST §5.3.6)',
      () {
        for (final c in [KeyClass.dataAtRest, KeyClass.backupEncryption]) {
          final r = EncryptionKeyRotationSchedule.byKeyClass(c)!;
          expect(
            r.rotationDays,
            lessThanOrEqualTo(365),
            reason:
                '${c.name}: NIST recommends <= 1 year for content encryption keys',
          );
        }
      },
    );
  });

  group('requiresReEncryption / retainsOldKeyForVerify helpers', () {
    test('requiresReEncryption true ONLY for content-encryption classes', () {
      for (final c in KeyClass.values) {
        final expected =
            c == KeyClass.dataAtRest || c == KeyClass.backupEncryption;
        expect(requiresReEncryption(c), expected, reason: c.name);
      }
    });

    test('retainsOldKeyForVerify true ONLY for signing classes', () {
      for (final c in KeyClass.values) {
        final expected =
            c == KeyClass.jwtSigning ||
            c == KeyClass.auditLogHmac ||
            c == KeyClass.partnerApiToken;
        expect(retainsOldKeyForVerify(c), expected, reason: c.name);
      }
    });
  });
}
