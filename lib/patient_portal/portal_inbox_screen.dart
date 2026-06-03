import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/ds/psy_card.dart';

/// `/portal/inbox` — Patient-side secure-message inbox. Skeleton.
class PortalInboxScreen extends StatelessWidget {
  const PortalInboxScreen({super.key, this.threads});

  final List<PortalInboxThread>? threads;

  @override
  Widget build(BuildContext context) {
    final rows = threads ??
        <PortalInboxThread>[
          PortalInboxThread(
            subject: 'Pre-session check-in',
            preview: 'Just wanted to share how this week went…',
            updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
            unread: true,
          ),
          PortalInboxThread(
            subject: 'Refill request',
            preview: 'I confirmed the request with the pharmacy.',
            updatedAt:
                DateTime.now().subtract(const Duration(days: 2, hours: 1)),
            unread: false,
          ),
        ];
    return Scaffold(
      appBar: AppBar(title: const Text('Secure inbox')),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(PsySpacing.lg),
          itemCount: rows.length,
          itemBuilder: (_, i) {
            final r = rows[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: PsySpacing.md),
              child: PsyCard(
                // Thread detail view ships in a follow-up sprint;
                // leaving `onTap` null avoids a deceptive ink-splash
                // affordance on a no-op tap.
                onTap: null,
                child: Row(
                  children: [
                    Icon(r.unread ? Icons.mark_email_unread : Icons.mail),
                    const SizedBox(width: PsySpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.subject,
                              style:
                                  Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(r.preview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    Text(_relative(r.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall),
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

String _relative(DateTime t) {
  final delta = DateTime.now().difference(t);
  if (delta.inHours < 1) return '${delta.inMinutes}m';
  if (delta.inDays < 1) return '${delta.inHours}h';
  return '${delta.inDays}d';
}

class PortalInboxThread {
  const PortalInboxThread({
    required this.subject,
    required this.preview,
    required this.updatedAt,
    required this.unread,
  });
  final String subject;
  final String preview;
  final DateTime updatedAt;
  final bool unread;
}
