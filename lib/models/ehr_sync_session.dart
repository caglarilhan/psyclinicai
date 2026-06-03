/// HL7 FHIR R4 sync session — bridges PsyClinicAI with Epic / Cerner
/// / Medistar. Sprint 23 surfaces the session state + conflict list.
enum FhirVendor {
  epic('epic', 'Epic'),
  cerner('cerner', 'Cerner (Oracle Health)'),
  medistar('medistar', 'Medistar'),
  smartOnFhir('smart', 'SMART on FHIR (generic)');

  const FhirVendor(this.id, this.label);
  final String id;
  final String label;

  static FhirVendor fromId(String id) =>
      values.firstWhere((v) => v.id == id,
          orElse: () => FhirVendor.smartOnFhir);
}

enum FhirSyncStatus { idle, running, conflict, complete, error }

enum FhirConflictKind { divergent, remoteMissing, localMissing }

class FhirConflict {
  const FhirConflict({
    required this.resourceType,
    required this.resourceId,
    required this.kind,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    this.fieldPath,
  });

  final String resourceType;
  final String resourceId;
  final FhirConflictKind kind;
  final DateTime localUpdatedAt;
  final DateTime remoteUpdatedAt;
  final String? fieldPath;

  Map<String, dynamic> toJson() => {
        'resource_type': resourceType,
        'resource_id': resourceId,
        'kind': kind.name,
        'local_updated_at': localUpdatedAt.toUtc().toIso8601String(),
        'remote_updated_at': remoteUpdatedAt.toUtc().toIso8601String(),
        if (fieldPath != null) 'field_path': fieldPath,
      };

  factory FhirConflict.fromJson(Map<String, dynamic> json) => FhirConflict(
        resourceType: json['resource_type'] as String,
        resourceId: json['resource_id'] as String,
        kind: FhirConflictKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => FhirConflictKind.divergent,
        ),
        localUpdatedAt: DateTime.parse(json['local_updated_at'] as String),
        remoteUpdatedAt: DateTime.parse(json['remote_updated_at'] as String),
        fieldPath: json['field_path'] as String?,
      );
}

class EhrSyncSession {
  const EhrSyncSession({
    required this.sessionId,
    required this.vendor,
    required this.resourceTypes,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.conflicts = const [],
    this.recordsRead = 0,
    this.recordsWritten = 0,
    this.errorMessage,
  });

  final String sessionId;
  final FhirVendor vendor;
  final List<String> resourceTypes;
  final FhirSyncStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final List<FhirConflict> conflicts;
  final int recordsRead;
  final int recordsWritten;
  final String? errorMessage;

  bool get needsAttention =>
      status == FhirSyncStatus.conflict || status == FhirSyncStatus.error;

  Duration? get runtime =>
      completedAt == null ? null : completedAt!.difference(startedAt);

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'vendor': vendor.id,
        'resource_types': resourceTypes,
        'status': status.name,
        'started_at': startedAt.toUtc().toIso8601String(),
        if (completedAt != null)
          'completed_at': completedAt!.toUtc().toIso8601String(),
        'conflicts': conflicts.map((c) => c.toJson()).toList(),
        'records_read': recordsRead,
        'records_written': recordsWritten,
        if (errorMessage != null) 'error_message': errorMessage,
      };

  factory EhrSyncSession.fromJson(Map<String, dynamic> json) =>
      EhrSyncSession(
        sessionId: json['session_id'] as String,
        vendor: FhirVendor.fromId(json['vendor'] as String? ?? 'smart'),
        resourceTypes: (json['resource_types'] as List)
            .map((e) => e as String)
            .toList(),
        status: FhirSyncStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => FhirSyncStatus.idle,
        ),
        startedAt: DateTime.parse(json['started_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        conflicts: (json['conflicts'] as List? ?? [])
            .map((c) => FhirConflict.fromJson(c as Map<String, dynamic>))
            .toList(),
        recordsRead: json['records_read'] as int? ?? 0,
        recordsWritten: json['records_written'] as int? ?? 0,
        errorMessage: json['error_message'] as String?,
      );
}
