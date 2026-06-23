/// Coverage for PatientPulseService — the four pulse signals
/// (FIT, adherence, tolerability, ADHD subtype) and the overall
/// worst-of-four bubble.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/feedback_rating.dart';
import 'package:psyclinicai/models/medication_dose_log.dart';
import 'package:psyclinicai/models/medication_side_effect.dart';
import 'package:psyclinicai/models/vanderbilt_assessment.dart';
import 'package:psyclinicai/services/data/patient_pulse_service.dart';

List<int> _split(int total) {
  final out = [0, 0, 0, 0];
  var rem = total;
  for (var i = 0; i < 4 && rem > 0; i++) {
    final v = rem > 10 ? 10 : rem;
    out[i] = v;
    rem -= v;
  }
  return out;
}

FeedbackRating _ors(int total, DateTime at, {String patientId = 'p1'}) {
  final s = _split(total);
  return FeedbackRating(
    id: 'ors-${at.millisecondsSinceEpoch}',
    sessionId: 's1',
    patientId: patientId,
    clinicianId: 'c1',
    capturedAt: at,
    kind: FitKind.ors,
    scores: {
      FitItem.orsIndividual: s[0],
      FitItem.orsInterpersonal: s[1],
      FitItem.orsSocial: s[2],
      FitItem.orsOverall: s[3],
    },
  );
}

FeedbackRating _srs(int total, DateTime at) {
  final s = _split(total);
  return FeedbackRating(
    id: 'srs-${at.millisecondsSinceEpoch}',
    sessionId: 's1',
    patientId: 'p1',
    clinicianId: 'c1',
    capturedAt: at,
    kind: FitKind.srs,
    scores: {
      FitItem.srsRelationship: s[0],
      FitItem.srsGoals: s[1],
      FitItem.srsApproach: s[2],
      FitItem.srsOverall: s[3],
    },
  );
}

MedicationDoseLog _dose({
  required String id,
  required DoseStatus status,
  required DateTime when,
}) => MedicationDoseLog(
  id: id,
  patientId: 'p1',
  medicationId: 'm1',
  scheduledAt: when,
  status: status,
);

MedicationSideEffect _se({
  required String id,
  SideEffectSeverity severity = SideEffectSeverity.mild,
  DateTime? resolved,
}) => MedicationSideEffect(
  id: id,
  patientId: 'p1',
  medicationId: 'm1',
  clinicianId: 'c1',
  reportedAt: DateTime.utc(2026, 6, 23),
  symptom: 'Headache',
  severity: severity,
  resolvedAt: resolved,
);

VanderbiltAssessment _vandy(
  VanderbiltRespondent r, {
  bool meetsInattn = false,
  bool meetsImpairment = false,
}) => VanderbiltAssessment(
  id: 'v-${r.id}',
  patientId: 'p1',
  clinicianId: 'c1',
  respondent: r,
  capturedAt: DateTime.utc(2026, 6, 20),
  inattention: meetsInattn
      ? const [2, 2, 2, 2, 2, 2, 0, 0, 0]
      : const [0, 0, 0, 0, 0, 0, 0, 0, 0],
  performance: meetsImpairment
      ? const [1, 1, 1, 4, 1, 1, 1, 1]
      : const [1, 1, 1, 1, 1, 1, 1, 1],
);

void main() {
  final now = DateTime.utc(2026, 6, 23, 12);

  group('FitPulse', () {
    test('dropout signal fires on >=5-point ORS drop', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: [
          _ors(34, DateTime.utc(2026, 6, 2)),
          _ors(28, DateTime.utc(2026, 6, 15)),
        ],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.fit.dropoutSignal, isTrue);
      expect(pulse.fit.signal, PulseSignal.concern);
    });

    test('below ORS cutoff is concern even without prior drop', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: [_ors(20, now)],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.fit.dropoutSignal, isFalse);
      expect(pulse.fit.signal, PulseSignal.concern);
    });

    test('SRS below cutoff is watch (alliance signal, not crisis)', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: [_ors(35, now), _srs(30, now)],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.fit.signal, PulseSignal.watch);
    });

    test('no FIT data is watch', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.fit.signal, PulseSignal.watch);
    });
  });

  group('AdherencePulse', () {
    test('100% adherence is ok', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: List.generate(
          10,
          (i) => _dose(
            id: 'd$i',
            status: DoseStatus.taken,
            when: now.subtract(Duration(days: i + 1)),
          ),
        ),
        sideEffects: const [],
        now: now,
      );
      expect(pulse.adherence.summary.adherencePct, 100);
      expect(pulse.adherence.signal, PulseSignal.ok);
    });

    test('below 80 is concern, 80-89 is watch', () {
      final doses = [
        for (var i = 0; i < 7; i++)
          _dose(
            id: 't$i',
            status: DoseStatus.taken,
            when: now.subtract(Duration(days: i + 1)),
          ),
        for (var i = 0; i < 3; i++)
          _dose(
            id: 'm$i',
            status: DoseStatus.missed,
            when: now.subtract(Duration(days: i + 8)),
          ),
      ];
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: doses,
        sideEffects: const [],
        now: now,
      );
      expect(pulse.adherence.summary.adherencePct, 70);
      expect(pulse.adherence.signal, PulseSignal.concern);
    });

    test('nothing scheduled is watch (no MAR data yet)', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.adherence.summary.scheduled, 0);
      expect(pulse.adherence.signal, PulseSignal.watch);
    });
  });

  group('TolerabilityPulse', () {
    test('moderate+ SE is concern', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: [_se(id: 'a', severity: SideEffectSeverity.moderate)],
        now: now,
      );
      expect(pulse.tolerability.signal, PulseSignal.concern);
    });

    test('only mild ongoing is watch', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: [_se(id: 'a')],
        now: now,
      );
      expect(pulse.tolerability.signal, PulseSignal.watch);
    });

    test('all resolved is ok', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: [_se(id: 'a', resolved: DateTime.utc(2026, 6, 2))],
        now: now,
      );
      expect(pulse.tolerability.signal, PulseSignal.ok);
    });
  });

  group('AdhdPulse', () {
    test('only one respondent is watch, even if subtype is none', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: const [],
        latestParent: _vandy(VanderbiltRespondent.parent),
        now: now,
      );
      expect(pulse.adhd.respondentsCovered, 1);
      expect(pulse.adhd.signal, PulseSignal.watch);
    });

    test('both respondents + positive subtype is concern', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: const [],
        latestParent: _vandy(
          VanderbiltRespondent.parent,
          meetsInattn: true,
          meetsImpairment: true,
        ),
        latestTeacher: _vandy(
          VanderbiltRespondent.teacher,
          meetsInattn: true,
          meetsImpairment: true,
        ),
        now: now,
      );
      expect(pulse.adhd.subtype, VanderbiltSubtype.inattentive);
      expect(pulse.adhd.signal, PulseSignal.concern);
    });

    test('no Vanderbilt data is watch', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: const [],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.adhd.signal, PulseSignal.watch);
    });
  });

  group('PatientPulse.overall', () {
    test('worst-of-four bubbles concern up', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: [_ors(20, now)],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.overall, PulseSignal.concern);
    });

    test('all signals ok bubble ok', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: [_ors(35, now), _srs(38, now)],
        doses: List.generate(
          10,
          (i) => _dose(
            id: 'd$i',
            status: DoseStatus.taken,
            when: now.subtract(Duration(days: i + 1)),
          ),
        ),
        sideEffects: [_se(id: 'a', resolved: DateTime.utc(2026, 6, 2))],
        latestParent: _vandy(VanderbiltRespondent.parent),
        latestTeacher: _vandy(VanderbiltRespondent.teacher),
        now: now,
      );
      expect(pulse.fit.signal, PulseSignal.ok);
      expect(pulse.adherence.signal, PulseSignal.ok);
      expect(pulse.tolerability.signal, PulseSignal.ok);
      expect(pulse.adhd.signal, PulseSignal.ok);
      expect(pulse.overall, PulseSignal.ok);
    });

    test('scoping by patientId excludes other patients data', () {
      final pulse = PatientPulseService.compute(
        patientId: 'p1',
        ratings: [_ors(10, now, patientId: 'other')],
        doses: const [],
        sideEffects: const [],
        now: now,
      );
      expect(pulse.fit.latestOrs, isNull);
    });
  });
}
