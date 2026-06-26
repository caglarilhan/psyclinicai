/// O9 — Required environment variable catalog (pinned helper).
///
/// **Why this exists**: a missing env var in production is a silent
/// failure mode — the app boots, half a feature works, the rest
/// throws on first use. SOC 2 CC8.1 (change management) and ISO
/// 27001 A.12.1.2 (change-control procedures) require a documented
/// config inventory. This catalog pins every env var the platform
/// reads, classified by sensitivity (secret vs public) and by
/// which deployment slots MUST have it set. Boot-time validator +
/// CI gate both read this catalog, so a forgotten env var fails
/// fast instead of bleeding through to users.
///
/// This catalog pins per env var:
///   1. Stable name (e.g. `STRIPE_SECRET_KEY`).
///   2. Sensitivity (`secret` vs `publicConfig`).
///   3. Which deployment slots REQUIRE it (production /
///      preview / local).
///   4. Why the platform needs it (one short line).
///   5. Regulatory anchor or SOC 2 / ISO control mapping.
///
/// **Distinct from**:
///   * Future `EnvironmentInventory` catalog — describes WHICH
///     environments exist; O9 pins WHICH env vars must be present
///     in each.
///   * `SubprocessorRegistry` — names the vendors whose API keys we
///     hold; O9 pins the var names + presence requirement.
///   * `EncryptionKeyRotationSchedule` (N20) — key lifecycle; O9
///     just pins the existence + classification of the variable
///     that holds the current key handle.
///
/// **Out of scope** (separate PRs):
///   * Boot-time validator implementation.
///   * CI lint that fails the build on missing var in env file.
///   * Secret store backend selection (1Password, Doppler, KMS).
library;

/// Sensitivity classification.
enum EnvVarSensitivity {
  /// Secret — never logged, never returned in API responses, must
  /// live in secret store (KMS / 1Password / Doppler).
  secret,

  /// Public config — safe to ship in the client bundle (e.g.
  /// Firebase web config public keys).
  publicConfig,
}

/// Deployment slot.
enum DeploymentSlot {
  /// Local developer workstation.
  local,

  /// CI preview deploys for PRs.
  preview,

  /// Staging-equivalent stable deploy.
  staging,

  /// Production.
  production,
}

class RequiredEnvVarRecord {
  const RequiredEnvVarRecord({
    required this.name,
    required this.description,
    required this.sensitivity,
    required this.requiredIn,
    required this.regulatoryRefs,
  });

  /// Stable env var name (case-sensitive).
  final String name;

  /// One-line why-do-we-need-it.
  final String description;

  final EnvVarSensitivity sensitivity;

  /// Slots that MUST have the variable set. Tests pin per-var.
  final List<DeploymentSlot> requiredIn;

  final List<String> regulatoryRefs;
}

class RequiredEnvVarCatalog {
  const RequiredEnvVarCatalog._();

  /// YYYY-MM stamp — drives the ops "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned catalog. Append-only.
  static const List<RequiredEnvVarRecord> records = [
    RequiredEnvVarRecord(
      name: 'FIREBASE_PROJECT_ID',
      description:
          'Firebase project id for Auth + Firestore. Public — shipped in client bundle.',
      sensitivity: EnvVarSensitivity.publicConfig,
      requiredIn: [
        DeploymentSlot.local,
        DeploymentSlot.preview,
        DeploymentSlot.staging,
        DeploymentSlot.production,
      ],
      regulatoryRefs: [
        'SOC 2 CC8.1 change management',
        'ISO 27001 A.12.1.2 change control',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'FIREBASE_API_KEY',
      description:
          'Firebase web API key. Public per Firebase docs — security enforced via App Check + security rules.',
      sensitivity: EnvVarSensitivity.publicConfig,
      requiredIn: [
        DeploymentSlot.local,
        DeploymentSlot.preview,
        DeploymentSlot.staging,
        DeploymentSlot.production,
      ],
      regulatoryRefs: [
        'SOC 2 CC8.1 change management',
        'ISO 27001 A.12.1.2 change control',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'STRIPE_SECRET_KEY',
      description:
          'Stripe restricted-mode secret key for invoice + subscription API calls. Server-side only.',
      sensitivity: EnvVarSensitivity.secret,
      requiredIn: [DeploymentSlot.staging, DeploymentSlot.production],
      regulatoryRefs: [
        'PCI DSS v4.0 §3.7 cryptographic key management',
        'SOC 2 CC6.1 logical access',
        'ISO 27001 A.9.4.5 access control to program source code',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'STRIPE_WEBHOOK_SECRET',
      description:
          'Stripe webhook signing secret — verifies inbound webhook authenticity.',
      sensitivity: EnvVarSensitivity.secret,
      requiredIn: [DeploymentSlot.staging, DeploymentSlot.production],
      regulatoryRefs: [
        'PCI DSS v4.0 §6.5.4 broken authentication',
        'OWASP API Top-10 BFLA',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'OPENAI_API_KEY',
      description:
          'OpenAI inference key for LLM-backed clinician copilot. Server-side via LLM proxy.',
      sensitivity: EnvVarSensitivity.secret,
      requiredIn: [DeploymentSlot.staging, DeploymentSlot.production],
      regulatoryRefs: [
        'SOC 2 CC6.1 logical access',
        'EU AI Act Art. 13 transparency (provider relationship)',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'SENTRY_DSN',
      description:
          'Sentry DSN for crash + error telemetry. PHI scrub runs before send (L9).',
      sensitivity: EnvVarSensitivity.publicConfig,
      requiredIn: [DeploymentSlot.staging, DeploymentSlot.production],
      regulatoryRefs: [
        'SOC 2 CC7.2 system monitoring',
        'ISO 27001 A.12.4.1 event logging',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'JWT_SIGNING_KEY_HANDLE',
      description:
          'KMS handle for the active JWT signing key (rotated per N20, every 90 days).',
      sensitivity: EnvVarSensitivity.secret,
      requiredIn: [
        DeploymentSlot.preview,
        DeploymentSlot.staging,
        DeploymentSlot.production,
      ],
      regulatoryRefs: [
        'NIST SP 800-57 Part 1 §5.3.6 signature key cryptoperiod',
        'HIPAA §164.312(d) person/entity authentication',
        'OWASP ASVS V3.5 token lifecycle',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'AUDIT_LOG_HMAC_KEY_HANDLE',
      description:
          'KMS handle for the active audit-log HMAC chain key (rotated per N20, every 180 days).',
      sensitivity: EnvVarSensitivity.secret,
      requiredIn: [
        DeploymentSlot.preview,
        DeploymentSlot.staging,
        DeploymentSlot.production,
      ],
      regulatoryRefs: [
        'HIPAA §164.312(b) audit controls',
        'HIPAA §164.316(b)(2)(i) retention',
        'NIST SP 800-57 Part 1 §5.3.6 MAC key cryptoperiod',
      ],
    ),
    RequiredEnvVarRecord(
      name: 'BACKUP_ENCRYPTION_KEY_HANDLE',
      description:
          'KMS handle for offsite backup blob encryption key (rotated per N20, every 365 days).',
      sensitivity: EnvVarSensitivity.secret,
      requiredIn: [DeploymentSlot.staging, DeploymentSlot.production],
      regulatoryRefs: [
        'HIPAA §164.308(a)(7) contingency plan',
        'NIST SP 800-57 Part 1 §5.3.6 content encryption keys',
        'ISO 27001 A.17.1.3 continuity verify/review',
      ],
    ),
  ];

  static RequiredEnvVarRecord? byName(String name) {
    for (final r in records) {
      if (r.name == name) return r;
    }
    return null;
  }

  /// Vars REQUIRED in the given deployment slot.
  static List<RequiredEnvVarRecord> requiredInSlot(DeploymentSlot slot) {
    return records.where((r) => r.requiredIn.contains(slot)).toList();
  }
}

/// True when the var is REQUIRED in the given deployment slot.
/// Drives the boot-time validator to fail-fast if missing.
bool isRequiredIn(String name, DeploymentSlot slot) {
  final r = RequiredEnvVarCatalog.byName(name);
  if (r == null) return false;
  return r.requiredIn.contains(slot);
}
