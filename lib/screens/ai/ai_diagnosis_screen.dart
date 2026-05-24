import 'package:flutter/material.dart';

import '../../services/copilot/diagnosis_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/ds/psy_badge.dart';
import '../../widgets/ds/psy_button.dart';
import '../../widgets/ds/psy_card.dart';

/// `/ai_diagnosis` — real DSM-5 differential generator backed by
/// Anthropic Claude (BYOK). Replaces the prior hardcoded 14-chip
/// dummy with structured candidates the clinician confirms or
/// rules out.
class AIDiagnosisScreen extends StatefulWidget {
  const AIDiagnosisScreen({super.key});

  @override
  State<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends State<AIDiagnosisScreen> {
  final _svc = DiagnosisService();
  final _vignette = TextEditingController(
    text:
        'Patient reports 3 weeks of persistent low mood, reduced sleep '
        '(4–5 h/night), loss of interest in usual activities, '
        'increased fatigue, mild anhedonia. No suicidal ideation. '
        'No prior depressive episodes documented.',
  );
  final Set<String> _selected = {};
  List<DxCandidate>? _result;
  bool _loading = false;
  String? _error;

  static const _symptoms = <String>[
    'Depressed mood most of the day',
    'Diminished interest / pleasure (anhedonia)',
    'Significant weight change',
    'Insomnia / hypersomnia',
    'Psychomotor agitation / retardation',
    'Fatigue / loss of energy',
    'Feelings of worthlessness / guilt',
    'Diminished concentration',
    'Recurrent thoughts of death',
    'Excessive anxiety / worry',
    'Restlessness / on edge',
    'Irritability',
    'Muscle tension',
    'Sleep disturbance',
    'Panic attacks',
    'Avoidance behaviour',
    'Intrusive memories / flashbacks',
    'Hypervigilance',
    'Mood swings / mania',
    'Substance use',
  ];

  @override
  void dispose() {
    _vignette.dispose();
    _svc.dispose();
    super.dispose();
  }

  Future<void> _suggest() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final list = await _svc.suggest(
        vignette: _vignette.text,
        selectedSymptoms: _selected.toList(),
      );
      if (!mounted) return;
      setState(() {
        _result = list;
        _loading = false;
      });
    } on DiagnosisException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unexpected error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology_outlined, color: cs.primary, size: 22),
            const SizedBox(width: PsySpacing.sm),
            const Text('DSM-5 Differential'),
            const SizedBox(width: PsySpacing.md),
            const PsyBadge(
                label: 'Claude Haiku 3.5', tone: PsyBadgeTone.brand),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            PsySpacing.xxl, PsySpacing.xl, PsySpacing.xxl, PsySpacing.xxxl),
        children: [
          PsyCard(
            tinted: true,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: cs.primary, size: 18),
                const SizedBox(width: PsySpacing.sm),
                Expanded(
                  child: Text(
                    'Differential support tool. Clinician owns the '
                    'diagnosis — we surface candidates with criteria '
                    'matched, missing criteria, and next steps.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text('Vignette',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          TextField(
            controller: _vignette,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText:
                  'Chief complaint, observations, duration, prior history…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Text('Observed symptoms',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: PsySpacing.sm),
          Wrap(
            spacing: PsySpacing.sm,
            runSpacing: PsySpacing.sm,
            children: _symptoms.map((s) {
              final on = _selected.contains(s);
              return FilterChip(
                label: Text(s),
                selected: on,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selected.add(s);
                  } else {
                    _selected.remove(s);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: PsySpacing.xxl),
          Row(
            children: [
              PsyButton(
                label: 'Suggest differential',
                icon: Icons.auto_awesome,
                loading: _loading,
                size: PsyButtonSize.lg,
                onPressed: _loading ? null : _suggest,
              ),
              const SizedBox(width: PsySpacing.lg),
              Expanded(
                child: Text(
                  _selected.isEmpty
                      ? 'No symptoms selected — vignette only'
                      : '${_selected.length} symptoms selected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: PsySpacing.xl),
            Container(
              padding: const EdgeInsets.all(PsySpacing.lg),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(PsyRadius.md),
                border:
                    Border.all(color: cs.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: cs.error),
                  const SizedBox(width: PsySpacing.md),
                  Expanded(
                    child: Text(_error!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.error)),
                  ),
                ],
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: PsySpacing.xxxl),
            Text('Candidates',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: PsySpacing.lg),
            if (_result!.isEmpty)
              PsyCard(
                child: Text(
                  'No candidates returned. Try a richer vignette or pick '
                  'symptoms.',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              ..._result!.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: PsySpacing.lg),
                  child: _DxCard(c: c, theme: theme, cs: cs),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DxCard extends StatelessWidget {
  const _DxCard(
      {required this.c, required this.theme, required this.cs});
  final DxCandidate c;
  final ThemeData theme;
  final ColorScheme cs;

  PsyBadgeTone get _tone => switch (c.confidence.toLowerCase()) {
        'high' => PsyBadgeTone.success,
        'medium' => PsyBadgeTone.warning,
        _ => PsyBadgeTone.neutral,
      };

  @override
  Widget build(BuildContext context) {
    return PsyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(c.name,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              PsyBadge(
                label: 'Confidence: ${c.confidence}',
                tone: _tone,
              ),
            ],
          ),
          const SizedBox(height: PsySpacing.sm),
          Wrap(
            spacing: PsySpacing.md,
            runSpacing: PsySpacing.xs,
            children: [
              if (c.icd10.isNotEmpty)
                _CodeChip(label: 'ICD-10', value: c.icd10, cs: cs),
              if (c.dsm5.isNotEmpty)
                _CodeChip(label: 'DSM-5', value: c.dsm5, cs: cs),
            ],
          ),
          const SizedBox(height: PsySpacing.lg),
          _list(theme, cs, Icons.check_circle, 'Matching criteria',
              c.matchingCriteria, cs.primary),
          if (c.missingCriteria.isNotEmpty)
            _list(theme, cs, Icons.help_outline, 'Confirm / rule out',
                c.missingCriteria, const Color(0xFFEA580C)),
          if (c.nextSteps.isNotEmpty)
            _list(theme, cs, Icons.flag_outlined, 'Next steps',
                c.nextSteps, cs.secondary),
        ],
      ),
    );
  }

  Widget _list(ThemeData theme, ColorScheme cs, IconData icon,
      String title, List<String> items, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(top: PsySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: PsySpacing.sm),
              Text(title,
                  style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700, color: accent)),
            ],
          ),
          const SizedBox(height: PsySpacing.xs),
          ...items.map((s) => Padding(
                padding: const EdgeInsets.only(
                    left: 24, top: 4, bottom: 4),
                child: Text('• $s',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.78),
                      height: 1.5,
                    )),
              )),
        ],
      ),
    );
  }
}

class _CodeChip extends StatelessWidget {
  const _CodeChip(
      {required this.label, required this.value, required this.cs});
  final String label;
  final String value;
  final ColorScheme cs;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: PsySpacing.md, vertical: PsySpacing.xs),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PsyRadius.sm),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text('$label  $value',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'JetBrains Mono',
            color: cs.onSurface.withValues(alpha: 0.78),
            fontWeight: FontWeight.w600,
          )),
    );
  }
}
