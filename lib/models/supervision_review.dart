/// Trainee → supervisor co-sign queue (Sprint 9).
///
/// Different from [SupervisionReport] (a de-identified fidelity write-up
/// for a single session). This model is the *workflow* — a trainee's
/// note enters the supervisor's queue, the supervisor approves,
/// requests changes, or co-signs. Only after co-sign does the note
/// become a chargeable, countersigned clinical record.
///
/// Lifecycle (single direction, no back-edges):
///   pending → approved          (supervisor accepts as-is, no co-sign)
///   pending → changesRequested  (sent back to trainee)
///   pending → coSigned          (supervisor's signature appended)
///   changesRequested → pending  (trainee resubmits)
///
/// `co_signed` is what the audit log treats as a complete clinical
/// record; `approved` is supervisor agreement without taking formal
/// legal responsibility for the note.
class SupervisionReview {
  SupervisionReview({
    required this.id,
    required this.clinicId,
    required this.traineeId,
    required this.supervisorId,
    required this.sessionNoteId,
    this.status = SupervisionReviewStatus.pending,
    this.supervisorComment = '',
    DateTime? requestedAt,
    this.decidedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();

  factory SupervisionReview.fromJson(Map<String, dynamic> json) =>
      SupervisionReview(
        id: json['id'] as String? ?? '',
        clinicId: json['clinicId'] as String? ?? '',
        traineeId: json['traineeId'] as String? ?? '',
        supervisorId: json['supervisorId'] as String? ?? '',
        sessionNoteId: json['sessionNoteId'] as String? ?? '',
        status: SupervisionReviewStatus.fromId(json['status'] as String?),
        supervisorComment: json['supervisorComment'] as String? ?? '',
        requestedAt: DateTime.tryParse(json['requestedAt'] as String? ?? ''),
        decidedAt: DateTime.tryParse(json['decidedAt'] as String? ?? ''),
      );

  final String id;
  final String clinicId;
  final String traineeId;
  final String supervisorId;
  final String sessionNoteId;
  final SupervisionReviewStatus status;
  final String supervisorComment;
  final DateTime requestedAt;
  final DateTime? decidedAt;

  bool get isOpen => status == SupervisionReviewStatus.pending;
  bool get isFinal =>
      status == SupervisionReviewStatus.approved ||
      status == SupervisionReviewStatus.coSigned;

  /// Returns null when the transition is allowed; otherwise a short
  /// explainer the UI can show. The repository must enforce this
  /// before persisting — a UI bug must not drag a co_signed row back
  /// to pending.
  String? transitionBlockedReason(SupervisionReviewStatus next) {
    if (status == next) return 'Already in that state';
    switch (status) {
      case SupervisionReviewStatus.pending:
        return null;
      case SupervisionReviewStatus.changesRequested:
        if (next == SupervisionReviewStatus.pending) return null;
        return 'Trainee must resubmit before a decision can be made';
      case SupervisionReviewStatus.approved:
      case SupervisionReviewStatus.coSigned:
        return 'Final decisions are immutable — open a new review';
    }
  }

  SupervisionReview copyWith({
    SupervisionReviewStatus? status,
    String? supervisorComment,
    DateTime? decidedAt,
  }) => SupervisionReview(
    id: id,
    clinicId: clinicId,
    traineeId: traineeId,
    supervisorId: supervisorId,
    sessionNoteId: sessionNoteId,
    status: status ?? this.status,
    supervisorComment: supervisorComment ?? this.supervisorComment,
    requestedAt: requestedAt,
    decidedAt: decidedAt ?? this.decidedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clinicId': clinicId,
    'traineeId': traineeId,
    'supervisorId': supervisorId,
    'sessionNoteId': sessionNoteId,
    'status': status.id,
    'supervisorComment': supervisorComment,
    'requestedAt': requestedAt.toIso8601String(),
    if (decidedAt != null) 'decidedAt': decidedAt!.toIso8601String(),
  };
}

enum SupervisionReviewStatus {
  pending('pending'),
  changesRequested('changes_requested'),
  approved('approved'),
  coSigned('co_signed');

  const SupervisionReviewStatus(this.id);
  final String id;

  static SupervisionReviewStatus fromId(String? id) {
    for (final s in SupervisionReviewStatus.values) {
      if (s.id == id) return s;
    }
    return SupervisionReviewStatus.pending;
  }
}
