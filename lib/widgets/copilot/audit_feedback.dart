/// Audit-readiness feedback for the live session — the score
/// banner that sits above the SOAP draft + the bottom sheet with
/// per-check detail (pass / warn / fail rows from the
/// `ComplianceReport`).
///
/// HIGH-3 (audit 2026-06-21): hoisted out of the live_ai_panel.dart
/// god-file. AuditBanner and AuditSheet always travel together
/// (sheet is opened from the banner's "Details" button) so they
/// share this module.
library;

import 'package:flutter/material.dart';

import '../../services/copilot/compliance_check_service.dart';

/// Banner colour by overall score: green ≥ 80%, amber 60-79%, red < 60%.
Color scoreColor(int score) => score >= 80
    ? const Color(0xFF16A34A)
    : score >= 60
    ? const Color(0xFFD97706)
    : const Color(0xFFDC2626);

/// Status-bullet colour for a single check row in the sheet.
Color checkColor(CheckStatus s) => switch (s) {
  CheckStatus.pass => const Color(0xFF16A34A),
  CheckStatus.warn => const Color(0xFFD97706),
  CheckStatus.fail => const Color(0xFFDC2626),
};

/// Status-bullet icon for a single check row in the sheet.
IconData checkIcon(CheckStatus s) => switch (s) {
  CheckStatus.pass => Icons.check_circle,
  CheckStatus.warn => Icons.error_outline,
  CheckStatus.fail => Icons.cancel,
};

/// Header strip on the SOAP draft — surfaces overall score +
/// quick-actions (Insights, Details, optional AI deep-check).
class AuditBanner extends StatelessWidget {
  const AuditBanner({
    super.key,
    required this.report,
    required this.deepChecking,
    required this.theme,
    required this.cs,
    required this.onDetails,
    required this.onDeepCheck,
    required this.onInsights,
    required this.loadingInsights,
  });

  final ComplianceReport report;
  final bool deepChecking;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onDetails;
  final VoidCallback onDeepCheck;
  final VoidCallback onInsights;
  final bool loadingInsights;

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(report.score);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            'Audit readiness ${report.score}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (report.toFixCount > 0) ...[
            const SizedBox(width: 6),
            Text(
              '· ${report.toFixCount} to fix',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: loadingInsights ? null : onInsights,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: loadingInsights
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.school_outlined, size: 14),
            label: const Text('Insights'),
          ),
          TextButton(
            onPressed: onDetails,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Details'),
          ),
          if (report.source != ComplianceSource.ai)
            TextButton.icon(
              onPressed: deepChecking ? null : onDeepCheck,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: deepChecking
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 14),
              label: const Text('AI check'),
            ),
        ],
      ),
    );
  }
}

/// Modal sheet showing the per-check rubric breakdown.
class AuditSheet extends StatelessWidget {
  const AuditSheet({super.key, required this.report});
  final ComplianceReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = scoreColor(report.score);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_outlined, color: color),
                const SizedBox(width: 8),
                Text(
                  'Audit readiness · ${report.score}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  report.source == ComplianceSource.ai
                      ? 'AI review'
                      : 'Quick check',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (report.summary != null) ...[
              const SizedBox(height: 6),
              Text(
                report.summary!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: report.checks
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                checkIcon(c.status),
                                size: 18,
                                color: checkColor(c.status),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.label,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (c.fix != null)
                                      Text(
                                        c.fix!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurface.withValues(
                                                alpha: 0.7,
                                              ),
                                              height: 1.4,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Decision-support against the payer "golden thread" rubric — '
              'review clinically. Not a reimbursement guarantee.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
