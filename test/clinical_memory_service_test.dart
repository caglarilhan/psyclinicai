import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/homework_item.dart';
import 'package:psyclinicai/models/session_note.dart';
import 'package:psyclinicai/models/treatment_plan_models.dart';
import 'package:psyclinicai/services/copilot/clinical_memory_service.dart';

void main() {
  final svc = ClinicalMemoryService();
  final now = DateTime(2026, 5, 28, 9);

  SessionNote note(int daysAgo, {bool risk = false, String text = 'note'}) =>
      SessionNote(
        id: 'n$daysAgo',
        patientId: 'p1',
        markdown: text,
        flaggedRisk: risk,
        createdAt: now.subtract(Duration(days: daysAgo)),
      );

  HomeworkItem hw({bool done = false, required DateTime due}) => HomeworkItem(
      id: 'h${due.millisecondsSinceEpoch}',
      patientId: 'p1',
      title: 'Task',
      dueDate: due,
      done: done);

  TreatmentPlan planWithGoal(int progress) => TreatmentPlan(
        id: 'pl1',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: now.subtract(const Duration(days: 30)),
        primaryDiagnosis: 'F41.1',
        clinicalFormulation: 'x',
        goals: [
          TreatmentGoal(
            id: 'g1',
            description: 'Reduce GAD-7 below 10',
            category: GoalCategory.symptomReduction,
            priority: GoalPriority.high,
            targetDate: now.add(const Duration(days: 60)),
            progress: progress,
            createdAt: now.subtract(const Duration(days: 30)),
          )
        ],
      );

  test('first session when no notes', () {
    final b = svc.build(patientName: 'Alice', notes: const [], now: now);
    expect(b.isFirstSession, isTrue);
    expect(b.sessionCount, 0);
  });

  test('summarizes prior sessions + last recap', () {
    final b = svc.build(
      patientName: 'Alice',
      notes: [note(2, text: 'most recent'), note(9), note(16)],
      now: now,
    );
    expect(b.sessionCount, 3);
    expect(b.lastSessionAt, now.subtract(const Duration(days: 2)));
    expect(b.lastRecap, contains('most recent'));
    expect(b.isFirstSession, isFalse);
  });

  test('counts overdue vs pending homework and adds a todo', () {
    final b = svc.build(
      patientName: 'Alice',
      notes: [note(1)],
      homework: [
        hw(due: now.subtract(const Duration(days: 1))), // overdue
        hw(due: now.add(const Duration(days: 3))), // pending
        hw(done: true, due: now.subtract(const Duration(days: 5))), // done
      ],
      now: now,
    );
    expect(b.homeworkOverdue, 1);
    expect(b.homeworkPending, 1);
    expect(b.todos.any((t) => t.contains('overdue')), isTrue);
  });

  test('recent risk with no safety plan surfaces a risk note + todo', () {
    final b = svc.build(
      patientName: 'Alice',
      notes: [note(1, risk: true)],
      now: now,
    );
    expect(b.riskNote, isNotNull);
    expect(b.todos.any((t) => t.toLowerCase().contains('safety plan')), isTrue);
  });

  test('active goals are listed with progress', () {
    final b = svc.build(
      patientName: 'Alice',
      notes: [note(1)],
      plan: planWithGoal(40),
      now: now,
    );
    expect(b.activeGoals, hasLength(1));
    expect(b.activeGoals.first, contains('40%'));
    expect(b.todos.any((t) => t.contains('Revisit')), isTrue);
  });
}
