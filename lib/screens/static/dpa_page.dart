import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/dpa` — GDPR Article 28 Data Processing Agreement summary + the
/// "request your signed copy" CTA. Renders an executive abstract of
/// `docs/GDPR-DPA.md`; the signed PDF is mailed on request so the
/// landing build doesn't ship a 30-page legal annex.
class DpaPage extends StatelessWidget {
  const DpaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/dpa',
      title: 'GDPR DPA',
      subtitle:
          'EU General Data Protection Regulation — Article 28 (Processor).',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('GDPR DPA', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Summary(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xl),
          _FactsCard(theme: theme, cs: cs, rows: const [
            _Fact('Controller', 'Clinic / clinician'),
            _Fact('Processor', 'PsyClinic Software GmbH'),
            _Fact('Data residency', 'Frankfurt, EU-Central'),
            _Fact('Audio handling', 'On-device by default'),
            _Fact('Breach notice', 'Within 72 hours'),
          ]),
          const SizedBox(height: PsySpacing.xl),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Roles',
            body:
                'You (the clinic / clinician) are the Controller. PsyClinic '
                'Software GmbH is the Processor. Patients are Data Subjects.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Sub-processors',
            body:
                'Hetzner Online GmbH (DE-Frankfurt) · Firebase Auth (eu-multi) · '
                'Anthropic — only when you supply your own API key (BYOK). A live '
                'list is at /subprocessors with 30-day change notice.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Data residency',
            body:
                'All clinical data stored in EU-Central (Frankfurt). Audio is '
                'transcribed on-device by default — never uploaded.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Sub-processor changes',
            body:
                'We email you 30 days before adding or replacing any sub-processor. '
                'You can object during that window without penalty.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Breach notification',
            body:
                'You are notified within 72 hours of a confirmed personal-data '
                'breach affecting your tenant, with scope, affected data, and '
                'remediation steps.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Data subject rights',
            body:
                'Self-serve export and erasure are surfaced in Settings → Account. '
                'For complex requests we respond within 30 days.',
          ),
          const SizedBox(height: PsySpacing.xl),
          _DownloadCard(theme: theme, cs: cs),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return PsyCard(
      // Info notice (no action) — neutral surface keeps the teal palette
      // reserved for primary CTAs and active states, per critique.
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: cs.primary, size: 22),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Text(
              'This is an executive summary. The signed DPA — countersigned, '
              'PDF, with full Annex I/II/III — is emailed on request.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.theme,
    required this.cs,
    required this.title,
    required this.body,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          Text(body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
                height: 1.55,
                fontSize: 13.5,
              )),
        ],
      ),
    );
  }
}

// Quick facts strip — the 5 questions every clinic asks before signing.
// Scannable in 5 seconds, while the narrative _Section below carries
// the full legal language.
class _Fact {
  const _Fact(this.label, this.value);
  final String label;
  final String value;
}

class _FactsCard extends StatelessWidget {
  const _FactsCard(
      {required this.theme, required this.cs, required this.rows});
  final ThemeData theme;
  final ColorScheme cs;
  final List<_Fact> rows;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.lg, vertical: PsySpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Divider(
                    height: 1, color: cs.outlineVariant.withValues(alpha: 0.6)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      rows[i].label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rows[i].value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
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

class _DownloadCard extends StatelessWidget {
  const _DownloadCard({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request a signed copy',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Email legal@psyclinicai.com with your clinic name and we will '
            'return a counter-signed DPA within 1 business day.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.72),
              height: 1.55,
            ),
          ),
          const SizedBox(height: PsySpacing.lg),
          PsyButton(
            label: 'Email legal@psyclinicai.com',
            icon: Icons.email_outlined,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Email client opens in your local mail handler — demo skips this in web.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
