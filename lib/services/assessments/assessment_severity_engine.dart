/// Maps a raw assessment score onto its severity band + a
/// human-readable recommendation list (plan §C).
///
/// One engine call per submitted assessment. The result feeds the
/// AssessmentResultScreen (`/assessments/:scale/:id/result`).
///
/// Pure — no I/O, no Flutter dependency.
library;

enum AssessmentInstrument {
  phq9('phq9'),
  cssrs('cssrs'),
  pcl5('pcl5'),
  audit('audit');

  const AssessmentInstrument(this.id);
  final String id;

  static AssessmentInstrument? tryFromId(String id) {
    for (final i in AssessmentInstrument.values) {
      if (i.id == id) return i;
    }
    return null;
  }
}

class SeverityBand {
  const SeverityBand({
    required this.label,
    required this.minInclusive,
    required this.maxInclusive,
    required this.isClinicalConcern,
  });

  final String label;
  final int minInclusive;
  final int maxInclusive;

  /// True when the band is at or above the "moderate" line and the
  /// UI should colour the score red / amber rather than green.
  final bool isClinicalConcern;
}

class AssessmentResult {
  const AssessmentResult({
    required this.instrument,
    required this.score,
    required this.band,
    required this.recommendations,
    this.deltaVsPrevious,
  });

  final AssessmentInstrument instrument;
  final int score;
  final SeverityBand band;

  /// Plain-English follow-ups the clinician can pick from. The first
  /// entry is the highest-priority action.
  final List<String> recommendations;

  /// `score - previousScore` when the engine was given a previous
  /// value; null otherwise. Negative = improvement (lower symptom
  /// burden); positive = worsening.
  final int? deltaVsPrevious;

  bool get isImproving =>
      deltaVsPrevious != null && deltaVsPrevious! < 0;

  bool get isWorsening =>
      deltaVsPrevious != null && deltaVsPrevious! > 0;
}

class AssessmentSeverityEngine {
  const AssessmentSeverityEngine();

  /// Evaluate a single submitted score. `previousScore` is optional
  /// (the trend delta is null when omitted).
  AssessmentResult evaluate({
    required AssessmentInstrument instrument,
    required int score,
    int? previousScore,
  }) {
    final bands = _bandsFor(instrument);
    final band = bands.firstWhere(
      (b) => score >= b.minInclusive && score <= b.maxInclusive,
      orElse: () => bands.last,
    );
    return AssessmentResult(
      instrument: instrument,
      score: score,
      band: band,
      recommendations: _recommendations(instrument, band),
      deltaVsPrevious:
          previousScore == null ? null : score - previousScore,
    );
  }

  /// Band table for the instrument. Pure data — exposed so the UI
  /// can render the full table next to the score.
  List<SeverityBand> bandsFor(AssessmentInstrument instrument) =>
      _bandsFor(instrument);

  static const _phq9Bands = <SeverityBand>[
    SeverityBand(
      label: 'minimal',
      minInclusive: 0,
      maxInclusive: 4,
      isClinicalConcern: false,
    ),
    SeverityBand(
      label: 'mild',
      minInclusive: 5,
      maxInclusive: 9,
      isClinicalConcern: false,
    ),
    SeverityBand(
      label: 'moderate',
      minInclusive: 10,
      maxInclusive: 14,
      isClinicalConcern: true,
    ),
    SeverityBand(
      label: 'moderately severe',
      minInclusive: 15,
      maxInclusive: 19,
      isClinicalConcern: true,
    ),
    SeverityBand(
      label: 'severe',
      minInclusive: 20,
      maxInclusive: 27,
      isClinicalConcern: true,
    ),
  ];

  static const _cssrsBands = <SeverityBand>[
    SeverityBand(
      label: 'low',
      minInclusive: 0,
      maxInclusive: 0,
      isClinicalConcern: false,
    ),
    SeverityBand(
      label: 'moderate',
      minInclusive: 1,
      maxInclusive: 2,
      isClinicalConcern: true,
    ),
    SeverityBand(
      label: 'high',
      minInclusive: 3,
      maxInclusive: 5,
      isClinicalConcern: true,
    ),
  ];

  static const _pcl5Bands = <SeverityBand>[
    SeverityBand(
      label: 'unlikely PTSD',
      minInclusive: 0,
      maxInclusive: 30,
      isClinicalConcern: false,
    ),
    SeverityBand(
      label: 'probable PTSD (boundary)',
      minInclusive: 31,
      maxInclusive: 32,
      isClinicalConcern: true,
    ),
    SeverityBand(
      label: 'probable PTSD',
      minInclusive: 33,
      maxInclusive: 80,
      isClinicalConcern: true,
    ),
  ];

  static const _auditBands = <SeverityBand>[
    SeverityBand(
      label: 'low risk',
      minInclusive: 0,
      maxInclusive: 7,
      isClinicalConcern: false,
    ),
    SeverityBand(
      label: 'hazardous',
      minInclusive: 8,
      maxInclusive: 15,
      isClinicalConcern: true,
    ),
    SeverityBand(
      label: 'harmful',
      minInclusive: 16,
      maxInclusive: 19,
      isClinicalConcern: true,
    ),
    SeverityBand(
      label: 'dependence likely',
      minInclusive: 20,
      maxInclusive: 40,
      isClinicalConcern: true,
    ),
  ];

  List<SeverityBand> _bandsFor(AssessmentInstrument instrument) {
    switch (instrument) {
      case AssessmentInstrument.phq9:
        return _phq9Bands;
      case AssessmentInstrument.cssrs:
        return _cssrsBands;
      case AssessmentInstrument.pcl5:
        return _pcl5Bands;
      case AssessmentInstrument.audit:
        return _auditBands;
    }
  }

  List<String> _recommendations(
    AssessmentInstrument instrument,
    SeverityBand band,
  ) {
    if (!band.isClinicalConcern) {
      return const [
        'Continue routine monitoring; rescreen at the next visit.',
      ];
    }
    switch (instrument) {
      case AssessmentInstrument.phq9:
        return const [
          'Review item 9 (self-harm ideation) and run the C-SSRS.',
          'Revisit the safety plan with the patient.',
          'Consider a stepped-care referral if the score is severe.',
        ];
      case AssessmentInstrument.cssrs:
        return const [
          'Open the crisis-resource modal and document a decision.',
          'Update the Stanley-Brown safety plan and means-restriction.',
          'Escalate to on-call psychiatrist if active ideation with plan.',
        ];
      case AssessmentInstrument.pcl5:
        return const [
          'Review trauma history and confirm DSM-5 criteria.',
          'Consider trauma-focused CBT or EMDR referral.',
        ];
      case AssessmentInstrument.audit:
        return const [
          'Brief intervention; revisit motivational stage.',
          'Refer to addiction services for harmful / dependence bands.',
        ];
    }
  }
}
