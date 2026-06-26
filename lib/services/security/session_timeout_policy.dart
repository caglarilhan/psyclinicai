/// N9 — Session timeout policy catalog (HIPAA automatic-logoff floor).
///
/// **Why this exists**: HIPAA §164.312(a)(2)(iii) requires "automatic
/// logoff that terminates an electronic session after a predetermined
/// time of inactivity". Today the device-side `app_lock_service.dart`
/// holds a single mutable `_idleMinutes` that the clinician can edit
/// freely — including past safe limits. Some contexts (kiosk on the
/// front desk, telehealth waiting room) need a *compliance floor*
/// the user CANNOT raise.
///
/// This catalog pins one policy per context and exposes:
///   * `floorSecondsFor(context)` — the floor the app_lock service
///     clamps to; user preference cannot exceed this.
///   * `defaultSecondsFor(context)` — the default the app picks if
///     the user has not changed the preference.
///   * `requireReauthFor(context)` — what the user must present to
///     resume (PIN, passkey, full sign-in).
///
/// **Out of scope** (separate PRs):
///   * Patch `app_lock_service.dart` to clamp against
///     `floorSecondsFor` per current context.
///   * Trust-center widget rendering the matrix.
///   * Telehealth waiting-room auto-end + audit row.
library;

/// Where the device is being used. The wider the audience, the
/// shorter the floor.
enum SessionContext {
  /// Clinician at their own workstation working on PHI.
  activeClinicSession,

  /// Front-desk / shared kiosk where any patient could walk by.
  kiosk,

  /// Telehealth screen while in / waiting for a video session.
  telehealth,

  /// Admin / billing console; less PHI exposure but elevated rights.
  admin,

  /// Patient portal on a personal device.
  patientPortal,
}

/// What credential the user MUST present to resume the session.
enum ReauthMethod {
  /// Device-stored PIN (the app_lock PIN today).
  pin,

  /// Platform passkey (WebAuthn / Touch ID / Face ID).
  passkey,

  /// Full re-authentication against Firebase Auth.
  fullSignIn,
}

/// One pinned session-timeout policy.
class SessionTimeoutPolicy {
  const SessionTimeoutPolicy({
    required this.context,
    required this.floorSeconds,
    required this.defaultSeconds,
    required this.ceilingSeconds,
    required this.requireReauth,
    required this.regulatoryRefs,
  });

  final SessionContext context;

  /// Hard floor — the user cannot lengthen the idle window past
  /// this. Compliance floor. E.g. kiosk = 60s.
  final int floorSeconds;

  /// What the app picks if the user has not customised the
  /// preference. MUST be ≤ ceiling and ≥ floor.
  final int defaultSeconds;

  /// Upper bound the preference UI exposes. Beyond this the slider
  /// disables; not enforceable per regulation but a UX guardrail.
  final int ceilingSeconds;

  final ReauthMethod requireReauth;

  /// Citations the policy is grounded in.
  final List<String> regulatoryRefs;
}

class SessionTimeoutCatalog {
  const SessionTimeoutCatalog._();

  /// YYYY-MM stamp — drives the "needs review" badge.
  static const String lastReviewed = '2026-06';

  /// Pinned policy per context. Append-only.
  static const List<SessionTimeoutPolicy> policies = [
    SessionTimeoutPolicy(
      context: SessionContext.activeClinicSession,
      floorSeconds: 60,
      defaultSeconds: 900, // 15 min — matches existing trust page promise
      ceilingSeconds: 1800,
      requireReauth: ReauthMethod.passkey,
      regulatoryRefs: [
        'HIPAA §164.312(a)(2)(iii) automatic logoff',
        'NIST SP 800-66 §4.4',
      ],
    ),
    SessionTimeoutPolicy(
      context: SessionContext.kiosk,
      floorSeconds: 30,
      defaultSeconds: 60,
      ceilingSeconds: 120,
      requireReauth: ReauthMethod.fullSignIn,
      regulatoryRefs: [
        'HIPAA §164.310(c) workstation security',
        'HIPAA §164.312(a)(2)(iii) automatic logoff',
      ],
    ),
    SessionTimeoutPolicy(
      context: SessionContext.telehealth,
      floorSeconds: 60,
      defaultSeconds: 300,
      ceilingSeconds: 900,
      requireReauth: ReauthMethod.passkey,
      regulatoryRefs: [
        'HIPAA §164.312(a)(2)(iii)',
        'HHS Telehealth Notice (Apr 2023 PHE end)',
      ],
    ),
    SessionTimeoutPolicy(
      context: SessionContext.admin,
      floorSeconds: 60,
      defaultSeconds: 600,
      ceilingSeconds: 1800,
      requireReauth: ReauthMethod.fullSignIn,
      regulatoryRefs: [
        'HIPAA §164.308(a)(4) info access management',
        'HIPAA §164.312(a)(2)(iii) automatic logoff',
        'SOC 2 CC6.1',
      ],
    ),
    SessionTimeoutPolicy(
      context: SessionContext.patientPortal,
      floorSeconds: 60,
      defaultSeconds: 900,
      ceilingSeconds: 1800,
      requireReauth: ReauthMethod.pin,
      regulatoryRefs: [
        'HIPAA §164.312(a)(2)(iii)',
        'GDPR Art. 32 organisational measures',
      ],
    ),
  ];

  static SessionTimeoutPolicy forContext(SessionContext context) {
    for (final p in policies) {
      if (p.context == context) return p;
    }
    throw StateError(
      'No SessionTimeoutPolicy pinned for ${context.name} — every '
      'SessionContext MUST have a policy.',
    );
  }
}

/// Clamp the user-supplied [requestedSeconds] against the compliance
/// floor + ceiling for [context]. Returns the value the app_lock
/// service should actually use. Tests pin behaviour at the edges.
int clampToPolicy(SessionContext context, int requestedSeconds) {
  final p = SessionTimeoutCatalog.forContext(context);
  if (requestedSeconds < p.floorSeconds) return p.floorSeconds;
  if (requestedSeconds > p.ceilingSeconds) return p.ceilingSeconds;
  return requestedSeconds;
}
