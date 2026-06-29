/// O6 — Feature flag registry (pinned helper).
///
/// **Why this exists**: feature flags are the primary tool for
/// dark launches, kill switches, and gradual rollouts. Without
/// a pinned registry, flags accumulate forever, owners forget
/// they shipped them, and a stale "experimental" flag becomes
/// load-bearing for a year before anyone notices. This catalog
/// pins per flag:
///   1. Stable key + owner (single accountable role).
///   2. Lifecycle stage (experimental / ramping / general /
///      deprecated) + expiry date for cleanup.
///   3. Whether the flag is a hard kill switch (no progressive
///      ramp; instant disable).
///   4. Kill criteria — what observable signal trips the switch.
///
/// **Distinct from**:
///   * O4 PricingTierCatalog: that pins tier-gated features (a
///     static "pilot includes X"); O6 pins runtime-toggleable
///     flags that may apply across tiers.
///   * D-09 `GROQ_PAID_TIER_ENABLED` kill switch (env var) — the
///     env-var pattern still works, but each new one lands here.
///
/// **Out of scope** (separate PRs):
///   * GrowthBook / Remote Config SDK wrap that reads from here.
///   * Expired-flag cleanup Cloud Function (warns owner 14d before
///     expiry; fails the build past expiry).
///   * Dashboard widget rendering the registry.
library;

/// Lifecycle stage of a flag.
enum FlagStage {
  /// Brand-new flag, off for everyone, used for dark-launch testing.
  experimental,

  /// Gradual rollout to a percentage of users.
  ramping,

  /// Fully on for everyone (or fully off if it is a "deprecated
  /// feature off" flag). Cleanup pending.
  general,

  /// Marked for removal; owner has a `deprecatedOn` date.
  deprecated,
}

/// Why the flag exists — drives the cleanup conversation.
enum FlagPurpose {
  /// True kill switch — no ramp, instant disable for safety.
  killSwitch,

  /// Progressive rollout of a new feature.
  progressiveRollout,

  /// Per-tenant override (a specific clinic asked for early access).
  tenantOverride,

  /// Permanent toggle (e.g. test-mode flag for CI).
  permanentToggle,
}

/// One pinned flag record.
class FeatureFlagRecord {
  const FeatureFlagRecord({
    required this.key,
    required this.description,
    required this.owner,
    required this.purpose,
    required this.stage,
    required this.createdIso,
    required this.expiresIso,
    required this.killCriteria,
  });

  /// Stable flag key (snake_case). Drives both the SDK lookup +
  /// the analytics exposure event name.
  final String key;

  /// One-line plain-English description.
  final String description;

  /// Single accountable role.
  final String owner;

  final FlagPurpose purpose;
  final FlagStage stage;

  /// ISO `YYYY-MM-DD` when the flag was first added.
  final String createdIso;

  /// ISO `YYYY-MM-DD` after which the cleanup cron fails the build.
  /// `permanentToggle` flags get a 5-year horizon so the test
  /// invariant still applies.
  final String expiresIso;

  /// One-line description of the observable signal that trips a
  /// kill switch (e.g. "audit chain hash mismatch detected").
  /// Required for kill switches; empty allowed elsewhere.
  final String killCriteria;
}

class FeatureFlagRegistry {
  const FeatureFlagRegistry._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned flags. Append-only — deprecated flags stay so historic
  /// SDK lookups still resolve.
  static const List<FeatureFlagRecord> flags = [
    FeatureFlagRecord(
      key: 'kill_groq_paid_tier',
      description: 'Disable Groq paid-tier LLM calls instantly on cost spike.',
      owner: 'cfo',
      purpose: FlagPurpose.killSwitch,
      stage: FlagStage.general,
      createdIso: '2026-05-01',
      expiresIso: '2031-05-01',
      killCriteria:
          'Daily Groq spend > 2x rolling 7-day median OR cost-anomaly '
          'cron alert fires.',
    ),
    FeatureFlagRecord(
      key: 'kill_ai_relay_global',
      description:
          'Master kill for all LLM relay (Anthropic + Groq + OpenAI) — '
          'flips to local rule-only mode.',
      owner: 'ciso',
      purpose: FlagPurpose.killSwitch,
      stage: FlagStage.general,
      createdIso: '2026-05-01',
      expiresIso: '2031-05-01',
      killCriteria:
          'Vendor breach disclosure OR sustained PHI-flag escape rate > 1% '
          'over 1h.',
    ),
    FeatureFlagRecord(
      key: 'rollout_telehealth_video',
      description: 'Progressive rollout of Daily.co video for pilot tenants.',
      owner: 'cto',
      purpose: FlagPurpose.progressiveRollout,
      stage: FlagStage.ramping,
      createdIso: '2026-06-01',
      expiresIso: '2026-12-31',
      killCriteria: '',
    ),
    FeatureFlagRecord(
      key: 'rollout_ai_soap_draft',
      description: 'Progressive rollout of the AI SOAP draft feature.',
      owner: 'cto',
      purpose: FlagPurpose.progressiveRollout,
      stage: FlagStage.ramping,
      createdIso: '2026-06-01',
      expiresIso: '2026-12-31',
      killCriteria: '',
    ),
    FeatureFlagRecord(
      key: 'tenant_override_cssrs_decision_support',
      description:
          'Early access to the CSSRS decision-support card for named '
          'pilot clinics.',
      owner: 'clinical_advisor',
      purpose: FlagPurpose.tenantOverride,
      stage: FlagStage.experimental,
      createdIso: '2026-06-01',
      expiresIso: '2026-09-30',
      killCriteria: '',
    ),
    FeatureFlagRecord(
      key: 'permanent_test_mode',
      description:
          'CI / dev-environment marker; never true in production builds.',
      owner: 'cto',
      purpose: FlagPurpose.permanentToggle,
      stage: FlagStage.general,
      createdIso: '2026-05-01',
      expiresIso: '2031-05-01',
      killCriteria: '',
    ),
  ];

  static FeatureFlagRecord? byKey(String key) {
    for (final f in flags) {
      if (f.key == key) return f;
    }
    return null;
  }

  static List<FeatureFlagRecord> byStage(FlagStage stage) {
    return flags.where((f) => f.stage == stage).toList();
  }

  static List<FeatureFlagRecord> killSwitches() {
    return flags.where((f) => f.purpose == FlagPurpose.killSwitch).toList();
  }
}

/// Days remaining until the flag's pinned expiry date given [today].
/// Negative = past expiry; cron uses this to break the build.
int daysUntilFlagExpiry(FeatureFlagRecord flag, DateTime today) {
  final exp = DateTime.parse(flag.expiresIso);
  return exp.difference(today).inDays;
}

/// True when the flag is past its pinned expiry (auto-cleanup).
bool isFlagExpired(FeatureFlagRecord flag, DateTime today) =>
    daysUntilFlagExpiry(flag, today) < 0;
