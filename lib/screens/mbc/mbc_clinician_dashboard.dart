import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/mbc/mbc_dispatch_catalog.dart';
import '../../services/mbc/mbc_dispatch_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/clinician/mbc` — entry point for the Measurement-Based Care
/// dispatcher. MVP slice (PILAR 2 / PR-4): the clinician picks a
/// patient + scale, mints a token-signed form link, copies it for the
/// patient. Recent-submissions stream + outcome-trend chart land in
/// Sprint 32 once the Firestore index is provisioned.
class MbcClinicianDashboardScreen extends StatefulWidget {
  const MbcClinicianDashboardScreen({
    super.key,
    required this.service,
    required this.tenantId,
  });

  final MbcDispatchService service;
  final String tenantId;

  @override
  State<MbcClinicianDashboardScreen> createState() =>
      _MbcClinicianDashboardScreenState();
}

class _MbcClinicianDashboardScreenState
    extends State<MbcClinicianDashboardScreen> {
  final TextEditingController _patientId = TextEditingController();
  String _scaleId = 'phq9';
  bool _dispatching = false;
  String? _error;
  MbcDispatch? _lastDispatch;

  @override
  void dispose() {
    _patientId.dispose();
    super.dispose();
  }

  Future<void> _onDispatch() async {
    if (_dispatching) return;
    final pid = _patientId.text.trim();
    if (pid.isEmpty) {
      setState(() => _error = 'Patient id is required.');
      return;
    }
    setState(() {
      _dispatching = true;
      _error = null;
    });
    try {
      final res = await widget.service.dispatch(
        tenantId: widget.tenantId,
        patientId: pid,
        scaleId: _scaleId,
      );
      if (!mounted) return;
      setState(() {
        _lastDispatch = res;
        _dispatching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _dispatching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/clinician/mbc',
      title: 'Measurement-Based Care',
      subtitle:
          'Send a between-session assessment in two taps. The patient '
          'gets a private link that works without an account.',
      breadcrumbs: const [
        Crumb('Clinician', '/dashboard'),
        Crumb('MBC', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DispatchCard(
            theme: theme,
            cs: cs,
            patientId: _patientId,
            scaleId: _scaleId,
            onScaleChanged: (v) => setState(() => _scaleId = v),
            dispatching: _dispatching,
            onDispatch: _onDispatch,
            error: _error,
          ),
          const SizedBox(height: PsySpacing.xl),
          if (_lastDispatch != null)
            _LinkPanel(theme: theme, cs: cs, dispatch: _lastDispatch!),
        ],
      ),
    );
  }
}

class _DispatchCard extends StatelessWidget {
  const _DispatchCard({
    required this.theme,
    required this.cs,
    required this.patientId,
    required this.scaleId,
    required this.onScaleChanged,
    required this.dispatching,
    required this.onDispatch,
    required this.error,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final TextEditingController patientId;
  final String scaleId;
  final ValueChanged<String> onScaleChanged;
  final bool dispatching;
  final VoidCallback onDispatch;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Send a new assessment',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: patientId,
                  decoration: const InputDecoration(
                    labelText: 'Patient id',
                  ),
                ),
              ),
              const SizedBox(width: PsySpacing.md),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: scaleId,
                  decoration: const InputDecoration(labelText: 'Scale'),
                  items: [
                    for (final r in MbcDispatchCatalog.rules)
                      DropdownMenuItem(
                        value: r.scaleId,
                        child: Text('${r.scaleId.toUpperCase()} — '
                            '${r.payerCadenceLabel}'),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) onScaleChanged(v);
                  },
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(error!,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error)),
          ],
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: dispatching ? null : onDispatch,
              icon: dispatching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(dispatching ? 'Sending…' : 'Generate link'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkPanel extends StatelessWidget {
  const _LinkPanel({
    required this.theme,
    required this.cs,
    required this.dispatch,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final MbcDispatch dispatch;

  @override
  Widget build(BuildContext context) {
    final expiresAt =
        DateTime.fromMillisecondsSinceEpoch(dispatch.expiresAtMillis).toLocal();
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('Patient link ready',
                  style: theme.textTheme.titleMedium),
              const SizedBox(width: PsySpacing.md),
              PsyBadge(
                label:
                    '${dispatch.scaleId.toUpperCase()} · ${dispatch.channel}',
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Expires ${expiresAt.toIso8601String()}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: PsySpacing.md),
          SelectableText(
            dispatch.formUrl,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontFamily: 'monospace'),
          ),
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: dispatch.formUrl),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy link'),
            ),
          ),
        ],
      ),
    );
  }
}
