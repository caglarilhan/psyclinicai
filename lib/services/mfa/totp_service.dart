import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Pure-Dart RFC 6238 TOTP + recovery codes for the MFA setup hub
/// (`/settings/mfa`). No external runtime dependency — keeps the
/// secret on-device and lets us unit-test the math against the
/// published RFC test vectors.
///
/// HIPAA §164.312(d) (person or entity authentication) requires a
/// second factor on accounts that touch ePHI; this helper is the
/// authoritative implementation behind the enrolment wizard, the
/// recovery-code generator, and the verify step.
class TotpService {
  TotpService({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// (secret-hash, counter) tuples that have already been consumed —
  /// guards against replay within the skew window. Keyed by a SHA-1
  /// digest of the secret so we never hold the raw secret here.
  final Set<String> _consumedCounters = <String>{};

  static const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const int defaultDigits = 6;
  static const int defaultPeriodSeconds = 30;
  static const int defaultSkew = 1;

  /// Generates a 160-bit base32 secret (20 bytes). Matches what
  /// Google Authenticator, 1Password and Authy expect when scanning a
  /// `otpauth://` QR code.
  String generateSecret() {
    final bytes = Uint8List(20);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return _toBase32(bytes);
  }

  /// Builds the standard provisioning URI consumed by authenticator
  /// apps. `label` should be the clinician email; `issuer` is the
  /// brand string shown in the app.
  String provisioningUri({
    required String label,
    required String secret,
    String issuer = 'PsyClinicAI',
    int digits = defaultDigits,
    int period = defaultPeriodSeconds,
  }) {
    final encodedLabel = Uri.encodeComponent('$issuer:$label');
    final query = <String, String>{
      'secret': secret,
      'issuer': issuer,
      'algorithm': 'SHA1',
      'digits': '$digits',
      'period': '$period',
    };
    final qs = query.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return 'otpauth://totp/$encodedLabel?$qs';
  }

  /// Returns the TOTP code for [secret] at [forTime] (defaults to
  /// now). Public so widgets can render a live ticking preview.
  String currentCode(
    String secret, {
    DateTime? forTime,
    int digits = defaultDigits,
    int period = defaultPeriodSeconds,
  }) {
    final ts = forTime ?? DateTime.now().toUtc();
    final counter = ts.millisecondsSinceEpoch ~/ 1000 ~/ period;
    return _codeForCounter(secret, counter, digits: digits);
  }

  /// Verifies a user-entered [code]. Accepts the current 30 s window
  /// plus [skew] windows on each side to forgive clock drift.
  bool verify({
    required String secret,
    required String code,
    DateTime? at,
    int digits = defaultDigits,
    int period = defaultPeriodSeconds,
    int skew = defaultSkew,
    bool consume = true,
  }) {
    final cleaned = code.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length != digits) return false;
    final ts = at ?? DateTime.now().toUtc();
    final current = ts.millisecondsSinceEpoch ~/ 1000 ~/ period;
    final secretFingerprint = sha1.convert(utf8.encode(secret)).toString();
    for (var offset = -skew; offset <= skew; offset++) {
      final counter = current + offset;
      final key = '$secretFingerprint:$counter';
      // RFC 6238 §5.2: a verifier must reject the same counter twice.
      if (_consumedCounters.contains(key)) continue;
      final candidate = _codeForCounter(secret, counter, digits: digits);
      if (_constantTimeEquals(candidate, cleaned)) {
        if (consume) _consumedCounters.add(key);
        return true;
      }
    }
    return false;
  }

  /// Test/storybook seam.
  @visibleForTesting
  void clearConsumedCounters() => _consumedCounters.clear();

  /// Ten single-use codes formatted as `XXXX-XXXX` so they look like
  /// password-manager fixtures, not lottery numbers.
  List<String> generateRecoveryCodes({int count = 10}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final codes = <String>[];
    for (var i = 0; i < count; i++) {
      String chunk(int n) =>
          List.generate(n, (_) => chars[_random.nextInt(chars.length)]).join();
      codes.add('${chunk(4)}-${chunk(4)}');
    }
    return codes;
  }

  String _codeForCounter(String secret, int counter, {required int digits}) {
    final key = _fromBase32(secret);
    final counterBytes = ByteData(8)..setUint64(0, counter);
    final hmac = Hmac(sha1, key).convert(counterBytes.buffer.asUint8List());
    final bytes = hmac.bytes;
    final offset = bytes[bytes.length - 1] & 0x0f;
    final binary =
        ((bytes[offset] & 0x7f) << 24) |
        ((bytes[offset + 1] & 0xff) << 16) |
        ((bytes[offset + 2] & 0xff) << 8) |
        (bytes[offset + 3] & 0xff);
    final modulo = pow(10, digits).toInt();
    return (binary % modulo).toString().padLeft(digits, '0');
  }

  String _toBase32(Uint8List bytes) {
    final buffer = StringBuffer();
    var bits = 0;
    var value = 0;
    for (final byte in bytes) {
      value = (value << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        buffer.write(_base32Alphabet[(value >> bits) & 0x1f]);
      }
    }
    if (bits > 0) {
      buffer.write(_base32Alphabet[(value << (5 - bits)) & 0x1f]);
    }
    return buffer.toString();
  }

  Uint8List _fromBase32(String input) {
    final clean = input.replaceAll(RegExp(r'[\s=]+'), '').toUpperCase();
    final output = <int>[];
    var bits = 0;
    var value = 0;
    for (final ch in clean.codeUnits) {
      final idx = _base32Alphabet.indexOf(String.fromCharCode(ch));
      if (idx < 0) {
        throw FormatException(
          'Invalid base32 character: ${String.fromCharCode(ch)}',
        );
      }
      value = (value << 5) | idx;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        output.add((value >> bits) & 0xff);
      }
    }
    return Uint8List.fromList(output);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// SHA-256 fingerprint of a recovery code used when persisting to
/// Firestore — we never store the raw code (HIPAA §164.312(a)(2)(iv)).
String hashRecoveryCode(String code) {
  final bytes = utf8.encode(code.replaceAll('-', '').toUpperCase());
  return sha256.convert(bytes).toString();
}
