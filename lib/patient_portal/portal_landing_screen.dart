import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../widgets/ds/psy_card.dart';

/// `/portal` — Patient self-service landing.
///
/// The Patient PWA is a **separate route tree** under `/portal/*` with
/// no clinician chrome. EU + US scope on launch (HIPAA Right of
/// Access + GDPR Art. 15–22).
class PortalLandingScreen extends StatelessWidget {
  const PortalLandingScreen({super.key, this.firstName});

  final String? firstName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(title: const Text('Patient portal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PsySpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                firstName == null
                    ? 'Welcome back.'
                    : 'Welcome back, $firstName.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: PsySpacing.sm),
              Text(
                'Manage your appointments, complete questionnaires, '
                'and message your clinician — all in one place.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: PsySpacing.lg),
              const _PortalActionCard(
                icon: Icons.event_outlined,
                title: 'Appointments',
                subtitle: 'View, confirm, or reschedule.',
                route: '/portal/appointments',
              ),
              const _PortalActionCard(
                icon: Icons.assignment_outlined,
                title: 'Questionnaires',
                subtitle: 'PHQ-9, GAD-7 — completed at your pace.',
                route: '/portal/proms',
              ),
              const _PortalActionCard(
                icon: Icons.mail_outline,
                title: 'Secure inbox',
                subtitle: 'Encrypted messages with your care team.',
                route: '/portal/inbox',
              ),
              const _PortalActionCard(
                icon: Icons.assignment_ind_outlined,
                title: 'Intake form',
                subtitle: 'Complete before your first session.',
                route: '/portal/intake',
              ),
              const SizedBox(height: PsySpacing.xl),
              PsyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data, your rights',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: PsySpacing.sm),
                    const Text(
                      'You can request an export of your records, '
                      'correct any inaccuracies, or ask us to delete '
                      'your account at any time.',
                    ),
                    const SizedBox(height: PsySpacing.md),
                    TextButton(
                      onPressed: () {
                        // Until the in-app DSAR portal lands, route to a
                        // mailto fallback so the legal obligation
                        // (HIPAA Right of Access, GDPR Art. 15-22) is
                        // never a dead button.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Email privacy@psyclinic.ai to manage '
                              'your data rights. The in-app portal is '
                              'launching soon.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Manage data rights →'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortalActionCard extends StatelessWidget {
  const _PortalActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        onTap: () => Navigator.of(context).pushNamed(route),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
