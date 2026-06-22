import 'dart:async';

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
            child: _KpiRow(theme: theme, cs: cs),
          ),
          const SizedBox(height: PsySpacing.xxl),
          PsyReveal(
            delay: const Duration(milliseconds: 40),
            child: _SetupChecklist(),
          ),
          const SizedBox(height: PsySpacing.xxl),
          PsyReveal(
            delay: const Duration(milliseconds: 80),
            child: _QuickActions(theme: theme, cs: cs),
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

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    // Demo-mode seed so the dashboard reads "live" instead of "broken".
    // Production wiring swaps this for a Firestore stream feeding
    // DashboardMetricsBuilder; surface stays the same.
    final kpis = <_Kpi>[
      _Kpi(
        label: "Today's sessions",
        value: '4',
        emptyText: 'Next at 13:30 · John Demo',
        icon: Icons.event_available_outlined,
        tint: cs.primary,
      ),
      _Kpi(
        label: 'Pending notes',
        value: '2',
        emptyText: 'Both > 24h — sign before billing',
        icon: Icons.edit_note_outlined,
        tint: cs.tertiary,
      ),
      _Kpi(
        label: 'At-risk patients (7d)',
        value: '1',
        emptyText: 'PHQ-9 ≥ 15 or C-SSRS flag',
        icon: Icons.health_and_safety_outlined,
        tint: cs.error,
      ),
      _Kpi(
        label: 'Outstanding superbills',
        value: '\$680',
        emptyText: 'Oldest 12 days — chase before 30d',
        icon: Icons.receipt_long_outlined,
        tint: cs.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= PsyBreakpoints.lg
            ? 4
            : c.maxWidth >= PsyBreakpoints.sm
            ? 2
            : 1;
        final cardW = (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
        return Wrap(
          spacing: PsySpacing.lg,
          runSpacing: PsySpacing.lg,
          children: kpis
              .map(
                (k) => SizedBox(
                  width: cardW,
                  child: _KpiCard(kpi: k, theme: theme, cs: cs),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// Sprint 29 F-06 — explicit lifecycle for KPI cards. Each card resolves
/// to exactly one of these so the screen never renders a confused mix.
enum KpiState { loading, data, error }

class _Kpi {
  _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    this.emptyText,
    // Reserved for Firestore-stream wiring; defaults preserve the demo
    // seed visually until the production stream lands.
    // ignore: unused_element_parameter
    this.state = KpiState.data,
    // ignore: unused_element_parameter
    this.onRetry,
  });
  final String label;
  // `value` is null while we have no backend data; the card then renders
  // `emptyText` in a calmer body style instead of a giant em-dash.
  final String? value;
  final String? emptyText;
  final IconData icon;
  final Color tint;
  final KpiState state;
  final VoidCallback? onRetry;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi, required this.theme, required this.cs});
  final _Kpi kpi;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PsySpacing.xl),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kpi.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(PsyRadius.md),
            ),
            child: Icon(kpi.icon, color: kpi.tint, size: 22),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sprint 29 F-06 — render exactly one of the 3 lifecycle
                // states so the dashboard never half-paints.
                switch (kpi.state) {
                  KpiState.loading => _KpiLoadingLine(cs: cs),
                  KpiState.error => _KpiErrorLine(
                    cs: cs,
                    theme: theme,
                    onRetry: kpi.onRetry,
                  ),
                  KpiState.data =>
                    kpi.value != null
                        ? Text(
                            kpi.value!,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            // Empty state: smaller, muted — reads as
                            // "ready, no data yet" instead of a broken
                            // placeholder.
                            kpi.emptyText ?? '—',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.85),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                },
                const SizedBox(height: PsySpacing.xxs),
                Text(
                  kpi.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
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

/// Pulsing skeleton line for [KpiState.loading]. Pure CSS-style
/// pulse so we don't pull in a shimmer dependency.
class _KpiLoadingLine extends StatefulWidget {
  const _KpiLoadingLine({required this.cs});
  final ColorScheme cs;

  @override
  State<_KpiLoadingLine> createState() => _KpiLoadingLineState();
}

class _KpiLoadingLineState extends State<_KpiLoadingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _alpha;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    unawaited(_ctrl.repeat(reverse: true));
    _alpha = Tween<double>(begin: 0.35, end: 0.75).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alpha,
      builder: (_, __) {
        return Semantics(
          label: 'Loading metric',
          liveRegion: true,
          child: Container(
            height: 26,
            width: 96,
            decoration: BoxDecoration(
              color: widget.cs.onSurface.withValues(alpha: _alpha.value * 0.18),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        );
      },
    );
  }
}

/// Error row for [KpiState.error] — readable label + actionable retry.
class _KpiErrorLine extends StatelessWidget {
  const _KpiErrorLine({
    required this.cs,
    required this.theme,
    required this.onRetry,
  });
  final ColorScheme cs;
  final ThemeData theme;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Failed to load metric',
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Unavailable',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.error,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 32),
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final actions = <_Action>[
      _Action(
        icon: Icons.mic_none,
        label: 'Start a session',
        body: 'Live AI Co-Pilot with on-device transcription.',
        route: '/session',
      ),
      _Action(
        icon: Icons.notifications_active_outlined,
        label: 'Caseload attention',
        body: 'Who needs you now — overdue work, stalled plans, risk.',
        route: '/caseload',
      ),
      _Action(
        icon: Icons.group_outlined,
        label: 'Patients',
        body: 'Search the roster, add a patient, open a chart.',
        route: '/patients',
      ),
      _Action(
        icon: Icons.show_chart,
        label: 'Outcomes',
        body: 'PHQ-9 + GAD-7 trend dashboard with severity bands.',
        route: '/outcomes',
      ),
      _Action(
        icon: Icons.receipt_long_outlined,
        label: 'Create superbill',
        body: 'CPT + ICD-10 picker, CMS-1500-aligned PDF.',
        route: '/superbill',
      ),
      _Action(
        icon: Icons.psychology_outlined,
        label: 'Send PHQ-9',
        body: 'Depression screener with severity bands.',
        route: '/assessments/phq9',
      ),
      _Action(
        icon: Icons.spa_outlined,
        label: 'Send GAD-7',
        body: 'Anxiety screener with severity bands.',
        route: '/assessments/gad7',
      ),
      _Action(
        icon: Icons.shield_moon_outlined,
        label: 'C-SSRS suicide screen',
        body: 'Columbia suicide-risk screener with categorical guidance.',
        route: '/scales/cssrs',
      ),
      _Action(
        icon: Icons.bolt_outlined,
        label: 'PCL-5 (PTSD)',
        body: '20-item PTSD checklist with provisional threshold.',
        route: '/scales/pcl5',
      ),
      _Action(
        icon: Icons.local_bar_outlined,
        label: 'AUDIT (alcohol)',
        body: 'WHO alcohol-use screener with risk bands.',
        route: '/scales/audit',
      ),
      _Action(
        icon: Icons.smart_toy_outlined,
        label: 'AI assistant',
        body: 'Chat with the clinical reasoning co-pilot.',
        route: '/ai_chatbot',
      ),
      _Action(
        icon: Icons.help_outline,
        label: 'Help & docs',
        body: 'Setup guide, FAQ, security overview.',
        route: '/security',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: PsySpacing.lg),
        LayoutBuilder(
          builder: (ctx, c) {
            final cols = c.maxWidth >= PsyBreakpoints.lg
                ? 3
                : c.maxWidth >= PsyBreakpoints.sm
                ? 2
                : 1;
            final cardW = (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
            return Wrap(
              spacing: PsySpacing.lg,
              runSpacing: PsySpacing.lg,
              children: actions
                  .map(
                    (a) => SizedBox(
                      width: cardW,
                      child: _ActionTile(action: a, theme: theme, cs: cs),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Action {
  _Action({
    required this.icon,
    required this.label,
    required this.body,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String body;
  final String route;
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.action,
    required this.theme,
    required this.cs,
  });
  final _Action action;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final cs = widget.cs;
    final action = widget.action;
    final hover = _hover;
    final radius = BorderRadius.circular(PsyRadius.lg);

    return Material(
      color: cs.surface,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => Navigator.of(context).pushNamed(action.route),
        onHover: (h) => setState(() => _hover = h),
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: PsyMotion.fast,
          curve: PsyMotion.standard,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, hover ? -3.0 : 0.0, 0.0, 1.0),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.all(PsySpacing.xl),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: hover
                  ? cs.primary.withValues(alpha: 0.45)
                  : cs.outlineVariant,
            ),
            boxShadow: hover
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: PsyMotion.fast,
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: hover ? 0.18 : 0.12),
                      borderRadius: BorderRadius.circular(PsyRadius.sm),
                    ),
                    child: Icon(action.icon, color: cs.primary, size: 20),
                  ),
                  const Spacer(),
                  // Surprise affordance: an arrow slides in on hover.
                  AnimatedOpacity(
                    duration: PsyMotion.fast,
                    opacity: hover ? 1 : 0,
                    child: AnimatedSlide(
                      duration: PsyMotion.fast,
                      curve: PsyMotion.standard,
                      offset: hover ? Offset.zero : const Offset(-0.3, 0.3),
                      child: Icon(
                        Icons.arrow_outward,
                        color: cs.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PsySpacing.lg),
              Text(
                action.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: PsySpacing.xs),
              Text(
                action.body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
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
