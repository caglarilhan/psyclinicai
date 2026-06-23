/// Coverage for AssessmentOutcomesService — ASEBA + Vanderbilt
/// trend series ordering, skip rules, latest-subtype helper.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/aseba_score_record.dart';
import 'package:psyclinicai/models/vanderbilt_assessment.dart';
import 'package:psyclinicai/services/assessment_outcomes_service.dart';

AsebaScoreRecord _aseba({
  required String id,
  required DateTime at,
  int? totalT,
  Map<AsebaSyndromeScale, int>? syndrome,
}) => AsebaScoreRecord(
  id: id,
  patientId: 'p1',
  clinicianId: 'c1',
  form: AsebaForm.cbclParent,
  capturedAt: at,
  syndromeT: syndrome,
  compositeT: totalT == null
      ? null
      : {AsebaCompositeScale.totalProblems: totalT},
);

VanderbiltAssessment _vandy({
  required String id,
  required DateTime at,
  bool meetsInattn = false,
  VanderbiltRespondent respondent = VanderbiltRespondent.parent,
}) => VanderbiltAssessment(
  id: id,
  patientId: 'p1',
  clinicianId: 'c1',
  respondent: respondent,
  capturedAt: at,
  inattention: meetsInattn
      ? const [2, 2, 2, 2, 2, 2, 0, 0, 0]
      : const [0, 0, 0, 0, 0, 0, 0, 0, 0],
  performance: const [1, 1, 1, 4, 1, 1, 1, 1],
);

void main() {
  group('asebaTotalProblemsTrend', () {
    test('sorts captures oldest-first', () {
      final series = AssessmentOutcomesService.asebaTotalProblemsTrend([
        _aseba(id: 'b', at: DateTime.utc(2026, 6, 22), totalT: 70),
        _aseba(id: 'a', at: DateTime.utc(2026, 6, 2), totalT: 64),
      ]);
      expect(series.map((p) => p.value), [64, 70]);
    });

    test('skips records missing the composite (does not zero-fill)', () {
      final series = AssessmentOutcomesService.asebaTotalProblemsTrend([
        _aseba(id: 'a', at: DateTime.utc(2026, 6, 2)),
        _aseba(id: 'b', at: DateTime.utc(2026, 6, 22), totalT: 65),
      ]);
      expect(series, hasLength(1));
      expect(series.first.value, 65);
    });

    test('returns empty for empty input', () {
      expect(
        AssessmentOutcomesService.asebaTotalProblemsTrend(const []),
        isEmpty,
      );
    });
  });

  group('asebaSyndromeClinicalTrend', () {
    test('counts subscales scored T>=70 per capture', () {
      final series = AssessmentOutcomesService.asebaSyndromeClinicalTrend([
        _aseba(
          id: 'a',
          at: DateTime.utc(2026, 6, 2),
          syndrome: const {
            AsebaSyndromeScale.aggressive: 72,
            AsebaSyndromeScale.attentionProblems: 60,
          },
        ),
        _aseba(
          id: 'b',
          at: DateTime.utc(2026, 6, 22),
          syndrome: const {
            AsebaSyndromeScale.aggressive: 75,
            AsebaSyndromeScale.attentionProblems: 70,
            AsebaSyndromeScale.anxiousDepressed: 65,
          },
        ),
      ]);
      expect(series.map((p) => p.value), [1, 2]);
    });
  });

  group('Vanderbilt trends', () {
    test('inattention trend uses symptomCount (items at 2 or 3)', () {
      final series = AssessmentOutcomesService.vanderbiltInattentionTrend([
        _vandy(id: 'a', at: DateTime.utc(2026, 6, 2)),
        _vandy(id: 'b', at: DateTime.utc(2026, 6, 22), meetsInattn: true),
      ]);
      expect(series.map((p) => p.value), [0, 6]);
    });

    test('label reflects respondent', () {
      final series = AssessmentOutcomesService.vanderbiltInattentionTrend([
        _vandy(id: 'parent', at: DateTime.utc(2026, 6, 2)),
        _vandy(
          id: 'teacher',
          at: DateTime.utc(2026, 6, 22),
          respondent: VanderbiltRespondent.teacher,
        ),
      ]);
      expect(series.first.label, 'Parent');
      expect(series.last.label, 'Teacher');
    });
  });

  group('latestSubtype', () {
    test('returns the subtype of the most recent record', () {
      final subtype = AssessmentOutcomesService.latestSubtype([
        _vandy(id: 'a', at: DateTime.utc(2026, 6, 2)),
        _vandy(id: 'b', at: DateTime.utc(2026, 6, 22), meetsInattn: true),
      ]);
      expect(subtype, VanderbiltSubtype.inattentive);
    });

    test('null when no records', () {
      expect(AssessmentOutcomesService.latestSubtype(const []), isNull);
    });
  });
}
