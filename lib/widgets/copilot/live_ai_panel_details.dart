/// Bottom-sheet presenters the LiveAiPanel pops once the underlying
/// model (DenialRisk / SupervisionReport / ClinicalLens) is already
/// loaded. Pure render — the panel owns the model + the fix-apply
/// callback and just dispatches here.
///
/// HIGH-3 slice 7 (audit 2026-06-21): trims the remaining
/// live_ai_panel.dart god-file by lifting the three biggest sheet
/// builders out of the panel state class.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../models/clinical_lens.dart';
import '../../models/denial_risk.dart';
import '../../models/supervision_report.dart';
import '../../services/billing/denial_shield_service.dart';
import 'risk_denial_strip.dart' show denialColor;

/// Denial Shield detail sheet. The panel passes `onApplyFixes` — when
/// the clinician taps "Update note & reset risk" we fire that
/// callback so the panel can mutate its `_note` + `_denial` state,
/// then pop the sheet ourselves.
void showDenialDetailsSheet(
  BuildContext context, {
  required DenialRisk denial,
  required VoidCallback onApplyFixes,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: denialColor(cs, denial),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${denial.level.label} · ${denial.payer.label}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${denial.cptCode} · ${denial.cptLabel}'
              '${denial.revenueAtRisk != null ? ' · ~\$${denial.revenueAtRisk!.round()} at risk' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (denial.reasons.any((r) => r.insertText != null)) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  onApplyFixes();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.auto_fix_high, size: 18),
                label: const Text('Update note & reset risk'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (denial.reasons.isEmpty)
              Text(
                'No denial drivers found for ${denial.payer.short}. '
                'Documentation supports the billed code.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ...denial.reasons.map(
                (r) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: r.critical
                          ? cs.error.withValues(alpha: 0.4)
                          : cs.outlineVariant,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      const SizedBox(height: 4),
                      Text(
                        r.detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 15,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                r.fixSentence,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.primary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              DenialShieldService.payerFocus(denial.payer),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Decision-support — payer rules and reimbursement vary and change. '
              'This estimates denial risk; it does not guarantee payment.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Supervision (de-identified) — fidelity score, summary, strengths
/// + growth areas + reflective questions, and a "copy anonymized"
/// CTA that puts the report on the clipboard.
void showSupervisionSheet(BuildContext context, SupervisionReport report) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final color = report.fidelityScore >= 80
      ? const Color(0xFF16A34A)
      : report.fidelityScore >= 60
      ? const Color(0xFFD97706)
      : cs.error;
  Widget list(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                Expanded(child: Text(i, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Icon(Icons.school_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${report.modalityLabel} supervision (de-identified)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${report.fidelityScore}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(
                    '/100 fidelity',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            if (report.summary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(report.summary, style: theme.textTheme.bodyMedium),
            ],
            if (report.fidelityNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                report.fidelityNotes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            list('Strengths', report.strengths),
            list('Growth areas', report.growthAreas),
            list('Reflective questions', report.reflectiveQuestions),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                unawaited(
                  Clipboard.setData(
                    ClipboardData(text: report.anonymizedText()),
                  ),
                );
                ScaffoldMessenger.of(sheetCtx).showSnackBar(
                  const SnackBar(
                    content: Text('De-identified report copied.'),
                  ),
                );
              },
              icon: const Icon(Icons.copy_outlined, size: 18),
              label: const Text('Copy anonymized report'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Decision-support for supervision — not a competency '
              'determination. Verify anonymization before sharing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Clinical Lens — the selected modality's structured read of the
/// session (sections of bulleted items).
void showClinicalLensSheet(BuildContext context, ClinicalLens lens) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Icon(Icons.center_focus_strong_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  '${lens.modalityLabel} lens',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final s in lens.sections) ...[
              Text(
                s.title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              ...s.items.map(
                (it) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      Expanded(
                        child: Text(it, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Decision-support — extracted from the transcript for review, not '
              'a diagnosis.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
