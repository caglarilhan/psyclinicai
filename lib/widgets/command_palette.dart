import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// Cmd+K / Ctrl+K global command palette.
class CommandPaletteEntry {
  const CommandPaletteEntry({
    required this.label,
    required this.section,
    required this.onSelect,
    this.subtitle,
    this.icon,
    this.shortcut,
  });

  final String label;
  final String section;
  final VoidCallback onSelect;
  final String? subtitle;
  final IconData? icon;
  final String? shortcut;

  int score(String query) {
    if (query.isEmpty) return 1;
    final hay = ('$label ${subtitle ?? ''} $section').toLowerCase();
    final q = query.toLowerCase();
    if (hay.startsWith(q)) return 1000;
    if (label.toLowerCase().contains(q)) return 500;
    if (hay.contains(q)) return 100;
    var i = 0;
    var consec = 0;
    var matched = 0;
    for (final ch in q.split('')) {
      final hit = hay.indexOf(ch, i);
      if (hit < 0) return 0;
      consec = hit == i ? consec + 1 : 1;
      matched++;
      i = hit + 1;
    }
    return matched * 10 + consec * 4;
  }
}

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key, required this.entries});

  final List<CommandPaletteEntry> entries;

  static Future<void> show(
    BuildContext context, {
    required List<CommandPaletteEntry> entries,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close command palette',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, a, b) => CommandPalette(entries: entries),
      transitionBuilder: (ctx, anim, _, child) {
        final fade = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(fade),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _ctl = TextEditingController();
  final _focus = FocusNode();
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<CommandPaletteEntry> get _filtered {
    final q = _ctl.text.trim();
    final scored =
        widget.entries
            .map((e) => MapEntry(e, e.score(q)))
            .where((e) => e.value > 0)
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).take(12).toList(growable: false);
  }

  void _runSelected() {
    final list = _filtered;
    if (list.isEmpty) return;
    final i = _selected.clamp(0, list.length - 1);
    Navigator.of(context).pop();
    list[i].onSelect();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final results = _filtered;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 480),
        margin: const EdgeInsets.all(PsySpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(
                () => _selected = (_selected + 1).clamp(0, results.length - 1),
              );
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(
                () => _selected = (_selected - 1).clamp(0, results.length - 1),
              );
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              _runSelected();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(PsySpacing.md),
                child: TextField(
                  controller: _ctl,
                  focusNode: _focus,
                  onChanged: (_) => setState(() => _selected = 0),
                  onSubmitted: (_) => _runSelected(),
                  decoration: InputDecoration(
                    hintText: 'Jump to a screen, patient, action…',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: PsySpacing.sm,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text('ESC', style: theme.textTheme.labelSmall),
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 1, color: cs.outlineVariant),
              Flexible(
                child: results.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(PsySpacing.xxl),
                        child: Text(
                          'No match. Try a route, patient name, or '
                          'action verb.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final e = results[i];
                          final selected = i == _selected;
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              e.onSelect();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: PsySpacing.md,
                                vertical: PsySpacing.sm,
                              ),
                              color: selected
                                  ? cs.primary.withValues(alpha: 0.12)
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    e.icon ?? Icons.arrow_forward,
                                    size: 18,
                                    color: selected
                                        ? cs.primary
                                        : cs.onSurface.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: PsySpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          e.label,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: selected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                              ),
                                        ),
                                        if (e.subtitle != null)
                                          Text(
                                            e.subtitle!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: cs.onSurface
                                                      .withValues(alpha: 0.55),
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    e.section,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: cs.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  if (e.shortcut != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        e.shortcut!,
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Divider(height: 1, color: cs.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(PsySpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text('navigate', style: theme.textTheme.labelSmall),
                    const SizedBox(width: PsySpacing.md),
                    Text(
                      '↵ open · ESC close',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
