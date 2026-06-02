/// Per-tenant Firestore region pin — fixes the N-11 finding from the
/// Sprint-17 audit ("Firestore eur3 + us-central1" residency claim
/// conflict).
///
/// Each tenant (clinic) is locked to a single Firestore region for
/// the lifetime of the contract. Cross-region replication is **not**
/// performed; the region also drives KMS key location, audit-log
/// storage and transactional email pipeline.
enum TenantRegion {
  euCentral('eu-central', 'eur3', 'Frankfurt', 'EU/EEA'),
  usCentral('us-central', 'us-central1', 'Iowa', 'United States');

  const TenantRegion(
    this.id,
    this.firestoreRegion,
    this.city,
    this.jurisdiction,
  );

  /// Stable identifier persisted on the tenant document.
  final String id;

  /// Firestore region literal used when provisioning the project.
  final String firestoreRegion;

  /// Human label shown in the UI ("Frankfurt", "Iowa").
  final String city;

  /// Legal jurisdiction surfaced in the DPA + BAA copy.
  final String jurisdiction;

  /// Display label e.g. "EU · Frankfurt (eur3)".
  String get displayLabel => switch (this) {
        TenantRegion.euCentral => 'EU · $city ($firestoreRegion)',
        TenantRegion.usCentral => 'US · $city ($firestoreRegion)',
      };

  /// Compliance frameworks that **must** apply for this region.
  List<String> get mandatoryFrameworks => switch (this) {
        TenantRegion.euCentral => const ['GDPR', 'KVKK'],
        TenantRegion.usCentral => const ['HIPAA'],
      };

  static TenantRegion fromId(String id) {
    return values.firstWhere(
      (r) => r.id == id,
      orElse: () => TenantRegion.euCentral,
    );
  }
}

/// Immutable snapshot of a tenant's residency commitment. Lives in
/// Firestore at `tenants/{tenantId}` under the `region_pin` field.
class TenantRegionPin {
  const TenantRegionPin({
    required this.tenantId,
    required this.region,
    required this.pinnedAt,
    this.changeRequestedAt,
    this.changeRequestedTo,
  });

  final String tenantId;
  final TenantRegion region;
  final DateTime pinnedAt;

  /// When the clinician asked to migrate to another region. Lives for
  /// the audit trail even if the migration is rejected.
  final DateTime? changeRequestedAt;
  final TenantRegion? changeRequestedTo;

  bool get hasPendingChange => changeRequestedTo != null;

  TenantRegionPin requestChangeTo(
    TenantRegion newRegion, {
    DateTime? at,
  }) {
    if (newRegion == region) {
      throw ArgumentError('Already pinned to ${region.id}');
    }
    return TenantRegionPin(
      tenantId: tenantId,
      region: region,
      pinnedAt: pinnedAt,
      changeRequestedAt: at ?? DateTime.now().toUtc(),
      changeRequestedTo: newRegion,
    );
  }

  Map<String, dynamic> toJson() => {
        'tenant_id': tenantId,
        'region': region.id,
        'pinned_at': pinnedAt.toUtc().toIso8601String(),
        if (changeRequestedAt != null)
          'change_requested_at': changeRequestedAt!.toUtc().toIso8601String(),
        if (changeRequestedTo != null)
          'change_requested_to': changeRequestedTo!.id,
      };

  factory TenantRegionPin.fromJson(Map<String, dynamic> json) {
    return TenantRegionPin(
      tenantId: json['tenant_id'] as String,
      region: TenantRegion.fromId(json['region'] as String),
      pinnedAt: DateTime.parse(json['pinned_at'] as String),
      changeRequestedAt: json['change_requested_at'] != null
          ? DateTime.parse(json['change_requested_at'] as String)
          : null,
      changeRequestedTo: json['change_requested_to'] != null
          ? TenantRegion.fromId(json['change_requested_to'] as String)
          : null,
    );
  }
}
