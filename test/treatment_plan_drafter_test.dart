/// Coverage for TreatmentPlanDrafter — template suggestion by
/// keyword scoring, AI-goal merge keeps template interventions
/// while replacing goals, empty inputs handled.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/treatment_plan_models.dart';
import 'package:psyclinicai/services/copilot/treatment_plan_ai_service.dart';
import 'package:psyclinicai/services/copilot/treatment_plan_drafter.dart';
import 'package:psyclinicai/services/treatment_plan_templates.dart';

void main() {
  const drafter = TreatmentPlanDrafter();

  group('suggestTemplate', () {
    test('GAD diagnosis suggests cbt-gad', () {
      final t = drafter.suggestTemplate(
        diagnosis: 'Generalised Anxiety Disorder',
        formulation: 'Persistent worry across multiple domains.',
      );
      expect(t?.id, 'cbt-gad');
    });

    test('PTSD diagnosis suggests emdr-ptsd', () {
      final t = drafter.suggestTemplate(
        diagnosis: 'PTSD with intrusive memories',
        formulation: 'Trauma history, flashbacks weekly.',
      );
      expect(t?.id, 'emdr-ptsd');
    });

    test('borderline / NSSI features suggest dbt-emo', () {
      final t = drafter.suggestTemplate(
        diagnosis: 'Emotion dysregulation, BPD traits',
        formulation: 'NSSI weekly, affect lability.',
      );
      expect(t?.id, 'dbt-emo');
    });

    test('couple relational distress suggests family-couple', () {
      final t = drafter.suggestTemplate(
        diagnosis: 'Couple relational distress',
        formulation: 'Pursue-withdraw cycle, partner conflict.',
      );
      expect(t?.id, 'family-couple');
    });

    test('empty input returns null', () {
      expect(drafter.suggestTemplate(diagnosis: ''), isNull);
    });

    test('no-match returns null', () {
      expect(
        drafter.suggestTemplate(diagnosis: 'xyzzy random nonsense words zzz'),
        isNull,
      );
    });
  });

  group('drafterMerge', () {
    test('keeps template interventions and replaces goals with AI goals', () {
      final template = TreatmentPlanTemplate.all.firstWhere(
        (t) => t.id == 'cbt-gad',
      );
      final aiGoals = [
        DraftGoal(
          description: 'Reduce GAD-7 by at least 5 points in 8 weeks.',
          category: GoalCategory.symptomReduction,
          priority: GoalPriority.high,
          measurement: 'Weekly GAD-7.',
          targetWeeks: 8,
        ),
      ];
      final plan = drafter.drafterMerge(
        template: template,
        aiGoals: aiGoals,
        patientId: 'p1',
        clinicianId: 'c1',
        now: DateTime.utc(2026, 6, 23),
      );
      expect(plan.goals.length, 1);
      expect(plan.goals.first.description, contains('GAD-7'));
      expect(plan.interventions.length, template.interventions.length);
      expect(plan.status, TreatmentPlanStatus.draft);
    });

    test('empty aiGoals leaves the template plan as-is', () {
      final template = TreatmentPlanTemplate.all.firstWhere(
        (t) => t.id == 'cbt-gad',
      );
      final plan = drafter.drafterMerge(
        template: template,
        aiGoals: const [],
        patientId: 'p1',
        clinicianId: 'c1',
        now: DateTime.utc(2026, 6, 23),
      );
      expect(plan.goals.length, template.goals.length);
    });
  });
}
