import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_filter.dart';
import '../../services/data/patient_pin_repository.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../theme/tokens.dart';
import '../../utils/time_format.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';
import '../../widgets/ds/psy_empty_state.dart';
import '../../widgets/ds/psy_skeleton.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/patient_list_filter_bar.dart';

/// `/patients` — searchable patient roster.
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  static const int _pageSize = 50;
  static const Duration _searchDebounce = Duration(milliseconds: 250);

  final _searchCtrl = TextEditingController();
  String _query = '';
  Timer? _searchTimer;
  PatientFilter _filter = PatientFilter.empty;
  int _visibleCount = _pageSize;

  final PatientPinRepository _pinRepo = PatientPinRepository();

  @override
  void initState() {
    super.initState();
    unawaited(_pinRepo.initialize());
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _togglePin(String patientId) async {
    await _pinRepo.toggle(patientId);
  }

  void _onQueryChanged(String v) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () {
      if (!mounted) return;
      setState(() {
        _query = v.trim();
        _visibleCount = _pageSize;
      });
      unawaited(
        TelemetryService.instance.capture(
          'patient_list.search',
          properties: {'has_query': _query.isNotEmpty},
        ),
      );
    });
  }

  void _loadMore() {
    setState(() => _visibleCount += _pageSize);
    unawaited(
      TelemetryService.instance.capture(
        'patient_list.load_more',
        properties: {'visible': _visibleCount},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppShell(
      routeName: '/patients',
      title: 'Patients',
      subtitle: 'Search the roster, open a chart, or add a new patient.',
      primaryAction: PsyButton(
        label: 'Add patient',
        icon: Icons.person_add_alt_1,
        onPressed: _openAddPatient,
      ),
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: _onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search by name, member ID, or insurer…',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          PatientListFilterBar(
            filter: _filter,
            onChanged: (f) => setState(() {
              _filter = f;
              _visibleCount = _pageSize;
            }),
          ),
          const SizedBox(height: PsySpacing.lg),
          Expanded(child: _list(context, theme, cs)),
        ],
      ),
    );
  }

  Widget _list(BuildContext context, ThemeData theme, ColorScheme cs) {
    if (!PsyFirebase.isReady) {
      return _demoList(theme, cs);
    }
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) {
      return _emptyState(
        icon: Icons.lock_outline,
        title: 'Sign in to see patients',
        body: 'Your roster lives in your tenant — log in to load it.',
      );
    }
    return StreamBuilder<List<PatientDoc>>(
      stream: PatientRepository.instance.watch(profile.clinicId),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          // Skeleton list mirrors the real _PatientTile shape so the
          // page layout is stable across the loading → loaded
          // transition. No jarring spinner → row jump.
          return PsySkeletonList(
            itemBuilder: (_) => const _PatientTileSkeleton(),
          );
        }
        if (snap.hasError) {
          return _emptyState(
            icon: Icons.error_outline,
            title: 'Could not load patients',
            body: snap.error.toString(),
          );
        }
        final patients = (snap.data ?? const <PatientDoc>[])
            .where(_match)
            .toList(growable: false);
        if (patients.isEmpty) {
          return _emptyState(
            icon: Icons.group_outlined,
            title: _query.isEmpty
                ? 'No patients yet'
                : 'No matches for "$_query"',
            body: _query.isEmpty
                ? 'Add your first patient to get started.'
                : 'Try a different keyword or clear the search.',
            action: _query.isEmpty
                ? PsyEmptyStateAction(
                    label: 'Add patient',
                    icon: Icons.person_add_alt_1,
                    onTap: _openAddPatient,
                  )
                : null,
          );
        }
        return ValueListenableBuilder<Set<String>>(
          valueListenable: _pinRepo.listenable,
          builder: (context, pinned, _) {
            // Pinned first (their relative order preserved by the
            // underlying stream), unpinned next.
            final pinnedSlice = patients
                .where((p) => pinned.contains(p.id))
                .toList(growable: false);
            final restSlice = patients
                .where((p) => !pinned.contains(p.id))
                .toList(growable: false);
            final ordered = <PatientDoc>[...pinnedSlice, ...restSlice];
            final total = ordered.length;
            final visible = total <= _visibleCount ? total : _visibleCount;
            final hasMore = visible < total;
            final shown = ordered.take(visible).toList(growable: false);
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: PsySpacing.lg),
              itemCount: shown.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: PsySpacing.md),
              itemBuilder: (_, i) {
                if (i == shown.length) {
                  return _ResultFooter(
                    visible: visible,
                    total: total,
                    hasMore: hasMore,
                    onLoadMore: _loadMore,
                  );
                }
                return _PatientTile(
                  patient: shown[i],
                  pinned: pinned.contains(shown[i].id),
                  onOpen: () => _openDetail(shown[i].id, shown[i].fullName),
                  onTogglePin: () => _togglePin(shown[i].id),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _demoList(ThemeData theme, ColorScheme cs) {
    const demos = <_DemoPatient>[
      _DemoPatient(
        id: 'demo-1',
        name: 'John Demo',
        insurer: 'BCBS',
        memberId: 'BCBS-INS-001',
        lastSeen: 'Yesterday',
        tone: PsyBadgeTone.brand,
        status: 'Active',
      ),
      _DemoPatient(
        id: 'demo-2',
        name: 'Maria Sample',
        insurer: 'Aetna',
        memberId: 'AET-9981-002',
        lastSeen: 'Last week',
        tone: PsyBadgeTone.success,
        status: 'Stable',
      ),
      _DemoPatient(
        id: 'demo-3',
        name: 'Sven Müller',
        insurer: 'TK',
        memberId: 'TK-EU-301',
        lastSeen: '3 weeks ago',
        tone: PsyBadgeTone.warning,
        status: 'Follow-up',
      ),
    ];
    final filtered = demos
        .where((d) {
          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            final matchQuery =
                d.name.toLowerCase().contains(q) ||
                d.memberId.toLowerCase().contains(q) ||
                d.insurer.toLowerCase().contains(q);
            if (!matchQuery) return false;
          }
          if (_filter.statuses.isNotEmpty) {
            final statusId = d.status.toLowerCase().replaceAll(
              RegExp(r'\s+'),
              '-',
            );
            final matchStatus = _filter.statuses.any(
              (s) => s.id == statusId || s.name == statusId,
            );
            if (!matchStatus) return false;
          }
          if (_filter.risks.isNotEmpty) {
            final risk = d.tone == PsyBadgeTone.warning
                ? PatientRiskFilter.medium
                : (d.tone == PsyBadgeTone.danger
                      ? PatientRiskFilter.high
                      : PatientRiskFilter.low);
            if (!_filter.risks.contains(risk)) return false;
          }
          return true;
        })
        .toList(growable: false);
    if (filtered.isEmpty) {
      return _emptyState(
        icon: Icons.search_off,
        title: 'No matches for "$_query"',
        body: 'Try a different keyword.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.lg),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: PsySpacing.md),
      itemBuilder: (_, i) => PsyCard(
        onTap: () => _openDetail(filtered[i].id, filtered[i].name),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: cs.primaryContainer,
              child: Text(
                filtered[i].name[0],
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: PsySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    filtered[i].name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: PsySpacing.xxs),
                  Text(
                    '${filtered[i].insurer} · ${filtered[i].memberId} · last seen ${filtered[i].lastSeen}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            PsyBadge(label: filtered[i].status, tone: filtered[i].tone),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String body,
    PsyEmptyStateAction? action,
  }) {
    return PsyEmptyState(icon: icon, title: title, body: body, action: action);
  }

  bool _match(PatientDoc p) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return p.fullName.toLowerCase().contains(q) ||
        p.memberId.toLowerCase().contains(q) ||
        p.insurer.toLowerCase().contains(q);
  }

  Future<void> _openAddPatient() async {
    final nameCtrl = TextEditingController();
    final insurerCtrl = TextEditingController();
    final memberCtrl = TextEditingController();
    try {
      await _addPatientFlow(nameCtrl, insurerCtrl, memberCtrl);
    } finally {
      nameCtrl.dispose();
      insurerCtrl.dispose();
      memberCtrl.dispose();
    }
  }

  Future<void> _addPatientFlow(
    TextEditingController nameCtrl,
    TextEditingController insurerCtrl,
    TextEditingController memberCtrl,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add patient'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: PsySpacing.md),
              TextField(
                controller: insurerCtrl,
                decoration: const InputDecoration(labelText: 'Insurer'),
              ),
              const SizedBox(height: PsySpacing.md),
              TextField(
                controller: memberCtrl,
                decoration: const InputDecoration(labelText: 'Member ID'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          PsyButton(
            label: 'Add',
            size: PsyButtonSize.sm,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (saved != true) return;
    if (nameCtrl.text.trim().isEmpty) return;

    if (!PsyFirebase.isReady) {
      if (!mounted) return;
      PsySnack.warning(
        context,
        'Demo mode — "${nameCtrl.text}" not persisted. Configure Firebase to save.',
        hint: 'patient_list.add_demo_no_persist',
      );
      return;
    }
    final profile = FirebaseAuthService.instance.profile;
    if (profile == null) return;
    final draft = PatientDraft(
      fullName: nameCtrl.text.trim(),
      insurer: insurerCtrl.text.trim(),
      memberId: memberCtrl.text.trim(),
    );
    try {
      await PatientRepository.instance.create(profile.clinicId, draft);
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'patient_list.add_failed',
        ),
      );
      if (!mounted) return;
      PsySnack.error(
        context,
        'Could not add patient — please retry.',
        hint: 'patient_list.add_failed',
      );
    }
  }

  void _openDetail(String patientId, String patientName) {
    unawaited(
      Navigator.of(context).pushNamed(
        '/patient/detail',
        arguments: PatientDetailArgs(id: patientId, name: patientName),
      ),
    );
  }
}

class _DemoPatient {
  const _DemoPatient({
    required this.id,
    required this.name,
    required this.insurer,
    required this.memberId,
    required this.lastSeen,
    required this.tone,
    required this.status,
  });
  final String id;
  final String name;
  final String insurer;
  final String memberId;
  final String lastSeen;
  final PsyBadgeTone tone;
  final String status;
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({
    required this.patient,
    required this.onOpen,
    this.pinned = false,
    this.onTogglePin,
  });
  final PatientDoc patient;
  final VoidCallback onOpen;
  final bool pinned;
  final VoidCallback? onTogglePin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final initial = patient.fullName.isNotEmpty
        ? patient.fullName[0].toUpperCase()
        : '?';
    final updated = patient.createdAt;
    return PsyCard(
      onTap: onOpen,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer,
            child: Text(
              initial,
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: PsySpacing.xxs),
                Text(
                  [
                    if (patient.insurer.isNotEmpty) patient.insurer,
                    if (patient.memberId.isNotEmpty) 'ID ${patient.memberId}',
                    if (updated != null)
                      'added ${TimeFormat.relativeDay(updated)}',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (onTogglePin != null)
            IconButton(
              tooltip: pinned ? 'Unpin' : 'Pin to top',
              onPressed: onTogglePin,
              icon: Icon(
                pinned ? Icons.star : Icons.star_outline,
                color: pinned
                    ? const Color(0xFFD97706)
                    : cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// Args passed from list → detail.
class PatientDetailArgs {
  const PatientDetailArgs({required this.id, required this.name});
  final String id;
  final String name;
}

/// Result-count + "Load more" footer for the patient list. Always
/// renders the "showing X of Y" line so the clinician knows the page
/// is capped; the button only appears while more rows remain.
class _ResultFooter extends StatelessWidget {
  const _ResultFooter({
    required this.visible,
    required this.total,
    required this.hasMore,
    required this.onLoadMore,
  });

  final int visible;
  final int total;
  final bool hasMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              'Showing $visible of $total',
              style: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
          if (hasMore) ...[
            const SizedBox(height: PsySpacing.sm),
            Center(
              child: OutlinedButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more, size: 18),
                label: const Text('Load more'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Placeholder row that mirrors [_PatientTile]'s layout so the page
/// doesn't flicker when StreamBuilder flips waiting → data. Sits
/// inside a [PsyCard] and pulses with its enclosing
/// [PsySkeletonGroup] (inserted by [PsySkeletonList]).
class _PatientTileSkeleton extends StatelessWidget {
  const _PatientTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const PsyCard(
      child: Row(
        children: [
          PsySkeletonCircle(size: 44),
          SizedBox(width: PsySpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PsySkeletonLine(width: 180, height: 16),
                SizedBox(height: 8),
                PsySkeletonLine(width: 240, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
