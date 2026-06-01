import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../config/build_config.dart';

/// Telemetry façade — Sentry (errors) + PostHog (funnel events).
///
/// No-op until a DSN/key is injected via `--dart-define` (see [BuildConfig]).
/// When `SENTRY_DSN` is set, this class wires real `Sentry.captureException`
/// calls behind the same API surface that call sites already use. PostHog
/// stays a logging-only stub for now — when `POSTHOG_KEY` lands the same
/// `capture` / `identify` hooks here will fan out without touching UI code.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  bool _sentryReady = false;

  bool get _enabled => BuildConfig.telemetryEnabled;
  bool get _sentryEnabled => BuildConfig.sentryDsn.isNotEmpty;

  Future<void> initialize() async {
    if (_sentryEnabled) {
      try {
        await SentryFlutter.init((options) {
          options.dsn = BuildConfig.sentryDsn;
          // Tag every event so dashboards can split by build mode.
          options.environment = kReleaseMode ? 'production' : 'development';
          // Default off — clinical PHI must never leave the device through
          // a stack frame. Re-enable only after a PHI-scrubbing pass.
          options.sendDefaultPii = false;
          // Keep traces sample low; we care about errors, not perf yet.
          options.tracesSampleRate = 0.0;
        });
        _sentryReady = true;
      } catch (e, stack) {
        // Never let a misconfigured DSN crash the app — fall back to no-op.
        _sentryReady = false;
        if (kDebugMode) debugPrint('[telemetry] Sentry init failed: $e\n$stack');
      }
    }
    if (kDebugMode) {
      debugPrint('[telemetry] init — enabled=$_enabled sentry=$_sentryReady');
    }
  }

  /// Funnel event (PostHog — still a logging stub; same call sites already
  /// flow through here so wiring PostHog later doesn't touch UI code).
  Future<void> capture(
    String event, {
    Map<String, Object?> properties = const {},
  }) async {
    if (_sentryReady) {
      // Record as a Sentry breadcrumb so a later crash carries the funnel
      // context. Cheap and PHI-free (event names are public constants).
      await Sentry.addBreadcrumb(Breadcrumb(
        message: event,
        category: 'funnel',
        level: SentryLevel.info,
        data: properties.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      ));
    }
    if (kDebugMode) {
      debugPrint('[telemetry] capture: $event $properties');
    }
  }

  /// Tag a user (after signup or sign-in). We send only an opaque id —
  /// never email, name, or any free-text PII.
  Future<void> identify(
    String userId, {
    Map<String, Object?> traits = const {},
  }) async {
    if (_sentryReady) {
      await Sentry.configureScope((scope) {
        scope.setUser(SentryUser(id: userId));
      });
    }
    if (kDebugMode) {
      debugPrint('[telemetry] identify: $userId $traits');
    }
  }

  /// Reset on sign-out so the next session starts anonymous.
  Future<void> reset() async {
    if (_sentryReady) {
      await Sentry.configureScope((scope) => scope.setUser(null));
    }
    if (kDebugMode) {
      debugPrint('[telemetry] reset');
    }
  }

  /// Crash + error reporting (Sentry).
  Future<void> captureError(
    Object error,
    StackTrace? stack, {
    String? hint,
  }) async {
    if (_sentryReady) {
      await Sentry.captureException(
        error,
        stackTrace: stack,
        hint: hint != null ? Hint.withMap({'hint': hint}) : null,
      );
    }
    if (kDebugMode) {
      debugPrint('[telemetry] error${hint != null ? '/$hint' : ''}: $error');
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
  static const String landingExitIntentSubmit = 'landing.exit_intent_submit';

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

  /// A C-SSRS screener crossed a risk threshold (mild and above). Properties
  /// MUST NOT include item answers or patient identifiers — only the tier
  /// and severity band so dashboards can monitor escalation volume.
  static const String cssrsRiskEscalated = 'assessment.cssrs_escalated';

  /// The clinician acted on the escalation banner and navigated to safety
  /// planning. Pairs with [cssrsRiskEscalated] to measure follow-through.
  static const String safetyPlanInitiatedFromCssrs =
      'assessment.cssrs_safety_plan_initiated';

  /// The clinician dismissed the high-risk escalation modal without
  /// initiating safety planning. Useful to flag training gaps. Carries a
  /// non-PHI reason code ("opened_full_view", "dismissed_explicit").
  static const String cssrsEscalationModalDismissed =
      'assessment.cssrs_escalation_dismissed';
}
