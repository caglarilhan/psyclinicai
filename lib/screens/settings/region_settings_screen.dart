import 'package:flutter/material.dart';

import '../../models/tenant_region.dart';
import '../../theme/brand_colors.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings/region` — Per-tenant Firestore region surface (closes
/// the N-11 finding from the Sprint-17 audit).
class RegionSettingsScreen extends StatefulWidget {
  const RegionSettingsScreen({super.key, this.initialPin});

  /// Test seam.
  final TenantRegionPin? initialPin;

  @override
  State<RegionSettingsScreen> createState() => _RegionSettingsScreenState();
}

class _RegionSettingsScreenState extends State<RegionSettingsScreen> {
  late TenantRegionPin _pin;

  @override
  void initState() {
    super.initState();
    _pin =
        widget.initialPin ??
        TenantRegionPin(
          tenantId: 'demo-tenant',
          region: TenantRegion.euCentral,
          pinnedAt: DateTime.utc(2026, 1, 14),
        );
  }

  TenantRegion get _other => _pin.region == TenantRegion.euCentral
      ? TenantRegion.usCentral
      : TenantRegion.euCentral;

  void _requestMigration() {
    setState(() {
      _pin = _pin.requestChangeTo(_other);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Change request logged. Our CISO replies within one business '
          'day — no data is moved until you confirm.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/settings',
      title: 'Data residency',
      subtitle:
          'Per-tenant Firestore region — no cross-region '
          'replication of clinical records.',
      scrollable: false,
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Data residency', null),
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _StatusCard(pin: _pin, theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          Text(
            'What this region pin covers',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          PsyCard(
            child: Column(
              children: [
                _Bullet(
                  icon: Icons.storage_outlined,
                  title: 'Firestore documents',
                  body:
                      'All clinical records (patients, sessions, '
                      'assessments, superbills, audit logs) live in '
                      '${_pin.region.firestoreRegion}.',
                  cs: cs,
                ),
                _Divider(cs: cs),
                _Bullet(
                  icon: Icons.key_outlined,
                  title: 'KMS envelope keys',
                  body:
                      'Encryption keys are rotated in the same region; '
                      'no cross-region key escrow.',
                  cs: cs,
                ),
                _Divider(cs: cs),
                _Bullet(
                  icon: Icons.mail_outline,
                  title: 'Transactional email',
                  body: _pin.region == TenantRegion.euCentral
                      ? 'AWS SES eu-west-1 (Ireland) — TLS 1.3 in transit, '
                            'opportunistic STARTTLS at the recipient edge.'
                      : 'AWS SES us-east-1 (Virginia) — TLS 1.3 in transit, '
                            'opportunistic STARTTLS at the recipient edge.',
                  cs: cs,
                ),
                _Divider(cs: cs),
                _Bullet(
                  icon: Icons.history_outlined,
                  title: 'Audit log retention',
                  body:
                      '6 years (HIPAA §164.316). Append-only, '
                      'hash-chained, regional.',
                  cs: cs,
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          Text(
            'Compliance bundle for this region',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PsySpacing.sm),
          PsyCard(
            child: Wrap(
              spacing: PsySpacing.sm,
              runSpacing: PsySpacing.sm,
              children: [
                for (final f in _pin.region.mandatoryFrameworks)
                  PsyBadge(label: f, tone: PsyBadgeTone.success),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          if (_pin.hasPendingChange) ...[
            PsyCard(
              tinted: true,
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_outlined, color: PsyColors.warning),
                  const SizedBox(width: PsySpacing.sm),
                  Expanded(
                    child: Text(
                      'Migration to ${_pin.changeRequestedTo!.displayLabel} '
                      'requested ${_pin.changeRequestedAt!.toIso8601String()} '
                      '— awaiting CISO approval. Your data is still in '
                      '${_pin.region.displayLabel}.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: PsySpacing.xl),
          ],
          if (!_pin.hasPendingChange)
            OutlinedButton.icon(
              onPressed: _requestMigration,
              icon: const Icon(Icons.compare_arrows),
              label: Text('Request migration to ${_other.displayLabel}'),
            ),
          const SizedBox(height: PsySpacing.huge),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.pin, required this.theme, required this.cs});
  final TenantRegionPin pin;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
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
            child: Icon(Icons.public, color: cs.primary, size: 24),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Active pin',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    PsyBadge(
                      label: pin.region.displayLabel,
                      tone: PsyBadgeTone.success,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pinned ${pin.pinnedAt.toIso8601String().split("T").first} · '
                  '${pin.region.jurisdiction} jurisdiction. Tenant id '
                  '${pin.tenantId}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
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

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.title,
    required this.body,
    required this.cs,
  });
  final IconData icon;
  final String title;
  final String body;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: t.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
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

class _Divider extends StatelessWidget {
  const _Divider({required this.cs});
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) => Divider(
    height: PsySpacing.lg,
    color: cs.onSurface.withValues(alpha: 0.08),
  );
}
