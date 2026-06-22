/// Sign-out scrubber registry (audit 2026-06-21, H-8).
///
/// Several singleton-style services in `lib/services/copilot/` hold the
/// in-memory state of a clinical session (live transcript, draft SOAP,
/// pending notes). When the clinician signs out the next session's
/// user must NOT see any of that — HIPAA §164.310(d)(2)(i) media re-
/// use + §164.312(a)(2)(iii) automatic logoff. The audit flagged that
/// nothing wires those `reset()` methods to the auth lifecycle.
///
/// This registry is the wire. Each service that owns PHI in memory
/// registers a callback at construction time; `FirebaseAuthService.signOut`
/// runs every callback before completing the sign-out so the next
/// user lands on a clean slate.
///
/// Callbacks must be idempotent (sign-out may be called twice on the
/// same lifecycle in error recovery paths) and MUST NOT throw —
/// failures are caught and recorded via telemetry so a single
/// misbehaving cleaner cannot block the sign-out.
library;

import 'dart:async';

import '../data/telemetry_service.dart';

typedef SignOutScrubber = FutureOr<void> Function();

class SignOutScrubbers {
  SignOutScrubbers._();

  static final List<SignOutScrubber> _scrubbers = <SignOutScrubber>[];

  /// Register a scrubber. Returns a removal function so widget tests
  /// can install + uninstall a scrubber per test without leaking state
  /// across cases.
  static void Function() register(SignOutScrubber scrubber) {
    _scrubbers.add(scrubber);
    return () => _scrubbers.remove(scrubber);
  }

  /// Run every registered scrubber. Used by [FirebaseAuthService.signOut]
  /// and by integration tests that simulate a logout boundary.
  /// Exceptions inside a scrubber are caught + telemetry-reported so a
  /// single failure cannot block the sign-out — clinicians MUST always
  /// be able to log out.
  static Future<void> runAll() async {
    final snapshot = List<SignOutScrubber>.from(_scrubbers);
    for (final scrubber in snapshot) {
      try {
        await scrubber();
      } catch (e, stack) {
        await TelemetryService.instance.captureError(
          e,
          stack,
          hint: 'sign_out_scrubber',
        );
      }
    }
  }

  /// Test-only — empties the registry. Production code should NOT
  /// reach for this; sign-out cleanup must always run on the live
  /// scrubber set.
  static void clearForTest() => _scrubbers.clear();

  /// How many scrubbers are currently installed. Exposed for tests
  /// that assert registration semantics.
  static int get debugCount => _scrubbers.length;
}
