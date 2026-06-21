/// Between-Session AI Coach data shapes (audit 2026-06-21, Winner
/// Portfolio bet F-1).
///
/// The coach is a *clinician-supervised* chat companion the patient
/// uses between sessions to practice the skills their treatment plan
/// prescribes (CBT thought records, DBT diary cards, IFS parts
/// mapping). It is NOT a replacement therapist — every conversation
/// is logged + visible to the assigned clinician, and any risk signal
/// (SI, self-harm, crisis vocabulary) triggers immediate escalation
/// via the existing `RiskSignalService` lexicon.
///
/// The competitive wedge: every rival mental-health chatbot (Wysa,
/// Woebot, Limbic) runs unsupervised + outside the clinical record.
/// Ours is supervised, chart-aware, and modality-trained — which is
/// also why we stay in AI-Act limited-risk classification (Art. 14
/// human oversight is built in).
///
/// This file ships the data models + an extension surface only — the
/// service that drives a conversation against the relay lands in
/// `lib/services/copilot/between_session_coach_service.dart` (F-1
/// implementation continues in M4/M5 with the UI).
library;

/// One turn in a between-session coach conversation. Mirrors the
/// Anthropic `messages` API roles so a conversation can be replayed
/// to the model verbatim.
class CoachMessage {
  const CoachMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.at,
    this.riskFlagged = false,
    this.modality,
  });

  factory CoachMessage.fromJson(Map<String, dynamic> json) => CoachMessage(
        id: json['id'] as String? ?? '',
        role: CoachRole.fromWire(json['role'] as String? ?? 'user'),
        text: json['text'] as String? ?? '',
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
        riskFlagged: json['riskFlagged'] as bool? ?? false,
        modality: json['modality'] as String?,
      );

  /// Opaque message id — Firestore doc id when persisted; UUID v4 in
  /// the test fixtures.
  final String id;

  /// Who said this — patient (`user`), coach (`assistant`), or the
  /// internal system priming (`system`, never shown).
  final CoachRole role;

  /// Plain-text body. Stored verbatim for now; once F-1 ships in
  /// production, server-side `PhiRedactor` runs over it before any
  /// LLM egress (same path as the relay's PHI scrub).
  final String text;

  /// Server-clock-trusted timestamp. UTC ISO-8601 on the wire.
  final DateTime at;

  /// True when the risk lexicon flagged this message. The clinician
  /// dashboard sorts conversations by max-risk-flagged-at so a
  /// concerning patient surfaces immediately.
  final bool riskFlagged;

  /// Optional modality tag attached to this turn — useful for
  /// fidelity scoring (e.g. "the coach was prompting a thought-
  /// record per the CBT plan").
  final String? modality;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.wire,
        'text': text,
        'at': at.toUtc().toIso8601String(),
        'riskFlagged': riskFlagged,
        if (modality != null) 'modality': modality,
      };
}

enum CoachRole {
  /// Patient-authored turn.
  user('user'),

  /// Coach (model) turn.
  assistant('assistant'),

  /// System priming — never shown to the patient. Carries the
  /// treatment plan summary + modality directive.
  system('system');

  const CoachRole(this.wire);

  /// Wire encoding (Anthropic / OpenAI shape).
  final String wire;

  /// Permissive parser — unknown wire names fall through to `user`
  /// (least privilege; an unknown payload is treated as patient input,
  /// not as a system directive).
  static CoachRole fromWire(String value) {
    for (final r in CoachRole.values) {
      if (r.wire == value) return r;
    }
    return CoachRole.user;
  }
}

/// One coach conversation tied to a single patient + treatment plan.
class CoachConversation {
  CoachConversation({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.treatmentPlanId,
    required this.modality,
    DateTime? createdAt,
    List<CoachMessage>? messages,
  })  : createdAt = createdAt ?? DateTime.now(),
        messages = List<CoachMessage>.unmodifiable(messages ?? const []);

  factory CoachConversation.fromJson(Map<String, dynamic> json) =>
      CoachConversation(
        id: json['id'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        clinicianId: json['clinicianId'] as String? ?? '',
        treatmentPlanId: json['treatmentPlanId'] as String? ?? '',
        modality: json['modality'] as String? ?? 'general',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                DateTime.now(),
        messages: ((json['messages'] as List<dynamic>?) ?? const [])
            .map((e) => CoachMessage.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  final String id;
  final String patientId;

  /// Firebase uid of the clinician who owns this patient. Surfaced
  /// so the relay can verify the caller's tenancy via the standard
  /// Firestore rule path.
  final String clinicianId;

  /// Id of the treatment plan this conversation is anchored to. The
  /// coach reads the plan to build the system prompt (modality, goals,
  /// homework). Empty string is allowed for pre-plan conversations
  /// (intake-style) but the UI must render a "no plan yet" badge.
  final String treatmentPlanId;

  /// Modality label driving the system prompt — `cbt`, `dbt`, `ifs`,
  /// `act`, `emdr`, `schema`, `psychodynamic`, `mi`, or `general`.
  final String modality;

  final DateTime createdAt;
  final List<CoachMessage> messages;

  /// True when any message in the conversation has been flagged by
  /// the risk lexicon. Drives the clinician dashboard's "needs
  /// attention" badge.
  bool get hasRiskFlag => messages.any((m) => m.riskFlagged);

  /// Last patient/assistant turn, ignoring system priming. Returns
  /// null on an empty conversation.
  CoachMessage? get lastTurn {
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role != CoachRole.system) return messages[i];
    }
    return null;
  }

  /// Append a turn and return a new conversation (immutable model).
  CoachConversation append(CoachMessage message) {
    return CoachConversation(
      id: id,
      patientId: patientId,
      clinicianId: clinicianId,
      treatmentPlanId: treatmentPlanId,
      modality: modality,
      createdAt: createdAt,
      messages: [...messages, message],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'clinicianId': clinicianId,
        'treatmentPlanId': treatmentPlanId,
        'modality': modality,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(growable: false),
      };
}
