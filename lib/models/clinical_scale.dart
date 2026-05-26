/// Data-driven definition of a validated clinical rating scale (C-SSRS, PCL-5,
/// AUDIT, …). Keeps each instrument's items, per-item options, and scoring in
/// one auditable place so the runner UI stays generic. Decision-support — every
/// result tells the clinician what to review, never diagnoses.

enum ScaleSeverity { minimal, mild, moderate, severe, critical }

extension ScaleSeverityX on ScaleSeverity {
  String get label => switch (this) {
        ScaleSeverity.minimal => 'Minimal',
        ScaleSeverity.mild => 'Mild',
        ScaleSeverity.moderate => 'Moderate',
        ScaleSeverity.severe => 'Severe',
        ScaleSeverity.critical => 'Critical',
      };
}

/// One selectable answer with its point value (values differ per item on some
/// scales — e.g. AUDIT items 9–10 score 0/2/4).
class ScaleChoice {
  const ScaleChoice(this.label, this.value);
  final String label;
  final int value;
}

class ScaleQuestion {
  const ScaleQuestion(this.text, this.choices);
  final String text;
  final List<ScaleChoice> choices;
}

/// The scored outcome of a completed scale.
class ScaleResult {
  const ScaleResult({
    required this.total,
    required this.maxScore,
    required this.severity,
    required this.bandLabel,
    required this.guidance,
    this.riskFlag = false,
    this.riskFlagText,
  });

  final int total;
  final int maxScore;
  final ScaleSeverity severity;
  final String bandLabel;
  final String guidance;
  final bool riskFlag;
  final String? riskFlagText;
}

class ClinicalScale {
  const ClinicalScale({
    required this.id,
    required this.shortName,
    required this.title,
    required this.instructions,
    required this.questions,
    required this.scorer,
    this.referenceNote,
  });

  final String id;
  final String shortName;
  final String title;
  final String instructions;
  final List<ScaleQuestion> questions;
  final ScaleResult Function(List<int> answers) scorer;
  final String? referenceNote;

  int get itemCount => questions.length;

  ScaleResult score(List<int> answers) => scorer(answers);
}
