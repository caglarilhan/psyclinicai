/// Power-user "save" keyboard shortcut for clinical form screens.
///
/// Wraps a child subtree so Cmd+S (macOS / iPadOS) or Ctrl+S
/// (Windows / Linux / web) triggers the screen's [onSave] callback —
/// without the clinician having to mouse over to the AppShell
/// primary CTA every time. Standard expectation for any document
/// editor; lifting it into a DS widget keeps every save flow
/// identically bound and testable.
///
/// When [enabled] is false (e.g. the form is incomplete or already
/// saving) the shortcut is registered but no-ops, so a tap doesn't
/// silently trigger a partial save while the screen looks busy.
///
/// Usage:
/// ```dart
/// return PsySaveShortcut(
///   onSave: _save,
///   enabled: !_saving && _current().isComplete,
///   child: AppShell(...),
/// );
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Intent fired when the user presses Cmd+S / Ctrl+S inside a
/// [PsySaveShortcut]. Exposed so tests can inject the intent
/// directly without simulating a key event.
class PsySaveIntent extends Intent {
  const PsySaveIntent();
}

class PsySaveShortcut extends StatelessWidget {
  const PsySaveShortcut({
    super.key,
    required this.onSave,
    required this.child,
    this.enabled = true,
  });

  /// Fired on Cmd+S / Ctrl+S when [enabled] is true.
  final VoidCallback onSave;

  /// Gate so an incomplete form / in-flight save doesn't trigger a
  /// double-write. The shortcut is still registered (so the system
  /// doesn't fall through to the browser "Save page as…" dialog on
  /// web), it just no-ops when not eligible.
  final bool enabled;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyS, meta: true): PsySaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true):
            PsySaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PsySaveIntent: CallbackAction<PsySaveIntent>(
            onInvoke: (_) {
              if (enabled) onSave();
              return null;
            },
          ),
        },
        // FocusableActionDetector with autofocus:false so we don't
        // steal first focus from form fields the user actually wants
        // to type into. Web/desktop still routes the activator
        // because Shortcuts walks up the focus tree.
        child: FocusableActionDetector(child: child),
      ),
    );
  }
}
