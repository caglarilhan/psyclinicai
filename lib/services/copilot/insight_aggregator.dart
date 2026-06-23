/// Pure aggregator that turns recent per-patient activity into a
/// "since last visit" digest the clinician sees on the dashboard
/// tile + at the top of the session screen. No LLM, no PHI off
/// device — just a deterministic roll-up across the existing
/// repos.
library;

import '../../models/feedback_rating.dart';
import '../../models/medication_dose_log.dart';
import '../../models/medication_side_effect.dart';

/// One highlight surfaced in the digest. Stable id makes the
/// dashboard tile rebuild cheaply across renders.
class Insight {
  const Insight({
    required this.id,
    required this.headline,
    required this.detail,
    required this.severity,
    required this.kind,
  });

  final String id;
  final String headline;
  final String detail;
  final InsightSeverity severity;
  final InsightKind kind;
}

enum InsightSeverity { info, watch, concern }

enum InsightKind { fit, adherence, sideEffect, modality }

class BetweenSessionDigest {
  const BetweenSessionDigest({
    required this.insights,
    required this.windowStart,
    required this.windowEnd,
  });
  final List<Insight> insights;
  final DateTime windowStart;
  final DateTime windowEnd;

  /// Highest-severity tag in the bundle.
  InsightSeverity get topSeverity {
    if (insights.any((i) => i.severity == InsightSeverity.concern)) {
      return InsightSeverity.concern;
    }
    if (insights.any((i) => i.severity == InsightSeverity.watch)) {
      return InsightSeverity.watch;
    }
    return InsightSeverity.info;
  }

  bool get isEmpty => insights.isEmpty;
}

class InsightAggregator {
  const InsightAggregator();

  /// Build the digest for the window [from, to]. Inputs are
  /// already-loaded record lists — caller owns the repo I/O.
  BetweenSessionDigest digest({
    required DateTime from,
    required DateTime to,
    required List<FeedbackRating> ratings,
    required List<MedicationDoseLog> doses,
    required Iterable<MedicationSideEffect> sideEffects,
  }) {
    final insights = <Insight>[];
    insights.addAll(_fitInsights(ratings, from, to));
    insights.addAll(_adherenceInsights(doses, from, to));
    insights.addAll(_sideEffectInsights(sideEffects, from, to));
    return BetweenSessionDigest(
      insights: insights,
      windowStart: from,
      windowEnd: to,
    );
  }

  Iterable<Insight> _fitInsights(
    List<FeedbackRating> ratings,
    DateTime from,
    DateTime to,
  ) sync* {
    final inWindow =
        ratings
            .where(
              (r) => !r.capturedAt.isBefore(from) && !r.capturedAt.isAfter(to),
            )
            .toList()
          ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final orsList = inWindow.where((r) => r.kind == FitKind.ors).toList();
    if (orsList.length >= 2) {
      final last = orsList.last.total;
      final prev = orsList[orsList.length - 2].total;
      if ((prev - last) >= 5) {
        yield Insight(
          id: 'fit-ors-drop',
          headline: 'ORS dropped 5+ points',
          detail: 'Last two ORS scores: $prev -> $last. Miller dropout signal.',
          severity: InsightSeverity.concern,
          kind: InsightKind.fit,
        );
      }
    }
    if (orsList.isNotEmpty && orsList.last.isBelowCutoff) {
      yield Insight(
        id: 'fit-ors-cutoff',
        headline: 'ORS at or below clinical cutoff',
        detail: 'Latest ORS = ${orsList.last.total} / 40 (cutoff <= 25).',
        severity: InsightSeverity.concern,
        kind: InsightKind.fit,
      );
    }
  }

  Iterable<Insight> _adherenceInsights(
    List<MedicationDoseLog> doses,
    DateTime from,
    DateTime to,
  ) sync* {
    final scoped = doses
        .where(
          (d) => !d.scheduledAt.isBefore(from) && !d.scheduledAt.isAfter(to),
        )
        .toList();
    if (scoped.isEmpty) return;
    final summary = AdherenceSummary.compute(
      start: from,
      end: to,
      doses: scoped,
    );
    if (summary.scheduled == 0) return;
    final pct = summary.adherencePct;
    if (pct < 80) {
      yield Insight(
        id: 'mar-adherence-low',
        headline: 'Adherence below 80%',
        detail:
            '${summary.taken} of ${summary.scheduled - summary.skipped} '
            'taken since the last visit ($pct%).',
        severity: InsightSeverity.concern,
        kind: InsightKind.adherence,
      );
    } else if (pct < 90) {
      yield Insight(
        id: 'mar-adherence-watch',
        headline: 'Adherence drifted 80-89%',
        detail:
            '${summary.taken} of ${summary.scheduled - summary.skipped} '
            'taken ($pct%). Worth a brief check-in.',
        severity: InsightSeverity.watch,
        kind: InsightKind.adherence,
      );
    }
  }

  Iterable<Insight> _sideEffectInsights(
    Iterable<MedicationSideEffect> sideEffects,
    DateTime from,
    DateTime to,
  ) sync* {
    final scoped = sideEffects
        .where((e) => !e.reportedAt.isBefore(from) && !e.reportedAt.isAfter(to))
        .toList();
    if (scoped.isEmpty) return;
    final significant = scoped.where((e) => e.isClinicallySignificant).toList();
    if (significant.isNotEmpty) {
      yield Insight(
        id: 'se-significant',
        headline: '${significant.length} moderate+ side effect(s) reported',
        detail: significant
            .map((e) => '${e.symptom} (${e.severity.label.toLowerCase()})')
            .join(', '),
        severity: InsightSeverity.concern,
        kind: InsightKind.sideEffect,
      );
    } else {
      yield Insight(
        id: 'se-mild',
        headline: '${scoped.length} mild side effect(s) reported',
        detail: scoped.map((e) => e.symptom).toSet().join(', '),
        severity: InsightSeverity.watch,
        kind: InsightKind.sideEffect,
      );
    }
  }
}
