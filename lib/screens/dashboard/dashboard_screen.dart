import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/firestore_schema.dart';
import '../../theme/tokens.dart';

/// Dashboard v2 — clinician home.
///
/// Replaces the previous 978-line monolithic dashboard with a focused
/// surface: greeting, four outcome KPIs, quick-action grid, recent
/// activity placeholder. Counts will go live once Sprint D wires
/// repository streams in.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = context.watch<FirebaseAuthService>();
    final profile = auth.profile;
    final greeting = _greeting();
    final name = profile?.fullName.split(' ').first ?? 'there';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, color: cs.primary, size: 26),
            const SizedBox(width: PsySpacing.sm),
            Text(
              'PsyClinicAI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'API keys',
            onPressed: () =>
                Navigator.of(context).pushNamed('/settings/api_keys'),
            icon: const Icon(Icons.key_outlined),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              if (PsyFirebase.isReady) {
                await FirebaseAuthService.instance.signOut();
              }
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/landing');
              }
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: PsySpacing.md),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Greeting(
              greeting: greeting, name: name, role: profile?.role.label),
          if (!PsyFirebase.isReady) _DemoBanner(cs: cs, theme: theme),
          _KpiRow(theme: theme, cs: cs),
          _QuickActions(theme: theme, cs: cs),
          _RecentActivity(theme: theme, cs: cs),
          const SizedBox(height: PsySpacing.xxxl),
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

class _Greeting extends StatelessWidget {
  const _Greeting(
      {required this.greeting, required this.name, required this.role});
  final String greeting;
  final String name;
  final String? role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withValues(alpha: 0.10),
            cs.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(
          PsySpacing.xxl, PsySpacing.xxxl, PsySpacing.xxl, PsySpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name.',
            style: theme.textTheme.displaySmall
                ?.copyWith(fontWeight: FontWeight.bold, height: 1.1),
          ),
          if (role != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: PsySpacing.md, vertical: PsySpacing.xs),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(PsyRadius.full),
                border:
                    Border.all(color: cs.primary.withValues(alpha: 0.30)),
              ),
              child: Text(
                role!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: PsySpacing.lg),
          Text(
            'Here is what your practice looks like right now.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
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
      margin: const EdgeInsets.fromLTRB(
          PsySpacing.xxl, PsySpacing.xl, PsySpacing.xxl, 0),
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
                _bullet(cs, theme,
                    'Sign-ups, patients and superbills are stored in memory only.'),
                _bullet(cs, theme,
                    'Counts and trends show placeholders ("—") until a real backend is online.'),
                _bullet(cs, theme,
                    'Run flutterfire configure with your Firebase project and refresh.'),
                const SizedBox(height: PsySpacing.md),
                Wrap(
                  spacing: PsySpacing.md,
                  runSpacing: PsySpacing.sm,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context)
                          .pushNamed('/security'),
                      icon: const Icon(Icons.menu_book_outlined,
                          size: 16),
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
    final kpis = <_Kpi>[
      _Kpi(
          label: "Today's sessions",
          value: '—',
          icon: Icons.event_available_outlined,
          tint: cs.primary),
      _Kpi(
          label: 'Pending notes',
          value: '—',
          icon: Icons.edit_note_outlined,
          tint: cs.tertiary),
      _Kpi(
          label: 'Active patients',
          value: '—',
          icon: Icons.group_outlined,
          tint: cs.secondary),
      _Kpi(
          label: 'Assessments this week',
          value: '—',
          icon: Icons.show_chart,
          tint: cs.primary),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          PsySpacing.xxl, PsySpacing.xxl, PsySpacing.xxl, PsySpacing.lg),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final cols = c.maxWidth >= PsyBreakpoints.lg
              ? 4
              : c.maxWidth >= PsyBreakpoints.sm
                  ? 2
                  : 1;
          final cardW =
              (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
          return Wrap(
            spacing: PsySpacing.lg,
            runSpacing: PsySpacing.lg,
            children: kpis
                .map((k) => SizedBox(
                      width: cardW,
                      child: _KpiCard(kpi: k, theme: theme, cs: cs),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _Kpi {
  _Kpi(
      {required this.label,
      required this.value,
      required this.icon,
      required this.tint});
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(
      {required this.kpi, required this.theme, required this.cs});
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
                Text(
                  kpi.value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: PsySpacing.xxs),
                Text(
                  kpi.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
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
          route: '/session'),
      _Action(
          icon: Icons.group_outlined,
          label: 'Patients',
          body: 'Search the roster, add a patient, open a chart.',
          route: '/patients'),
      _Action(
          icon: Icons.show_chart,
          label: 'Outcomes',
          body: 'PHQ-9 + GAD-7 trend dashboard with severity bands.',
          route: '/outcomes'),
      _Action(
          icon: Icons.receipt_long_outlined,
          label: 'Create superbill',
          body: 'CPT + ICD-10 picker, CMS-1500-aligned PDF.',
          route: '/superbill'),
      _Action(
          icon: Icons.psychology_outlined,
          label: 'Send PHQ-9',
          body: 'Depression screener with severity bands.',
          route: '/assessments/phq9'),
      _Action(
          icon: Icons.spa_outlined,
          label: 'Send GAD-7',
          body: 'Anxiety screener with severity bands.',
          route: '/assessments/gad7'),
      _Action(
          icon: Icons.smart_toy_outlined,
          label: 'AI assistant',
          body: 'Chat with the clinical reasoning co-pilot.',
          route: '/ai_chatbot'),
      _Action(
          icon: Icons.help_outline,
          label: 'Help & docs',
          body: 'Setup guide, FAQ, security overview.',
          route: '/security'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          PsySpacing.xxl, PsySpacing.lg, PsySpacing.xxl, PsySpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick actions',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.lg),
          LayoutBuilder(
            builder: (ctx, c) {
              final cols = c.maxWidth >= PsyBreakpoints.lg
                  ? 3
                  : c.maxWidth >= PsyBreakpoints.sm
                      ? 2
                      : 1;
              final cardW =
                  (c.maxWidth - (cols - 1) * PsySpacing.lg) / cols;
              return Wrap(
                spacing: PsySpacing.lg,
                runSpacing: PsySpacing.lg,
                children: actions
                    .map((a) => SizedBox(
                          width: cardW,
                          child: _ActionTile(
                              action: a, theme: theme, cs: cs),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Action {
  _Action(
      {required this.icon,
      required this.label,
      required this.body,
      required this.route});
  final IconData icon;
  final String label;
  final String body;
  final String route;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(
      {required this.action, required this.theme, required this.cs});
  final _Action action;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(PsyRadius.lg),
        onTap: () => Navigator.of(context).pushNamed(action.route),
        child: Container(
          padding: const EdgeInsets.all(PsySpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PsyRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(PsyRadius.sm),
                ),
                child: Icon(action.icon, color: cs.primary, size: 20),
              ),
              const SizedBox(height: PsySpacing.lg),
              Text(action.label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: PsySpacing.xs),
              Text(action.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    height: 1.5,
                  )),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PsySpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent activity',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: PsySpacing.xxl, vertical: PsySpacing.xxxl),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(PsyRadius.lg),
              border: Border.all(color: cs.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.history_outlined,
                    color: cs.onSurface.withValues(alpha: 0.45),
                    size: 36),
                const SizedBox(height: PsySpacing.md),
                Text('No activity yet.',
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7))),
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
      ),
    );
  }
}
