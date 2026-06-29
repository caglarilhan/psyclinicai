/// N7 — Quarterly access-review schedule (pinned helper).
///
/// **Why this exists**: SOC 2 CC6.2 + ISO 27001 A.9.2.5 + HIPAA
/// §164.308(a)(4)(ii)(C) all require the controller to review who
/// has logical access to each system on a documented cadence + to
/// keep the evidence. The narrative version lives at
/// `docs/compliance/SOC2_ACCESS_REVIEW.md`. The clinicians/* slice
/// is already automated by `functions/src/access_review_cron.ts`,
/// but auditors expect coverage across *every* scope where access
/// is granted — not just the application roster.
///
/// This helper pins the full scope matrix in code so:
///   1. A new scope (a new Sentry tenant, a new GCS bucket) cannot
///      ship without being added here + the test failing.
///   2. The trust-center page renders the same matrix the SOC 2
///      observer reads.
///   3. The Cloud Function scheduler picks the right cron per
///      scope without hard-coding the cadence in the function.
///
/// **Out of scope** (separate PRs):
///   * Cloud Function that fans out the snapshots per scope.
///   * Trust-center widget rendering the matrix.
///   * Slack / email reminders before the sign-off SLA expires.
library;

/// Cadence at which the scope's roster MUST be reviewed.
enum ReviewCadence { monthly, quarterly, semiAnnual, annual }

/// One reviewable access scope.
class AccessReviewScope {
  const AccessReviewScope({
    required this.id,
    required this.name,
    required this.cadence,
    required this.reviewerRole,
    required this.signOffSlaDays,
    required this.evidencePath,
    required this.snapshotSource,
    required this.regulatoryRefs,
  });

  /// Stable id (used by the scheduler and the evidence ledger).
  final String id;

  /// Human-readable scope name shown on the trust page.
  final String name;

  final ReviewCadence cadence;

  /// Whoever must stamp `reviewed_by` + `reviewed_at` on the
  /// snapshot. Single owner per scope so accountability is clear.
  final String reviewerRole;

  /// Sign-off SLA in days from the cron run. CC6.2 evidence
  /// requires the review to be completed within a documented
  /// window; we hold to 7 days for quarterly, 14 for slower
  /// cadences.
  final int signOffSlaDays;

  /// Path inside the repo (or a cloud console URL) where the
  /// signed evidence lands. Auditors follow this verbatim.
  final String evidencePath;

  /// Where the roster snapshot comes from — `firestore://...`,
  /// `firebase-auth`, `gcp-iam://<project>`, `gh://<org>/<repo>`,
  /// `sentry://<org>`, `stripe-dashboard://team`.
  final String snapshotSource;

  /// Citations the scope is grounded in.
  final List<String> regulatoryRefs;
}

class AccessReviewSchedule {
  const AccessReviewSchedule._();

  /// YYYY-MM stamp — drives the trust-page "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned scope matrix. Append-only; deprecated scopes stay so
  /// historic evidence rows still resolve.
  static const List<AccessReviewScope> scopes = [
    AccessReviewScope(
      id: 'clinicians_roster',
      name: 'Application clinician roster',
      cadence: ReviewCadence.quarterly,
      reviewerRole: 'compliance_officer',
      signOffSlaDays: 7,
      evidencePath: 'firestore://access_reviews',
      snapshotSource: 'firestore://clinicians',
      regulatoryRefs: [
        'SOC 2 CC6.2 logical access review',
        'HIPAA §164.308(a)(4)(ii)(C) access establishment + modification',
        'ISO 27001 A.9.2.5 review of user access rights',
      ],
    ),
    AccessReviewScope(
      id: 'firebase_auth_admins',
      name: 'Firebase Auth — privileged users (custom claims)',
      cadence: ReviewCadence.quarterly,
      reviewerRole: 'compliance_officer',
      signOffSlaDays: 7,
      evidencePath: 'firestore://access_reviews_firebase_admins',
      snapshotSource: 'firebase-auth',
      regulatoryRefs: [
        'SOC 2 CC6.1 logical access — authentication',
        'HIPAA §164.308(a)(3) workforce security',
      ],
    ),
    AccessReviewScope(
      id: 'gcp_iam_project_psyclinicai',
      name: 'GCP IAM — psyclinicai project',
      cadence: ReviewCadence.quarterly,
      reviewerRole: 'ciso',
      signOffSlaDays: 7,
      evidencePath:
          'docs/security/evidence/<YYYYqN>/gcp-iam-psyclinicai.MANUAL.md',
      snapshotSource: 'gcp-iam://psyclinicai',
      regulatoryRefs: [
        'SOC 2 CC6.3 manage logical access',
        'ISO 27001 A.9.2.3 privileged access',
      ],
    ),
    AccessReviewScope(
      id: 'gcs_buckets_backups',
      name: 'GCS retention-locked backup buckets',
      cadence: ReviewCadence.semiAnnual,
      reviewerRole: 'ciso',
      signOffSlaDays: 14,
      evidencePath: 'docs/security/evidence/<YYYY-mm>/gcs-backup-acl.MANUAL.md',
      snapshotSource: 'gcp-iam://psyclinicai-backups-eu',
      regulatoryRefs: [
        'SOC 2 CC6.3',
        'HIPAA §164.308(a)(7) Contingency Plan — backup access',
      ],
    ),
    AccessReviewScope(
      id: 'cloud_function_service_accounts',
      name: 'Cloud Function service-account inventory',
      cadence: ReviewCadence.quarterly,
      reviewerRole: 'ciso',
      signOffSlaDays: 7,
      evidencePath:
          'docs/security/evidence/<YYYYqN>/cf-service-accounts.MANUAL.md',
      snapshotSource: 'gcp-iam://psyclinicai/service-accounts',
      regulatoryRefs: ['SOC 2 CC6.1', 'NIST SP 800-53 AC-2 account management'],
    ),
    AccessReviewScope(
      id: 'github_org_collaborators',
      name: 'GitHub repo collaborators',
      cadence: ReviewCadence.quarterly,
      reviewerRole: 'cto',
      signOffSlaDays: 7,
      evidencePath: 'docs/security/evidence/<YYYYqN>/github-collabs.MANUAL.md',
      snapshotSource: 'gh://caglarilhan/psyclinicai',
      regulatoryRefs: [
        'SOC 2 CC6.1',
        'ISO 27001 A.9.2.1 user registration + deregistration',
      ],
    ),
    AccessReviewScope(
      id: 'sentry_org_members',
      name: 'Sentry organisation members + project ACLs',
      cadence: ReviewCadence.semiAnnual,
      reviewerRole: 'ciso',
      signOffSlaDays: 14,
      evidencePath: 'docs/security/evidence/<YYYY-mm>/sentry-org-acl.MANUAL.md',
      snapshotSource: 'sentry://psyclinicai',
      regulatoryRefs: ['SOC 2 CC6.1', 'GDPR Art. 32 organisational measures'],
    ),
    AccessReviewScope(
      id: 'stripe_dashboard_team',
      name: 'Stripe dashboard team + role assignments',
      cadence: ReviewCadence.annual,
      reviewerRole: 'cfo',
      signOffSlaDays: 14,
      evidencePath: 'docs/security/evidence/<YYYY>/stripe-team-acl.MANUAL.md',
      snapshotSource: 'stripe-dashboard://team',
      regulatoryRefs: ['PCI DSS v4.0 §7 restrict access'],
    ),
  ];

  static AccessReviewScope? byId(String id) {
    for (final s in scopes) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Cron expression each cadence renders to. Pinned in tests so the
/// scheduler picks a valid cron without ad-hoc strings.
String cronForCadence(ReviewCadence cadence) {
  switch (cadence) {
    case ReviewCadence.monthly:
      return '0 6 1 * *';
    case ReviewCadence.quarterly:
      return '0 6 1 1,4,7,10 *';
    case ReviewCadence.semiAnnual:
      return '0 6 1 1,7 *';
    case ReviewCadence.annual:
      return '0 6 1 1 *';
  }
}
