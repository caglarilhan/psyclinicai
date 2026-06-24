import 'package:flutter/material.dart';

import '../../services/release_notes.dart';
import '../../theme/tokens.dart';
import '../../widgets/static/static_page_shell.dart';

/// `/changelog` — public release notes. Reads from the shared
/// [ReleaseNotes] ledger so the in-app "What's new" sheet and this
/// page can never drift apart.
class ChangelogPage extends StatelessWidget {
  const ChangelogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'Release notes',
      title: 'Changelog',
      lede:
          'Every meaningful change we ship. Older entries are preserved — we '
          'do not edit history.',
      lastUpdated: DateTime(2026, 6, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ReleaseNotes.releases
            .map((r) => _ReleaseCard(release: r))
            .toList(),
      ),
    );
  }
}

class _ReleaseCard extends StatelessWidget {
  const _ReleaseCard({required this.release});
  final Release release;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: PsySpacing.xl),
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: PsySpacing.md,
            runSpacing: PsySpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PsySpacing.md,
                  vertical: PsySpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(PsyRadius.full),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
                ),
                child: Text(
                  'v${release.version}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                release.date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
              Text(
                release.tag,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.lg),
          ...release.bullets.map(StaticBullet.new),
        ],
      ),
    );
  }
}
