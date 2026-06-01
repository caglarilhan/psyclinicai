import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/trust` — the enterprise-grade compliance landing.
///
/// One hub that mirrors the layout auditors and IT-procurement teams
/// expect (Vanta / Drata / Linear-style): security posture at a glance,
/// then a grid of cards linking to every detail document.
///
/// Pages reached from here:
///   `/trust/subprocessors`         GDPR Art. 28 live list
///   `/trust/security_controls`     HIPAA Security Rule mapping
///   `/trust/incident_response`     IR plan summary
///   `/baa`                         HIPAA Business Associate Agreement
///   `/dpa`                         GDPR Article 28 DPA
///   `/settings/audit_log`          Immutable activity timeline
class TrustCenterScreen extends StatelessWidget {
  const TrustCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/trust',
      title: 'Trust Center',
      subtitle:
          'Security, privacy, and compliance posture — verifiable in one place.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('Trust Center', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PostureBar(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          _SectionHeader(theme: theme, cs: cs, label: 'Programs'),
          const SizedBox(height: PsySpacing.md),
          _TrustGrid(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xxl),
          _SectionHeader(
              theme: theme, cs: cs, label: 'Documents on request'),
          const SizedBox(height: PsySpacing.md),
          _DocsCard(theme: theme, cs: cs),
        ],
      ),
    );
  }
}

class _PostureBar extends StatelessWidget {
  const _PostureBar({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    final items = const [
      _Posture('HIPAA', 'Aligned', PsyBadgeTone.success),
      _Posture('GDPR Art. 28', 'DPA signed on request', PsyBadgeTone.success),
      _Posture('SOC 2 Type II', 'In progress · Q4 2026', PsyBadgeTone.warning),
      _Posture('ISO 27001:2022', 'Roadmap · 2027', PsyBadgeTone.warning),
    ];
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(
                  height: 1,
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      items[i].name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      items[i].status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  PsyBadge(
                    label: items[i].tone == PsyBadgeTone.success
                        ? 'Live'
                        : 'Planned',
                    tone: items[i].tone,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Posture {
  const _Posture(this.name, this.status, this.tone);
  final String name;
  final String status;
  final PsyBadgeTone tone;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.theme, required this.cs, required this.label});
  final ThemeData theme;
  final ColorScheme cs;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
      ),
    );
  }
}

class _TrustGrid extends StatelessWidget {
  const _TrustGrid({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    final cards = <_TrustCard>[
      const _TrustCard(
        icon: Icons.health_and_safety_outlined,
        title: 'HIPAA BAA',
        body: 'US Business Associate Agreement — signed before any PHI upload.',
        route: '/baa',
      ),
      const _TrustCard(
        icon: Icons.assignment_turned_in_outlined,
        title: 'GDPR DPA',
        body: 'EU Article 28 Data Processing Agreement + Art. 30 register.',
        route: '/dpa',
      ),
      const _TrustCard(
        icon: Icons.shield_outlined,
        title: 'Security controls',
        body: 'Administrative, physical, and technical safeguards mapped.',
        route: '/trust/security_controls',
      ),
      const _TrustCard(
        icon: Icons.lan_outlined,
        title: 'Subprocessors',
        body: 'Live list — 30-day change notice + risk classification.',
        route: '/trust/subprocessors',
      ),
      const _TrustCard(
        icon: Icons.fact_check_outlined,
        title: 'Audit log',
        body: 'Append-only, hash-chained, tamper-evident clinician activity.',
        route: '/settings/audit_log',
      ),
      const _TrustCard(
        icon: Icons.report_problem_outlined,
        title: 'Incident response',
        body: 'Detection → containment → notification → post-mortem.',
        route: '/trust/incident_response',
      ),
    ];
    return LayoutBuilder(builder: (context, c) {
      final cols = c.maxWidth >= PsyBreakpoints.md ? 2 : 1;
      final w = (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
      return Wrap(
        spacing: PsySpacing.lg,
        runSpacing: PsySpacing.lg,
        children: cards
            .map((card) => SizedBox(
                  width: w,
                  child: _TrustCardView(card: card, theme: theme, cs: cs),
                ))
            .toList(),
      );
    });
  }
}

class _TrustCard {
  const _TrustCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.route,
  });
  final IconData icon;
  final String title;
  final String body;
  final String route;
}

class _TrustCardView extends StatelessWidget {
  const _TrustCardView(
      {required this.card, required this.theme, required this.cs});
  final _TrustCard card;
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return PsyCard(
      onTap: () => Navigator.of(context).pushNamed(card.route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.md),
                ),
                child: Icon(card.icon, color: cs.primary, size: 18),
              ),
              const Spacer(),
              Icon(Icons.chevron_right,
                  color: cs.onSurface.withValues(alpha: 0.45)),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          Text(card.title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.xs),
          Text(
            card.body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocsCard extends StatelessWidget {
  const _DocsCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    final docs = const [
      _DocRow('Security whitepaper', 'On request'),
      _DocRow('SOC 2 readiness summary', 'Q4 2026'),
      _DocRow('Penetration test report', 'Under NDA'),
      _DocRow('ISO 27001 statement of applicability', 'Roadmap · 2027'),
      _DocRow('Vulnerability disclosure', '/.well-known/security.txt'),
    ];
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.sm),
      child: Column(
        children: [
          for (var i = 0; i < docs.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.md),
              child: Row(
                children: [
                  Icon(Icons.description_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: PsySpacing.md),
                  Expanded(
                    child: Text(
                      docs[i].name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    docs[i].when,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocRow {
  const _DocRow(this.name, this.when);
  final String name;
  final String when;
}
