import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/denial_risk.dart';
import '../../models/session_note.dart';
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
import '../../services/data/risk_signal_repository.dart';
import '../../services/data/session_note_repository.dart';
import '../ds/psy_snack.dart';
import 'ai_disclaimer.dart';
import 'audit_feedback.dart';
import 'compliance_rail.dart';
import 'insights_sheet.dart';
import 'live_ai_panel_details.dart';
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
  final _signalRepo = RiskSignalRepository();
  final _lensService = ClinicalLensService();
  final _supervision = SupervisionService();
  bool _editing = false;
  bool _loadingLens = false;
  bool _loadingSupervision = false;

  /// Per-listening-burst session id. Generated on _startListening so
  /// every persisted risk signal can be grouped + replayed under the
  /// same key. Format is millisUtc-randomSuffix — no PHI, stable.
  String? _sessionId;
  int _signalSerial = 0;

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
    await _signalRepo.initialize();
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
    _persistSignals(fresh);
  }

  void _persistSignals(List<RiskSignal> fresh) {
    final sid = _sessionId;
    if (sid == null) return;
    for (final s in fresh) {
      _signalSerial++;
      final id = '$sid#${_signalSerial.toString().padLeft(4, '0')}';
      unawaited(
        _signalRepo.save(
          PersistedRiskSignal(
            id: id,
            sessionId: sid,
            patientId: widget.patientId,
            category: s.category,
            severity: s.severity,
            matchedText: s.matchedText,
            snippet: s.snippet,
            source: s.source,
            at: s.at,
          ),
        ),
      );
    }
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
      _signalSerial = 0;
      _sessionId =
          'ses-${DateTime.now().toUtc().millisecondsSinceEpoch}-'
          '${(widget.patientId ?? 'anon').hashCode.toUnsigned(16).toRadixString(16)}';
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
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey ? 'live_ai.insights_no_key' : 'live_ai.insights_failed',
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'),
              )
            : null,
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
      showSupervisionSheet(context, report);
    } on SupervisionException catch (e) {
      if (!context.mounted) return;
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey
            ? 'live_ai.supervision_no_key'
            : 'live_ai.supervision_failed',
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'),
              )
            : null,
      );
    } finally {
      if (mounted) setState(() => _loadingSupervision = false);
    }
  }

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
      showClinicalLensSheet(context, lens);
    } on ClinicalLensException catch (e) {
      if (!context.mounted) return;
      PsySnack.error(
        context,
        e.message,
        hint: e.noKey ? 'live_ai.lens_no_key' : 'live_ai.lens_failed',
        action: e.noKey
            ? SnackBarAction(
                label: 'API keys',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/settings/api_keys'),
              )
            : null,
      );
    } finally {
      if (mounted) setState(() => _loadingLens = false);
    }
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
            AiDisclaimer.compact(surface: 'live_panel_listening'),
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
        final innerNote = NoteReadyView(
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
        final noteView = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: AiDisclaimer.full(
                surface: 'soap_draft',
                draftedLabel: 'AI-drafted SOAP note',
              ),
            ),
            Expanded(child: innerNote),
          ],
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
                          child: ComplianceRail(
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
                          onDetails: () {
                            final d = _denial;
                            if (d == null) return;
                            showDenialDetailsSheet(
                              context,
                              denial: d,
                              onApplyFixes: _applyDenialFixes,
                            );
                          },
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

// HIGH-3 (audit 2026-06-21) — god-file split. The pieces below
// used to live inline; they now sit next to this file:
//   * insights_sheet.dart    — _InsightsSheet (slice 1)
//   * audit_feedback.dart    — AuditBanner + AuditSheet + helpers (slice 2)
//   * risk_denial_strip.dart — RiskStrip + DenialBanner + denialColor (slice 3)
//   * panel_state_views.dart — Idle/Listening/Generating/NoteReady/Error (slice 4)
//   * panel_chrome.dart      — PanelHeader + PanelFooter + PanelState (slice 5)
//   * compliance_rail.dart   — ComplianceRail (slice 6)
