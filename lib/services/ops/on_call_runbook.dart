/// N3 — On-call operational runbook.
///
/// **Why this exists**: when a Sentry alert fires at 03:00, the
/// on-call should not be Googling for the right playbook. Each
/// incident class the platform can throw at us — tampered audit
/// chain, high-severity CSSRS surge, payment-failure spike, audit-
/// mirror outage, DSAR SLA approaching, 72h breach clock running
/// — is encoded here as an ordered protocol with owners, time
/// budgets, and escalation-on-failure pointers.
///
/// **Distinct from `CssrsRunbook` (L2)**: that one is the *clinician*-
/// facing protocol for a positive screener. This is the *operator*-
/// facing protocol for a production alert.
///
/// **Pure data + invariants**: no Firestore, no Sentry, no network.
/// The on-call dashboard renders this as a timeline; the Sentry
/// alert template links to the dashboard route. Both the dashboard
/// and the alert template (separate PRs) consume the runbook
/// from here, so a step renaming flows everywhere.
library;

/// The alert classes the platform can fire. Append-only — every
/// new alert MUST get a runbook entry, otherwise the Sentry rule
/// has no playbook to link to.
enum IncidentKind {
  /// `auditChainVerify` Cloud Function (J2) flagged a hash chain
  /// mismatch in a per-clinic audit mirror.
  chainTamper,

  /// CSSRS escalation telemetry shows a sudden surge of immediate /
  /// imminent tier events (> 3× rolling 7-day baseline). Suggests
  /// either a population spike OR a scoring regression we shipped.
  cssrsSurge,

  /// `billing.payment_failed` events exceed the 1-hour 5%
  /// failure-rate threshold. Stripe outage, expired BIN, or a
  /// deposit-handler regression.
  paymentFailureSpike,

  /// `audit_log.mirror_failed` events exceed 5% of total appends
  /// over 15 minutes. Firestore quota, auth-token expiry, or the
  /// per-clinic rule shape drifted.
  mirrorOutage,

  /// A DSAR request is within 24h of its 30-day SLA without a
  /// completed export. KVKK md. 12/3 + GDPR Art. 12(3) deadline
  /// breach risk.
  dsarSlaApproaching,

  /// A logged breach incident is within 6h of its 72h regulator
  /// notification deadline (KVKK md. 12/5 + GDPR Art. 33).
  breach72hApproaching,
}

/// Severity bucket — drives the on-call paging policy (page vs
/// queue) and the runbook's UI tint.
enum IncidentSeverity {
  /// Heartbeat / informational. Acknowledge within the next
  /// business day. No paging.
  low,

  /// Action expected within 24h. Email-only, not pager.
  medium,

  /// Page on-call. SLA: first response within 30 min.
  high,

  /// War-room. SLA: first response within 5 min, escalates to
  /// the CTO + DPO within 30 min if not acknowledged.
  critical,
}

class OpsRunbookStep {
  const OpsRunbookStep({
    required this.label,
    required this.ownerRole,
    required this.targetMinutes,
    required this.action,
    this.escalateOnFailure,
  });

  /// Timeline marker, < 40 chars.
  final String label;

  /// Owner of the step: `on_call`, `dpo`, `cto`, `legal`,
  /// `customer_success`, `support`, `infra`.
  final String ownerRole;

  /// Soft target — minutes from alert receipt.
  final int targetMinutes;

  final String action;

  final String? escalateOnFailure;
}

class OpsRunbook {
  const OpsRunbook({
    required this.incident,
    required this.severity,
    required this.steps,
    required this.totalTargetMinutes,
    required this.regulatoryRefs,
  });

  final IncidentKind incident;
  final IncidentSeverity severity;
  final List<OpsRunbookStep> steps;
  final int totalTargetMinutes;
  final List<String> regulatoryRefs;
}

/// Pinned role strings — the on-call dashboard switches on a stable
/// string when picking the pager target / avatar.
class OpsRunbookRoles {
  const OpsRunbookRoles._();
  static const String onCall = 'on_call';
  static const String dpo = 'dpo';
  static const String cto = 'cto';
  static const String legal = 'legal';
  static const String customerSuccess = 'customer_success';
  static const String support = 'support';
  static const String infra = 'infra';
}

/// Returns the runbook for [incident]. Pure: same input → same
/// output, byte-for-byte.
OpsRunbook runbookFor(IncidentKind incident) {
  switch (incident) {
    case IncidentKind.chainTamper:
      return const OpsRunbook(
        incident: IncidentKind.chainTamper,
        severity: IncidentSeverity.critical,
        steps: [
          OpsRunbookStep(
            label: 'Acknowledge + freeze writes',
            ownerRole: 'on_call',
            targetMinutes: 5,
            action:
                'Acknowledge the Sentry alert. Run `gcloud functions '
                'deploy auditChainVerify --update-env-vars '
                'PAUSE_MIRROR=true` to temporarily freeze new '
                'mirror writes for the affected clinic.',
            escalateOnFailure: 'Page CTO immediately',
          ),
          OpsRunbookStep(
            label: 'Snapshot + diff',
            ownerRole: 'on_call',
            targetMinutes: 15,
            action:
                'Export the affected clinic_audit_logs subcollection '
                'to a cold-storage bucket. Run the chain-replay '
                'helper locally; identify the first bad row index.',
          ),
          OpsRunbookStep(
            label: 'Loop in DPO + CTO',
            ownerRole: 'dpo',
            targetMinutes: 30,
            action:
                'Notify DPO + CTO in the incident channel with the '
                'clinic id, first bad row index, and the diff '
                'against the expected hash. DPO assesses whether '
                'this rises to a notifiable breach.',
            escalateOnFailure:
                'Treat as notifiable breach → run '
                'breach72hApproaching runbook in parallel',
          ),
          OpsRunbookStep(
            label: 'Restore + replay',
            ownerRole: 'infra',
            targetMinutes: 120,
            action:
                'Restore the chain from the last-good cold-storage '
                'snapshot. Replay subsequent rows from the device '
                'mirror queue. Verify chain end-to-end before '
                'un-pausing mirror writes.',
          ),
          OpsRunbookStep(
            label: 'Post-incident review + CAPA',
            ownerRole: 'cto',
            targetMinutes: 60,
            action:
                'Schedule a CAPA review within 5 business days. '
                'Document root cause, scope, customer comms, and '
                'preventive actions in the incident log.',
          ),
        ],
        totalTargetMinutes: 230,
        regulatoryRefs: [
          'HIPAA §164.312(c)(1) integrity controls',
          'KVKK md. 12 veri güvenliği yükümlülüğü',
          'ISO 27001 A.16.1 incident management',
        ],
      );

    case IncidentKind.cssrsSurge:
      return const OpsRunbook(
        incident: IncidentKind.cssrsSurge,
        severity: IncidentSeverity.high,
        steps: [
          OpsRunbookStep(
            label: 'Confirm signal',
            ownerRole: 'on_call',
            targetMinutes: 5,
            action:
                'Cross-check the surge against the 30-day baseline '
                'on the CSSRS dashboard. A planned awareness '
                'campaign launching today is a normal trigger.',
          ),
          OpsRunbookStep(
            label: 'Check scoring regression',
            ownerRole: 'on_call',
            targetMinutes: 10,
            action:
                'Compare deployed `clinical_scales.dart` SHA against '
                'the last release tag. If they differ, roll back '
                'the scoring change and re-baseline.',
            escalateOnFailure:
                'Treat as patient-safety incident; loop in clinical '
                'safety officer',
          ),
          OpsRunbookStep(
            label: 'Patient-safety officer brief',
            ownerRole: 'dpo',
            targetMinutes: 30,
            action:
                'Brief the patient-safety officer with the surge '
                'magnitude, scoring-version diff, and any patterns '
                'in flagged clinic ids. Decide whether to publish '
                'an in-app banner reminding clinicians of the '
                'escalation protocol (CssrsRunbook L2).',
          ),
        ],
        totalTargetMinutes: 45,
        regulatoryRefs: [
          'APA Practice Guideline §V (quality monitoring)',
          'Joint Commission Sentinel Event Policy SE-A',
        ],
      );

    case IncidentKind.paymentFailureSpike:
      return const OpsRunbook(
        incident: IncidentKind.paymentFailureSpike,
        severity: IncidentSeverity.medium,
        steps: [
          OpsRunbookStep(
            label: 'Stripe status check',
            ownerRole: 'on_call',
            targetMinutes: 5,
            action:
                'Open status.stripe.com. If Stripe declares an '
                'outage, mark our incident as "upstream" and queue '
                'a customer comms note.',
          ),
          OpsRunbookStep(
            label: 'Webhook idempotency probe',
            ownerRole: 'on_call',
            targetMinutes: 15,
            action:
                'Inspect the `processed_webhooks` collection — '
                'duplicate event ids indicate the idempotency '
                'ledger is racing. Roll back the deposit handler '
                'if our deploy SHA changed in the last 60 min.',
          ),
          OpsRunbookStep(
            label: 'Customer comms',
            ownerRole: 'customer_success',
            targetMinutes: 60,
            action:
                'If failures exceed 10% over 60 min, email the '
                'affected clinic admins with the standard payment '
                'incident template; CC support@.',
          ),
        ],
        totalTargetMinutes: 80,
        regulatoryRefs: ['PCI DSS v4.0 §12.10 incident response plan'],
      );

    case IncidentKind.mirrorOutage:
      return const OpsRunbook(
        incident: IncidentKind.mirrorOutage,
        severity: IncidentSeverity.high,
        steps: [
          OpsRunbookStep(
            label: 'Rule-shape diff',
            ownerRole: 'on_call',
            targetMinutes: 10,
            action:
                'Diff `firestore.rules` between the deployed and '
                'last-known-good revisions for the '
                '`clinic_audit_logs` block. A predicate drift '
                '(e.g. hash size != 64) silently denies every '
                'mirror write.',
          ),
          OpsRunbookStep(
            label: 'Replay backlog',
            ownerRole: 'infra',
            targetMinutes: 30,
            action:
                'If the device side queued failed mirror writes, '
                'trigger the replay batch. Verify clinic_audit_logs '
                'count converges to the device chain.',
          ),
          OpsRunbookStep(
            label: 'Brief DPO if > 1h',
            ownerRole: 'dpo',
            targetMinutes: 60,
            action:
                'If the outage exceeds 1h, brief the DPO on whether '
                'this counts as a §164.312(b) integrity event. '
                'Document the gap in the incident log.',
            escalateOnFailure:
                'Page CTO; treat as notifiable breach if device '
                'chain integrity is in question',
          ),
        ],
        totalTargetMinutes: 100,
        regulatoryRefs: [
          'HIPAA §164.312(b) audit controls',
          'HIPAA §164.316(b)(2)(i) 6-year retention',
        ],
      );

    case IncidentKind.dsarSlaApproaching:
      return const OpsRunbook(
        incident: IncidentKind.dsarSlaApproaching,
        severity: IncidentSeverity.medium,
        steps: [
          OpsRunbookStep(
            label: 'Locate the request',
            ownerRole: 'on_call',
            targetMinutes: 10,
            action:
                'Open the dsar_requests collection. Confirm the '
                'request id, requested_at, and current export '
                'state.',
          ),
          OpsRunbookStep(
            label: 'Force-run export',
            ownerRole: 'on_call',
            targetMinutes: 20,
            action:
                'Trigger `dsarExport` Cloud Function manually with '
                'the (clinicId, patientId) tuple. Confirm the '
                'bundle is delivered and audit row appended.',
            escalateOnFailure:
                'Loop in CTO + DPO; document a '
                'KVKK md. 13 reasoned delay',
          ),
          OpsRunbookStep(
            label: 'Patient comms',
            ownerRole: 'customer_success',
            targetMinutes: 60,
            action:
                'Send the bundle to the patient via the originally '
                'verified contact. Confirm receipt and close the '
                'request.',
          ),
        ],
        totalTargetMinutes: 90,
        regulatoryRefs: [
          'GDPR Art. 12(3) one-month response deadline',
          'KVKK md. 13/2 30-gün cevap süresi',
        ],
      );

    case IncidentKind.breach72hApproaching:
      return const OpsRunbook(
        incident: IncidentKind.breach72hApproaching,
        severity: IncidentSeverity.critical,
        steps: [
          OpsRunbookStep(
            label: 'Convene incident war-room',
            ownerRole: 'cto',
            targetMinutes: 0,
            action:
                'Open the breach war-room in the incident channel. '
                'CTO, DPO, legal, and on-call all present.',
          ),
          OpsRunbookStep(
            label: 'Build notification template',
            ownerRole: 'dpo',
            targetMinutes: 30,
            action:
                'Run `buildNotificationTemplate()` (K4) for KVKK + '
                'EU GDPR + HIPAA jurisdictions as applicable. '
                'Legal reviews the draft for each.',
          ),
          OpsRunbookStep(
            label: 'File with regulators',
            ownerRole: 'legal',
            targetMinutes: 90,
            action:
                'Submit the KVKK Kurumu form, the EU SA notification, '
                'and the HHS OCR notification per jurisdiction. '
                'Record `regulatorNotifiedAtUtc` on the breach record.',
            escalateOnFailure:
                'Document the missed deadline + the reasoned '
                'justification per Art. 33(1) "where feasible"',
          ),
          OpsRunbookStep(
            label: 'Individual notice (if required)',
            ownerRole: 'customer_success',
            targetMinutes: 240,
            action:
                'If `BreachSeverity.requiresIndividualNotice` is '
                'true, dispatch the patient-side notification '
                'using the K4 template; CC clinic admins.',
          ),
        ],
        totalTargetMinutes: 360,
        regulatoryRefs: [
          'GDPR Art. 33 72-hour controller notification',
          'KVKK md. 12/5 72 saat içinde bildirim',
          'HIPAA §164.408 OCR notification',
        ],
      );
  }
}
