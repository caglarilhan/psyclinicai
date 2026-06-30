import 'package:flutter/material.dart';

import '../../services/treatment_plan_drafter/tp_drafter_catalog.dart';
import '../../services/treatment_plan_drafter/tp_drafter_client.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

/// `/clinician/tp-drafter` — Evidence-Based Treatment Plan Drafter.
///
/// MVP slice (PILAR 4 / PR-3): pick disorder + modality, list
/// presenting problems, generate, review SMART goals + session plan,
/// see the co-sign requirement banner when present.
class TpDrafterScreen extends StatefulWidget {
  const TpDrafterScreen({
    super.key,
    required this.client,
    required this.tenantId,
    this.initialPatientId,
  });

  final TpDrafterClient client;
  final String tenantId;
  final String? initialPatientId;

  @override
  State<TpDrafterScreen> createState() => _TpDrafterScreenState();
}

class _TpDrafterScreenState extends State<TpDrafterScreen> {
  TpDisorderId _disorder = TpDisorderId.majorDepressiveDisorder;
  TpModality _modality = TpModality.cbt;
  final TextEditingController _patientId = TextEditingController();
  final TextEditingController _problems = TextEditingController();
  final TextEditingController _context = TextEditingController();
  bool _drafting = false;
  String? _error;
  TpDraftedPlan? _draft;

  @override
  void initState() {
    super.initState();
    _patientId.text = widget.initialPatientId ?? '';
  }

  @override
  void dispose() {
    _patientId.dispose();
    _problems.dispose();
    _context.dispose();
    super.dispose();
  }

  void _onDisorderChanged(TpDisorderId d) {
    final mods = TpDrafterCatalog.modalitiesFor(d);
    setState(() {
      _disorder = d;
      _modality = mods.isNotEmpty ? mods.first : _modality;
    });
  }

  Future<void> _onDraft() async {
    if (_drafting) return;
    final problems = _problems.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (problems.isEmpty) {
      setState(() => _error = 'At least one presenting problem is required.');
      return;
    }
    setState(() {
      _drafting = true;
      _error = null;
    });
    try {
      final draft = await widget.client.draftPlan(
        tenantId: widget.tenantId,
        patientId:
            _patientId.text.trim().isEmpty ? null : _patientId.text.trim(),
        disorder: _disorder,
        modality: _modality,
        presentingProblems: problems,
        extraContext:
            _context.text.trim().isEmpty ? null : _context.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _draft = draft;
        _drafting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _drafting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AppShell(
      routeName: '/clinician/tp-drafter',
      title: 'Treatment plan drafter',
      subtitle:
          'Pick disorder + modality. Get a SMART-goal plan cited to '
          'the published guideline. Edit + sign before persisting.',
      breadcrumbs: const [
        Crumb('Clinician', '/dashboard'),
        Crumb('Treatment plan drafter', null),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _IntakeCard(
            theme: theme,
            cs: cs,
            disorder: _disorder,
            modality: _modality,
            onDisorderChanged: _onDisorderChanged,
            onModalityChanged: (m) => setState(() => _modality = m),
            patientId: _patientId,
            problems: _problems,
            extraContext: _context,
            drafting: _drafting,
            onDraft: _onDraft,
            error: _error,
          ),
          const SizedBox(height: PsySpacing.xl),
          if (_draft != null)
            _DraftPanel(theme: theme, cs: cs, draft: _draft!)
          else
            _EmptyState(theme: theme, cs: cs),
        ],
      ),
    );
  }
}

class _IntakeCard extends StatelessWidget {
  const _IntakeCard({
    required this.theme,
    required this.cs,
    required this.disorder,
    required this.modality,
    required this.onDisorderChanged,
    required this.onModalityChanged,
    required this.patientId,
    required this.problems,
    required this.extraContext,
    required this.drafting,
    required this.onDraft,
    required this.error,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final TpDisorderId disorder;
  final TpModality modality;
  final ValueChanged<TpDisorderId> onDisorderChanged;
  final ValueChanged<TpModality> onModalityChanged;
  final TextEditingController patientId;
  final TextEditingController problems;
  final TextEditingController extraContext;
  final bool drafting;
  final VoidCallback onDraft;
  final String? error;

  static String _disorderLabel(TpDisorderId d) {
    switch (d) {
      case TpDisorderId.majorDepressiveDisorder:
        return 'Major Depressive Disorder';
      case TpDisorderId.generalisedAnxietyDisorder:
        return 'Generalised Anxiety Disorder';
      case TpDisorderId.panicDisorder:
        return 'Panic Disorder';
      case TpDisorderId.socialAnxietyDisorder:
        return 'Social Anxiety Disorder';
      case TpDisorderId.ptsd:
        return 'PTSD';
      case TpDisorderId.ocd:
        return 'OCD';
      case TpDisorderId.borderlinePersonalityDisorder:
        return 'Borderline Personality Disorder';
      case TpDisorderId.bingEatingDisorder:
        return 'Binge-Eating Disorder';
      case TpDisorderId.alcoholUseDisorder:
        return 'Alcohol Use Disorder';
      case TpDisorderId.insomniaDisorder:
        return 'Insomnia Disorder';
    }
  }

  @override
  Widget build(BuildContext context) {
    final modalities = TpDrafterCatalog.modalitiesFor(disorder);
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Plan intake', style: theme.textTheme.titleMedium),
          const SizedBox(height: PsySpacing.md),
          Wrap(
            spacing: PsySpacing.md,
            runSpacing: PsySpacing.md,
            children: [
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<TpDisorderId>(
                  isExpanded: true,
                  initialValue: disorder,
                  decoration: const InputDecoration(labelText: 'Disorder'),
                  items: [
                    for (final d in TpDisorderId.values)
                      DropdownMenuItem(
                        value: d,
                        child: Text(_disorderLabel(d),
                            overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) onDisorderChanged(v);
                  },
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<TpModality>(
                  isExpanded: true,
                  initialValue: modalities.contains(modality)
                      ? modality
                      : modalities.first,
                  decoration: const InputDecoration(labelText: 'Modality'),
                  items: [
                    for (final m in modalities)
                      DropdownMenuItem(
                        value: m,
                        child: Text(m.name.toUpperCase()),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null) onModalityChanged(v);
                  },
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: patientId,
                  decoration: const InputDecoration(
                    labelText: 'Patient id (optional)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: problems,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Presenting problems (one per line)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          TextField(
            controller: extraContext,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Additional context (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(error!,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.error)),
          ],
          const SizedBox(height: PsySpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: drafting ? null : onDraft,
              icon: drafting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(drafting ? 'Drafting…' : 'Draft plan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PsySpacing.xl),
        child: Column(
          children: [
            Icon(Icons.checklist_outlined, size: 48, color: cs.outline),
            const SizedBox(height: PsySpacing.md),
            Text('No draft yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: PsySpacing.xs),
            Text(
              'Pick a disorder + modality, list the presenting problems, '
              'and tap Draft plan. Every SMART goal will cite the '
              'published guideline so you can review before signing.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftPanel extends StatelessWidget {
  const _DraftPanel({
    required this.theme,
    required this.cs,
    required this.draft,
  });
  final ThemeData theme;
  final ColorScheme cs;
  final TpDraftedPlan draft;

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(draft.protocolLabel,
                  style: theme.textTheme.titleMedium),
              const SizedBox(width: PsySpacing.md),
              PsyBadge(
                label: 'Schema v${draft.schemaVersion} · ${draft.provider}',
              ),
              const Spacer(),
              if (draft.phiRedactions > 0)
                PsyBadge(
                  label: '${draft.phiRedactions} PHI redacted',
                  tone: PsyBadgeTone.info,
                ),
            ],
          ),
          if (draft.requiresSupervisorCoSign) ...[
            const SizedBox(height: PsySpacing.md),
            Container(
              padding: const EdgeInsets.all(PsySpacing.md),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_late_outlined,
                      color: cs.onErrorContainer),
                  const SizedBox(width: PsySpacing.sm),
                  Expanded(
                    child: Text(
                      'Supervisor co-sign required before this plan can '
                      'persist to the patient record.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: PsySpacing.md),
          _Section(
            theme: theme,
            title: 'Presenting problems',
            children: draft
                .presentingProblems()
                .map((p) => Text('• $p'))
                .toList(),
          ),
          _Section(
            theme: theme,
            title: 'SMART goals',
            children: [
              for (final g in draft.smartGoals())
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((g['goal_text'] as String? ?? '').trim(),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        'S: ${g['specific'] ?? ''}\n'
                        'M: ${g['measurable'] ?? ''}\n'
                        'A: ${g['achievable'] ?? ''}\n'
                        'R: ${g['relevant'] ?? ''}\n'
                        'T: ${g['time_bound'] ?? ''}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (g['cited_guideline'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: PsyBadge(
                            label: 'cite: ${g['cited_guideline']}',
                            tone: PsyBadgeTone.info,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          _Section(
            theme: theme,
            title: 'Session-by-session plan',
            children: [
              for (final s in draft.sessionPlan())
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '#${s['session_index']}: ${s['focus']} — '
                    '${(s['interventions'] as List?)?.join(", ") ?? ""}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
          _Section(
            theme: theme,
            title: 'Risk review cadence',
            children: [Text(draft.riskReviewCadence())],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.theme,
    required this.title,
    required this.children,
  });
  final ThemeData theme;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PsySpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }
}
