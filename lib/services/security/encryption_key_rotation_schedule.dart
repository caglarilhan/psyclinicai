/// N20 — Encryption key rotation schedule (pinned helper).
///
/// **Why this exists**: HIPAA §164.312(a)(2)(iv) and PCI DSS v4.0
/// §3.7 both require documented key management with bounded
/// cryptoperiods. NIST SP 800-57 Part 1 §5.3.6 spells out the
/// recommended cryptoperiod per key type. An auditor will ask:
/// "How often do you rotate your data-at-rest keys? Your TLS
/// certs? Your JWT signing keys? Where is the policy?" — this
/// catalog IS that policy.
///
/// This catalog pins per key class:
///   1. Key class (dataAtRest / tlsServerCert / jwtSigning / etc.).
///   2. Rotation cadence in days.
///   3. Whether re-encryption of historical data is required on
///      rotation (true for content-encryption keys, false for
///      ephemeral signing keys).
///   4. Whether the old key must be retained for verify-only use
///      after rotation (true for audit-trail signing keys).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `SubprocessorRegistry` — names vendors holding keys; N20 is
///     the lifecycle policy for keys regardless of vendor.
///   * `VendorRiskTierCatalog` (N19) — gates vendor onboarding by
///     diligence artifact; N20 governs key lifecycle independent
///     of vendor.
///   * `local_db_encryption_test.dart` — verifies SQLCipher key
///     wraps the on-device DB; N20 documents WHEN that key rolls.
///
/// **Out of scope** (separate PRs):
///   * Actual rotation job runner.
///   * KMS HSM integration.
///   * Customer-managed-key (CMK / BYOK) onboarding flow.
library;

/// Key classes the platform manages.
enum KeyClass {
  /// AES-256 wrapping the patient database at rest (SQLCipher on
  /// device, server-side envelope key in KMS).
  dataAtRest,

  /// TLS server certificate (Let's Encrypt or commercial CA).
  tlsServerCert,

  /// JWT signing key for clinician auth sessions.
  jwtSigning,

  /// HMAC key for audit-log tamper-evident chain.
  auditLogHmac,

  /// Backup encryption key — wraps offsite backup blobs.
  backupEncryption,

  /// API token signing key for partner integrations.
  partnerApiToken,
}

/// One pinned key rotation policy.
class KeyRotationRecord {
  const KeyRotationRecord({
    required this.id,
    required this.keyClass,
    required this.description,
    required this.rotationDays,
    required this.requiresReEncryption,
    required this.retainOldKeyForVerify,
    required this.regulatoryRefs,
  });

  final String id;
  final KeyClass keyClass;
  final String description;

  /// Days between scheduled rotations. NIST SP 800-57 cryptoperiod.
  final int rotationDays;

  /// True when rotation must re-encrypt historical ciphertext under
  /// the new key (data-at-rest, backups). False for ephemeral
  /// signing keys whose old material can be discarded.
  final bool requiresReEncryption;

  /// True when the OLD key must be retained read-only after
  /// rotation so already-signed artifacts (audit log entries, JWTs
  /// in flight) can still be verified.
  final bool retainOldKeyForVerify;

  final List<String> regulatoryRefs;
}

class EncryptionKeyRotationSchedule {
  const EncryptionKeyRotationSchedule._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned schedule. Append-only.
  static const List<KeyRotationRecord> records = [
    KeyRotationRecord(
      id: 'data-at-rest-key',
      keyClass: KeyClass.dataAtRest,
      description:
          'AES-256 envelope key wrapping the patient database at rest. SQLCipher key on device + KMS envelope key server-side.',
      rotationDays: 365,
      requiresReEncryption: true,
      retainOldKeyForVerify: false,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 (1-2 yr cryptoperiod for content encryption keys)',
        'HIPAA §164.312(a)(2)(iv) encryption + decryption',
        'PCI DSS v4.0 §3.7 cryptographic key management',
      ],
    ),
    KeyRotationRecord(
      id: 'tls-server-cert',
      keyClass: KeyClass.tlsServerCert,
      description:
          'TLS server certificate — public-facing endpoints (web + Cloud Functions). Rotated automatically via ACME.',
      rotationDays: 90,
      requiresReEncryption: false,
      retainOldKeyForVerify: false,
      regulatoryRefs: [
        'CA/Browser Forum Baseline Requirements §6.3.2 (398-day max)',
        'NIST SP 800-52 Rev. 2 TLS recommendations',
        'PCI DSS v4.0 §4.2.1 strong cryptography over open networks',
      ],
    ),
    KeyRotationRecord(
      id: 'jwt-signing-key',
      keyClass: KeyClass.jwtSigning,
      description:
          'Asymmetric signing key (Ed25519) for clinician session JWTs. Retain old key for verify-only window equal to max JWT TTL.',
      rotationDays: 90,
      requiresReEncryption: false,
      retainOldKeyForVerify: true,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 signature private key cryptoperiod',
        'OWASP ASVS V3.5 token lifecycle',
        'HIPAA §164.312(d) person/entity authentication',
      ],
    ),
    KeyRotationRecord(
      id: 'audit-log-hmac',
      keyClass: KeyClass.auditLogHmac,
      description:
          'HMAC-SHA256 key for tamper-evident audit log chain. Old keys retained 7 years for verification of historical entries (HIPAA §164.316(b)(2)(i)).',
      rotationDays: 180,
      requiresReEncryption: false,
      retainOldKeyForVerify: true,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 MAC key cryptoperiod',
        'HIPAA §164.312(b) audit controls',
        'HIPAA §164.316(b)(2)(i) 6-year retention',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
    KeyRotationRecord(
      id: 'backup-encryption-key',
      keyClass: KeyClass.backupEncryption,
      description:
          'AES-256-GCM key wrapping nightly backup blobs in offsite cold storage. Re-encryption gated by backup retention window.',
      rotationDays: 365,
      requiresReEncryption: true,
      retainOldKeyForVerify: false,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 content encryption keys',
        'HIPAA §164.308(a)(7) contingency plan',
        'ISO 27001 A.17.1.3 verify, review and evaluate continuity',
      ],
    ),
    KeyRotationRecord(
      id: 'partner-api-token-key',
      keyClass: KeyClass.partnerApiToken,
      description:
          'HMAC key signing partner API tokens (Stripe webhook verify, EHR connector). Old key retained one cadence for in-flight requests.',
      rotationDays: 180,
      requiresReEncryption: false,
      retainOldKeyForVerify: true,
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 MAC key cryptoperiod',
        'OWASP ASVS V3.5 token lifecycle',
        'PCI DSS v4.0 §3.7 cryptographic key management',
      ],
    ),
  ];

  static KeyRotationRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static KeyRotationRecord? byKeyClass(KeyClass c) {
    for (final r in records) {
      if (r.keyClass == c) return r;
    }
    return null;
  }
}

/// True when rotating the key requires re-encryption of historical
/// ciphertext under the new key. Drives the rotation job runner to
/// schedule a backfill window.
bool requiresReEncryption(KeyClass c) {
  final r = EncryptionKeyRotationSchedule.byKeyClass(c);
  return r?.requiresReEncryption ?? false;
}

/// True when the old key must be kept around in verify-only mode
/// after rotation (signing keys with in-flight artifacts).
bool retainsOldKeyForVerify(KeyClass c) {
  final r = EncryptionKeyRotationSchedule.byKeyClass(c);
  return r?.retainOldKeyForVerify ?? false;
}
