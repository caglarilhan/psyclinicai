/// Composes treatment-plan templates (PR #25) with AI-drafted
/// goals (existing TreatmentPlanAiService) to produce a draft
/// `TreatmentPlan` that already has the bulk of the scaffold +
/// AI-personalised goals layered on top.
///
/// Two stages:
///   1. `suggestTemplate(diagnosis, formulation)` — pure heuristic
///      that picks the closest-matching curated template based on
///      keyword overlap. No AI call, no PHI off-device.
///   2. `drafterMerge(template, aiGoals)` — pure helper that
///      merges AI-drafted goals into the chosen template's plan
///      (AI goals + template interventions = personalised plan).
library;

import '../../models/treatment_plan_models.dart';
import '../treatment_plan_templates.dart';
import 'treatment_plan_ai_service.dart';

class TreatmentPlanDrafter {
  const TreatmentPlanDrafter();

  /// Picks the curated template whose modality + presentation best
  /// matches the clinician's intake. Pure keyword scoring — no AI
  /// call. Returns null when nothing scores above the floor.
  TreatmentPlanTemplate? suggestTemplate({
    required String diagnosis,
    String formulation = '',
  }) {
    final haystack = '${diagnosis.toLowerCase()} ${formulation.toLowerCase()}';
    if (haystack.trim().isEmpty) return null;
    final best = <_Scored>[];
    for (final t in TreatmentPlanTemplate.all) {
      final score = _score(haystack, t);
      if (score > 0) best.add(_Scored(t, score));
    }
    if (best.isEmpty) return null;
    best.sort((a, b) => b.score.compareTo(a.score));
    return best.first.template;
  }

  int _score(String haystack, TreatmentPlanTemplate t) {
    var s = 0;
    s += _kw(haystack, t.targetPresentation.toLowerCase());
    s += _kw(haystack, t.modality.toLowerCase());
    for (final tag in _diagnosisKeywords[t.id] ?? const <String>[]) {
      if (haystack.contains(tag)) s += 3;
    }
    return s;
  }

  /// 1 point per matching word >= 4 letters.
  int _kw(String hay, String needle) {
    var s = 0;
    for (final w in needle.split(RegExp(r'\W+'))) {
      if (w.length >= 4 && hay.contains(w)) s++;
    }
    return s;
  }

  /// Per-template diagnosis tag list.
  static const _diagnosisKeywords = <String, List<String>>{
    'cbt-gad': ['gad', 'anxiety', 'worry', 'rumination'],
    'cbt-mdd': ['mdd', 'depression', 'depressive', 'phq'],
    'dbt-emo': ['bpd', 'borderline', 'self-harm', 'nssi', 'dysregulation'],
    'emdr-ptsd': ['ptsd', 'trauma', 'pcl', 'flashback'],
    'family-couple': ['couple', 'marital', 'partner', 'relationship'],
    'family-parent-child': ['parent', 'child', 'family conflict'],
  };

  /// Merge AI-drafted goals into the chosen template's plan. The
  /// template's interventions stay (they are modality-specific);
  /// the AI goals replace the template's generic goal scaffold so
  /// the clinician sees patient-specific language.
  TreatmentPlan drafterMerge({
    required TreatmentPlanTemplate template,
    required List<DraftGoal> aiGoals,
    required String patientId,
    required String clinicianId,
    DateTime? now,
  }) {
    final plan = template.apply(
      patientId: patientId,
      clinicianId: clinicianId,
      now: now,
    );
    if (aiGoals.isEmpty) return plan;
    final created = now ?? DateTime.now().toUtc();
    final goals = <TreatmentGoal>[
      for (var i = 0; i < aiGoals.length; i++)
        TreatmentGoal(
          id: 'ai-goal-${created.microsecondsSinceEpoch}-$i',
          description: aiGoals[i].description,
          category: aiGoals[i].category,
          priority: aiGoals[i].priority,
          targetDate: created.add(Duration(days: aiGoals[i].targetWeeks * 7)),
          createdAt: created,
          measurementMethod: aiGoals[i].measurement,
        ),
    ];
    return TreatmentPlan(
      id: plan.id,
      patientId: plan.patientId,
      clinicianId: plan.clinicianId,
      createdAt: plan.createdAt,
      primaryDiagnosis: plan.primaryDiagnosis,
      clinicalFormulation: plan.clinicalFormulation,
      goals: goals,
      interventions: plan.interventions,
      prognosis: plan.prognosis,
      reviewDate: plan.reviewDate,
      status: plan.status,
    );
  }
}

class _Scored {
  const _Scored(this.template, this.score);
  final TreatmentPlanTemplate template;
  final int score;
}
