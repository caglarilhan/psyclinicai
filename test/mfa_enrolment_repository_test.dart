import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/mfa_enrolment_repository.dart';
import 'package:psyclinicai/services/mfa/totp_service.dart';

void main() {
  group('MfaEnrolment', () {
    final base = MfaEnrolment(
      uid: 'uid-1',
      enrolledAt: DateTime.utc(2026, 6, 2, 10),
      recoveryCodeHashes: [
        hashRecoveryCode('AAAA-AAAA'),
        hashRecoveryCode('BBBB-BBBB'),
      ],
    );

    test('hasUnusedCodes true at enrolment', () {
      expect(base.hasUnusedCodes, isTrue);
    });

    test('JSON round-trip preserves fields', () {
      final restored = MfaEnrolment.fromJson(base.toJson());
      expect(restored.uid, base.uid);
      expect(restored.enrolledAt, base.enrolledAt);
      expect(restored.recoveryCodeHashes, base.recoveryCodeHashes);
    });

    test('markUsed adds hash + bumps lastVerifiedAt + dedupes', () {
      final h = hashRecoveryCode('AAAA-AAAA');
      final at = DateTime.utc(2026, 6, 2, 11);
      final used = base.markUsed(h, at);
      expect(used.usedRecoveryCodes, contains(h));
      expect(used.lastVerifiedAt, at);
      final twice = used.markUsed(h, at.add(const Duration(minutes: 1)));
      expect(twice.usedRecoveryCodes.length, 1);
    });

    test('hasUnusedCodes false when all consumed', () {
      var current = base;
      for (final hash in base.recoveryCodeHashes) {
        current = current.markUsed(hash, DateTime.now().toUtc());
      }
      expect(current.hasUnusedCodes, isFalse);
    });
  });

  group('InMemoryMfaEnrolmentRepository', () {
    test('consumeRecoveryCode true for unused, false for replay',
        () async {
      final repo = InMemoryMfaEnrolmentRepository();
      await repo.upsert(MfaEnrolment(
        uid: 'uid-1',
        enrolledAt: DateTime.utc(2026, 6, 2, 10),
        recoveryCodeHashes: [hashRecoveryCode('AAAA-AAAA')],
      ));
      expect(await repo.consumeRecoveryCode(
              uid: 'uid-1', rawCode: 'AAAA-AAAA'),
          isTrue);
      expect(await repo.consumeRecoveryCode(
              uid: 'uid-1', rawCode: 'AAAA-AAAA'),
          isFalse,
          reason: 'each code is single-use');
      expect(await repo.consumeRecoveryCode(
              uid: 'uid-1', rawCode: 'CCCC-CCCC'),
          isFalse,
          reason: 'unknown code');
    });

    test('consumeRecoveryCode is case-insensitive on the raw code',
        () async {
      final repo = InMemoryMfaEnrolmentRepository();
      await repo.upsert(MfaEnrolment(
        uid: 'uid-1',
        enrolledAt: DateTime.utc(2026, 6, 2, 10),
        recoveryCodeHashes: [hashRecoveryCode('AAAA-AAAA')],
      ));
      expect(
        await repo.consumeRecoveryCode(uid: 'uid-1', rawCode: 'aaaa-aaaa'),
        isTrue,
      );
    });

    test('consumeRecoveryCode without enrolment returns false', () async {
      final repo = InMemoryMfaEnrolmentRepository();
      expect(
        await repo.consumeRecoveryCode(uid: 'nope', rawCode: 'X'),
        isFalse,
      );
    });
  });
}
