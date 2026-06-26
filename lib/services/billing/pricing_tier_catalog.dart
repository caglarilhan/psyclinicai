/// O4 — Pricing tier catalog (pinned helper).
///
/// **Why this exists**: today the pricing page renders tiers from
/// a private `_Tier` class inside the UI widget, and the Stripe
/// price-id mapping is hard-coded in a Cloud Function. Sales decks,
/// the customer DPA, the support escalation matrix (M3), and the
/// trust page each duplicate the per-tier numbers. Pinning the
/// catalog here means:
///   1. The pricing page renders from one source.
///   2. Stripe price-id lookup picks the right id per tier without
///      a hard-coded map.
///   3. M3 customer support escalation matrix can validate that
///      every tier in this catalog has a matching SupportTier row
///      (parity test).
///
/// **Out of scope** (separate PRs):
///   * Refactor `pricing_section.dart` to read from this catalog.
///   * Stripe price-id sync Cloud Function.
///   * Per-tier feature gate runtime checks.
library;

/// Customer-facing tier. MUST match `SupportTier` in M3
/// (support_escalation_matrix.dart) so the parity test holds.
enum PricingTier { free, pilot, enterprise }

/// Billing cadence.
enum BillingCycle { perMonth, perYear }

/// One pinned tier record.
class PricingTierRecord {
  const PricingTierRecord({
    required this.tier,
    required this.publicName,
    required this.priceEurMonth,
    required this.includedSeats,
    required this.maxSeats,
    required this.trialDays,
    required this.billingCycle,
    required this.includedFeatures,
    required this.excludedFeatures,
    required this.stripePriceIdKey,
  });

  final PricingTier tier;

  /// Marketing name shown on the pricing page (e.g. "Pilot",
  /// "Enterprise"). Localised separately.
  final String publicName;

  /// Headline price in EUR per month. `0` for free; positive for
  /// paid. Price-string parity with the pricing page is enforced
  /// by the renderer test, not here (this is the numeric source
  /// of truth).
  final int priceEurMonth;

  /// Number of clinician seats the headline price covers.
  final int includedSeats;

  /// Hard cap on seats per tier. `0` for unlimited (enterprise).
  /// Drives the seat-add UI gate.
  final int maxSeats;

  /// Free trial duration in days. `0` for tiers that have no trial
  /// (free is already free; enterprise is contract-only).
  final int trialDays;

  final BillingCycle billingCycle;

  /// Stable feature ids the tier includes. Mirrors the feature-
  /// flag registry (future); for now a free-form list pinned by
  /// the marketing team + tests.
  final List<String> includedFeatures;

  /// Stable feature ids the tier explicitly does NOT include.
  /// Used by the gate so a free user can't sneak into a paid
  /// feature via deep-link.
  final List<String> excludedFeatures;

  /// Key the Stripe price-id sync function uses to resolve the
  /// per-region Stripe `price_...` id. Stable across price
  /// changes; bumped on a new tier add.
  final String stripePriceIdKey;
}

class PricingTierCatalog {
  const PricingTierCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned tier records. Order = PricingTier.values; parity is
  /// pinned by a test.
  static const List<PricingTierRecord> tiers = [
    PricingTierRecord(
      tier: PricingTier.free,
      publicName: 'Free',
      priceEurMonth: 0,
      includedSeats: 1,
      maxSeats: 1,
      trialDays: 0,
      billingCycle: BillingCycle.perMonth,
      includedFeatures: [
        'clinician_workspace_basic',
        'rag_console_read',
        'cookie_essentials',
      ],
      excludedFeatures: [
        'ai_soap_draft',
        'telehealth_video',
        'audit_log_export',
        'dsar_export',
        'priority_support',
        'sso_saml',
      ],
      stripePriceIdKey: 'free',
    ),
    PricingTierRecord(
      tier: PricingTier.pilot,
      publicName: 'Pilot',
      priceEurMonth: 49,
      includedSeats: 3,
      maxSeats: 10,
      trialDays: 14,
      billingCycle: BillingCycle.perMonth,
      includedFeatures: [
        'clinician_workspace_basic',
        'clinician_workspace_advanced',
        'rag_console_read',
        'rag_console_write',
        'ai_soap_draft',
        'telehealth_video',
        'audit_log_export',
        'dsar_export',
      ],
      excludedFeatures: ['priority_support', 'sso_saml', 'baa_signed'],
      stripePriceIdKey: 'pilot_monthly_eur',
    ),
    PricingTierRecord(
      tier: PricingTier.enterprise,
      publicName: 'Enterprise',
      // contract-only; renderer shows "Contact us".
      priceEurMonth: 0,
      includedSeats: 10,
      // unlimited.
      maxSeats: 0,
      trialDays: 0,
      billingCycle: BillingCycle.perYear,
      includedFeatures: [
        'clinician_workspace_basic',
        'clinician_workspace_advanced',
        'rag_console_read',
        'rag_console_write',
        'ai_soap_draft',
        'telehealth_video',
        'audit_log_export',
        'dsar_export',
        'priority_support',
        'sso_saml',
        'baa_signed',
        'dedicated_csm',
      ],
      excludedFeatures: [],
      stripePriceIdKey: 'enterprise_annual_eur_contract',
    ),
  ];

  static PricingTierRecord forTier(PricingTier t) {
    for (final r in tiers) {
      if (r.tier == t) return r;
    }
    throw StateError('No record for ${t.name}');
  }

  static PricingTierRecord? byStripePriceIdKey(String key) {
    for (final r in tiers) {
      if (r.stripePriceIdKey == key) return r;
    }
    return null;
  }
}

/// True when [feature] is included on [tier]. Negative on either
/// "explicitly excluded" or "not in included list" — strict.
bool isFeatureIncluded(PricingTier tier, String feature) {
  final r = PricingTierCatalog.forTier(tier);
  if (r.excludedFeatures.contains(feature)) return false;
  return r.includedFeatures.contains(feature);
}

/// True when [seats] is below the tier's hard cap. `maxSeats == 0`
/// means unlimited.
bool isWithinSeatCap(PricingTier tier, int seats) {
  final r = PricingTierCatalog.forTier(tier);
  if (r.maxSeats == 0) return true;
  return seats <= r.maxSeats;
}
