import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/homework_item.dart';
import 'package:psyclinicai/models/safety_plan.dart';
import 'package:psyclinicai/models/session_note.dart';

/// Clinical-data integrity: these models are persisted and reloaded, so a
/// lossy or crashing (de)serialization silently corrupts a chart. Round-trips
/// and missing-key resilience are pinned.
void main() {
  group('SafetyPlan', () {
    test('round-trip preserves every step + updatedAt', () {
      final plan = SafetyPlan(
        patientId: 'p1',
        warningSigns: const ['ruminating at night'],
        copingStrategies: const ['paced breathing'],
        socialDistractions: const ['call a friend'],
        supportContacts: const ['Partner — 555-0101'],
        professionals: const ['Dr. Lee — 555-0102'],
        crisisLines: const ['988'],
        meansSafety: 'medications stored with a trusted person',
        updatedAt: DateTime.parse('2026-05-20T10:00:00.000'),
      );
      final r = SafetyPlan.fromJson(plan.toJson());
      expect(r.patientId, 'p1');
      expect(r.warningSigns, plan.warningSigns);
      expect(r.crisisLines, ['988']);
      expect(r.meansSafety, plan.meansSafety);
      expect(r.updatedAt, DateTime.parse('2026-05-20T10:00:00.000'));
    });

    test('fromJson tolerates missing keys (no crash, empty defaults)', () {
      final r = SafetyPlan.fromJson({'patientId': 'p2'});
      expect(r.warningSigns, isEmpty);
      expect(r.crisisLines, isEmpty);
      expect(r.isEmpty, isTrue);
    });

    test('isEmpty flips once any step has content', () {
      final r = SafetyPlan(patientId: 'p3', warningSigns: const ['x']);
      expect(r.isEmpty, isFalse);
    });

    test('copyWith keeps patientId and untouched fields', () {
      final base = SafetyPlan(patientId: 'p4', copingStrategies: const ['a']);
      final next = base.copyWith(warningSigns: const ['w']);
      expect(next.patientId, 'p4');
      expect(next.copingStrategies, ['a']); // untouched
      expect(next.warningSigns, ['w']);
    });

    test('reasonsForLiving round-trips through JSON', () {
      final plan = SafetyPlan(
        patientId: 'p5',
        reasonsForLiving: const ['my daughter', 'finishing my research'],
      );
      final r = SafetyPlan.fromJson(plan.toJson());
      expect(r.reasonsForLiving, plan.reasonsForLiving);
    });

    test('legacy JSON without reasonsForLiving stays empty (back-compat)', () {
      final r = SafetyPlan.fromJson({
        'patientId': 'p6',
        'warningSigns': ['x'],
      });
      expect(r.reasonsForLiving, isEmpty);
      expect(r.warningSigns, ['x']);
    });

    test('copyWith can update reasonsForLiving in isolation', () {
      final base = SafetyPlan(patientId: 'p7', warningSigns: const ['w']);
      final next = base.copyWith(reasonsForLiving: const ['hope']);
      expect(next.warningSigns, ['w']);
      expect(next.reasonsForLiving, ['hope']);
    });

    test('isClinicallyComplete demands warning + coping + contact + line',
        () {
      final empty = SafetyPlan(patientId: 'p8');
      expect(empty.isClinicallyComplete, isFalse);
      expect(empty.missingClinicalSections,
          containsAll(['warning_signs', 'coping_strategies',
              'people_to_reach', 'crisis_lines']));

      final partial = SafetyPlan(
        patientId: 'p8',
        warningSigns: const ['ruminating'],
        copingStrategies: const ['paced breathing'],
        supportContacts: const ['Partner — 555-0101'],
      );
      expect(partial.isClinicallyComplete, isFalse);
      expect(partial.missingClinicalSections, ['crisis_lines']);

      final complete = partial.copyWith(crisisLines: const ['988']);
      expect(complete.isClinicallyComplete, isTrue);
      expect(complete.missingClinicalSections, isEmpty);
    });

    test('professionals satisfies the "people to reach" floor', () {
      final p = SafetyPlan(
        patientId: 'p9',
        warningSigns: const ['x'],
        copingStrategies: const ['y'],
        professionals: const ['Dr. Lee — 555-0102'],
        crisisLines: const ['988'],
      );
      expect(p.isClinicallyComplete, isTrue);
    });
  });

  group('SessionNote', () {
    test('round-trip preserves flaggedRisk and format', () {
      final note = SessionNote(
        id: 'n1',
        patientId: 'p1',
        markdown: 'S: ... O: ... A: ... P: ...',
        format: 'dap',
        flaggedRisk: true,
        createdAt: DateTime.parse('2026-05-22T09:30:00.000'),
      );
      final r = SessionNote.fromJson(note.toJson());
      expect(r.id, 'n1');
      expect(r.flaggedRisk, isTrue);
      expect(r.format, 'dap');
      expect(r.createdAt, DateTime.parse('2026-05-22T09:30:00.000'));
    });

    test('fromJson with null/absent createdAt does not throw', () {
      final r = SessionNote.fromJson({
        'id': 'n2',
        'patientId': 'p1',
        'markdown': 'note',
      });
      expect(r.format, 'soap'); // default
      expect(r.flaggedRisk, isFalse);
      expect(r.createdAt, isA<DateTime>());
    });
  });

  group('HomeworkItem', () {
    test('round-trip with and without linkedGoal', () {
      final withGoal = HomeworkItem(
        id: 'h1',
        patientId: 'p1',
        title: 'Thought record',
        dueDate: DateTime.parse('2026-06-01T00:00:00.000'),
        linkedGoal: 'Reduce GAD-7 below 10',
      );
      final r1 = HomeworkItem.fromJson(withGoal.toJson());
      expect(r1.linkedGoal, 'Reduce GAD-7 below 10');
      expect(r1.dueDate, DateTime.parse('2026-06-01T00:00:00.000'));

      final noGoal = HomeworkItem(
        id: 'h2',
        patientId: 'p1',
        title: 'Breathing log',
        dueDate: DateTime.parse('2026-06-02T00:00:00.000'),
      );
      expect(HomeworkItem.fromJson(noGoal.toJson()).linkedGoal, isNull);
    });

    test('copyWith(done) flips done but keeps linkedGoal', () {
      final h = HomeworkItem(
        id: 'h3',
        patientId: 'p1',
        title: 'x',
        dueDate: DateTime.now(),
        linkedGoal: 'goal',
      );
      final done = h.copyWith(done: true);
      expect(done.done, isTrue);
      expect(done.linkedGoal, 'goal');
    });
  });
}
