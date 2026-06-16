import 'package:flutter/material.dart';

import '../../services/assessments/gad7_service.dart';
import '../../services/assessments/phq9_item9_router.dart';
import '../../services/assessments/phq9_service.dart';
import '../../services/data/assessment_repository.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../widgets/phq9_trigger_sheet.dart';

/// Unified assessment runner for PHQ-9 and GAD-7. One question at a time with
/// progress, navigation, instant scoring, and clinical-action guidance.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key, required this.type, this.patientName});

  final AssessmentType type;
  final String? patientName;

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

enum AssessmentType { phq9, gad7 }

extension AssessmentTypeX on AssessmentType {
  String get title => this == AssessmentType.phq9
      ? 'PHQ-9 Depression Screening'
      : 'GAD-7 Anxiety Screening';

  String get instructionsPrompt =>
      'Over the last 2 weeks, how often have you been bothered by the following problems?';

  List<String> get questions => this == AssessmentType.phq9
      ? Phq9Service.questions
      : Gad7Service.questions;

  List<String> get choices =>
      this == AssessmentType.phq9 ? Phq9Service.choices : Gad7Service.choices;

  /// Public-domain attribution shown on the result screen. The PHQ-9 and
  /// GAD-7 are free to use under their original educational grants — we
  /// display the citation so clinicians and auditors can trace provenance.
  String get referenceNote => this == AssessmentType.phq9
      ? 'PHQ-9 — Kroenke, Spitzer & Williams (2001). Developed with an '
            'educational grant from Pfizer Inc. No permission required to '
            'reproduce, translate, display, or distribute.'
      : 'GAD-7 — Spitzer, Kroenke, Williams & Löwe (2006). Developed with '
            'an educational grant from Pfizer Inc. Free to use without '
            'permission.';
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late final List<int?> _answers;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(widget.type.questions.length, null);
  }

  bool get _allAnswered => !_answers.any((a) => a == null);

  void _next() {
    if (_currentIndex < widget.type.questions.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  Future<void> _submit() async {
    final intAnswers = _answers.cast<int>();
    final phq9 = widget.type == AssessmentType.phq9
        ? Phq9Service.instance.score(intAnswers)
        : null;
    final gad7 = widget.type == AssessmentType.gad7
        ? Gad7Service.instance.score(intAnswers)
        : null;
    final result = phq9 != null
        ? _resultFromPhq9(phq9)
        : _resultFromGad7(gad7!);

    await _persistToFirestore(phq9: phq9, gad7: gad7);
    TelemetryService.instance.capture(
      TelemetryEvents.assessmentCompleted,
      properties: {'type': widget.type.name},
    );

    // PHQ-9 item 9 (suicidal ideation) is a hard patient-safety
    // signal: regardless of the total band, a positive answer must
    // surface the Phq9TriggerSheet BEFORE the score page so the
    // clinician decides on a C-SSRS / safety plan / crisis path.
    if (widget.type == AssessmentType.phq9 && intAnswers.length >= 9) {
      final recommendation = const Phq9Item9Router().evaluate({
        'phq9_9': intAnswers[8],
      });
      if (recommendation.primaryAction != Phq9Item9Action.none) {
        if (!mounted) return;
        await Phq9TriggerSheet.show(
          context,
          recommendation: recommendation,
          locale: Localizations.maybeLocaleOf(context),
        );
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _ResultScreen(
          type: widget.type,
          patientName: widget.patientName,
          result: result,
        ),
      ),
    );
  }

  Future<void> _persistToFirestore({Phq9Result? phq9, Gad7Result? gad7}) async {
    if (!PsyFirebase.isReady) return;
    final auth = FirebaseAuthService.instance;
    final profile = auth.profile;
    if (profile == null) return;
    final patientId = _slug(widget.patientName ?? 'demo-patient');
    try {
      await PatientRepository.instance.upsert(
        profile.clinicId,
        patientId,
        PatientDraft(fullName: widget.patientName ?? 'Unnamed Patient'),
      );
      if (phq9 != null) {
        await AssessmentRepository.instance.savePhq9(
          clinicId: profile.clinicId,
          patientId: patientId,
          clinicianId: profile.userId,
          result: phq9,
        );
      } else if (gad7 != null) {
        await AssessmentRepository.instance.saveGad7(
          clinicId: profile.clinicId,
          patientId: patientId,
          clinicianId: profile.userId,
          result: gad7,
        );
      }
    } catch (_) {
      // Persist is best-effort; UI already shows the score.
    }
  }

  String _slug(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'(^-|-$)'), '');

  _GenericResult _resultFromPhq9(Phq9Result r) => _GenericResult(
    total: r.total,
    maxScore: 27,
    severityLabel: r.severity.label,
    severityColor: _phq9Color(r.severity),
    actionSuggestion: r.severity.actionSuggestion,
    riskFlag: r.selfHarmFlag,
    riskFlagText: r.selfHarmFlag
        ? 'Item 9 (self-harm/suicide ideation) endorsed — clinical review required.'
        : null,
  );

  _GenericResult _resultFromGad7(Gad7Result r) => _GenericResult(
    total: r.total,
    maxScore: 21,
    severityLabel: r.severity.label,
    severityColor: _gad7Color(r.severity),
    actionSuggestion: r.severity.actionSuggestion,
    riskFlag: false,
  );

  Color _phq9Color(Phq9Severity s) => switch (s) {
    Phq9Severity.minimal => Colors.green,
    Phq9Severity.mild => Colors.lightGreen,
    Phq9Severity.moderate => Colors.amber,
    Phq9Severity.moderatelySevere => Colors.deepOrange,
    Phq9Severity.severe => Colors.red,
  };

  Color _gad7Color(Gad7Severity s) => switch (s) {
    Gad7Severity.minimal => Colors.green,
    Gad7Severity.mild => Colors.lightGreen,
    Gad7Severity.moderate => Colors.amber,
    Gad7Severity.severe => Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final questions = widget.type.questions;
    final choices = widget.type.choices;
    final progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(widget.type.title),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.patientName != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.patientName!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  widget.type.instructionsPrompt,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question ${_currentIndex + 1} of ${questions.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questions[_currentIndex],
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(choices.length, (i) {
                        final selected = _answers[_currentIndex] == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => setState(() {
                              _answers[_currentIndex] = i;
                            }),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
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
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selected
                                            ? cs.primary
                                            : cs.outline,
                                        width: 2,
                                      ),
                                      color: selected
                                          ? cs.primary
                                          : Colors.transparent,
                                    ),
                                    alignment: Alignment.center,
                                    child: selected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 14,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      choices[i],
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: selected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '+$i',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        color: cs.onSurface.withValues(
                                          alpha: 0.55,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
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
                const SizedBox(height: 16),
                // Visual anchor — same sticky-feeling pattern as clinical_scale.
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _currentIndex == 0 ? null : _prev,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back'),
                      ),
                      const Spacer(),
                      if (_currentIndex < questions.length - 1)
                        FilledButton.icon(
                          onPressed: _answers[_currentIndex] == null
                              ? null
                              : _next,
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Next'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        )
                      else
                        FilledButton.icon(
                          onPressed: _allAnswered ? _submit : null,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Score'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GenericResult {
  _GenericResult({
    required this.total,
    required this.maxScore,
    required this.severityLabel,
    required this.severityColor,
    required this.actionSuggestion,
    required this.riskFlag,
    this.riskFlagText,
  });

  final int total;
  final int maxScore;
  final String severityLabel;
  final Color severityColor;
  final String actionSuggestion;
  final bool riskFlag;
  final String? riskFlagText;
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({
    required this.type,
    required this.patientName,
    required this.result,
  });

  final AssessmentType type;
  final String? patientName;
  final _GenericResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final progressValue = result.total / result.maxScore;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          '${type == AssessmentType.phq9 ? "PHQ-9" : "GAD-7"} Result',
        ),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: [
              if (patientName != null) ...[
                Text(
                  patientName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      result.severityColor.withValues(alpha: 0.15),
                      result.severityColor.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: result.severityColor.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total score',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${result.total}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: result.severityColor,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '/ ${result.maxScore}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 8,
                        color: result.severityColor,
                        backgroundColor: result.severityColor.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: result.severityColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        result.severityLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
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
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.35),
                    ),
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
                            Text(
                              'Clinical risk flag',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.red[800],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result.riskFlagText!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
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
                    Text(
                      'Clinical guidance',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.actionSuggestion,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      type.referenceNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (_) => AssessmentScreen(
                            type: type,
                            patientName: patientName,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Run again'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
