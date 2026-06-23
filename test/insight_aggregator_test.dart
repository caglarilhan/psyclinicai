/// Coverage for InsightAggregator — FIT dropout + cutoff detection,
/// adherence band classification, side-effect severity routing,
/// topSeverity roll-up, window filter.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/feedback_rating.dart';
import 'package:psyclinicai/models/medication_dose_log.dart';
import 'package:psyclinicai/models/medication_side_effect.dart';
import 'package:psyclinicai/services/copilot/insight_aggregator.dart';

FeedbackRating _ors(int total, DateTime at) {
  final out = [0, 0, 0, 0];
  var rem = total;
  for (var i = 0; i < 4 && rem > 0; i++) {
    final v = rem > 10 ? 10 : rem;
    out[i] = v;
    rem -= v;
  }
  return FeedbackRating(
    id: 'ors-${at.millisecondsSinceEpoch}',
    sessionId: 's1',
    patientId: 'p1',
    clinicianId: 'c1',
    capturedAt: at,
    kind: FitKind.ors,
    scores: {
      FitItem.orsIndividual: out[0],
      FitItem.orsInterpersonal: out[1],
      FitItem.orsSocial: out[2],
      FitItem.orsOverall: out[3],
    },
  );
}

MedicationDoseLog _dose(DoseStatus s, DateTime at, {String id = 'd1'}) =>
    MedicationDoseLog(
      id: id,
      patientId: 'p1',
      medicationId: 'm1',
      scheduledAt: at,
      status: s,
    );

MedicationSideEffect _se({
  String id = 'se1',
  SideEffectSeverity severity = SideEffectSeverity.mild,
  DateTime? at,
}) => MedicationSideEffect(
  id: id,
  patientId: 'p1',
  medicationId: 'm1',
  clinicianId: 'c1',
  reportedAt: at ?? DateTime.utc(2026, 6, 22),
  symptom: 'Drowsiness',
  severity: severity,
);

void main() {
  const agg = InsightAggregator();
  final from = DateTime.utc(2026, 6, 16);
  final to = DateTime.utc(2026, 6, 23, 12);

  test('FIT dropout fires when ORS drops 5+ between last two', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: [
        _ors(34, DateTime.utc(2026, 6, 18)),
        _ors(28, DateTime.utc(2026, 6, 22)),
      ],
      doses: const [],
      sideEffects: const [],
    );
    expect(d.insights.map((i) => i.id), contains('fit-ors-drop'));
    expect(d.topSeverity, InsightSeverity.concern);
  });

  test('FIT cutoff fires when latest ORS <= 25', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: [_ors(20, DateTime.utc(2026, 6, 22))],
      doses: const [],
      sideEffects: const [],
    );
    expect(d.insights.map((i) => i.id), contains('fit-ors-cutoff'));
  });

  test('adherence 80% surfaces as watch', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: const [],
      doses: [
        _dose(DoseStatus.taken, DateTime.utc(2026, 6, 17), id: 'a'),
        _dose(DoseStatus.taken, DateTime.utc(2026, 6, 18), id: 'b'),
        _dose(DoseStatus.taken, DateTime.utc(2026, 6, 19), id: 'c'),
        _dose(DoseStatus.taken, DateTime.utc(2026, 6, 20), id: 'd'),
        _dose(DoseStatus.missed, DateTime.utc(2026, 6, 21), id: 'e'),
      ],
      sideEffects: const [],
    );
    expect(d.insights.map((i) => i.id), contains('mar-adherence-watch'));
  });

  test('moderate+ side effect surfaces as concern', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: const [],
      doses: const [],
      sideEffects: [
        _se(
          severity: SideEffectSeverity.moderate,
          at: DateTime.utc(2026, 6, 20),
        ),
      ],
    );
    final ids = d.insights.map((i) => i.id);
    expect(ids, contains('se-significant'));
    expect(d.topSeverity, InsightSeverity.concern);
  });

  test('mild side effects surface as watch', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: const [],
      doses: const [],
      sideEffects: [_se(at: DateTime.utc(2026, 6, 20))],
    );
    expect(d.insights.map((i) => i.id), contains('se-mild'));
    expect(d.topSeverity, InsightSeverity.watch);
  });

  test('window filter excludes records outside [from, to]', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: [_ors(20, DateTime.utc(2026, 5, 5))],
      doses: const [],
      sideEffects: const [],
    );
    expect(d.isEmpty, isTrue);
  });

  test('topSeverity bubbles concern across mixed insights', () {
    final d = agg.digest(
      from: from,
      to: to,
      ratings: const [],
      doses: const [],
      sideEffects: [
        _se(severity: SideEffectSeverity.severe, at: DateTime.utc(2026, 6, 20)),
        _se(id: 'se2', at: DateTime.utc(2026, 6, 21)),
      ],
    );
    expect(d.topSeverity, InsightSeverity.concern);
  });
}
