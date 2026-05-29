/// PHQ-9 (Patient Health Questionnaire-9) — the most widely used self-report
/// depression severity screener. Scoring per Kroenke, Spitzer & Williams (2001).
class Phq9Service {
  Phq9Service._();
  static final Phq9Service instance = Phq9Service._();

  /// The 9 question items, presented over the last 2 weeks.
  static const List<String> questions = [
    'Little interest or pleasure in doing things',
    'Feeling down, depressed, or hopeless',
    'Trouble falling or staying asleep, or sleeping too much',
    'Feeling tired or having little energy',
    'Poor appetite or overeating',
    'Feeling bad about yourself — or that you are a failure or have let yourself or your family down',
    'Trouble concentrating on things, such as reading the newspaper or watching television',
    'Moving or speaking so slowly that other people could have noticed? Or the opposite — being so fidgety or restless that you have been moving around a lot more than usual',
    'Thoughts that you would be better off dead, or of hurting yourself in some way',
  ];

  /// 4-point Likert (0..3): "Not at all" -> "Nearly every day".
  static const List<String> choices = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  /// Item 9 is the self-harm/suicide ideation question — any score >0 must be
  /// flagged and clinically reviewed regardless of total score.
  static const int selfHarmItemIndex = 8;

  Phq9Result score(List<int> answers) {
    assert(answers.length == 9, 'PHQ-9 requires exactly 9 answers');
    final total = answers.fold<int>(0, (s, a) => s + a);
    final selfHarmFlag = answers[selfHarmItemIndex] > 0;
    return Phq9Result(
      total: total,
      severity: _bandFor(total),
      selfHarmFlag: selfHarmFlag,
      answers: List.unmodifiable(answers),
    );
  }

  Phq9Severity _bandFor(int total) {
    if (total <= 4) return Phq9Severity.minimal;
    if (total <= 9) return Phq9Severity.mild;
    if (total <= 14) return Phq9Severity.moderate;
    if (total <= 19) return Phq9Severity.moderatelySevere;
    return Phq9Severity.severe;
  }
}

enum Phq9Severity { minimal, mild, moderate, moderatelySevere, severe }

extension Phq9SeverityX on Phq9Severity {
  String get label => switch (this) {
    Phq9Severity.minimal => 'None / Minimal',
    Phq9Severity.mild => 'Mild',
    Phq9Severity.moderate => 'Moderate',
    Phq9Severity.moderatelySevere => 'Moderately Severe',
    Phq9Severity.severe => 'Severe',
  };

  String get actionSuggestion => switch (this) {
    Phq9Severity.minimal => 'Monitor; may not require treatment.',
    Phq9Severity.mild => 'Watchful waiting; reassess at next visit.',
    Phq9Severity.moderate =>
      'Treatment plan; consider therapy, pharmacotherapy, or both.',
    Phq9Severity.moderatelySevere =>
      'Active treatment with pharmacotherapy and/or psychotherapy.',
    Phq9Severity.severe =>
      'Immediate initiation of treatment, consider hospitalization if active suicidality.',
  };
}

class Phq9Result {
  Phq9Result({
    required this.total,
    required this.severity,
    required this.selfHarmFlag,
    required this.answers,
  });

  final int total;
  final Phq9Severity severity;
  final bool selfHarmFlag;
  final List<int> answers;
}
