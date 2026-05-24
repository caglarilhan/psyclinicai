import 'package:flutter/foundation.dart';

/// PsyClinicAI runtime environment.
///
/// Selection priority:
///   1. `--dart-define=PSY_ENV=staging|prod` (CI builds, deploys)
///   2. `kReleaseMode` -> `prod`
///   3. `kProfileMode` -> `staging`
///   4. default -> `dev`
///
/// Usage:
///   if (PsyEnv.current.isProd) { ... }
///   final region = PsyEnv.current.firestoreRegion;
enum PsyEnv {
  /// Local development. Firestore emulator allowed. Demo seed data on.
  dev,

  /// Pre-production. Real Firebase project, ring-fenced from prod. Used for
  /// pilot dry-runs and QA.
  staging,

  /// Live production. Real PHI. No demo seed data, debug banners, or
  /// unfenced logging.
  prod;

  /// Resolves the active environment exactly once per app launch.
  static final PsyEnv current = _resolve();

  static PsyEnv _resolve() {
    const overridden = String.fromEnvironment('PSY_ENV');
    if (overridden.isNotEmpty) {
      for (final e in PsyEnv.values) {
        if (e.name == overridden.toLowerCase()) return e;
      }
    }
    if (kReleaseMode) return PsyEnv.prod;
    if (kProfileMode) return PsyEnv.staging;
    return PsyEnv.dev;
  }

  bool get isDev => this == PsyEnv.dev;
  bool get isStaging => this == PsyEnv.staging;
  bool get isProd => this == PsyEnv.prod;

  /// Whether to render the in-app debug banner.
  bool get showDebugBanner => !isProd;

  /// Whether to seed a demo patient on first signup (UX onboarding aid).
  bool get seedDemoData => isDev || isStaging;

  /// Firestore region label for diagnostics & support tickets.
  String get firestoreRegion => 'eur3';

  /// Marketing site origin (used by share buttons, OG tags).
  String get marketingOrigin => switch (this) {
        PsyEnv.dev => 'http://localhost:8765',
        PsyEnv.staging => 'https://staging.psyclinicai.com',
        PsyEnv.prod => 'https://psyclinicai.com',
      };

  /// Sentry release tag (Sprint 5 observability wiring).
  String get sentryRelease => 'psyclinicai@$_buildVersion';

  /// PostHog project key (Sprint 5).
  String get postHogProjectKey => switch (this) {
        PsyEnv.dev => '',
        PsyEnv.staging =>
          const String.fromEnvironment('POSTHOG_KEY_STAGING'),
        PsyEnv.prod => const String.fromEnvironment('POSTHOG_KEY_PROD'),
      };

  /// Whether AI vendor calls (Anthropic) are enabled. Always true today,
  /// kept here so we can globally kill-switch via
  /// `--dart-define=PSY_KILL_AI=1`.
  bool get aiEnabled =>
      const String.fromEnvironment('PSY_KILL_AI') != '1';
}

const String _buildVersion = String.fromEnvironment(
  'BUILD_VERSION',
  defaultValue: '0.0.0-dev',
);
