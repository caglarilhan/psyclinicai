/// HIPAA / GDPR aware video-visit session (Sprint 11).
///
/// One row per scheduled telehealth meeting. The Cloud Function
/// (`telehealthRoom`) mints a Daily.co room + meeting token; the
/// client stores the room handle here so the same row can carry
/// audit trail (join, end, recording consent).
///
/// The meeting token itself is **never** persisted — it is returned
/// once by the relay and used in-memory by the WebRTC widget.
class TelehealthSession {
  TelehealthSession({
    required this.id,
    required this.clinicId,
    required this.sessionId,
    required this.patientId,
    required this.clinicianId,
    required this.roomName,
    required this.scheduledFor,
    this.joinedAt,
    this.endedAt,
    this.visitConsent = VisitConsent.notAsked,
    this.recordingConsent = RecordingConsent.notAsked,
    this.consentAt,
  });

  factory TelehealthSession.fromJson(Map<String, dynamic> json) =>
      TelehealthSession(
        id: json['id'] as String? ?? '',
        clinicId: json['clinicId'] as String? ?? '',
        sessionId: json['sessionId'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        clinicianId: json['clinicianId'] as String? ?? '',
        roomName: json['roomName'] as String? ?? '',
        scheduledFor:
            DateTime.tryParse(json['scheduledFor'] as String? ?? '') ??
                DateTime.now().toUtc(),
        joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? ''),
        endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
        visitConsent:
            VisitConsent.fromId(json['visitConsent'] as String?),
        recordingConsent:
            RecordingConsent.fromId(json['recordingConsent'] as String?),
        consentAt: DateTime.tryParse(json['consentAt'] as String? ?? ''),
      );

  /// CMS 90832 (psychotherapy 16–37 min) minimum duration — anything
  /// shorter is treated as an abandoned session for billing purposes.
  static const Duration billableMinDuration = Duration(minutes: 8);

  final String id;
  final String clinicId;

  /// The clinical-session id this video meeting is attached to.
  final String sessionId;
  final String patientId;
  final String clinicianId;

  /// Daily.co room handle (no token — token is ephemeral).
  final String roomName;

  final DateTime scheduledFor;
  final DateTime? joinedAt;
  final DateTime? endedAt;

  /// HIPAA §164.510 / GDPR Art. 9 — separate consent for the
  /// telehealth visit itself (the patient agrees to be treated over
  /// video). Distinct from `recordingConsent`, which only governs
  /// whether the call may be recorded.
  final VisitConsent visitConsent;

  final RecordingConsent recordingConsent;
  final DateTime? consentAt;

  bool get isLive => joinedAt != null && endedAt == null;

  /// Minutes the patient and clinician were both connected.
  /// Null until the call has ended.
  int? get durationMinutes {
    final j = joinedAt;
    final e = endedAt;
    if (j == null || e == null) return null;
    return e.difference(j).inMinutes;
  }

  /// True when the session is long enough to bill (CMS 90832 floor).
  /// Used by the superbill to refuse a primary CPT on abandoned
  /// visits — the clinician sees an "abandoned" tag instead.
  bool get isBillable {
    final d = durationMinutes;
    if (d == null) return false;
    return d >= billableMinDuration.inMinutes;
  }

  /// Strict guard for the recording control. Even if the front-end
  /// shows a record button, no recording must start unless this is
  /// `true` — the absence of `granted` is treated as a refusal.
  bool get canRecord => recordingConsent == RecordingConsent.granted;

  TelehealthSession copyWith({
    DateTime? joinedAt,
    DateTime? endedAt,
    VisitConsent? visitConsent,
    RecordingConsent? recordingConsent,
    DateTime? consentAt,
  }) =>
      TelehealthSession(
        id: id,
        clinicId: clinicId,
        sessionId: sessionId,
        patientId: patientId,
        clinicianId: clinicianId,
        roomName: roomName,
        scheduledFor: scheduledFor,
        joinedAt: joinedAt ?? this.joinedAt,
        endedAt: endedAt ?? this.endedAt,
        visitConsent: visitConsent ?? this.visitConsent,
        recordingConsent: recordingConsent ?? this.recordingConsent,
        consentAt: consentAt ?? this.consentAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clinicId': clinicId,
        'sessionId': sessionId,
        'patientId': patientId,
        'clinicianId': clinicianId,
        'roomName': roomName,
        'scheduledFor': scheduledFor.toIso8601String(),
        if (joinedAt != null) 'joinedAt': joinedAt!.toIso8601String(),
        if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
        'visitConsent': visitConsent.id,
        'recordingConsent': recordingConsent.id,
        if (consentAt != null) 'consentAt': consentAt!.toIso8601String(),
      };
}

/// HIPAA §164.510 / GDPR Art. 9 — visit-level consent. Separate
/// from `RecordingConsent`: a patient may agree to the telehealth
/// visit while declining recording.
enum VisitConsent {
  notAsked('not_asked'),
  granted('granted'),
  declined('declined');

  const VisitConsent(this.id);
  final String id;

  static VisitConsent fromId(String? id) {
    for (final v in VisitConsent.values) {
      if (v.id == id) return v;
    }
    return VisitConsent.notAsked;
  }
}

/// HIPAA §164.508 + GDPR Art. 9 — explicit consent per session.
enum RecordingConsent {
  notAsked('not_asked'),
  granted('granted'),
  declined('declined');

  const RecordingConsent(this.id);
  final String id;

  static RecordingConsent fromId(String? id) {
    for (final c in RecordingConsent.values) {
      if (c.id == id) return c;
    }
    return RecordingConsent.notAsked;
  }
}
