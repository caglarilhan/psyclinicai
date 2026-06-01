/// Renders the optional SMART fields (baseline / target / achievable /
/// relevant) into a single markdown block stored on
/// [TreatmentGoal.notes].
///
/// Sections without content are omitted so the note stays readable and the
/// downstream PDF export does not surface empty labels. Strings are
/// trimmed; whitespace-only values count as empty.
///
/// Pure function — kept out of the widget tree so it can be unit-tested
/// without booting Flutter.
library;

String formatSmartGoalNotes({
  String baseline = '',
  String target = '',
  String achievability = '',
  String relevance = '',
}) {
  final lines = <String>[];
  void addLine(String label, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    lines.add('**$label:** $trimmed');
  }

  addLine('Baseline', baseline);
  addLine('Target', target);
  addLine('Achievable', achievability);
  addLine('Relevant', relevance);
  return lines.join('\n');
}
