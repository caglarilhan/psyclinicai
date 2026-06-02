/// Patient-initiated GDPR / KVKK data-subject access request (Sprint 13).
///
/// The portal lets a patient file an access, portability, correction,
/// or erasure request without going through their clinician. The
/// clinic admin then fulfills the request inside the deadline
/// (GDPR Art. 12(3) — one month; can extend by two more on complex
/// requests).
///
/// Lifecycle:
///   submitted      — patient just filed
///   underReview    — clinic admin has acknowledged
///   fulfilled      — data delivered / correction applied
///   rejected       — refused with reason (e.g. another lawful basis)
class PortalDsarRequest {
  PortalDsarRequest({
    required this.id,
    required this.userId,
    required this.patientId,
    required this.kind,
    this.state = PortalDsarState.submitted,
    this.notes = '',
    this.rejectionReason = '',
    DateTime? submittedAt,
    this.fulfilledAt,
  }) : submittedAt = submittedAt ?? DateTime.now().toUtc();

  factory PortalDsarRequest.fromJson(Map<String, dynamic> json) =>
      PortalDsarRequest(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        kind: PortalDsarKind.fromId(json['kind'] as String?),
        state: PortalDsarState.fromId(json['state'] as String?),
        notes: json['notes'] as String? ?? '',
        rejectionReason: json['rejectionReason'] as String? ?? '',
        submittedAt:
            DateTime.tryParse(json['submittedAt'] as String? ?? ''),
        fulfilledAt:
            DateTime.tryParse(json['fulfilledAt'] as String? ?? ''),
      );

  /// GDPR Art. 12(3) standard window.
  static const Duration fulfilmentWindow = Duration(days: 30);

  final String id;
  final String userId;
  final String patientId;
  final PortalDsarKind kind;
  final PortalDsarState state;
  final String notes;

  /// Patient-visible explanation when [state] is
  /// [PortalDsarState.rejected]. GDPR Art. 12(4) requires the
  /// controller to disclose the reasons for not taking action; the
  /// portal renders this verbatim to the patient.
  final String rejectionReason;

  final DateTime submittedAt;
  final DateTime? fulfilledAt;

  DateTime get deadline => submittedAt.add(fulfilmentWindow);

  /// True when fulfilment is past the GDPR Art. 12(3) deadline.
  bool isOverdue(DateTime now) =>
      state != PortalDsarState.fulfilled &&
      state != PortalDsarState.rejected &&
      now.toUtc().isAfter(deadline);

  String? transitionBlockedReason(PortalDsarState next) {
    if (state == next) return 'Already in that state';
    switch (state) {
      case PortalDsarState.submitted:
        if (next == PortalDsarState.underReview ||
            next == PortalDsarState.rejected) {
          return null;
        }
        return 'A submitted request must first move to underReview';
      case PortalDsarState.underReview:
        if (next == PortalDsarState.fulfilled ||
            next == PortalDsarState.rejected) {
          return null;
        }
        return 'Under-review requests transition to fulfilled or rejected';
      case PortalDsarState.fulfilled:
      case PortalDsarState.rejected:
        return 'This request is in a final state';
    }
  }

  PortalDsarRequest copyWith({
    PortalDsarState? state,
    String? notes,
    String? rejectionReason,
    DateTime? fulfilledAt,
  }) =>
      PortalDsarRequest(
        id: id,
        userId: userId,
        patientId: patientId,
        kind: kind,
        state: state ?? this.state,
        notes: notes ?? this.notes,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        submittedAt: submittedAt,
        fulfilledAt: fulfilledAt ?? this.fulfilledAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'patientId': patientId,
        'kind': kind.id,
        'state': state.id,
        'notes': notes,
        if (rejectionReason.isNotEmpty) 'rejectionReason': rejectionReason,
        'submittedAt': submittedAt.toIso8601String(),
        if (fulfilledAt != null) 'fulfilledAt': fulfilledAt!.toIso8601String(),
      };
}

enum PortalDsarKind {
  access('access'),
  portability('portability'),
  correction('correction'),
  erasure('erasure');

  const PortalDsarKind(this.id);
  final String id;

  static PortalDsarKind fromId(String? id) {
    for (final k in PortalDsarKind.values) {
      if (k.id == id) return k;
    }
    return PortalDsarKind.access;
  }
}

enum PortalDsarState {
  submitted('submitted'),
  underReview('under_review'),
  fulfilled('fulfilled'),
  rejected('rejected');

  const PortalDsarState(this.id);
  final String id;

  static PortalDsarState fromId(String? id) {
    for (final s in PortalDsarState.values) {
      if (s.id == id) return s;
    }
    return PortalDsarState.submitted;
  }
}
