/// Small status pill that tells the clinician whether their last
/// edit hit the database. Solves the "did it actually save?" anxiety
/// every clinical form has — without forcing a modal or a snackbar.
///
/// Visual states:
///   - [SavingState.idle]    — invisible. No noise when nothing is
///                             happening.
///   - [SavingState.saving]  — grey pill, "Saving…" + 12 px spinner.
///                             Shown the moment the screen kicks off
///                             a repository call.
///   - [SavingState.saved]   — green pill, "Saved" + check icon,
///                             auto-fades after 2 s.
///   - [SavingState.error]   — red pill, "Save failed — tap to retry",
///                             tappable. Stays visible until the user
///                             either retries or navigates away.
///
/// Usage:
/// ```dart
/// final _saveCtrl = SavingIndicatorController();
///
/// Future<void> _save() async {
///   _saveCtrl.startSaving();
///   try {
///     await repo.save(payload);
///     _saveCtrl.markSaved();
///   } catch (_) {
///     _saveCtrl.markError(onRetry: _save);
///     rethrow;
///   }
/// }
///
/// // ... in build():
/// SavingIndicator(controller: _saveCtrl);
/// ```
library;

import 'dart:async';

import 'package:flutter/material.dart';

enum SavingState { idle, saving, saved, error }

/// Controls a [SavingIndicator]. Keep one instance per form;
/// dispose it with the surrounding state object.
class SavingIndicatorController extends ChangeNotifier {
  SavingState _state = SavingState.idle;
  VoidCallback? _retry;
  Timer? _fadeTimer;

  SavingState get state => _state;
  VoidCallback? get onRetry => _retry;

  /// Flip into `saving`. Cancels any pending `saved` fade-out.
  void startSaving() {
    _fadeTimer?.cancel();
    _retry = null;
    _set(SavingState.saving);
  }

  /// Flip into `saved`. After [autoHide] the indicator quietly
  /// returns to `idle` — clinicians don't need a permanent badge,
  /// just confirmation that the write landed.
  void markSaved({Duration autoHide = const Duration(seconds: 2)}) {
    _fadeTimer?.cancel();
    _retry = null;
    _set(SavingState.saved);
    _fadeTimer = Timer(autoHide, () {
      if (_state == SavingState.saved) _set(SavingState.idle);
    });
  }

  /// Flip into `error`. Stays visible until the user retries via
  /// [onRetry] or the screen disposes. Calling this with no
  /// `onRetry` makes the pill non-interactive (informational only).
  void markError({VoidCallback? onRetry}) {
    _fadeTimer?.cancel();
    _retry = onRetry;
    _set(SavingState.error);
  }

  /// Forcibly clear the pill — e.g. after the screen recovers via a
  /// different path (full reload).
  void reset() {
    _fadeTimer?.cancel();
    _retry = null;
    _set(SavingState.idle);
  }

  void _set(SavingState next) {
    if (_state == next) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }
}

class SavingIndicator extends StatelessWidget {
  const SavingIndicator({super.key, required this.controller});
  final SavingIndicatorController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _buildPill(theme, cs),
        );
      },
    );
  }

  Widget _buildPill(ThemeData theme, ColorScheme cs) {
    switch (controller.state) {
      case SavingState.idle:
        return const SizedBox.shrink(key: ValueKey('idle'));
      case SavingState.saving:
        return _Pill(
          key: const ValueKey('saving'),
          icon: const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 1.6),
          ),
          label: 'Saving…',
          background: cs.surfaceContainerHigh,
          foreground: cs.onSurface.withValues(alpha: 0.75),
          border: cs.outlineVariant,
        );
      case SavingState.saved:
        return _Pill(
          key: const ValueKey('saved'),
          icon: const Icon(
            Icons.check_circle,
            size: 14,
            color: Color(0xFF16A34A),
          ),
          label: 'Saved',
          background: const Color(0xFF16A34A).withValues(alpha: 0.10),
          foreground: const Color(0xFF15803D),
          border: const Color(0xFF16A34A).withValues(alpha: 0.30),
        );
      case SavingState.error:
        final retry = controller.onRetry;
        return Material(
          key: const ValueKey('error'),
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: retry,
            child: _Pill(
              icon: Icon(Icons.error_outline, size: 14, color: cs.error),
              label: retry != null
                  ? 'Save failed — tap to retry'
                  : 'Save failed',
              background: cs.error.withValues(alpha: 0.10),
              foreground: cs.error,
              border: cs.error.withValues(alpha: 0.30),
            ),
          ),
        );
    }
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Widget icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
