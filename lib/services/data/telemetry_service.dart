import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../config/build_config.dart';
import '../../utils/phi_redaction.dart';

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

  /// Test seam — fires synchronously on every [capture] call with the
  /// raw event name + properties map. The analytics contract test
  /// uses this to pin property keys so a future rename trips CI
  /// before it lands in production dashboards.
  @visibleForTesting
  static void Function(String event, Map<String, Object?> properties)?
  captureRecorderForTest;

  /// Test seam — fires synchronously on every [captureError] call.
  /// Tests pin the `hint` taxonomy so SIEM rules + Sentry alert
  /// routes stay coherent.
  @visibleForTesting
  static void Function(Object error, StackTrace? stack, String? hint)?
  errorRecorderForTest;

  bool get _enabled => BuildConfig.telemetryEnabled;
  bool get _sentryEnabled => BuildConfig.sentryDsn.isNotEmpty;

  /// Public read-only view of the Sentry wiring. Consumed by the
  /// status page (`/status`) and the internal ops runbook so the
  /// on-call clinician can distinguish "Sentry is silent because no
  /// crashes" from "Sentry is silent because the DSN never bound".
  TelemetryHealth get health => TelemetryHealth(
    telemetryEnabled: _enabled,
    dsnConfigured: _sentryEnabled,
    sentryReady: _sentryReady,
    environment: kReleaseMode ? 'production' : 'development',
  );

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
        if (kDebugMode) {
          debugPrint('[telemetry] Sentry init failed: $e\n$stack');
        }
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
    // CWE-489 defence: the recorder field is static + reachable from
    // any Dart isolate, including a release binary. Gate INVOCATION
    // (not mutation) so even if an attacker manages to set it, the
    // recorder is never called from a production build — the test
    // seam is purely a debug / profile / test affordance.
    if (!kReleaseMode) {
      captureRecorderForTest?.call(event, properties);
    }
    if (_sentryReady) {
      // Record as a Sentry breadcrumb so a later crash carries the funnel
      // context. Cheap and PHI-free (event names are public constants).
      await Sentry.addBreadcrumb(
        Breadcrumb(
          message: event,
          category: 'funnel',
          level: SentryLevel.info,
          data: properties.map((k, v) => MapEntry(k, v?.toString() ?? '')),
        ),
      );
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
      await Sentry.configureScope((scope) async {
        await scope.setUser(SentryUser(id: userId));
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
  ///
  /// H-7 fix (audit 2026-06-21): Anthropic / HTTP exceptions echo the
  /// upstream response body in `.toString()`, which can include the
  /// prompt — and the prompt may carry a transcript line with PHI
  /// (name, phone, MRN). We never trusted error messages to be PHI-
  /// free; now we run the same `PhiRedactor` patterns the relay uses
  /// over the message before sending it to Sentry, and we replace the
  /// original error with a `SafeReportedError` carrying the scrubbed
  /// text. Stack traces stay verbatim — they encode code paths, not
  /// patient data.
  Future<void> captureError(
    Object error,
    StackTrace? stack, {
    String? hint,
  }) async {
    // CWE-489 defence — see [capture] for the rationale.
    if (!kReleaseMode) {
      errorRecorderForTest?.call(error, stack, hint);
    }
    final scrubber = PhiRedactor();
    final scrubbedMessage = scrubber.scrub(error.toString()).cleanText;
    final scrubbedHint = hint == null ? null : scrubber.scrub(hint).cleanText;
    final reportError = SafeReportedError(scrubbedMessage, error.runtimeType);

    if (_sentryReady) {
      await Sentry.captureException(
        reportError,
        stackTrace: stack,
        hint: scrubbedHint != null
            ? Hint.withMap({'hint': scrubbedHint})
            : null,
      );
    }
    if (kDebugMode) {
      debugPrint(
        '[telemetry] error${scrubbedHint != null ? '/$scrubbedHint' : ''}: '
        '$scrubbedMessage',
      );
    }
  }
}

/// Wrapper used by [TelemetryService.captureError] so Sentry receives
/// a PHI-scrubbed message + the original runtime type for grouping.
class SafeReportedError implements Exception {
  SafeReportedError(this.message, this.originalType);

  final String message;
  final Type originalType;

  @override
  String toString() => 'SafeReportedError(type=$originalType): $message';
}

/// Read-only snapshot of the telemetry wiring. Rendered by `/status`
/// and consumed by the ops runbook. All flags are booleans + the
/// build environment tag — no PHI, no user identity.
class TelemetryHealth {
  const TelemetryHealth({
    required this.telemetryEnabled,
    required this.dsnConfigured,
    required this.sentryReady,
    required this.environment,
  });

  /// True when the whole telemetry stack is enabled at build time
  /// (`BuildConfig.telemetryEnabled`). Kill switch honoured first.
  final bool telemetryEnabled;

  /// True when a Sentry DSN is injected via `--dart-define`.
  final bool dsnConfigured;

  /// True when `SentryFlutter.init` succeeded — the app is actually
  /// reporting crashes to Sentry right now. False when the DSN is
  /// present but init failed (network, bad DSN, wrong env).
  final bool sentryReady;

  /// `production` or `development` — matches the tag Sentry sends
  /// with every event.
  final String environment;

  /// Human-readable status for the /status page.
  ///  * `wired` — DSN configured AND init succeeded.
  ///  * `misconfigured` — DSN configured but init failed.
  ///  * `off` — DSN not configured (expected in local + demo builds).
  String get label {
    if (!dsnConfigured) return 'off';
    return sentryReady ? 'wired' : 'misconfigured';
  }
}

/// Common funnel event names — centralised so dashboards use a stable
/// vocabulary.
class TelemetryEvents {
  const TelemetryEvents._();

  // Sprint 29 P-01 — public-funnel taxonomy (snake_case `noun.verb`).
  // Wired through the existing TelemetryService; PostHog DSN ramps in
  // via lib/config/build_config.dart once D-07 secrets land.
  static const String landingVisit = 'landing.visit';
  static const String landingHeroEmailSubmit = 'landing.hero_email_submit';
  static const String landingWatchDemoClick = 'landing.watch_demo_click';
  static const String landingPricingPickTier = 'landing.pricing_pick_tier';
  static const String landingExitIntentSubmit = 'landing.exit_intent_submit';
  static const String betaWaitlistSubmitted = 'landing.beta_waitlist_submitted';

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

  // Sprint 29 P-06 — north-star activation. Track when a clinician
  // produces their first SOAP draft so the D7 activation cohort is
  // measurable. Properties must NOT include patient identifiers or
  // note content — only the `time_to_first_soap_sec` from signup.
  static const String firstSoapGenerated = 'session.first_soap_generated';
  static const String soapGenerated = 'session.soap_generated';

  // Sprint 29 P-04 — Stripe Reserve-seat funnel.
  static const String paymentInitiated = 'billing.payment_initiated';
  static const String paymentSucceeded = 'billing.payment_succeeded';
  static const String paymentFailed = 'billing.payment_failed';

  // Sprint 32 P2 — BYOK key rotation lifecycle. Properties carry
  // `provider` (anthropic|openai|cohere), `grace_period_h`, never
  // the key value itself.
  static const String byokRotationRequested = 'byok.rotation_requested';
  static const String byokRotationCompleted = 'byok.rotation_completed';
  static const String byokRotationFailed = 'byok.rotation_failed';

  // Sprint 31 P2 — first-launch session tour. Properties carry
  // `total_steps`, `last_step_index`. No PHI.
  static const String onboardingTourStarted = 'onboarding.tour_started';
  static const String onboardingTourCompleted = 'onboarding.tour_completed';
  static const String onboardingTourSkipped = 'onboarding.tour_skipped';

  // Sprint 33 P2 — Stripe Customer Portal redirect.
  static const String billingCustomerPortalOpened =
      'billing.customer_portal_opened';
  static const String billingInvoiceDownloaded = 'billing.invoice_downloaded';

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
