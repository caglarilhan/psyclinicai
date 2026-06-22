/// Unified snackbar for the clinician surface.
///
/// Every place that needs to nudge the clinician — "Saved", "Could
/// not save", "AI is offline", "Consent missing" — goes through this
/// helper instead of constructing a bare `SnackBar` inline. That
/// gives us three things at once:
///
///   1. **Visual consistency.** Every snackbar carries a leading
///      level-tinted icon + the message + (optional) action, in the
///      same Material 3 surface and radius the rest of the app uses.
///      Clinicians see snackbars 50+ times per shift; a consistent
///      vocabulary keeps the platform feeling clinical, not generic.
///   2. **Telemetry vocabulary.** Every show fires a
///      `psysnack.shown` event with `{level, hint}` so PostHog can
///      slice "error snackbars / day / cohort" without each call
///      site reinventing the property bag.
///   3. **Accessibility.** Level → `liveRegion`: `error`/`warning`
///      use `liveRegion: true` so screen readers announce them
///      immediately; `info`/`success` stay polite.
///
/// Usage:
/// ```dart
/// PsySnack.success(context, 'Safety plan saved.', hint: 'safety_plan.save');
/// PsySnack.error(context, 'Could not save — please retry.',
///   hint: 'safety_plan.save_failed',
///   action: SnackBarAction(label: 'Retry', onPressed: _save));
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/telemetry_service.dart';

enum PsySnackLevel { info, success, warning, error }

class PsySnack {
  const PsySnack._();

  /// Default visible duration. Clinicians need a beat to register the
  /// message; the Material default (4s) is too short for "Saved" but
  /// fine for "Error — retry" style nudges.
  static const _defaultDuration = Duration(seconds: 4);

  /// Show a snackbar at [level]. [hint] is the telemetry tag — keep
  /// it stable across deploys so dashboards group correctly
  /// (e.g. `safety_plan.save`, not "safety plan saved at 12:30").
  static void show(
    BuildContext context,
    String message, {
    PsySnackLevel level = PsySnackLevel.info,
    SnackBarAction? action,
    Duration duration = _defaultDuration,
    String? hint,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (icon, tint, fg) = _palette(level, cs, theme.brightness);

    unawaited(
      TelemetryService.instance.capture(
        'psysnack.shown',
        properties: {'level': level.name, if (hint != null) 'hint': hint},
      ),
    );

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Semantics(
          // All four levels are user-relevant in a clinical workflow —
          // success confirms that a save landed, info gives a
          // non-urgent status. Polite is the right register; assertive
          // is reserved for runtime errors / safety alerts.
          liveRegion: true,
          child: Row(
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: tint),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fg,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        action: action,
      ),
    );
  }

  static void info(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = _defaultDuration,
    String? hint,
  }) => show(
    context,
    message,
    action: action,
    duration: duration,
    hint: hint,
  );

  static void success(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = _defaultDuration,
    String? hint,
  }) => show(
    context,
    message,
    level: PsySnackLevel.success,
    action: action,
    duration: duration,
    hint: hint,
  );

  static void warning(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = _defaultDuration,
    String? hint,
  }) => show(
    context,
    message,
    level: PsySnackLevel.warning,
    action: action,
    duration: duration,
    hint: hint,
  );

  static void error(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Duration duration = _defaultDuration,
    String? hint,
  }) => show(
    context,
    message,
    level: PsySnackLevel.error,
    action: action,
    duration: duration,
    hint: hint,
  );

  /// Per-level (icon, accent, foreground). The accent is tuned per
  /// brightness because the SnackBar surface uses `cs.inverseSurface`
  /// — that swatch flips between near-black (light theme) and
  /// near-white (dark theme). The same tint can't satisfy WCAG
  /// 1.4.11 non-text contrast (3:1) on both, so we branch.
  static (IconData, Color, Color) _palette(
    PsySnackLevel level,
    ColorScheme cs,
    Brightness themeBrightness,
  ) {
    // On a light app theme the snackbar surface is DARK, so we need
    // lighter accents to reach 3:1; on a dark theme it inverts.
    final lighter = themeBrightness == Brightness.light;
    switch (level) {
      case PsySnackLevel.info:
        return (
          Icons.info_outline,
          lighter ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1),
          cs.onInverseSurface,
        );
      case PsySnackLevel.success:
        return (
          Icons.check_circle_outline,
          lighter ? const Color(0xFF6EE7B7) : const Color(0xFF15803D),
          cs.onInverseSurface,
        );
      case PsySnackLevel.warning:
        return (
          Icons.warning_amber_rounded,
          lighter ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
          cs.onInverseSurface,
        );
      case PsySnackLevel.error:
        return (
          Icons.error_outline,
          lighter ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
          cs.onInverseSurface,
        );
    }
  }
}
