import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/phq9_service.dart';

/// PHQ-9 scoring + severity-band tests — clinical-safety critical.
/// Severity bands per Kroenke, Spitzer & Williams (2001):
///   0–4   Minimal      5–9   Mild     10–14 Moderate
///   15–19 Moderately severe       20–27 Severe
/// Item 9 (self-harm / SI) must always flag when answered >0,
/// even if the total stays in the "minimal" band.
void main() {
  final svc = Phq9Service.instance;

  group('PHQ-9 totals and band boundaries', () {
    test('all zeros → 0, minimal, no SI flag', () {
      final r = svc.score(List.filled(9, 0));
      expect(r.total, 0);
      expect(r.severity, Phq9Severity.minimal);
      expect(r.selfHarmFlag, isFalse);
    });

    test('upper edge of minimal (4) stays minimal', () {
      final r = svc.score([1, 1, 1, 1, 0, 0, 0, 0, 0]);
      expect(r.total, 4);
      expect(r.severity, Phq9Severity.minimal);
    });

    test('lower edge of mild (5)', () {
      final r = svc.score([1, 1, 1, 1, 1, 0, 0, 0, 0]);
      expect(r.total, 5);
      expect(r.severity, Phq9Severity.mild);
    });

    test('upper edge of mild (9) stays mild', () {
      final r = svc.score([2, 2, 2, 2, 1, 0, 0, 0, 0]);
      expect(r.total, 9);
      expect(r.severity, Phq9Severity.mild);
    });

    test('lower edge of moderate (10)', () {
      final r = svc.score([2, 2, 2, 2, 2, 0, 0, 0, 0]);
      expect(r.total, 10);
      expect(r.severity, Phq9Severity.moderate);
    });

    test('upper edge of moderate (14)', () {
      final r = svc.score([2, 2, 2, 2, 2, 2, 2, 0, 0]);
      expect(r.total, 14);
      expect(r.severity, Phq9Severity.moderate);
    });

    test('lower edge of moderatelySevere (15)', () {
      final r = svc.score([2, 2, 2, 2, 2, 2, 2, 1, 0]);
      expect(r.total, 15);
      expect(r.severity, Phq9Severity.moderatelySevere);
    });

    test('upper edge of moderatelySevere (19)', () {
      final r = svc.score([3, 3, 3, 3, 3, 2, 2, 0, 0]);
      expect(r.total, 19);
      expect(r.severity, Phq9Severity.moderatelySevere);
    });

    test('severe band starts at 20', () {
      final r = svc.score([3, 3, 3, 3, 3, 3, 2, 0, 0]);
      expect(r.total, 20);
      expect(r.severity, Phq9Severity.severe);
    });

    test('maximum score (27)', () {
      final r = svc.score(List.filled(9, 3));
      expect(r.total, 27);
      expect(r.severity, Phq9Severity.severe);
      expect(r.selfHarmFlag, isTrue);
    });
  });

  group('Item 9 — suicidal ideation flag', () {
    test('SI=1 alone flags even when total stays minimal', () {
      final r = svc.score([0, 0, 0, 0, 0, 0, 0, 0, 1]);
      expect(r.total, 1);
      expect(r.severity, Phq9Severity.minimal);
      // Critical: the SI flag must fire regardless of band, so a clinician
      // is alerted on a single endorsement of item 9.
      expect(r.selfHarmFlag, isTrue);
    });

    test('SI=0 keeps flag off even at high totals', () {
      final r = svc.score([3, 3, 3, 3, 3, 3, 3, 3, 0]);
      expect(r.total, 24);
      expect(r.severity, Phq9Severity.severe);
      expect(r.selfHarmFlag, isFalse);
    });

    test('SI=3 (nearly every day) flags', () {
      final r = svc.score([1, 1, 1, 1, 1, 1, 1, 1, 3]);
      expect(r.selfHarmFlag, isTrue);
    });
  });

  group('severity → action mapping', () {
    test('minimal suggests monitoring', () {
      expect(
        Phq9Severity.minimal.actionSuggestion.toLowerCase(),
        contains('monitor'),
      );
    });

    test('severe escalates to immediate treatment', () {
      expect(
        Phq9Severity.severe.actionSuggestion.toLowerCase(),
        contains('immediate'),
      );
    });

    test('all bands have a non-empty label', () {
      for (final s in Phq9Severity.values) {
        expect(s.label, isNotEmpty);
      }
    });
  });

  group('input validation', () {
    test('throws on wrong answer length', () {
      expect(
        () => svc.score(List.filled(8, 0)),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => svc.score(List.filled(10, 0)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('returns immutable answers list', () {
      final answers = [1, 1, 1, 1, 1, 1, 1, 1, 1];
      final r = svc.score(answers);
      expect(() => r.answers.add(0), throwsUnsupportedError);
    });
  });
}
