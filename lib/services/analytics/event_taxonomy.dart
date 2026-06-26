/// O5 — Analytics event taxonomy (pinned helper).
///
/// **Why this exists**: today every screen that wants to fire an
/// analytics event picks an event name + property bag ad-hoc.
/// That breaks two contracts at once:
///   1. Product analytics: PostHog dashboards key off event names,
///      so a typo or rename silently breaks funnels.
///   2. Privacy: the K9 cookie taxonomy says analytics fire only
///      after opt-in AND only on non-clinical surfaces, and the
///      K7 data classification says PHI MUST be scrubbed before
///      relay. Without a pinned per-event property schema there is
///      no enforcement.
///
/// This catalog pins per event: stable name, allowed properties
/// (with type + max length), required consent kind, surface
/// allow-list, PII-redaction policy. The future `analytics_service.
/// dart` wrap reads from here so a misspelled property is a build
/// break, not a silent data leak.
///
/// **Distinct from**:
///   * O1 `activation_funnel.dart` (PR #120) — funnel STAGES; this
///     is the EVENT level that fires the stage.
///   * `feat/consent-telemetry-contract` — that pins consent-event
///     property names; this is the product-analytics layer.
///
/// **Out of scope** (separate PRs):
///   * PostHog SDK wrap that reads from this catalog at runtime.
///   * Analytics dashboard widget rendering the taxonomy.
///   * DSAR per-event redaction.
library;

/// Where in the app the event may fire. Marketing / public surfaces
/// only — analytics is BANNED on clinical surfaces (per K9 cookie
/// taxonomy `isAllowedOnClinicalSurface`).
enum AnalyticsSurface {
  /// Public marketing pages (landing, pricing, trust).
  publicMarketing,

  /// Sign-up + sign-in flow (account creation only — never PHI).
  authFlow,

  /// Clinician workspace meta-events (settings open, theme switch).
  /// No PHI, no patient ids; only the clinician's own action.
  clinicianMeta,

  /// Patient portal meta-events (signed in, language change).
  patientPortalMeta,
}

/// Which consent the event requires before it can fire.
enum AnalyticsConsentGate {
  /// No consent needed — essential cookie / first-party event.
  essentialOnly,

  /// Analytics opt-in required (K9 `analytics` category).
  analyticsOptIn,
}

/// Allowed value type for an event property.
enum AnalyticsPropertyType { string, integer, boolean, isoDate }

/// One pinned property spec.
class AnalyticsPropertySpec {
  const AnalyticsPropertySpec({
    required this.name,
    required this.type,
    required this.maxLength,
    required this.required,
    required this.example,
  });

  /// Stable property name (snake_case).
  final String name;

  final AnalyticsPropertyType type;

  /// Max string length (string + isoDate only). `0` for non-strings.
  final int maxLength;

  /// True when the wrap MUST refuse to fire the event without it.
  final bool required;

  /// Synthetic example shown to engineers + auditors. Never PHI.
  final String example;
}

/// One pinned event record.
class AnalyticsEventRecord {
  const AnalyticsEventRecord({
    required this.name,
    required this.description,
    required this.surface,
    required this.consentGate,
    required this.properties,
  });

  /// Stable event name (snake_case). Drives the PostHog dashboard
  /// key — never rename in place, always add a new event.
  final String name;

  /// One-line description rendered in the analytics dashboard.
  final String description;

  final AnalyticsSurface surface;
  final AnalyticsConsentGate consentGate;

  /// Allowed property schema. The wrap rejects any property not in
  /// this list AND any missing-required property.
  final List<AnalyticsPropertySpec> properties;
}

class AnalyticsEventTaxonomy {
  const AnalyticsEventTaxonomy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned event catalog. Append-only — deprecated events stay
  /// so historic PostHog rows still resolve their schema.
  static const List<AnalyticsEventRecord> events = [
    AnalyticsEventRecord(
      name: 'landing_viewed',
      description: 'Public landing page rendered.',
      surface: AnalyticsSurface.publicMarketing,
      consentGate: AnalyticsConsentGate.analyticsOptIn,
      properties: [
        AnalyticsPropertySpec(
          name: 'route',
          type: AnalyticsPropertyType.string,
          maxLength: 200,
          required: true,
          example: '/landing',
        ),
        AnalyticsPropertySpec(
          name: 'referrer_host',
          type: AnalyticsPropertyType.string,
          maxLength: 200,
          required: false,
          example: 'news.ycombinator.com',
        ),
      ],
    ),
    AnalyticsEventRecord(
      name: 'pricing_tier_inspected',
      description: 'User clicked into a pricing tier card.',
      surface: AnalyticsSurface.publicMarketing,
      consentGate: AnalyticsConsentGate.analyticsOptIn,
      properties: [
        AnalyticsPropertySpec(
          name: 'tier',
          type: AnalyticsPropertyType.string,
          maxLength: 50,
          required: true,
          example: 'pilot',
        ),
      ],
    ),
    AnalyticsEventRecord(
      name: 'waitlist_signup_completed',
      description: 'A visitor finished the waitlist signup flow.',
      surface: AnalyticsSurface.publicMarketing,
      // Essential because the signup is the contract action
      // itself; no separate consent gate needed.
      consentGate: AnalyticsConsentGate.essentialOnly,
      properties: [
        AnalyticsPropertySpec(
          name: 'region',
          type: AnalyticsPropertyType.string,
          maxLength: 4,
          required: true,
          example: 'eu',
        ),
        AnalyticsPropertySpec(
          name: 'is_clinician',
          type: AnalyticsPropertyType.boolean,
          maxLength: 0,
          required: true,
          example: 'true',
        ),
      ],
    ),
    AnalyticsEventRecord(
      name: 'auth_signup_started',
      description: 'User opened the sign-up form.',
      surface: AnalyticsSurface.authFlow,
      consentGate: AnalyticsConsentGate.essentialOnly,
      properties: [
        AnalyticsPropertySpec(
          name: 'method',
          type: AnalyticsPropertyType.string,
          maxLength: 50,
          required: true,
          example: 'email_password',
        ),
      ],
    ),
    AnalyticsEventRecord(
      name: 'auth_signup_completed',
      description: 'User completed the sign-up flow.',
      surface: AnalyticsSurface.authFlow,
      consentGate: AnalyticsConsentGate.essentialOnly,
      properties: [
        AnalyticsPropertySpec(
          name: 'method',
          type: AnalyticsPropertyType.string,
          maxLength: 50,
          required: true,
          example: 'email_password',
        ),
        AnalyticsPropertySpec(
          name: 'duration_seconds',
          type: AnalyticsPropertyType.integer,
          maxLength: 0,
          required: false,
          example: '42',
        ),
      ],
    ),
    AnalyticsEventRecord(
      name: 'clinician_theme_switched',
      description: 'Clinician toggled light / dark theme.',
      surface: AnalyticsSurface.clinicianMeta,
      consentGate: AnalyticsConsentGate.analyticsOptIn,
      properties: [
        AnalyticsPropertySpec(
          name: 'theme',
          type: AnalyticsPropertyType.string,
          maxLength: 20,
          required: true,
          example: 'dark',
        ),
      ],
    ),
    AnalyticsEventRecord(
      name: 'patient_portal_signed_in',
      description: 'Patient signed in to the portal.',
      surface: AnalyticsSurface.patientPortalMeta,
      // Essential because portal sign-in is the contract.
      consentGate: AnalyticsConsentGate.essentialOnly,
      properties: [
        AnalyticsPropertySpec(
          name: 'method',
          type: AnalyticsPropertyType.string,
          maxLength: 50,
          required: true,
          example: 'magic_link',
        ),
      ],
    ),
  ];

  static AnalyticsEventRecord? byName(String name) {
    for (final e in events) {
      if (e.name == name) return e;
    }
    return null;
  }

  static List<AnalyticsEventRecord> bySurface(AnalyticsSurface surface) {
    return events.where((e) => e.surface == surface).toList();
  }
}

/// Banned property name patterns. Any property whose name (or whose
/// value, if string) hits one of these is refused at the wrap
/// before relay. Mirrors L9 PHI scrub categories.
const phiBannedPropertyNames = {
  'patient_id',
  'patient_name',
  'email',
  'phone',
  'mrn',
  'ssn',
  'kvnr',
  'dob',
  'date_of_birth',
  'address',
};

/// True when a property name is on the PHI deny-list. The wrap MUST
/// refuse to fire an event carrying any such property.
bool isPhiBannedProperty(String name) =>
    phiBannedPropertyNames.contains(name.toLowerCase());

/// Resolves the property spec for an event by name; returns null if
/// the property is unknown for that event (i.e. extra / typo).
AnalyticsPropertySpec? propertySpec(
  AnalyticsEventRecord event,
  String propertyName,
) {
  for (final p in event.properties) {
    if (p.name == propertyName) return p;
  }
  return null;
}
