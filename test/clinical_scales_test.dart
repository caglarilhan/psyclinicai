import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/clinical_scale.dart';
import 'package:psyclinicai/services/assessments/clinical_scales.dart';

void main() {
  group('AUDIT', () {
    final s = ClinicalScales.audit;
    test('has 10 items, max 40', () {
      expect(s.itemCount, 10);
      expect(s.score(List.filled(10, 0)).maxScore, 40);
    });
    test('low risk band, no flag', () {
      final r = s.score(List.filled(10, 0));
      expect(r.total, 0);
      expect(r.severity, ScaleSeverity.minimal);
      expect(r.riskFlag, isFalse);
    });
    test('hazardous band (8–15)', () {
      final r = s.score([4, 4, 2, 0, 0, 0, 0, 0, 0, 0]); // 10
      expect(r.severity, ScaleSeverity.moderate);
      expect(r.bandLabel, contains('Hazardous'));
      expect(r.riskFlag, isFalse);
    });
    test('score >=16 flags harmful/dependence', () {
      final r = s.score([4, 4, 4, 4, 0, 0, 0, 0, 0, 0]); // 16
      expect(r.severity, ScaleSeverity.severe);
      expect(r.riskFlag, isTrue);
    });
    test('dependence band (>=20) is critical', () {
      final r = s.score([4, 4, 4, 4, 4, 1, 0, 0, 0, 0]); // 21
      expect(r.severity, ScaleSeverity.critical);
      expect(r.riskFlag, isTrue);
    });
  });

  group('PCL-5', () {
    final s = ClinicalScales.pcl5;
    test('has 20 items, max 80', () {
      expect(s.itemCount, 20);
      expect(s.score(List.filled(20, 0)).maxScore, 80);
    });
    test('below threshold, no flag', () {
      final r = s.score(List.filled(20, 1)); // 20
      expect(r.total, 20);
      expect(r.riskFlag, isFalse);
      expect(r.bandLabel, contains('Below'));
    });
    test('score >=33 flags provisional PTSD', () {
      final answers = List.filled(20, 0);
      for (var i = 0; i < 11; i++) {
        answers[i] = 3; // 33
      }
      final r = s.score(answers);
      expect(r.total, 33);
      expect(r.severity, ScaleSeverity.moderate);
      expect(r.riskFlag, isTrue);
    });
    test('high symptom load is severe', () {
      final r = s.score(List.filled(20, 4)); // 80
      expect(r.severity, ScaleSeverity.severe);
      expect(r.riskFlag, isTrue);
    });
  });

  group('C-SSRS', () {
    final s = ClinicalScales.cssrs;
    test('has 6 items, max 6', () {
      expect(s.itemCount, 6);
      expect(s.score(List.filled(6, 0)).maxScore, 6);
    });
    test('all-no is minimal, no flag', () {
      final r = s.score(List.filled(6, 0));
      expect(r.severity, ScaleSeverity.minimal);
      expect(r.riskFlag, isFalse);
    });
    test('wish-to-be-dead only is mild but still flagged', () {
      final r = s.score([1, 0, 0, 0, 0, 0]);
      expect(r.severity, ScaleSeverity.mild);
      expect(r.riskFlag, isTrue);
      expect(r.riskFlagText, contains('Positive screen'));
    });
    test('method (Q3) is moderate, high-priority', () {
      final r = s.score([0, 0, 1, 0, 0, 0]);
      expect(r.severity, ScaleSeverity.moderate);
      expect(r.riskFlag, isTrue);
      expect(r.riskFlagText, contains('immediate'));
    });
    test('intent (Q4) is severe', () {
      final r = s.score([0, 0, 0, 1, 0, 0]);
      expect(r.severity, ScaleSeverity.severe);
    });
    test('behavior (Q6) is critical', () {
      final r = s.score([0, 0, 0, 0, 0, 1]);
      expect(r.severity, ScaleSeverity.critical);
      expect(r.riskFlag, isTrue);
    });
  });

  test('registry: all + byId', () {
    expect(ClinicalScales.all, hasLength(3));
    expect(ClinicalScales.byId('audit')?.shortName, 'AUDIT');
    expect(ClinicalScales.byId('pcl5')?.shortName, 'PCL-5');
    expect(ClinicalScales.byId('cssrs')?.shortName, 'C-SSRS');
    expect(ClinicalScales.byId('nope'), isNull);
  });
}
