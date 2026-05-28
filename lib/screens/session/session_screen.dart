import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/copilot/soap_generator_service.dart';
import '../../services/data/auth_service.dart';
import '../../services/data/firebase_bootstrap.dart';
import '../../services/data/patient_repository.dart';
import '../../services/data/session_repository.dart';
import '../../services/data/telemetry_service.dart';
import '../../services/pdf_export_service.dart';
import '../../services/therapy_note_service.dart';
import '../../services/treatment_plan_service.dart';
import '../../widgets/copilot/live_ai_panel.dart';

class SessionScreen extends StatefulWidget {
  final String sessionId;
  final String clientId;
  final String clientName;

  const SessionScreen({
    super.key,
    required this.sessionId,
    required this.clientId,
    required this.clientName,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _aiPromptController = TextEditingController();
  String _aiSummary = '';
  List<String> _treatmentGoals = const [];

  // Seans durumu
  bool _isSessionActive = false;
  DateTime? _sessionStartTime;
  Duration _sessionDuration = Duration.zero;
  
  // Timer için
  late Timer _sessionTimer;

  @override
  void initState() {
    super.initState();
    _startSession();
    _loadGoals();
  }

  /// Load the patient's active treatment-plan goals so the AI note can tie
  /// back to them (the "golden thread").
  Future<void> _loadGoals() async {
    final svc = TreatmentPlanService();
    await svc.initialize();
    final plan = svc.getTreatmentPlanForPatient(widget.clientId);
    if (plan != null && mounted) {
      setState(() => _treatmentGoals =
          plan.activeGoals.map((g) => g.description).toList());
    }
  }

  @override
  void dispose() {
    _sessionTimer.cancel();
    _notesController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
      _sessionStartTime = DateTime.now();
    });
    
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
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  Future<void> _saveSessionNotes() async {
    final noteText = _notesController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedilecek bir seans notu bulunamadı')),
      );
      return;
    }

    try {
      final therapyNoteService = context.read<TherapyNoteService>();
      await therapyNoteService.createEntry(
        sessionId: widget.sessionId,
        clinicianId: 'demo_clinician',
        clientId: widget.clientId,
        templateId: 'session_note',
        values: {
          'notes': noteText,
          'aiSummary': _aiSummary,
          'aiPrompt': _aiPromptController.text.trim(),
          'sessionDuration': _sessionDuration.inSeconds,
          'savedAt': DateTime.now().toIso8601String(),
        },
      );

      await _persistToFirestore(noteText);
      TelemetryService.instance.capture(TelemetryEvents.sessionNoteSaved,
          properties: {'duration_s': _sessionDuration.inSeconds});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session note saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save note: $e')),
      );
    }
  }

  Future<void> _persistToFirestore(String noteText) async {
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
        format: SoapFormat.soap,
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
    } catch (_) {
      // Swallow — local save already succeeded; Firestore retry will be
      // handled by the offline persistence layer in a future sprint.
    }
  }

  Future<void> _exportToPDF() async {
    try {
      // PDF servisini import et
      final pdfService = PDFExportService();
      
      // PDF oluştur
      final pdfBytes = await pdfService.generateSessionPDF(
        clientName: widget.clientName,
        sessionId: widget.sessionId,
        sessionNotes: _notesController.text,
        aiSummary: _aiSummary,
        sessionDate: _sessionStartTime ?? DateTime.now(),
        sessionDuration: _sessionDuration,
        therapistName: 'Dr. Terapist', // TODO: Gerçek terapist adını al
      );
      
      // PDF'i yazdır
      await pdfService.printPDF(pdfBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generated successfully and sent to printer'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF generation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.clientName[0].toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.clientName,
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Session ID: ${widget.sessionId}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Seans süresi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isSessionActive ? Icons.timer : Icons.timer_off,
                  size: 16,
                  color: _isSessionActive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDuration(_sessionDuration),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Seans kontrol butonları
          if (_isSessionActive)
            IconButton(
              onPressed: _endSession,
              icon: const Icon(Icons.stop_circle),
              tooltip: 'End Session',
            )
          else
            IconButton(
              onPressed: _startSession,
              icon: const Icon(Icons.play_circle),
              tooltip: 'Start Session',
            ),
          IconButton(
            onPressed: _exportToPDF,
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'PDF Export',
          ),
        ],
      ),
      body: Row(
        children: [
          // Sol panel - Seans notu
          Expanded(
            flex: 2,
            child: _buildNotesPanel(),
          ),
          // Orta panel - AI özeti
          Expanded(
            flex: 1,
            child: _buildAIPanel(),
          ),
          // Sağ panel - Danışan bilgileri
          Expanded(
            flex: 1,
            child: _buildClientInfoPanel(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildNotesPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Session Note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _saveSessionNotes();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Not yazma alanı
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your session notes here...\n\nExample:\n- Client mood today\n- Main concerns\n- Techniques used\n- Next steps',
                  border: InputBorder.none,
                  alignLabelWithHint: true,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
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
      localeId: 'en_US',
      treatmentGoals: _treatmentGoals,
    );
  }


  Widget _buildClientInfoPanel() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel başlığı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Client Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Danışan bilgileri
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $item',
              style: const TextStyle(fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Klavye kısayolları bilgisi
          Expanded(
            child: Text(
              '💡 Shortcuts: Ctrl+S (Save) | Ctrl+P (PDF) | Ctrl+N (New)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          // Hızlı aksiyonlar
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today),
            label: const Text('Appointment'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.medical_services),
            label: const Text('Prescription'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.flag),
            label: const Text('Flag'),
          ),
        ],
      ),
    );
  }
}
