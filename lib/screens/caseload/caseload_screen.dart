import 'package:flutter/material.dart';

import '../../services/caseload_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/homework_repository.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/safety_plan_repository.dart';
import '../../services/treatment_plan_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../patients/patient_list_screen.dart' show PatientDetailArgs;

/// `/caseload` — proactive "who needs attention now" view across the whole
/// caseload. Aggregates overdue homework, stalled treatment plans, and missing
/// safety plans so the clinician triages without opening every chart.
class CaseloadScreen extends StatefulWidget {
  const CaseloadScreen({super.key});

  @override
  State<CaseloadScreen> createState() => _CaseloadScreenState();
}

class _CaseloadScreenState extends State<CaseloadScreen> {
  static const _demoNames = <String, String>{
    'demo-1': 'John Demo',
    'demo-2': 'Maria Sample',
    'demo-3': 'Sven Müller',
  };

  final _homework = HomeworkRepository();
  final _plans = TreatmentPlanService();
  final _safety = SafetyPlanRepository();
  final _service = const CaseloadService();

  bool _loading = true;
  List<CaseloadAttention> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _homework.initialize();
    await _plans.initialize();
    await _safety.initialize();

    final names = Map<String, String>.from(_demoNames);
    if (PsyFirebase.isReady) {
      final profile = FirebaseAuthService.instance.profile;
      if (profile != null) {
        try {
          final docs = await PatientRepository.instance
              .watch(profile.clinicId)
              .first
              .timeout(const Duration(seconds: 5));
          for (final d in docs) {
            names[d.id] = d.fullName;
          }
        } catch (_) {
          // best-effort — fall back to ids/demo names
        }
      }
    }

    final items = _service.compute(
      names: names,
      homework: _homework.all,
      plans: _plans.allPlans,
      safetyPlans: _safety.all,
    );
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppShell(
      routeName: '/caseload',
      title: 'Caseload attention',
      subtitle: _loading
          ? null
          : '${_items.length} ${_items.length == 1 ? 'patient needs' : 'patients need'} attention',
      breadcrumbs: const [
        Crumb('Home', '/dashboard'),
        Crumb('Caseload attention', null),
      ],
      child: _loading
          ? const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()))
          : _items.isEmpty
              ? _AllClear(theme: theme)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Triaged across your caseload — overdue work, stalled '
                      'plans, and missing safety plans. Decision-support, not '
                      'an alert system.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: PsySpacing.xl),
                    ..._items.map((a) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: PsySpacing.md),
                          child: _AttentionCard(
                            item: a,
                            onOpen: () => Navigator.of(context).pushNamed(
                              '/patient/detail',
                              arguments: PatientDetailArgs(
                                  id: a.patientId, name: a.patientName),
                            ),
                          ),
                        )),
                    const SizedBox(height: PsySpacing.huge),
                  ],
                ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.item, required this.onOpen});
  final CaseloadAttention item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = _levelColor(item.level, cs);
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(PsySpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(PsyRadius.lg),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(width: 4, height: 44, color: accent),
            const SizedBox(width: PsySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.patientName,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: PsySpacing.sm),
                  Wrap(
                    spacing: PsySpacing.sm,
                    runSpacing: PsySpacing.xs,
                    children: item.reasons
                        .map((r) => _ReasonChip(reason: r))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: PsySpacing.md),
            Icon(Icons.chevron_right,
                color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({required this.reason});
  final AttentionReason reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final c = _levelColor(reason.level, cs);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: PsySpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(PsyRadius.full),
        border: Border.all(color: c.withValues(alpha: 0.30)),
      ),
      child: Text(reason.label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: c, fontWeight: FontWeight.w600)),
    );
  }
}

class _AllClear extends StatelessWidget {
  const _AllClear({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: cs.primary),
            const SizedBox(height: PsySpacing.md),
            Text('All clear',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: PsySpacing.xs),
            Text('No patients need attention right now.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: PsySpacing.lg),
            Wrap(
              spacing: PsySpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/patients'),
                  icon: const Icon(Icons.group_outlined),
                  label: const Text('Open roster'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/appointments'),
                  icon: const Icon(Icons.event),
                  label: const Text('Schedule a session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color _levelColor(AttentionLevel level, ColorScheme cs) => switch (level) {
      AttentionLevel.high => cs.error,
      AttentionLevel.medium => const Color(0xFFD97706), // amber-600
      AttentionLevel.low => cs.primary,
    };
