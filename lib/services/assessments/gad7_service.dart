/// GAD-7 (Generalized Anxiety Disorder 7-item) — Spitzer, Kroenke, Williams &
/// Löwe (2006). Industry-standard anxiety severity screener.
class Gad7Service {
  Gad7Service._();
  static final Gad7Service instance = Gad7Service._();

  static const List<String> questions = [
    'Feeling nervous, anxious, or on edge',
    'Not being able to stop or control worrying',
    'Worrying too much about different things',
    'Trouble relaxing',
    'Being so restless that it is hard to sit still',
    'Becoming easily annoyed or irritable',
    'Feeling afraid as if something awful might happen',
  ];

  static const List<String> choices = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  Gad7Result score(List<int> answers) {
    assert(answers.length == 7, 'GAD-7 requires exactly 7 answers');
    final total = answers.fold<int>(0, (s, a) => s + a);
    return Gad7Result(
      total: total,
      severity: _bandFor(total),
      answers: List.unmodifiable(answers),
    );
  }

  Gad7Severity _bandFor(int total) {
    if (total <= 4) return Gad7Severity.minimal;
    if (total <= 9) return Gad7Severity.mild;
    if (total <= 14) return Gad7Severity.moderate;
    return Gad7Severity.severe;
  }
}

enum Gad7Severity { minimal, mild, moderate, severe }

extension Gad7SeverityX on Gad7Severity {
  String get label => switch (this) {
        Gad7Severity.minimal => 'None / Minimal',
        Gad7Severity.mild => 'Mild',
        Gad7Severity.moderate => 'Moderate',
        Gad7Severity.severe => 'Severe',
      };

  String get actionSuggestion => switch (this) {
        Gad7Severity.minimal => 'No intervention typically needed.',
        Gad7Severity.mild => 'Watchful waiting + psychoeducation.',
        Gad7Severity.moderate =>
          'Active treatment recommended (CBT and/or SSRI).',
        Gad7Severity.severe =>
          'Specialist referral or intensive treatment indicated.',
      };
}

class Gad7Result {
  Gad7Result({
    required this.total,
    required this.severity,
    required this.answers,
  });

  final int total;
  final Gad7Severity severity;
  final List<int> answers;
}
