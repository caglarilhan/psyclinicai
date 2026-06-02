import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/erx/ddi_checker.dart';

void main() {
  const checker = DdiChecker();

  group('DdiChecker', () {
    test('flags SSRI + non-selective MAOI as contraindicated', () {
      final matches = checker.check(['N06AB04', 'N06AF01']);
      expect(matches, hasLength(1));
      expect(matches.first.severity, DdiSeverity.contraindicated);
      expect(matches.first.summary, contains('serotonin syndrome'));
    });

    test('flags benzo + opioid as severe', () {
      final matches = checker.check(['N05BA01', 'N02AA01']);
      expect(matches, hasLength(1));
      expect(matches.first.severity, DdiSeverity.severe);
      expect(matches.first.summary, contains('respiratory depression'));
    });

    test('emits a single match for unordered pairs', () {
      final ab = checker.check(['N06AB04', 'N06AF01']);
      final ba = checker.check(['N06AF01', 'N06AB04']);
      expect(ab.length, ba.length);
      expect(ab.first.severity, ba.first.severity);
    });

    test('does NOT flag two SSRIs alone (same class)', () {
      final matches = checker.check(['N06AB04', 'N06AB06']);
      expect(matches, isEmpty);
    });

    test('hasContraindication is the boolean gate', () {
      expect(checker.hasContraindication(['N06AB04', 'N06AF01']), isTrue);
      expect(checker.hasContraindication(['N06AB04', 'N06AB06']),
          isFalse);
    });

    test('hasBlockingInteraction includes severe interactions', () {
      // benzo + opioid is severe (FDA black box) and MUST block
      // transmission — not "warn only".
      expect(
        checker.hasBlockingInteraction(['N05BA01', 'N02AA01']),
        isTrue,
      );
      // Moderate-only does NOT block (TCA + SSRI).
      expect(
        checker.hasBlockingInteraction(['N06AA09', 'N06AB04']),
        isFalse,
      );
    });

    test('returns moderate severity for TCA + SSRI', () {
      final matches = checker.check(['N06AA09', 'N06AB04']);
      expect(matches, hasLength(1));
      expect(matches.first.severity, DdiSeverity.moderate);
    });

    test('SSRI + linezolid is contraindicated', () {
      expect(
        checker.hasContraindication(['N06AB04', 'J01XX08']),
        isTrue,
      );
    });

    test('citalopram + ondansetron raises severe QT warning', () {
      final matches = checker.check(['N06AB04', 'A04AA01']);
      expect(matches, hasLength(1));
      expect(matches.first.severity, DdiSeverity.severe);
      expect(matches.first.summary, contains('QT'));
    });

    test('lexicon attribution surfaces a sourceVersion stamp', () {
      const c = DdiChecker();
      expect(c.sourceVersion, isNotEmpty);
      expect(c.lastVerifiedAt, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    });
  });
}
