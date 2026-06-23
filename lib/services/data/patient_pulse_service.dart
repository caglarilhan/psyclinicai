/// Pure helpers that roll up a patient's pulse — the single
/// "is this patient OK right now?" view a clinician glances at
/// before the next visit. Combines four signals that are already
/// captured but live in separate screens:
///
///   1. FIT alliance/outcome (ORS + SRS) — latest score + dropout
///      flag.
///   2. Medication adherence (MAR) — taken / scheduled over the
///      last 30 days.
///   3. ADHD subtype call (Vanderbilt) — combined / inattentive /
///      hyperactive-impulsive / none.
///   4. Side-effect burden — ongoing count + clinically-significant
///      count.
///
/// No widgets here — the screen file consumes these data classes
/// and renders them. This module is unit-testable end-to-end
/// without Flutter test bindings.
library;

import '../../models/feedback_rating.dart';
import '../../models/medication_dose_log.dart';
import '../../models/medication_side_effect.dart';
import '../../models/vanderbilt_assessment.dart';

enum PulseSignal { ok, watch, concern }

class FitPulse {
  const FitPulse({
    required this.latestOrs,
    required this.latestSrs,
    required this.dropoutSignal,
  });

  /// Latest ORS total in the patient's history. Null when never
  /// captured. Cutoff = ≤25 in `FeedbackRating.isBelowCutoff`.
  final FeedbackRating? latestOrs;

  /// Latest SRS total. Null when never captured. Cutoff = ≤36.
  final FeedbackRating? latestSrs;

  /// True when the two most recent ORS totals dropped ≥ 5 points
  /// (Miller's reliable-change threshold).
  final bool dropoutSignal;

  PulseSignal get signal {
    if (dropoutSignal) return PulseSignal.concern;
    if (latestOrs?.isBelowCutoff == true) return PulseSignal.concern;
    if (latestSrs?.isBelowCutoff == true) return PulseSignal.watch;
    if (latestOrs == null && latestSrs == null) return PulseSignal.watch;
    return PulseSignal.ok;
  }
}

class AdherencePulse {
  const AdherencePulse({required this.summary});
  final AdherenceSummary summary;

  PulseSignal get signal {
    if (summary.scheduled == 0) return PulseSignal.watch;
    final pct = summary.adherencePct;
    if (pct < 80) return PulseSignal.concern;
    if (pct < 90) return PulseSignal.watch;
    return PulseSignal.ok;
  }
}

class TolerabilityPulse {
  const TolerabilityPulse({required this.summary});
  final SideEffectSummary summary;

  PulseSignal get signal {
    if (summary.clinicallySignificant > 0) return PulseSignal.concern;
    if (summary.ongoing > 0) return PulseSignal.watch;
    return PulseSignal.ok;
  }
}

class AdhdPulse {
  const AdhdPulse({this.subtype, this.respondentsCovered = 0});
  final VanderbiltSubtype? subtype;

  /// 0, 1, or 2 — how many respondent types (parent, teacher) the
  /// clinician has captured. DSM-5 wants both for a diagnosis.
  final int respondentsCovered;

  PulseSignal get signal {
    if (subtype == null) return PulseSignal.watch;
    if (respondentsCovered < 2) return PulseSignal.watch;
    if (subtype == VanderbiltSubtype.none) return PulseSignal.ok;
    return PulseSignal.concern;
  }
}

class PatientPulse {
  const PatientPulse({
    required this.patientId,
    required this.fit,
    required this.adherence,
    required this.tolerability,
    required this.adhd,
  });

  final String patientId;
  final FitPulse fit;
  final AdherencePulse adherence;
  final TolerabilityPulse tolerability;
  final AdhdPulse adhd;

  /// Worst-of-four bubble. The header chip shows this so the
  /// clinician knows at a glance whether to dig in.
  PulseSignal get overall {
    final all = [
      fit.signal,
      adherence.signal,
      tolerability.signal,
      adhd.signal,
    ];
    if (all.contains(PulseSignal.concern)) return PulseSignal.concern;
    if (all.contains(PulseSignal.watch)) return PulseSignal.watch;
    return PulseSignal.ok;
  }
}

class PatientPulseService {
  /// Roll up a single-patient pulse from already-loaded records.
  /// Pure synchronous helper so the screen can call it after the
  /// async repo loads finish.
  ///
  /// `now` is injectable for deterministic tests.
  static PatientPulse compute({
    required String patientId,
    required List<FeedbackRating> ratings,
    required List<MedicationDoseLog> doses,
    required Iterable<MedicationSideEffect> sideEffects,
    VanderbiltAssessment? latestParent,
    VanderbiltAssessment? latestTeacher,
    int adherenceWindowDays = 30,
    DateTime? now,
  }) {
    final asOf = now ?? DateTime.now().toUtc();
    final orsList =
        ratings
            .where((r) => r.patientId == patientId && r.kind == FitKind.ors)
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final srsList =
        ratings
            .where((r) => r.patientId == patientId && r.kind == FitKind.srs)
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    var dropout = false;
    if (orsList.length >= 2) {
      final last = orsList.last.total;
      final prev = orsList[orsList.length - 2].total;
      dropout = (prev - last) >= 5;
    }

    final fit = FitPulse(
      latestOrs: orsList.isEmpty ? null : orsList.last,
      latestSrs: srsList.isEmpty ? null : srsList.last,
      dropoutSignal: dropout,
    );

    final windowStart = asOf.subtract(Duration(days: adherenceWindowDays));
    final scopedDoses = doses
        .where((d) => d.patientId == patientId)
        .where(
          (d) =>
              !d.scheduledAt.isBefore(windowStart) &&
              !d.scheduledAt.isAfter(asOf),
        )
        .toList();
    final adherence = AdherencePulse(
      summary: AdherenceSummary.compute(
        start: windowStart,
        end: asOf,
        doses: scopedDoses,
      ),
    );

    final scopedSe = sideEffects.where((e) => e.patientId == patientId);
    final tolerability = TolerabilityPulse(
      summary: SideEffectSummary.compute(scopedSe),
    );

    var respondents = 0;
    if (latestParent != null) respondents++;
    if (latestTeacher != null) respondents++;
    final subtype = latestParent?.subtype ?? latestTeacher?.subtype;
    final adhd = AdhdPulse(subtype: subtype, respondentsCovered: respondents);

    return PatientPulse(
      patientId: patientId,
      fit: fit,
      adherence: adherence,
      tolerability: tolerability,
      adhd: adhd,
    );
  }
}
