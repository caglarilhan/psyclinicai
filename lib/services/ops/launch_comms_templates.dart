/// M5 — Launch comms / press kit template registry (pinned helper).
///
/// **Why this exists**: shipping a milestone (public beta, paid tier
/// open, SOC 2 Type I issued) requires consistent copy across PR
/// outlets, existing customers, the investor update, and social
/// channels. Today every launch is written from scratch under time
/// pressure, and brand voice drifts — "we" becomes "I" on LinkedIn,
/// "EU-based" gets dropped, the disclaimer "AI is a decision-support
/// tool" disappears. Pinning the templates here means:
///   1. Sales decks, customer email, press wire, and social all
///      render the same vocabulary.
///   2. Compliance-critical lines (AI disclaimer, EU positioning,
///      brand-voice plural) are enforced by tests at build time.
///   3. A future "ship a new milestone" cron picks the right
///      template per audience without copy-paste.
///
/// **Distinct from M2 incident comms** (PR #125): M2 handles
/// reactive outage messaging; M5 handles proactive announcements.
///
/// **Out of scope** (separate PRs):
///   * Sendgrid blast Cloud Function.
///   * Slack / X / LinkedIn post scheduler.
///   * Press wire integration (Notified / PRNewswire).
library;

/// Who the announcement is addressed to.
enum LaunchAudience {
  /// Existing paying customers.
  existingCustomers,

  /// Pre-launch waitlist + beta signups.
  waitlist,

  /// Press / journalists / industry analysts.
  pressJournalists,

  /// Existing investors + the next-round shortlist.
  investorUpdate,

  /// Public social channels (LinkedIn, X).
  socialPublic,

  /// Slack / Discord channels we participate in (clinical AI,
  /// digital-health practitioner communities).
  communityChannels,
}

/// Which milestone the announcement covers.
enum LaunchMilestone {
  /// Closed pilot opens to a new region.
  pilotRegionExpand,

  /// Public beta opens to all waitlisters.
  publicBetaOpen,

  /// Paid tier becomes generally available.
  paidTierGa,

  /// SOC 2 Type I report issued.
  soc2TypeIssued,

  /// HIPAA BAA counsel-approved + first U.S. customer signed.
  hipaaBaaSigned,

  /// Major feature ships (e.g. cssrs decision-support).
  majorFeatureShip,
}

/// One pinned launch comms template.
class LaunchCommsTemplate {
  const LaunchCommsTemplate({
    required this.id,
    required this.audience,
    required this.milestone,
    required this.subject,
    required this.body,
    required this.requiredPlaceholders,
    required this.embedsAiDisclaimer,
    required this.embedsEuPositioning,
    required this.usesPluralVoice,
  });

  /// Stable id — used by the scheduler + the audit log.
  final String id;

  final LaunchAudience audience;
  final LaunchMilestone milestone;

  /// Email subject line / press-release headline / social headline.
  final String subject;

  /// Full body, with `{{double_braces}}` placeholders the launch
  /// captain fills before publish. Same vocabulary as M2 templates.
  final String body;

  /// Placeholder tokens (without the braces) the launch captain
  /// MUST fill. Tests check every entry resolves in [body].
  final List<String> requiredPlaceholders;

  /// True when the template embeds the FDA / EU AI Act
  /// "decision-support only" disclaimer (mandatory for public,
  /// press, social, community channels).
  final bool embedsAiDisclaimer;

  /// True when the template explicitly positions us as EU-based
  /// (mandatory for press + investor + public).
  final bool embedsEuPositioning;

  /// True when the template uses the plural brand voice
  /// (we / our team / the platform — never founder first person).
  final bool usesPluralVoice;
}

class LaunchCommsTemplates {
  const LaunchCommsTemplates._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned templates. Append-only.
  static const List<LaunchCommsTemplate> entries = [
    // ────────── PUBLIC BETA OPEN ──────────
    LaunchCommsTemplate(
      id: 'public-beta-existing-customers',
      audience: LaunchAudience.existingCustomers,
      milestone: LaunchMilestone.publicBetaOpen,
      subject: 'Public beta is open — your clinic gets early access',
      body:
          'Hi {{first_name}}, our team is opening the platform to the '
          'public beta on {{launch_date_utc}}. As an existing pilot, '
          'your clinic keeps its current plan and gets early access to '
          '{{headline_feature}}. The platform remains decision-support '
          'only — clinical decisions stay with your team.',
      requiredPlaceholders: [
        'first_name',
        'launch_date_utc',
        'headline_feature',
      ],
      embedsAiDisclaimer: true,
      embedsEuPositioning: false,
      usesPluralVoice: true,
    ),
    LaunchCommsTemplate(
      id: 'public-beta-waitlist',
      audience: LaunchAudience.waitlist,
      milestone: LaunchMilestone.publicBetaOpen,
      subject: 'Your invitation is ready — public beta',
      body:
          'Hi {{first_name}}, the platform you joined the waitlist for '
          'opens for public beta on {{launch_date_utc}}. Click the link '
          'below to claim your seat. The platform is decision-support '
          'only and operated by our EU-based team.',
      requiredPlaceholders: ['first_name', 'launch_date_utc'],
      embedsAiDisclaimer: true,
      embedsEuPositioning: true,
      usesPluralVoice: true,
    ),
    LaunchCommsTemplate(
      id: 'public-beta-press',
      audience: LaunchAudience.pressJournalists,
      milestone: LaunchMilestone.publicBetaOpen,
      subject:
          'PsyClinicAI — EU-based clinical AI decision-support platform '
          'opens public beta on {{launch_date_utc}}',
      body:
          'Our team is opening the platform to public beta on '
          '{{launch_date_utc}}. The product is decision-support only; '
          'every clinical decision stays with the clinician. Founded in '
          '{{founding_year}} and operated from {{eu_city}}, the platform '
          'is GDPR-aligned, BAA-ready for U.S. clinics, and ships '
          'HIPAA-grade controls. Press kit + screenshots: {{press_kit_url}}',
      requiredPlaceholders: [
        'launch_date_utc',
        'founding_year',
        'eu_city',
        'press_kit_url',
      ],
      embedsAiDisclaimer: true,
      embedsEuPositioning: true,
      usesPluralVoice: true,
    ),
    LaunchCommsTemplate(
      id: 'public-beta-social',
      audience: LaunchAudience.socialPublic,
      milestone: LaunchMilestone.publicBetaOpen,
      subject: 'Public beta is open',
      body:
          'Our team has opened the public beta of the platform. '
          'Decision-support only — every clinical decision stays with '
          'the clinician. EU-based, GDPR-aligned. Try it: {{signup_url}}',
      requiredPlaceholders: ['signup_url'],
      embedsAiDisclaimer: true,
      embedsEuPositioning: true,
      usesPluralVoice: true,
    ),
    // ────────── PAID TIER GA ──────────
    LaunchCommsTemplate(
      id: 'paid-ga-existing-customers',
      audience: LaunchAudience.existingCustomers,
      milestone: LaunchMilestone.paidTierGa,
      subject: 'Paid tier is GA — pilot pricing locked for 12 months',
      body:
          'Hi {{first_name}}, the paid tier becomes generally available '
          'on {{launch_date_utc}}. Your pilot pricing of {{pilot_price}} '
          'is locked for the next 12 months — no action needed.',
      requiredPlaceholders: ['first_name', 'launch_date_utc', 'pilot_price'],
      embedsAiDisclaimer: false,
      embedsEuPositioning: false,
      usesPluralVoice: true,
    ),
    LaunchCommsTemplate(
      id: 'paid-ga-investor-update',
      audience: LaunchAudience.investorUpdate,
      milestone: LaunchMilestone.paidTierGa,
      subject: 'Investor update — paid tier GA + month-1 metrics',
      body:
          'Team, the paid tier reached general availability on '
          '{{launch_date_utc}}. Month-1 metrics: MRR {{mrr_eur}}, paying '
          'clinics {{paying_clinics}}, active clinicians {{active_clini'
          'cians}}, week-4 retention {{w4_retention_pct}}%. Headline '
          'risk: {{headline_risk}}. Next milestone: {{next_milestone}}.',
      requiredPlaceholders: [
        'launch_date_utc',
        'mrr_eur',
        'paying_clinics',
        'active_clinicians',
        'w4_retention_pct',
        'headline_risk',
        'next_milestone',
      ],
      embedsAiDisclaimer: false,
      embedsEuPositioning: false,
      usesPluralVoice: true,
    ),
    // ────────── SOC 2 TYPE I ISSUED ──────────
    LaunchCommsTemplate(
      id: 'soc2-type1-existing-customers',
      audience: LaunchAudience.existingCustomers,
      milestone: LaunchMilestone.soc2TypeIssued,
      subject: 'SOC 2 Type I report is available on the trust center',
      body:
          'Hi {{first_name}}, our team received the SOC 2 Type I report '
          'on {{report_date_utc}} from {{audit_firm}}. The report is '
          'available on the trust center under NDA — request via '
          '{{trust_url}}. Type II observation window opens '
          '{{type2_start_utc}}.',
      requiredPlaceholders: [
        'first_name',
        'report_date_utc',
        'audit_firm',
        'trust_url',
        'type2_start_utc',
      ],
      embedsAiDisclaimer: false,
      embedsEuPositioning: false,
      usesPluralVoice: true,
    ),
    LaunchCommsTemplate(
      id: 'soc2-type1-press',
      audience: LaunchAudience.pressJournalists,
      milestone: LaunchMilestone.soc2TypeIssued,
      subject:
          'PsyClinicAI receives SOC 2 Type I report — EU-based clinical '
          'AI platform',
      body:
          'Our team has received the SOC 2 Type I report on '
          '{{report_date_utc}} from {{audit_firm}}. The platform remains '
          'decision-support only; every clinical decision stays with '
          'the clinician. EU-based + GDPR-aligned. Trust center + report '
          'request: {{trust_url}}',
      requiredPlaceholders: ['report_date_utc', 'audit_firm', 'trust_url'],
      embedsAiDisclaimer: true,
      embedsEuPositioning: true,
      usesPluralVoice: true,
    ),
    // ────────── MAJOR FEATURE SHIP ──────────
    LaunchCommsTemplate(
      id: 'major-feature-existing-customers',
      audience: LaunchAudience.existingCustomers,
      milestone: LaunchMilestone.majorFeatureShip,
      subject: '{{feature_name}} is live for your clinic',
      body:
          'Hi {{first_name}}, our team has shipped {{feature_name}} on '
          '{{launch_date_utc}}. {{one_line_value}}. The platform remains '
          'decision-support only — every clinical decision stays with '
          'your team. Release notes: {{release_notes_url}}.',
      requiredPlaceholders: [
        'first_name',
        'feature_name',
        'launch_date_utc',
        'one_line_value',
        'release_notes_url',
      ],
      embedsAiDisclaimer: true,
      embedsEuPositioning: false,
      usesPluralVoice: true,
    ),
    LaunchCommsTemplate(
      id: 'major-feature-community',
      audience: LaunchAudience.communityChannels,
      milestone: LaunchMilestone.majorFeatureShip,
      subject: 'Shipped: {{feature_name}}',
      body:
          'Our team shipped {{feature_name}} on {{launch_date_utc}}. '
          '{{one_line_value}}. Happy to hear feedback / questions — '
          'we are EU-based and the platform is decision-support only.',
      requiredPlaceholders: [
        'feature_name',
        'launch_date_utc',
        'one_line_value',
      ],
      embedsAiDisclaimer: true,
      embedsEuPositioning: true,
      usesPluralVoice: true,
    ),
  ];

  static LaunchCommsTemplate? byId(String id) {
    for (final t in entries) {
      if (t.id == id) return t;
    }
    return null;
  }

  static List<LaunchCommsTemplate> byMilestone(LaunchMilestone milestone) {
    return entries.where((t) => t.milestone == milestone).toList();
  }

  static List<LaunchCommsTemplate> byAudience(LaunchAudience audience) {
    return entries.where((t) => t.audience == audience).toList();
  }
}

/// Extract every `{{token}}` from [body]; tests use this to verify
/// the required-vs-actual placeholder parity. Same shape as M2.
Iterable<String> placeholdersIn(String body) sync* {
  final pattern = RegExp(r'\{\{(\w+)\}\}');
  for (final m in pattern.allMatches(body)) {
    yield m.group(1)!;
  }
}

/// True when first-person singular pronouns leak into copy meant
/// for plural-voice channels. Brand-voice guard.
bool containsFirstPersonSingular(String body) {
  return RegExp(
    r'\b(I am|I will|I have|my team|my company|my product)\b',
    caseSensitive: false,
  ).hasMatch(body);
}
