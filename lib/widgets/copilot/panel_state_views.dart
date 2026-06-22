/// Five state-machine views the LiveAiPanel switches between:
/// idle, listening, generating, note-ready, and error. Each view
/// is a tiny stateless widget that the panel constructs from its
/// current state snapshot.
///
/// HIGH-3 (audit 2026-06-21): slice 4 of the live_ai_panel.dart
/// god-file split. Grouping the five views in one module keeps
/// the state-machine surface contiguous + readable.
library;

import 'package:flutter/material.dart';

import '../../services/copilot/soap_generator_service.dart';

/// Empty state — before the clinician taps Start.
class IdleView extends StatelessWidget {
  const IdleView({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_none, size: 40, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to listen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Press Start to capture the session on-device. A structured note '
            'is generated when you stop.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Active transcription — final words in opaque body, in-flight
/// partial in italic / faded.
class ListeningView extends StatelessWidget {
  const ListeningView({
    super.key,
    required this.theme,
    required this.cs,
    required this.transcript,
    required this.partial,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String transcript;
  final String partial;

  @override
  Widget build(BuildContext context) {
    final hasContent = transcript.isNotEmpty || partial.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: hasContent
          ? SingleChildScrollView(
              reverse: true,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface,
                    height: 1.55,
                  ),
                  children: [
                    if (transcript.isNotEmpty) TextSpan(text: '$transcript '),
                    if (partial.isNotEmpty)
                      TextSpan(
                        text: partial,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Center(
              child: Text(
                'Speak naturally…',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
    );
  }
}

/// Note-generation in flight — linear progress + faded transcript.
class GeneratingView extends StatelessWidget {
  const GeneratingView({
    super.key,
    required this.theme,
    required this.cs,
    required this.transcript,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(
            color: cs.primary,
            backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Synthesizing structured note…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                transcript,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Finished SOAP note — header chips (format + risk flag) +
/// action row (lens / supervision / superbill) + viewable or
/// editable body.
class NoteReadyView extends StatelessWidget {
  const NoteReadyView({
    super.key,
    required this.theme,
    required this.cs,
    required this.note,
    required this.controller,
    required this.editing,
    required this.onCreateSuperbill,
    required this.onClinicalLens,
    required this.loadingLens,
    required this.onSupervision,
    required this.loadingSupervision,
    required this.modalityLabel,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final SoapNote note;
  final TextEditingController controller;
  final bool editing;
  final VoidCallback onCreateSuperbill;
  final VoidCallback onClinicalLens;
  final bool loadingLens;
  final VoidCallback onSupervision;
  final bool loadingSupervision;
  final String modalityLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${note.format.label} note',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (note.flaggedRisk) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Risk flagged',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: loadingLens ? null : onClinicalLens,
                visualDensity: VisualDensity.compact,
                tooltip: '$modalityLabel lens',
                icon: loadingLens
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.center_focus_strong_outlined, size: 18),
              ),
              IconButton(
                onPressed: loadingSupervision ? null : onSupervision,
                visualDensity: VisualDensity.compact,
                tooltip: 'Supervision report (de-identified)',
                icon: loadingSupervision
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.school_outlined, size: 18),
              ),
              IconButton(
                onPressed: onCreateSuperbill,
                visualDensity: VisualDensity.compact,
                tooltip: 'Create superbill',
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: editing
                ? TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      controller.text.isEmpty
                          ? note.rawMarkdown
                          : controller.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Error state — supports the "no API key" branch with a direct
/// link to the API Keys settings.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.theme,
    required this.cs,
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isNoKey = message.toLowerCase().contains('api key');
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Could not complete',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          if (isNoKey) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.key, size: 16),
              label: const Text('Open API Keys settings'),
            ),
          ],
        ],
      ),
    );
  }
}
