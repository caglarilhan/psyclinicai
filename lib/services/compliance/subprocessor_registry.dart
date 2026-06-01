import '../../models/subprocessor.dart';

/// Single source of truth for the sub-processors we engage. The trust
/// center reads this list directly and a CI check enforces that any new
/// vendor added to the build first lands here and bumps [lastReviewed].
///
/// Sources & cross-checks (last reviewed June 2026):
/// - GDPR Art. 28(2) — written authorisation before engagement.
/// - Vendor DPA URLs collected so prospects can verify in one click.
///
/// Update protocol when a vendor is added/removed:
/// 1. Edit this file.
/// 2. Bump [lastReviewed].
/// 3. Update the source comment above with the verification step.
/// 4. Notify existing customers 30 days before the change goes live.
class SubprocessorRegistry {
  const SubprocessorRegistry._();

  /// YYYY-MM stamp surfaced on the trust center page.
  static const String lastReviewed = '2026-06';

  static const List<Subprocessor> entries = [
    // ────────── Core infrastructure (EU-resident) ──────────
    Subprocessor(
      id: 'hetzner',
      name: 'Hetzner Online GmbH',
      purpose: 'Primary application + database hosting',
      data: 'All clinical records at rest, encrypted',
      location: 'Frankfurt · eu-central-1',
      transferMechanism: 'No transfer mechanism required (EU/EEA)',
      risk: SubprocessorRisk.low,
      dpaUrl: 'https://www.hetzner.com/legal/dpa',
    ),
    Subprocessor(
      id: 'aws-ses',
      name: 'Amazon Web Services EMEA (SES)',
      purpose: 'Transactional email (password reset, receipts)',
      data: 'Recipient email, subject, send metadata',
      location: 'eu-west-1 · Ireland',
      transferMechanism: 'No transfer mechanism required (EU/EEA)',
      risk: SubprocessorRisk.low,
      dpaUrl: 'https://aws.amazon.com/compliance/eu-data-protection',
    ),
    Subprocessor(
      id: 'cloudflare',
      name: 'Cloudflare, Inc.',
      purpose: 'WAF + edge CDN in front of the web app',
      data: 'Request metadata, no clinical content',
      location: 'Global edge, EU routing preferred',
      transferMechanism: 'EU SCCs + DPA + EU enterprise data localization',
      risk: SubprocessorRisk.low,
      dpaUrl: 'https://www.cloudflare.com/cloudflare-customer-dpa',
    ),

    // ────────── Identity & auth ──────────
    Subprocessor(
      id: 'firebase-auth',
      name: 'Google Firebase (Authentication)',
      purpose: 'Sign-in, password-reset email delivery',
      data: 'Email, hashed password, sign-in metadata',
      location: 'EU multi-region',
      transferMechanism: 'EU SCCs in place',
      risk: SubprocessorRisk.medium,
      dpaUrl: 'https://firebase.google.com/terms/data-processing-terms',
    ),

    // ────────── AI providers (opt-in BYOK) ──────────
    Subprocessor(
      id: 'anthropic',
      name: 'Anthropic, PBC',
      purpose: 'AI inference for SOAP drafts and risk co-pilot — BYOK '
          'opt-in only; routes through the clinician-supplied API key.',
      data: 'Session transcript text (no audio)',
      location: 'US',
      transferMechanism:
          'EU SCCs + DPA · BYOK opt-in per workspace · 0-day retention',
      risk: SubprocessorRisk.medium,
      dpaUrl: 'https://www.anthropic.com/legal/dpa',
    ),
    Subprocessor(
      id: 'openai',
      name: 'OpenAI Ireland Ltd.',
      purpose: 'Alternate AI provider — same BYOK gate as Anthropic',
      data: 'Session transcript text (no audio)',
      location: 'EU + US fallback',
      transferMechanism: 'EU SCCs + DPA · zero-retention API mode',
      risk: SubprocessorRisk.medium,
      dpaUrl: 'https://openai.com/policies/data-processing-addendum',
    ),

    // ────────── Payments ──────────
    Subprocessor(
      id: 'stripe',
      name: 'Stripe Payments Europe Ltd.',
      purpose: 'Billing, invoicing, card processing for the practice',
      data: 'Billing contact, card token, invoice metadata',
      location: 'Ireland · EEA-resident',
      transferMechanism: 'No transfer mechanism required (EEA)',
      risk: SubprocessorRisk.low,
      dpaUrl: 'https://stripe.com/legal/dpa',
      statusPageUrl: 'https://status.stripe.com',
    ),

    // ────────── Observability ──────────
    Subprocessor(
      id: 'sentry',
      name: 'Sentry (Functional Software, Inc.)',
      purpose: 'Crash + error reporting',
      data: 'Stack traces, opaque user id · sendDefaultPii=false',
      location: 'US (EU residency on enterprise plan)',
      transferMechanism: 'EU SCCs + DPA',
      risk: SubprocessorRisk.low,
      dpaUrl: 'https://sentry.io/legal/dpa',
      statusPageUrl: 'https://status.sentry.io',
    ),
    Subprocessor(
      id: 'posthog',
      name: 'PostHog, Inc.',
      purpose: 'Product analytics for the web app (funnel events only)',
      data: 'Event names, anonymous device id, no PHI',
      location: 'EU (eu.posthog.com)',
      transferMechanism: 'No transfer mechanism required (EU)',
      risk: SubprocessorRisk.low,
      dpaUrl: 'https://posthog.com/dpa',
    ),

    // ────────── Communications ──────────
    Subprocessor(
      id: 'daily-co',
      name: 'Daily.co (Pluot Communications, Inc.)',
      purpose: 'Telehealth video — clinician ↔ patient sessions '
          '(planned, Q3 2026)',
      data: 'Real-time A/V stream, room metadata; no recording by default',
      location: 'EU region, no cross-region fallback',
      transferMechanism: 'EU SCCs + DPA, EU-only routing flag enabled',
      risk: SubprocessorRisk.medium,
      dpaUrl: 'https://www.daily.co/legal/dpa',
    ),
    Subprocessor(
      id: 'twilio',
      name: 'Twilio Ireland Ltd.',
      purpose: 'Appointment-reminder SMS (planned, Q3 2026)',
      data: 'Phone number, message text, delivery status',
      location: 'Ireland · EEA-resident',
      transferMechanism: 'No transfer mechanism required (EEA)',
      risk: SubprocessorRisk.medium,
      dpaUrl: 'https://www.twilio.com/legal/data-protection-addendum',
    ),
  ];

  /// All entries (caller may sort).
  static List<Subprocessor> get all => entries;

  /// Convenience lookup — null when the id is unknown.
  static Subprocessor? byId(String id) {
    for (final s in entries) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Entries whose [Subprocessor.transferMechanism] mentions cross-border
  /// instruments (SCC / IDTA). Used by the trust center to highlight
  /// vendors that need the customer's attention.
  static Iterable<Subprocessor> get withCrossBorderTransfer => entries.where(
      (s) =>
          s.transferMechanism.toLowerCase().contains('scc') ||
          s.transferMechanism.toLowerCase().contains('idta'));
}
