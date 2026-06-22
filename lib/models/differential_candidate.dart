/// Structured DSM-5 / ICD-10 differential candidate emitted by the
/// AI Diagnosis screen (plan §23).
///
/// The model never represents an authoritative diagnosis — it surfaces
/// a clinician decision-support hint with the criteria it considered.
/// The clinician owns the final diagnosis (sticky disclaimer on the
/// screen).
///
/// Wire format (LLM output JSON) example:
/// ```json
/// {
///   "code": "F32.1",
///   "name": "Major depressive disorder, single episode, moderate",
///   "confidence": 0.72,
///   "criteriaMet": ["A.1 depressed mood", "A.2 anhedonia"],
///   "criteriaMissing": ["A.5 psychomotor agitation"],
///   "differentialFrom": ["F33.1 recurrent MDD", "F41.2 mixed anxiety-depressive"]
/// }
/// ```
class DifferentialCandidate {
  DifferentialCandidate({
    required this.code,
    required this.name,
    required this.confidence,
    required this.criteriaMet,
    required this.criteriaMissing,
    required this.differentialFrom,
  }) {
    if (code.isEmpty || name.isEmpty) {
      throw ArgumentError('DifferentialCandidate code/name are required.');
    }
    if (confidence < 0 || confidence > 1) {
      throw ArgumentError(
        'DifferentialCandidate.confidence must be in [0, 1] '
        '(got $confidence).',
      );
    }
  }

  factory DifferentialCandidate.fromJson(Map<String, dynamic> json) =>
      DifferentialCandidate(
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        confidence: (json['confidence'] as num? ?? 0).toDouble(),
        criteriaMet: _strList(json['criteriaMet']),
        criteriaMissing: _strList(json['criteriaMissing']),
        differentialFrom: _strList(json['differentialFrom']),
      );

  /// DSM-5 / ICD-10 code (e.g. `F32.1`, `296.22`).
  final String code;

  /// Human label as it appears on the chart ribbon.
  final String name;

  /// 0..1 confidence from the model. UI maps to a 4-band chip
  /// (`low` <0.25, `moderate` <0.5, `high` <0.75, `very high` ≥0.75).
  final double confidence;

  /// DSM-5 criteria the AI considered satisfied.
  final List<String> criteriaMet;

  /// Criteria still missing for a confident diagnosis.
  final List<String> criteriaMissing;

  /// Differential rule-out hints (other codes worth considering).
  final List<String> differentialFrom;

  /// 4-band confidence chip used by the UI.
  ConfidenceBand get band {
    if (confidence >= 0.75) return ConfidenceBand.veryHigh;
    if (confidence >= 0.5) return ConfidenceBand.high;
    if (confidence >= 0.25) return ConfidenceBand.moderate;
    return ConfidenceBand.low;
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'confidence': confidence,
    'criteriaMet': criteriaMet,
    'criteriaMissing': criteriaMissing,
    'differentialFrom': differentialFrom,
  };

  static List<String> _strList(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) => e.toString()).toList(growable: false);
  }
}

enum ConfidenceBand { low, moderate, high, veryHigh }
