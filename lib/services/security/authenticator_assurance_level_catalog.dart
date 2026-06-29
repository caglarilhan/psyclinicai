/// N23 — Authenticator Assurance Level policy catalog (pinned).
///
/// **Why this exists**: NIST SP 800-63B defines three Authenticator
/// Assurance Levels (AAL1 / AAL2 / AAL3). HIPAA §164.312(d) requires
/// person/entity authentication; SOC 2 CC6.1 requires logical access
/// controls; ISO 27001 A.9.4.2 requires secure log-on. The right
/// AAL depends on the user role + data sensitivity — a patient using
/// the intake form is not at the same risk class as a platform-admin
/// reading cross-tenant logs. Picking too low forfeits the access-
/// control story; picking too high burns users. This catalog pins
/// the AAL floor per role so the MFA enrolment gate has a single
/// source of truth.
///
/// This catalog pins per role:
///   1. Role id + display name.
///   2. Minimum AAL required.
///   3. Acceptable second-factor classes (totp / webauthn /
///      hardwareToken / push).
///   4. Whether re-authentication is required for sensitive actions.
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `TotpService` — implements one factor (TOTP). N23 says which
///     roles can rely on TOTP and which need stronger (hardware key).
///   * `MfaEnrolmentRepository` — persists enrolment state. N23 is
///     the upstream policy.
///   * `VendorRiskTierCatalog` (N19) — vendor diligence; N23 is end-
///     user authentication assurance.
///
/// **Out of scope** (separate PRs):
///   * AAL enforcement middleware.
///   * Per-tenant AAL override (enterprise SKU).
///   * Re-authentication timing tuner.
library;

/// User roles in the platform. Pinned per-role AAL row required.
enum UserRole {
  /// Patient using the platform (intake form, secure messaging).
  patient,

  /// Licensed clinician providing care.
  clinician,

  /// Clinic admin (manages clinicians, billing, schedule).
  clinicAdmin,

  /// Internal operator with cross-tenant readonly access (O8
  /// platform-admin-readonly).
  platformAdmin,

  /// Read-only auditor (regulator inspection, internal compliance).
  auditor,
}

/// NIST SP 800-63B Authenticator Assurance Levels.
enum AssuranceLevel {
  /// AAL1 — some assurance. Single-factor (memorized secret or
  /// software OTP) is acceptable.
  aal1,

  /// AAL2 — high assurance. Two-factor REQUIRED; one of which is a
  /// physical authenticator (TOTP app, push, WebAuthn).
  aal2,

  /// AAL3 — very high assurance. Hardware authenticator REQUIRED
  /// (FIDO2/WebAuthn security key or TPM). Phishing-resistant.
  aal3,
}

/// Second-factor classes accepted at AAL2+.
enum SecondFactorClass {
  /// Time-based one-time password (RFC 6238). AAL2 acceptable.
  totp,

  /// Push notification to enrolled mobile app. AAL2 acceptable.
  push,

  /// WebAuthn / FIDO2 platform authenticator (Touch ID, Windows
  /// Hello). AAL2 acceptable; phishing-resistant.
  webauthnPlatform,

  /// FIDO2 hardware security key (YubiKey, Titan, etc.). AAL3
  /// acceptable; phishing-resistant.
  hardwareKey,
}

class AalPolicyRecord {
  const AalPolicyRecord({
    required this.id,
    required this.role,
    required this.description,
    required this.minimumAal,
    required this.acceptableSecondFactors,
    required this.requireReauthForSensitiveActions,
    required this.regulatoryRefs,
  });

  final String id;
  final UserRole role;
  final String description;
  final AssuranceLevel minimumAal;
  final List<SecondFactorClass> acceptableSecondFactors;

  /// True when the role MUST re-authenticate before performing a
  /// sensitive action (export PHI, change billing, change admin
  /// access).
  final bool requireReauthForSensitiveActions;

  final List<String> regulatoryRefs;
}

class AuthenticatorAssuranceLevelCatalog {
  const AuthenticatorAssuranceLevelCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policy table. Append-only.
  static const List<AalPolicyRecord> records = [
    AalPolicyRecord(
      id: 'patient',
      role: UserRole.patient,
      description:
          'Patient using the platform (intake form, secure messaging). Lowest privilege — touches own data only.',
      minimumAal: AssuranceLevel.aal1,
      acceptableSecondFactors: [],
      requireReauthForSensitiveActions: false,
      regulatoryRefs: [
        'NIST SP 800-63B AAL1 single-factor',
        'HIPAA §164.312(d) person/entity authentication',
      ],
    ),
    AalPolicyRecord(
      id: 'clinician',
      role: UserRole.clinician,
      description:
          'Licensed clinician providing care. Reads + writes PHI for tenant patients.',
      minimumAal: AssuranceLevel.aal2,
      acceptableSecondFactors: [
        SecondFactorClass.totp,
        SecondFactorClass.push,
        SecondFactorClass.webauthnPlatform,
        SecondFactorClass.hardwareKey,
      ],
      requireReauthForSensitiveActions: true,
      regulatoryRefs: [
        'NIST SP 800-63B AAL2 multi-factor',
        'HIPAA §164.312(d) person/entity authentication',
        'HIPAA §164.308(a)(5)(ii)(D) password management',
        'ISO 27001 A.9.4.2 secure log-on procedures',
        'SOC 2 CC6.1 logical access',
      ],
    ),
    AalPolicyRecord(
      id: 'clinic-admin',
      role: UserRole.clinicAdmin,
      description:
          'Clinic admin (manages clinicians, billing, schedule). Higher-privilege org-level access.',
      minimumAal: AssuranceLevel.aal2,
      acceptableSecondFactors: [
        SecondFactorClass.totp,
        SecondFactorClass.webauthnPlatform,
        SecondFactorClass.hardwareKey,
      ],
      requireReauthForSensitiveActions: true,
      regulatoryRefs: [
        'NIST SP 800-63B AAL2 multi-factor',
        'HIPAA §164.308(a)(4) information access management',
        'ISO 27001 A.9.2.3 management of privileged access',
        'SOC 2 CC6.3 access change management',
      ],
    ),
    AalPolicyRecord(
      id: 'platform-admin',
      role: UserRole.platformAdmin,
      description:
          'Internal operator with cross-tenant read-only access (per O8 platform-admin-readonly domain). Highest privilege; AAL3 mandatory.',
      minimumAal: AssuranceLevel.aal3,
      acceptableSecondFactors: [SecondFactorClass.hardwareKey],
      requireReauthForSensitiveActions: true,
      regulatoryRefs: [
        'NIST SP 800-63B AAL3 hardware-backed phishing-resistant',
        'HIPAA §164.308(a)(4) information access management',
        'ISO 27001 A.9.2.3 management of privileged access',
        'SOC 2 CC6.1 + CC6.3',
        'FIDO Alliance FIDO2 specification',
      ],
    ),
    AalPolicyRecord(
      id: 'auditor',
      role: UserRole.auditor,
      description:
          'Regulator inspection / internal compliance auditor — read-only audit-log access. AAL3 phishing-resistant.',
      minimumAal: AssuranceLevel.aal3,
      acceptableSecondFactors: [SecondFactorClass.hardwareKey],
      requireReauthForSensitiveActions: false,
      regulatoryRefs: [
        'NIST SP 800-63B AAL3 hardware-backed phishing-resistant',
        'HIPAA §164.312(b) audit controls',
        'SOC 2 CC4.1 monitoring of controls',
      ],
    ),
  ];

  static AalPolicyRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static AalPolicyRecord? byRole(UserRole r) {
    for (final rec in records) {
      if (rec.role == r) return rec;
    }
    return null;
  }
}

/// AAL ordinal for monotonic comparisons. AAL3 > AAL2 > AAL1.
int _aalOrdinal(AssuranceLevel a) {
  switch (a) {
    case AssuranceLevel.aal1:
      return 1;
    case AssuranceLevel.aal2:
      return 2;
    case AssuranceLevel.aal3:
      return 3;
  }
}

/// True when [a] is at least as strong as [b].
bool aalAtLeast(AssuranceLevel a, AssuranceLevel b) {
  return _aalOrdinal(a) >= _aalOrdinal(b);
}
