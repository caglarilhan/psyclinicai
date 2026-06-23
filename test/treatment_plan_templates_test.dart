/// Coverage for TreatmentPlanTemplate — full template catalogue
/// is present, `apply` materialises a draft TreatmentPlan with
/// correctly scoped IDs and review window, and `filter` finds
/// templates by modality + presentation.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/treatment_plan_models.dart';
import 'package:psyclinicai/services/treatment_plan_templates.dart';

void main() {
  group('TreatmentPlanTemplate catalogue', () {
    test('catalogue has six clinically scoped templates', () {
      expect(TreatmentPlanTemplate.all, hasLength(6));
      final ids = TreatmentPlanTemplate.all.map((t) => t.id).toSet();
      expect(
        ids,
        equals({
          'cbt-gad',
          'cbt-mdd',
          'dbt-emo',
          'emdr-ptsd',
          'family-couple',
          'family-parent-child',
        }),
      );
    });

    test('every template carries at least one goal and one intervention', () {
      for (final t in TreatmentPlanTemplate.all) {
        expect(t.goals, isNotEmpty, reason: 'goals: ${t.id}');
        expect(t.interventions, isNotEmpty, reason: 'interventions: ${t.id}');
      }
    });

    test('every template id is unique', () {
      final ids = TreatmentPlanTemplate.all.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('TreatmentPlanTemplate.apply', () {
    test('produces a draft plan with scoped goal + intervention ids', () {
      final t = TreatmentPlanTemplate.all.firstWhere((t) => t.id == 'cbt-gad');
      final now = DateTime.utc(2026, 6, 23, 12);
      final plan = t.apply(patientId: 'p1', clinicianId: 'c1', now: now);
      expect(plan.status, TreatmentPlanStatus.draft);
      expect(plan.patientId, 'p1');
      expect(plan.clinicianId, 'c1');
      expect(plan.primaryDiagnosis, 'Generalised Anxiety Disorder');
      // First template carries 3 goals — assertion above already
      // covers count, this just locks the diagnosis label.
      expect(plan.goals, hasLength(3));
      expect(plan.interventions, hasLength(3));
      expect(plan.reviewDate, now.add(const Duration(days: 84)));
      expect(plan.goals.first.id, startsWith('goal-'));
      expect(plan.interventions.first.id, startsWith('intv-'));
    });

    test('goal target dates follow the targetWeeks specification', () {
      final t = TreatmentPlanTemplate.all.firstWhere((t) => t.id == 'cbt-gad');
      final now = DateTime.utc(2026, 6, 23);
      final plan = t.apply(patientId: 'p1', clinicianId: 'c1', now: now);
      // First template goal in CBT-GAD: 12 weeks -> 84 days out.
      expect(plan.goals.first.targetDate, now.add(const Duration(days: 84)));
    });
  });

  group('TreatmentPlanTemplate.filter', () {
    test('filters by modality substring (case-insensitive)', () {
      expect(
        TreatmentPlanTemplate.filter(modality: 'cbt').map((t) => t.id).toSet(),
        equals({'cbt-gad', 'cbt-mdd'}),
      );
      expect(
        TreatmentPlanTemplate.filter(
          modality: 'FAMILY',
        ).map((t) => t.id).toSet(),
        containsAll({'family-couple', 'family-parent-child'}),
      );
    });

    test('filters by presentation substring', () {
      expect(
        TreatmentPlanTemplate.filter(presentation: 'PTSD').first.id,
        'emdr-ptsd',
      );
    });

    test('returns empty list when no match', () {
      expect(TreatmentPlanTemplate.filter(modality: 'unknown'), isEmpty);
    });
  });
}
