/// N10 — Org-wide secret rotation calendar (pinned helper).
///
/// **Why this exists**: today only the customer-facing BYOK key is
/// rotated by `byok_rotation_service.dart`. The org carries a much
/// larger set of secrets (KMS master keys, vendor API keys, OAuth
/// client secrets, service-account JSON, signing keys, webhook
/// shared secrets) each with its own regulator-mandated cadence:
///   * PCI DSS v4.0 §3.7 — quarterly rotation for cardholder-data
///     keys + when staff with access change.
///   * NIST SP 800-57 §5.3.6 — annual rotation for digital signature
///     keys.
///   * SOC 2 CC6.1 — documented rotation cadence for every secret.
///   * HIPAA §164.308(a)(5)(ii)(D) — password management → extended
///     by current guidance to all credentials.
///
/// Pinning the calendar here means:
///   1. A new secret class cannot ship without a row + tests fail.
///   2. The Cloud Function reminder cron picks the right cadence
///      per class (today every secret would use one hard-coded
///      90-day window).
///   3. Trust-center renders the same numbers the procurement
///      questionnaire references.
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that emits 30-day-before reminders.
///   * Rotation runbook per class (KMS, OAuth, etc.).
///   * Wire byok_rotation_service to read its window from here.
library;

/// What kind of secret it is. Drives the regulator-mandated cadence.
enum SecretClass {
  /// KMS master / wrapping keys (cloud KMS or hardware HSM).
  kmsMasterKey,

  /// Long-lived vendor API keys (Anthropic, OpenAI, Stripe API keys).
  vendorApiKey,

  /// OAuth client secret for our identity providers.
  oauthClientSecret,

  /// GCP service-account JSON used by Cloud Functions.
  serviceAccountJson,

  /// Asymmetric signing key (JWT, webhook signatures).
  signingKey,

  /// Webhook shared secret (Stripe webhook, Slack webhook).
  webhookSharedSecret,

  /// Customer-supplied BYOK LLM key.
  byokCustomerKey,
}

/// Where the secret physically lives.
enum SecretStorage {
  /// Cloud KMS (managed key store, e.g. GCP KMS, AWS KMS).
  cloudKms,

  /// Vendor's own dashboard (Stripe / Anthropic UI generates the key).
  vendorDashboard,

  /// Firebase Functions secret manager (`firebase functions:secrets:set`).
  functionsSecrets,

  /// Per-tenant secret stored encrypted on-device (BYOK).
  onDeviceSqlcipher,
}

/// One pinned rotation policy.
class SecretRotationRecord {
  const SecretRotationRecord({
    required this.id,
    required this.secretClass,
    required this.label,
    required this.rotationDays,
    required this.reminderDays,
    required this.owner,
    required this.storage,
    required this.regulatoryRefs,
  });

  /// Stable id (`kms-master-eu`, `stripe-api-key`, etc.).
  final String id;

  final SecretClass secretClass;

  /// Human-readable label for the trust page + reminder email
  /// subject. Never includes the secret itself.
  final String label;

  /// Days between rotations.
  final int rotationDays;

  /// How many days before the deadline the reminder fires.
  /// MUST be < rotationDays.
  final int reminderDays;

  /// Single accountable role.
  final String owner;

  final SecretStorage storage;

  /// Citations the cadence is grounded in.
  final List<String> regulatoryRefs;
}

class SecretRotationCalendar {
  const SecretRotationCalendar._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policy per secret. Append-only — deprecated rows stay
  /// so historic rotation logs still resolve.
  static const List<SecretRotationRecord> records = [
    SecretRotationRecord(
      id: 'kms-master-eu',
      secretClass: SecretClass.kmsMasterKey,
      label: 'GCP KMS master key — psyclinicai EU',
      rotationDays: 365,
      reminderDays: 30,
      owner: 'ciso',
      storage: SecretStorage.cloudKms,
      regulatoryRefs: [
        'NIST SP 800-57 §5.3.6 cryptographic key management',
        'SOC 2 CC6.1 logical access',
      ],
    ),
    SecretRotationRecord(
      id: 'stripe-api-key',
      secretClass: SecretClass.vendorApiKey,
      label: 'Stripe restricted API key',
      rotationDays: 90,
      reminderDays: 14,
      owner: 'cfo',
      storage: SecretStorage.vendorDashboard,
      regulatoryRefs: [
        'PCI DSS v4.0 §3.7 cryptographic key rotation',
        'SOC 2 CC6.1',
      ],
    ),
    SecretRotationRecord(
      id: 'stripe-webhook-secret',
      secretClass: SecretClass.webhookSharedSecret,
      label: 'Stripe webhook signing secret',
      rotationDays: 90,
      reminderDays: 14,
      owner: 'cto',
      storage: SecretStorage.functionsSecrets,
      regulatoryRefs: ['PCI DSS v4.0 §3.7', 'SOC 2 CC7.1 system operations'],
    ),
    SecretRotationRecord(
      id: 'anthropic-api-key',
      secretClass: SecretClass.vendorApiKey,
      label: 'Anthropic API key (LLM relay)',
      rotationDays: 90,
      reminderDays: 14,
      owner: 'cto',
      storage: SecretStorage.functionsSecrets,
      regulatoryRefs: [
        'SOC 2 CC6.1',
        'HIPAA §164.308(a)(5)(ii)(D) credential management',
      ],
    ),
    SecretRotationRecord(
      id: 'openai-api-key',
      secretClass: SecretClass.vendorApiKey,
      label: 'OpenAI API key (fallback LLM)',
      rotationDays: 90,
      reminderDays: 14,
      owner: 'cto',
      storage: SecretStorage.functionsSecrets,
      regulatoryRefs: ['SOC 2 CC6.1'],
    ),
    SecretRotationRecord(
      id: 'jwt-signing-key',
      secretClass: SecretClass.signingKey,
      label: 'JWT signing key (HS256 / RS256)',
      rotationDays: 365,
      reminderDays: 45,
      owner: 'ciso',
      storage: SecretStorage.cloudKms,
      regulatoryRefs: [
        'NIST SP 800-57 §5.3.6 signing key lifetime',
        'OWASP ASVS 6.4.1',
      ],
    ),
    SecretRotationRecord(
      id: 'firebase-functions-service-account',
      secretClass: SecretClass.serviceAccountJson,
      label: 'Firebase Functions service-account JSON',
      rotationDays: 180,
      reminderDays: 30,
      owner: 'ciso',
      storage: SecretStorage.cloudKms,
      regulatoryRefs: [
        'SOC 2 CC6.3 manage logical access',
        'NIST SP 800-53 IA-5 authenticator management',
      ],
    ),
    SecretRotationRecord(
      id: 'sentry-dsn',
      secretClass: SecretClass.vendorApiKey,
      label: 'Sentry DSN (telemetry ingest)',
      rotationDays: 365,
      reminderDays: 30,
      owner: 'cto',
      storage: SecretStorage.functionsSecrets,
      regulatoryRefs: ['SOC 2 CC6.1'],
    ),
    SecretRotationRecord(
      id: 'byok-customer-llm-key',
      secretClass: SecretClass.byokCustomerKey,
      label: 'Customer-supplied LLM key (BYOK)',
      rotationDays: 90,
      reminderDays: 14,
      owner: 'tenant_admin',
      storage: SecretStorage.onDeviceSqlcipher,
      regulatoryRefs: [
        'HIPAA §164.308(a)(5)(ii)(D)',
        'Tenant DPA — customer-controlled key',
      ],
    ),
  ];

  static SecretRotationRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// Days remaining until rotation is due from [today] given a
/// [lastRotatedIso] date in `YYYY-MM-DD`. Negative when overdue.
/// Tests pin behaviour at +days, exact-day, and overdue.
int daysUntilRotation({
  required SecretRotationRecord record,
  required String lastRotatedIso,
  required DateTime today,
}) {
  final last = DateTime.parse(lastRotatedIso);
  final due = last.add(Duration(days: record.rotationDays));
  return due.difference(today).inDays;
}

/// True when [today] is inside the reminder window for the secret
/// (lastRotated + (rotationDays - reminderDays) ≤ today < lastRotated
/// + rotationDays). Drives the reminder cron's "fire today" decision.
bool isInReminderWindow({
  required SecretRotationRecord record,
  required String lastRotatedIso,
  required DateTime today,
}) {
  final left = daysUntilRotation(
    record: record,
    lastRotatedIso: lastRotatedIso,
    today: today,
  );
  return left >= 0 && left <= record.reminderDays;
}
