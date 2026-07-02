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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/billing/subscription_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/mfa_local_repository.dart';
import '../../services/onboarding/onboarding_signals_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_empty_state.dart';
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
        DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(PsyRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: const PsyEmptyState(
            icon: Icons.history_outlined,
            title: 'No activity yet.',
            body:
                'Start a session or send a screener — entries will show up here.',
          ),
        ),
      ],
    );
  }
}

class SetupChecklist extends StatefulWidget {
  const SetupChecklist({super.key, this.mfaRepo, this.signalsRepo});

  /// Override for tests; production wires a default
  /// [MfaLocalRepository].
  final MfaLocalRepository? mfaRepo;

  /// Sprint 31 — PILAR activation stream (SOAP / MBC / no-show / TP).
  /// Defaults to a Firestore-backed implementation in production;
  /// tests inject a fake so the pillar milestones can be exercised
  /// without spinning up a real Firebase project.
  final OnboardingSignalsRepository? signalsRepo;

  @override
  State<SetupChecklist> createState() => _SetupChecklistState();
}

class _SetupChecklistState extends State<SetupChecklist> {
  late final MfaLocalRepository _mfaRepo =
      widget.mfaRepo ?? MfaLocalRepository();

  /// Cached so the StreamBuilder subscription doesn't restart on every
  /// parent rebuild (auth profile refresh, theme change, …).
  late final OnboardingSignalsRepository _signalsRepo =
      widget.signalsRepo ?? OnboardingSignalsRepository();

  @override
  void initState() {
    super.initState();
    unawaited(_mfaRepo.initialize());
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    // Live signals — Provider-watched so checking a step in another
    // tab flips the box without a refresh.
    final auth = context.watch<FirebaseAuthService?>();
    final subscription = context.watch<SubscriptionService?>();
    final profile = auth?.profile;
    final profileDone =
        profile != null &&
        profile.fullName.isNotEmpty &&
        profile.npi.isNotEmpty;
    final stripeDone = subscription?.isActive ?? false;

    return ValueListenableBuilder<DateTime?>(
      valueListenable: _mfaRepo.listenable,
      builder: (context, mfaAt, _) {
        final mfaDone = mfaAt != null;

        List<OnboardingChecklistItem> buildItems(OnboardingSignals signals) {
          return <OnboardingChecklistItem>[
            OnboardingChecklistItem(
              id: 'profile',
              label: 'Add your clinician profile',
              body: 'NPI, license, signature — feeds the superbill.',
              icon: Icons.badge_outlined,
              done: profileDone,
              onTap: () => nav.pushNamed('/settings/profile'),
            ),
            OnboardingChecklistItem(
              id: 'mfa',
              label: 'Enable two-factor authentication',
              body: 'TOTP + recovery codes. Required for ePHI under HIPAA.',
              icon: Icons.shield_outlined,
              done: mfaDone,
              onTap: () => nav.pushNamed('/settings/mfa'),
            ),
            OnboardingChecklistItem(
              id: 'stripe',
              label: 'Connect Stripe to take payments',
              body: 'Express onboarding · 5 minutes · KYC handled by Stripe.',
              icon: Icons.payments_outlined,
              done: stripeDone,
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
            // Sprint 31 — PILAR activation milestones. Each flips the
            // moment the audit collection sees its first row from
            // this clinic, so the box ticks itself without any
            // client-side write.
            OnboardingChecklistItem(
              id: 'first-soap',
              label: 'Draft your first SOAP note',
              body: 'Ambient scribe · 30 seconds · every claim cited.',
              icon: Icons.description_outlined,
              done: signals.hasSoapDraft,
              onTap: () => nav.pushNamed('/clinician/scribe'),
            ),
            OnboardingChecklistItem(
              id: 'first-mbc',
              label: 'Send your first between-session assessment',
              body: 'PHQ-9 · GAD-7 · a link the patient posts in seconds.',
              icon: Icons.assignment_turned_in_outlined,
              done: signals.hasMbcDispatch,
              onTap: () => nav.pushNamed('/clinician/mbc'),
            ),
            OnboardingChecklistItem(
              id: 'first-noshow',
              label: 'Score your first no-show risk',
              body: 'Tier + ROI + recovery playbook in one row.',
              icon: Icons.online_prediction,
              done: signals.hasNoShowPrediction,
              onTap: () => nav.pushNamed('/clinician/noshow'),
            ),
            OnboardingChecklistItem(
              id: 'first-tp',
              label: 'Draft your first treatment plan',
              body: 'CBT / EMDR / MI protocols · SMART goals inline.',
              icon: Icons.psychology_outlined,
              done: signals.hasTpPlan,
              onTap: () => nav.pushNamed('/clinician/tp-drafter'),
            ),
          ];
        }

        final clinicId = profile?.userId;
        if (clinicId == null || clinicId.isEmpty) {
          // Unauthenticated build (e.g. first-frame render before
          // auth resolves) — surface the local-signal milestones
          // only so the widget still paints without an empty state.
          return OnboardingChecklist(
            items: buildItems(const OnboardingSignals.empty()),
          );
        }

        return StreamBuilder<OnboardingSignals>(
          stream: _signalsRepo.watchAll(clinicId),
          initialData: const OnboardingSignals.empty(),
          builder: (context, snapshot) {
            final signals = snapshot.data ?? const OnboardingSignals.empty();
            return OnboardingChecklist(items: buildItems(signals));
          },
        );
      },
    );
  }
}
