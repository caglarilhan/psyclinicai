import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/gad7_service.dart';

/// GAD-7 scoring + severity-band tests — clinical-safety critical.
/// Severity bands per Spitzer, Kroenke, Williams & Löwe (2006):
///   0–4   Minimal      5–9   Mild     10–14 Moderate      15–21 Severe
void main() {
  final svc = Gad7Service.instance;

  group('GAD-7 totals and band boundaries', () {
    test('all zeros → 0, minimal', () {
      final r = svc.score(List.filled(7, 0));
      expect(r.total, 0);
      expect(r.severity, Gad7Severity.minimal);
    });

    test('upper edge of minimal (4) stays minimal', () {
      final r = svc.score([1, 1, 1, 1, 0, 0, 0]);
      expect(r.total, 4);
      expect(r.severity, Gad7Severity.minimal);
    });

    test('lower edge of mild (5)', () {
      final r = svc.score([1, 1, 1, 1, 1, 0, 0]);
      expect(r.total, 5);
      expect(r.severity, Gad7Severity.mild);
    });

    test('upper edge of mild (9)', () {
      final r = svc.score([2, 2, 2, 2, 1, 0, 0]);
      expect(r.total, 9);
      expect(r.severity, Gad7Severity.mild);
    });

    test('lower edge of moderate (10)', () {
      final r = svc.score([2, 2, 2, 2, 2, 0, 0]);
      expect(r.total, 10);
      expect(r.severity, Gad7Severity.moderate);
    });

    test('upper edge of moderate (14)', () {
      final r = svc.score([3, 3, 3, 3, 2, 0, 0]);
      expect(r.total, 14);
      expect(r.severity, Gad7Severity.moderate);
    });

    test('severe band starts at 15', () {
      final r = svc.score([3, 3, 3, 3, 3, 0, 0]);
      expect(r.total, 15);
      expect(r.severity, Gad7Severity.severe);
    });

    test('maximum score (21)', () {
      final r = svc.score(List.filled(7, 3));
      expect(r.total, 21);
      expect(r.severity, Gad7Severity.severe);
    });
  });

  group('severity → action mapping', () {
    test('minimal: no intervention', () {
      expect(
        Gad7Severity.minimal.actionSuggestion.toLowerCase(),
        contains('no intervention'),
      );
    });

    test('severe escalates to specialist referral', () {
      expect(
        Gad7Severity.severe.actionSuggestion.toLowerCase(),
        contains('specialist'),
      );
    });

    test('all bands have non-empty label', () {
      for (final s in Gad7Severity.values) {
        expect(s.label, isNotEmpty);
      }
    });
  });

  group('input validation', () {
    test('throws on wrong answer length', () {
      expect(
        () => svc.score(List.filled(6, 0)),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => svc.score(List.filled(8, 0)),
        throwsA(isA<AssertionError>()),
      );
    });

    test('returns immutable answers list', () {
      final r = svc.score(List.filled(7, 1));
      expect(() => r.answers.add(0), throwsUnsupportedError);
    });
  });
}
