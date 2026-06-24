/// Help sheet that lists every global keyboard shortcut. Triggered
/// by `?` (Shift + /) from anywhere inside [AppShell] and also via
/// the Cmd+K command palette entry "Keyboard shortcuts".
///
/// New shortcuts ship here as `ShortcutEntry` rows so the help
/// surface stays the single source of truth for what the clinician
/// can press.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../services/data/telemetry_service.dart';

class ShortcutEntry {
  const ShortcutEntry({required this.keys, required this.label, this.hint});

  /// Display keys, e.g. `Cmd K` or `?`. We render each whitespace-
  /// separated chunk inside its own keycap.
  final String keys;

  /// Single-line action description, e.g. "Open command palette".
  final String label;

  /// Optional clarifier shown muted under the label.
  final String? hint;
}

const List<ShortcutEntry> _shortcuts = [
  ShortcutEntry(
    keys: 'Cmd K',
    label: 'Open command palette',
    hint: 'Ctrl K on Windows / Linux. Type a destination to jump.',
  ),
  ShortcutEntry(
    keys: '?',
    label: 'Show this keyboard help sheet',
    hint: 'Shift + /. Press anywhere inside the app.',
  ),
];

/// Pops the help sheet + fires the `keyboard_shortcuts.shown`
/// telemetry hint. Safe to call from anywhere — uses the nearest
/// Navigator.
Future<void> showKeyboardShortcuts(BuildContext context) async {
  unawaited(TelemetryService.instance.capture('keyboard_shortcuts.shown'));
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => const KeyboardShortcutsSheet(),
  );
}

class KeyboardShortcutsSheet extends StatelessWidget {
  const KeyboardShortcutsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.keyboard_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Keyboard shortcuts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Press these from anywhere inside the app.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in _shortcuts)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ShortcutRow(entry: s, theme: theme, cs: cs),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.entry,
    required this.theme,
    required this.cs,
  });

  final ShortcutEntry entry;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final k in entry.keys.split(' ')) _Keycap(label: k, cs: cs),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (entry.hint != null) ...[
                const SizedBox(height: 2),
                Text(
                  entry.hint!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Keycap extends StatelessWidget {
  const _Keycap({required this.label, required this.cs});
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
    );
  }
}
