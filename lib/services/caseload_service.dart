import '../models/homework_item.dart';
import '../models/safety_plan.dart';
import '../models/treatment_plan_models.dart';

/// Severity of a caseload attention signal. Drives sort order + colour.
enum AttentionLevel { high, medium, low }

/// One reason a patient surfaces on the caseload attention list.
class AttentionReason {
  const AttentionReason(this.label, this.level);
  final String label;
  final AttentionLevel level;
}

/// A patient who needs the clinician's attention, with the reasons why.
class CaseloadAttention {
  CaseloadAttention({
    required this.patientId,
    required this.patientName,
    required this.reasons,
  });

  final String patientId;
  final String patientName;
  final List<AttentionReason> reasons;

  /// Highest severity among the reasons.
  AttentionLevel get level {
    if (reasons.any((r) => r.level == AttentionLevel.high)) {
      return AttentionLevel.high;
    }
    if (reasons.any((r) => r.level == AttentionLevel.medium)) {
      return AttentionLevel.medium;
    }
    return AttentionLevel.low;
  }

  int get _score =>
      reasons.fold(0, (s, r) => s + _weight(r.level)) * 100 + reasons.length;

  static int _weight(AttentionLevel l) => switch (l) {
        AttentionLevel.high => 10000,
        AttentionLevel.medium => 100,
        AttentionLevel.low => 1,
      };
}

/// Aggregates per-patient clinical state across the local repositories into a
/// prioritised "who needs attention now" list. Pure + offline — the screen
/// passes in already-loaded data so this stays unit-testable.
///
/// This is the proactive caseload view EHRs lack: instead of opening each
/// chart, the clinician sees overdue work, stalled plans, and missing safety
/// plans at a glance. Decision-support — it surfaces, it does not act.
class CaseloadService {
  const CaseloadService();

  List<CaseloadAttention> compute({
    required Map<String, String> names,
    required List<HomeworkItem> homework,
    required List<TreatmentPlan> plans,
    required List<SafetyPlan> safetyPlans,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();

    final ids = <String>{
      ...homework.map((h) => h.patientId),
      ...plans.map((p) => p.patientId),
      ...safetyPlans.map((s) => s.patientId),
    }..removeWhere((e) => e.trim().isEmpty);

    final out = <CaseloadAttention>[];
    for (final id in ids) {
      final reasons = <AttentionReason>[];

      // 1 — overdue homework (assigned, past due, not done).
      final overdue = homework
          .where(
              (h) => h.patientId == id && !h.done && h.dueDate.isBefore(clock))
          .length;
      if (overdue > 0) {
        reasons.add(AttentionReason(
            '$overdue homework ${overdue == 1 ? 'task' : 'tasks'} overdue',
            AttentionLevel.high));
      }

      // 2 — active treatment plan signals.
      final activePlans = plans.where(
          (p) => p.patientId == id && p.status == TreatmentPlanStatus.active);
      final plan = activePlans.isEmpty ? null : activePlans.first;
      if (plan != null) {
        final ageDays = clock.difference(plan.createdAt).inDays;
        final pct = plan.overallProgress.round(); // overallProgress is 0–100
        if (plan.activeGoals.isNotEmpty &&
            plan.overallProgress < 20 &&
            ageDays > 14) {
          reasons.add(AttentionReason(
              'Treatment plan stalled ($pct%)', AttentionLevel.medium));
        }
        final reviewed = plan.updatedAt ?? plan.createdAt;
        final sinceReview = clock.difference(reviewed).inDays;
        if (sinceReview >= 30) {
          reasons.add(AttentionReason(
              'Plan not reviewed in ${sinceReview}d', AttentionLevel.medium));
        }
      }

      // 3 — active treatment plan but no safety plan on file.
      final safetyList = safetyPlans.where((s) => s.patientId == id);
      final hasSafety = safetyList.isNotEmpty && !safetyList.first.isEmpty;
      if (!hasSafety && plan != null) {
        reasons.add(const AttentionReason(
            'No safety plan on file', AttentionLevel.low));
      }

      if (reasons.isNotEmpty) {
        out.add(CaseloadAttention(
          patientId: id,
          patientName: names[id] ?? id,
          reasons: reasons,
        ));
      }
    }

    out.sort((a, b) {
      final c = b._score.compareTo(a._score);
      if (c != 0) return c;
      return a.patientName.toLowerCase().compareTo(b.patientName.toLowerCase());
    });
    return out;
  }
}
