/// A de-identified supervision report for a session — fidelity to the chosen
/// modality, strengths, growth areas, and reflective questions for a trainee.
/// Built for academic / clinical supervision (the B2B training wedge).
///
/// SAFETY: this is meant to be shareable with a supervisor, so it must contain
/// NO client-identifying information. The generating prompt de-identifies, and
/// the clinician confirms anonymization before sharing. Decision-support for
/// supervision — not a competency or licensure determination.
class SupervisionReport {
  const SupervisionReport({
    required this.modalityLabel,
    required this.fidelityScore,
    required this.fidelityNotes,
    this.strengths = const [],
    this.growthAreas = const [],
    this.reflectiveQuestions = const [],
    this.summary = '',
  });

  final String modalityLabel;

  /// 0–100 adherence to the selected modality's evidence-based method.
  final int fidelityScore;
  final String fidelityNotes;
  final List<String> strengths;
  final List<String> growthAreas;
  final List<String> reflectiveQuestions;
  final String summary;

  /// Plain-text, de-identified report for copy/export to a supervisor.
  String anonymizedText() {
    final b = StringBuffer()
      ..writeln('SUPERVISION REPORT (de-identified) — $modalityLabel')
      ..writeln('Modality fidelity: $fidelityScore/100')
      ..writeln();
    if (summary.isNotEmpty) {
      b
        ..writeln(summary)
        ..writeln();
    }
    if (fidelityNotes.isNotEmpty) {
      b
        ..writeln('Fidelity: $fidelityNotes')
        ..writeln();
    }
    void section(String title, List<String> items) {
      if (items.isEmpty) return;
      b.writeln('$title:');
      for (final i in items) {
        b.writeln('  - $i');
      }
      b.writeln();
    }

    section('Strengths', strengths);
    section('Growth areas', growthAreas);
    section('Reflective questions', reflectiveQuestions);
    b.writeln(
      'Decision-support for supervision — not a competency '
      'determination. Verify anonymization before sharing.',
    );
    return b.toString().trimRight();
  }
}
