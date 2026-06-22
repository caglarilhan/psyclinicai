import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/passkey.dart';

void main() {
  group('PasskeyCredential', () {
    PasskeyCredential sample({int signCount = 0, String? label}) =>
        PasskeyCredential(
          credentialId: 'cred-1',
          publicKey: 'pubkey-aaaa',
          signCount: signCount,
          deviceLabel: label ?? 'MacBook Touch ID',
          transports: const ['internal', 'hybrid'],
          aaguid: '00000000-0000-0000-0000-000000000001',
        );

    test('validates empty / overlong fields', () {
      expect(
        () => PasskeyCredential(
          credentialId: '',
          publicKey: 'p',
          signCount: 0,
          deviceLabel: 'd',
        ),
        throwsArgumentError,
      );
      expect(
        () => PasskeyCredential(
          credentialId: 'c',
          publicKey: '',
          signCount: 0,
          deviceLabel: 'd',
        ),
        throwsArgumentError,
      );
      expect(
        () => PasskeyCredential(
          credentialId: 'c',
          publicKey: 'p',
          signCount: -1,
          deviceLabel: 'd',
        ),
        throwsArgumentError,
      );
      expect(
        () => PasskeyCredential(
          credentialId: 'c',
          publicKey: 'p',
          signCount: 0,
          deviceLabel: 'x' * 81,
        ),
        throwsArgumentError,
      );
    });

    test('JSON round-trip preserves every field', () {
      final original = sample(
        signCount: 7,
      ).copyWith(lastUsedAt: DateTime.utc(2026, 6, 3, 12));
      final restored = PasskeyCredential.fromJson(original.toJson());
      expect(restored.credentialId, 'cred-1');
      expect(restored.signCount, 7);
      expect(restored.transports, ['internal', 'hybrid']);
      expect(restored.aaguid, '00000000-0000-0000-0000-000000000001');
      expect(restored.lastUsedAt, DateTime.utc(2026, 6, 3, 12));
      expect(restored.isActive, isTrue);
    });

    test('revoked credential round-trips and is inactive', () {
      final revoked = sample().copyWith(revokedAt: DateTime.utc(2026, 6, 3));
      final restored = PasskeyCredential.fromJson(revoked.toJson());
      expect(restored.isActive, isFalse);
    });
  });

  group('InMemoryPasskeyRepository', () {
    test('add + list + revoke flow', () async {
      final repo = InMemoryPasskeyRepository();
      await repo.add(
        'u-1',
        PasskeyCredential(
          credentialId: 'cred-1',
          publicKey: 'p',
          signCount: 0,
          deviceLabel: 'phone',
        ),
      );
      var list = await repo.listForUser('u-1');
      expect(list.length, 1);
      expect(list.first.isActive, isTrue);
      await repo.revoke('u-1', 'cred-1');
      list = await repo.listForUser('u-1');
      expect(list.first.isActive, isFalse);
    });

    test('duplicate enrolment is rejected', () async {
      final repo = InMemoryPasskeyRepository();
      final cred = PasskeyCredential(
        credentialId: 'cred-1',
        publicKey: 'p',
        signCount: 0,
        deviceLabel: 'phone',
      );
      await repo.add('u-1', cred);
      expect(() => repo.add('u-1', cred), throwsA(isA<StateError>()));
    });

    test('sign-count regression is rejected (cloning defence)', () async {
      final repo = InMemoryPasskeyRepository();
      await repo.add(
        'u-1',
        PasskeyCredential(
          credentialId: 'cred-1',
          publicKey: 'p',
          signCount: 5,
          deviceLabel: 'phone',
        ),
      );
      await repo.recordAuthentication('u-1', 'cred-1', 6);
      expect(
        () => repo.recordAuthentication('u-1', 'cred-1', 4),
        throwsA(isA<StateError>()),
      );
    });
  });
}
