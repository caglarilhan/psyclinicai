/// Models + widgets that drive the audit-log timeline body:
/// - [AuditKind] enum + its `icon` / `tone(cs)` extension — the
///   per-kind palette branches on `ColorScheme.brightness` so a
///   row reads on both light and dark surfaces.
/// - [AuditEntry] data class mirroring the production
///   `audit_logs` Firestore schema (id, kind, action, actor,
///   entity, relativeTime, timestampUtc ISO-8601, userId, ip,
///   device, result, hash).
/// - [demoAuditEntries] — 8-row demo list with redacted IPs so
///   the timeline reads "live" without leaking a real address.
/// - [FilterBar] / [FilterChip]: horizontal scroll of "All / Sign-in
///   / Read / Write / Export / Delete" chips driving the state's
///   `_filterKind`.
/// - [AuditRow]: PsyCard row with kind icon, tone-tinted square,
///   tabular time + result badge, and an expanded detail block.
///
/// HIGH-class refactor slice (audit 2026-06-21): extracted from
/// the 818-line audit_log_screen.dart so the screen file owns its
/// state machine + export sheet only.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

enum AuditKind { read, write, export, signin, delete }

extension AuditKindX on AuditKind {
  IconData get icon => switch (this) {
    AuditKind.read => Icons.visibility_outlined,
    AuditKind.write => Icons.edit_outlined,
    AuditKind.export => Icons.download_outlined,
    AuditKind.signin => Icons.login_outlined,
    AuditKind.delete => Icons.delete_outlined,
  };

  /// Arch M3 fix (audit 2026-06-21): the previous palette hard-coded
  /// light-mode hex values that washed out / clashed on Material 3
  /// dark surfaces. We now branch on the ColorScheme brightness so
  /// each kind keeps a stable semantic hue while staying readable in
  /// both themes.
  Color tone(ColorScheme cs) {
    final dark = cs.brightness == Brightness.dark;
    return switch (this) {
      AuditKind.signin => cs.primary,
      AuditKind.read =>
        dark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
      AuditKind.write =>
        dark ? const Color(0xFFF9A8D4) : const Color(0xFFDB2777),
      AuditKind.export =>
        dark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
      AuditKind.delete => cs.error,
    };
  }
}

class AuditEntry {
  const AuditEntry({
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
  final AuditKind kind;
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
List<AuditEntry> demoAuditEntries() => const [
  AuditEntry(
    id: 1,
    kind: AuditKind.signin,
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
  AuditEntry(
    id: 2,
    kind: AuditKind.read,
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
  AuditEntry(
    id: 3,
    kind: AuditKind.write,
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
  AuditEntry(
    id: 4,
    kind: AuditKind.export,
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
  AuditEntry(
    id: 5,
    kind: AuditKind.export,
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
  AuditEntry(
    id: 6,
    kind: AuditKind.write,
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
  AuditEntry(
    id: 7,
    kind: AuditKind.read,
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
  AuditEntry(
    id: 8,
    kind: AuditKind.signin,
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

class FilterBar extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.theme,
    required this.cs,
    required this.selected,
    required this.onSelected,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final AuditKind? selected;
  final ValueChanged<AuditKind?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <(AuditKind?, String)>[
      (null, 'All events'),
      (AuditKind.signin, 'Sign-in'),
      (AuditKind.read, 'Read'),
      (AuditKind.write, 'Write'),
      (AuditKind.export, 'Export'),
      (AuditKind.delete, 'Delete'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final c in chips) ...[
            AuditFilterChip(
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

/// Named `AuditFilterChip` (not `FilterChip`) to avoid colliding with
/// Material's own `FilterChip` widget when both are imported.
class AuditFilterChip extends StatelessWidget {
  const AuditFilterChip({
    super.key,
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

class AuditRow extends StatelessWidget {
  const AuditRow({
    super.key,
    required this.entry,
    required this.theme,
    required this.cs,
    required this.expanded,
    required this.onTap,
    this.onOpenDetail,
  });
  final AuditEntry entry;
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
