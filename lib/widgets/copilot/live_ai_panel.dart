import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/copilot/soap_generator_service.dart';
import '../../services/copilot/transcription_service.dart';

/// Real-time AI Co-Pilot panel.
///
/// Three visual states: idle → listening → generating → noteReady (or error).
/// Material 3 surface tokens, animated state transitions, accessible contrast.
class LiveAiPanel extends StatefulWidget {
  const LiveAiPanel({
    super.key,
    this.clientName,
    this.clientPresenting,
    this.clinicianRole = 'licensed mental health clinician',
    this.localeId = 'en_US',
  });

  final String? clientName;
  final String? clientPresenting;
  final String clinicianRole;
  final String localeId;

  @override
  State<LiveAiPanel> createState() => _LiveAiPanelState();
}

enum _PanelState { idle, listening, generating, noteReady, error }

class _LiveAiPanelState extends State<LiveAiPanel>
    with SingleTickerProviderStateMixin {
  late final TranscriptionService _transcription;
  late final SoapGeneratorService _generator;
  late final AnimationController _pulse;

  StreamSubscription<TranscriptUpdate>? _sub;

  _PanelState _state = _PanelState.idle;
  String _transcript = '';
  String _partial = '';
  String? _errorMessage;
  SoapNote? _note;
  SoapFormat _format = SoapFormat.soap;
  final _editCtl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _transcription = TranscriptionService();
    _generator = SoapGeneratorService();
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);

    _initialize();
  }

  Future<void> _initialize() async {
    await _transcription.initialize();
    _sub = _transcription.transcriptStream.listen(_onTranscript);
    if (mounted) setState(() {});
  }

  void _onTranscript(TranscriptUpdate u) {
    if (!mounted) return;
    setState(() {
      _transcript = u.fullTranscript;
      _partial = u.partial;
    });
  }

  Future<void> _startListening() async {
    if (!_transcription.available) {
      await _transcription.initialize();
      if (!_transcription.available) {
        setState(() {
          _state = _PanelState.error;
          _errorMessage =
              'Microphone or speech recognition not available on this device.';
        });
        return;
      }
    }
    setState(() {
      _state = _PanelState.listening;
      _errorMessage = null;
      _transcript = '';
      _partial = '';
      _note = null;
      _transcription.reset();
    });
    await _transcription.start(localeId: widget.localeId);
  }

  Future<void> _stopAndGenerate() async {
    await _transcription.stop();
    final fullText = _transcription.fullTranscript.trim();
    if (fullText.isEmpty) {
      setState(() {
        _state = _PanelState.error;
        _errorMessage =
            'No speech detected. Try again with the microphone closer.';
      });
      return;
    }
    setState(() => _state = _PanelState.generating);

    try {
      final note = await _generator.generate(
        transcript: fullText,
        format: _format,
        clientName: widget.clientName,
        clientPresenting: widget.clientPresenting,
        clinicianRole: widget.clinicianRole,
      );
      if (!mounted) return;
      setState(() {
        _note = note;
        _editCtl.text = note.rawMarkdown;
        _state = _PanelState.noteReady;
      });
    } on SoapGeneratorException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _PanelState.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _PanelState.error;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _cancelListening() async {
    await _transcription.cancel();
    setState(() {
      _state = _PanelState.idle;
      _transcript = '';
      _partial = '';
    });
  }

  void _resetForNewSession() {
    setState(() {
      _state = _PanelState.idle;
      _transcript = '';
      _partial = '';
      _note = null;
      _editing = false;
      _editCtl.clear();
      _errorMessage = null;
      _transcription.reset();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _transcription.dispose();
    _generator.dispose();
    _pulse.dispose();
    _editCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _Header(
            cs: cs,
            theme: theme,
            state: _state,
            pulse: _pulse,
            format: _format,
            onFormatChanged: _state == _PanelState.idle
                ? (f) => setState(() => _format = f)
                : null,
            onOpenSettings: () =>
                Navigator.of(context).pushNamed('/settings/api_keys'),
          ),
          Expanded(child: _buildBody(theme, cs)),
          _Footer(
            cs: cs,
            theme: theme,
            state: _state,
            onStart: _startListening,
            onStopGenerate: _stopAndGenerate,
            onCancel: _cancelListening,
            onNewSession: _resetForNewSession,
            onSaveEdit: () => setState(() => _editing = false),
            onEdit: () => setState(() => _editing = true),
            editing: _editing,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme cs) {
    switch (_state) {
      case _PanelState.idle:
        return _IdleView(theme: theme, cs: cs);
      case _PanelState.listening:
        return _ListeningView(
          theme: theme,
          cs: cs,
          transcript: _transcript,
          partial: _partial,
        );
      case _PanelState.generating:
        return _GeneratingView(theme: theme, cs: cs, transcript: _transcript);
      case _PanelState.noteReady:
        return _NoteReadyView(
          theme: theme,
          cs: cs,
          note: _note!,
          controller: _editCtl,
          editing: _editing,
        );
      case _PanelState.error:
        return _ErrorView(
          theme: theme,
          cs: cs,
          message: _errorMessage ?? 'Unknown error',
          onRetry: _resetForNewSession,
          onOpenSettings: () =>
              Navigator.of(context).pushNamed('/settings/api_keys'),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.cs,
    required this.theme,
    required this.state,
    required this.pulse,
    required this.format,
    required this.onFormatChanged,
    required this.onOpenSettings,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final _PanelState state;
  final AnimationController pulse;
  final SoapFormat format;
  final ValueChanged<SoapFormat>? onFormatChanged;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isLive = state == _PanelState.listening;
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
            AnimatedBuilder(
              animation: pulse,
              builder: (_, __) => Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color:
                      Colors.red.withValues(alpha: 0.5 + pulse.value * 0.5),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: pulse.value * 0.6),
                      blurRadius: 8 + pulse.value * 4,
                    ),
                  ],
                ),
              ),
            )
          else
            Icon(Icons.auto_awesome, color: cs.primary, size: 20),
          const SizedBox(width: 6),
          Text(
            'Live AI Co-Pilot',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.primary,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
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
                    .map((f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.label),
                        ))
                    .toList(),
                onChanged: (v) => v != null ? onFormatChanged!(v) : null,
              ),
            ),
          IconButton(
            tooltip: 'API Keys',
            icon: Icon(Icons.key,
                size: 18, color: cs.onSurface.withValues(alpha: 0.7)),
            onPressed: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  const _Footer({
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
  final _PanelState state;
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
        _PanelState.idle => FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.mic, size: 18),
            label: const Text('Start AI Recording'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        _PanelState.listening => Row(
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
        _PanelState.generating => OutlinedButton.icon(
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
        _PanelState.noteReady => Row(
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
        _PanelState.error => FilledButton.icon(
            onPressed: onNewSession,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
          ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// State views
// ---------------------------------------------------------------------------

class _IdleView extends StatelessWidget {
  const _IdleView({required this.theme, required this.cs});
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
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
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

class _ListeningView extends StatelessWidget {
  const _ListeningView({
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
                    if (transcript.isNotEmpty)
                      TextSpan(text: '$transcript '),
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

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({
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

class _NoteReadyView extends StatelessWidget {
  const _NoteReadyView({
    required this.theme,
    required this.cs,
    required this.note,
    required this.controller,
    required this.editing,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final SoapNote note;
  final TextEditingController controller;
  final bool editing;

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 12, color: Colors.red[700]),
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
                    style:
                        const TextStyle(fontFamily: 'monospace', height: 1.45),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      controller.text.isEmpty
                          ? note.rawMarkdown
                          : controller.text,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(height: 1.5, fontFamily: 'monospace'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
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
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
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
