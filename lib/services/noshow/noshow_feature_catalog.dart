/// NS1 — No-show feature + recovery catalog (pinned helper, PILAR 3 / PR-1).
///
/// **Why this exists**: PILAR 3 ships a no-show predictor that turns
/// scheduled appointments into a risk-tiered queue with auto-recovery
/// playbooks. The catalog pins:
///   1. The feature set the predictor model is allowed to read — so a
///      future model bump cannot silently start consuming PHI it
///      shouldn't (HIPAA §164.502(b) minimum-necessary).
///   2. The risk tiers (low / medium / high) + the recovery playbook
///      attached to each tier (confirmation cadence, deposit hold,
///      waitlist offer cadence).
///   3. The win/loss labels the model trains on so retrains never
///      drift from production.
///
/// **Out of scope** (separate PRs):
///   * The actual logistic regression coefficients — those live in
///     `functions/src/lib/noshow_model.ts` (PR-2) so cost / accuracy
///     iteration does not require a Dart redeploy.
///   * SMS reminder adapter — Twilio relay ships in Sprint 33.
///   * Deposit hold integration — already wired in deposit_handler.ts
///     but the no-show predictor binds it in Sprint 34.
library;

enum NoShowRiskTier { low, medium, high }

enum FeatureKind { count, ratio, boolean, band }

enum PhiSensitivity { none, low, high }

class NoShowFeatureSpec {
  const NoShowFeatureSpec({
    required this.key,
    required this.label,
    required this.kind,
    required this.phiSensitivity,
    required this.rationale,
  });

  /// Stable feature key emitted in the predict-handler request body.
  final String key;
  final String label;
  final FeatureKind kind;

  /// `none` → counts only (history + same-day weather opt-in).
  /// `low`  → coarse demographic features (distance band).
  /// `high` → never read by the predictor.
  final PhiSensitivity phiSensitivity;
  final String rationale;
}

class NoShowRecoveryPlaybook {
  const NoShowRecoveryPlaybook({
    required this.tier,
    required this.confirmCadenceHours,
    required this.smsConfirmHours,
    required this.callConfirmHours,
    required this.depositRequired,
    required this.waitlistOfferOnCancel,
    required this.estUsdSavedPerSlot,
    required this.regulatoryRefs,
  });

  final NoShowRiskTier tier;

  /// Hours-before-appointment offsets when an SMS/email confirm fires.
  /// Sorted DESCENDING (earliest reminder first). Empty list = no
  /// proactive confirm.
  final List<int> confirmCadenceHours;

  final int smsConfirmHours;
  final int callConfirmHours;
  final bool depositRequired;
  final bool waitlistOfferOnCancel;
  final int estUsdSavedPerSlot;
  final List<String> regulatoryRefs;
}

class NoShowFeatureCatalog {
  const NoShowFeatureCatalog._();

  static const String lastReviewed = '2026-06';
  static const int schemaVersion = 1;

  /// Allowed feature set the predictor model can read. Append-only.
  static const List<NoShowFeatureSpec> features = [
    NoShowFeatureSpec(
      key: 'history_attended_count_90d',
      label: 'Attended appointments in last 90 days',
      kind: FeatureKind.count,
      phiSensitivity: PhiSensitivity.none,
      rationale: 'Strongest single predictor of show-up behaviour.',
    ),
    NoShowFeatureSpec(
      key: 'history_noshow_count_90d',
      label: 'No-shows in last 90 days',
      kind: FeatureKind.count,
      phiSensitivity: PhiSensitivity.none,
      rationale: 'Direct base-rate signal.',
    ),
    NoShowFeatureSpec(
      key: 'history_late_cancel_count_90d',
      label: 'Late cancellations in last 90 days',
      kind: FeatureKind.count,
      phiSensitivity: PhiSensitivity.none,
      rationale:
          'Late cancels correlate with future no-shows even when '
          'total attended count looks fine.',
    ),
    NoShowFeatureSpec(
      key: 'days_since_last_session',
      label: 'Days since the last attended session',
      kind: FeatureKind.count,
      phiSensitivity: PhiSensitivity.none,
      rationale: 'Gap from last contact is a strong drop-off signal.',
    ),
    NoShowFeatureSpec(
      key: 'is_first_session',
      label: 'First-ever session with this clinician',
      kind: FeatureKind.boolean,
      phiSensitivity: PhiSensitivity.none,
      rationale:
          'First-session no-show rate is roughly 2x the established '
          'patient rate per Mitchell et al. (2014).',
    ),
    NoShowFeatureSpec(
      key: 'lead_time_days_band',
      label: 'Days between booking and appointment',
      kind: FeatureKind.band,
      phiSensitivity: PhiSensitivity.none,
      rationale:
          'Longer lead times monotonically increase no-show probability.',
    ),
    NoShowFeatureSpec(
      key: 'slot_hour_band',
      label: 'Hour-of-day band (morning / midday / evening)',
      kind: FeatureKind.band,
      phiSensitivity: PhiSensitivity.none,
      rationale: 'Evening slots show ~1.4x no-show vs midday in our data.',
    ),
    NoShowFeatureSpec(
      key: 'weekday',
      label: 'Day of week (Mon..Sun)',
      kind: FeatureKind.band,
      phiSensitivity: PhiSensitivity.none,
      rationale: 'Monday + Friday slots skew higher.',
    ),
    NoShowFeatureSpec(
      key: 'modality',
      label: 'In-person vs telehealth',
      kind: FeatureKind.boolean,
      phiSensitivity: PhiSensitivity.none,
      rationale:
          'Telehealth slots no-show less in our cohort; controlled for '
          'distance band.',
    ),
    NoShowFeatureSpec(
      key: 'distance_band',
      label: 'Approximate travel distance band',
      kind: FeatureKind.band,
      phiSensitivity: PhiSensitivity.low,
      rationale:
          'Coarse band only — never the raw address. Drops out when '
          'modality == telehealth.',
    ),
    NoShowFeatureSpec(
      key: 'has_active_safety_plan',
      label: 'Patient has an active safety plan',
      kind: FeatureKind.boolean,
      phiSensitivity: PhiSensitivity.low,
      rationale:
          'Crisis-tier patients show up MORE reliably (the safety plan '
          'itself is a retention intervention).',
    ),
  ];

  /// Recovery playbook per risk tier.
  static const List<NoShowRecoveryPlaybook> playbooks = [
    NoShowRecoveryPlaybook(
      tier: NoShowRiskTier.low,
      confirmCadenceHours: [24],
      smsConfirmHours: 24,
      callConfirmHours: 0,
      depositRequired: false,
      waitlistOfferOnCancel: false,
      estUsdSavedPerSlot: 0,
      regulatoryRefs: ['Joint Commission scheduling efficiency'],
    ),
    NoShowRecoveryPlaybook(
      tier: NoShowRiskTier.medium,
      confirmCadenceHours: [48, 24, 4],
      smsConfirmHours: 24,
      callConfirmHours: 4,
      depositRequired: false,
      waitlistOfferOnCancel: true,
      estUsdSavedPerSlot: 60,
      regulatoryRefs: [
        'Joint Commission scheduling efficiency',
        'NIH PMC4574795 SMS reminders evidence',
      ],
    ),
    NoShowRecoveryPlaybook(
      tier: NoShowRiskTier.high,
      confirmCadenceHours: [72, 48, 24, 4, 1],
      smsConfirmHours: 24,
      callConfirmHours: 4,
      depositRequired: true,
      waitlistOfferOnCancel: true,
      estUsdSavedPerSlot: 120,
      regulatoryRefs: [
        'Joint Commission scheduling efficiency',
        'NIH PMC4574795 SMS reminders evidence',
      ],
    ),
  ];

  /// Labels the model trains on. Pinned so retrains never silently
  /// change the loss surface.
  static const Map<String, String> outcomeLabels = {
    'attended': 'Patient attended the appointment',
    'noshow': 'No-show (patient never arrived, no advance cancel)',
    'late_cancel': 'Cancelled <24h before the slot',
    'on_time_cancel': 'Cancelled >=24h before the slot',
    'rescheduled': 'Moved to a new slot before the original',
  };

  static NoShowFeatureSpec byKey(String key) {
    for (final f in features) {
      if (f.key == key) return f;
    }
    throw StateError('Unknown no-show feature key=$key');
  }

  static NoShowRecoveryPlaybook playbookFor(NoShowRiskTier tier) {
    for (final p in playbooks) {
      if (p.tier == tier) return p;
    }
    throw StateError('No playbook for tier $tier — catalog corrupt');
  }
}

/// Maps a probability to a tier. Pure for unit testing.
/// Boundaries chosen so the medium band targets the meaningful
/// recovery ROI without spamming low-risk patients.
NoShowRiskTier tierForProbability(double p) {
  if (p < 0.15) return NoShowRiskTier.low;
  if (p < 0.40) return NoShowRiskTier.medium;
  return NoShowRiskTier.high;
}
