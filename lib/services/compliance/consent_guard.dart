import '../../models/consent_entry.dart';
import '../../models/consent_record.dart';

/// Thrown when a consent-gated code path is invoked for a patient
/// whose consent for the matching kind is missing or has been
/// withdrawn.
///
/// Carrying the patient id keeps the audit log informative without
/// leaking PHI — the id is opaque elsewhere in the chart.
class ConsentDeniedException implements Exception {
  const ConsentDeniedException({
    required this.patientId,
    this.reason = 'ai_assistance_consent_missing',
  });

  /// Opaque patient identifier.
  final String patientId;

  /// Machine-readable reason code so analytics / dashboards can split
  /// the failure modes. Stays short and ASCII so it's safe to log.
  final String reason;

  @override
  String toString() =>
      'ConsentDeniedException(patientId=$patientId, reason=$reason)';
}

/// Lookup signature for per-kind consent entries — the Consent Center
/// stream that the patient can revoke from at any time.
typedef ConsentEntryLookup =
    ConsentEntry? Function(String patientId, ConsentKind kind);

/// Runtime gate that ensures consent-bound services (AI, audio
/// recording, telehealth) are only invoked for patients whose consent
/// is currently active.
///
/// The gate reads from TWO sources because we deliberately have two:
///   1. [ConsentRecord] — the intake-time aggregate captured during
///      onboarding ("did the patient tick AI assistance on the form?").
///   2. [ConsentEntry] of the matching [ConsentKind] — the live,
///      revoke-able stream the patient manages from the Consent
///      Center. Reading only #1 means a Consent Center revoke flips
///      the UI but the AI service keeps running (GDPR Art. 7(3) +
///      KVKK md. 11/1(e) violation). Reading only #2 means a fresh
///      intake without a Consent Center grant would deny AI; today
///      we still want intake-time consent to suffice for the legacy
///      flow.
///
/// **Union rule** — a kind is allowed iff:
///   * the intake-time gate passes for the kind (AI uses
///     `ConsentRecord.aiAssistanceConsent`; audio + telehealth have
///     no intake aggregate so they default to "pass" at this layer),
///     AND
///   * if a [ConsentEntry] lookup is configured: the active entry
///     for the matching [ConsentKind] must NOT be revoked. When no
///     lookup is configured (legacy callers) the entry check is
///     skipped — back-compat with pre-router code.
///
/// **Default policy** when no intake record is on file for AI: AI is
/// **denied** (GDPR Art. 7 / Art. 9(2)(a) — explicit "yes" required).
class ConsentGuard {
  ConsentGuard({
    ConsentRecord? Function(String patientId)? consentLookup,
    ConsentEntryLookup? consentEntryLookup,
  }) : _lookup = consentLookup ?? _denyLookup,
       _entryLookup = consentEntryLookup;

  /// Test / production constructor with a map-backed lookup — useful
  /// when the caller already has the consent records in memory and
  /// does not want a repository dependency.
  factory ConsentGuard.fromMap(
    Map<String, ConsentRecord?> consents, {
    ConsentEntryLookup? consentEntryLookup,
  }) {
    return ConsentGuard(
      consentLookup: (id) => consents[id],
      consentEntryLookup: consentEntryLookup,
    );
  }

  final ConsentRecord? Function(String patientId) _lookup;
  final ConsentEntryLookup? _entryLookup;

  static ConsentRecord? _denyLookup(String _) => null;

  /// True when the patient has granted AI-assistance consent at intake
  /// AND (if an entry lookup is configured) has NOT revoked the
  /// per-kind [ConsentKind.aiProcessing] from the Consent Center.
  bool aiAllowed(String patientId) =>
      _kindAllowed(patientId, ConsentKind.aiProcessing, _intakeAiOk);

  /// True when the patient has not revoked audio recording. The
  /// intake record has no aggregate toggle for this; the per-kind
  /// entry is the sole source. With no lookup configured, the gate
  /// is permissive (matches pre-Consent-Center behavior).
  bool audioAllowed(String patientId) =>
      _kindAllowed(patientId, ConsentKind.audioRecording, _alwaysOk);

  /// True when the patient has not revoked telehealth. Same shape as
  /// [audioAllowed].
  bool telehealthAllowed(String patientId) =>
      _kindAllowed(patientId, ConsentKind.telehealth, _alwaysOk);

  bool _intakeAiOk(String patientId) {
    final c = _lookup(patientId);
    if (c == null) return false;
    if (!c.isValid) return false;
    return c.aiAssistanceConsent;
  }

  bool _alwaysOk(String _) => true;

  /// Shared union-read logic. The intake gate must pass AND, if an
  /// entry lookup is configured, the per-kind entry must exist + be
  /// active. When no entry lookup is configured we fall back to the
  /// intake gate alone (back-compat with pre-router callers).
  bool _kindAllowed(
    String patientId,
    ConsentKind kind,
    bool Function(String) intakeGate,
  ) {
    if (!intakeGate(patientId)) return false;
    final lookup = _entryLookup;
    if (lookup == null) return true;
    final entry = lookup(patientId, kind);
    if (entry == null) return false;
    return entry.isActive;
  }

  /// Throws [ConsentDeniedException] when the AI gate denies. Call
  /// this at every entry point of an AI service so the caller does
  /// not have to repeat the boolean check.
  void requireAi(String patientId) {
    if (!aiAllowed(patientId)) {
      throw ConsentDeniedException(patientId: patientId);
    }
  }

  /// Throws [ConsentDeniedException] when audio recording is revoked.
  void requireAudio(String patientId) {
    if (!audioAllowed(patientId)) {
      throw ConsentDeniedException(
        patientId: patientId,
        reason: 'audio_recording_consent_revoked',
      );
    }
  }

  /// Throws [ConsentDeniedException] when telehealth consent is revoked.
  void requireTelehealth(String patientId) {
    if (!telehealthAllowed(patientId)) {
      throw ConsentDeniedException(
        patientId: patientId,
        reason: 'telehealth_consent_revoked',
      );
    }
  }
}
