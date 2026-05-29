/// Compile-time configuration, supplied via `--dart-define` at build time.
///
/// Nothing secret is hardcoded in the repo: production values are injected by
/// the build (CI / `flutter build web --dart-define=...`). Defaults keep the
/// app fully usable in local/demo mode with no configuration.
///
/// Example release build:
/// ```
/// flutter build web --release \
///   --dart-define=IS_DEMO=false \
///   --dart-define=SENTRY_DSN=https://...@sentry.io/123 \
///   --dart-define=POSTHOG_KEY=phc_... \
///   --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_... \
///   --dart-define=BACKEND_URL=https://api.psyclinicai.com
/// ```
class BuildConfig {
  const BuildConfig._();

  /// Demo mode: no real backend/auth required. Defaults to TRUE so the app
  /// always runs locally; production release builds MUST pass IS_DEMO=false.
  static const bool isDemo =
      bool.fromEnvironment('IS_DEMO', defaultValue: true);

  /// Sentry DSN for crash/error reporting. Empty ⇒ telemetry stays a no-op.
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// PostHog project key for product analytics. Empty ⇒ no-op.
  static const String posthogKey = String.fromEnvironment('POSTHOG_KEY');

  /// Stripe publishable (client) key. Empty ⇒ checkout shows "not configured".
  static const String stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  /// Base URL of our backend (Cloud Functions): Stripe checkout sessions,
  /// webhooks, and the Anthropic relay. Empty ⇒ BYOK / demo paths only.
  static const String backendUrl = String.fromEnvironment('BACKEND_URL');

  /// True once real telemetry keys are present.
  static bool get telemetryEnabled =>
      sentryDsn.isNotEmpty || posthogKey.isNotEmpty;

  /// True once a backend is configured (enables checkout + managed relay).
  static bool get backendConfigured => backendUrl.isNotEmpty;

  /// True once Stripe is configured for client-side checkout redirect.
  static bool get billingConfigured =>
      backendConfigured && stripePublishableKey.isNotEmpty;
}
