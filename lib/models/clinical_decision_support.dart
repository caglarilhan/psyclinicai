/// KRİTİK-3 (audit 2026-06-21) defensive envelope for AI-generated
/// clinical suggestions.
///
/// The audit flagged that `diagnosis_service` returns ICD-10 / DSM-5
/// codes with a `confidence: high` field. Regulators (FDA SaMD,
/// MDR 2017/745 Rule 11) read those outputs as a *diagnosis*, which
/// kicks the product into Class IIa device territory.
///
/// To stay in the CDSS carve-out (21st Century Cures §3060) every
/// AI-bound suggestion that surfaces clinical conclusions must be
/// wrapped in this envelope so the UI, the audit log, and any export
/// downstream all carry the same disclosure: this is decision support,
/// the licensed clinician is the decider, the suggestion is not a
/// diagnosis.
///
/// The Dart side wraps `DxCandidate` / `TreatmentSuggestion` etc.; the
/// JSON shape is verbose by design (every consumer should see the
/// disclosure even if they only read a subset of the fields).
library;

/// Risk class as it lines up with EU MDR Rule 11. `decisionSupportOnly`
/// is the safe default; the regulatory-classified surfaces (suicide
/// risk model, controlled-substance triage) bump up to `iia` / `iib`
/// once Cure53 + notified-body sign-off lands.
enum ClinicalRiskClass {
  /// Pure documentation aid — no clinical decision is recommended.
  decisionSupportOnly,

  /// Decision support that informs but does not drive clinical
  /// management (e.g. suggested ICD-10 codes for a finished note).
  cdss,

  /// MDR Rule 11 Class IIa — software intended to inform a decision.
  iia,

  /// MDR Rule 11 Class IIb — software intended to drive a decision in
  /// a way that could lead to serious deterioration of health.
  iib,
}

/// Envelope wrapping every AI clinical suggestion so the disclosure
/// stays attached to the data, not just the UI chrome around it.
class ClinicalDecisionSupport<T> {
  const ClinicalDecisionSupport({
    required this.suggestion,
    required this.modelId,
    required this.modelVersion,
    required this.generatedAt,
    this.riskClass = ClinicalRiskClass.decisionSupportOnly,
    this.disclaimer = _defaultDisclaimer,
    this.evidenceSpans = const [],
    this.requiresClinicianConfirmation = true,
  });

  /// The underlying suggestion (DxCandidate, TreatmentPlanDraft, …).
  final T suggestion;

  /// Identifier of the model that produced this suggestion. Logged for
  /// post-market surveillance (AI Act Art. 72).
  final String modelId;

  /// Specific revision / snapshot of the model. Captures prompt edits
  /// + tooling versions when present.
  final String modelVersion;

  /// Time the suggestion was produced. UTC ISO-8601 when serialised.
  final DateTime generatedAt;

  /// Regulatory risk class — see [ClinicalRiskClass].
  final ClinicalRiskClass riskClass;

  /// Human-facing disclosure. Defaults to a non-binding "AI suggestion"
  /// banner; services may override per modality.
  final String disclaimer;

  /// Spans / quotes from the source transcript that explain why the
  /// model made this suggestion. Empty by default; populated by
  /// services that build an explainability receipt (E5 of the roadmap).
  final List<String> evidenceSpans;

  /// When true, the UI MUST present a "Confirm" gesture before the
  /// suggestion is committed to the chart. AI Act Art. 14 oversight.
  final bool requiresClinicianConfirmation;

  static const String _defaultDisclaimer =
      'AI suggestion — for licensed clinician review. Not a diagnosis. '
      'Confirm before adding to the chart.';

  Map<String, dynamic> toJson() => {
        'kind': 'clinical_decision_support',
        'modelId': modelId,
        'modelVersion': modelVersion,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'riskClass': riskClass.name,
        'disclaimer': disclaimer,
        'evidenceSpans': evidenceSpans,
        'requiresClinicianConfirmation': requiresClinicianConfirmation,
        'suggestion': _serialiseSuggestion(),
      };

  dynamic _serialiseSuggestion() => _toJsonLike(suggestion);

  static dynamic _toJsonLike(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is List) {
      return value.map(_toJsonLike).toList(growable: false);
    }
    if (value is Map) {
      return value.map<String, dynamic>(
        (k, v) => MapEntry(k.toString(), _toJsonLike(v)),
      );
    }
    // Prefer a toJson() if the wrapped object defines one — otherwise
    // we fall back to toString() so the audit log never silently loses
    // the suggestion content.
    try {
      // ignore: avoid_dynamic_calls
      return _toJsonLike((value as dynamic).toJson() as Object?);
    } catch (_) {
      return value.toString();
    }
  }
}
