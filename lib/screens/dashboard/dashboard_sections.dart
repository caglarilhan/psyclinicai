/// Dashboard sections that aren't outcome KPIs or the quick-actions
/// grid:
/// - [RoleChip]: small pill showing the clinician's role
///   (Therapist / Psychiatrist / Admin) above the dashboard title.
/// - [DemoBanner]: amber dev-only callout that surfaces when
///   Firebase isn't configured — kept gated behind kDebugMode so
///   production visitors never see "demo mode".
/// - [RecentActivity]: empty-state placeholder for the activity
///   feed; live stream wiring lands later.
/// - [SetupChecklist]: onboarding tasks (profile, MFA, Stripe,
///   first patient) backed by [OnboardingChecklist].
///
/// HIGH-6 slice C (audit 2026-06-21): extracted from
/// dashboard_screen.dart.
library;

import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../widgets/onboarding_checklist.dart';

class RoleChip extends StatelessWidget {
  const RoleChip({
    super.key,
    required this.label,
    required this.cs,
    required this.theme,
  });
  final String label;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PsySpacing.md,
        vertical: PsySpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PsyRadius.full),
        border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, required this.cs, required this.theme});
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud_off, color: Colors.amber, size: 22),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're in demo mode — Firebase isn't configured yet.",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: PsySpacing.sm),
                _bullet(
                  cs,
                  theme,
                  'Sign-ups, patients and superbills are stored in memory only.',
                ),
                _bullet(
                  cs,
                  theme,
                  'KPI cards show empty-state copy until a real backend is online.',
                ),
                _bullet(
                  cs,
                  theme,
                  'Run flutterfire configure with your Firebase project and refresh.',
                ),
                const SizedBox(height: PsySpacing.md),
                Wrap(
                  spacing: PsySpacing.md,
                  runSpacing: PsySpacing.sm,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/security'),
                      icon: const Icon(Icons.menu_book_outlined, size: 16),
                      label: const Text('Setup guide'),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/contact'),
                      icon: const Icon(Icons.support_agent, size: 16),
                      label: const Text('Need help'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(ColorScheme cs, ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key, required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.xxl,
            vertical: PsySpacing.xxxl,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(PsyRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(
                Icons.history_outlined,
                color: cs.onSurface.withValues(alpha: 0.45),
                size: 36,
              ),
              const SizedBox(height: PsySpacing.md),
              Text(
                'No activity yet.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: PsySpacing.xs),
              Text(
                'Start a session or send a screener — entries will show up here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SetupChecklist extends StatelessWidget {
  const SetupChecklist({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    final items = <OnboardingChecklistItem>[
      OnboardingChecklistItem(
        id: 'profile',
        label: 'Add your clinician profile',
        body: 'NPI, license, signature — feeds the superbill.',
        icon: Icons.badge_outlined,
        done: false,
        onTap: () => nav.pushNamed('/settings/profile'),
      ),
      OnboardingChecklistItem(
        id: 'mfa',
        label: 'Enable two-factor authentication',
        body: 'TOTP + recovery codes. Required for ePHI under HIPAA.',
        icon: Icons.shield_outlined,
        done: false,
        onTap: () => nav.pushNamed('/settings/mfa'),
      ),
      OnboardingChecklistItem(
        id: 'stripe',
        label: 'Connect Stripe to take payments',
        body: 'Express onboarding · 5 minutes · KYC handled by Stripe.',
        icon: Icons.payments_outlined,
        done: false,
        onTap: () => nav.pushNamed('/settings/payments'),
      ),
      OnboardingChecklistItem(
        id: 'first-patient',
        label: 'Invite your first patient',
        body: 'Send the intake form, capture consent, schedule.',
        icon: Icons.person_add_alt_outlined,
        done: false,
        onTap: () => nav.pushNamed('/patients'),
      ),
    ];
    return OnboardingChecklist(items: items);
  }
}
