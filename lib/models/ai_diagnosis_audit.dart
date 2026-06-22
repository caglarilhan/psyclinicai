/// A PHI-free record that an AI diagnosis suggestion was generated,
/// shown to the clinician, and either accepted or overridden.
///
/// Stored to the audit log so an auditor can answer:
/// - Was an AI suggestion involved in this diagnosis?
/// - Which model produced it, and at what temperature?
/// - Which DSM-5-TR / ICD-10 sections were cited as the basis?
/// - Did the clinician keep, edit, or discard the suggestion?
///
/// The vignette text itself is **not** persisted here — that would smuggle
/// PHI past the BAA boundary. Free-text fields cap at 120 chars and must
/// be clinician-curated labels, never raw transcript chunks.
library;

/// What the clinician did with the suggestion. Captured so a future
/// "AI acceptance rate" dashboard can call out over-trust.
enum AiSuggestionDisposition {
  /// Surfaced but not yet acted on (timed out, navigation away).
  pending,

  /// Clinician kept the suggestion verbatim.
  accepted,

  /// Clinician edited the suggestion before keeping it.
  edited,

  /// Clinician explicitly discarded the suggestion.
  discarded;

  static AiSuggestionDisposition fromId(String? id) {
    for (final d in AiSuggestionDisposition.values) {
      if (d.name == id) return d;
    }
    return AiSuggestionDisposition.pending;
  }
}

class AiDiagnosisAudit {
  AiDiagnosisAudit({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.model,
    required this.temperature,
    required this.candidateLabel,
    required this.dsm5Code,
    required this.icd10Code,
    required this.criteriaMatched,
    required this.criteriaMissing,
    required this.citations,
    required this.disposition,
    required this.consentPolicyVersion,
    DateTime? createdAt,
  }) : assert(
         candidateLabel.length <= 120,
         'candidateLabel must be clinician-curated; raw PHI is forbidden',
       ),
       assert(
         consentPolicyVersion.length > 0,
         'consentPolicyVersion must be set — an AI audit row without '
         'consent context is invalid (GDPR Art. 7).',
       ),
       createdAt = (createdAt ?? DateTime.now()).toUtc();

  factory AiDiagnosisAudit.fromJson(Map<String, dynamic> json) =>
      AiDiagnosisAudit(
        id: json['id'] as String? ?? '',
        patientId: json['patient_id'] as String? ?? '',
        clinicianId: json['clinician_id'] as String? ?? '',
        model: json['model'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
        candidateLabel: json['candidate_label'] as String? ?? '',
        dsm5Code: json['dsm5_code'] as String? ?? '',
        icd10Code: json['icd10_code'] as String? ?? '',
        criteriaMatched: json['criteria_matched'] as int? ?? 0,
        criteriaMissing: json['criteria_missing'] as int? ?? 0,
        citations: (json['citations'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        disposition: AiSuggestionDisposition.fromId(
          json['disposition'] as String?,
        ),
        consentPolicyVersion:
            json['consent_policy_version'] as String? ?? 'unknown',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );

  /// Opaque event id (UUIDv4 in production).
  final String id;

  /// Opaque patient identifier — same one used elsewhere in the chart.
  final String patientId;

  /// Clinician who saw the suggestion.
  final String clinicianId;

  /// LLM name (e.g. `claude-haiku-4-5-20251001`). Stored verbatim so an
  /// auditor can match it against the provider's model card.
  final String model;

  /// Sampling temperature; 0 means deterministic. Stored at 2-decimal
  /// precision on the wire.
  final double temperature;

  /// Short clinician-curated label ("Recurrent MDD, moderate"). Not raw
  /// PHI. Asserts ≤120 chars at construction time.
  final String candidateLabel;

  /// DSM-5-TR code (e.g. "296.32"). Empty when none assigned yet.
  final String dsm5Code;

  /// ICD-10 code (e.g. "F33.1"). Empty when none assigned yet.
  final String icd10Code;

  /// Number of DSM-5-TR criteria the AI matched.
  final int criteriaMatched;

  /// Number of DSM-5-TR criteria still missing for a full diagnosis.
  final int criteriaMissing;

  /// References for every criterion the suggestion relied on — e.g.
  /// `["DSM-5-TR §296.32(A)", "DSM-5-TR §296.32(C)"]`. Required: an
  /// empty citation list invalidates the suggestion.
  final List<String> citations;

  /// What happened next.
  final AiSuggestionDisposition disposition;

  /// Privacy policy / consent template version active when the
  /// suggestion was surfaced. Required — an AI audit row without a
  /// consent context is meaningless under GDPR Art. 7. Stored as the
  /// YYYY-MM stamp copied from the patient's signed [ConsentRecord].
  final String consentPolicyVersion;

  /// UTC timestamp of the event.
  final DateTime createdAt;

  /// A suggestion is well-formed when it cites at least one source and
  /// has a non-empty candidate label. Used to block the UI from showing
  /// a suggestion with no provenance.
  bool get isWellFormed =>
      citations.isNotEmpty &&
      candidateLabel.trim().isNotEmpty &&
      (dsm5Code.isNotEmpty || icd10Code.isNotEmpty);

  AiDiagnosisAudit copyWith({AiSuggestionDisposition? disposition}) =>
      AiDiagnosisAudit(
        id: id,
        patientId: patientId,
        clinicianId: clinicianId,
        model: model,
        temperature: temperature,
        candidateLabel: candidateLabel,
        dsm5Code: dsm5Code,
        icd10Code: icd10Code,
        criteriaMatched: criteriaMatched,
        criteriaMissing: criteriaMissing,
        citations: citations,
        disposition: disposition ?? this.disposition,
        consentPolicyVersion: consentPolicyVersion,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'patient_id': patientId,
    'clinician_id': clinicianId,
    'model': model,
    'temperature': double.parse(temperature.toStringAsFixed(2)),
    'candidate_label': candidateLabel,
    'dsm5_code': dsm5Code,
    'icd10_code': icd10Code,
    'criteria_matched': criteriaMatched,
    'criteria_missing': criteriaMissing,
    'citations': citations,
    'disposition': disposition.name,
    'consent_policy_version': consentPolicyVersion,
    'created_at': createdAt.toUtc().toIso8601String(),
  };
}
