import 'package:flutter/foundation.dart';

import '../../config/build_config.dart';

/// Telemetry façade — Sentry (errors) + PostHog (funnel events).
///
/// No-op until a DSN/key is injected via `--dart-define` (see [BuildConfig]).
/// Once keys are present the body becomes real `Sentry.captureException` +
/// `Posthog.capture` calls; every call site stays unchanged because the API
/// surface below is the canonical one.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  bool get _enabled => BuildConfig.telemetryEnabled;

  Future<void> initialize() async {
    if (_enabled) {
      // Real init goes here once keys are wired:
      //   await SentryFlutter.init((o) => o.dsn = _sentryDsn);
      //   await Posthog().setup(_posthogKey, ...);
    }
    if (kDebugMode) {
      debugPrint('[telemetry] init — enabled=$_enabled');
    }
  }

  /// Funnel event (PostHog).
  Future<void> capture(String event,
      {Map<String, Object?> properties = const {}}) async {
    if (kDebugMode) {
      debugPrint('[telemetry] capture: $event $properties');
    }
  }

  /// Tag a user (after signup or sign-in).
  Future<void> identify(String userId,
      {Map<String, Object?> traits = const {}}) async {
    if (kDebugMode) {
      debugPrint('[telemetry] identify: $userId $traits');
    }
  }

  /// Reset on sign-out so the next session starts anonymous.
  Future<void> reset() async {
    if (kDebugMode) {
      debugPrint('[telemetry] reset');
    }
  }

  /// Crash + error reporting (Sentry).
  Future<void> captureError(Object error, StackTrace? stack,
      {String? hint}) async {
    if (kDebugMode) {
      debugPrint(
          '[telemetry] error${hint != null ? '/$hint' : ''}: $error');
    }
  }
}

/// Common funnel event names — centralised so dashboards use a stable
/// vocabulary.
class TelemetryEvents {
  const TelemetryEvents._();

  static const String landingHeroEmailSubmit = 'landing.hero_email_submit';
  static const String landingWatchDemoClick = 'landing.watch_demo_click';
  static const String landingPricingPickTier = 'landing.pricing_pick_tier';
  static const String landingExitIntentSubmit =
      'landing.exit_intent_submit';

  static const String signUpStarted = 'auth.signup_started';
  static const String signUpCompleted = 'auth.signup_completed';
  static const String signInCompleted = 'auth.signin_completed';
  static const String passwordResetSent = 'auth.password_reset_sent';

  static const String onboardingStarted = 'onboarding.started';
  static const String onboardingFinished = 'onboarding.finished';
  static const String onboardingSkipped = 'onboarding.skipped';
  static const String onboardingByokSaved = 'onboarding.byok_saved';
  static const String onboardingSeedRequested = 'onboarding.seed_requested';

  static const String sessionStarted = 'session.started';
  static const String sessionNoteSaved = 'session.note_saved';
  static const String superbillGenerated = 'billing.superbill_generated';
  static const String assessmentCompleted = 'assessment.completed';
}
