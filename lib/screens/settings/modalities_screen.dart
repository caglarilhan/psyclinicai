/// `/settings/modalities` — per-clinician modality enablement.
///
/// Each row is a modality (CBT / DBT / EMDR). The toggle stores
/// the preference even when the tier is Free, but the session-
/// screen picker only surfaces modalities where
/// `ModalityPreferences.isEnabled` returns true — i.e. tier == Pro
/// AND enabled. We pre-store the choice so an upgrade flips it on
/// automatically; nobody has to "remember to toggle" after
/// upgrading.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/modality_preferences.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/modality_preferences_repository.dart';
import '../../services/data/modality_session_repository.dart' show ModalityKind;
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/ds/saving_indicator.dart';

class ModalitiesScreen extends StatefulWidget {
  const ModalitiesScreen({super.key, this.repository});

  /// Injected for tests; default real repo with on-device persistence.
  final ModalityPreferencesRepository? repository;

  @override
  State<ModalitiesScreen> createState() => _ModalitiesScreenState();
}

class _ModalitiesScreenState extends State<ModalitiesScreen> {
  late final ModalityPreferencesRepository _repo;
  late final SavingIndicatorController _saveCtrl;
  ModalityPreferences? _prefs;
  bool _loading = true;

  String get _clinicianId =>
      FirebaseAuthService.instance.profile?.userId ?? 'demo_clinician';

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ModalityPreferencesRepository();
    _saveCtrl = SavingIndicatorController();
    unawaited(_load());
  }

  @override
  void dispose() {
    _saveCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() {
      _prefs = _repo.forClinician(_clinicianId);
      _loading = false;
    });
  }

  Future<void> _toggle(ModalityKind k) async {
    final current = _prefs;
    if (current == null) return;
    final next = current.toggle(k);
    setState(() => _prefs = next);
    _saveCtrl.startSaving();
    try {
      await _repo.save(next);
      _saveCtrl.markSaved();
      unawaited(
        TelemetryService.instance.capture(
          'modality_preferences.toggled',
          properties: {'kind': k.id, 'enabled': next.isEnabled(k)},
        ),
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'modality_preferences.toggle_failed',
        ),
      );
      _saveCtrl.markError(onRetry: () => _toggle(k));
      if (mounted) {
        PsySnack.error(
          context,
          'Could not save preference — please retry.',
          hint: 'modality_preferences.toggle_failed',
        );
      }
    }
  }

  Future<void> _upgradeToPro() async {
    final current = _prefs;
    if (current == null) return;
    // Local-only stub: in production this routes through Stripe and
    // the webhook flips the tier server-side. For the local-first
    // build we set the tier optimistically so the rest of the UX
    // unblocks; webhook-driven reconciliation runs in Sprint 28+.
    final next = current.copyWith(tier: ModalityTier.pro);
    setState(() => _prefs = next);
    await _repo.save(next);
    unawaited(
      TelemetryService.instance.capture(
        'modality_preferences.tier_upgraded_local',
      ),
    );
    if (mounted) {
      PsySnack.success(
        context,
        'Pro tier active — your enabled modalities are live.',
        hint: 'modality_preferences.upgrade',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/settings',
      title: 'Modalities',
      subtitle:
          'Pick which modality-specific session templates you want to '
          'use. CBT / DBT / EMDR require the Pro tier.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Modalities', null),
      ],
      primaryAction: SavingIndicator(controller: _saveCtrl),
      scrollable: false,
      child: _loading || _prefs == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.zero,
              children: [
                _TierCard(prefs: _prefs!, onUpgrade: _upgradeToPro),
                const SizedBox(height: PsySpacing.xl),
                _ModalityRow(
                  kind: ModalityKind.cbt,
                  label: 'CBT — Beck/Padesky Thought Record',
                  blurb:
                      'Seven-column model. Surfaces automatic thoughts + '
                      "tagged distortions (Burns' 10) and tracks the "
                      'intensity delta before/after the cognitive work.',
                  prefs: _prefs!,
                  onToggle: () => _toggle(ModalityKind.cbt),
                ),
                _ModalityRow(
                  kind: ModalityKind.dbt,
                  label: 'DBT — Linehan Diary Card',
                  blurb:
                      'Seven-day card. Target behaviours (SI / NSSI / TIB), '
                      "Linehan's 6 emotions 0-5, and the 15 DBT skills "
                      'across the four modules.',
                  prefs: _prefs!,
                  onToggle: () => _toggle(ModalityKind.dbt),
                ),
                _ModalityRow(
                  kind: ModalityKind.emdr,
                  label: 'EMDR — Shapiro 8-Phase Tracker',
                  blurb:
                      'NC/PC/VOC/SUDS/Body assessment + BLS-set log + '
                      'abreaction safety gate. Closure is blocked until '
                      'the stabilising resource is recorded.',
                  prefs: _prefs!,
                  onToggle: () => _toggle(ModalityKind.emdr),
                ),
                _ModalityRow(
                  kind: ModalityKind.family,
                  label: 'Family — McGoldrick / Bowen / Structural',
                  blurb:
                      'Approach picker (Bowen / structural / strategic / '
                      'narrative / EFT / systemic), subsystem focus, '
                      'attendees + optional genogram link, 0-10 '
                      'relational-shift slider.',
                  prefs: _prefs!,
                  onToggle: () => _toggle(ModalityKind.family),
                ),
                const SizedBox(height: PsySpacing.xl),
                _Footnote(),
              ],
            ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({required this.prefs, required this.onUpgrade});
  final ModalityPreferences prefs;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isPro = prefs.tier == ModalityTier.pro;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return PsyCard(
      tinted: true,
      child: Row(
        children: [
          Icon(
            isPro ? Icons.workspace_premium : Icons.lock_outline,
            color: isPro ? cs.primary : cs.onSurface.withValues(alpha: 0.65),
          ),
          const SizedBox(width: PsySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isPro ? 'Pro tier' : 'Free tier',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: PsySpacing.sm),
                    PsyBadge(
                      label: isPro ? 'Active' : 'Standard only',
                      tone: isPro ? PsyBadgeTone.success : PsyBadgeTone.brand,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isPro
                      ? 'CBT / DBT / EMDR templates are live across the '
                            'session screen.'
                      : 'Upgrade to surface CBT / DBT / EMDR templates in '
                            'the session picker.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (!isPro)
            FilledButton.icon(
              onPressed: onUpgrade,
              icon: const Icon(Icons.upgrade, size: 18),
              label: const Text('Upgrade'),
            ),
        ],
      ),
    );
  }
}

class _ModalityRow extends StatelessWidget {
  const _ModalityRow({
    required this.kind,
    required this.label,
    required this.blurb,
    required this.prefs,
    required this.onToggle,
  });
  final ModalityKind kind;
  final String label;
  final String blurb;
  final ModalityPreferences prefs;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final enabled = prefs.enabled.contains(kind);
    final live = prefs.isEnabled(kind);
    return Padding(
      padding: const EdgeInsets.only(bottom: PsySpacing.md),
      child: PsyCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: PsySpacing.sm),
                      if (live)
                        const PsyBadge(
                          label: 'Live',
                          tone: PsyBadgeTone.success,
                        )
                      else if (enabled)
                        const PsyBadge(
                          label: 'Pending Pro',
                          tone: PsyBadgeTone.warning,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    blurb,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: enabled, onChanged: (_) => onToggle()),
          ],
        ),
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Why a Pro tier? CBT/DBT/EMDR templates ship with clinical-fidelity '
      'detail (Burns 10 distortions, Linehan 15 skills, Shapiro 8 phases) '
      'that we license, support, and keep current. The Standard SOAP/DAP/'
      'BIRP path stays free for everyone.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
        height: 1.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
