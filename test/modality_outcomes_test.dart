/// Pure-helper coverage for the modality outcomes dashboard
/// aggregators. Each helper is a stateless transform from a list of
/// modality records → chart-ready data; we exercise them
/// independently of the LineChart / BarChart widgets so the
/// shape-of-data contract is locked in.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/modalities/cbt_thought_record.dart';
import 'package:psyclinicai/models/modalities/dbt_diary_card.dart';
import 'package:psyclinicai/models/modalities/emdr_session_tracker.dart';
import 'package:psyclinicai/screens/outcomes/modality_outcomes_screen.dart';

void main() {
  group('buildCbtDeltaSeries', () {
    test('empty input produces empty list', () {
      expect(buildCbtDeltaSeries(const []), isEmpty);
    });

    test('one point per record, x indexed chronologically', () {
      final r1 = CbtThoughtRecord(
        id: 'r1',
        patientId: 'p1',
        clinicianId: 'c1',
        recordedAt: DateTime.utc(2026, 6, 20),
        emotionsBefore: const [CbtEmotionRating(emotion: 'sad', intensity: 80)],
        emotionsAfter: const [CbtEmotionRating(emotion: 'sad', intensity: 30)],
      );
      final r2 = CbtThoughtRecord(
        id: 'r2',
        patientId: 'p1',
        clinicianId: 'c1',
        recordedAt: DateTime.utc(2026, 6, 22),
        emotionsBefore: const [CbtEmotionRating(emotion: 'sad', intensity: 60)],
        emotionsAfter: const [CbtEmotionRating(emotion: 'sad', intensity: 20)],
      );
      final spots = buildCbtDeltaSeries([r1, r2]);
      expect(spots, hasLength(2));
      expect(spots[0].x, 0.0);
      expect(spots[0].y, 50.0);
      expect(spots[1].x, 1.0);
      expect(spots[1].y, 40.0);
    });
  });

  group('buildDbtSiPeakSeries', () {
    test('one bar per card; selfHarmAct flag carried', () {
      final card = DbtDiaryCard.blank(
        id: 'w1',
        patientId: 'p1',
        clinicianId: 'c1',
        weekOf: DateTime.utc(2026, 6, 22),
      );
      final updated = card.withDay(
        card.days.first.copyWith(
          targetBehaviorRatings: const {'si': 4, 'sh_act': 1},
        ),
      );
      final bars = buildDbtSiPeakSeries([updated]);
      expect(bars, hasLength(1));
      expect(bars.first.siPeak, 4);
      expect(bars.first.selfHarmAct, isTrue);
    });

    test('empty cards yield zero SI peak and no NSSI flag', () {
      final card = DbtDiaryCard.blank(
        id: 'w0',
        patientId: 'p1',
        clinicianId: 'c1',
        weekOf: DateTime.utc(2026, 6, 22),
      );
      final bars = buildDbtSiPeakSeries([card]);
      expect(bars.single.siPeak, 0);
      expect(bars.single.selfHarmAct, isFalse);
    });
  });

  group('buildEmdrSudsArcs', () {
    test('reduced=true when sudsEnd ≤ sudsStart', () {
      final s = EmdrSessionTracker(
        id: 'e1',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 22),
        sudsStart: 8,
        sudsEnd: 1,
      );
      final arc = buildEmdrSudsArcs([s]).single;
      expect(arc.delta, -7);
      expect(arc.reduced, isTrue);
    });

    test('reduced=false when SUDS climbed during the session', () {
      final s = EmdrSessionTracker(
        id: 'e2',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 22),
        sudsStart: 4,
        sudsEnd: 7,
      );
      final arc = buildEmdrSudsArcs([s]).single;
      expect(arc.delta, 3);
      expect(arc.reduced, isFalse);
    });

    test('delta is null when sudsEnd was never recorded', () {
      final s = EmdrSessionTracker(
        id: 'e3',
        patientId: 'p1',
        clinicianId: 'c1',
        createdAt: DateTime.utc(2026, 6, 22),
        sudsStart: 5,
      );
      final arc = buildEmdrSudsArcs([s]).single;
      expect(arc.delta, isNull);
      expect(arc.reduced, isFalse);
    });
  });
}
