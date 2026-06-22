/// Multi-patient group therapy session (Sprint 9).
///
/// HIPAA constraint: one patient's PHI must not be visible to another
/// patient. We enforce this by giving every roster member their own
/// per-patient sub-note id — the shared [GroupSession] only carries
/// roster references and a modality-level facilitator note. Patient
/// subjective material lives in the individual session_notes
/// collection, gated by the existing clinic-scoped Firestore rules.
///
/// Group size is capped at 8 — the consensus from our supervisor
/// review for what one facilitator can safely hold without rotating
/// into co-facilitation. Enforced at the model level so a UI bug
/// cannot quietly create a roster of 12.
class GroupSession {
  GroupSession({
    required this.id,
    required this.clinicId,
    required this.modalityLabel,
    required this.scheduledAt,
    this.roster = const [],
    this.facilitatorNote = '',
    this.status = GroupSessionStatus.scheduled,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now().toUtc() {
    // Throw (not assert) — `flutter build --release` strips asserts and
    // a roster of 30 in production with one facilitator is a patient-
    // safety event we want to fail loud about.
    if (roster.length > maxRosterSize) {
      throw ArgumentError(
        'GroupSession roster size ${roster.length} exceeds clinical cap '
        '($maxRosterSize). Split the group or co-facilitate.',
      );
    }
  }

  factory GroupSession.fromJson(Map<String, dynamic> json) => GroupSession(
    id: json['id'] as String? ?? '',
    clinicId: json['clinicId'] as String? ?? '',
    modalityLabel: json['modalityLabel'] as String? ?? '',
    scheduledAt:
        DateTime.tryParse(json['scheduledAt'] as String? ?? '') ??
        DateTime.now(),
    roster: (json['roster'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(GroupSessionAttendance.fromJson)
        .toList(),
    facilitatorNote: json['facilitatorNote'] as String? ?? '',
    status: GroupSessionStatus.fromId(json['status'] as String?),
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
  );

  static const int maxRosterSize = 8;

  final String id;
  final String clinicId;
  final String modalityLabel;
  final DateTime scheduledAt;
  final List<GroupSessionAttendance> roster;

  /// Modality-level (non-patient-identifying) facilitator note. Patient
  /// subjective material must go in the per-patient sub-note, not here.
  final String facilitatorNote;

  final GroupSessionStatus status;
  final DateTime updatedAt;

  bool get isAtCapacity => roster.length >= maxRosterSize;

  /// Roster patient ids — **clinician scope only**.
  ///
  /// HIPAA minimum-necessary: a patient must never see the co-attendee
  /// list of their own group (substance-use re-identification risk).
  /// Any caller that may render this in a patient-facing context MUST
  /// gate the call by clinician role first; the patient portal must
  /// not reach this getter at all.
  List<String> get clinicianOnlyPatientIds =>
      roster.map((e) => e.patientId).toList(growable: false);

  GroupSession copyWith({
    String? modalityLabel,
    DateTime? scheduledAt,
    List<GroupSessionAttendance>? roster,
    String? facilitatorNote,
    GroupSessionStatus? status,
  }) => GroupSession(
    id: id,
    clinicId: clinicId,
    modalityLabel: modalityLabel ?? this.modalityLabel,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    roster: roster ?? this.roster,
    facilitatorNote: facilitatorNote ?? this.facilitatorNote,
    status: status ?? this.status,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'clinicId': clinicId,
    'modalityLabel': modalityLabel,
    'scheduledAt': scheduledAt.toIso8601String(),
    'roster': roster.map((e) => e.toJson()).toList(),
    'facilitatorNote': facilitatorNote,
    'status': status.id,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// One roster row inside a [GroupSession]. Kept small — the per-patient
/// subjective note lives in the session_notes collection under its own
/// id, never duplicated here.
class GroupSessionAttendance {
  const GroupSessionAttendance({
    required this.patientId,
    required this.subNoteId,
    this.attended = false,
    this.notes = '',
  });

  factory GroupSessionAttendance.fromJson(Map<String, dynamic> json) =>
      GroupSessionAttendance(
        patientId: json['patientId'] as String? ?? '',
        subNoteId: json['subNoteId'] as String? ?? '',
        attended: json['attended'] as bool? ?? false,
        notes: json['notes'] as String? ?? '',
      );

  final String patientId;

  /// Pointer to the per-patient session_note document. Kept separate so
  /// patient A's progress note never lands in patient B's roster row.
  final String subNoteId;

  final bool attended;

  /// Brief roster-level note (e.g. "arrived 10 min late"). PHI-light
  /// by convention — anything substantive belongs in the per-patient
  /// sub-note.
  final String notes;

  GroupSessionAttendance copyWith({bool? attended, String? notes}) =>
      GroupSessionAttendance(
        patientId: patientId,
        subNoteId: subNoteId,
        attended: attended ?? this.attended,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
    'patientId': patientId,
    'subNoteId': subNoteId,
    'attended': attended,
    'notes': notes,
  };
}

enum GroupSessionStatus {
  scheduled('scheduled'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const GroupSessionStatus(this.id);
  final String id;

  static GroupSessionStatus fromId(String? id) {
    for (final s in GroupSessionStatus.values) {
      if (s.id == id) return s;
    }
    return GroupSessionStatus.scheduled;
  }
}
