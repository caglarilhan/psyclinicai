/// `/settings/pinned` — management screen for the per-device pin
/// set. Surfaces every pinned id with an Unpin button + a bulk
/// "Unpin all" action so a clinician can clear the roster favourites
/// without star-tapping each row individually.
///
/// Resolves patient names via [PatientRepository] when Firebase is
/// ready; falls back to opaque ids in demo mode so the surface stays
/// useful for testing.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_pin_repository.dart';
import '../../services/data/patient_repository.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;

class PinnedPatientsScreen extends StatefulWidget {
  const PinnedPatientsScreen({super.key, this.repo});

  /// Override for tests; production wires a default
  /// [PatientPinRepository].
  final PatientPinRepository? repo;

  @override
  State<PinnedPatientsScreen> createState() => _PinnedPatientsScreenState();
}

class _PinnedPatientsScreenState extends State<PinnedPatientsScreen> {
  late final PatientPinRepository _repo = widget.repo ?? PatientPinRepository();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _repo.initialize();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _unpinAll(Set<String> ids) async {
    for (final id in ids) {
      await _repo.unpin(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/settings',
      title: 'Pinned patients',
      subtitle:
          'Per-device favourites — pinned rows float to the top of the roster.',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Settings', '/settings'),
        Crumb('Pinned patients', null),
      ],
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<Set<String>>(
              valueListenable: _repo.listenable,
              builder: (context, pinned, _) {
                if (pinned.isEmpty) {
                  return PsyEmptyState(
                    icon: Icons.star_outline,
                    title: 'No pinned patients',
                    body:
                        'Tap the star on a patient tile or chart to pin them '
                        'to the top of the roster.',
                    action: PsyEmptyStateAction(
                      label: 'Open roster',
                      icon: Icons.group_outlined,
                      onTap: () => Navigator.of(context).pushNamed('/patients'),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${pinned.length} pinned',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (pinned.length >= 2)
                          OutlinedButton.icon(
                            onPressed: () => unawaited(_unpinAll(pinned)),
                            icon: const Icon(Icons.star_border, size: 18),
                            label: const Text('Unpin all'),
                          ),
                      ],
                    ),
                    const SizedBox(height: PsySpacing.md),
                    if (PsyFirebase.isReady)
                      _FirestoreList(pinned: pinned, repo: _repo)
                    else
                      _OfflineList(pinned: pinned, repo: _repo),
                  ],
                );
              },
            ),
    );
  }
}

class _FirestoreList extends StatelessWidget {
  const _FirestoreList({required this.pinned, required this.repo});

  final Set<String> pinned;
  final PatientPinRepository repo;

  @override
  Widget build(BuildContext context) {
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return _OfflineList(pinned: pinned, repo: repo);
    }
    return StreamBuilder<List<PatientDoc>>(
      stream: PatientRepository.instance.watch(profile.clinicId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final byId = {for (final p in snap.data!) p.id: p};
        final rows = pinned
            .map((id) {
              final patient = byId[id];
              return _Row(
                key: ValueKey(id),
                id: id,
                name: patient?.fullName,
                onOpen: patient == null
                    ? null
                    : () => Navigator.of(context).pushNamed(
                        '/patient/detail',
                        arguments: PatientDetailArgs(
                          id: patient.id,
                          name: patient.fullName,
                        ),
                      ),
                onUnpin: () => unawaited(repo.unpin(id)),
              );
            })
            .toList(growable: false);
        return Column(
          children: [
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: PsySpacing.sm),
                child: r,
              ),
          ],
        );
      },
    );
  }
}

class _OfflineList extends StatelessWidget {
  const _OfflineList({required this.pinned, required this.repo});

  final Set<String> pinned;
  final PatientPinRepository repo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final id in pinned)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.sm),
            child: _Row(
              key: ValueKey(id),
              id: id,
              name: null,
              onOpen: null,
              onUnpin: () => unawaited(repo.unpin(id)),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.id,
    required this.name,
    required this.onOpen,
    required this.onUnpin,
  });

  final String id;
  final String? name;
  final VoidCallback? onOpen;
  final VoidCallback onUnpin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final display = name ?? id;
    final initial = display.isNotEmpty ? display[0].toUpperCase() : '?';
    return PsyCard(
      onTap: onOpen,
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
                    display,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (name != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Patient id $id',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Unpin',
              onPressed: onUnpin,
              icon: const Icon(Icons.star, color: Color(0xFFD97706)),
            ),
          ],
        ),
      ),
    );
  }
}
