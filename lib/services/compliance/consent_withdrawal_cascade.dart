/// K11 — Consent withdrawal cascade catalog (pinned helper).
///
/// **Why this exists**: when a patient revokes a consent, the
/// platform must execute a chain of downstream actions, not just
/// flip a boolean. GDPR Art. 7(3) + KVKK md. 7 require withdrawal
/// to be as easy as granting AND that data processing stops
/// "ivedilikle" (without delay). K6.helper ConsentKindCatalog
/// records the human-readable revoke effect; this catalog pins
/// the deterministic *action sequence* the repository runs.
///
/// Pins per ConsentKind:
///   1. Ordered list of cascade actions (stop recording, purge
///      transcripts, scrub AI prompt history, etc.).
///   2. SLA in minutes from revoke timestamp to last action done.
///   3. Whether each action is reversible if the patient changes
///      their mind within a grace window (some are; purge is not).
///
/// **Distinct from**:
///   * K6.helper `ConsentKindCatalog` (PR #124): per-kind copy +
///     policy; THIS catalog: deterministic cascade actions.
///   * K8 `subject_rights_taxonomy` (PR #137): Art. 15-22 rights
///     in general; THIS is the per-consent-kind revoke side.
///
/// **Out of scope** (separate PRs):
///   * Wire ConsentRepositoryRouter to execute the cascade.
///   * Cloud Function that does the per-action purge.
///   * Audit log entry per cascade action.
library;

import '../../models/consent_entry.dart';

/// One deterministic action the cascade may execute.
enum CascadeAction {
  /// Set a runtime flag that prevents new AI assistance calls for
  /// this patient until consent is re-granted.
  blockAiAssistance,

  /// Stop any active audio recording session for this patient.
  stopActiveAudioRecording,

  /// Delete all recorded audio + transcripts for the patient that
  /// are not under a clinician-retention hold.
  purgeAudioAndTranscripts,

  /// Cancel any future telehealth appointments + disable
  /// telehealth scheduling for the patient.
  blockTelehealth,

  /// Unsubscribe from all marketing email lists; suppress future
  /// product comms.
  unsubscribeMarketing,

  /// Close the patient chart (no read / no write) for everyone
  /// EXCEPT the assigned clinician + DPO. Triggers DPO review.
  closeChartPendingDpoReview,

  /// Run KVKK md. 7 silme/yok etme prosedürü — pseudonymise
  /// records, preserve audit chain entries with hashed identifiers.
  triggerKvkkErasure,

  /// Run GDPR Art. 17 erasure procedure — schedule full record
  /// deletion within the statutory window.
  triggerGdprErasure,
}

/// One pinned cascade record.
class CascadeRecord {
  const CascadeRecord({
    required this.kind,
    required this.actions,
    required this.slaMinutes,
    required this.reversibleWithinMinutes,
    required this.requiresClinicianAck,
    required this.regulatoryRefs,
  });

  final ConsentKind kind;

  /// Ordered action list. Order matters — block first, purge
  /// after.
  final List<CascadeAction> actions;

  /// Max minutes from revoke timestamp to the LAST action being
  /// done. Mirrors K6.helper revocationSlaHours but in minutes
  /// for finer granularity.
  final int slaMinutes;

  /// If the patient changes their mind within this window, the
  /// repository may re-grant + the cascade is REVERSED. `0`
  /// means irreversible (purge has already run).
  final int reversibleWithinMinutes;

  /// True when the cascade MUST surface to the clinician dashboard
  /// for acknowledgement (so the chart isn't silently closed).
  final bool requiresClinicianAck;

  final List<String> regulatoryRefs;
}

class ConsentWithdrawalCascade {
  const ConsentWithdrawalCascade._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned cascade per ConsentKind. Order MUST match
  /// ConsentKind.values; parity test pins it.
  static const List<CascadeRecord> cascades = [
    CascadeRecord(
      kind: ConsentKind.hipaaNopp,
      // HIPAA NOPP is service-agreement gated — withdrawal here
      // closes the chart + escalates to DPO review (no auto-purge
      // because HIPAA §164.316(b)(2)(i) retention rules apply).
      actions: [
        CascadeAction.blockAiAssistance,
        CascadeAction.closeChartPendingDpoReview,
      ],
      slaMinutes: 72 * 60,
      reversibleWithinMinutes: 60,
      requiresClinicianAck: true,
      regulatoryRefs: [
        'HIPAA §164.520 Notice of Privacy Practices',
        'HIPAA §164.316(b)(2)(i) 6-year retention',
      ],
    ),
    CascadeRecord(
      kind: ConsentKind.gdprProcessing,
      // GDPR Art. 17 erasure — closes chart, triggers full erasure
      // schedule. Reversible only within 60 min before erasure
      // starts.
      actions: [
        CascadeAction.blockAiAssistance,
        CascadeAction.closeChartPendingDpoReview,
        CascadeAction.triggerGdprErasure,
      ],
      slaMinutes: 72 * 60,
      reversibleWithinMinutes: 60,
      requiresClinicianAck: true,
      regulatoryRefs: [
        'GDPR Art. 7(3) withdrawal as easy as granting',
        'GDPR Art. 17 erasure',
      ],
    ),
    CascadeRecord(
      kind: ConsentKind.kvkkSpecialCategoryHealth,
      // KVKK md. 7 silme — triggers pseudonymisation + audit-chain
      // hash preservation.
      actions: [
        CascadeAction.blockAiAssistance,
        CascadeAction.closeChartPendingDpoReview,
        CascadeAction.triggerKvkkErasure,
      ],
      slaMinutes: 24 * 60,
      reversibleWithinMinutes: 60,
      requiresClinicianAck: true,
      regulatoryRefs: ['KVKK md. 6/2 açık rıza', 'KVKK md. 7 silme / yok etme'],
    ),
    CascadeRecord(
      kind: ConsentKind.aiProcessing,
      // AI consent revoke: stop new AI calls + scrub prompt
      // history. Fast (1h) — fail-open never holds PHI in queue.
      actions: [CascadeAction.blockAiAssistance],
      slaMinutes: 60,
      reversibleWithinMinutes: 60,
      requiresClinicianAck: false,
      regulatoryRefs: ['GDPR Art. 7(3)', 'EU AI Act Art. 14 human oversight'],
    ),
    CascadeRecord(
      kind: ConsentKind.audioRecording,
      // Audio revoke: STOP active recording first, THEN purge
      // transcripts. Order matters; tests pin it.
      actions: [
        CascadeAction.stopActiveAudioRecording,
        CascadeAction.purgeAudioAndTranscripts,
      ],
      slaMinutes: 60,
      // Purge is irreversible.
      reversibleWithinMinutes: 0,
      requiresClinicianAck: true,
      regulatoryRefs: [
        'GDPR Art. 9(2)(a) explicit consent',
        'GDPR Art. 17 erasure',
      ],
    ),
    CascadeRecord(
      kind: ConsentKind.telehealth,
      actions: [CascadeAction.blockTelehealth],
      slaMinutes: 24 * 60,
      reversibleWithinMinutes: 24 * 60,
      requiresClinicianAck: false,
      regulatoryRefs: ['GDPR Art. 7(3)'],
    ),
    CascadeRecord(
      kind: ConsentKind.marketing,
      actions: [CascadeAction.unsubscribeMarketing],
      slaMinutes: 24 * 60,
      reversibleWithinMinutes: 24 * 60,
      requiresClinicianAck: false,
      regulatoryRefs: [
        'GDPR Art. 7(3)',
        'CAN-SPAM §7704 unsubscribe',
        'KVKK md. 5/1',
      ],
    ),
  ];

  static CascadeRecord forKind(ConsentKind kind) {
    for (final r in cascades) {
      if (r.kind == kind) return r;
    }
    throw StateError('No cascade for ${kind.id}');
  }
}

/// True when the cascade is still reversible at [elapsedMinutes]
/// after the revoke timestamp. `reversibleWithinMinutes == 0`
/// always returns false (purge done).
bool isCascadeReversible({
  required CascadeRecord cascade,
  required int elapsedMinutes,
}) {
  if (cascade.reversibleWithinMinutes == 0) return false;
  return elapsedMinutes <= cascade.reversibleWithinMinutes;
}

/// True when the cascade includes an irreversible action (purge,
/// erasure). Drives the confirmation dialog before the revoke.
bool hasIrreversibleAction(CascadeRecord cascade) {
  for (final a in cascade.actions) {
    if (a == CascadeAction.purgeAudioAndTranscripts ||
        a == CascadeAction.triggerGdprErasure ||
        a == CascadeAction.triggerKvkkErasure) {
      return true;
    }
  }
  return false;
}
