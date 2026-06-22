/// Live decision-support strips for the session co-pilot: the
/// red/amber risk-signal pills + the payer-aware Denial Shield
/// banner. Both are tiny stateless widgets reading value-objects
/// (`RiskSignal`, `DenialRisk`) and never reach for state, so they
/// extract cleanly from live_ai_panel.dart's god-file.
///
/// HIGH-3 (audit 2026-06-21): slice 3 of the live_ai_panel.dart
/// split. RiskStrip + DenialBanner share the rail concept ("live
/// hint above the note") but are otherwise independent — the
/// denial helper colour mapping is unique to DenialBanner so it
/// stays a private function in this module.
library;

import 'package:flutter/material.dart';

import '../../models/denial_risk.dart';
import '../../services/copilot/risk_signal_service.dart';
import '../../theme/tokens.dart';

/// Header strip rendered above the SOAP draft when one or more
/// risk signals fire during transcription. Sorts by severity then
/// recency so the worst trigger is always on the left. Each pill
/// carries a Tooltip with the matched snippet + source tag so the
/// clinician can audit a decision before acting on it.
class RiskStrip extends StatelessWidget {
  const RiskStrip({
    super.key,
    required this.signals,
    required this.theme,
    required this.cs,
  });

  final List<RiskSignal> signals;
  final ThemeData theme;
  final ColorScheme cs;

  Color _color(RiskSeverity s) => switch (s) {
    // L-2 (audit 2026-06-21): imminent = deepest red, distinct from
    // high so the clinician can spot acute intent at a glance.
    RiskSeverity.imminent => const Color(0xFFB91C1C),
    RiskSeverity.high => const Color(0xFFDC2626),
    RiskSeverity.elevated => const Color(0xFFD97706),
    RiskSeverity.info => cs.primary,
  };

  @override
  Widget build(BuildContext context) {
    // Highest severity first, then most recent.
    final sorted = [...signals]
      ..sort(
        (a, b) => b.severity.index != a.severity.index
            ? b.severity.index - a.severity.index
            : b.at.compareTo(a.at),
      );
    final topColor = _color(sorted.first.severity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: topColor.withValues(alpha: 0.06),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined, size: 16, color: topColor),
              const SizedBox(width: 6),
              Text(
                'Live risk signals (${signals.length})',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: topColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorted.map((s) {
              final c = _color(s.severity);
              return Tooltip(
                message:
                    '${s.severity.label} · ${s.snippet}'
                    '${s.source == RiskSource.ai ? '  (AI)' : ''}',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: c.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 12, color: c),
                      const SizedBox(width: 4),
                      Text(
                        s.category.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: c,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            'Decision-support — review clinically, not a diagnosis.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Public — also used by the panel state class + the
/// ComplianceRail to colour the denial cluster. Kept public so the
/// god-file split does not introduce a duplicate mapping.
Color denialColor(ColorScheme cs, DenialRisk d) => switch (d.level) {
  DenialLevel.high => cs.error,
  DenialLevel.medium => const Color(0xFFD97706),
  DenialLevel.low => const Color(0xFF16A34A),
};

/// Denial Shield strip — payer-aware claim-rejection risk for the
/// note, with a payer selector. Tap opens the reasons + the exact
/// sentences to add.
class DenialBanner extends StatelessWidget {
  const DenialBanner({
    super.key,
    required this.denial,
    required this.payer,
    required this.theme,
    required this.cs,
    required this.onPayerChanged,
    required this.onDetails,
  });

  final DenialRisk denial;
  final Payer payer;
  final ThemeData theme;
  final ColorScheme cs;
  final ValueChanged<Payer> onPayerChanged;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final color = denialColor(cs, denial);
    final risk = denial.revenueAtRisk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDetails,
          borderRadius: BorderRadius.circular(PsyRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(PsyRadius.md),
              border: Border.all(color: color.withValues(alpha: 0.32)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${denial.level.label} · ${denial.cptCode}'
                    '${risk != null ? ' · ~\$${risk.round()} risk' : ''}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Payer>(
                    value: payer,
                    isDense: true,
                    icon: const Icon(Icons.expand_more, size: 16),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface,
                    ),
                    items: [
                      for (final p in Payer.values)
                        DropdownMenuItem(value: p, child: Text(p.short)),
                    ],
                    onChanged: (p) => p == null ? null : onPayerChanged(p),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
