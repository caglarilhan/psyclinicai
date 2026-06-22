/// No-show risk scorer for the appointments view. Rapor 12 cpo-advisor
/// finding: random reminders cannot compete; risk-tiered cadence does.
///
/// Rule-based for now; the ML model behind a Cloud Function lands
/// when we have 30+ days of real labels.
library;

enum NoShowRisk {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const NoShowRisk(this.id, this.label);
  final String id;
  final String label;
}

class NoShowPredictionInput {
  const NoShowPredictionInput({
    required this.patientId,
    required this.scheduledFor,
    required this.now,
    required this.historicalNoShowCount,
    required this.historicalAttendedCount,
    required this.daysSinceLastVisit,
    this.isNewPatient = false,
    this.isMonday = false,
    this.isWinterStormForecast = false,
  });

  final String patientId;
  final DateTime scheduledFor;
  final DateTime now;
  final int historicalNoShowCount;
  final int historicalAttendedCount;
  final int daysSinceLastVisit;
  final bool isNewPatient;
  final bool isMonday;
  final bool isWinterStormForecast;

  double get historicalNoShowRate {
    final total = historicalNoShowCount + historicalAttendedCount;
    if (total == 0) return 0.15;
    return historicalNoShowCount / total;
  }
}

class NoShowPrediction {
  const NoShowPrediction({
    required this.risk,
    required this.score,
    required this.reasons,
  });

  final NoShowRisk risk;
  final double score;
  final List<String> reasons;
}

class NoShowPredictor {
  static const _mediumCutoff = 0.30;
  static const _highCutoff = 0.55;

  NoShowPrediction predict(NoShowPredictionInput x) {
    final reasons = <String>[];
    var score = x.historicalNoShowRate;
    if (x.historicalNoShowRate > 0.20) {
      reasons.add(
        'Historical no-show rate ${(x.historicalNoShowRate * 100).round()}%',
      );
    }

    if (x.isNewPatient) {
      score += 0.10;
      reasons.add('First visit (no history to anchor on)');
    }
    if (x.daysSinceLastVisit >= 60) {
      score += 0.10;
      reasons.add(
        'Last visit ${x.daysSinceLastVisit} days ago — engagement drift',
      );
    }
    if (x.isMonday) {
      score += 0.05;
      reasons.add('Monday slot (statistically higher no-show rate)');
    }
    if (x.isWinterStormForecast) {
      score += 0.10;
      reasons.add('Winter weather alert for the slot window');
    }
    final hour = x.scheduledFor.hour;
    if (hour < 9 || hour >= 18) {
      score += 0.05;
      reasons.add('Off-peak hour (before 09:00 or after 18:00)');
    }

    score = score.clamp(0.0, 1.0);
    final tier = score >= _highCutoff
        ? NoShowRisk.high
        : score >= _mediumCutoff
        ? NoShowRisk.medium
        : NoShowRisk.low;
    return NoShowPrediction(
      risk: tier,
      score: score,
      reasons: List.unmodifiable(reasons),
    );
  }
}
