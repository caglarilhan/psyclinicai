import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/audit_log` — clinician-facing audit log timeline.
///
/// Surfaces the GDPR/HIPAA-required record of who accessed which
/// patient and when, so a clinic admin can self-serve audit reviews
/// instead of asking us for a database dump.
///
/// Until the real backend lands, this view renders a synthetic
/// timeline so the UX is fully testable in demo mode. The shape
/// (`_AuditEntry`) mirrors the shipped `audit_logs` Firestore
/// collection schema so swapping in real data is one stream change.
class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final entries = _demoEntries();

    return AppShell(
      routeName: '/settings/audit_log',
      title: 'Audit log',
      subtitle:
          'Every read, write, and export — GDPR Art. 30 + HIPAA §164.312(b).',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('Audit log', null),
      ],
      primaryAction: OutlinedButton.icon(
        // Export-as-CSV intentionally falls through to a snackbar in demo;
        // a real backend would stream a date-ranged export.
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'CSV export requires a paid plan — emailed to your admin within 24 h.'),
          ),
        ),
        icon: const Icon(Icons.download_outlined, size: 18),
        label: const Text('Export CSV'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NoticeCard(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: PsySpacing.sm),
            itemBuilder: (_, i) =>
                _AuditRow(entry: entries[i], theme: theme, cs: cs),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: cs.primary, size: 22),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Text(
              'Immutable: entries are append-only and retained 6 y. '
              'Demo data shown — production logs are tenant-scoped.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow(
      {required this.entry, required this.theme, required this.cs});
  final _AuditEntry entry;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final tone = entry.kind.tone(cs);
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.md),
      child: Row(
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
                Text(entry.action,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
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
          Text(
            entry.relativeTime,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

enum _AuditKind {
  read,
  write,
  export,
  signin,
  delete,
}

extension on _AuditKind {
  IconData get icon => switch (this) {
        _AuditKind.read => Icons.visibility_outlined,
        _AuditKind.write => Icons.edit_outlined,
        _AuditKind.export => Icons.download_outlined,
        _AuditKind.signin => Icons.login_outlined,
        _AuditKind.delete => Icons.delete_outlined,
      };

  Color tone(ColorScheme cs) => switch (this) {
        _AuditKind.read => cs.primary,
        _AuditKind.write => cs.tertiary,
        _AuditKind.export => cs.secondary,
        _AuditKind.signin => cs.primary,
        _AuditKind.delete => cs.error,
      };
}

class _AuditEntry {
  const _AuditEntry({
    required this.kind,
    required this.action,
    required this.actor,
    required this.entity,
    required this.relativeTime,
  });
  final _AuditKind kind;
  final String action;
  final String actor;
  final String entity;
  final String relativeTime;
}

// Demo data — shape mirrors the production `audit_logs` Firestore docs.
List<_AuditEntry> _demoEntries() => const [
      _AuditEntry(
        kind: _AuditKind.signin,
        action: 'Signed in',
        actor: 'demo@psyclinicai.com',
        entity: 'IP 92.184.··.··· · macOS · Safari',
        relativeTime: 'just now',
      ),
      _AuditEntry(
        kind: _AuditKind.read,
        action: 'Opened patient chart',
        actor: 'demo@psyclinicai.com',
        entity: 'Patient #demo-001',
        relativeTime: '2 min ago',
      ),
      _AuditEntry(
        kind: _AuditKind.write,
        action: 'Saved SOAP note',
        actor: 'demo@psyclinicai.com',
        entity: 'Session session-1780310462846',
        relativeTime: '7 min ago',
      ),
      _AuditEntry(
        kind: _AuditKind.export,
        action: 'Generated superbill PDF',
        actor: 'demo@psyclinicai.com',
        entity: 'Invoice INV-2026-0014',
        relativeTime: '24 min ago',
      ),
      _AuditEntry(
        kind: _AuditKind.write,
        action: 'Updated safety plan',
        actor: 'demo@psyclinicai.com',
        entity: 'Patient #demo-001',
        relativeTime: '1 h ago',
      ),
      _AuditEntry(
        kind: _AuditKind.read,
        action: 'Opened outcomes dashboard',
        actor: 'demo@psyclinicai.com',
        entity: 'Cohort all',
        relativeTime: '2 h ago',
      ),
      _AuditEntry(
        kind: _AuditKind.signin,
        action: 'Signed out',
        actor: 'demo@psyclinicai.com',
        entity: 'Manual',
        relativeTime: '14 h ago',
      ),
    ];
