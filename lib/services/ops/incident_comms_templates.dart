/// M2 — Incident communication templates (pinned helper).
///
/// **Why this exists**: when an incident lands, the on-call MUST
/// publish a status post within minutes (P0: 15 min target — see
/// [IncidentTargets.acknowledgeWithin]). Composing copy under pressure
/// is how legally-relevant phrasing slips ("data leak" vs "potential
/// disclosure"; "fixed" before the root cause is confirmed). This
/// helper pins one approved template per (severity × lifecycle
/// stage) so the on-call fills two blanks and ships.
///
/// **Three downstream consumers**:
///   1. Status-page poster Cloud Function — picks the right template
///      from [IncidentCommsTemplates.byStage].
///   2. Customer email blast generator — same templates with an
///      [IncidentCommsTemplate.emailSubject] header.
///   3. Internal Slack `#incidents` bot — posts the
///      [IncidentCommsTemplate.internalSummary] tldr.
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that picks the template + actually posts it.
///   * Sendgrid integration that mails the blast.
///   * Webhook that mirrors the status post to Slack.
library;

import '../../models/incident_severity.dart';

/// Lifecycle of a published incident post. Ordering matters — every
/// incident must walk acknowledged → investigating → identified →
/// (monitoring) → resolved.
enum IncidentLifecycleStage {
  acknowledged,
  investigating,
  identified,
  monitoring,
  resolved,
}

/// One approved status-post + email template for a (severity ×
/// stage) pair. Placeholders the on-call MUST fill are wrapped in
/// `{{double_braces}}`; tests pin that every required placeholder
/// is present so a copy edit cannot accidentally drop one.
class IncidentCommsTemplate {
  const IncidentCommsTemplate({
    required this.severity,
    required this.stage,
    required this.statusPageHeadline,
    required this.statusPageBody,
    required this.emailSubject,
    required this.emailBody,
    required this.internalSummary,
    required this.requiredPlaceholders,
  });

  final IncidentSeverity severity;
  final IncidentLifecycleStage stage;

  /// Short status-page headline. Filled placeholders shown to the
  /// public — never include internal jargon or vendor names that
  /// would surprise customers.
  final String statusPageHeadline;

  final String statusPageBody;

  final String emailSubject;
  final String emailBody;

  /// Internal Slack `#incidents` tldr — terser than the public copy
  /// because the audience is engineers who can see the dashboard.
  final String internalSummary;

  /// Placeholder tokens (without the braces) the on-call MUST fill.
  /// E.g. `['component', 'started_at_utc']`.
  final List<String> requiredPlaceholders;
}

class IncidentCommsTemplates {
  const IncidentCommsTemplates._();

  /// Pinned templates. Append-only — deprecated entries stay so
  /// historic status-page archives still match the source.
  static const List<IncidentCommsTemplate> entries = [
    // ────────── P0: total outage / confirmed PHI breach ──────────
    IncidentCommsTemplate(
      severity: IncidentSeverity.p0,
      stage: IncidentLifecycleStage.acknowledged,
      statusPageHeadline: 'Investigating an issue affecting {{component}}',
      statusPageBody:
          'We have detected a service-wide issue affecting '
          '{{component}}. Our on-call team is engaged and we will '
          'post the next update by {{next_update_utc}}.',
      emailSubject:
          '[psyclinicai] We are investigating an incident affecting '
          '{{component}}',
      emailBody:
          'Hi, we are writing to let you know our team has detected '
          'a service-wide issue affecting {{component}} that started '
          'at {{started_at_utc}}. We will post the next update by '
          '{{next_update_utc}} on https://psyclinicai.com/status.',
      internalSummary:
          'P0 declared at {{started_at_utc}} for {{component}}. '
          'Incident commander: {{commander}}. War-room: '
          '#incident-{{ticket}}.',
      requiredPlaceholders: ['component', 'next_update_utc', 'started_at_utc'],
    ),
    IncidentCommsTemplate(
      severity: IncidentSeverity.p0,
      stage: IncidentLifecycleStage.identified,
      statusPageHeadline: 'Cause identified for the {{component}} incident',
      statusPageBody:
          'We have identified the root cause for the issue affecting '
          '{{component}} ({{root_cause}}). Mitigation is in progress; '
          'the next update will land by {{next_update_utc}}.',
      emailSubject:
          '[psyclinicai] Root cause identified for the {{component}} '
          'incident',
      emailBody:
          'We have identified the root cause for the {{component}} '
          'incident: {{root_cause}}. Our team is mitigating now and '
          'we will write again by {{next_update_utc}}. Live status: '
          'https://psyclinicai.com/status.',
      internalSummary:
          'Root cause for {{component}} incident identified: '
          '{{root_cause}}. ETA to mitigation: {{eta_minutes}} min.',
      requiredPlaceholders: ['component', 'root_cause', 'next_update_utc'],
    ),
    IncidentCommsTemplate(
      severity: IncidentSeverity.p0,
      stage: IncidentLifecycleStage.resolved,
      statusPageHeadline: 'Resolved — {{component}} fully restored',
      statusPageBody:
          'The incident affecting {{component}} is fully resolved as '
          'of {{resolved_at_utc}}. A written post-mortem will be '
          'published within 5 working days at '
          'https://psyclinicai.com/security/post-mortems.',
      emailSubject:
          '[psyclinicai] Resolved — the {{component}} incident is over',
      emailBody:
          'The {{component}} incident is resolved as of '
          '{{resolved_at_utc}}. The post-mortem will be published '
          'within 5 working days. If you would like a copy, reply to '
          'this email.',
      internalSummary:
          'P0 incident on {{component}} resolved at '
          '{{resolved_at_utc}}. Post-mortem owner: {{pm_owner}}. CAPA '
          'opened: {{capa_id}}.',
      requiredPlaceholders: ['component', 'resolved_at_utc'],
    ),
    // ────────── P1: severe but partial ──────────
    IncidentCommsTemplate(
      severity: IncidentSeverity.p1,
      stage: IncidentLifecycleStage.acknowledged,
      statusPageHeadline: 'Investigating degraded {{component}}',
      statusPageBody:
          'We are seeing degraded performance on {{component}}. Some '
          'requests may be slower than usual. Next update by '
          '{{next_update_utc}}.',
      emailSubject: '[psyclinicai] Degraded performance on {{component}}',
      emailBody:
          'We are investigating degraded performance on {{component}} '
          'that started at {{started_at_utc}}. The next update will '
          'land by {{next_update_utc}}.',
      internalSummary:
          'P1 declared at {{started_at_utc}} for {{component}}. '
          'Incident commander: {{commander}}.',
      requiredPlaceholders: ['component', 'started_at_utc', 'next_update_utc'],
    ),
    IncidentCommsTemplate(
      severity: IncidentSeverity.p1,
      stage: IncidentLifecycleStage.resolved,
      statusPageHeadline: 'Resolved — {{component}} back to normal',
      statusPageBody:
          'The degradation on {{component}} is resolved as of '
          '{{resolved_at_utc}}. We will publish a post-mortem within '
          '5 working days.',
      emailSubject: '[psyclinicai] Resolved — {{component}} back to normal',
      emailBody:
          'The {{component}} degradation is resolved as of '
          '{{resolved_at_utc}}. Post-mortem within 5 working days.',
      internalSummary:
          'P1 incident on {{component}} resolved at '
          '{{resolved_at_utc}}. Post-mortem owner: {{pm_owner}}.',
      requiredPlaceholders: ['component', 'resolved_at_utc'],
    ),
    // ────────── P2: customer-visible but minor ──────────
    IncidentCommsTemplate(
      severity: IncidentSeverity.p2,
      stage: IncidentLifecycleStage.investigating,
      statusPageHeadline: 'Investigating intermittent {{component}} issues',
      statusPageBody:
          'Some users are reporting intermittent issues with '
          '{{component}}. We are investigating and will update by '
          '{{next_update_utc}}.',
      emailSubject: '[psyclinicai] Intermittent {{component}} issues',
      emailBody:
          'We are looking into intermittent reports on {{component}} '
          'since {{started_at_utc}}. No action is required from you; '
          'we will update at {{next_update_utc}}.',
      internalSummary:
          'P2 investigating {{component}} since {{started_at_utc}}.',
      requiredPlaceholders: ['component', 'started_at_utc', 'next_update_utc'],
    ),
    IncidentCommsTemplate(
      severity: IncidentSeverity.p2,
      stage: IncidentLifecycleStage.resolved,
      statusPageHeadline: 'Resolved — {{component}}',
      statusPageBody:
          'The {{component}} issue is resolved as of '
          '{{resolved_at_utc}}.',
      emailSubject: '[psyclinicai] Resolved — {{component}}',
      emailBody:
          'The {{component}} issue is resolved as of '
          '{{resolved_at_utc}}. No further action is needed.',
      internalSummary:
          'P2 incident on {{component}} resolved at {{resolved_at_utc}}.',
      requiredPlaceholders: ['component', 'resolved_at_utc'],
    ),
  ];

  /// Index by (severity, stage). Returns `null` if no template is
  /// pinned for that pair — callers should fall back to the lower
  /// severity's template + flag the gap in the runbook.
  static IncidentCommsTemplate? byStage(
    IncidentSeverity severity,
    IncidentLifecycleStage stage,
  ) {
    for (final t in entries) {
      if (t.severity == severity && t.stage == stage) return t;
    }
    return null;
  }
}

/// Finds every `{{token}}` in [body]; tests use this to confirm
/// the `requiredPlaceholders` list matches the rendered template.
Iterable<String> placeholdersIn(String body) sync* {
  final pattern = RegExp(r'\{\{(\w+)\}\}');
  for (final m in pattern.allMatches(body)) {
    yield m.group(1)!;
  }
}
