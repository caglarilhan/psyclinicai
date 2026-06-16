import 'dart:async';

import 'package:flutter/foundation.dart';

import '../mfa/totp_service.dart';

/// Per-UID MFA enrolment record. Lives in Firestore at
/// `mfa_enrolments/{uid}`. The TOTP secret stays on-device in the
/// authenticator app — only the recovery-code hashes are persisted
/// so we can verify lost-device unlock without seeing the raw codes
/// (HIPAA §164.312(a)(2)(iv)).
class MfaEnrolment {
  const MfaEnrolment({
    required this.uid,
    required this.enrolledAt,
    required this.recoveryCodeHashes,
    this.usedRecoveryCodes = const [],
    this.lastVerifiedAt,
  });

  final String uid;
  final DateTime enrolledAt;
  final List<String> recoveryCodeHashes;
  final List<String> usedRecoveryCodes;
  final DateTime? lastVerifiedAt;

  bool get hasUnusedCodes =>
      recoveryCodeHashes.length > usedRecoveryCodes.length;

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'enrolled_at': enrolledAt.toUtc().toIso8601String(),
    'recovery_code_hashes': recoveryCodeHashes,
    'used_recovery_codes': usedRecoveryCodes,
    if (lastVerifiedAt != null)
      'last_verified_at': lastVerifiedAt!.toUtc().toIso8601String(),
  };

  factory MfaEnrolment.fromJson(Map<String, dynamic> json) {
    return MfaEnrolment(
      uid: json['uid'] as String,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      recoveryCodeHashes:
          (json['recovery_code_hashes'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      usedRecoveryCodes:
          (json['used_recovery_codes'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lastVerifiedAt: json['last_verified_at'] != null
          ? DateTime.parse(json['last_verified_at'] as String)
          : null,
    );
  }

  MfaEnrolment markUsed(String hash, DateTime at) => MfaEnrolment(
    uid: uid,
    enrolledAt: enrolledAt,
    recoveryCodeHashes: recoveryCodeHashes,
    usedRecoveryCodes: [
      ...usedRecoveryCodes,
      if (!usedRecoveryCodes.contains(hash)) hash,
    ],
    lastVerifiedAt: at,
  );
}

abstract class MfaEnrolmentRepository {
  Future<MfaEnrolment?> read(String uid);
  Future<void> upsert(MfaEnrolment record);

  /// Returns true if [rawCode] matched an unused hash. False on
  /// already-used, unknown, or no enrolment.
  Future<bool> consumeRecoveryCode({
    required String uid,
    required String rawCode,
    DateTime? at,
  });
}

class InMemoryMfaEnrolmentRepository implements MfaEnrolmentRepository {
  final Map<String, MfaEnrolment> _store = {};

  @override
  Future<MfaEnrolment?> read(String uid) async => _store[uid];

  @override
  Future<void> upsert(MfaEnrolment record) async {
    _store[record.uid] = record;
  }

  @override
  Future<bool> consumeRecoveryCode({
    required String uid,
    required String rawCode,
    DateTime? at,
  }) async {
    final current = _store[uid];
    if (current == null) return false;
    final hash = hashRecoveryCode(rawCode);
    final isKnown = current.recoveryCodeHashes.contains(hash);
    final isUsed = current.usedRecoveryCodes.contains(hash);
    if (!isKnown || isUsed) return false;
    _store[uid] = current.markUsed(hash, at ?? DateTime.now().toUtc());
    return true;
  }

  @visibleForTesting
  void clear() => _store.clear();
}
