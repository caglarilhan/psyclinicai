import 'package:flutter/material.dart';

import '../../models/clinical_scale.dart';
import '../../services/data/telemetry_service.dart';

/// Generic runner for any [ClinicalScale] (C-SSRS, PCL-5, AUDIT, …). One
/// question at a time with per-item options, instant scoring, severity band,
/// and clinical-action guidance. Decision-support — never a diagnosis.
class ClinicalScaleScreen extends StatefulWidget {
  const ClinicalScaleScreen({super.key, required this.scale, this.patientName});

  final ClinicalScale scale;
  final String? patientName;

  @override
  State<ClinicalScaleScreen> createState() => _ClinicalScaleScreenState();
}

class _ClinicalScaleScreenState extends State<ClinicalScaleScreen> {
  late final List<int?> _answers;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.scale.itemCount, null);
  }

  bool get _allAnswered => !_answers.any((a) => a == null);

  void _next() {
    if (_index < widget.scale.itemCount - 1) setState(() => _index++);
  }

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  void _submit() {
    final values = <int>[];
    for (var i = 0; i < _answers.length; i++) {
      values.add(widget.scale.questions[i].choices[_answers[i]!].value);
    }
    final result = widget.scale.score(values);
    TelemetryService.instance.capture(TelemetryEvents.assessmentCompleted,
        properties: {'type': widget.scale.id});
    Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
      builder: (_) => _ScaleResultScreen(
          scale: widget.scale,
          patientName: widget.patientName,
          result: result),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = widget.scale.questions[_index];
    final progress = (_index + 1) / widget.scale.itemCount;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(widget.scale.shortName),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: cs.surfaceContainerHighest,
            color: cs.primary,
            minHeight: 4,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.patientName != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(widget.patientName!,
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(widget.scale.instructions,
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 8),
                Text('Question ${_index + 1} of ${widget.scale.itemCount}',
                    style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.55))),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.text,
                              style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600, height: 1.35)),
                          const SizedBox(height: 24),
                          ...List.generate(q.choices.length, (i) {
                            final selected = _answers[_index] == i;
                            final choice = q.choices[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _answers[_index] = i),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? cs.primary.withValues(alpha: 0.1)
                                        : cs.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? cs.primary
                                          : cs.outlineVariant,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: selected
                                            ? cs.primary
                                            : cs.outline,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(choice.label,
                                            style: theme.textTheme.bodyLarge
                                                ?.copyWith(
                                                    fontWeight: selected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text('+${choice.value}',
                                            style: TextStyle(
                                                fontFamily: 'monospace',
                                                color: cs.onSurface
                                                    .withValues(alpha: 0.55),
                                                fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _index == 0 ? null : _prev,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Back'),
                    ),
                    const Spacer(),
                    if (_index < widget.scale.itemCount - 1)
                      FilledButton.icon(
                        onPressed: _answers[_index] == null ? null : _next,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Next'),
                        style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14)),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _allAnswered ? _submit : null,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Score'),
                        style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _severityColor(ScaleSeverity s) => switch (s) {
      ScaleSeverity.minimal => Colors.green,
      ScaleSeverity.mild => Colors.lightGreen,
      ScaleSeverity.moderate => Colors.amber,
      ScaleSeverity.severe => Colors.deepOrange,
      ScaleSeverity.critical => Colors.red,
    };

class _ScaleResultScreen extends StatelessWidget {
  const _ScaleResultScreen(
      {required this.scale, required this.patientName, required this.result});

  final ClinicalScale scale;
  final String? patientName;
  final ScaleResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _severityColor(result.severity);
    final progress =
        result.maxScore == 0 ? 0.0 : result.total / result.maxScore;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: Text('${scale.shortName} result'),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (patientName != null) ...[
                Text(patientName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 8),
              ],
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: color.withValues(alpha: 0.35), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total score',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${result.total}',
                            style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                                height: 1)),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('/ ${result.maxScore}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                  color: cs.onSurface
                                      .withValues(alpha: 0.5))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(result.bandLabel,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (result.riskFlag && result.riskFlagText != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Clinical risk flag',
                                style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[800])),
                            const SizedBox(height: 4),
                            Text(result.riskFlagText!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurface
                                        .withValues(alpha: 0.85))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Clinical guidance',
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Text(result.guidance,
                        style:
                            theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
                    if (scale.referenceNote != null) ...[
                      const SizedBox(height: 16),
                      Text(scale.referenceNote!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.5),
                              fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      icon: const Icon(Icons.home, size: 18),
                      label: const Text('Back to dashboard'),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => ClinicalScaleScreen(
                              scale: scale, patientName: patientName),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Run again'),
                      style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
