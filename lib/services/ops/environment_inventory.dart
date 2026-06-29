/// O7 — Deployment environment inventory (pinned helper).
///
/// **Why this exists**: today the deploy commands hard-code
/// `--project psyclinicai`, `--project psyclinicai-staging`, etc.
/// Each script knows about its own env but no one helper knows
/// about all of them. Engineers join the team and have to grep
/// for which secret namespace + Firebase project corresponds to
/// which environment. Pinning the matrix here means:
///   1. Every deploy script reads the project id + secret
///      namespace + healthcheck URL from one source.
///   2. A new environment (e.g. preview-per-PR) cannot ship
///      without a row + the parity test failing.
///   3. The status-page widget renders prod/staging health from
///      the same URLs the cron polls.
///
/// **Distinct from `region_service.dart`**: that file tracks per-
/// tenant data residency (EU vs US); O7 tracks deployment stage.
/// A single env (prod) hosts both EU and US tenants.
///
/// **Out of scope** (separate PRs):
///   * Refactor `deploy_web.yml` to read project id from here.
///   * Per-PR preview environment provisioning (N5 candidate).
///   * Status-page widget rendering env health.
library;

/// Deployment stage.
enum DeploymentEnv { local, preview, staging, production }

/// One pinned environment record.
class EnvironmentRecord {
  const EnvironmentRecord({
    required this.env,
    required this.firebaseProjectId,
    required this.functionsSecretNamespace,
    required this.publicHealthcheckUrl,
    required this.cspReportUrl,
    required this.allowsRealCustomerTraffic,
    required this.allowsRealPhi,
  });

  final DeploymentEnv env;

  /// Firebase project id (drives Firestore + Functions + Hosting).
  final String firebaseProjectId;

  /// Secret namespace under `firebase functions:secrets:set` —
  /// keeps prod / staging / preview secrets isolated.
  final String functionsSecretNamespace;

  /// HTTPS healthcheck URL the status page poller hits. Local
  /// envs return `http://...` (still https-prefixed externally).
  final String publicHealthcheckUrl;

  /// CSP report-to endpoint per env so violations land in the
  /// right project's logging.
  final String cspReportUrl;

  /// True when real customer traffic terminates here. Tests pin
  /// only production is true.
  final bool allowsRealCustomerTraffic;

  /// True when real PHI may be processed in this env. Tests pin
  /// only production is true.
  final bool allowsRealPhi;
}

class EnvironmentInventory {
  const EnvironmentInventory._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned environment matrix. Order = DeploymentEnv.values;
  /// parity test enforces it.
  static const List<EnvironmentRecord> environments = [
    EnvironmentRecord(
      env: DeploymentEnv.local,
      firebaseProjectId: 'psyclinicai-emulator',
      functionsSecretNamespace: 'local',
      publicHealthcheckUrl: 'http://localhost:5000/__/health',
      cspReportUrl: 'http://localhost:5001/csp-report',
      allowsRealCustomerTraffic: false,
      allowsRealPhi: false,
    ),
    EnvironmentRecord(
      env: DeploymentEnv.preview,
      firebaseProjectId: 'psyclinicai-preview',
      functionsSecretNamespace: 'preview',
      publicHealthcheckUrl: 'https://psyclinicai-preview.web.app/__/health',
      cspReportUrl: 'https://psyclinicai-preview.web.app/__/csp-report',
      allowsRealCustomerTraffic: false,
      allowsRealPhi: false,
    ),
    EnvironmentRecord(
      env: DeploymentEnv.staging,
      firebaseProjectId: 'psyclinicai-staging',
      functionsSecretNamespace: 'staging',
      publicHealthcheckUrl: 'https://psyclinicai-staging.web.app/__/health',
      cspReportUrl: 'https://psyclinicai-staging.web.app/__/csp-report',
      allowsRealCustomerTraffic: false,
      allowsRealPhi: false,
    ),
    EnvironmentRecord(
      env: DeploymentEnv.production,
      firebaseProjectId: 'psyclinicai',
      functionsSecretNamespace: 'prod',
      publicHealthcheckUrl: 'https://psyclinicai.web.app/__/health',
      cspReportUrl: 'https://psyclinicai.web.app/__/csp-report',
      allowsRealCustomerTraffic: true,
      allowsRealPhi: true,
    ),
  ];

  static EnvironmentRecord forEnv(DeploymentEnv env) {
    for (final r in environments) {
      if (r.env == env) return r;
    }
    throw StateError('No record for ${env.name}');
  }

  static EnvironmentRecord? byFirebaseProjectId(String id) {
    for (final r in environments) {
      if (r.firebaseProjectId == id) return r;
    }
    return null;
  }
}

/// True when the env may have real customer PHI. Wired to runtime
/// guards (e.g. PhiRedactor `kReleaseMode` invocation gate).
bool envAllowsRealPhi(DeploymentEnv env) =>
    EnvironmentInventory.forEnv(env).allowsRealPhi;
