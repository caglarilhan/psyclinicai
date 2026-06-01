import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/baa` — HIPAA Business Associate Agreement summary + request CTA.
/// Mirrors the structure of [DpaPage]; the binding contract is the
/// signed PDF emailed from legal@psyclinicai.com on request.
class BaaPage extends StatelessWidget {
  const BaaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/baa',
      title: 'HIPAA BAA',
      subtitle:
          'Business Associate Agreement — for US clinicians handling PHI.',
      breadcrumbs: const [
        Crumb('Settings', '/settings'),
        Crumb('HIPAA BAA', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PsyCard(
            tinted: true,
            child: Row(
              children: [
                Icon(Icons.health_and_safety_outlined,
                    color: cs.primary, size: 22),
                const SizedBox(width: PsySpacing.md),
                Expanded(
                  child: Text(
                    'A signed BAA is required before storing US Protected '
                    'Health Information (PHI) on PsyClinicAI. We sign before '
                    'you upload your first patient.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xl),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Scope',
            body:
                'PsyClinicAI is the Business Associate under 45 CFR §160.103. '
                'We process PHI solely to perform services you instruct.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Safeguards',
            body:
                'Administrative, physical, and technical safeguards meeting '
                'the HIPAA Security Rule, including AES-256 at rest, TLS 1.3 '
                'in transit, role-based access, and audit logging.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Breach notification',
            body:
                'Within 60 days of discovery (45 CFR §164.410) — we aim for '
                '72 hours to mirror the GDPR commitment.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Subcontractors',
            body:
                'No subcontractor receives PHI unless it has executed a written '
                'BAA with terms at least as protective. Live list at /subprocessors.',
          ),
          _Section(
            theme: theme,
            cs: cs,
            title: 'Termination',
            body:
                'On termination we return or destroy all PHI in our possession '
                'within 30 days, or extend protections if return/destruction is '
                'infeasible, per §164.504(e)(2)(ii)(J).',
          ),
          const SizedBox(height: PsySpacing.xl),
          PsyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request a signed BAA',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: PsySpacing.sm),
                Text(
                  'Email legal@psyclinicai.com with your NPI and clinic '
                  'address. Counter-signed BAA returns within 1 business day.',
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.72),
                height: 1.6,
              )),
        ],
      ),
    );
  }
}
