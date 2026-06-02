import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/mfa/totp_service.dart';

void main() {
  group('TotpService', () {
    final svc = TotpService(random: Random(42));

    test('generated secret is 32 base32 chars (160 bits)', () {
      final secret = svc.generateSecret();
      expect(secret.length, 32);
      expect(RegExp(r'^[A-Z2-7]+$').hasMatch(secret), isTrue);
    });

    test('round-trip: generated code verifies at the same instant', () {
      final secret = svc.generateSecret();
      final at = DateTime.utc(2026, 6, 2, 12, 0, 0);
      final code = svc.currentCode(secret, forTime: at);
      expect(svc.verify(secret: secret, code: code, at: at), isTrue);
    });

    test('verify accepts code from previous window (clock skew)', () {
      final secret = svc.generateSecret();
      final at = DateTime.utc(2026, 6, 2, 12, 0, 0);
      final previous = at.subtract(const Duration(seconds: 30));
      final prevCode = svc.currentCode(secret, forTime: previous);
      expect(svc.verify(secret: secret, code: prevCode, at: at), isTrue);
    });

    test('verify rejects a code from 5 minutes ago (outside skew)', () {
      final secret = svc.generateSecret();
      final at = DateTime.utc(2026, 6, 2, 12, 0, 0);
      final old = at.subtract(const Duration(minutes: 5));
      final oldCode = svc.currentCode(secret, forTime: old);
      expect(svc.verify(secret: secret, code: oldCode, at: at), isFalse);
    });

    test('verify rejects bad length input', () {
      final secret = svc.generateSecret();
      expect(svc.verify(secret: secret, code: '12345'), isFalse);
      expect(svc.verify(secret: secret, code: '1234567'), isFalse);
    });

    test('verify refuses replay of the same code (RFC 6238 §5.2)', () {
      final secret = svc.generateSecret();
      final at = DateTime.utc(2026, 6, 2, 12, 0, 0);
      final code = svc.currentCode(secret, forTime: at);
      expect(svc.verify(secret: secret, code: code, at: at), isTrue);
      expect(svc.verify(secret: secret, code: code, at: at), isFalse,
          reason: 'second use must be rejected');
    });

    test('consume:false allows repeated verifies for tests/preview', () {
      final secret = svc.generateSecret();
      final at = DateTime.utc(2026, 6, 2, 12, 0, 0);
      final code = svc.currentCode(secret, forTime: at);
      expect(
        svc.verify(secret: secret, code: code, at: at, consume: false),
        isTrue,
      );
      expect(
        svc.verify(secret: secret, code: code, at: at, consume: false),
        isTrue,
      );
    });

    test('provisioning URI follows otpauth spec with PsyClinicAI issuer', () {
      final uri = svc.provisioningUri(
        label: 'demo@psyclinicai.com',
        secret: 'JBSWY3DPEHPK3PXP',
      );
      expect(uri, startsWith('otpauth://totp/'));
      expect(uri, contains('issuer=PsyClinicAI'));
      expect(uri, contains('secret=JBSWY3DPEHPK3PXP'));
      expect(uri, contains('digits=6'));
      expect(uri, contains('period=30'));
    });

    test('recovery codes are XXXX-XXXX and unique within a batch', () {
      final codes = svc.generateRecoveryCodes(count: 10);
      expect(codes.length, 10);
      for (final c in codes) {
        expect(RegExp(r'^[A-Z2-9]{4}-[A-Z2-9]{4}$').hasMatch(c), isTrue,
            reason: 'unexpected format: $c');
      }
      expect(codes.toSet().length, 10, reason: 'recovery codes collided');
    });

    test('recovery code hash is deterministic + case-insensitive', () {
      const code = 'ABCD-EFGH';
      final a = hashRecoveryCode(code);
      final b = hashRecoveryCode('abcd-efgh');
      final c = hashRecoveryCode('ABCDEFGH');
      expect(a, b);
      expect(a, c);
      expect(a.length, 64);
    });
  });
}
