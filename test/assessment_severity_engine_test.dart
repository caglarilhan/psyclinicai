import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/assessments/assessment_severity_engine.dart';

void main() {
  const engine = AssessmentSeverityEngine();

  group('PHQ-9 bands', () {
    test('0..4 → minimal, not a clinical concern', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.phq9,
        score: 3,
      );
      expect(r.band.label, 'minimal');
      expect(r.band.isClinicalConcern, isFalse);
    });

    test('10..14 → moderate, clinical concern + recommendations', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.phq9,
        score: 12,
      );
      expect(r.band.label, 'moderate');
      expect(r.band.isClinicalConcern, isTrue);
      expect(r.recommendations.first, contains('item 9'));
    });

    test('20..27 → severe', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.phq9,
        score: 25,
      );
      expect(r.band.label, 'severe');
    });
  });

  group('PCL-5 boundary', () {
    test('31 → probable PTSD (boundary)', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.pcl5,
        score: 31,
      );
      expect(r.band.label, contains('boundary'));
    });

    test('33 → probable PTSD (above boundary)', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.pcl5,
        score: 33,
      );
      expect(r.band.label, 'probable PTSD');
    });
  });

  group('AUDIT bands', () {
    test('hazardous + harmful + dependence chain', () {
      expect(
        engine
            .evaluate(instrument: AssessmentInstrument.audit, score: 10)
            .band
            .label,
        'hazardous',
      );
      expect(
        engine
            .evaluate(instrument: AssessmentInstrument.audit, score: 18)
            .band
            .label,
        'harmful',
      );
      expect(
        engine
            .evaluate(instrument: AssessmentInstrument.audit, score: 30)
            .band
            .label,
        'dependence likely',
      );
    });
  });

  group('C-SSRS tiers', () {
    test('flag count 0 → low; 2 → moderate; 5 → high', () {
      expect(
        engine
            .evaluate(instrument: AssessmentInstrument.cssrs, score: 0)
            .band
            .label,
        'low',
      );
      expect(
        engine
            .evaluate(instrument: AssessmentInstrument.cssrs, score: 2)
            .band
            .label,
        'moderate',
      );
      expect(
        engine
            .evaluate(instrument: AssessmentInstrument.cssrs, score: 5)
            .band
            .label,
        'high',
      );
    });
  });

  group('delta vs previous', () {
    test('improving = score decreased', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.phq9,
        score: 9,
        previousScore: 14,
      );
      expect(r.isImproving, isTrue);
      expect(r.deltaVsPrevious, -5);
    });

    test('worsening = score increased', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.phq9,
        score: 18,
        previousScore: 12,
      );
      expect(r.isWorsening, isTrue);
      expect(r.deltaVsPrevious, 6);
    });

    test('no previous score → null delta, both flags false', () {
      final r = engine.evaluate(
        instrument: AssessmentInstrument.phq9,
        score: 9,
      );
      expect(r.deltaVsPrevious, isNull);
      expect(r.isImproving, isFalse);
      expect(r.isWorsening, isFalse);
    });
  });

  test('bandsFor exposes the full band table', () {
    expect(engine.bandsFor(AssessmentInstrument.phq9), hasLength(5));
    expect(engine.bandsFor(AssessmentInstrument.cssrs), hasLength(3));
    expect(engine.bandsFor(AssessmentInstrument.pcl5), hasLength(3));
    expect(engine.bandsFor(AssessmentInstrument.audit), hasLength(4));
  });

  test('AssessmentInstrument.tryFromId tolerates unknown', () {
    expect(AssessmentInstrument.tryFromId('phq9'),
        AssessmentInstrument.phq9);
    expect(AssessmentInstrument.tryFromId('xx'), isNull);
  });
}
