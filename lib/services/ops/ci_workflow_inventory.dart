/// N18 — CI/CD workflow inventory (pinned helper).
///
/// **Why this exists**: a new engineer joining the team has to
/// grep `.github/workflows/` to learn which workflow runs when,
/// which is required for a merge, which is best-effort. Workflows
/// also accumulate — a deprecated `deploy_web.yml` still sits in
/// the tree even though `pages.yml` superseded it. SOC 2 CC4.1
/// monitoring expects a documented build pipeline.
///
/// Pins per workflow file:
///   1. Stable filename + display name.
///   2. Trigger surface (push / pull_request / workflow_dispatch /
///      schedule).
///   3. Whether the workflow is *required* for merge (blocking)
///      or best-effort / informational.
///   4. Single owner + the secrets the workflow needs.
///
/// **Distinct from**:
///   * N12 alerting_policy: that handles runtime alerts; N18
///     handles build-time workflows.
///   * O7 environment_inventory: that pins target envs; N18 pins
///     the workflows that ship to them.
///
/// **Out of scope** (separate PRs):
///   * CI dashboard widget rendering the matrix.
///   * Workflow audit cron that diffs runtime status vs this pin.
///   * Stale-workflow cleanup PR removing `deploy_web.yml`.
library;

/// What kind of event fires the workflow. Multiple values pinned
/// per workflow — a workflow may have both `push` + `pull_request`.
enum WorkflowTrigger {
  /// Fires on every push to the default branch.
  push,

  /// Fires on every pull_request open / sync.
  pullRequest,

  /// Manual run via `workflow_dispatch`.
  manual,

  /// Cron schedule.
  schedule,
}

/// One pinned workflow record.
class CiWorkflowRecord {
  const CiWorkflowRecord({
    required this.filename,
    required this.displayName,
    required this.triggers,
    required this.isRequiredForMerge,
    required this.owner,
    required this.requiredSecrets,
    required this.purpose,
  });

  /// Stable filename inside `.github/workflows/`. Tests pin the
  /// file actually exists.
  final String filename;

  /// Display name shown in the GitHub Actions UI.
  final String displayName;

  /// Trigger surface(s) — one workflow may fire on multiple.
  final List<WorkflowTrigger> triggers;

  /// True when the workflow MUST be green before a merge. Drives
  /// the branch-protection sync + the auditor's "what gates the
  /// release" answer.
  final bool isRequiredForMerge;

  /// Single accountable role.
  final String owner;

  /// GitHub secret names the workflow consumes. Empty when the
  /// workflow needs none (public-pages build, codeql).
  final List<String> requiredSecrets;

  /// One-line plain-English summary of what the workflow does.
  final String purpose;
}

class CiWorkflowInventory {
  const CiWorkflowInventory._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Path where workflow files live.
  static const String workflowsDir = '.github/workflows';

  /// Pinned inventory. Append-only — deprecated workflows stay
  /// flagged with `isRequiredForMerge: false` until the cleanup
  /// PR removes them.
  static const List<CiWorkflowRecord> workflows = [
    CiWorkflowRecord(
      filename: 'ci.yml',
      displayName: 'CI',
      triggers: [WorkflowTrigger.push, WorkflowTrigger.pullRequest],
      isRequiredForMerge: true,
      owner: 'cto',
      requiredSecrets: [],
      purpose:
          'Primary build gate — flutter analyze + flutter test + '
          'TypeScript build + Python AST + JSON/YAML lint.',
    ),
    CiWorkflowRecord(
      filename: 'codeql.yml',
      displayName: 'CodeQL',
      triggers: [
        WorkflowTrigger.push,
        WorkflowTrigger.pullRequest,
        WorkflowTrigger.schedule,
      ],
      isRequiredForMerge: true,
      owner: 'ciso',
      requiredSecrets: [],
      purpose:
          'SAST coverage on functions/ (Stripe webhooks + PHI relay '
          '+ WebAuthn + account deletion).',
    ),
    CiWorkflowRecord(
      filename: 'e2e.yml',
      displayName: 'E2E (Playwright)',
      triggers: [WorkflowTrigger.pullRequest],
      isRequiredForMerge: true,
      owner: 'cto',
      requiredSecrets: [],
      purpose: 'Playwright golden-path suite against the web build.',
    ),
    CiWorkflowRecord(
      filename: 'lighthouse.yml',
      displayName: 'Lighthouse CI',
      triggers: [WorkflowTrigger.pullRequest],
      // Performance + a11y + SEO budget; informational by default
      // to avoid blocking copy-only PRs on a flaky perf score.
      isRequiredForMerge: false,
      owner: 'cto',
      requiredSecrets: [],
      purpose:
          'Landing performance + a11y + SEO audit (informational; '
          'flag regressions in PR).',
    ),
    CiWorkflowRecord(
      filename: 'pages.yml',
      displayName: 'Deploy demo to GitHub Pages',
      triggers: [WorkflowTrigger.push],
      isRequiredForMerge: false,
      owner: 'cto',
      requiredSecrets: [],
      purpose:
          'Public, credential-free DEMO build for clinician '
          'reviewers — no Firebase, no real PHI.',
    ),
    CiWorkflowRecord(
      filename: 'deploy_web.yml',
      displayName: 'Deploy Web',
      // Manual-only — superseded by pages.yml for the public demo
      // path; kept around for VPS-direct deploys.
      triggers: [WorkflowTrigger.manual],
      isRequiredForMerge: false,
      owner: 'cto',
      requiredSecrets: ['SSH_HOST', 'SSH_USER', 'SSH_KEY', 'SENTRY_AUTH_TOKEN'],
      purpose:
          'Manual VPS-SSH deploy (legacy path; public demo lives on '
          'pages.yml now).',
    ),
  ];

  static CiWorkflowRecord? byFilename(String filename) {
    for (final w in workflows) {
      if (w.filename == filename) return w;
    }
    return null;
  }

  static List<CiWorkflowRecord> requiredForMerge() {
    return workflows.where((w) => w.isRequiredForMerge).toList();
  }
}

/// True when the workflow fires on every PR (push-or-PR ramp).
/// Drives branch-protection sync.
bool runsOnEveryPr(CiWorkflowRecord w) =>
    w.triggers.contains(WorkflowTrigger.pullRequest);
