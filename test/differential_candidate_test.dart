import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/differential_candidate.dart';

DifferentialCandidate _candidate({double confidence = 0.6}) =>
    DifferentialCandidate(
      code: 'F32.1',
      name: 'Major depressive disorder, single episode, moderate',
      confidence: confidence,
      criteriaMet: const ['A.1 depressed mood', 'A.2 anhedonia'],
      criteriaMissing: const ['A.5 psychomotor agitation'],
      differentialFrom: const ['F33.1 recurrent MDD'],
    );

void main() {
  group('DifferentialCandidate', () {
    test('rejects empty code / name', () {
      expect(
        () => DifferentialCandidate(
          code: '',
          name: 'X',
          confidence: 0.5,
          criteriaMet: const [],
          criteriaMissing: const [],
          differentialFrom: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects confidence outside [0, 1]', () {
      expect(() => _candidate(confidence: 1.2), throwsA(isA<ArgumentError>()));
      expect(
        () => _candidate(confidence: -0.01),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('JSON round-trip preserves arrays', () {
      final c = _candidate();
      final round = DifferentialCandidate.fromJson(c.toJson());
      expect(round.code, c.code);
      expect(round.criteriaMet, c.criteriaMet);
      expect(round.differentialFrom, c.differentialFrom);
      expect(round.confidence, c.confidence);
    });

    test('confidence bands', () {
      expect(_candidate(confidence: 0.1).band, ConfidenceBand.low);
      expect(_candidate(confidence: 0.3).band, ConfidenceBand.moderate);
      expect(_candidate(confidence: 0.6).band, ConfidenceBand.high);
      expect(_candidate(confidence: 0.85).band, ConfidenceBand.veryHigh);
    });

    test('boundary confidences land in the upper band', () {
      expect(_candidate(confidence: 0.25).band, ConfidenceBand.moderate);
      expect(_candidate(confidence: 0.5).band, ConfidenceBand.high);
      expect(_candidate(confidence: 0.75).band, ConfidenceBand.veryHigh);
    });
  });
}
