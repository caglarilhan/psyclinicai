/// O8 — Tenant isolation policy catalog (pinned helper).
///
/// **Why this exists**: `TenantContext` resolves WHICH tenant is
/// active. But the question "what does isolation mean per data
/// domain?" is policy, not implementation. Cross-tenant data leaks
/// are the #1 SaaS breach class (OWASP API Top-10 BOLA, HIPAA
/// minimum necessary §164.502(b), SOC 2 CC6.1). This catalog pins
/// per data domain:
///   1. Whether the domain MUST scope reads/writes by tenantId.
///   2. Whether cross-tenant queries are EVER allowed (only the
///      platform-admin-readonly domain may, never user-facing).
///   3. Whether the domain participates in tenant-deletion cascade
///      (purge on tenant offboarding for GDPR Art. 17 erasure).
///   4. Whether the domain uses per-tenant key derivation (KDF
///      with tenantId as info parameter, so even an envelope-key
///      leak does not cross tenants).
///   5. Regulatory anchor.
///
/// **Distinct from**:
///   * `TenantContext` — resolver returning the current tenantId;
///     O8 is the per-domain isolation *policy*.
///   * `TenantMembershipService` — manages who belongs to which
///     tenant; O8 governs the data routed by that membership.
///   * `VendorRiskTierCatalog` (N19) — vendor-onboarding gate;
///     O8 governs in-process per-tenant data routing.
///
/// **Out of scope** (separate PRs):
///   * Firestore security rule generator that emits the matching
///     `match /clinics/{tid}/...` rules.
///   * Tenant-deletion saga runner.
///   * Per-tenant KMS key derivation rollout.
library;

/// Coarse data domain in the platform.
enum TenantDataDomain {
  /// Patient charts, sessions, SOAP notes, clinical assessments.
  clinicalRecords,

  /// Audit log entries (one append-only stream per tenant).
  auditLog,

  /// Billing records, invoices, subscription state.
  billing,

  /// Feature analytics events (per-tenant funnel + activation).
  productAnalytics,

  /// Crash + error telemetry (Sentry / Crashlytics).
  errorTelemetry,

  /// Read-only platform admin (cross-tenant queries for incident
  /// response, billing reconciliation).
  platformAdminReadonly,
}

class TenantIsolationRecord {
  const TenantIsolationRecord({
    required this.id,
    required this.domain,
    required this.description,
    required this.scopeReadsByTenant,
    required this.scopeWritesByTenant,
    required this.allowCrossTenantQuery,
    required this.includedInDeletionCascade,
    required this.perTenantKeyDerivation,
    required this.regulatoryRefs,
  });

  final String id;
  final TenantDataDomain domain;
  final String description;

  /// True when every read MUST include a `tenantId == currentTenant`
  /// predicate. Test pins this.
  final bool scopeReadsByTenant;

  /// True when every write MUST be tagged with the current
  /// tenantId. Test pins this.
  final bool scopeWritesByTenant;

  /// True when the domain allows cross-tenant queries. ONLY the
  /// platform-admin-readonly domain may set this true.
  final bool allowCrossTenantQuery;

  /// True when records in this domain MUST be purged when a tenant
  /// is offboarded (GDPR Art. 17 erasure).
  final bool includedInDeletionCascade;

  /// True when encryption keys are derived per-tenant via KDF with
  /// tenantId as info parameter, so envelope-key compromise does
  /// not cross tenants.
  final bool perTenantKeyDerivation;

  final List<String> regulatoryRefs;
}

class TenantIsolationPolicyCatalog {
  const TenantIsolationPolicyCatalog._();

  /// YYYY-MM stamp — drives the trust-center "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policy table. Append-only.
  static const List<TenantIsolationRecord> records = [
    TenantIsolationRecord(
      id: 'clinical-records',
      domain: TenantDataDomain.clinicalRecords,
      description:
          'Patient charts, sessions, SOAP notes, assessments, copilot drafts. Hardest-isolation tier: PHI under HIPAA + GDPR Art. 9.',
      scopeReadsByTenant: true,
      scopeWritesByTenant: true,
      allowCrossTenantQuery: false,
      includedInDeletionCascade: true,
      perTenantKeyDerivation: true,
      regulatoryRefs: [
        'HIPAA §164.502(b) minimum necessary',
        'HIPAA §164.312(a)(1) access control',
        'GDPR Art. 9 special categories',
        'GDPR Art. 17 right to erasure',
        'SOC 2 CC6.1 logical + physical access',
        'OWASP API Top-10 BOLA',
      ],
    ),
    TenantIsolationRecord(
      id: 'audit-log',
      domain: TenantDataDomain.auditLog,
      description:
          'Tamper-evident audit chain — append-only per tenant. Cross-tenant queries forbidden; HMAC chain anchored per tenant.',
      scopeReadsByTenant: true,
      scopeWritesByTenant: true,
      allowCrossTenantQuery: false,
      includedInDeletionCascade: false,
      perTenantKeyDerivation: true,
      regulatoryRefs: [
        'HIPAA §164.312(b) audit controls',
        'HIPAA §164.316(b)(2)(i) 6-year retention',
        'SOC 2 CC7.2 system monitoring',
        'EU AI Act Art. 12 record-keeping',
      ],
    ),
    TenantIsolationRecord(
      id: 'billing',
      domain: TenantDataDomain.billing,
      description:
          'Invoices, subscription state, payment method handles. Stripe customer maps 1:1 to tenant.',
      scopeReadsByTenant: true,
      scopeWritesByTenant: true,
      allowCrossTenantQuery: false,
      includedInDeletionCascade: false,
      perTenantKeyDerivation: false,
      regulatoryRefs: [
        'PCI DSS v4.0 §7 restrict access by business need',
        'SOC 2 CC6.1 logical access',
        'GDPR Art. 6(1)(b) contract necessity',
      ],
    ),
    TenantIsolationRecord(
      id: 'product-analytics',
      domain: TenantDataDomain.productAnalytics,
      description:
          'Feature funnel + activation events. Pseudonymised at ingest; per-tenant aggregation only.',
      scopeReadsByTenant: true,
      scopeWritesByTenant: true,
      allowCrossTenantQuery: false,
      includedInDeletionCascade: true,
      perTenantKeyDerivation: false,
      regulatoryRefs: [
        'GDPR Art. 5(1)(c) data minimisation',
        'GDPR Art. 17 right to erasure',
        'ePrivacy Directive Art. 5(3) consent for non-essential analytics',
      ],
    ),
    TenantIsolationRecord(
      id: 'error-telemetry',
      domain: TenantDataDomain.errorTelemetry,
      description:
          'Crash + error reports (Sentry / Crashlytics). Scoped per tenant; PHI scrub per L9 runs before send.',
      scopeReadsByTenant: true,
      scopeWritesByTenant: true,
      allowCrossTenantQuery: false,
      includedInDeletionCascade: true,
      perTenantKeyDerivation: false,
      regulatoryRefs: [
        'GDPR Art. 5(1)(c) data minimisation',
        'GDPR Art. 17 right to erasure',
        'HIPAA §164.502(b) minimum necessary',
        'SOC 2 CC7.2 system monitoring',
      ],
    ),
    TenantIsolationRecord(
      id: 'platform-admin-readonly',
      domain: TenantDataDomain.platformAdminReadonly,
      description:
          'Cross-tenant READ-ONLY surface for incident response, billing reconciliation, regulator inquiry. RBAC-gated to platform-admin role only; every access audit-logged.',
      scopeReadsByTenant: false,
      scopeWritesByTenant: false,
      allowCrossTenantQuery: true,
      includedInDeletionCascade: false,
      perTenantKeyDerivation: false,
      regulatoryRefs: [
        'HIPAA §164.308(a)(4) information access management',
        'SOC 2 CC6.3 logical access change management',
        'EU AI Act Art. 14 human oversight (operator access)',
      ],
    ),
  ];

  static TenantIsolationRecord? byId(String id) {
    for (final r in records) {
      if (r.id == id) return r;
    }
    return null;
  }

  static TenantIsolationRecord? byDomain(TenantDataDomain d) {
    for (final r in records) {
      if (r.domain == d) return r;
    }
    return null;
  }
}

/// True when the data domain MUST scope reads by the current
/// tenantId. Drives the query builder to inject the predicate.
bool mustScopeReads(TenantDataDomain d) {
  final r = TenantIsolationPolicyCatalog.byDomain(d);
  return r?.scopeReadsByTenant ?? false;
}

/// True when the data domain MUST scope writes by the current
/// tenantId. Drives the document writer to assert the tag.
bool mustScopeWrites(TenantDataDomain d) {
  final r = TenantIsolationPolicyCatalog.byDomain(d);
  return r?.scopeWritesByTenant ?? false;
}
