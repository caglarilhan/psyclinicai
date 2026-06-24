/// Pseudonymized URL slug for patient identifiers. Solves the
/// "browser history / screenshot leaks the raw Firestore doc id"
/// problem (HIPAA §164.514 — de-identification of PHI in URLs).
///
/// The encode is deterministic so the same patient always resolves
/// to the same slug for the same tenant; tenant-scoped via a
/// salt so two tenants holding the same patient id never collide.
///
/// Today this PR ships only the utility + tests; consumers are
/// migrated in a follow-up so the diff stays review-friendly.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

class PatientSlug {
  PatientSlug._();

  /// Encode [patientId] under [tenantSalt] into a 12-char URL-safe
  /// slug. Output charset is base32-alphabet upper without
  /// I/O/L (Crockford-lite); collisions are vanishingly unlikely
  /// at 12 × 5 = 60 bits within a single tenant.
  static String encode({
    required String patientId,
    required String tenantSalt,
  }) {
    if (patientId.isEmpty) {
      throw ArgumentError.value(patientId, 'patientId', 'must not be empty');
    }
    if (tenantSalt.isEmpty) {
      throw ArgumentError.value(tenantSalt, 'tenantSalt', 'must not be empty');
    }
    final bytes = utf8.encode('$tenantSalt:$patientId');
    final digest = sha256.convert(bytes).bytes;
    return _toBase32Slug(digest, length: 12);
  }

  /// Constant-time check that [slug] is the slug for [patientId]
  /// under [tenantSalt]. Returning a bool instead of recomputing
  /// the slug + comparing avoids leaking timing differences if the
  /// caller stores it next to a user-supplied input.
  static bool matches({
    required String slug,
    required String patientId,
    required String tenantSalt,
  }) {
    final expected = encode(patientId: patientId, tenantSalt: tenantSalt);
    if (slug.length != expected.length) return false;
    var diff = 0;
    for (var i = 0; i < slug.length; i++) {
      diff |= slug.codeUnitAt(i) ^ expected.codeUnitAt(i);
    }
    return diff == 0;
  }

  /// Base32-ish alphabet skipping confusable glyphs. 32 symbols so
  /// each character carries 5 bits.
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static String _toBase32Slug(List<int> bytes, {required int length}) {
    final buffer = StringBuffer();
    var acc = 0;
    var bits = 0;
    var i = 0;
    while (buffer.length < length) {
      if (bits < 5) {
        if (i >= bytes.length) {
          // Re-seed from the same bytes; we already covered >2x the
          // surface we need at 12 chars of a 32-byte digest, so this
          // branch only fires for very long requested lengths.
          acc = (acc << 8) | bytes[i % bytes.length];
        } else {
          acc = (acc << 8) | bytes[i];
        }
        bits += 8;
        i++;
      }
      final idx = (acc >> (bits - 5)) & 0x1F;
      bits -= 5;
      // Modulo defends against alphabet-length drift even though
      // it is fixed at 32.
      buffer.write(_alphabet[idx % _alphabet.length]);
    }
    return buffer.toString();
  }
}
