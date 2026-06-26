/// N13 — Change management policy catalog (pinned helper).
///
/// **Why this exists**: SOC 2 CC8.1 requires a documented change
/// management process — who approves what, when changes can land,
/// and what evidence the auditor reads back. Today changes ship via
/// PR review + `gh pr merge` with no formal class-based gating:
/// a Firestore rules edit lands the same way as a typo fix. This
/// catalog pins:
///   1. The change class (standard / normal / emergency / locked)
///      with deterministic examples per class.
///   2. The minimum approver set per class (engineer / two-person
///      review / CISO co-sign / executive break-glass).
///   3. Change-freeze windows that override the class (no non-
///      emergency changes during a mobile release cut).
///
/// **Out of scope** (separate PRs):
///   * Deploy gate Cloud Function that consults this matrix.
///   * Change-window dashboard widget.
///   * GitHub workflow that auto-labels PRs with their class.
library;

/// How much oversight a change requires before it lands.
enum ChangeClass {
  /// Low-risk, repeatable change — copy edits, dependency bumps
  /// inside SemVer minor, test additions. One reviewer + green
  /// CI suffices.
  standard,

  /// Customer-visible feature work, schema edits, refactors that
  /// touch ≥ 3 files. Needs two reviewers; one must be CODEOWNER.
  normal,

  /// Fix a P0 / P1 incident; ship in minutes, not hours. Needs
  /// IC + CTO ack; full post-merge review within 24h.
  emergency,

  /// Locked surface (firestore.rules, billing functions, audit-
  /// chain code, KMS config). Two reviewers + CISO co-sign +
  /// audit-log entry MANDATORY.
  locked,
}

/// One pinned change-class policy.
class ChangePolicyRecord {
  const ChangePolicyRecord({
    required this.changeClass,
    required this.label,
    required this.exampleChanges,
    required this.minReviewers,
    required this.requiresCodeowner,
    required this.requiresCisoCosign,
    required this.maxLeadTimeHours,
    required this.evidencePath,
    required this.regulatoryRefs,
  });

  final ChangeClass changeClass;
  final String label;

  /// Plain examples to disambiguate the class for engineers.
  final List<String> exampleChanges;

  /// Reviewer count (excluding the author). 1 for standard,
  /// 2 for normal/locked.
  final int minReviewers;

  /// True when at least one reviewer must be the CODEOWNER of the
  /// touched path.
  final bool requiresCodeowner;

  /// True when CISO sign-off is mandatory on the PR (locked
  /// surfaces only).
  final bool requiresCisoCosign;

  /// Max hours from PR open to merge — emergency is 1h; standard
  /// is generous (168h = 1 week) so a small change doesn't bloat.
  final int maxLeadTimeHours;

  /// Where the merge evidence lands. `git://` for normal commits,
  /// `docs/security/evidence/...` for locked + emergency.
  final String evidencePath;

  final List<String> regulatoryRefs;
}

/// A scheduled change-freeze window that overrides class policy.
class ChangeFreezeWindow {
  const ChangeFreezeWindow({
    required this.id,
    required this.label,
    required this.startIso,
    required this.endIso,
    required this.permittedClasses,
    required this.declaringRole,
  });

  /// Stable id used by the deploy gate + the dashboard.
  final String id;
  final String label;

  /// ISO 8601 `YYYY-MM-DDTHH:MM:SSZ` UTC.
  final String startIso;
  final String endIso;

  /// Which classes may still land during the window. Emergency is
  /// always permitted; others are explicit.
  final List<ChangeClass> permittedClasses;

  /// Who declared the freeze — usually the CTO or release manager.
  final String declaringRole;
}

class ChangeManagementPolicy {
  const ChangeManagementPolicy._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned class policies. Order = ChangeClass.values; tests pin
  /// parity so adding a class fails the build without a record.
  static const List<ChangePolicyRecord> classes = [
    ChangePolicyRecord(
      changeClass: ChangeClass.standard,
      label: 'Standard change (low risk, repeatable)',
      exampleChanges: [
        'Copy edit in landing or trust pages',
        'Dependency bump within SemVer minor',
        'Test-only addition',
        'docs/* markdown refresh',
      ],
      minReviewers: 1,
      requiresCodeowner: false,
      requiresCisoCosign: false,
      maxLeadTimeHours: 168,
      evidencePath: 'git://commit',
      regulatoryRefs: ['SOC 2 CC8.1 change management'],
    ),
    ChangePolicyRecord(
      changeClass: ChangeClass.normal,
      label: 'Normal change (customer-visible / multi-file refactor)',
      exampleChanges: [
        'New customer-facing screen',
        'Refactor touching ≥ 3 files',
        'Firestore schema add (non-PHI collections)',
        'Cloud Function add or rewrite',
      ],
      minReviewers: 2,
      requiresCodeowner: true,
      requiresCisoCosign: false,
      maxLeadTimeHours: 72,
      evidencePath: 'git://commit',
      regulatoryRefs: ['SOC 2 CC8.1', 'ISO 27001 A.12.1.2 change control'],
    ),
    ChangePolicyRecord(
      changeClass: ChangeClass.emergency,
      label: 'Emergency change (P0 / P1 incident fix)',
      exampleChanges: [
        'Hotfix for active P0 outage',
        'Block exfiltrated credential',
        'Revert a faulty deploy',
      ],
      minReviewers: 1,
      requiresCodeowner: false,
      requiresCisoCosign: false,
      maxLeadTimeHours: 1,
      evidencePath:
          'docs/security/evidence/<YYYYqN>/emergency-change-<ticket>.MANUAL.md',
      regulatoryRefs: [
        'SOC 2 CC8.1 emergency change procedures',
        'HIPAA §164.308(a)(6) security incident procedures',
      ],
    ),
    ChangePolicyRecord(
      changeClass: ChangeClass.locked,
      label: 'Locked surface (rules, billing, audit chain, KMS)',
      exampleChanges: [
        'firestore.rules edit',
        'Stripe webhook handler change',
        'Audit chain hash function change',
        'KMS key policy edit',
        'BAA / DPA template edit',
      ],
      minReviewers: 2,
      requiresCodeowner: true,
      requiresCisoCosign: true,
      maxLeadTimeHours: 168,
      evidencePath:
          'docs/security/evidence/<YYYYqN>/locked-change-<ticket>.MANUAL.md',
      regulatoryRefs: [
        'SOC 2 CC8.1 + CC6.1 logical access',
        'HIPAA §164.308(a)(4) info access management',
        'PCI DSS v4.0 §6.5 change-control for payment-touch code',
      ],
    ),
  ];

  /// Pinned change-freeze windows. Append-only.
  static const List<ChangeFreezeWindow> freezes = [
    ChangeFreezeWindow(
      id: 'mobile-release-cut-q3',
      label: 'Mobile release cut (Q3 2026)',
      startIso: '2026-09-01T00:00:00Z',
      endIso: '2026-09-08T23:59:59Z',
      permittedClasses: [ChangeClass.emergency, ChangeClass.locked],
      declaringRole: 'release_manager',
    ),
    ChangeFreezeWindow(
      id: 'year-end-financial-close',
      label: 'Year-end financial close',
      startIso: '2026-12-29T00:00:00Z',
      endIso: '2027-01-04T23:59:59Z',
      permittedClasses: [ChangeClass.emergency],
      declaringRole: 'cfo',
    ),
  ];

  static ChangePolicyRecord forClass(ChangeClass c) {
    for (final p in classes) {
      if (p.changeClass == c) return p;
    }
    throw StateError('No policy pinned for ${c.name}');
  }

  static ChangeFreezeWindow? freezeById(String id) {
    for (final f in freezes) {
      if (f.id == id) return f;
    }
    return null;
  }
}

/// True when a change of [c] may land at [now] given the pinned
/// freezes. Emergency always permitted; everything else respects
/// the per-window permitted-classes list.
bool isChangePermittedAt(ChangeClass c, DateTime now) {
  for (final f in ChangeManagementPolicy.freezes) {
    final start = DateTime.parse(f.startIso);
    final end = DateTime.parse(f.endIso);
    final inWindow = !now.isBefore(start) && !now.isAfter(end);
    if (!inWindow) continue;
    if (!f.permittedClasses.contains(c)) return false;
  }
  return true;
}
