import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../services/data/auth_service.dart';
import '../../services/data/intake_repository.dart';
import '../../services/data/safety_plan_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/dsar_export.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/data_export` — Patient Subject Access Request (DSAR)
/// portal under GDPR Articles 15 + 20.
///
/// Generates a portable JSON bundle of every record the platform holds
/// for the supplied patient id (defaults to the demo patient when
/// nothing is selected). The clinician can copy the bundle to the
/// clipboard for hand-off; a true streaming download is a follow-up
/// once the file-system permissions story lands across all platforms.
class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key, this.patientId = 'demo-1'});

  final String patientId;

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  final _intakes = IntakeRepository();
  final _safetyPlans = SafetyPlanRepository();
  bool _loading = true;
  String _prettyJson = '';
  bool _empty = true;
  int _byteSize = 0;

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    await Future.wait([
      _intakes.initialize(),
      _safetyPlans.initialize(),
    ]);
    final intake = _intakes.forPatient(widget.patientId);
    final plan = _safetyPlans.forPatient(widget.patientId);
    final profile = FirebaseAuthService.instance.profile;
    final bundle = buildPatientExport(
      patientId: widget.patientId,
      generatedAt: DateTime.now(),
      intake: intake,
      safetyPlan: plan,
      clinicianProfile: profile == null
          ? null
          : {
              'full_name': profile.fullName,
              'credentials': profile.credentials,
              'specialty': profile.specialty,
              'license_number': profile.licenseNumber,
              if (profile.licenseExpiry != null)
                'license_expiry':
                    profile.licenseExpiry!.toUtc().toIso8601String(),
            },
    );
    final json = const JsonEncoder.withIndent('  ').convert(bundle);
    if (!mounted) return;
    setState(() {
      _prettyJson = json;
      _empty = isExportEmpty(bundle);
      _byteSize = utf8.encode(json).length;
      _loading = false;
    });
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _prettyJson));
    if (!mounted) return;
    TelemetryService.instance.capture(
      'compliance.dsar_export_copied',
      properties: {
        'bytes': _byteSize,
        'schema_version': dsarSchemaVersion,
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Export bundle copied to clipboard.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings',
      title: 'Data export (DSAR)',
      subtitle: 'GDPR Article 15 (access) + Article 20 (portability) — '
          'one bundle, every record we hold.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Data export', null),
      ],
      primaryAction: FilledButton.icon(
        onPressed: _loading || _empty ? null : _copy,
        icon: const Icon(Icons.copy_outlined),
        label: const Text('Copy JSON'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
        ),
      ),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()))
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                PsyCard(
                  tinted: true,
                  child: Row(children: [
                    Icon(Icons.policy_outlined, color: cs.primary),
                    const SizedBox(width: PsySpacing.md),
                    Expanded(
                      child: Text(
                        'Sharing this file outside the chart is patient '
                        'authorised under GDPR Art. 15/20. Treat the JSON '
                        'as PHI — encrypted transport, deletion when no '
                        'longer needed.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.45,
                            color: cs.onSurface.withValues(alpha: 0.78)),
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    const PsyBadge(label: 'PHI', tone: PsyBadgeTone.info),
                  ]),
                ),
                const SizedBox(height: PsySpacing.xl),
                Row(children: [
                  Text('Bundle',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: PsySpacing.sm),
                  PsyBadge(
                    label: 'v$dsarSchemaVersion',
                    tone: PsyBadgeTone.neutral,
                  ),
                  const Spacer(),
                  Text('${(_byteSize / 1024).toStringAsFixed(1)} KB',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6))),
                ]),
                const SizedBox(height: PsySpacing.sm),
                if (_empty)
                  PsyCard(
                    child: Row(children: [
                      Icon(Icons.info_outline,
                          color: cs.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: PsySpacing.md),
                      Expanded(
                        child: Text(
                          'No patient records on file yet for '
                          '${widget.patientId}. Complete an intake or open '
                          'a safety plan and the bundle will populate.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
                    ]),
                  )
                else
                  PsyCard(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PsySpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(PsyRadius.md),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: SelectableText(
                        _prettyJson,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.45),
                      ),
                    ),
                  ),
                const SizedBox(height: PsySpacing.huge),
              ],
            ),
    );
  }
}
