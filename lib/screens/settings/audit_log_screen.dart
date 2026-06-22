import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import '../../models/audit_log_entry.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/audit_log_exporter.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/audit_log_detail_sheet.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
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
/// The data shape (`_AuditEntry`) mirrors the production `audit_logs`
/// Firestore collection so swapping in a real stream is one wire change.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  int? _expandedIndex;
  _AuditKind? _filterKind;

  /// Map the private demo row onto the public [AuditLogEntry] so the
  /// pure exporter pipeline can format it. Demo rows already use the
  /// production Firestore shape, so the adapter is mechanical.
  AuditLogEntry _toPublicEntry(_AuditEntry e) => AuditLogEntry(
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
    List<_AuditEntry> rows,
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

  void _showExportSheet(BuildContext context, List<_AuditEntry> rows) {
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
    final all = _demoEntries();
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
          _FilterBar(
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
              return _AuditRow(
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


class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.theme,
    required this.cs,
    required this.selected,
    required this.onSelected,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final _AuditKind? selected;
  final ValueChanged<_AuditKind?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <(_AuditKind?, String)>[
      (null, 'All events'),
      (_AuditKind.signin, 'Sign-in'),
      (_AuditKind.read, 'Read'),
      (_AuditKind.write, 'Write'),
      (_AuditKind.export, 'Export'),
      (_AuditKind.delete, 'Delete'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in chips) ...[
            _FilterChip(
              label: c.$2,
              active: selected == c.$1,
              onTap: () => onSelected(c.$1),
              theme: theme,
              cs: cs,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    required this.theme,
    required this.cs,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? cs.primary : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PsyRadius.full),
        side: BorderSide(color: active ? cs.primary : cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PsyRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.md,
            vertical: 7,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: active
                  ? cs.onPrimary
                  : cs.onSurface.withValues(alpha: 0.78),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({
    required this.entry,
    required this.theme,
    required this.cs,
    required this.expanded,
    required this.onTap,
    this.onOpenDetail,
  });
  final _AuditEntry entry;
  final ThemeData theme;
  final ColorScheme cs;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final tone = entry.kind.tone(cs);
    return PsyCard(
      onTap: onOpenDetail ?? onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.lg,
        vertical: PsySpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.md),
                ),
                child: Icon(entry.kind.icon, color: tone, size: 18),
              ),
              const SizedBox(width: PsySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.action,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${entry.actor} · ${entry.entity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.relativeTime,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  PsyBadge(
                    label: entry.result == 'success' ? 'OK' : entry.result,
                    tone: entry.result == 'success'
                        ? PsyBadgeTone.success
                        : PsyBadgeTone.danger,
                  ),
                ],
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: PsySpacing.md),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.6)),
            const SizedBox(height: PsySpacing.sm),
            _detailRow(theme, cs, 'Timestamp (UTC)', entry.timestampUtc),
            _detailRow(theme, cs, 'User ID', entry.userId),
            _detailRow(theme, cs, 'IP address', entry.ip),
            _detailRow(theme, cs, 'Device', entry.device),
            _detailRow(theme, cs, 'Affected record', entry.entity),
            _detailRow(theme, cs, 'Result', entry.result),
            _detailRow(theme, cs, 'Chain hash', entry.hash, monospace: true),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    ThemeData theme,
    ColorScheme cs,
    String k,
    String v, {
    bool monospace = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.88),
                height: 1.45,
                fontFamily: monospace ? 'JetBrainsMono' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _AuditKind { read, write, export, signin, delete }

extension on _AuditKind {
  IconData get icon => switch (this) {
    _AuditKind.read => Icons.visibility_outlined,
    _AuditKind.write => Icons.edit_outlined,
    _AuditKind.export => Icons.download_outlined,
    _AuditKind.signin => Icons.login_outlined,
    _AuditKind.delete => Icons.delete_outlined,
  };
  // Arch M3 fix (audit 2026-06-21): the previous palette hard-coded
  // light-mode hex values that washed out / clashed on Material 3
  // dark surfaces. We now branch on the ColorScheme brightness so
  // each kind keeps a stable semantic hue while staying readable in
  // both themes.
  Color tone(ColorScheme cs) {
    final dark = cs.brightness == Brightness.dark;
    return switch (this) {
      _AuditKind.signin => cs.primary,
      _AuditKind.read =>
        dark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
      _AuditKind.write =>
        dark ? const Color(0xFFF9A8D4) : const Color(0xFFDB2777),
      _AuditKind.export =>
        dark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
      _AuditKind.delete => cs.error,
    };
  }
}

class _AuditEntry {
  const _AuditEntry({
    required this.id,
    required this.kind,
    required this.action,
    required this.actor,
    required this.entity,
    required this.relativeTime,
    required this.timestampUtc,
    required this.userId,
    required this.ip,
    required this.device,
    required this.result,
    required this.hash,
  });
  final int id;
  final _AuditKind kind;
  final String action;
  final String actor;
  final String entity;
  final String relativeTime;
  final String timestampUtc;
  final String userId;
  final String ip;
  final String device;
  final String result;
  final String hash;
}

// Demo data — mirrors the production Firestore audit_logs schema.
// IP redacted with U+00B7 dots so the demo doesn't leak a public IP.
List<_AuditEntry> _demoEntries() => const [
  _AuditEntry(
    id: 1,
    kind: _AuditKind.signin,
    action: 'Signed in',
    actor: 'demo@psyclinicai.com',
    entity: 'IP 92.184.··.··· · macOS · Safari',
    relativeTime: 'just now',
    timestampUtc: '2026-06-01T12:00:42Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: 'a1f2…7c4d',
  ),
  _AuditEntry(
    id: 2,
    kind: _AuditKind.read,
    action: 'Opened patient chart',
    actor: 'demo@psyclinicai.com',
    entity: 'Patient #demo-001',
    relativeTime: '2 min ago',
    timestampUtc: '2026-06-01T11:58:09Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: 'b2e7…9c1a',
  ),
  _AuditEntry(
    id: 3,
    kind: _AuditKind.write,
    action: 'Saved SOAP note',
    actor: 'demo@psyclinicai.com',
    entity: 'Session session-1780310462846',
    relativeTime: '7 min ago',
    timestampUtc: '2026-06-01T11:53:31Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: 'c4d1…0e8b',
  ),
  _AuditEntry(
    id: 4,
    kind: _AuditKind.export,
    action: 'Generated superbill PDF',
    actor: 'demo@psyclinicai.com',
    entity: 'Invoice INV-2026-0014',
    relativeTime: '24 min ago',
    timestampUtc: '2026-06-01T11:36:55Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: 'd9a3…6f02',
  ),
  _AuditEntry(
    id: 5,
    kind: _AuditKind.export,
    action: 'Audit log exported (CSV)',
    actor: 'demo@psyclinicai.com',
    entity: 'Range 2026-05-25 → 2026-06-01',
    relativeTime: '35 min ago',
    timestampUtc: '2026-06-01T11:25:01Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: 'e5b4…2a17',
  ),
  _AuditEntry(
    id: 6,
    kind: _AuditKind.write,
    action: 'Updated safety plan',
    actor: 'demo@psyclinicai.com',
    entity: 'Patient #demo-001',
    relativeTime: '1 h ago',
    timestampUtc: '2026-06-01T11:00:18Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: 'f7c8…b32d',
  ),
  _AuditEntry(
    id: 7,
    kind: _AuditKind.read,
    action: 'Opened outcomes dashboard',
    actor: 'demo@psyclinicai.com',
    entity: 'Cohort all',
    relativeTime: '2 h ago',
    timestampUtc: '2026-06-01T10:02:47Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: '08e1…4c69',
  ),
  _AuditEntry(
    id: 8,
    kind: _AuditKind.signin,
    action: 'Signed out',
    actor: 'demo@psyclinicai.com',
    entity: 'Manual',
    relativeTime: '14 h ago',
    timestampUtc: '2026-05-31T22:01:09Z',
    userId: 'usr_3F8h2K9aQ7vMnLp4',
    ip: '92.184.··.···',
    device: 'macOS 14 · Safari 17',
    result: 'success',
    hash: '193a…7fe2',
  ),
];
