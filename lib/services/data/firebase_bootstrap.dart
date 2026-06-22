import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import 'auth_service.dart';
import 'telemetry_service.dart';

/// Initialises Firebase + auth service.
///
/// Gracefully degrades: if `firebase_options.dart` still contains the
/// placeholder values, `Firebase.initializeApp` throws — we catch and
/// continue in offline mode so the demo build remains usable on routes
/// that do not require auth (landing, settings/api_keys, in-memory demo).
class PsyFirebase {
  PsyFirebase._();

  static bool _ready = false;
  static String? _initError;

  /// True once Firebase + auth have been initialised successfully.
  static bool get isReady => _ready;

  /// Initialisation error, if any. Used by the UI to surface a banner.
  static String? get initError => _initError;

  /// L-7 fix (audit 2026-06-21): a clinical write must NOT proceed
  /// when Firebase is not bootstrapped — otherwise the data lands in
  /// the in-memory demo store and silently disappears on reload. Any
  /// repository writing PHI MUST call this assert before the write
  /// path; the thrown [FirebaseNotReadyException] is caught at the
  /// UI boundary and re-rendered as the existing init-error banner.
  ///
  /// Reads remain best-effort (the UI can still show cached data).
  /// Writes are the path that loses PHI when no backend exists.
  static void assertReadyForClinicalWrite() {
    if (!_ready) {
      throw FirebaseNotReadyException(
        _initError ?? 'Firebase has not been initialised.',
      );
    }
  }

  static Future<void> bootstrap() async {
    if (_ready) return;
    try {
      final hasPlaceholder = DefaultFirebaseOptions.currentPlatform.apiKey
          .startsWith('TODO');
      if (hasPlaceholder) {
        // H-5 fix (audit 2026-06-21): a misconfigured release build
        // would silently fall into the "demo / unauthenticated"
        // branch — the app keeps painting screens but every Firestore
        // call no-ops, so PHI writes are dropped on the floor without
        // a banner. In release we fail loudly so the build does not
        // ship and the user reports the broken config immediately;
        // debug builds keep the soft-fail UX for dev iteration.
        _initError =
            'Firebase not configured yet. Run `flutterfire configure`.';
        if (kReleaseMode) {
          throw StateError(
            'PsyFirebase.bootstrap refused: firebase_options.dart '
            'still contains placeholder values. Run `flutterfire '
            'configure` before building for release.',
          );
        }
        if (kDebugMode) {
          debugPrint('[PsyFirebase] $_initError');
        }
        return;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // L-11 (audit 2026-06-21) — App Check activation. We ship the
      // debug provider in all build modes today; the production
      // providers (Play Integrity on Android, DeviceCheck/AppAttest
      // on iOS, reCAPTCHA v3 on web) need their site keys wired
      // through the Firebase Console + `--dart-define=APP_CHECK_
      // RECAPTCHA_SITE_KEY=...` before enforcement can flip on.
      // Activation is best-effort — a misconfigured provider must
      // not block Firebase Auth + Firestore from coming up.
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
          webProvider: ReCaptchaV3Provider(
            const String.fromEnvironment(
              'APP_CHECK_RECAPTCHA_SITE_KEY',
              defaultValue: 'recaptcha-v3-site-key-not-configured',
            ),
          ),
        );
      } catch (e, stack) {
        // Firebase Console may not have enabled App Check yet, the
        // platform provider may not be available (e.g. emulator), or
        // the placeholder reCAPTCHA key may be rejected. Each of
        // those is recoverable — keep booting.
        await TelemetryService.instance.captureError(
          e,
          stack,
          hint: 'app_check_activate',
        );
        if (kDebugMode) {
          debugPrint('[PsyFirebase] App Check activation skipped: $e');
        }
      }
      await FirebaseAuthService.instance.initialize();
      _ready = true;
    } catch (e, stack) {
      _initError = 'Firebase init failed: $e';
      // Report unconditionally: in release, debugPrint is a no-op, so without
      // this a Firebase init failure (and the auth/Firestore outage it causes)
      // would be completely invisible.
      await TelemetryService.instance.captureError(
        e,
        stack,
        hint: 'firebase_bootstrap',
      );
      if (kDebugMode) {
        debugPrint('[PsyFirebase] $_initError\n$stack');
      }
    }
  }
}

/// Thrown by [PsyFirebase.assertReadyForClinicalWrite]. Carries the
/// underlying [initError] so the UI banner can render the same
/// reason the boot path logged.
class FirebaseNotReadyException implements Exception {
  const FirebaseNotReadyException(this.reason);
  final String reason;
  @override
  String toString() =>
      'FirebaseNotReadyException: $reason. Clinical writes are '
      'blocked until the backend is configured.';
}
