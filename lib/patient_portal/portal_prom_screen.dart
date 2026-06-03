import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/ds/psy_badge.dart';
import '../widgets/ds/psy_card.dart';

/// `/portal/proms` — Patient-side PROM assignment queue. Skeleton.
class PortalPromScreen extends StatelessWidget {
  const PortalPromScreen({super.key, this.assignments});

  final List<PortalPromAssignment>? assignments;

  @override
  Widget build(BuildContext context) {
    final rows = assignments ??
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
                          child: Text(r.scaleName,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
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
                    Text('~${r.estimatedMinutes} min · paced for you',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: PsySpacing.sm),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context)
                            .pushNamed('/portal/proms/${r.scaleId}'),
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
