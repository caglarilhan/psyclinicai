import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../models/audit_log_entry.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/audit_log_exporter.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/audit_log_detail_sheet.dart';
import 'audit_log_entry.dart';
import 'audit_log_status.dart';

/// `/settings/audit_log` — clinician-facing audit log timeline.
///
/// Surfaces the GDPR/HIPAA-required record of who accessed which
/// patient and when, so a clinic admin can self-serve audit reviews
/// instead of asking us for a database dump. Auditor-grade additions
/// (2026-06-01):
///   - Integrity attestation card (append-only · hash-chained · tamper-evident).
///   - Filter bar (date range · event type · user · patient · IP).
///   - Tap a row to expand: UTC timestamp, full user id, IP, device,
///     SHA-256 chain hash, and result. Demo includes the
///     'audit log exported' self-event so reviewers can verify the
///     export itself is logged (a HIPAA audit checkpoint).
///
/// The data shape (`AuditEntry`) mirrors the production `audit_logs`
/// Firestore collection so swapping in a real stream is one wire change.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  int? _expandedIndex;
  AuditKind? _filterKind;

  /// Map the private demo row onto the public [AuditLogEntry] so the
  /// pure exporter pipeline can format it. Demo rows already use the
  /// production Firestore shape, so the adapter is mechanical.
  AuditLogEntry _toPublicEntry(AuditEntry e) => AuditLogEntry(
    id: e.id.toString(),
    kind: e.kind.name,
    action: e.action,
    actor: e.actor,
    entity: e.entity,
    timestampUtc: DateTime.tryParse(e.timestampUtc) ?? DateTime.now().toUtc(),
    result: AuditResult.fromId(e.result),
    userId: e.userId,
    ip: e.ip,
    device: e.device,
    hash: e.hash,
  );

  Future<void> _exportInFormat(
    List<AuditEntry> rows,
    String format, {
    required bool redact,
  }) async {
    final public = rows.map(_toPublicEntry);
    final shaped = redact ? public.map(redactForSiem) : public;
    final String body;
    switch (format) {
      case 'jsonl':
        body = toJsonLines(shaped);
        break;
      case 'syslog':
        body = toSyslogRfc5424(shaped);
        break;
      case 'csv':
      default:
        body = toCsv(shaped);
        break;
    }
    await Clipboard.setData(ClipboardData(text: body));
    // Unredacted exports are still allowed — auditors sometimes need
    // the raw row — but the event is split so dashboards can flag the
    // unredacted leg for review.
    unawaited(
      TelemetryService.instance.capture(
        redact
            ? 'compliance.audit_log_export'
            : 'compliance.audit_log_export_unredacted',
        properties: {'format': format, 'rows': rows.length, 'redacted': redact},
      ),
    );
    if (!mounted) return;
    unawaited(Navigator.of(context).maybePop());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${rows.length} rows copied as ${format.toUpperCase()} '
          '${redact ? '(PHI redacted)' : '(RAW — PHI included)'}.',
        ),
      ),
    );
  }

  void _showExportSheet(BuildContext context, List<AuditEntry> rows) {
    var redact = true; // default ON — fail-closed for PHI
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setSheetState) {
              final theme = Theme.of(ctx);
              final cs = theme.colorScheme;
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PsySpacing.xl,
                    0,
                    PsySpacing.xl,
                    PsySpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Export audit log',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: PsySpacing.xs),
                      Text(
                        'With redaction on, email-shaped actors and the last '
                        'two IP octets are masked before the bundle leaves '
                        'your device. The export itself is logged on this '
                        'trail either way.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: PsySpacing.md),
                      SwitchListTile.adaptive(
                        value: redact,
                        onChanged: (v) => setSheetState(() => redact = v),
                        title: const Text('Redact PHI (recommended)'),
                        subtitle: Text(
                          redact
                              ? 'Emails and last two IP octets are masked.'
                              : 'RAW export — file contains PHI. Audit log '
                                    'flags this leg for compliance review.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: redact
                                ? cs.onSurface.withValues(alpha: 0.6)
                                : cs.error,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: PsySpacing.sm),
                      ExportTile(
                        label: 'JSONL · for Splunk / Datadog',
                        icon: Icons.data_object,
                        onTap: () =>
                            _exportInFormat(rows, 'jsonl', redact: redact),
                      ),
                      ExportTile(
                        label: 'CSV · for compliance review',
                        icon: Icons.table_chart_outlined,
                        onTap: () =>
                            _exportInFormat(rows, 'csv', redact: redact),
                      ),
                      ExportTile(
                        label: 'Syslog RFC 5424 · for ELK',
                        icon: Icons.dns_outlined,
                        onTap: () =>
                            _exportInFormat(rows, 'syslog', redact: redact),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final all = demoAuditEntries();
    final entries = _filterKind == null
        ? all
        : all.where((e) => e.kind == _filterKind).toList();

    return AppShell(
      routeName: '/settings/audit_log',
      title: 'Audit log',
      subtitle:
          'Every read, write, and export — GDPR Art. 30 + HIPAA §164.312(b).',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('Trust Center', '/trust'),
        Crumb('Audit log', null),
      ],
      primaryAction: OutlinedButton.icon(
        onPressed: () => _showExportSheet(context, all),
        icon: const Icon(Icons.download_outlined, size: 18),
        label: const Text('Export'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntegrityCard(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          FilterBar(
            theme: theme,
            cs: cs,
            selected: _filterKind,
            onSelected: (k) => setState(() => _filterKind = k),
          ),
          const SizedBox(height: PsySpacing.xl),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: PsySpacing.sm),
            itemBuilder: (_, i) {
              // Use the entry id (not list index) so filtering doesn't
              // confuse which row is expanded.
              final isOpen = _expandedIndex == entries[i].id;
              final publicEntry = _toPublicEntry(entries[i]);
              final previousHash = i == 0
                  ? null
                  : _toPublicEntry(entries[i - 1]).hash;
              return AuditRow(
                entry: entries[i],
                theme: theme,
                cs: cs,
                expanded: isOpen,
                onTap: () => setState(
                  () => _expandedIndex = isOpen ? null : entries[i].id,
                ),
                onOpenDetail: () => AuditLogDetailSheet.show(
                  context,
                  entry: publicEntry,
                  previousHash: previousHash,
                ),
              );
            },
          ),
          if (entries.isEmpty) ...[
            const SizedBox(height: PsySpacing.xl),
            Center(
              child: Text(
                'No entries match the current filter.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
