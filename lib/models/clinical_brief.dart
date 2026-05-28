/// The synthesized pre-session "Clinical Memory" brief — what the clinician
/// needs to walk into a session prepared in 30 seconds, assembled from prior
/// notes, treatment goals, homework, risk history, and a safety plan.
/// Decision-support: it surfaces continuity, it does not direct care.
class ClinicalBrief {
  const ClinicalBrief({
    required this.patientName,
    required this.sessionCount,
    this.lastSessionAt,
    this.lastRecap,
    this.activeGoals = const [],
    this.homeworkOverdue = 0,
    this.homeworkPending = 0,
    this.hasSafetyPlan = false,
    this.riskNote,
    this.narrative,
    this.todos = const [],
  });

  final String patientName;
  final int sessionCount;
  final DateTime? lastSessionAt;
  final String? lastRecap;
  final List<String> activeGoals;
  final int homeworkOverdue;
  final int homeworkPending;
  final bool hasSafetyPlan;

  /// Set when a recent session flagged risk.
  final String? riskNote;

  /// Tier-2 (Claude) natural-language continuity narrative.
  final String? narrative;

  /// "Today, focus on" suggestions (deterministic defaults; enriched by AI).
  final List<String> todos;

  bool get isFirstSession => sessionCount == 0;

  ClinicalBrief copyWith({String? narrative, List<String>? todos}) =>
      ClinicalBrief(
        patientName: patientName,
        sessionCount: sessionCount,
        lastSessionAt: lastSessionAt,
        lastRecap: lastRecap,
        activeGoals: activeGoals,
        homeworkOverdue: homeworkOverdue,
        homeworkPending: homeworkPending,
        hasSafetyPlan: hasSafetyPlan,
        riskNote: riskNote,
        narrative: narrative ?? this.narrative,
        todos: todos ?? this.todos,
      );
}
