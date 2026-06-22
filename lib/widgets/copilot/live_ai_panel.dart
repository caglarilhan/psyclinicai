import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/clinical_lens.dart';
import '../../models/denial_risk.dart';
import '../../models/session_note.dart';
import '../../models/supervision_report.dart';
import '../../services/billing/denial_shield_service.dart';
import '../../services/billing/icd10_lookup_service.dart';
import '../../services/billing/note_billing_extractor.dart';
import '../../services/copilot/clinical_lens_service.dart';
import '../../services/copilot/compliance_check_service.dart';
import '../../services/copilot/risk_signal_service.dart';
import '../../services/copilot/session_insights_service.dart';
import '../../services/copilot/soap_generator_service.dart';
import '../../services/copilot/supervision_service.dart';
import '../../services/copilot/transcription_service.dart';
import '../../services/data/session_note_repository.dart';
import '../../theme/tokens.dart';
import 'insights_sheet.dart';

/// Real-time AI Co-Pilot panel.
///
/// Three visual states: idle → listening → generating → noteReady (or error).
/// Material 3 surface tokens, animated state transitions, accessible contrast.
class LiveAiPanel extends StatefulWidget {
  const LiveAiPanel({
    super.key,
    this.clientName,
    this.clientPresenting,
    this.clinicianRole = 'licensed mental health clinician',
    this.localeId = 'en_US',
    this.treatmentGoals = const [],
    this.patientId,
  });

  /// When set, generated notes are persisted to the patient's Clinical Memory
  /// so the next pre-session brief includes this session.
  final String? patientId;

  final String? clientName;
  final String? clientPresenting;
  final String clinicianRole;
  final String localeId;

  /// Active treatment-plan goal texts, surfaced into the note (golden thread).
  final List<String> treatmentGoals;

  @override
  State<LiveAiPanel> createState() => _LiveAiPanelState();
}

enum _PanelState { idle, listening, generating, noteReady, error }

class _LiveAiPanelState extends State<LiveAiPanel>
    with SingleTickerProviderStateMixin {
  late final TranscriptionService _transcription;
  late final SoapGeneratorService _generator;
  late final RiskSignalService _risk;
  late final ComplianceCheckService _compliance;
  late final SessionInsightsService _insights;
  late final AnimationController _pulse;

  StreamSubscription<TranscriptUpdate>? _sub;
  Timer? _tier2Timer;

  /// Live risk signals surfaced during the session (decision-support only).
  final List<RiskSignal> _signals = [];
  final Set<String> _seenSignals = {};

  /// Audit-readiness report for the generated note (decision-support).
  ComplianceReport? _report;
  bool _deepChecking = false;
  bool _loadingInsights = false;

  _PanelState _state = _PanelState.idle;
  String _transcript = '';
  String _partial = '';
  String? _errorMessage;
  SoapNote? _note;
  SoapFormat _format = SoapFormat.soap;
  Modality _modality = Modality.general;
  Payer _payer = Payer.medicare;
  DenialRisk? _denial;
  final _editCtl = TextEditingController();
  final _noteRepo = SessionNoteRepository();
  final _lensService = ClinicalLensService();
  final _supervision = SupervisionService();
  bool _editing = false;
  bool _loadingLens = false;
  bool _loadingSupervision = false;

  @override
  void initState() {
    super.initState();
    _transcription = TranscriptionService();
    _generator = SoapGeneratorService();
    _risk = RiskSignalService();
    _compliance = ComplianceCheckService();
    _insights = SessionInsightsService();
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    unawaited(_pulse.repeat(reverse: true));

    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await _transcription.initialize();
    _sub = _transcription.transcriptStream.listen(_onTranscript);
    if (mounted) setState(() {});
  }

  void _onTranscript(TranscriptUpdate u) {
    if (!mounted) return;
    setState(() {
      _transcript = u.fullTranscript;
      _partial = u.partial;
    });
    if (u.isFinal && u.delta.trim().isNotEmpty) {
      _addSignals(_risk.scanSegment(u.delta)); // Tier 1 — instant, offline
      _scheduleTier2(); // Tier 2 — optional Claude refinement (BYOK)
    }
  }

  void _addSignals(List<RiskSignal> found) {
    final fresh = found.where((s) => _seenSignals.add(s.dedupKey)).toList();
    if (fresh.isEmpty || !mounted) return;
    setState(() => _signals.addAll(fresh));
  }

  void _scheduleTier2() {
    _tier2Timer?.cancel();
    _tier2Timer = Timer(const Duration(seconds: 4), () async {
      if (!mounted) return; // don't touch _risk after dispose
      final ai = await _risk.classifyWindow(_transcript);
      _addSignals(ai);
    });
  }

  Future<void> _startListening() async {
    if (!_transcription.available) {
      await _transcription.initialize();
      if (!_transcription.available) {
        setState(() {
          _state = _PanelState.error;
          _errorMessage =
              'Microphone or speech recognition not available on this device.';
        });
        return;
      }
    }
    setState(() {
      _state = _PanelState.listening;
      _errorMessage = null;
      _transcript = '';
      _partial = '';
      _note = null;
      _signals.clear();
      _seenSignals.clear();
      _report = null;
      _transcription.reset();
    });
    await _transcription.start(localeId: widget.localeId);
  }

  Future<void> _stopAndGenerate() async {
    await _transcription.stop();
    final fullText = _transcription.fullTranscript.trim();
    if (fullText.isEmpty) {
      setState(() {
        _state = _PanelState.error;
        _errorMessage =
            'No speech detected. Try again with the microphone closer.';
      });
      return;
    }
    setState(() => _state = _PanelState.generating);

    try {
      final note = await _generator.generate(
        transcript: fullText,
        format: _format,
        clientName: widget.clientName,
        clientPresenting: widget.clientPresenting,
        clinicianRole: widget.clinicianRole,
        treatmentGoals: widget.treatmentGoals,
        modality: _modality,
      );
      if (!mounted) return;
      setState(() {
        _note = note;
        _editCtl.text = note.rawMarkdown;
        _report = _compliance.check(note.rawMarkdown);
        _state = _PanelState.noteReady;
        _computeDenial();
      });
      unawaited(_persistNote(note));
    } on SoapGeneratorException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _PanelState.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _PanelState.error;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _cancelListening() async {
    await _transcription.cancel();
    setState(() {
      _state = _PanelState.idle;
      _transcript = '';
      _partial = '';
    });
  }

  void _resetForNewSession() {
    _tier2Timer?.cancel();
    setState(() {
      _state = _PanelState.idle;
      _transcript = '';
      _partial = '';
      _note = null;
      _editing = false;
      _editCtl.clear();
      _errorMessage = null;
      _signals.clear();
      _seenSignals.clear();
      _report = null;
      _transcription.reset();
    });
  }

  /// Closes the golden thread: derive billing hints from the finished note and
  /// open the superbill pre-filled. The clinician confirms every code.
  void _createSuperbill(BuildContext context) {
    final note = _note;
    if (note == null) return;
    final text = _editCtl.text.isEmpty ? note.rawMarkdown : _editCtl.text;
    final prefill = const NoteBillingExtractor().fromNote(
      text,
      isKnownIcd: (c) => Icd10LookupService.instance.byCode(c) != null,
      patientName: widget.clientName,
      isPsychiatry: note.format == SoapFormat.psychiatry,
      serviceDate: DateTime.now(),
    );
    unawaited(
      Navigator.of(context).pushNamed('/superbill', arguments: prefill),
    );
  }

  /// Persists a finished note to the patient's Clinical Memory (the continuity
  /// flywheel) so the next pre-session brief includes this session.
  Future<void> _persistNote(SoapNote note) async {
    final pid = widget.patientId;
    if (pid == null || pid.isEmpty) return;
    await _noteRepo.initialize();
    await _noteRepo.add(
      SessionNote(
        id: 'n-${DateTime.now().millisecondsSinceEpoch}',
        patientId: pid,
        markdown: note.rawMarkdown,
        format: note.format.name,
        flaggedRisk: note.flaggedRisk,
      ),
    );
  }

  Future<void> _runDeepCheck() async {
    final note = _note;
    final base = _report;
    if (note == null || base == null) return;
    setState(() => _deepChecking = true);
    final updated = await _compliance.deepCheck(note.rawMarkdown, base: base);
    if (!mounted) return;
    setState(() {
      _report = updated;
      _deepChecking = false;
      _computeDenial();
    });
  }

  /// Recomputes the Denial Shield risk from the current note + report + payer.
  void _computeDenial() {
    final note = _note;
    final report = _report;
    if (note == null || report == null) {
      _denial = null;
      return;
    }
    final text = _editCtl.text.isEmpty ? note.rawMarkdown : _editCtl.text;
    final cpt =
        const NoteBillingExtractor().suggestCpt(
          text,
          isPsychiatry: note.format == SoapFormat.psychiatry,
        ) ??
        '90834';
    _denial = const DenialShieldService().assess(
      note: text,
      cptCode: cpt,
      payer: _payer,
      audit: report,
    );
  }

  /// One-click "update the note & reset the risk": appends each fixable
  /// reason's ready-to-paste sentence to the note, then re-runs the audit +
  /// denial check so the score updates immediately.
  void _applyDenialFixes() {
    final d = _denial;
    if (d == null) return;
    final additions = d.reasons
        .map((r) => r.insertText)
        .whereType<String>()
        .toList();
    if (additions.isEmpty) return;
    final current = _editCtl.text.isEmpty
        ? (_note?.rawMarkdown ?? '')
        : _editCtl.text;
    final updated = '$current\n\n${additions.join(' ')}';
    setState(() {
      _editCtl.text = updated;
      _report = _compliance.check(updated);
      _computeDenial();
    });
  }

  void _showDenialDetails(BuildContext context) {
    final d = _denial;
    if (d == null) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: cs.surface,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: _denialColor(cs, d),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${d.level.label} · ${d.payer.label}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${d.cptCode} · ${d.cptLabel}'
                '${d.revenueAtRisk != null ? ' · ~\$${d.revenueAtRisk!.round()} at risk' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              if (d.reasons.any((r) => r.insertText != null)) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _applyDenialFixes();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('Update note & reset risk'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              if (d.reasons.isEmpty)
                Text(
                  'No denial drivers found for ${d.payer.short}. '
                  'Documentation supports the billed code.',
                  style: theme.textTheme.bodyMedium,
                )
              else
                ...d.reasons.map(
                  (r) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: r.critical
                            ? cs.error.withValues(alpha: 0.4)
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              r.critical
                                  ? Icons.error_outline
                                  : Icons.warning_amber_rounded,
                              size: 16,
                              color: r.critical
                                  ? cs.error
                                  : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                r.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 15,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  r.fixSentence,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.primary,
                                    height: 1.4,
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
              const SizedBox(height: 8),
              Text(
                DenialShieldService.payerFocus(d.payer),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Decision-support — payer rules and reimbursement vary and change. '
                'This estimates denial risk; it does not guarantee payment.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuditDetails(BuildContext context) {
    final report = _report;
    if (report == null) return;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => _AuditSheet(report: report),
      ),
    );
  }

  Future<void> _showInsights(BuildContext context) async {
    final transcript = _transcript.trim().isNotEmpty
        ? _transcript
        : _note?.rawMarkdown ?? '';
    setState(() => _loadingInsights = true);
    try {
      final insights = await _insights.analyze(transcript);
      if (!context.mounted) return;
      unawaited(
        showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => InsightsSheet(insights: insights),
        ),
      );
    } on SessionInsightsException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingInsights = false);
    }
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    _tier2Timer?.cancel();
    _transcription.dispose();
    _generator.dispose();
    _risk.dispose();
    _compliance.dispose();
    _insights.dispose();
    _lensService.dispose();
    _supervision.dispose();
    _pulse.dispose();
    _editCtl.dispose();
    super.dispose();
  }

  /// Generates a de-identified supervision report (fidelity + reflective
  /// questions) for the session and shows it in a sheet, copyable for a
  /// supervisor.
  Future<void> _showSupervision(BuildContext context) async {
    final src = _transcript.isNotEmpty
        ? _transcript
        : (_note?.rawMarkdown ?? '');
    if (src.trim().isEmpty) return;
    setState(() => _loadingSupervision = true);
    try {
      final report = await _supervision.generate(
        transcript: src,
        modality: _modality,
      );
      if (!context.mounted) return;
      _presentSupervision(context, report);
    } on SupervisionException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingSupervision = false);
    }
  }

  void _presentSupervision(BuildContext context, SupervisionReport r) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = r.fidelityScore >= 80
        ? const Color(0xFF16A34A)
        : r.fidelityScore >= 60
        ? const Color(0xFFD97706)
        : cs.error;
    Widget list(String title, List<String> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          ...items.map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                  Expanded(child: Text(i, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: cs.surface,
        isScrollControlled: true,
        builder: (sheetCtx) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          builder: (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Icon(Icons.school_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${r.modalityLabel} supervision (de-identified)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '${r.fidelityScore}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      '/100 fidelity',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              if (r.summary.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(r.summary, style: theme.textTheme.bodyMedium),
              ],
              if (r.fidelityNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  r.fidelityNotes,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
              list('Strengths', r.strengths),
              list('Growth areas', r.growthAreas),
              list('Reflective questions', r.reflectiveQuestions),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  unawaited(
                    Clipboard.setData(ClipboardData(text: r.anonymizedText())),
                  );
                  ScaffoldMessenger.of(sheetCtx).showSnackBar(
                    const SnackBar(
                      content: Text('De-identified report copied.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy anonymized report'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Decision-support for supervision — not a competency '
                'determination. Verify anonymization before sharing.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Extracts the selected modality's clinical lens from the session and shows
  /// it in a sheet — the clinical-depth engine.
  Future<void> _showClinicalLens(BuildContext context) async {
    final src = _transcript.isNotEmpty
        ? _transcript
        : (_note?.rawMarkdown ?? '');
    if (src.trim().isEmpty) return;
    setState(() => _loadingLens = true);
    try {
      final lens = await _lensService.extract(
        transcript: src,
        modality: _modality,
      );
      if (!context.mounted) return;
      _presentLens(context, lens);
    } on ClinicalLensException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: e.noKey
              ? SnackBarAction(
                  label: 'API keys',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/settings/api_keys'),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingLens = false);
    }
  }

  void _presentLens(BuildContext context, ClinicalLens lens) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: cs.surface,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.92,
          builder: (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Icon(Icons.center_focus_strong_outlined, color: cs.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${lens.modalityLabel} lens',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final s in lens.sections) ...[
                Text(
                  s.title.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                ...s.items.map(
                  (it) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        Expanded(
                          child: Text(it, style: theme.textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'Decision-support — extracted from the transcript for review, not '
                'a diagnosis.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _Header(
            cs: cs,
            theme: theme,
            state: _state,
            pulse: _pulse,
            format: _format,
            onFormatChanged: _state == _PanelState.idle
                ? (f) => setState(() => _format = f)
                : null,
            modality: _modality,
            onModalityChanged: _state == _PanelState.idle
                ? (m) => setState(() => _modality = m)
                : null,
            onOpenSettings: () =>
                Navigator.of(context).pushNamed('/settings/api_keys'),
          ),
          Expanded(child: _buildBody(theme, cs)),
          _Footer(
            cs: cs,
            theme: theme,
            state: _state,
            onStart: _startListening,
            onStopGenerate: _stopAndGenerate,
            onCancel: _cancelListening,
            onNewSession: _resetForNewSession,
            onSaveEdit: () => setState(() => _editing = false),
            onEdit: () => setState(() => _editing = true),
            editing: _editing,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme cs) {
    switch (_state) {
      case _PanelState.idle:
        return _IdleView(theme: theme, cs: cs);
      case _PanelState.listening:
        return Column(
          children: [
            if (_signals.isNotEmpty)
              _RiskStrip(signals: _signals, theme: theme, cs: cs),
            Expanded(
              child: _ListeningView(
                theme: theme,
                cs: cs,
                transcript: _transcript,
                partial: _partial,
              ),
            ),
          ],
        );
      case _PanelState.generating:
        return _GeneratingView(theme: theme, cs: cs, transcript: _transcript);
      case _PanelState.noteReady:
        final noteView = _NoteReadyView(
          theme: theme,
          cs: cs,
          note: _note!,
          controller: _editCtl,
          editing: _editing,
          onCreateSuperbill: () => _createSuperbill(context),
          onClinicalLens: () => _showClinicalLens(context),
          loadingLens: _loadingLens,
          onSupervision: () => _showSupervision(context),
          loadingSupervision: _loadingSupervision,
          modalityLabel: _modality.label,
        );
        void onPayer(Payer p) => setState(() {
          _payer = p;
          _computeDenial();
        });
        return Column(
          children: [
            if (_signals.isNotEmpty)
              _RiskStrip(signals: _signals, theme: theme, cs: cs),
            Expanded(
              child: LayoutBuilder(
                builder: (ctx, c) {
                  // Wide: clinical note left, compliance rail right (the
                  // dual-engine split). Narrow: banners stacked over the note.
                  if (c.maxWidth >= 860) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: noteView),
                        VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: cs.outlineVariant,
                        ),
                        SizedBox(
                          width: 360,
                          child: _ComplianceRail(
                            report: _report,
                            denial: _denial,
                            payer: _payer,
                            deepChecking: _deepChecking,
                            loadingInsights: _loadingInsights,
                            theme: theme,
                            cs: cs,
                            onDetails: () => _showAuditDetails(context),
                            onDeepCheck: _runDeepCheck,
                            onInsights: () => _showInsights(context),
                            onPayerChanged: onPayer,
                            onApplyFixes: _applyDenialFixes,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      if (_report != null)
                        _AuditBanner(
                          report: _report!,
                          deepChecking: _deepChecking,
                          theme: theme,
                          cs: cs,
                          onDetails: () => _showAuditDetails(context),
                          onDeepCheck: _runDeepCheck,
                          onInsights: () => _showInsights(context),
                          loadingInsights: _loadingInsights,
                        ),
                      if (_denial != null)
                        _DenialBanner(
                          denial: _denial!,
                          payer: _payer,
                          theme: theme,
                          cs: cs,
                          onPayerChanged: onPayer,
                          onDetails: () => _showDenialDetails(context),
                        ),
                      Expanded(child: noteView),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      case _PanelState.error:
        return _ErrorView(
          theme: theme,
          cs: cs,
          message: _errorMessage ?? 'Unknown error',
          onRetry: _resetForNewSession,
          onOpenSettings: () =>
              Navigator.of(context).pushNamed('/settings/api_keys'),
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.cs,
    required this.theme,
    required this.state,
    required this.pulse,
    required this.format,
    required this.onFormatChanged,
    required this.modality,
    required this.onModalityChanged,
    required this.onOpenSettings,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final _PanelState state;
  final AnimationController pulse;
  final SoapFormat format;
  final ValueChanged<SoapFormat>? onFormatChanged;
  final Modality modality;
  final ValueChanged<Modality>? onModalityChanged;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isLive = state == _PanelState.listening;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (isLive)
            // prefers-reduced-motion → static red dot (no pulse/shadow).
            // WCAG 2.3.3 + Apple HIG. The icon-and-label combo still
            // conveys "live" without the throbbing visual.
            (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                ? Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                : AnimatedBuilder(
                    animation: pulse,
                    builder: (_, __) => Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(
                          alpha: 0.5 + pulse.value * 0.5,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(
                              alpha: pulse.value * 0.6,
                            ),
                            blurRadius: 8 + pulse.value * 4,
                          ),
                        ],
                      ),
                    ),
                  )
          else
            Icon(Icons.auto_awesome, color: cs.primary, size: 20),
          const SizedBox(width: 6),
          // On phones, two dropdowns + the key IconButton consume so much
          // width that any title ellipsizes to "Li...". The leading
          // sparkles/pulse icon already signals "AI co-pilot", so we drop
          // the title text below 560 and let the dropdowns keep full,
          // legible labels ("General" / "SOAP").
          Builder(
            builder: (ctx) {
              final wide = MediaQuery.sizeOf(ctx).width >= 560;
              if (!wide) return const SizedBox.shrink();
              return Flexible(
                child: Text(
                  'Live AI Co-Pilot',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
          const Spacer(),
          if (onModalityChanged != null)
            DropdownButtonHideUnderline(
              child: DropdownButton<Modality>(
                value: modality,
                icon: Icon(Icons.expand_more, color: cs.primary, size: 18),
                isDense: true,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                items: Modality.values
                    .map(
                      (m) => DropdownMenuItem(value: m, child: Text(m.label)),
                    )
                    .toList(),
                onChanged: (v) => v != null ? onModalityChanged!(v) : null,
              ),
            ),
          if (onModalityChanged != null) const SizedBox(width: 8),
          if (onFormatChanged != null)
            DropdownButtonHideUnderline(
              child: DropdownButton<SoapFormat>(
                value: format,
                icon: Icon(Icons.expand_more, color: cs.primary, size: 18),
                isDense: true,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                items: SoapFormat.values
                    .map(
                      (f) => DropdownMenuItem(value: f, child: Text(f.label)),
                    )
                    .toList(),
                onChanged: (v) => v != null ? onFormatChanged!(v) : null,
              ),
            ),
          IconButton(
            tooltip: 'API Keys',
            icon: Icon(
              Icons.key,
              size: 18,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  const _Footer({
    required this.cs,
    required this.theme,
    required this.state,
    required this.onStart,
    required this.onStopGenerate,
    required this.onCancel,
    required this.onNewSession,
    required this.onSaveEdit,
    required this.onEdit,
    required this.editing,
  });

  final ColorScheme cs;
  final ThemeData theme;
  final _PanelState state;
  final VoidCallback onStart;
  final VoidCallback onStopGenerate;
  final VoidCallback onCancel;
  final VoidCallback onNewSession;
  final VoidCallback onSaveEdit;
  final VoidCallback onEdit;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: switch (state) {
        _PanelState.idle => FilledButton.icon(
          onPressed: onStart,
          icon: const Icon(Icons.mic, size: 18),
          label: const Text('Start AI Recording'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        ),
        _PanelState.listening => Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onStopGenerate,
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('Stop & Generate Note'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: Colors.red[600],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Cancel',
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        _PanelState.generating => OutlinedButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Generating note…'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
          ),
        ),
        _PanelState.noteReady => Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: editing ? onSaveEdit : onEdit,
                icon: Icon(editing ? Icons.check : Icons.edit, size: 16),
                label: Text(editing ? 'Save edits' : 'Edit note'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onNewSession,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('New session'),
              ),
            ),
          ],
        ),
        _PanelState.error => FilledButton.icon(
          onPressed: onNewSession,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try again'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
        ),
      },
    );
  }
}

// ---------------------------------------------------------------------------
// State views
// ---------------------------------------------------------------------------

class _IdleView extends StatelessWidget {
  const _IdleView({required this.theme, required this.cs});
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.mic_none, size: 40, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to listen',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Press Start to capture the session on-device. A structured note '
            'is generated when you stop.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningView extends StatelessWidget {
  const _ListeningView({
    required this.theme,
    required this.cs,
    required this.transcript,
    required this.partial,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String transcript;
  final String partial;

  @override
  Widget build(BuildContext context) {
    final hasContent = transcript.isNotEmpty || partial.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: hasContent
          ? SingleChildScrollView(
              reverse: true,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface,
                    height: 1.55,
                  ),
                  children: [
                    if (transcript.isNotEmpty) TextSpan(text: '$transcript '),
                    if (partial.isNotEmpty)
                      TextSpan(
                        text: partial,
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.55),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Center(
              child: Text(
                'Speak naturally…',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
    );
  }
}

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({
    required this.theme,
    required this.cs,
    required this.transcript,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String transcript;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(
            color: cs.primary,
            backgroundColor: cs.primaryContainer.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Synthesizing structured note…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                transcript,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteReadyView extends StatelessWidget {
  const _NoteReadyView({
    required this.theme,
    required this.cs,
    required this.note,
    required this.controller,
    required this.editing,
    required this.onCreateSuperbill,
    required this.onClinicalLens,
    required this.loadingLens,
    required this.onSupervision,
    required this.loadingSupervision,
    required this.modalityLabel,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final SoapNote note;
  final TextEditingController controller;
  final bool editing;
  final VoidCallback onCreateSuperbill;
  final VoidCallback onClinicalLens;
  final bool loadingLens;
  final VoidCallback onSupervision;
  final bool loadingSupervision;
  final String modalityLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${note.format.label} note',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (note.flaggedRisk) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Risk flagged',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: loadingLens ? null : onClinicalLens,
                visualDensity: VisualDensity.compact,
                tooltip: '$modalityLabel lens',
                icon: loadingLens
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.center_focus_strong_outlined, size: 18),
              ),
              IconButton(
                onPressed: loadingSupervision ? null : onSupervision,
                visualDensity: VisualDensity.compact,
                tooltip: 'Supervision report (de-identified)',
                icon: loadingSupervision
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.school_outlined, size: 18),
              ),
              IconButton(
                onPressed: onCreateSuperbill,
                visualDensity: VisualDensity.compact,
                tooltip: 'Create superbill',
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: editing
                ? TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      height: 1.45,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      controller.text.isEmpty
                          ? note.rawMarkdown
                          : controller.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.theme,
    required this.cs,
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final ThemeData theme;
  final ColorScheme cs;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final isNoKey = message.toLowerCase().contains('api key');
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.red[400]),
          const SizedBox(height: 12),
          Text(
            'Could not complete',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          if (isNoKey) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.key, size: 16),
              label: const Text('Open API Keys settings'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Live risk-signal strip (decision-support — clinician reviews)
// ---------------------------------------------------------------------------

class _RiskStrip extends StatelessWidget {
  const _RiskStrip({
    required this.signals,
    required this.theme,
    required this.cs,
  });

  final List<RiskSignal> signals;
  final ThemeData theme;
  final ColorScheme cs;

  Color _color(RiskSeverity s) => switch (s) {
    // L-2 (audit 2026-06-21): imminent = deepest red, distinct from
    // high so the clinician can spot acute intent at a glance.
    RiskSeverity.imminent => const Color(0xFFB91C1C),
    RiskSeverity.high => const Color(0xFFDC2626),
    RiskSeverity.elevated => const Color(0xFFD97706),
    RiskSeverity.info => cs.primary,
  };

  @override
  Widget build(BuildContext context) {
    // Highest severity first, then most recent.
    final sorted = [...signals]
      ..sort(
        (a, b) => b.severity.index != a.severity.index
            ? b.severity.index - a.severity.index
            : b.at.compareTo(a.at),
      );
    final topColor = _color(sorted.first.severity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: topColor.withValues(alpha: 0.06),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.health_and_safety_outlined, size: 16, color: topColor),
              const SizedBox(width: 6),
              Text(
                'Live risk signals (${signals.length})',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: topColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sorted.map((s) {
              final c = _color(s.severity);
              return Tooltip(
                message:
                    '${s.severity.label} · ${s.snippet}'
                    '${s.source == RiskSource.ai ? '  (AI)' : ''}',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: c.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 12, color: c),
                      const SizedBox(width: 4),
                      Text(
                        s.category.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: c,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            'Decision-support — review clinically, not a diagnosis.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Audit-readiness banner + sheet (decision-support)
// ---------------------------------------------------------------------------

Color _scoreColor(int score) => score >= 80
    ? const Color(0xFF16A34A)
    : score >= 60
    ? const Color(0xFFD97706)
    : const Color(0xFFDC2626);

Color _checkColor(CheckStatus s) => switch (s) {
  CheckStatus.pass => const Color(0xFF16A34A),
  CheckStatus.warn => const Color(0xFFD97706),
  CheckStatus.fail => const Color(0xFFDC2626),
};

IconData _checkIcon(CheckStatus s) => switch (s) {
  CheckStatus.pass => Icons.check_circle,
  CheckStatus.warn => Icons.error_outline,
  CheckStatus.fail => Icons.cancel,
};

Color _denialColor(ColorScheme cs, DenialRisk d) => switch (d.level) {
  DenialLevel.high => cs.error,
  DenialLevel.medium => const Color(0xFFD97706),
  DenialLevel.low => const Color(0xFF16A34A),
};

/// Denial Shield strip — payer-aware claim-rejection risk for the note, with a
/// payer selector. Tap opens the reasons + the exact sentences to add.
class _DenialBanner extends StatelessWidget {
  const _DenialBanner({
    required this.denial,
    required this.payer,
    required this.theme,
    required this.cs,
    required this.onPayerChanged,
    required this.onDetails,
  });

  final DenialRisk denial;
  final Payer payer;
  final ThemeData theme;
  final ColorScheme cs;
  final ValueChanged<Payer> onPayerChanged;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    final color = _denialColor(cs, denial);
    final risk = denial.revenueAtRisk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDetails,
          borderRadius: BorderRadius.circular(PsyRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(PsyRadius.md),
              border: Border.all(color: color.withValues(alpha: 0.32)),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${denial.level.label} · ${denial.cptCode}'
                    '${risk != null ? ' · ~\$${risk.round()} risk' : ''}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Payer>(
                    value: payer,
                    isDense: true,
                    icon: const Icon(Icons.expand_more, size: 16),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurface,
                    ),
                    items: [
                      for (final p in Payer.values)
                        DropdownMenuItem(value: p, child: Text(p.short)),
                    ],
                    onChanged: (p) => p == null ? null : onPayerChanged(p),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The right-hand "compliance" rail in the wide split view: audit-readiness
/// score + actions on top, Denial Shield (payer-aware risk, drivers, and the
/// one-click "update note & reset risk") below.
class _ComplianceRail extends StatelessWidget {
  const _ComplianceRail({
    required this.report,
    required this.denial,
    required this.payer,
    required this.deepChecking,
    required this.loadingInsights,
    required this.theme,
    required this.cs,
    required this.onDetails,
    required this.onDeepCheck,
    required this.onInsights,
    required this.onPayerChanged,
    required this.onApplyFixes,
  });

  final ComplianceReport? report;
  final DenialRisk? denial;
  final Payer payer;
  final bool deepChecking;
  final bool loadingInsights;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onDetails;
  final VoidCallback onDeepCheck;
  final VoidCallback onInsights;
  final ValueChanged<Payer> onPayerChanged;
  final VoidCallback onApplyFixes;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerLowest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (report != null) _audit(report!),
            if (report != null && denial != null) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: cs.outlineVariant),
              const SizedBox(height: 14),
            ],
            if (denial != null) _denialPanel(denial!),
          ],
        ),
      ),
    );
  }

  Widget _audit(ComplianceReport r) {
    final score = r.score;
    final color = score >= 80
        ? const Color(0xFF16A34A)
        : score >= 60
        ? const Color(0xFFD97706)
        : cs.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AUDIT READINESS',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$score%',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${r.toFixCount} to fix',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
        if (r.summary != null && r.summary!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            r.summary!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _railBtn(Icons.list_alt_outlined, 'Details', onDetails),
            _railBtn(
              deepChecking ? null : Icons.auto_awesome,
              deepChecking ? 'Checking…' : 'Deep check',
              deepChecking ? null : onDeepCheck,
            ),
            _railBtn(
              loadingInsights ? null : Icons.psychology_alt_outlined,
              loadingInsights ? 'Loading…' : 'Insights',
              loadingInsights ? null : onInsights,
            ),
          ],
        ),
      ],
    );
  }

  Widget _denialPanel(DenialRisk d) {
    final color = _denialColor(cs, d);
    final risk = d.revenueAtRisk;
    final canApply = d.reasons.any((r) => r.insertText != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.verified_user_outlined, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'DENIAL SHIELD',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            DropdownButton<Payer>(
              value: payer,
              isDense: true,
              underline: const SizedBox.shrink(),
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurface),
              items: [
                for (final p in Payer.values)
                  DropdownMenuItem(value: p, child: Text(p.short)),
              ],
              onChanged: (p) => p == null ? null : onPayerChanged(p),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          d.level.label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${d.cptCode} · ${d.cptLabel}'
          '${risk != null ? ' · ~\$${risk.round()} at risk' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        if (d.reasons.isEmpty)
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 16,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Documentation supports the billed code.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          )
        else
          ...d.reasons.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        r.critical
                            ? Icons.error_outline
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: r.critical ? cs.error : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          r.title,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 19, top: 2),
                    child: Text(
                      '+ ${r.fixSentence}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        height: 1.4,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (canApply) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onApplyFixes,
              icon: const Icon(Icons.auto_fix_high, size: 16),
              label: const Text('Update note & reset risk'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _railBtn(IconData? icon, String label, VoidCallback? onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon != null
          ? Icon(icon, size: 14)
          : const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}

class _AuditBanner extends StatelessWidget {
  const _AuditBanner({
    required this.report,
    required this.deepChecking,
    required this.theme,
    required this.cs,
    required this.onDetails,
    required this.onDeepCheck,
    required this.onInsights,
    required this.loadingInsights,
  });

  final ComplianceReport report;
  final bool deepChecking;
  final ThemeData theme;
  final ColorScheme cs;
  final VoidCallback onDetails;
  final VoidCallback onDeepCheck;
  final VoidCallback onInsights;
  final bool loadingInsights;

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor(report.score);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            'Audit readiness ${report.score}%',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (report.toFixCount > 0) ...[
            const SizedBox(width: 6),
            Text(
              '· ${report.toFixCount} to fix',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: loadingInsights ? null : onInsights,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: loadingInsights
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.school_outlined, size: 14),
            label: const Text('Insights'),
          ),
          TextButton(
            onPressed: onDetails,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Details'),
          ),
          if (report.source != ComplianceSource.ai)
            TextButton.icon(
              onPressed: deepChecking ? null : onDeepCheck,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: deepChecking
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 14),
              label: const Text('AI check'),
            ),
        ],
      ),
    );
  }
}

class _AuditSheet extends StatelessWidget {
  const _AuditSheet({required this.report});
  final ComplianceReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final color = _scoreColor(report.score);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_outlined, color: color),
                const SizedBox(width: 8),
                Text(
                  'Audit readiness · ${report.score}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  report.source == ComplianceSource.ai
                      ? 'AI review'
                      : 'Quick check',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            if (report.summary != null) ...[
              const SizedBox(height: 6),
              Text(
                report.summary!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: report.checks
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _checkIcon(c.status),
                                size: 18,
                                color: _checkColor(c.status),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.label,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (c.fix != null)
                                      Text(
                                        c.fix!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: cs.onSurface.withValues(
                                                alpha: 0.7,
                                              ),
                                              height: 1.4,
                                            ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Decision-support against the payer "golden thread" rubric — '
              'review clinically. Not a reimbursement guarantee.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.55),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _InsightsSheet moved to insights_sheet.dart (HIGH-3 god-file split).
