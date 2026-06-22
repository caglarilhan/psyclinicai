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
import 'audit_feedback.dart';
import 'insights_sheet.dart';
import 'panel_chrome.dart';
import 'panel_state_views.dart';
import 'risk_denial_strip.dart';

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

  PanelState _state = PanelState.idle;
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
          _state = PanelState.error;
          _errorMessage =
              'Microphone or speech recognition not available on this device.';
        });
        return;
      }
    }
    setState(() {
      _state = PanelState.listening;
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
        _state = PanelState.error;
        _errorMessage =
            'No speech detected. Try again with the microphone closer.';
      });
      return;
    }
    setState(() => _state = PanelState.generating);

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
        _state = PanelState.noteReady;
        _computeDenial();
      });
      unawaited(_persistNote(note));
    } on SoapGeneratorException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = PanelState.error;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = PanelState.error;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  Future<void> _cancelListening() async {
    await _transcription.cancel();
    setState(() {
      _state = PanelState.idle;
      _transcript = '';
      _partial = '';
    });
  }

  void _resetForNewSession() {
    _tier2Timer?.cancel();
    setState(() {
      _state = PanelState.idle;
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
                    color: denialColor(cs, d),
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
        builder: (_) => AuditSheet(report: report),
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
          PanelHeader(
            cs: cs,
            theme: theme,
            state: _state,
            pulse: _pulse,
            format: _format,
            onFormatChanged: _state == PanelState.idle
                ? (f) => setState(() => _format = f)
                : null,
            modality: _modality,
            onModalityChanged: _state == PanelState.idle
                ? (m) => setState(() => _modality = m)
                : null,
            onOpenSettings: () =>
                Navigator.of(context).pushNamed('/settings/api_keys'),
          ),
          Expanded(child: _buildBody(theme, cs)),
          PanelFooter(
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
      case PanelState.idle:
        return IdleView(theme: theme, cs: cs);
      case PanelState.listening:
        return Column(
          children: [
            if (_signals.isNotEmpty)
              RiskStrip(signals: _signals, theme: theme, cs: cs),
            Expanded(
              child: ListeningView(
                theme: theme,
                cs: cs,
                transcript: _transcript,
                partial: _partial,
              ),
            ),
          ],
        );
      case PanelState.generating:
        return GeneratingView(theme: theme, cs: cs, transcript: _transcript);
      case PanelState.noteReady:
        final noteView = NoteReadyView(
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
              RiskStrip(signals: _signals, theme: theme, cs: cs),
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
                        AuditBanner(
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
                        DenialBanner(
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
      case PanelState.error:
        return ErrorView(
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

// PanelHeader + PanelFooter + PanelState enum moved to panel_chrome.dart
// (HIGH-3 slice 5).
// State views (idle/listening/generating/noteReady/error) moved to
// panel_state_views.dart (HIGH-3 slice 4).
// RiskStrip + DenialBanner + denialColor moved to risk_denial_strip.dart
// (HIGH-3 slice 3).

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
    final color = denialColor(cs, d);
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
// _InsightsSheet moved to insights_sheet.dart (HIGH-3 god-file split).
