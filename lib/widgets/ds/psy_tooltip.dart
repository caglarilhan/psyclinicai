/// Clinical-grade tooltip wrapper.
///
/// Material's default tooltip pops fast and disappears on the first
/// pointer move — useful for "Bookmark" / "Refresh" affordances,
/// rough for clinical metadata like "F32.1 — Major Depressive
/// Disorder, Single Episode, Moderate" that a clinician wants to
/// hover-read for a beat without the tip vanishing.
///
/// PsyTooltip:
///   - 800 ms hover wait → 8 s visible (Material defaults: 0 / 1.5 s)
///   - Two-line layout: short [label] on top, optional richer
///     [description] underneath in a calmer foreground colour
///   - Matches the rest of the DS surfaces (radius 8, body text)
///   - Skips the tooltip entirely when [label] is empty so a call
///     site can pass a possibly-null description without guarding
///     at every site
///
/// Usage:
/// ```dart
/// PsyTooltip(
///   label: 'F32.1',
///   description: 'Major Depressive Disorder, Single Episode, Moderate',
///   child: PsyBadge(label: 'F32.1'),
/// );
/// ```
library;

import 'package:flutter/material.dart';

class PsyTooltip extends StatelessWidget {
  const PsyTooltip({
    super.key,
    required this.label,
    required this.child,
    this.description,
  });

  /// Bold primary line — typically the code or short name.
  final String label;

  /// Optional secondary line — the human-readable expansion.
  /// When null/empty the tooltip renders just the [label].
  final String? description;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return child;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final desc = description?.trim();
    // We carry the screen-reader content on the surrounding Semantics
    // node (Material's Tooltip rejects having both `message` and
    // `richMessage` set), and use `richMessage` purely for the visual
    // hierarchy on hover / long-press.
    return Semantics(
      label: label,
      hint: desc,
      container: true,
      child: Tooltip(
        richMessage: WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onInverseSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (desc != null && desc.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onInverseSurface.withValues(alpha: 0.8),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        waitDuration: const Duration(milliseconds: 800),
        showDuration: const Duration(seconds: 6),
        triggerMode: TooltipTriggerMode.longPress,
        decoration: BoxDecoration(
          color: cs.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ExcludeSemantics(child: child),
      ),
    );
  }
}
