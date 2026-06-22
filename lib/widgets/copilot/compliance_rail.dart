/// Compliance rail — the right-hand column of the LiveAiPanel
/// wide split view. Shows audit-readiness on top and the Denial
/// Shield panel below; both reflect the current SOAP note and
/// give the clinician decision-support hooks (deep AI check,
/// per-driver fixes, one-click "update note & reset risk").
///
/// HIGH-3 (audit 2026-06-21): slice 6 of the live_ai_panel.dart
/// god-file split. The rail is a fat stateless widget (~270
/// lines) that pulls together the two compliance value-objects
/// the panel state owns — extracting it lets the panel file
/// focus on its state machine.
library;

import 'package:flutter/material.dart';

import '../../models/denial_risk.dart';
import '../../services/copilot/compliance_check_service.dart';
import 'risk_denial_strip.dart' show denialColor;

class ComplianceRail extends StatelessWidget {
  const ComplianceRail({
    super.key,
    required this.report,
    required this.denial,
    required this.payer,
    required this.deepChecking,
    required this.loadingInsights,
    required this.theme,
    required this.cs,
    required this.onDetails,
    required this.onDeepCheck,
    required this.onInsights,
    required this.onPayerChanged,
    required this.onApplyFixes,
  });

  final ComplianceReport? report;
  final DenialRisk? denial;
  final Payer payer;
  final bool deepChecking;
  final bool loadingInsights;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onDetails;
  final VoidCallback onDeepCheck;
  final VoidCallback onInsights;
  final ValueChanged<Payer> onPayerChanged;
  final VoidCallback onApplyFixes;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerLowest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report != null) _audit(report!),
            if (report != null && denial != null) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: cs.outlineVariant),
              const SizedBox(height: 14),
            ],
            if (denial != null) _denialPanel(denial!),
          ],
        ),
      ),
    );
  }

  Widget _audit(ComplianceReport r) {
    final score = r.score;
    final color = score >= 80
        ? const Color(0xFF16A34A)
        : score >= 60
        ? const Color(0xFFD97706)
        : cs.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUDIT READINESS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$score%',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${r.toFixCount} to fix',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        if (r.summary != null && r.summary!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            r.summary!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _railBtn(Icons.list_alt_outlined, 'Details', onDetails),
            _railBtn(
              deepChecking ? null : Icons.auto_awesome,
              deepChecking ? 'Checking…' : 'Deep check',
              deepChecking ? null : onDeepCheck,
            ),
            _railBtn(
              loadingInsights ? null : Icons.psychology_alt_outlined,
              loadingInsights ? 'Loading…' : 'Insights',
              loadingInsights ? null : onInsights,
            ),
          ],
        ),
      ],
    );
  }

  Widget _denialPanel(DenialRisk d) {
    final color = denialColor(cs, d);
    final risk = d.revenueAtRisk;
    final canApply = d.reasons.any((r) => r.insertText != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_user_outlined, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'DENIAL SHIELD',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            DropdownButton<Payer>(
              value: payer,
              isDense: true,
              underline: const SizedBox.shrink(),
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurface),
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
          d.level.label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${d.cptCode} · ${d.cptLabel}'
          '${risk != null ? ' · ~\$${risk.round()} at risk' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        if (d.reasons.isEmpty)
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Documentation supports the billed code.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          )
        else
          ...d.reasons.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
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
                        size: 14,
                        color: r.critical ? cs.error : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          r.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 19, top: 2),
                    child: Text(
                      '+ ${r.fixSentence}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        height: 1.4,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (canApply) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onApplyFixes,
              icon: const Icon(Icons.auto_fix_high, size: 16),
              label: const Text('Update note & reset risk'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _railBtn(IconData? icon, String label, VoidCallback? onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon != null
          ? Icon(icon, size: 14)
          : const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}
