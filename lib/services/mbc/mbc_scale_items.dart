import '../assessments/clinical_scales.dart';
import '../assessments/gad7_service.dart';
import '../assessments/phq9_service.dart';

/// Resolves the question + choice arrays the patient form renders for
/// each MBC scale. Re-uses the validated wordings already pinned in
/// the existing scale services / `ClinicalScales` registry so the
/// patient sees exactly what the clinician-side form shows.
///
/// The arrays are positional: `answers[i]` of the submitted vector
/// maps to `questions[i]`; the choice score is the array index.
class MbcScaleItems {
  const MbcScaleItems._();

  /// Returns `(questions, choices)` for a scaleId. Throws when the
  /// scale is not part of the MBC public-submit surface.
  static (List<String>, List<String>) forScale(String scaleId) {
    switch (scaleId) {
      case 'phq9':
        return (Phq9Service.questions, Phq9Service.choices);
      case 'gad7':
        return (Gad7Service.questions, Gad7Service.choices);
      case 'who5':
        return (_who5Questions, _who5Choices);
      case 'audit':
        final s = ClinicalScales.audit;
        return (
          s.questions.map((q) => q.text).toList(),
          // AUDIT has per-question choices, but 9 of 10 share `_freq5Audit`.
          // For the patient form (single-column choice column) we surface
          // the first question's choices as the canonical 5-point ladder.
          s.questions.first.choices.map((c) => c.label).toList(),
        );
      case 'pcl5':
        final s = ClinicalScales.pcl5;
        return (
          s.questions.map((q) => q.text).toList(),
          s.questions.first.choices.map((c) => c.label).toList(),
        );
      default:
        throw StateError('No MBC item map for scaleId=$scaleId');
    }
  }

  /// WHO-5 wellbeing — 5 items, 6-point Likert "at no time" → "all of the time".
  /// The catalog's per-item range is `[0..5]`; server scoring multiplies by 4.
  static const List<String> _who5Questions = [
    'I have felt cheerful and in good spirits',
    'I have felt calm and relaxed',
    'I have felt active and vigorous',
    'I woke up feeling fresh and rested',
    'My daily life has been filled with things that interest me',
  ];

  static const List<String> _who5Choices = [
    'At no time',
    'Some of the time',
    'Less than half of the time',
    'More than half of the time',
    'Most of the time',
    'All of the time',
  ];
}
