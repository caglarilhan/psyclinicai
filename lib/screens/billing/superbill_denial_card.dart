/// Denial Shield summary card shown above the superbill form when
/// the screen was launched from a session note. Displays:
///   - Tier-coloured header (high → cs.error, medium → amber, low → green)
///   - Payer dropdown so the clinician can re-evaluate against a
///     different payer without leaving the form
///   - CPT code + at-risk dollar estimate
///   - Each `r.title` reason + `r.fixSentence` action line
///   - Payer-specific focus footer (DenialShieldService.payerFocus)
///
/// HIGH-class refactor (audit 2026-06-21): extracted from
/// superbill_screen.dart so the screen file owns its form state +
/// generate flow only.
library;

import 'package:flutter/material.dart';

import '../../models/denial_risk.dart';
import '../../services/billing/denial_shield_service.dart';

class DenialShieldCard extends StatelessWidget {
  const DenialShieldCard({
    super.key,
    required this.denial,
    required this.payer,
    required this.onPayerChanged,
    required this.theme,
    required this.cs,
  });

  final DenialRisk denial;
  final Payer payer;
  final ValueChanged<Payer> onPayerChanged;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final color = switch (denial.level) {
      DenialLevel.high => cs.error,
      DenialLevel.medium => const Color(0xFFD97706),
      DenialLevel.low => const Color(0xFF16A34A),
    };
    final risk = denial.revenueAtRisk;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Denial Shield · ${denial.level.label}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              DropdownButton<Payer>(
                value: payer,
                isDense: true,
                underline: const SizedBox.shrink(),
                items: [
                  for (final p in Payer.values)
                    DropdownMenuItem(value: p, child: Text(p.short)),
                ],
                onChanged: (p) => p == null ? null : onPayerChanged(p),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${denial.cptCode} · ${denial.cptLabel}'
            '${risk != null ? ' · ~\$${risk.round()} at risk if denied' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          if (denial.reasons.isEmpty)
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Documentation supports billing — no denial drivers for '
                    '${payer.short}.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            )
          else
            ...denial.reasons.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          r.critical
                              ? Icons.error_outline
                              : Icons.warning_amber_rounded,
                          size: 16,
                          color: r.critical
                              ? cs.error
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            r.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 22, top: 4),
                      child: Text(
                        '+ ${r.fixSentence}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            DenialShieldService.payerFocus(payer),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
