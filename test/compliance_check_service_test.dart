import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/compliance_check_service.dart';

void main() {
  late ComplianceCheckService svc;
  setUp(() => svc = ComplianceCheckService());
  tearDown(() => svc.dispose());

  // A note hitting every rubric element.
  const goodNote = '''
## S — Subjective
Client reports persistent low mood (F32.1), difficulty concentrating at work
and withdrawing from relationships. PHQ-9 = 14 (down from 18).
## O — Objective
Session 10:02–10:55. Constricted affect, engaged. No SI/HI, no acute safety concerns.
## A — Assessment
Moderate MDD; functional impairment in work and self-care. Progress toward
treatment plan goal of improved activation.
## P — Plan
Used cognitive restructuring and behavioral activation; client responded well
and practiced reframing. Homework assigned; next session in one week.
''';

  const vagueNote =
      'Client came in and we talked. Patient is doing better. Good session.';

  group('Tier 1 check()', () {
    test('a complete note scores high with no failures', () {
      final r = svc.check(goodNote);
      expect(r.score, greaterThanOrEqualTo(80));
      expect(r.failCount, 0);
      expect(r.source, ComplianceSource.heuristic);
    });

    test('a vague note scores low and flags fixes', () {
      final r = svc.check(vagueNote);
      expect(r.score, lessThan(60));
      expect(r.toFixCount, greaterThan(3));
      // Every non-pass check carries an actionable fix.
      for (final c in r.checks.where((c) => c.status != CheckStatus.pass)) {
        expect(c.fix, isNotNull);
      }
    });

    test('goal linkage is a hard fail when no plan exists', () {
      final r = svc.check(vagueNote);
      final goal = r.checks.firstWhere((c) => c.id == 'goal_linkage');
      expect(goal.status, CheckStatus.fail);
    });

    test('risk is detected even when phrased as absent', () {
      final r = svc.check('No SI/HI reported, no acute safety concerns.');
      final risk = r.checks.firstWhere((c) => c.id == 'risk');
      expect(risk.status, CheckStatus.pass);
    });

    test('90837 (53+ min) without justification warns on time', () {
      final r = svc.check(
        '## O\nSession 10:00–11:00. Engaged. No SI/HI.',
        durationMinutes: 60,
      );
      final t = r.checks.firstWhere((c) => c.id == 'time');
      expect(t.status, CheckStatus.warn);
      expect(t.fix, contains('90837'));
    });

    test('every rubric criterion is present', () {
      final ids = svc.check(goodNote).checks.map((c) => c.id).toSet();
      expect(
        ids,
        containsAll(<String>{
          'diagnosis',
          'functional_impairment',
          'intervention',
          'response',
          'goal_linkage',
          'risk',
          'time',
          'plan',
        }),
      );
    });
  });
}
