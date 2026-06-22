/// One row of the tamper-evident audit log.
///
/// Mirrors the on-disk Firestore schema (see `audit_logs/{clinicId}/...`),
/// so SIEM exports and PDF attestations can round-trip without lossy
/// conversion. Persistence is append-only; mutating an entry after write
/// invalidates the hash chain.
///
/// JSON keys are stable wire labels (snake-case for parity with common
/// SIEM ingestors). Tarih: UTC ISO-8601.
library;

/// Outcome of the audited action. Stored as a stable string so a future
/// taxonomy expansion (e.g. "rate_limited") is back-compatible without a
/// migration.
enum AuditResult {
  success,
  failure,
  denied;

  static AuditResult fromId(String? id) {
    for (final r in AuditResult.values) {
      if (r.name == id) return r;
    }
    return AuditResult.success;
  }
}

class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.kind,
    required this.action,
    required this.actor,
    required this.entity,
    required this.timestampUtc,
    required this.result,
    this.userId,
    this.ip,
    this.device,
    this.hash,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) => AuditLogEntry(
    id: json['id'] as String? ?? '',
    kind: json['kind'] as String? ?? 'unknown',
    action: json['action'] as String? ?? '',
    actor: json['actor'] as String? ?? '',
    entity: json['entity'] as String? ?? '',
    timestampUtc:
        DateTime.tryParse(json['timestamp_utc'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    result: AuditResult.fromId(json['result'] as String?),
    userId: json['user_id'] as String?,
    ip: json['ip'] as String?,
    device: json['device'] as String?,
    hash: json['hash'] as String?,
  );

  /// Opaque row id (UUIDv4 in production; numeric demo).
  final String id;

  /// High-level kind: signin / read / write / export / risk / config / ...
  final String kind;

  /// Human label of what happened ("Opened patient chart").
  final String action;

  /// Who acted — email or service account name. PII; SIEM exports MAY
  /// redact this when shipping to lower-tier observability.
  final String actor;

  /// What was touched — patient id, route, or short description.
  /// May contain quasi-identifiers; treat as PHI-adjacent.
  final String entity;

  final DateTime timestampUtc;
  final AuditResult result;
  final String? userId;
  final String? ip;
  final String? device;

  /// Tamper-evident chain hash (SHA-256 over `previous_hash || row_json`).
  final String? hash;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'action': action,
    'actor': actor,
    'entity': entity,
    'timestamp_utc': timestampUtc.toUtc().toIso8601String(),
    'result': result.name,
    if (userId != null) 'user_id': userId,
    if (ip != null) 'ip': ip,
    if (device != null) 'device': device,
    if (hash != null) 'hash': hash,
  };
}
