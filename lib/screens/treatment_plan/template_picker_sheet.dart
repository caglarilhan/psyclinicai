/// BottomSheet that lists curated treatment-plan templates (PR
/// #25) and returns the clinician's pick. The caller materialises
/// the template via `template.apply(patientId, clinicianId)` and
/// persists through `TreatmentPlanService.persistPlan`.
///
/// Two-pane layout on wide screens: list on the left, preview on
/// the right (goals + interventions count, clinical formulation).
/// Stacked on narrow screens.
library;

import 'package:flutter/material.dart';

import '../../services/treatment_plan_templates.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_card.dart';

class TemplatePickerSheet extends StatefulWidget {
  const TemplatePickerSheet({super.key, this.initialModality});

  /// Optional pre-filter so the sheet opens scoped to a modality
  /// (e.g. only CBT templates) — useful when the clinician already
  /// picked a modality elsewhere in the flow.
  final String? initialModality;

  @override
  State<TemplatePickerSheet> createState() => _TemplatePickerSheetState();
}

class _TemplatePickerSheetState extends State<TemplatePickerSheet> {
  String _filter = '';
  TreatmentPlanTemplate? _selected;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialModality ?? '';
  }

  List<TreatmentPlanTemplate> get _visible {
    if (_filter.trim().isEmpty) return TreatmentPlanTemplate.all;
    return TreatmentPlanTemplate.filter(modality: _filter);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(PsySpacing.lg),
            child: LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth >= 900;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      filter: _filter,
                      onFilter: (f) => setState(() => _filter = f),
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: PsySpacing.md),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 360,
                            child: _ListPane(
                              templates: _visible,
                              selected: _selected,
                              onPick: (t) => setState(() => _selected = t),
                            ),
                          ),
                          const SizedBox(width: PsySpacing.lg),
                          Expanded(child: _PreviewPane(template: _selected)),
                        ],
                      )
                    else ...[
                      _ListPane(
                        templates: _visible,
                        selected: _selected,
                        onPick: (t) => setState(() => _selected = t),
                      ),
                      const SizedBox(height: PsySpacing.md),
                      _PreviewPane(template: _selected),
                    ],
                    const SizedBox(height: PsySpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: PsySpacing.md),
                        FilledButton.icon(
                          onPressed: _selected == null
                              ? null
                              : () => Navigator.of(context).pop(_selected),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Use this template'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.filter,
    required this.onFilter,
    required this.onClose,
  });
  final String filter;
  final ValueChanged<String> onFilter;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Treatment plan templates',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a scaffold to start from. The plan is created in draft '
          'status — edit before activating.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: PsySpacing.md),
        Wrap(
          spacing: PsySpacing.sm,
          children: [
            for (final m in const ['', 'CBT', 'DBT', 'EMDR', 'Family'])
              ChoiceChip(
                label: Text(m.isEmpty ? 'All' : m),
                selected: filter.toLowerCase() == m.toLowerCase(),
                onSelected: (_) => onFilter(m),
              ),
          ],
        ),
      ],
    );
  }
}

class _ListPane extends StatelessWidget {
  const _ListPane({
    required this.templates,
    required this.selected,
    required this.onPick,
  });
  final List<TreatmentPlanTemplate> templates;
  final TreatmentPlanTemplate? selected;
  final ValueChanged<TreatmentPlanTemplate> onPick;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) {
      return PsyCard(
        child: Text(
          'No templates match this filter.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final t in templates)
          Padding(
            padding: const EdgeInsets.only(bottom: PsySpacing.sm),
            child: _TemplateTile(
              template: t,
              selected: selected?.id == t.id,
              onTap: () => onPick(t),
            ),
          ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });
  final TreatmentPlanTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PsyRadius.lg),
      child: PsyCard(
        tinted: selected,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: cs.primary, size: 18),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              template.targetPresentation,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: PsySpacing.sm),
            Wrap(
              spacing: PsySpacing.sm,
              children: [
                PsyBadge(label: template.modality, tone: PsyBadgeTone.brand),
                PsyBadge(label: '${template.goals.length} goals'),
                PsyBadge(
                  label: '${template.interventions.length} interventions',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({required this.template});
  final TreatmentPlanTemplate? template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = template;
    if (t == null) {
      return PsyCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(PsySpacing.xl),
            child: Text(
              'Pick a template on the left to preview goals + interventions.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.clinicalFormulation,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: PsySpacing.md),
          Text(
            'Goals (${t.goals.length})',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final g in t.goals) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 6),
                  child: Icon(Icons.flag_outlined, size: 16),
                ),
                Expanded(
                  child: Text(
                    '${g.description} (${g.targetWeeks} weeks)',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: PsySpacing.sm),
          Text(
            'Interventions (${t.interventions.length})',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (final i in t.interventions) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4, right: 6),
                  child: Icon(Icons.medical_services_outlined, size: 16),
                ),
                Expanded(
                  child: Text(
                    '${i.name} · ${i.frequency.name} · ${i.durationMinutes} min',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (t.prognosis != null) ...[
            const SizedBox(height: PsySpacing.sm),
            Text(
              'Prognosis',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(t.prognosis!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
