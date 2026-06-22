/// Chrome around the LiveAiPanel state-machine views: header
/// (live-pulse + brand + modality / format pickers + API-keys
/// shortcut) and footer (start / stop / cancel / new-session
/// buttons keyed by [PanelState]).
///
/// HIGH-3 (audit 2026-06-21): slice 5 of the live_ai_panel.dart
/// god-file split. The `PanelState` enum is hoisted here because
/// both Header and Footer key off it, and lifting it into the
/// chrome module avoids a third tiny file.
library;

import 'package:flutter/material.dart';

import '../../services/copilot/soap_generator_service.dart';

/// State machine the panel cycles through. Promoted from a
/// file-private enum so the extracted Header/Footer + the panel
/// itself share the same type.
enum PanelState { idle, listening, generating, noteReady, error }

/// Panel header — pulse indicator + brand label + modality /
/// format dropdowns + API-key shortcut. Sits at the top of the
/// LiveAiPanel.
class PanelHeader extends StatelessWidget {
  const PanelHeader({
    super.key,
    required this.cs,
    required this.theme,
    required this.state,
    required this.pulse,
    required this.format,
    required this.onFormatChanged,
    required this.modality,
    required this.onModalityChanged,
    required this.onOpenSettings,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final PanelState state;
  final AnimationController pulse;
  final SoapFormat format;
  final ValueChanged<SoapFormat>? onFormatChanged;
  final Modality modality;
  final ValueChanged<Modality>? onModalityChanged;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isLive = state == PanelState.listening;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (isLive)
            // prefers-reduced-motion → static red dot (no pulse/shadow).
            // WCAG 2.3.3 + Apple HIG. The icon-and-label combo still
            // conveys "live" without the throbbing visual.
            (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                ? Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                : AnimatedBuilder(
                    animation: pulse,
                    builder: (_, __) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(
                          alpha: 0.5 + pulse.value * 0.5,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(
                              alpha: pulse.value * 0.6,
                            ),
                            blurRadius: 8 + pulse.value * 4,
                          ),
                        ],
                      ),
                    ),
                  )
          else
            Icon(Icons.auto_awesome, color: cs.primary, size: 20),
          const SizedBox(width: 6),
          // On phones, two dropdowns + the key IconButton consume so much
          // width that any title ellipsizes to "Li...". The leading
          // sparkles/pulse icon already signals "AI co-pilot", so we drop
          // the title text below 560 and let the dropdowns keep full,
          // legible labels ("General" / "SOAP").
          Builder(
            builder: (ctx) {
              final wide = MediaQuery.sizeOf(ctx).width >= 560;
              if (!wide) return const SizedBox.shrink();
              return Flexible(
                child: Text(
                  'Live AI Co-Pilot',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const Spacer(),
          if (onModalityChanged != null)
            DropdownButtonHideUnderline(
              child: DropdownButton<Modality>(
                value: modality,
                icon: Icon(Icons.expand_more, color: cs.primary, size: 18),
                isDense: true,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                items: Modality.values
                    .map(
                      (m) => DropdownMenuItem(value: m, child: Text(m.label)),
                    )
                    .toList(),
                onChanged: (v) => v != null ? onModalityChanged!(v) : null,
              ),
            ),
          if (onModalityChanged != null) const SizedBox(width: 8),
          if (onFormatChanged != null)
            DropdownButtonHideUnderline(
              child: DropdownButton<SoapFormat>(
                value: format,
                icon: Icon(Icons.expand_more, color: cs.primary, size: 18),
                isDense: true,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                items: SoapFormat.values
                    .map(
                      (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                    )
                    .toList(),
                onChanged: (v) => v != null ? onFormatChanged!(v) : null,
              ),
            ),
          IconButton(
            tooltip: 'API Keys',
            icon: Icon(
              Icons.key,
              size: 18,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

/// Footer button row — content varies by [PanelState].
class PanelFooter extends StatelessWidget {
  const PanelFooter({
    super.key,
    required this.cs,
    required this.theme,
    required this.state,
    required this.onStart,
    required this.onStopGenerate,
    required this.onCancel,
    required this.onNewSession,
    required this.onSaveEdit,
    required this.onEdit,
    required this.editing,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final PanelState state;
  final VoidCallback onStart;
  final VoidCallback onStopGenerate;
  final VoidCallback onCancel;
  final VoidCallback onNewSession;
  final VoidCallback onSaveEdit;
  final VoidCallback onEdit;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: switch (state) {
        PanelState.idle => FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.mic, size: 18),
          label: const Text('Start AI Recording'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        ),
        PanelState.listening => Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onStopGenerate,
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stop & Generate Note'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: Colors.red[600],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Cancel',
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        PanelState.generating => OutlinedButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Generating note…'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        PanelState.noteReady => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: editing ? onSaveEdit : onEdit,
                icon: Icon(editing ? Icons.check : Icons.edit, size: 16),
                label: Text(editing ? 'Save edits' : 'Edit note'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onNewSession,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('New session'),
              ),
            ),
          ],
        ),
        PanelState.error => FilledButton.icon(
          onPressed: onNewSession,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try again'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        ),
      },
    );
  }
}
