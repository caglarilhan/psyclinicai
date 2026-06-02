import 'package:flutter/material.dart';

import '../models/telehealth_session.dart';
import '../theme/brand_colors.dart';
import '../theme/tokens.dart';

/// Pre-call setup card surfaced on `/settings/telehealth` (Sprint 11
/// model wired to UI in Sprint 17). Renders the two consent toggles
/// (visit + recording) and the "Open room" CTA. Stateless: the
/// parent owns the [TelehealthSession] and rebuilds when the
/// callbacks fire.
class TelehealthControls extends StatelessWidget {
  const TelehealthControls({
    super.key,
    required this.session,
    this.onVisitConsentChanged,
    this.onRecordingConsentChanged,
    this.onOpenRoom,
  });

  final TelehealthSession session;
  final ValueChanged<VisitConsent>? onVisitConsentChanged;
  final ValueChanged<RecordingConsent>? onRecordingConsentChanged;
  final VoidCallback? onOpenRoom;

  bool get _readyToJoin =>
      session.visitConsent == VisitConsent.granted &&
      session.recordingConsent != RecordingConsent.notAsked;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Telehealth pre-flight', style: t.titleSmall),
            const SizedBox(height: PsySpacing.sm),
            _ConsentTile<VisitConsent>(
              label: 'Visit consent (HIPAA §164.510 / GDPR Art. 9)',
              current: session.visitConsent,
              options: const {
                VisitConsent.granted: 'Granted',
                VisitConsent.declined: 'Declined',
              },
              onChanged: onVisitConsentChanged,
            ),
            _ConsentTile<RecordingConsent>(
              label: 'Recording consent',
              current: session.recordingConsent,
              options: const {
                RecordingConsent.granted: 'Granted',
                RecordingConsent.declined: 'Declined',
              },
              onChanged: onRecordingConsentChanged,
            ),
            const SizedBox(height: PsySpacing.md),
            FilledButton.icon(
              onPressed: _readyToJoin ? onOpenRoom : null,
              icon: const Icon(Icons.video_call),
              label: const Text('Open meeting room'),
            ),
            if (!_readyToJoin)
              Padding(
                padding: const EdgeInsets.only(top: PsySpacing.xs),
                child: Text(
                  'Both consents must be recorded before the room can '
                  'be opened.',
                  style:
                      t.bodySmall?.copyWith(color: PsyColors.warning),
                ),
              ),
            const SizedBox(height: PsySpacing.sm),
            Container(
              padding: const EdgeInsets.all(PsySpacing.sm),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(PsyRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 16, color: cs.onTertiaryContainer),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'The meeting token is minted server-side and '
                      'never persisted. Recording is blocked unless '
                      'consent is explicitly granted.',
                      style: t.bodySmall
                          ?.copyWith(color: cs.onTertiaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentTile<T> extends StatelessWidget {
  const _ConsentTile({
    required this.label,
    required this.current,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T current;
  final Map<T, String> options;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.labelMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: PsySpacing.sm,
            children: [
              for (final entry in options.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: entry.key == current,
                  onSelected: onChanged == null
                      ? null
                      : (s) {
                          if (s) onChanged!(entry.key);
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
