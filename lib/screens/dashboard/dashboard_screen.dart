import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth/clinician_role.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/dashboard/open_risk_signals_card.dart';
import '../../widgets/dashboard/pinned_patients_card.dart';
import '../../widgets/dashboard/recent_audit_tile.dart';
import '../../widgets/ds/psy_reveal.dart';
import '../../widgets/whats_new_sheet.dart';
import 'dashboard_actions.dart';
import 'dashboard_kpis.dart';
import 'dashboard_sections.dart';

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
      child: _WhatsNewOnMount(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile?.role.label != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: RoleChip(
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
              DemoBanner(cs: cs, theme: theme),
              const SizedBox(height: PsySpacing.xl),
            ],
            PsyReveal(
              child: KpiRow(theme: theme, cs: cs),
            ),
            const SizedBox(height: PsySpacing.xxl),
            const PsyReveal(
              delay: Duration(milliseconds: 40),
              child: SetupChecklist(),
            ),
            const SizedBox(height: PsySpacing.xxl),
            PsyReveal(
              delay: const Duration(milliseconds: 80),
              child: QuickActions(theme: theme, cs: cs),
            ),
            const SizedBox(height: PsySpacing.xxl),
            const PsyReveal(
              delay: Duration(milliseconds: 100),
              child: PinnedPatientsCard(),
            ),
            const SizedBox(height: PsySpacing.xxl),
            const PsyReveal(
              delay: Duration(milliseconds: 120),
              child: OpenRiskSignalsCard(),
            ),
            const SizedBox(height: PsySpacing.xxl),
            PsyReveal(
              delay: const Duration(milliseconds: 140),
              child: RecentAuditTile(actor: profile?.email),
            ),
            const SizedBox(height: PsySpacing.xxl),
            PsyReveal(
              delay: const Duration(milliseconds: 160),
              child: RecentActivity(theme: theme, cs: cs),
            ),
          ],
        ),
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

/// Fires [maybeShowWhatsNew] exactly once when the dashboard mounts.
/// Kept private so the side-effect lives next to the screen that
/// uses it; promote it later if a second surface needs the same
/// "open this sheet on first frame" pattern.
class _WhatsNewOnMount extends StatefulWidget {
  const _WhatsNewOnMount({required this.child});
  final Widget child;

  @override
  State<_WhatsNewOnMount> createState() => _WhatsNewOnMountState();
}

class _WhatsNewOnMountState extends State<_WhatsNewOnMount> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Fire-and-forget. The helper itself guards against re-shows.
      unawaited(maybeShowWhatsNew(context));
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
