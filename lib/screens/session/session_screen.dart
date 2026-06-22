import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_format.dart';
import '../../services/copilot/soap_generator_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/session_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../services/pdf_export_service.dart';
import '../../services/therapy_note_service.dart';
import '../../services/treatment_plan_service.dart';
import '../../theme/tokens.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/copilot/live_ai_panel.dart';
import '../../widgets/ds/psy_snack.dart';
import '../../widgets/structured_note_editor.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.clientId,
    required this.clientName,
  });
  final String sessionId;
  final String clientId;
  final String clientName;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  /// Latest snapshot from [StructuredNoteEditor]. Null until the clinician
  /// types something; persisted on save via [StructuredNoteValue.markdown].
  StructuredNoteValue? _noteValue;
  final TextEditingController _aiPromptController = TextEditingController();
  final String _aiSummary = '';
  List<String> _treatmentGoals = const [];

  // Seans durumu
  bool _isSessionActive = false;
  DateTime? _sessionStartTime;
  Duration _sessionDuration = Duration.zero;

  // Session clock — a no-op sentinel until _startSession installs the real
  // periodic timer, so dispose() can always cancel safely (no late-init crash
  // if start ever fails before assignment).
  Timer _sessionTimer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    _startSession();
    unawaited(_loadGoals());
  }

  /// Load the patient's active treatment-plan goals so the AI note can tie
  /// back to them (the "golden thread").
  Future<void> _loadGoals() async {
    final svc = TreatmentPlanService();
    await svc.initialize();
    final plan = svc.getTreatmentPlanForPatient(widget.clientId);
    if (plan != null && mounted) {
      setState(
        () => _treatmentGoals = plan.activeGoals
            .map((g) => g.description)
            .toList(),
      );
    }
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    _aiPromptController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _sessionStartTime = DateTime.now();
    });

    _sessionTimer.cancel(); // never orphan a previous clock on restart
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionDuration = DateTime.now().difference(_sessionStartTime!);
        });
      }
    });
  }

  void _endSession() {
    setState(() {
      _isSessionActive = false;
    });
    _sessionTimer.cancel();

    // Seans sonlandırma dialog'u
    _showSessionEndDialog();
  }

  void _showSessionEndDialog() {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Session Ended'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Session duration: ${_formatDuration(_sessionDuration)}'),
              const SizedBox(height: 16),
              const Text('Do you want to save the session note?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveSessionNotes();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _saveSessionNotes() async {
    final snapshot = _noteValue;
    if (snapshot == null || snapshot.isEmpty) {
      PsySnack.info(
        context,
        'Kaydedilecek bir seans notu bulunamadı.',
        hint: 'session.save_empty',
      );
      return;
    }
    final markdown = snapshot.markdown;

    try {
      final therapyNoteService = context.read<TherapyNoteService>();
      await therapyNoteService.createEntry(
        sessionId: widget.sessionId,
        clinicianId: 'demo_clinician',
        clientId: widget.clientId,
        templateId: 'session_note',
        values: {
          'notes': markdown,
          'format': snapshot.format.id,
          'sections': snapshot.sections,
          'aiSummary': _aiSummary,
          'aiPrompt': _aiPromptController.text.trim(),
          'sessionDuration': _sessionDuration.inSeconds,
          'savedAt': DateTime.now().toIso8601String(),
        },
      );

      await _persistToFirestore(markdown, snapshot.format);
      unawaited(
        TelemetryService.instance.capture(
          TelemetryEvents.sessionNoteSaved,
          properties: {
            'duration_s': _sessionDuration.inSeconds,
            'format': snapshot.format.id,
          },
        ),
      );

      if (!mounted) return;
      PsySnack.success(
        context,
        'Session note saved.',
        hint: 'session.save',
      );
    } catch (e, st) {
      // Bare catch was swallowing the error to a generic snackbar.
      // Capture for telemetry so prod failures are diagnosable and
      // surface a retryable error via the DS vocabulary.
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'session.save_failed',
        ),
      );
      if (!mounted) return;
      PsySnack.error(
        context,
        'Could not save note — please retry.',
        hint: 'session.save_failed',
        action: SnackBarAction(label: 'Retry', onPressed: _saveSessionNotes),
      );
    }
  }

  /// Maps the editor-level [NoteFormat] (SOAP / BIRP / DAP) to the broader
  /// [SoapFormat] the persistence layer accepts (which also includes GIRP
  /// and a psychiatry variant managed by the AI generator).
  SoapFormat _toSoapFormat(NoteFormat f) => switch (f) {
    NoteFormat.soap => SoapFormat.soap,
    NoteFormat.birp => SoapFormat.birp,
    NoteFormat.dap => SoapFormat.dap,
  };

  Future<void> _persistToFirestore(String noteText, NoteFormat format) async {
    if (!PsyFirebase.isReady) return;
    final auth = FirebaseAuthService.instance;
    final profile = auth.profile;
    if (profile == null) return;
    try {
      await PatientRepository.instance.upsert(
        profile.clinicId,
        widget.clientId,
        PatientDraft(fullName: widget.clientName),
      );
      final sessionId = await SessionRepository.instance.createSession(
        clinicId: profile.clinicId,
        patientId: widget.clientId,
        clinicianId: profile.userId,
        startedAt: DateTime.now().subtract(_sessionDuration),
      );
      final note = SoapNote(
        rawMarkdown: noteText,
        format: _toSoapFormat(format),
        generatedAt: DateTime.now(),
      );
      await SessionRepository.instance.saveNote(
        clinicId: profile.clinicId,
        patientId: widget.clientId,
        sessionId: sessionId,
        note: note,
      );
      await SessionRepository.instance.endSession(
        clinicId: profile.clinicId,
        patientId: widget.clientId,
        sessionId: sessionId,
        endedAt: DateTime.now(),
        durationMinutes: _sessionDuration.inMinutes,
      );
    } catch (e, st) {
      // Local save already succeeded; Firestore retry will be handled
      // by the offline persistence layer in a future sprint. We
      // capture the error so the systemic break-rate is observable
      // until then — PHI scrubbing happens inside captureError.
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'session.firestore_persist',
        ),
      );
    }
  }

  /// The signing clinician for exports — the authenticated profile, with
  /// credentials when present (e.g. "Jane Smith, LCSW"). Falls back to a
  /// neutral label in demo mode where no profile is loaded.
  String get _therapistDisplayName {
    final p = FirebaseAuthService.instance.profile;
    if (p == null || p.fullName.trim().isEmpty) return 'Clinician';
    return p.credentials.trim().isEmpty
        ? p.fullName
        : '${p.fullName}, ${p.credentials}';
  }

  Future<void> _exportToPDF() async {
    try {
      // PDF servisini import et
      final pdfService = PDFExportService();

      // PDF oluştur
      final pdfBytes = await pdfService.generateSessionPDF(
        clientName: widget.clientName,
        sessionId: widget.sessionId,
        sessionNotes: _noteValue?.markdown ?? '',
        aiSummary: _aiSummary,
        sessionDate: _sessionStartTime ?? DateTime.now(),
        sessionDuration: _sessionDuration,
        therapistName: _therapistDisplayName,
      );

      // PDF'i yazdır
      await pdfService.printPDF(pdfBytes);

      if (!mounted) return;
      PsySnack.success(
        context,
        'PDF generated successfully and sent to printer.',
        hint: 'session.pdf_export',
      );
    } catch (e, st) {
      unawaited(
        TelemetryService.instance.captureError(
          e,
          st,
          hint: 'session.pdf_export_failed',
        ),
      );
      if (!mounted) return;
      PsySnack.error(
        context,
        'PDF generation error: $e',
        hint: 'session.pdf_export_failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      routeName: '/session',
      title: widget.clientName,
      subtitle: 'Session ID: ${widget.sessionId}',
      scrollable: false,
      child: Column(
        children: [
          _SessionControlBar(
            active: _isSessionActive,
            durationLabel: _formatDuration(_sessionDuration),
            onStartStop: _isSessionActive ? _endSession : _startSession,
            onExport: _exportToPDF,
          ),
          const SizedBox(height: PsySpacing.md),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Reflow below ~900px / at high zoom (WCAG 1.4.10): the three
                // panels stack instead of crushing into unreadable slivers.
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: _buildNotesPanel()),
                      Expanded(child: _buildAIPanel()),
                      Expanded(child: _buildClientInfoPanel()),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(flex: 3, child: _buildNotesPanel()),
                    Expanded(flex: 2, child: _buildAIPanel()),
                    Expanded(flex: 2, child: _buildClientInfoPanel()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPanel() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(PsySpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // Panel başlığı — neutral surface (was tinted teal). Only the
          // AI co-pilot panel below should carry the teal tint, per
          // critique: 'Session Note kartı beyaz olsun. Sadece AI paneli
          // açık teal olsun.'
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PsySpacing.lg,
              vertical: PsySpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: cs.onSurface.withValues(alpha: 0.75),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Session Note',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _saveSessionNotes,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Save'),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Structured editor — SOAP / BIRP / DAP with one field per
          // section. Snapshot piped to [_noteValue] for save + export.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Semantics(
                label: 'Structured session notes',
                child: StructuredNoteEditor(
                  initialFormat: _noteValue?.format ?? NoteFormat.soap,
                  initialSections: _noteValue?.sections ?? const {},
                  onChanged: (v) => setState(() => _noteValue = v),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel() {
    return LiveAiPanel(
      clientName: widget.clientName,
      patientId: widget.clientId,
      treatmentGoals: _treatmentGoals,
    );
  }

  Widget _buildClientInfoPanel() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(PsySpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(PsyRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(PsyRadius.md),
                topRight: Radius.circular(PsyRadius.md),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Client Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          // Danışan bilgileri — scrollable so it never overflows when stacked.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildInfoCard('Personal Info', [
                    'Name: ${widget.clientName}',
                    'ID: ${widget.clientId}',
                    'Session Date: ${DateTime.now().toString().split(' ')[0]}',
                    'Session Time: ${DateTime.now().toString().split(' ')[1].substring(0, 5)}',
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Session Status', [
                    'Status: ${_isSessionActive ? "Active" : "Inactive"}',
                    'Start: ${_sessionStartTime?.toString().split(' ')[1].substring(0, 5) ?? "Not started"}',
                    'Duration: ${_formatDuration(_sessionDuration)}',
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('Quick Access', [
                    'Previous Sessions',
                    'Treatment Plan',
                    'Medication List',
                    'Emergency Contact',
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<String> items) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(PsyRadius.sm),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $item', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Session control bar: timer state, start/stop, export, and quick nav —
/// surfaced inside the AppShell body (the screen no longer has a bare AppBar).
class _SessionControlBar extends StatelessWidget {
  const _SessionControlBar({
    required this.active,
    required this.durationLabel,
    required this.onStartStop,
    required this.onExport,
  });

  final bool active;
  final String durationLabel;
  final VoidCallback onStartStop;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final timerTint = active ? cs.primary : cs.onSurfaceVariant;
    return LayoutBuilder(
      builder: (context, c) {
        // Mobile (<560): timer + primary action + overflow menu (Export PDF,
        // Appointments, Prescriptions). Stops Export PDF from being cut off
        // at the right edge and calms the secondary actions, per feedback.
        final compact = c.maxWidth < 560;
        final timer = Semantics(
          label: active ? 'Session live, $durationLabel' : 'Session ended',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.timer : Icons.timer_off,
                size: 18,
                color: timerTint,
              ),
              const SizedBox(width: PsySpacing.xs),
              Text(
                '${active ? 'Live' : 'Ended'} · $durationLabel',
                style: TextStyle(fontWeight: FontWeight.w700, color: timerTint),
              ),
            ],
          ),
        );
        final startStop = FilledButton.icon(
          onPressed: onStartStop,
          icon: Icon(active ? Icons.stop_circle : Icons.play_circle),
          label: Text(active ? 'End session' : 'Start session'),
          style: FilledButton.styleFrom(
            backgroundColor: active ? cs.error : cs.primary,
            // Slightly tighter on mobile so the red CTA reads as "important"
            // without dominating the toolbar width.
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 10 : 12,
            ),
          ),
        );
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: PsySpacing.md,
            vertical: PsySpacing.sm,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(PsyRadius.md),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              timer,
              const Spacer(),
              startStop,
              const SizedBox(width: PsySpacing.sm),
              if (compact)
                PopupMenuButton<_SessionAction>(
                  tooltip: 'More',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (a) {
                    switch (a) {
                      case _SessionAction.export:
                        onExport();
                        break;
                      case _SessionAction.appointments:
                        unawaited(
                          Navigator.of(context).pushNamed('/appointments'),
                        );
                        break;
                      case _SessionAction.prescriptions:
                        unawaited(
                          Navigator.of(context).pushNamed('/e_prescription'),
                        );
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _SessionAction.export,
                      child: ListTile(
                        leading: Icon(Icons.picture_as_pdf),
                        title: Text('Export PDF'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _SessionAction.appointments,
                      child: ListTile(
                        leading: Icon(Icons.calendar_today),
                        title: Text('Appointments'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: _SessionAction.prescriptions,
                      child: ListTile(
                        leading: Icon(Icons.medical_services),
                        title: Text('Prescriptions'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )
              else ...[
                OutlinedButton.icon(
                  onPressed: onExport,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF'),
                ),
                const SizedBox(width: PsySpacing.sm),
                IconButton(
                  tooltip: 'Appointments',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/appointments'),
                  icon: const Icon(Icons.calendar_today),
                ),
                IconButton(
                  tooltip: 'Prescriptions',
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/e_prescription'),
                  icon: const Icon(Icons.medical_services),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Mobile overflow-menu actions for the session control bar — keeps
/// secondary actions reachable without crowding the top row.
enum _SessionAction { export, appointments, prescriptions }
