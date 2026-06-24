/// Bottom sheet that surfaces the latest entry in [ReleaseNotes] on
/// the user's next dashboard mount after a new release ships. Auto-
/// dismissed by tapping "Got it" — that fires
/// [ReleaseNotesSeenRepository.markSeen] so the sheet does not pop
/// again until the next version.
///
/// Render is intentionally plain. The full historical changelog is
/// at `/changelog`.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../services/data/release_notes_seen_repository.dart';
import '../services/data/telemetry_service.dart';
import '../services/release_notes.dart';

/// Pops the sheet if [release.version] differs from what the user
/// has previously dismissed. Safe to call repeatedly on the same
/// surface — second call is a no-op once the user has acknowledged.
Future<void> maybeShowWhatsNew(
  BuildContext context, {
  ReleaseNotesSeenRepository? repo,
  Release? release,
}) async {
  final r = release ?? ReleaseNotes.latest;
  final store = repo ?? ReleaseNotesSeenRepository();
  if (!await store.shouldShow(r.version)) return;
  if (!context.mounted) return;
  unawaited(
    TelemetryService.instance.capture(
      'release_notes.shown',
      properties: {'version': r.version},
    ),
  );
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => WhatsNewSheet(release: r, repo: store),
  );
}

class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key, required this.release, required this.repo});

  final Release release;
  final ReleaseNotesSeenRepository repo;

  Future<void> _dismiss(BuildContext context) async {
    await repo.markSeen(release.version);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.celebration_outlined, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'What’s new in v${release.version}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${release.tag} · ${release.date}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final b in release.bullets)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 8),
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                b,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
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
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _dismiss(context),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
