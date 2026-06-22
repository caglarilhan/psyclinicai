import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/utils/smart_goal_notes.dart';

void main() {
  group('formatSmartGoalNotes', () {
    test('returns an empty string when every field is blank', () {
      expect(formatSmartGoalNotes(), '');
      expect(
        formatSmartGoalNotes(
          baseline: '   ',
          target: '\n',
          achievability: '',
          relevance: ' ',
        ),
        '',
      );
    });

    test('emits only the populated lines, in canonical order', () {
      final md = formatSmartGoalNotes(
        baseline: 'PHQ-9 = 18',
        target: 'PHQ-9 ≤ 9',
      );
      expect(md, '**Baseline:** PHQ-9 = 18\n**Target:** PHQ-9 ≤ 9');
    });

    test('canonical order is Baseline · Target · Achievable · Relevant', () {
      final md = formatSmartGoalNotes(
        relevance: 'r',
        achievability: 'a',
        target: 't',
        baseline: 'b',
      );
      final iB = md.indexOf('Baseline');
      final iT = md.indexOf('Target');
      final iA = md.indexOf('Achievable');
      final iR = md.indexOf('Relevant');
      expect(iB < iT, isTrue);
      expect(iT < iA, isTrue);
      expect(iA < iR, isTrue);
    });

    test('trims surrounding whitespace from each value', () {
      final md = formatSmartGoalNotes(baseline: '   start  ');
      expect(md, '**Baseline:** start');
    });

    test('uses bold markdown for the label (compatible with PDF export)', () {
      final md = formatSmartGoalNotes(target: 'PHQ-9 ≤ 9');
      expect(md, contains('**Target:**'));
    });

    test('a single field populates exactly one line — no trailing newline', () {
      final md = formatSmartGoalNotes(achievability: 'Realistic');
      expect(md, '**Achievable:** Realistic');
      expect(md.endsWith('\n'), isFalse);
    });
  });
}
