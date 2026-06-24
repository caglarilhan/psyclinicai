/// Dashboard tile that surfaces the clinician's pinned patients
/// (PR #57 storage + PRs #58/#59 wiring) so a one-tap jump into a
/// pinned chart is on the home screen. Hidden when the pin set is
/// empty so the dashboard stays clean for first-run users.
///
/// Demo / no-Firebase mode renders the pinned count + a roster
/// link without demographic resolution — the underlying repository
/// is Firestore-backed and not available offline; this fallback
/// preserves utility without leaking placeholder copy.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../screens/patients/patient_list_screen.dart' show PatientDetailArgs;
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_pin_repository.dart';
import '../../services/data/patient_repository.dart';
import '../../theme/tokens.dart';
import '../ds/psy_card.dart';

class PinnedPatientsCard extends StatefulWidget {
  const PinnedPatientsCard({super.key, this.pinRepo});

  /// Override for tests; production wires a default
  /// [PatientPinRepository].
  final PatientPinRepository? pinRepo;

  @override
  State<PinnedPatientsCard> createState() => _PinnedPatientsCardState();
}

class _PinnedPatientsCardState extends State<PinnedPatientsCard> {
  late final PatientPinRepository _pinRepo =
      widget.pinRepo ?? PatientPinRepository();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _pinRepo.initialize();
    if (!mounted) return;
    setState(() => _ready = true);
  }

  void _openPatient(PatientDetailArgs args) {
    unawaited(
      Navigator.of(context).pushNamed('/patient/detail', arguments: args),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox.shrink();
    return ValueListenableBuilder<Set<String>>(
      valueListenable: _pinRepo.listenable,
      builder: (context, pinned, _) {
        if (pinned.isEmpty) return const SizedBox.shrink();
        return _CardBody(pinnedIds: pinned, onOpen: _openPatient);
      },
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.pinnedIds, required this.onOpen});

  final Set<String> pinnedIds;
  final void Function(PatientDetailArgs) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final header = Row(
      children: [
        Expanded(
          child: Text(
            'Pinned patients (${pinnedIds.length})',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/patients'),
          icon: const Icon(Icons.group_outlined, size: 18),
          label: const Text('Open roster'),
        ),
      ],
    );

    if (!PsyFirebase.isReady) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: PsySpacing.md),
          PsyCard(
            child: Padding(
              padding: const EdgeInsets.all(PsySpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.star, color: cs.primary),
                  const SizedBox(width: PsySpacing.md),
                  Expanded(
                    child: Text(
                      'Open the roster to view ${pinnedIds.length} pinned '
                      "patient${pinnedIds.length == 1 ? '' : 's'} (demo mode).",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: PsySpacing.md),
        StreamBuilder<List<PatientDoc>>(
          stream: PatientRepository.instance.watch(profile.clinicId),
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();
            final byId = {for (final p in snap.data!) p.id: p};
            final resolved = pinnedIds
                .map((id) => byId[id])
                .whereType<PatientDoc>()
                .take(3)
                .toList(growable: false);
            if (resolved.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final p in resolved)
                  Padding(
                    padding: const EdgeInsets.only(bottom: PsySpacing.sm),
                    child: _PinnedTile(
                      patient: p,
                      onTap: () =>
                          onOpen(PatientDetailArgs(id: p.id, name: p.fullName)),
                    ),
                  ),
                if (pinnedIds.length > resolved.length)
                  Padding(
                    padding: const EdgeInsets.only(top: PsySpacing.xs),
                    child: Text(
                      '+ ${pinnedIds.length - resolved.length} more pinned '
                      'on the roster.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PinnedTile extends StatelessWidget {
  const _PinnedTile({required this.patient, required this.onTap});

  final PatientDoc patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final initial = patient.fullName.isNotEmpty
        ? patient.fullName[0].toUpperCase()
        : '?';
    return PsyCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(PsySpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: cs.primaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.fullName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (patient.insurer.isNotEmpty ||
                      patient.memberId.isNotEmpty) ...[
                    const SizedBox(height: PsySpacing.xxs),
                    Text(
                      [
                        if (patient.insurer.isNotEmpty) patient.insurer,
                        if (patient.memberId.isNotEmpty)
                          'ID ${patient.memberId}',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.star, color: Color(0xFFD97706)),
            const SizedBox(width: PsySpacing.sm),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
