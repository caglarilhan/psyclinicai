import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/settings` — clinician settings hub. Surfaces account info,
/// integration keys, and a danger zone for account deletion.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = FirebaseAuthService.instance.profile;

    return AppShell(
      routeName: '/settings',
      title: 'Settings',
      subtitle: 'Account, integrations, and trust & legal.',
      scrollable: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _section(theme, cs, 'Account'),
          PsyCard(
            tinted: true,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: cs.primary,
                  child:
                      Icon(Icons.person, color: cs.onPrimary, size: 26),
                ),
                const SizedBox(width: PsySpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile?.fullName ?? 'Demo user',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      // Phones can't fit a full email + Demo-mode badge in one
                      // row; truncate cleanly instead of letting the last char
                      // drop to a second line.
                      Text(profile?.email ?? 'demo@psyclinicai.com',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                          )),
                    ],
                  ),
                ),
                PsyBadge(
                  label: PsyFirebase.isReady ? 'Live' : 'Demo mode',
                  tone: PsyFirebase.isReady
                      ? PsyBadgeTone.success
                      : PsyBadgeTone.warning,
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          _section(theme, cs, 'Profile'),
          _row(context, theme, cs,
              icon: Icons.badge_outlined,
              title: 'Clinician profile',
              body: 'Name, credentials, NPI, license — flows into the '
                  'superbill and PDF exports.',
              onTap: () =>
                  Navigator.of(context).pushNamed('/settings/profile')),
          const SizedBox(height: PsySpacing.xxl),
          _section(theme, cs, 'Workspace'),
          _row(context, theme, cs,
              icon: Icons.key_outlined,
              title: 'API keys',
              body: 'Bring-your-own Anthropic key.',
              onTap: () => Navigator.of(context)
                  .pushNamed('/settings/api_keys')),
          _row(context, theme, cs,
              icon: Icons.replay_outlined,
              title: 'Re-run onboarding',
              body: 'Walk the 5-step wizard again.',
              onTap: () =>
                  Navigator.of(context).pushNamed('/onboarding')),
          _row(context, theme, cs,
              icon: Icons.show_chart,
              title: 'Outcomes dashboard',
              body: 'Trend across all your patients.',
              onTap: () => Navigator.of(context).pushNamed('/outcomes')),
          const SizedBox(height: PsySpacing.xxl),
          _section(theme, cs, 'Security'),
          _row(context, theme, cs,
              icon: Icons.shield_outlined,
              title: 'Two-factor authentication',
              body: 'TOTP + recovery codes — required for ePHI under '
                  'HIPAA §164.312(d). Status: not enabled.',
              onTap: () =>
                  Navigator.of(context).pushNamed('/settings/mfa')),
          const SizedBox(height: PsySpacing.xxl),
          _section(theme, cs, 'Trust & legal'),
          _row(context, theme, cs,
              icon: Icons.shield_outlined,
              title: 'Trust Center',
              body: 'HIPAA, GDPR, security controls, subprocessors.',
              onTap: () => Navigator.of(context).pushNamed('/trust')),
          _row(context, theme, cs,
              icon: Icons.verified_user_outlined,
              title: 'Security',
              onTap: () => Navigator.of(context).pushNamed('/security')),
          _row(context, theme, cs,
              icon: Icons.fact_check_outlined,
              title: 'Audit log',
              body: 'Every read, write, and export — last 7 days.',
              onTap: () =>
                  Navigator.of(context).pushNamed('/settings/audit_log')),
          _row(context, theme, cs,
              icon: Icons.cloud_download_outlined,
              title: 'Patient data export (DSAR)',
              body: 'GDPR Art. 15 + 20 portable JSON bundle.',
              onTap: () => Navigator.of(context)
                  .pushNamed('/settings/data_export')),
          _row(context, theme, cs,
              icon: Icons.assignment_turned_in_outlined,
              title: 'GDPR DPA',
              body: 'EU Data Processing Agreement (Article 28).',
              onTap: () => Navigator.of(context).pushNamed('/dpa')),
          _row(context, theme, cs,
              icon: Icons.health_and_safety_outlined,
              title: 'HIPAA BAA',
              body: 'US Business Associate Agreement.',
              onTap: () => Navigator.of(context).pushNamed('/baa')),
          _row(context, theme, cs,
              icon: Icons.gavel_outlined,
              title: 'Privacy policy',
              onTap: () => Navigator.of(context).pushNamed('/privacy')),
          _row(context, theme, cs,
              icon: Icons.description_outlined,
              title: 'Terms of service',
              onTap: () => Navigator.of(context).pushNamed('/tos')),
          _row(context, theme, cs,
              icon: Icons.email_outlined,
              title: 'Contact',
              onTap: () => Navigator.of(context).pushNamed('/contact')),
          const SizedBox(height: PsySpacing.xxxl),
          _section(theme, cs, 'Danger zone'),
          PsyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: cs.error, size: 20),
                    const SizedBox(width: PsySpacing.sm),
                    Text('Delete my account',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: PsySpacing.sm),
                Text(
                  'Removes your tenant, all patients, notes, superbills, '
                  'and assessments. 30-day grace period for export, then '
                  'a hard delete with an audit-log entry.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.72),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: PsySpacing.lg),
                PsyButton(
                  label: 'Request deletion',
                  variant: PsyButtonVariant.destructive,
                  icon: Icons.delete_forever_outlined,
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Center(
            child: TextButton.icon(
              onPressed: () => _signOut(context),
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Sign out'),
              style: TextButton.styleFrom(
                foregroundColor: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(ThemeData theme, ColorScheme cs, String label) {
    return Padding(
      padding: const EdgeInsets.only(
          top: PsySpacing.xl, bottom: PsySpacing.md),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.4,
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs, {
    required IconData icon,
    required String title,
    String? body,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.xl, vertical: PsySpacing.lg),
        child: Row(
          children: [
            Icon(icon, color: cs.primary, size: 20),
            const SizedBox(width: PsySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (body != null) ...[
                    const SizedBox(height: 2),
                    Text(body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        )),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This starts a 30-day deletion countdown. Within that window '
          'you can email founders@psyclinicai.com to abort. After 30 '
          'days everything is permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Start deletion'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Deletion request received. We will email a confirmation within 24 h.'),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    if (PsyFirebase.isReady) {
      await FirebaseAuthService.instance.signOut();
    }
    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/landing');
  }
}
