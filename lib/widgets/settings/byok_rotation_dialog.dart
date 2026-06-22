/// Sprint 32 P2 — settings UI hook for BYOK key rotation.
///
/// Renders an alert dialog with one text field, a Rotate button, and a
/// Cancel button. Delegates the heavy lifting to [ByokRotationService]
/// and fires telemetry through [TelemetryService]. The widget owns no
/// secrets; the new key never leaves the controller.
///
/// Usage from a settings tile:
///   onTap: () => showByokRotateDialog(context, ByokProvider.anthropic),
///
/// Skill-panel coverage: senior-frontend (composition), env-secrets-
/// manager (rotation lifecycle), apple-hig-expert (one-tap dismiss,
/// SafeArea, focus management).
library;

import 'package:flutter/material.dart';

import '../../services/data/telemetry_service.dart';
import '../../services/security/byok_rotation_service.dart';

/// Friendly display name for a provider — kept here so consumers don't
/// rebuild the same switch statement in three places.
String byokProviderLabel(ByokProvider p) {
  switch (p) {
    case ByokProvider.anthropic:
      return 'Anthropic Claude';
    case ByokProvider.openai:
      return 'OpenAI';
    case ByokProvider.cohere:
      return 'Cohere';
  }
}

/// Convenience entry point. Returns the [ByokRotationResult] from the
/// service, or `null` if the operator dismissed without rotating.
Future<ByokRotationResult?> showByokRotateDialog(
  BuildContext context,
  ByokProvider provider, {
  ByokRotationService? service,
  TelemetryService? telemetry,
}) {
  return showDialog<ByokRotationResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ByokRotationDialog(
      provider: provider,
      service: service,
      telemetry: telemetry,
    ),
  );
}

class ByokRotationDialog extends StatefulWidget {
  const ByokRotationDialog({
    super.key,
    required this.provider,
    this.service,
    this.telemetry,
  });

  final ByokProvider provider;
  final ByokRotationService? service;
  final TelemetryService? telemetry;

  @override
  State<ByokRotationDialog> createState() => _ByokRotationDialogState();
}

class _ByokRotationDialogState extends State<ByokRotationDialog> {
  late final ByokRotationService _service =
      widget.service ?? ByokRotationService();
  late final TelemetryService _telemetry =
      widget.telemetry ?? TelemetryService.instance;
  final TextEditingController _ctl = TextEditingController();
  bool _busy = false;
  String? _inlineError;

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _rotate() async {
    if (_busy) return;
    final providerName = widget.provider.name;
    setState(() {
      _busy = true;
      _inlineError = null;
    });
    await _telemetry.capture(
      TelemetryEvents.byokRotationRequested,
      properties: {'provider': providerName},
    );
    final result = await _service.rotate(widget.provider, _ctl.text.trim());
    if (!mounted) return;
    switch (result.status) {
      case ByokRotationStatus.completed:
        // Capture the dialog's Navigator reference before the next
        // await so the use_build_context_synchronously lint can prove
        // we are not crossing a fresh async gap with the context.
        final navigator = Navigator.of(context);
        await _telemetry.capture(
          TelemetryEvents.byokRotationCompleted,
          properties: {
            'provider': providerName,
            'grace_period_h': ByokRotationService.defaultGraceWindow.inHours,
          },
        );
        navigator.pop(result);
        return;
      case ByokRotationStatus.rejected:
        setState(() {
          _busy = false;
          _inlineError = result.reason == 'empty_key'
              ? 'Enter the new key.'
              : 'Key is too short. Paste the full token.';
        });
        return;
      case ByokRotationStatus.failed:
        await _telemetry.capture(
          TelemetryEvents.byokRotationFailed,
          properties: {
            'provider': providerName,
            'reason': result.reason ?? 'unknown',
          },
        );
        setState(() {
          _busy = false;
          _inlineError =
              'Could not save the key. Check device storage and try again.';
        });
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerLabel = byokProviderLabel(widget.provider);
    return AlertDialog(
      title: Text('Rotate $providerLabel key'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The old key remains valid for '
              '${ByokRotationService.defaultGraceWindow.inHours} hours '
              'so any request already in flight finishes cleanly.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctl,
              autofocus: true,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'New $providerLabel key',
                border: const OutlineInputBorder(),
                errorText: _inlineError,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _rotate,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Rotate'),
        ),
      ],
    );
  }
}
