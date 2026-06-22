import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/ds/psy_badge.dart';
import '../widgets/ds/psy_card.dart';

/// `/portal/proms` — Patient-side PROM assignment queue. Skeleton.
///
/// **Clinical-safety contract:** patient-side completion is restricted
/// to non-acuity self-report scales. High-acuity instruments (C-SSRS,
/// safety-plan reviews, trauma exposure) MUST be administered with a
/// clinician present and live escalation paths — they are filtered
/// out here even if a clinician accidentally assigns them to the
/// patient portal.
const Set<String> kPortalSafePromIds = {
  'phq9',
  'gad7',
  'who5',
  'pss10',
  'pcl5_screen',
  'audit',
  'eq5d',
};

class PortalPromScreen extends StatelessWidget {
  const PortalPromScreen({super.key, this.assignments});

  final List<PortalPromAssignment>? assignments;

  @override
  Widget build(BuildContext context) {
    final rawRows =
        assignments ??
        <PortalPromAssignment>[
          const PortalPromAssignment(
            scaleId: 'phq9',
            scaleName: 'PHQ-9 — depression check-in',
            estimatedMinutes: 3,
            dueInDays: 1,
          ),
          const PortalPromAssignment(
            scaleId: 'gad7',
            scaleName: 'GAD-7 — anxiety check-in',
            estimatedMinutes: 2,
            dueInDays: 3,
          ),
        ];
    // Hard allow-list — high-acuity scales (C-SSRS, full PCL-5, safety
    // plan reviews) cannot be administered unsupervised on the portal.
    final rows = rawRows
        .where((a) => kPortalSafePromIds.contains(a.scaleId))
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('Questionnaires')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(PsySpacing.lg),
          itemCount: rows.length,
          itemBuilder: (_, i) {
            final r = rows[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: PsyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.scaleName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        PsyBadge(
                          label: 'Due in ${r.dueInDays}d',
                          tone: r.dueInDays <= 1
                              ? PsyBadgeTone.warning
                              : PsyBadgeTone.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: PsySpacing.xs),
                    Text(
                      '~${r.estimatedMinutes} min · paced for you',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: PsySpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () {
                          // Defence-in-depth — list is already filtered,
                          // but never build a route from a raw scaleId.
                          if (!kPortalSafePromIds.contains(r.scaleId)) {
                            return;
                          }
                          unawaited(
                            Navigator.of(
                              context,
                            ).pushNamed('/portal/proms/${r.scaleId}'),
                          );
                        },
                        child: const Text('Start'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PortalPromAssignment {
  const PortalPromAssignment({
    required this.scaleId,
    required this.scaleName,
    required this.estimatedMinutes,
    required this.dueInDays,
  });
  final String scaleId;
  final String scaleName;
  final int estimatedMinutes;
  final int dueInDays;
}
