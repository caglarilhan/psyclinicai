import 'package:flutter/material.dart';

import '../../services/mbc/mbc_client.dart';
import '../../services/mbc/mbc_dispatch_catalog.dart';
import '../../services/mbc/mbc_scale_items.dart';

/// `/p/mbc/:scaleId/:token` — public-facing assessment form.
///
/// Standalone surface (no `AppShell`, no clinician chrome) because the
/// audience is a patient who arrived here from an SMS or email link
/// — they should never see the clinician portal or another patient's
/// chart.
///
/// Safety posture (mirrors the CF in `functions/src/mbc_submit_assessment.ts`):
///   * No login. The URL-bound token is the only credential.
///   * Single-submit: the server returns 409 on a second submit.
///   * Score banner is the patient's own score — no PHI from the
///     clinician chart leaks back.
class MbcPatientFormScreen extends StatefulWidget {
  const MbcPatientFormScreen({
    super.key,
    required this.client,
    required this.scaleId,
    required this.token,
  });

  final MbcPublicClient client;
  final String scaleId;
  final String token;

  @override
  State<MbcPatientFormScreen> createState() => _MbcPatientFormScreenState();
}

class _MbcPatientFormScreenState extends State<MbcPatientFormScreen> {
  late final List<String> _questions;
  late final List<String> _choices;
  late final MbcDispatchRule _rule;
  late final List<int?> _answers;
  bool _submitting = false;
  String? _error;
  MbcSubmitResult? _result;

  @override
  void initState() {
    super.initState();
    final (qs, cs) = MbcScaleItems.forScale(widget.scaleId);
    _questions = qs;
    _choices = cs;
    _rule = MbcDispatchCatalog.byScaleId(widget.scaleId);
    _answers = List<int?>.filled(qs.length, null);
  }

  bool get _complete => _answers.every((a) => a != null);

  Future<void> _onSubmit() async {
    if (_submitting || !_complete) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final res = await widget.client.submit(
        token: widget.token,
        answers: _answers.map((a) => a!).toList(),
      );
      if (!mounted) return;
      setState(() {
        _result = res;
        _submitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: _result != null
                ? _ResultPanel(theme: theme, result: _result!)
                : _FormBody(
                    theme: theme,
                    rule: _rule,
                    questions: _questions,
                    choices: _choices,
                    answers: _answers,
                    onPick: (qIndex, vIndex) {
                      setState(() {
                        _answers[qIndex] = vIndex;
                      });
                    },
                    submitting: _submitting,
                    complete: _complete,
                    error: _error,
                    onSubmit: _onSubmit,
                  ),
          ),
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.theme,
    required this.rule,
    required this.questions,
    required this.choices,
    required this.answers,
    required this.onPick,
    required this.submitting,
    required this.complete,
    required this.error,
    required this.onSubmit,
  });

  final ThemeData theme;
  final MbcDispatchRule rule;
  final List<String> questions;
  final List<String> choices;
  final List<int?> answers;
  final void Function(int qIndex, int vIndex) onPick;
  final bool submitting;
  final bool complete;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(rule.fullName, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Your responses go directly to your care team. There are no '
          'right or wrong answers — pick what fits best.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        for (var q = 0; q < questions.length; q++)
          _QuestionTile(
            index: q,
            prompt: questions[q],
            choices: choices,
            selected: answers[q],
            onPick: (v) => onPick(q, v),
            theme: theme,
          ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: complete && !submitting ? onSubmit : null,
          child: Text(submitting ? 'Submitting…' : 'Submit'),
        ),
        const SizedBox(height: 16),
        Text(
          'Privacy: only your care team can see your answers. This page '
          'expires automatically.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.outline),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({
    required this.index,
    required this.prompt,
    required this.choices,
    required this.selected,
    required this.onPick,
    required this.theme,
  });

  final int index;
  final String prompt;
  final List<String> choices;
  final int? selected;
  final ValueChanged<int> onPick;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. $prompt',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < choices.length; i++)
            RadioListTile<int>(
              dense: true,
              value: i,
              groupValue: selected,
              onChanged: (v) {
                if (v != null) onPick(v);
              },
              title: Text(choices[i]),
            ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.theme, required this.result});
  final ThemeData theme;
  final MbcSubmitResult result;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          result.alarmTriggered
              ? Icons.flag_outlined
              : Icons.check_circle_outline,
          size: 56,
          color: result.alarmTriggered ? cs.error : cs.primary,
        ),
        const SizedBox(height: 16),
        Text('Thank you — your check-in is in.',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Score: ${result.score} / ${result.maxScore} '
          '(${result.severity}).',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        if (result.alarmTriggered) ...[
          const SizedBox(height: 16),
          Card(
            color: cs.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Your responses suggest a clinical review may help. '
                'Your care team has been notified and will reach out. '
                'If you are in immediate danger, call your local '
                'emergency number or a crisis line.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onErrorContainer),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'You can close this window.',
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
