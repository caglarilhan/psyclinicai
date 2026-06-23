/// Curated TreatmentPlan templates — pre-filled goal + intervention
/// scaffolds for the six modality / presenting-problem pairs that
/// drive the most plans in our caseload. Each template is a
/// starting point; the clinician customises before saving.
///
/// Templates pair with the modality vocabulary shipped in PRs #5
/// (CBT/DBT/EMDR) and #18 (family). Adding a template means adding
/// one entry to [TreatmentPlanTemplate.all]; no schema changes.
library;

import '../models/treatment_plan_models.dart';

/// A named template that materialises into a draft TreatmentPlan
/// for the given (patient, clinician). The clinician then edits
/// before saving — templates are scaffolds, not recipes.
class TreatmentPlanTemplate {
  const TreatmentPlanTemplate({
    required this.id,
    required this.label,
    required this.modality,
    required this.targetPresentation,
    required this.clinicalFormulation,
    required this.goals,
    required this.interventions,
    this.prognosis,
  });

  final String id;

  /// Short display label used in the template picker. Keep under
  /// ~40 chars so it fits on a chip without truncating.
  final String label;

  /// Therapy modality the template is built around. Free-text on
  /// purpose — templates can be CBT-only or hybrid (e.g.
  /// "CBT + medication").
  final String modality;

  /// What presenting problem the template targets — anxiety,
  /// depression, PTSD, couple distress, etc.
  final String targetPresentation;

  final String clinicalFormulation;
  final List<TemplateGoalSpec> goals;
  final List<TemplateInterventionSpec> interventions;
  final String? prognosis;

  /// Materialise into a draft [TreatmentPlan] for the supplied
  /// patient + clinician. The plan is created in `draft` status so
  /// the clinician must explicitly activate it after review.
  TreatmentPlan apply({
    required String patientId,
    required String clinicianId,
    DateTime? now,
  }) {
    final created = now ?? DateTime.now().toUtc();
    final reviewDate = created.add(const Duration(days: 84));
    return TreatmentPlan(
      id: 'plan-${created.microsecondsSinceEpoch}-$patientId',
      patientId: patientId,
      clinicianId: clinicianId,
      createdAt: created,
      primaryDiagnosis: targetPresentation,
      clinicalFormulation: clinicalFormulation,
      goals: [
        for (var i = 0; i < goals.length; i++)
          goals[i].toGoal(
            id: 'goal-${created.microsecondsSinceEpoch}-$i',
            createdAt: created,
          ),
      ],
      interventions: [
        for (var i = 0; i < interventions.length; i++)
          interventions[i].toIntervention(
            id: 'intv-${created.microsecondsSinceEpoch}-$i',
            startDate: created,
          ),
      ],
      prognosis: prognosis,
      reviewDate: reviewDate,
      // Templates are scaffolds — the clinician must edit and
      // activate explicitly before the plan goes live.
      status: TreatmentPlanStatus.draft,
    );
  }

  /// Filter templates by modality (case-insensitive substring match)
  /// or presenting problem.
  static List<TreatmentPlanTemplate> filter({
    String? modality,
    String? presentation,
  }) {
    return all.where((t) {
      if (modality != null &&
          !t.modality.toLowerCase().contains(modality.toLowerCase())) {
        return false;
      }
      if (presentation != null &&
          !t.targetPresentation.toLowerCase().contains(
            presentation.toLowerCase(),
          )) {
        return false;
      }
      return true;
    }).toList();
  }

  static const all = <TreatmentPlanTemplate>[
    TreatmentPlanTemplate(
      id: 'cbt-gad',
      label: 'CBT — Generalised anxiety',
      modality: 'CBT',
      targetPresentation: 'Generalised Anxiety Disorder',
      clinicalFormulation:
          'Excessive worry across multiple domains maintained by '
          'cognitive avoidance, intolerance of uncertainty, and '
          'safety-seeking behaviour. Beck/Padesky cognitive model — '
          'thought records + behavioural experiments + worry exposure.',
      goals: [
        TemplateGoalSpec(
          description: 'Reduce GAD-7 score by at least 5 points.',
          category: GoalCategory.symptomReduction,
          priority: GoalPriority.high,
          targetWeeks: 12,
          measurement: 'Weekly GAD-7 administered in session.',
        ),
        TemplateGoalSpec(
          description:
              'Identify and challenge five core worry-related '
              'distortions using the 7-column thought record.',
          category: GoalCategory.skillDevelopment,
          priority: GoalPriority.high,
          targetWeeks: 6,
          measurement: 'Completed thought records reviewed weekly.',
        ),
        TemplateGoalSpec(
          description:
              'Resume one avoided activity per week without safety '
              'behaviour.',
          category: GoalCategory.functionalImprovement,
          priority: GoalPriority.medium,
          targetWeeks: 10,
          measurement: 'Activity log + behavioural-experiment notes.',
        ),
      ],
      interventions: [
        TemplateInterventionSpec(
          name: 'CBT psychoeducation — worry cycle',
          type: InterventionType.psychoeducation,
          description:
              'Explain the maintenance cycle: trigger → worry → '
              'avoidance → relief → worry rebound.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
        ),
        TemplateInterventionSpec(
          name: 'Beck/Padesky thought record',
          type: InterventionType.cognitiveIntervention,
          description:
              'Capture automatic thoughts, tag distortions (Burns 10), '
              'restructure into balanced thoughts.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
          instructions: 'Use the in-app CBT panel.',
        ),
        TemplateInterventionSpec(
          name: 'Worry exposure / behavioural experiment',
          type: InterventionType.behavioralIntervention,
          description:
              'Graded confrontation of feared outcomes; record '
              'prediction, observation, takeaway.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
        ),
      ],
      prognosis:
          'Good — GAD-7 reductions of 5+ points in 12 weeks are '
          'typical with consistent thought-record + exposure work.',
    ),

    TreatmentPlanTemplate(
      id: 'cbt-mdd',
      label: 'CBT — Major depression',
      modality: 'CBT',
      targetPresentation: 'Major Depressive Disorder',
      clinicalFormulation:
          'Cognitive triad (self / world / future) maintained by '
          'rumination + behavioural withdrawal. Beck CBT — behavioural '
          'activation paired with cognitive restructuring.',
      goals: [
        TemplateGoalSpec(
          description: 'Reduce PHQ-9 score by at least 5 points.',
          category: GoalCategory.symptomReduction,
          priority: GoalPriority.high,
          targetWeeks: 12,
          measurement: 'Weekly PHQ-9.',
        ),
        TemplateGoalSpec(
          description:
              'Complete three values-aligned pleasure / mastery '
              'activities per week.',
          category: GoalCategory.functionalImprovement,
          priority: GoalPriority.high,
          targetWeeks: 8,
          measurement: 'Activity scheduling log.',
        ),
      ],
      interventions: [
        TemplateInterventionSpec(
          name: 'Behavioural activation',
          type: InterventionType.behavioralIntervention,
          description:
              'Graded scheduling of pleasure + mastery activities; '
              'pre / post mood ratings.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
        ),
        TemplateInterventionSpec(
          name: 'Cognitive restructuring of depressive thoughts',
          type: InterventionType.cognitiveIntervention,
          description:
              'Thought record focused on hopelessness, worthlessness, '
              'and helplessness themes.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
        ),
      ],
    ),

    TreatmentPlanTemplate(
      id: 'dbt-emo',
      label: 'DBT — Emotion dysregulation',
      modality: 'DBT',
      targetPresentation: 'Emotion dysregulation (BPD spectrum)',
      clinicalFormulation:
          'Biosocial model — emotional vulnerability + invalidating '
          'environment producing affect lability, interpersonal chaos, '
          'and impulsive coping. Standard four-module DBT (mindfulness, '
          'distress tolerance, emotion regulation, interpersonal '
          'effectiveness).',
      goals: [
        TemplateGoalSpec(
          description:
              'Eliminate target behaviours (SI / NSSI / TIB) for four '
              'consecutive weeks.',
          category: GoalCategory.crisisPrevention,
          priority: GoalPriority.critical,
          targetWeeks: 16,
          measurement: 'Diary card weekly review.',
        ),
        TemplateGoalSpec(
          description:
              'Demonstrate use of at least one DBT skill from each '
              'of the four modules.',
          category: GoalCategory.skillDevelopment,
          priority: GoalPriority.high,
          targetWeeks: 12,
          measurement: 'Skills tracking on weekly diary card.',
        ),
      ],
      interventions: [
        TemplateInterventionSpec(
          name: 'Weekly diary card review',
          type: InterventionType.psychotherapy,
          description:
              'Linehan diary card: target behaviours, emotions 0-5, '
              'skills practised. Reviewed at session start.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
          instructions: 'Use the in-app DBT panel.',
        ),
        TemplateInterventionSpec(
          name: 'DBT skills group (or 1:1 skills coaching)',
          type: InterventionType.groupTherapy,
          description:
              '24-week curriculum across the four modules. 1:1 '
              'coaching when group not available.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 90,
        ),
        TemplateInterventionSpec(
          name: 'Phone coaching for crisis',
          type: InterventionType.behavioralIntervention,
          description:
              'Brief between-session calls for skill generalisation '
              'during high-distress moments.',
          frequency: InterventionFrequency.asNeeded,
          durationMinutes: 15,
        ),
      ],
      prognosis:
          'Good with full 12-month standard DBT; partial DBT often '
          'reduces SI/NSSI within 4-6 months.',
    ),

    TreatmentPlanTemplate(
      id: 'emdr-ptsd',
      label: 'EMDR — PTSD',
      modality: 'EMDR',
      targetPresentation: 'Post-Traumatic Stress Disorder (PTSD)',
      clinicalFormulation:
          'Adaptive Information Processing (AIP) model — unprocessed '
          'memory networks driving intrusion, avoidance, hyperarousal. '
          'Shapiro 8-phase protocol with stabilisation gate.',
      goals: [
        TemplateGoalSpec(
          description: 'Reduce PCL-5 score below clinical cutoff (33).',
          category: GoalCategory.symptomReduction,
          priority: GoalPriority.high,
          targetWeeks: 16,
          measurement: 'Monthly PCL-5.',
        ),
        TemplateGoalSpec(
          description:
              'Process index trauma to SUDS at most 1 and VOC at '
              'least 6.',
          category: GoalCategory.symptomReduction,
          priority: GoalPriority.critical,
          targetWeeks: 12,
          measurement: 'EMDR session tracker SUDS / VOC ratings.',
        ),
      ],
      interventions: [
        TemplateInterventionSpec(
          name: 'Stabilisation + resource installation (Phase 2)',
          type: InterventionType.behavioralIntervention,
          description:
              'Calm-place install + resource build before any '
              'reprocessing. Closure-safe gate must pass.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 50,
        ),
        TemplateInterventionSpec(
          name: 'EMDR reprocessing (Phases 3-6)',
          type: InterventionType.psychotherapy,
          description:
              'Assessment + desensitisation + installation + body scan '
              'across BLS sets. SUDS 0 / VOC 7 target per session.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 90,
          instructions: 'Use the in-app EMDR panel.',
        ),
      ],
    ),

    TreatmentPlanTemplate(
      id: 'family-couple',
      label: 'Family — Couple distress',
      modality: 'Family / Couples',
      targetPresentation: 'Couple relational distress',
      clinicalFormulation:
          'Gottman / EFT-informed couples work — negative cycle '
          'identification, attachment-injury repair, communication '
          'and conflict-management skills.',
      goals: [
        TemplateGoalSpec(
          description:
              "Identify and de-escalate the couple's primary "
              'negative cycle.',
          category: GoalCategory.relationshipImprovement,
          priority: GoalPriority.high,
          targetWeeks: 8,
          measurement: 'Session relational shift rating (0-10).',
        ),
        TemplateGoalSpec(
          description:
              'Reduce conflict-related distress with at least three '
              'shared skills (time-out, soft start-up, repair attempt).',
          category: GoalCategory.skillDevelopment,
          priority: GoalPriority.high,
          targetWeeks: 12,
          measurement: 'Family session notes + homework log.',
        ),
      ],
      interventions: [
        TemplateInterventionSpec(
          name: 'Couple session — joining + cycle mapping',
          type: InterventionType.familyTherapy,
          description:
              "Map the couple's primary negative cycle (pursue / "
              'withdraw etc.); externalise the pattern.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 60,
        ),
        TemplateInterventionSpec(
          name: 'Attachment-injury repair conversation',
          type: InterventionType.familyTherapy,
          description:
              'Guided structured conversation about a specific '
              'attachment injury; partner-mirroring + repair attempt.',
          frequency: InterventionFrequency.biweekly,
          durationMinutes: 90,
        ),
      ],
    ),

    TreatmentPlanTemplate(
      id: 'family-parent-child',
      label: 'Family — Parent-child conflict',
      modality: 'Family',
      targetPresentation: 'Parent-child conflict',
      clinicalFormulation:
          'Structural / Bowen-informed work — boundary clarification, '
          'differentiation prompts, parent coaching. Genogram links '
          'session notes to multigenerational patterns when present.',
      goals: [
        TemplateGoalSpec(
          description:
              'Reduce intensity of parent-child conflict episodes by '
              'at least 50% (self-report).',
          category: GoalCategory.relationshipImprovement,
          priority: GoalPriority.high,
          targetWeeks: 12,
          measurement: 'Weekly conflict frequency + intensity log.',
        ),
        TemplateGoalSpec(
          description:
              'Parent demonstrates two effective differentiation '
              'strategies in session.',
          category: GoalCategory.skillDevelopment,
          priority: GoalPriority.medium,
          targetWeeks: 10,
          measurement: 'In-session observation by clinician.',
        ),
      ],
      interventions: [
        TemplateInterventionSpec(
          name: 'Family session — structural mapping',
          type: InterventionType.familyTherapy,
          description:
              'Identify enmeshment / disengagement; introduce boundary '
              'language; coach parent stance shifts.',
          frequency: InterventionFrequency.weekly,
          durationMinutes: 60,
        ),
        TemplateInterventionSpec(
          name: 'Parent coaching',
          type: InterventionType.psychoeducation,
          description:
              'Solo parent session(s) for skill rehearsal: '
              'differentiation, validation, boundary maintenance.',
          frequency: InterventionFrequency.biweekly,
          durationMinutes: 50,
        ),
      ],
    ),
  ];
}

class TemplateGoalSpec {
  const TemplateGoalSpec({
    required this.description,
    required this.category,
    required this.priority,
    required this.targetWeeks,
    required this.measurement,
  });
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final int targetWeeks;
  final String measurement;

  TreatmentGoal toGoal({required String id, required DateTime createdAt}) {
    return TreatmentGoal(
      id: id,
      description: description,
      category: category,
      priority: priority,
      targetDate: createdAt.add(Duration(days: targetWeeks * 7)),
      createdAt: createdAt,
      measurementMethod: measurement,
    );
  }
}

class TemplateInterventionSpec {
  const TemplateInterventionSpec({
    required this.name,
    required this.type,
    required this.description,
    required this.frequency,
    required this.durationMinutes,
    this.instructions,
  });
  final String name;
  final InterventionType type;
  final String description;
  final InterventionFrequency frequency;
  final int durationMinutes;
  final String? instructions;

  TreatmentIntervention toIntervention({
    required String id,
    required DateTime startDate,
  }) {
    return TreatmentIntervention(
      id: id,
      name: name,
      type: type,
      description: description,
      frequency: frequency,
      duration: Duration(minutes: durationMinutes),
      instructions: instructions,
      startDate: startDate,
    );
  }
}
