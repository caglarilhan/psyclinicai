/// Session-insights bottom sheet — surfaced by [LiveAiPanel] when
/// the clinician taps the "Insights" affordance. Self-contained,
/// reads from [SessionInsights] and renders a five-section
/// reflective brief (alliance + strengths / interventions /
/// themes / suggestions / homework).
///
/// HIGH-3 (audit 2026-06-21): hoisted out of live_ai_panel.dart's
/// 2,479-line god-file so the panel can shrink one fewer
/// stateless leaf at a time.
library;

import 'package:flutter/material.dart';

import '../../services/copilot/session_insights_service.dart';

class InsightsSheet extends StatelessWidget {
  const InsightsSheet({super.key, required this.insights});
  final SessionInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Widget section(String title, IconData icon, List<String> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...items.map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 22, top: 2),
                child: Text(
                  '• $s',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Session insights',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (insights.alliance.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  insights.alliance,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    section(
                      'Strengths',
                      Icons.thumb_up_outlined,
                      insights.strengths,
                    ),
                    section(
                      'Interventions observed',
                      Icons.handyman_outlined,
                      insights.interventions,
                    ),
                    section(
                      'Client themes',
                      Icons.topic_outlined,
                      insights.themes,
                    ),
                    section(
                      'Suggestions for next time',
                      Icons.lightbulb_outline,
                      insights.suggestions,
                    ),
                    section(
                      'Homework ideas',
                      Icons.assignment_outlined,
                      insights.homework,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reflective AI feedback — not a performance evaluation and not a '
              'substitute for clinical supervision.',
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
