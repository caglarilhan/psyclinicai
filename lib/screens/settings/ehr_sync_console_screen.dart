import 'package:flutter/material.dart';

import '../../models/ehr_sync_session.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/ehr` — FHIR R4 sync console.
class EhrSyncConsoleScreen extends StatelessWidget {
  const EhrSyncConsoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sessions = _demoSessions();
    return AppShell(
      routeName: '/settings',
      title: 'EHR sync',
      subtitle:
          'HL7 FHIR R4 connections to your hospital EHR — '
          'pull only the resources you choose, surface conflicts.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('EHR sync', null),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _StatusCard(sessions: sessions, theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          Text(
            'Recent sessions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          for (final s in sessions) ...[
            _SessionRow(session: s, theme: theme, cs: cs),
            const SizedBox(height: PsySpacing.sm),
          ],
          const SizedBox(height: PsySpacing.xl),
          PsyCard(
            tinted: true,
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: cs.onSurface.withValues(alpha: 0.6),
                  size: 18,
                ),
                const SizedBox(width: PsySpacing.sm),
                Expanded(
                  child: Text(
                    'We never write back to a remote EHR unless you '
                    'resolve a conflict explicitly. PHI flow is one-way '
                    'until the clinician approves outbound writes.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<EhrSyncSession> _demoSessions() {
    final started = DateTime.utc(2026, 6, 2, 8);
    return [
      EhrSyncSession(
        sessionId: 'sync-9001',
        vendor: FhirVendor.epic,
        resourceTypes: const ['Patient', 'Encounter', 'Observation'],
        status: FhirSyncStatus.complete,
        startedAt: started,
        completedAt: started.add(const Duration(minutes: 4)),
        recordsRead: 312,
        recordsWritten: 18,
      ),
      EhrSyncSession(
        sessionId: 'sync-9002',
        vendor: FhirVendor.cerner,
        resourceTypes: const ['Patient', 'MedicationRequest'],
        status: FhirSyncStatus.conflict,
        startedAt: started.add(const Duration(hours: 5)),
        recordsRead: 84,
        conflicts: [
          FhirConflict(
            resourceType: 'MedicationRequest',
            resourceId: 'med-A-12',
            kind: FhirConflictKind.divergent,
            localUpdatedAt: started.add(const Duration(hours: 4)),
            remoteUpdatedAt: started.add(const Duration(hours: 6)),
            fieldPath: 'dosageInstruction[0].text',
          ),
          FhirConflict(
            resourceType: 'Patient',
            resourceId: 'p-44',
            kind: FhirConflictKind.remoteMissing,
            localUpdatedAt: started.add(const Duration(hours: 3)),
            remoteUpdatedAt: started.subtract(const Duration(days: 30)),
          ),
        ],
      ),
      EhrSyncSession(
        sessionId: 'sync-9003',
        vendor: FhirVendor.medistar,
        resourceTypes: const ['Patient'],
        status: FhirSyncStatus.error,
        startedAt: started.add(const Duration(hours: 12)),
        completedAt: started.add(const Duration(hours: 12, minutes: 1)),
        errorMessage: 'OAuth token rejected — refresh via Medistar admin.',
      ),
    ];
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.sessions,
    required this.theme,
    required this.cs,
  });
  final List<EhrSyncSession> sessions;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final attention = sessions.where((s) => s.needsAttention).length;
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PsySpacing.md),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            child: Icon(Icons.sync, color: cs.primary, size: 24),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connections',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sessions.length} sessions today',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attention == 0
                      ? 'No issues — all sessions completed cleanly.'
                      : '$attention session${attention == 1 ? "" : "s"} '
                            'need your attention.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: attention == 0
                        ? cs.onSurface.withValues(alpha: 0.7)
                        : PsyColors.warning,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.session,
    required this.theme,
    required this.cs,
  });
  final EhrSyncSession session;
  final ThemeData theme;
  final ColorScheme cs;

  PsyBadgeTone _tone() {
    switch (session.status) {
      case FhirSyncStatus.complete:
        return PsyBadgeTone.success;
      case FhirSyncStatus.conflict:
        return PsyBadgeTone.warning;
      case FhirSyncStatus.error:
        return PsyBadgeTone.danger;
      case FhirSyncStatus.running:
      case FhirSyncStatus.idle:
        return PsyBadgeTone.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${session.vendor.label} · ${session.sessionId}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PsyBadge(label: session.status.name, tone: _tone()),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Resources: ${session.resourceTypes.join(", ")} · '
            '${session.recordsRead} read · '
            '${session.recordsWritten} written',
            style: theme.textTheme.bodySmall,
          ),
          if (session.errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              session.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
          if (session.conflicts.isNotEmpty) ...[
            const SizedBox(height: PsySpacing.sm),
            for (final c in session.conflicts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${c.resourceType}/${c.resourceId} · ${c.kind.name}'
                  '${c.fieldPath != null ? " · ${c.fieldPath}" : ""}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PsyColors.warning,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            const SizedBox(height: PsySpacing.sm),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.compare_arrows, size: 16),
                  label: const Text('Resolve conflicts'),
                ),
                const SizedBox(width: PsySpacing.sm),
                TextButton(onPressed: () {}, child: const Text('Re-run sync')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
