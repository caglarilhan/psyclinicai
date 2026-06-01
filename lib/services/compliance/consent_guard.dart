import '../../models/consent_record.dart';

/// Thrown when an AI-bound code path is invoked for a patient who has
/// not granted (or has withdrawn) AI-assistance consent.
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

/// Runtime gate that ensures AI-bound services are only invoked for
/// patients whose intake record explicitly grants
/// [ConsentRecord.aiAssistanceConsent].
///
/// The lookup is injected so unit tests can supply an in-memory map
/// without booting [IntakeRepository] / `SharedPreferences`. Production
/// callers wire the default lookup through the intake repository.
///
/// **Default policy** when a patient has no consent record on file: AI
/// is **denied**. We err on the side of GDPR Art. 7 / Art. 9(2)(a) and
/// require an explicit "yes" before any AI service runs.
class ConsentGuard {
  ConsentGuard({ConsentRecord? Function(String patientId)? consentLookup})
      : _lookup = consentLookup ?? _denyLookup;

  /// Test / production constructor with a map-backed lookup — useful
  /// when the caller already has the consent records in memory and
  /// does not want a repository dependency.
  factory ConsentGuard.fromMap(Map<String, ConsentRecord?> consents) {
    return ConsentGuard(consentLookup: (id) => consents[id]);
  }

  final ConsentRecord? Function(String patientId) _lookup;

  static ConsentRecord? _denyLookup(String _) => null;

  /// True when the patient has granted AI-assistance consent AND the
  /// surrounding consent record is itself well-formed (valid signature
  /// + non-empty policy version).
  bool aiAllowed(String patientId) {
    final c = _lookup(patientId);
    if (c == null) return false;
    if (!c.isValid) return false;
    return c.aiAssistanceConsent;
  }

  /// Throws [ConsentDeniedException] when the gate denies. Call this at
  /// every entry point of an AI service so the caller does not have to
  /// repeat the boolean check.
  void requireAi(String patientId) {
    if (!aiAllowed(patientId)) {
      throw ConsentDeniedException(patientId: patientId);
    }
  }
}
