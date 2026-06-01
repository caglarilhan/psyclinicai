/// ISO/IEC 27001:2022 Annex A control catalogue (subset).
///
/// Annex A holds 93 controls grouped into four themes:
/// - A.5 Organisational (37)
/// - A.6 People (8)
/// - A.7 Physical (14)
/// - A.8 Technological (34)
///
/// We surface the 24 controls that ship-ready SaaS auditors flag most
/// often. Each row carries the canonical clause number, the short label
/// from the standard, our implementation status, and a one-liner about
/// the artefact reviewers should look at.
///
/// Status values are deliberately conservative ("partial" is the default
/// when work-in-progress) so the trust center never overstates posture.
library;

/// Coarse readiness state for an Annex A control.
enum AnnexAStatus {
  /// Control is implemented and the artefact is linked.
  implemented,

  /// Implementation is underway; expect partial evidence.
  partial,

  /// Documented intent only; build work has not started.
  planned,
}

class AnnexAControl {
  const AnnexAControl({
    required this.clause,
    required this.theme,
    required this.title,
    required this.status,
    required this.evidence,
  });

  /// Canonical clause number, e.g. "A.5.7".
  final String clause;

  /// Annex A theme — Organisational / People / Physical / Technological.
  final String theme;

  /// Title as it appears in the standard.
  final String title;

  final AnnexAStatus status;

  /// One-line description of where to find the artefact (Trust Center
  /// link, internal Confluence page, repository path, …).
  final String evidence;
}

class Iso27001AnnexARegistry {
  const Iso27001AnnexARegistry._();

  /// YYYY-MM stamp surfaced on the trust center.
  static const String lastReviewed = '2026-06';

  static const List<AnnexAControl> controls = [
    // ────────── A.5 Organisational ──────────
    AnnexAControl(
      clause: 'A.5.1',
      theme: 'Organisational',
      title: 'Policies for information security',
      status: AnnexAStatus.implemented,
      evidence: 'Master ISMS policy + annual board review',
    ),
    AnnexAControl(
      clause: 'A.5.7',
      theme: 'Organisational',
      title: 'Threat intelligence',
      status: AnnexAStatus.partial,
      evidence: 'Subscribed feeds; ticketing automation pending',
    ),
    AnnexAControl(
      clause: 'A.5.15',
      theme: 'Organisational',
      title: 'Access control',
      status: AnnexAStatus.implemented,
      evidence: 'RBAC matrix + quarterly access review',
    ),
    AnnexAControl(
      clause: 'A.5.19',
      theme: 'Organisational',
      title: 'Information security in supplier relationships',
      status: AnnexAStatus.implemented,
      evidence: 'Subprocessor registry + signed DPAs',
    ),
    AnnexAControl(
      clause: 'A.5.23',
      theme: 'Organisational',
      title: 'Information security for use of cloud services',
      status: AnnexAStatus.implemented,
      evidence: 'AWS BAA + EU region pinning',
    ),
    AnnexAControl(
      clause: 'A.5.24',
      theme: 'Organisational',
      title: 'Information security incident management planning',
      status: AnnexAStatus.implemented,
      evidence: 'Incident response runbook + P0–P4 SLAs',
    ),
    AnnexAControl(
      clause: 'A.5.30',
      theme: 'Organisational',
      title: 'ICT readiness for business continuity',
      status: AnnexAStatus.partial,
      evidence: 'RTO/RPO defined; multi-region failover Q4 2026',
    ),
    AnnexAControl(
      clause: 'A.5.34',
      theme: 'Organisational',
      title: 'Privacy and protection of PII',
      status: AnnexAStatus.implemented,
      evidence: 'DPA + KVKK/GDPR mapping in trust center',
    ),

    // ────────── A.6 People ──────────
    AnnexAControl(
      clause: 'A.6.3',
      theme: 'People',
      title: 'Information security awareness, education and training',
      status: AnnexAStatus.implemented,
      evidence: 'Annual training + new-hire onboarding module',
    ),
    AnnexAControl(
      clause: 'A.6.6',
      theme: 'People',
      title: 'Confidentiality or non-disclosure agreements',
      status: AnnexAStatus.implemented,
      evidence: 'NDA in employment + contractor templates',
    ),
    AnnexAControl(
      clause: 'A.6.7',
      theme: 'People',
      title: 'Remote working',
      status: AnnexAStatus.implemented,
      evidence: 'Remote-work policy + MDM-enrolled endpoints',
    ),

    // ────────── A.7 Physical ──────────
    AnnexAControl(
      clause: 'A.7.4',
      theme: 'Physical',
      title: 'Physical security monitoring',
      status: AnnexAStatus.implemented,
      evidence: 'Hetzner data centre attestations',
    ),
    AnnexAControl(
      clause: 'A.7.8',
      theme: 'Physical',
      title: 'Equipment siting and protection',
      status: AnnexAStatus.implemented,
      evidence: 'Hetzner DC ISO 27001 + ISO 50001 certified',
    ),
    AnnexAControl(
      clause: 'A.7.10',
      theme: 'Physical',
      title: 'Storage media',
      status: AnnexAStatus.implemented,
      evidence: 'NIST 800-88 disposal contract',
    ),

    // ────────── A.8 Technological ──────────
    AnnexAControl(
      clause: 'A.8.2',
      theme: 'Technological',
      title: 'Privileged access rights',
      status: AnnexAStatus.implemented,
      evidence: 'Break-glass + 4-eye approval policy',
    ),
    AnnexAControl(
      clause: 'A.8.5',
      theme: 'Technological',
      title: 'Secure authentication',
      status: AnnexAStatus.partial,
      evidence: 'Password + reset live; MFA roll-out in Sprint 6',
    ),
    AnnexAControl(
      clause: 'A.8.7',
      theme: 'Technological',
      title: 'Protection against malware',
      status: AnnexAStatus.implemented,
      evidence: 'EDR on every endpoint + dependency scanning',
    ),
    AnnexAControl(
      clause: 'A.8.9',
      theme: 'Technological',
      title: 'Configuration management',
      status: AnnexAStatus.implemented,
      evidence: 'Terraform-managed AWS + drift detection',
    ),
    AnnexAControl(
      clause: 'A.8.10',
      theme: 'Technological',
      title: 'Information deletion',
      status: AnnexAStatus.partial,
      evidence: 'GDPR Art. 17 portal live; purge job lands Sprint 6',
    ),
    AnnexAControl(
      clause: 'A.8.12',
      theme: 'Technological',
      title: 'Data leakage prevention',
      status: AnnexAStatus.partial,
      evidence: 'Email DLP rules; endpoint DLP planned',
    ),
    AnnexAControl(
      clause: 'A.8.15',
      theme: 'Technological',
      title: 'Logging',
      status: AnnexAStatus.implemented,
      evidence: 'Append-only audit log + 6-year retention',
    ),
    AnnexAControl(
      clause: 'A.8.16',
      theme: 'Technological',
      title: 'Monitoring activities',
      status: AnnexAStatus.implemented,
      evidence: 'Sentry + StatusPage + on-call runbook',
    ),
    AnnexAControl(
      clause: 'A.8.24',
      theme: 'Technological',
      title: 'Use of cryptography',
      status: AnnexAStatus.implemented,
      evidence: 'AES-256 at rest, TLS 1.3 in transit, KMS rotation',
    ),
    AnnexAControl(
      clause: 'A.8.28',
      theme: 'Technological',
      title: 'Secure coding',
      status: AnnexAStatus.implemented,
      evidence: 'Code review + flutter analyze + dep audit in CI',
    ),
  ];

  /// Look up a specific clause; null when the registry does not cover it.
  static AnnexAControl? byClause(String clause) {
    for (final c in controls) {
      if (c.clause == clause) return c;
    }
    return null;
  }

  /// Counts per readiness state — drives the trust-center summary chip.
  static Map<AnnexAStatus, int> statusBreakdown() {
    final out = <AnnexAStatus, int>{
      for (final s in AnnexAStatus.values) s: 0,
    };
    for (final c in controls) {
      out[c.status] = (out[c.status] ?? 0) + 1;
    }
    return out;
  }

  /// Total controls catalogued — useful for the "X of 93 mapped" hint.
  static int get total => controls.length;
}
