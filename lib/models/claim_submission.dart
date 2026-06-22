/// Insurance claim (ANSI ASC X12 837P) lifecycle for the kanban
/// board. State machine is forward-only except for the explicit
/// `appealing` rollback — denial → appeal → re-submission re-uses
/// the same claim id so we never lose audit trail.
enum ClaimStatus {
  draft('draft', 'Draft', 0),
  submitted('submitted', 'Submitted', 1),
  accepted('accepted', 'Accepted', 2),
  paid('paid', 'Paid', 3),
  denied('denied', 'Denied', 2),
  appealing('appealing', 'Appealing', 2),
  writtenOff('written_off', 'Written off', 3);

  const ClaimStatus(this.id, this.label, this.order);
  final String id;
  final String label;
  final int order;

  bool get isFinal =>
      this == ClaimStatus.paid || this == ClaimStatus.writtenOff;

  static ClaimStatus fromId(String id) =>
      values.firstWhere((s) => s.id == id, orElse: () => ClaimStatus.draft);
}

class ClaimSubmission {
  ClaimSubmission({
    required this.id,
    required this.superbillId,
    required this.payerId,
    required this.subjectPatientId,
    required this.cptCodes,
    required this.icd10Codes,
    required this.amountCents,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    this.adjudicatedAt,
    this.denialReasonCode,
    this.refNumber,
  }) {
    if (id.isEmpty) {
      throw ArgumentError('ClaimSubmission.id is required.');
    }
    if (amountCents < 0) {
      throw ArgumentError('amountCents cannot be negative.');
    }
    if (cptCodes.isEmpty) {
      throw ArgumentError(
        'ClaimSubmission needs at least one CPT code (X12 837P).',
      );
    }
    if (icd10Codes.isEmpty) {
      throw ArgumentError('ClaimSubmission needs at least one ICD-10 pointer.');
    }
  }

  final String id;
  final String superbillId;
  final String payerId;
  final String subjectPatientId;
  final List<String> cptCodes;
  final List<String> icd10Codes;
  final int amountCents;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? adjudicatedAt;
  final String? denialReasonCode;
  final String? refNumber;

  static const _allowed = {
    ClaimStatus.draft: [ClaimStatus.submitted, ClaimStatus.writtenOff],
    ClaimStatus.submitted: [
      ClaimStatus.accepted,
      ClaimStatus.denied,
      ClaimStatus.writtenOff,
    ],
    ClaimStatus.accepted: [ClaimStatus.paid, ClaimStatus.writtenOff],
    ClaimStatus.denied: [ClaimStatus.appealing, ClaimStatus.writtenOff],
    ClaimStatus.appealing: [
      ClaimStatus.accepted,
      ClaimStatus.denied,
      ClaimStatus.writtenOff,
    ],
    ClaimStatus.paid: <ClaimStatus>[],
    ClaimStatus.writtenOff: <ClaimStatus>[],
  };

  String? transitionBlockedReason(ClaimStatus target) {
    final allowed = _allowed[status] ?? const [];
    if (allowed.contains(target)) return null;
    return 'Cannot move from ${status.label} to ${target.label} '
        '(allowed: ${allowed.map((s) => s.label).join(", ")})';
  }

  ClaimSubmission advance({
    required ClaimStatus to,
    DateTime? at,
    String? denialReasonCode,
    String? refNumber,
  }) {
    final blocked = transitionBlockedReason(to);
    if (blocked != null) {
      throw StateError(blocked);
    }
    final ts = at ?? DateTime.now().toUtc();
    return ClaimSubmission(
      id: id,
      superbillId: superbillId,
      payerId: payerId,
      subjectPatientId: subjectPatientId,
      cptCodes: cptCodes,
      icd10Codes: icd10Codes,
      amountCents: amountCents,
      status: to,
      createdAt: createdAt,
      submittedAt: to == ClaimStatus.submitted ? ts : submittedAt,
      adjudicatedAt:
          (to == ClaimStatus.accepted ||
              to == ClaimStatus.denied ||
              to == ClaimStatus.paid)
          ? ts
          : adjudicatedAt,
      denialReasonCode: denialReasonCode ?? this.denialReasonCode,
      refNumber: refNumber ?? this.refNumber,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'superbill_id': superbillId,
    'payer_id': payerId,
    'subject_patient_id': subjectPatientId,
    'cpt_codes': cptCodes,
    'icd10_codes': icd10Codes,
    'amount_cents': amountCents,
    'status': status.id,
    'created_at': createdAt.toUtc().toIso8601String(),
    if (submittedAt != null)
      'submitted_at': submittedAt!.toUtc().toIso8601String(),
    if (adjudicatedAt != null)
      'adjudicated_at': adjudicatedAt!.toUtc().toIso8601String(),
    if (denialReasonCode != null) 'denial_reason_code': denialReasonCode,
    if (refNumber != null) 'ref_number': refNumber,
  };

  factory ClaimSubmission.fromJson(Map<String, dynamic> json) {
    return ClaimSubmission(
      id: json['id'] as String,
      superbillId: json['superbill_id'] as String,
      payerId: json['payer_id'] as String,
      subjectPatientId: json['subject_patient_id'] as String,
      cptCodes: (json['cpt_codes'] as List).map((e) => e as String).toList(),
      icd10Codes: (json['icd10_codes'] as List)
          .map((e) => e as String)
          .toList(),
      amountCents: json['amount_cents'] as int,
      status: ClaimStatus.fromId(json['status'] as String? ?? 'draft'),
      createdAt: DateTime.parse(json['created_at'] as String),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      adjudicatedAt: json['adjudicated_at'] != null
          ? DateTime.parse(json['adjudicated_at'] as String)
          : null,
      denialReasonCode: json['denial_reason_code'] as String?,
      refNumber: json['ref_number'] as String?,
    );
  }
}
