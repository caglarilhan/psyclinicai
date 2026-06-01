/// Insurance pre-authorisation record — captures whether the payer has
/// approved a planned course of treatment before the clinician bills.
///
/// US payers require a CPT-coded service + member id; EU statutory funds
/// (TK, Allianz, ASL) tend to issue a reference number tied to the
/// diagnosis. The model carries both shapes.
library;

/// Lifecycle for a single pre-authorisation request.
enum PreAuthStatus {
  submitted,
  approved,
  denied,
  expired;

  static PreAuthStatus fromId(String? id) {
    for (final s in PreAuthStatus.values) {
      if (s.name == id) return s;
    }
    return PreAuthStatus.submitted;
  }
}

class InsurancePreAuth {
  InsurancePreAuth({
    required this.id,
    required this.patientId,
    required this.payer,
    required this.memberId,
    required this.serviceCode,
    required this.requestedUnits,
    required this.status,
    required this.requestedAt,
    this.decisionAt,
    this.expiresAt,
    this.referenceNumber,
    this.denialReason,
  })  : assert(requestedUnits > 0,
            'requestedUnits must be positive — payers reject 0 / negative'),
        assert(serviceCode.length <= 16,
            'CPT/HCPCS service codes are short — guard against PHI smuggling');

  factory InsurancePreAuth.fromJson(Map<String, dynamic> json) =>
      InsurancePreAuth(
        id: json['id'] as String? ?? '',
        patientId: json['patient_id'] as String? ?? '',
        payer: json['payer'] as String? ?? '',
        memberId: json['member_id'] as String? ?? '',
        serviceCode: json['service_code'] as String? ?? '',
        requestedUnits: (json['requested_units'] as num?)?.toInt() ?? 1,
        status: PreAuthStatus.fromId(json['status'] as String?),
        requestedAt:
            DateTime.tryParse(json['requested_at'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        decisionAt:
            DateTime.tryParse(json['decision_at'] as String? ?? ''),
        expiresAt:
            DateTime.tryParse(json['expires_at'] as String? ?? ''),
        referenceNumber: json['reference_number'] as String?,
        denialReason: json['denial_reason'] as String?,
      );

  /// Opaque request id (UUIDv4 in production).
  final String id;

  /// Opaque patient identifier — same one used elsewhere in the chart.
  final String patientId;

  /// Display name of the payer ("Aetna", "Techniker Krankenkasse"...).
  final String payer;

  /// Member / insured id supplied by the patient.
  final String memberId;

  /// CPT (US) or equivalent national code for the requested service.
  /// Asserts ≤16 chars to keep PHI from leaking into this field.
  final String serviceCode;

  /// Number of sessions / units the payer was asked to authorise.
  final int requestedUnits;

  final PreAuthStatus status;
  final DateTime requestedAt;
  final DateTime? decisionAt;

  /// When the authorisation lapses if unused (payer-supplied).
  final DateTime? expiresAt;

  /// Payer-issued reference number returned with the decision.
  final String? referenceNumber;

  /// Free-text reason for a denial (or empty when not denied).
  final String? denialReason;

  /// True when the authorisation is currently usable: approved AND not
  /// expired against [now].
  bool isUsableAt(DateTime now) {
    if (status != PreAuthStatus.approved) return false;
    if (expiresAt == null) return true;
    return now.toUtc().isBefore(expiresAt!.toUtc());
  }

  /// Convenience for the dashboard — colour-coded badge keys without
  /// having to read the enum.
  bool get awaitingDecision => status == PreAuthStatus.submitted;

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'payer': payer,
        'member_id': memberId,
        'service_code': serviceCode,
        'requested_units': requestedUnits,
        'status': status.name,
        'requested_at': requestedAt.toUtc().toIso8601String(),
        if (decisionAt != null)
          'decision_at': decisionAt!.toUtc().toIso8601String(),
        if (expiresAt != null)
          'expires_at': expiresAt!.toUtc().toIso8601String(),
        if (referenceNumber != null) 'reference_number': referenceNumber,
        if (denialReason != null) 'denial_reason': denialReason,
      };
}
