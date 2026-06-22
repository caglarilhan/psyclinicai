import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/homework_item.dart';
import 'package:psyclinicai/models/safety_plan.dart';
import 'package:psyclinicai/models/treatment_plan_models.dart';
import 'package:psyclinicai/services/caseload_service.dart';

void main() {
  const service = CaseloadService();
  final now = DateTime(2026, 5, 26, 12);

  HomeworkItem hw(
    String patientId, {
    bool done = false,
    required DateTime due,
  }) => HomeworkItem(
    id: 'h-$patientId-${due.millisecondsSinceEpoch}',
    patientId: patientId,
    title: 'Task',
    dueDate: due,
    done: done,
  );

  TreatmentGoal goal(int progress) => TreatmentGoal(
    id: 'g',
    description: 'Reduce symptoms',
    category: GoalCategory.symptomReduction,
    priority: GoalPriority.high,
    targetDate: now.add(const Duration(days: 60)),
    progress: progress,
    createdAt: now,
  );

  TreatmentPlan plan(
    String patientId, {
    required DateTime createdAt,
    DateTime? updatedAt,
    List<TreatmentGoal> goals = const [],
  }) => TreatmentPlan(
    id: 'p-$patientId',
    patientId: patientId,
    clinicianId: 'c1',
    createdAt: createdAt,
    updatedAt: updatedAt,
    primaryDiagnosis: 'F41.1',
    clinicalFormulation: 'x',
    goals: goals,
  );

  test('flags overdue homework as high severity', () {
    final out = service.compute(
      names: {'p1': 'Alice'},
      homework: [hw('p1', due: now.subtract(const Duration(days: 2)))],
      plans: const [],
      safetyPlans: const [],
      now: now,
    );
    expect(out, hasLength(1));
    expect(out.first.patientName, 'Alice');
    expect(out.first.level, AttentionLevel.high);
    expect(out.first.reasons.any((r) => r.label.contains('overdue')), isTrue);
  });

  test('ignores done and not-yet-due homework', () {
    final out = service.compute(
      names: const {},
      homework: [
        hw('p1', done: true, due: now.subtract(const Duration(days: 5))),
        hw('p2', due: now.add(const Duration(days: 3))),
      ],
      plans: const [],
      safetyPlans: const [],
      now: now,
    );
    expect(out, isEmpty);
  });

  test('flags a stalled treatment plan (low progress, aged) as medium', () {
    final out = service.compute(
      names: const {},
      homework: const [],
      plans: [
        plan(
          'p1',
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now.subtract(const Duration(days: 2)),
          goals: [goal(10)],
        ),
      ],
      safetyPlans: const [],
      now: now,
    );
    expect(out, hasLength(1));
    expect(out.first.reasons.any((r) => r.label.contains('stalled')), isTrue);
    // active plan + no safety plan => the low "no safety plan" reason too.
    expect(out.first.reasons.any((r) => r.label.contains('safety')), isTrue);
  });

  test('flags a plan not reviewed in 30+ days', () {
    final out = service.compute(
      names: const {},
      homework: const [],
      plans: [
        plan(
          'p1',
          createdAt: now.subtract(const Duration(days: 45)),
          goals: [goal(60)],
        ), // progressed → not "stalled"
      ],
      safetyPlans: const [],
      now: now,
    );
    expect(
      out.first.reasons.any((r) => r.label.contains('not reviewed')),
      isTrue,
    );
    expect(out.first.reasons.any((r) => r.label.contains('stalled')), isFalse);
  });

  test('a present safety plan suppresses the no-safety reason', () {
    final out = service.compute(
      names: const {},
      homework: const [],
      plans: [
        plan(
          'p1',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
          goals: [goal(60)],
        ),
      ],
      safetyPlans: [
        SafetyPlan(patientId: 'p1', warningSigns: const ['feeling low']),
      ],
      now: now,
    );
    // recent, progressed plan with a safety plan => nothing to flag.
    expect(out, isEmpty);
  });

  test('sorts high-severity patients before lower ones', () {
    final out = service.compute(
      names: const {'p1': 'Low', 'p2': 'High'},
      homework: [hw('p2', due: now.subtract(const Duration(days: 1)))],
      plans: [
        plan(
          'p1',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
          goals: [goal(60)],
        ), // only low "no safety plan"
      ],
      safetyPlans: const [],
      now: now,
    );
    expect(out, hasLength(2));
    expect(out.first.patientName, 'High');
    expect(out.first.level, AttentionLevel.high);
    expect(out.last.level, AttentionLevel.low);
  });

  test('falls back to patient id when name is unknown', () {
    final out = service.compute(
      names: const {},
      homework: [hw('p9', due: now.subtract(const Duration(days: 1)))],
      plans: const [],
      safetyPlans: const [],
      now: now,
    );
    expect(out.first.patientName, 'p9');
  });
}
