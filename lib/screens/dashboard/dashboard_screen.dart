import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth/clinician_role.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_reveal.dart';
import '../../widgets/onboarding_checklist.dart';
import 'dashboard_actions.dart';
import 'dashboard_kpis.dart';

/// Dashboard v2 — clinician home.
///
/// Sits in the shared [AppShell] (rail + header + breadcrumb). Surface:
/// greeting title + "New session" CTA, four outcome KPIs, quick-action grid,
/// recent-activity empty state. Counts go live once repository streams wire in.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = context.watch<FirebaseAuthService>();
    final profile = auth.profile;
    final name = profile?.fullName.split(' ').first;
    // Don't fall back to "Good afternoon, there." — that screams placeholder.
    final title = (name == null || name.isEmpty)
        ? '${_greeting()}.'
        : '${_greeting()}, $name.';

    return AppShell(
      routeName: '/dashboard',
      breadcrumbs: const [Crumb('Dashboard', null)],
      title: title,
      subtitle: 'Here is what your practice looks like right now.',
      primaryAction: FilledButton.icon(
        onPressed: () => Navigator.of(context).pushNamed('/session'),
        icon: const Icon(Icons.mic_none),
        label: const Text('New session'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xl),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (profile?.role.label != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: _RoleChip(
                label: profile!.role.label,
                cs: cs,
                theme: theme,
              ),
            ),
            const SizedBox(height: PsySpacing.xl),
          ],
          // Dev-only callout — production visitors should not see "Firebase
          // isn't configured" on the dashboard.
          if (!PsyFirebase.isReady && kDebugMode) ...[
            _DemoBanner(cs: cs, theme: theme),
            const SizedBox(height: PsySpacing.xl),
          ],
          PsyReveal(
            child: KpiRow(theme: theme, cs: cs),
          ),
          const SizedBox(height: PsySpacing.xxl),
          const PsyReveal(
            delay: Duration(milliseconds: 40),
            child: _SetupChecklist(),
          ),
          const SizedBox(height: PsySpacing.xxl),
          PsyReveal(
            delay: const Duration(milliseconds: 80),
            child: QuickActions(theme: theme, cs: cs),
          ),
          const SizedBox(height: PsySpacing.xxl),
          PsyReveal(
            delay: const Duration(milliseconds: 160),
            child: _RecentActivity(theme: theme, cs: cs),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.cs, required this.theme});
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

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.cs, required this.theme});
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



class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.theme, required this.cs});
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

class _SetupChecklist extends StatelessWidget {
  const _SetupChecklist();

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
