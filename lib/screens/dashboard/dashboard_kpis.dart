/// KPI row + cards for the clinician dashboard. The row hosts four
/// outcome metrics (today's sessions, pending notes, at-risk patients,
/// outstanding superbills) that resolve to one of three lifecycle
/// states — loading, data, error — each rendered by its own widget
/// so the dashboard never half-paints.
///
/// HIGH-6 slice A (audit 2026-06-21): extracted from
/// dashboard_screen.dart so the screen file owns layout + state
/// only.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Sprint 29 F-06 — explicit lifecycle for KPI cards. Each card resolves
/// to exactly one of these so the screen never renders a confused mix.
enum KpiState { loading, data, error }

class Kpi {
  Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    this.emptyText,
    this.state = KpiState.data,
    this.onRetry,
  });
  final String label;

  /// `value` is null while there is no backend data; the card then renders
  /// `emptyText` in a calmer body style instead of a giant em-dash.
  final String? value;
  final String? emptyText;
  final IconData icon;
  final Color tint;
  final KpiState state;
  final VoidCallback? onRetry;
}

class KpiRow extends StatelessWidget {
  const KpiRow({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    // Demo-mode seed so the dashboard reads "live" instead of "broken".
    // Production wiring swaps this for a Firestore stream feeding
    // DashboardMetricsBuilder; surface stays the same.
    final kpis = <Kpi>[
      Kpi(
        label: "Today's sessions",
        value: '4',
        emptyText: 'Next at 13:30 · John Demo',
        icon: Icons.event_available_outlined,
        tint: cs.primary,
      ),
      Kpi(
        label: 'Pending notes',
        value: '2',
        emptyText: 'Both > 24h — sign before billing',
        icon: Icons.edit_note_outlined,
        tint: cs.tertiary,
      ),
      Kpi(
        label: 'At-risk patients (7d)',
        value: '1',
        emptyText: 'PHQ-9 ≥ 15 or C-SSRS flag',
        icon: Icons.health_and_safety_outlined,
        tint: cs.error,
      ),
      Kpi(
        label: 'Outstanding superbills',
        value: '\$680',
        emptyText: 'Oldest 12 days — chase before 30d',
        icon: Icons.receipt_long_outlined,
        tint: cs.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= PsyBreakpoints.lg
            ? 4
            : c.maxWidth >= PsyBreakpoints.sm
            ? 2
            : 1;
        final cardW = (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
        return Wrap(
          spacing: PsySpacing.lg,
          runSpacing: PsySpacing.lg,
          children: kpis
              .map(
                (k) => SizedBox(
                  width: cardW,
                  child: KpiCard(kpi: k, theme: theme, cs: cs),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.kpi,
    required this.theme,
    required this.cs,
  });
  final Kpi kpi;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kpi.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            child: Icon(kpi.icon, color: kpi.tint, size: 22),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sprint 29 F-06 — render exactly one of the 3 lifecycle
                // states so the dashboard never half-paints.
                switch (kpi.state) {
                  KpiState.loading => KpiLoadingLine(cs: cs),
                  KpiState.error => KpiErrorLine(
                    cs: cs,
                    theme: theme,
                    onRetry: kpi.onRetry,
                  ),
                  KpiState.data =>
                    kpi.value != null
                        // A11y guard (audit 2026-06-21 — DESIGN.md
                        // dynamic-type follow-up): accessibility text
                        // scale ≥1.3 was pushing "$680" / "1 234" beyond
                        // the card edge. FittedBox.scaleDown bounds the
                        // numeral to the card width without breaking
                        // smaller numbers.
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              kpi.value!,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            // Empty state: smaller, muted — reads as
                            // "ready, no data yet" instead of a broken
                            // placeholder.
                            kpi.emptyText ?? '—',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                },
                const SizedBox(height: PsySpacing.xxs),
                Text(
                  kpi.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing skeleton line for [KpiState.loading]. Pure CSS-style
/// pulse so we don't pull in a shimmer dependency.
class KpiLoadingLine extends StatefulWidget {
  const KpiLoadingLine({super.key, required this.cs});
  final ColorScheme cs;

  @override
  State<KpiLoadingLine> createState() => _KpiLoadingLineState();
}

class _KpiLoadingLineState extends State<KpiLoadingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alpha;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    unawaited(_ctrl.repeat(reverse: true));
    _alpha = Tween<double>(begin: 0.35, end: 0.75).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alpha,
      builder: (_, __) {
        return Semantics(
          label: 'Loading metric',
          liveRegion: true,
          child: Container(
            height: 26,
            width: 96,
            decoration: BoxDecoration(
              color: widget.cs.onSurface.withValues(alpha: _alpha.value * 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      },
    );
  }
}

/// Error row for [KpiState.error] — readable label + actionable retry.
class KpiErrorLine extends StatelessWidget {
  const KpiErrorLine({
    super.key,
    required this.cs,
    required this.theme,
    required this.onRetry,
  });
  final ColorScheme cs;
  final ThemeData theme;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Failed to load metric',
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Unavailable',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
