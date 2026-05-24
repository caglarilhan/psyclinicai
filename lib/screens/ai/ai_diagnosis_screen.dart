import 'package:flutter/material.dart';
import '../../models/homework_assignment.dart';
import 'package:provider/provider.dart';
import '../../services/patient_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/homework_service.dart';
import '../../services/homework_template_service.dart';
import '../../services/ai_homework_generator.dart';
import '../../services/region_service.dart';
import 'package:flutter/services.dart';
import '../../services/role_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AIDiagnosisScreen extends StatefulWidget {
  const AIDiagnosisScreen({super.key});

  @override
  State<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends State<AIDiagnosisScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _historyController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();
  final List<_UploadedItem> _uploads = [];
  
  bool _isAnalyzing = false;
  AIAnalysisResult? _analysisResult;
  final List<AIAnalysisResult> _history = [];
  
  // Hasta seçimi
  String? _selectedPatientId;
  
  final List<String> _commonSymptoms = [
    'Sadness',
    'Anxiety',
    'Panic attack',
    'Insomnia',
    'Loss of appetite',
    'Fatigue',
    'Concentration difficulty',
    'Irritability',
    'Hopelessness',
    'Guilt',
    'Worthlessness',
    'Suicidal thoughts',
    'Social isolation',
    'Substance use',
    'Trauma',
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI-Powered Diagnosis'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/landing');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.psychology_alt), text: 'Diagnosis'),
            Tab(icon: Icon(Icons.smart_toy), text: 'Chat'),
            Tab(icon: Icon(Icons.warning_amber_rounded), text: 'Risk Analysis'),
            Tab(icon: Icon(Icons.medical_services), text: 'Treatment'),
          ],
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1) Tanı Asistanı
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hasta Seçimi
                Card(
                  color: Colors.purple[800],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Selection',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedPatientId,
                          decoration: InputDecoration(
                            labelText: 'Select Patient',
                            labelStyle: const TextStyle(color: Colors.white70),
                            prefixIcon: const Icon(Icons.person, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                          dropdownColor: Colors.purple[800],
                          style: const TextStyle(color: Colors.white),
                          items: [
                            ...context.read<PatientService>().patients.map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name, style: const TextStyle(color: Colors.white)),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPatientId = value;
                            });
                          },
                        ),
                        if (_selectedPatientId != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Selected Patient: ${context.read<PatientService>().getById(_selectedPatientId!)?.name ?? ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Dosya Yükleme
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAddFileSheet,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Add File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _selectedPatientId==null ? null : (){
                        Navigator.pushNamed(context, '/appointment');
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text('Appointment'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple[800],
                        side: BorderSide(color: Colors.purple[800]!),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: (_selectedPatientId==null || _analysisResult==null) ? null : _addTreatmentHomework,
                      icon: const Icon(Icons.task_alt),
                      label: const Text('Homework'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple[800],
                        side: BorderSide(color: Colors.purple[800]!),
                      ),
                    ),
                    if (_uploads.isNotEmpty)
                      Text('${_uploads.length} dosya eklendi', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 12),
                if (_uploads.isNotEmpty) _buildUploadsList(),
                const SizedBox(height: 16),
            // AI Asistan Kartı
            Card(
              color: Colors.purple[800],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology_alt,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Diagnosis Assistant',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Analyzes patient symptoms and suggests evidence-based diagnoses',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Card(
              color: Colors.purple[600],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _showAnalysisHistory,
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('History'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _analysisResult == null ? null : _exportAnalysisPdf,
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _analysisResult == null ? null : _exportAnalysisHtml,
                      icon: const Icon(Icons.html, size: 16),
                      label: const Text('HTML'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _analysisResult == null ? null : _addToNotes,
                      icon: const Icon(Icons.note_add_outlined, size: 16),
                      label: const Text('Add Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/diagnosis-guide'),
                      icon: const Icon(Icons.menu_book_outlined, size: 16),
                      label: const Text('Guide'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectedPatientId == null ? null : _generateAISuggestions,
                      icon: const Icon(Icons.auto_awesome, size: 16),
                      label: const Text('AI Homework'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showHelpDialog,
                      icon: const Icon(Icons.help, size: 16),
                      label: const Text('Help'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple[800],
                        minimumSize: const Size(80, 36),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Semptomlar Bölümü
            Text(
              'Symptoms',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the symptoms the patient is experiencing:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            
            // Yaygın Semptomlar
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((symptom) {
                return FilterChip(
                  label: Text(symptom, style: const TextStyle(color: Colors.white)),
                  selected: _symptomsController.text.contains(symptom),
                  backgroundColor: Colors.purple[600],
                  selectedColor: Colors.purple[400],
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_symptomsController.text.isEmpty) {
                          _symptomsController.text = symptom;
                        } else {
                          _symptomsController.text += ', $symptom';
                        }
                      } else {
                        _symptomsController.text = _symptomsController.text
                            .replaceAll(symptom, '')
                            .replaceAll(', ,', ',')
                            .replaceAll(RegExp(r'^,\s*'), '')
                            .replaceAll(RegExp(r',\s*$'), '');
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _symptomsController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Semptomlar',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'Describe the patient\'s symptoms in detail...',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                prefixIcon: const Icon(Icons.medical_services, color: Colors.white70),
                filled: true,
                fillColor: Colors.purple[800]?.withOpacity(0.3),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Geçmiş Bölümü
            Text(
              'Patient History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _historyController,
              decoration: InputDecoration(
                labelText: 'History',
                hintText: 'Past treatments, family history, medication use...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.history),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Gözlemler Bölümü
            Text(
              'Clinical Observations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observationsController,
              decoration: InputDecoration(
                labelText: 'Observations',
                hintText: 'Patient appearance, behavior, speech observations...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.visibility),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Analiz Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isAnalyzing || _selectedPatientId == null) ? null : _analyzeSymptoms,
                icon: _isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.psychology_alt),
                label: Text(_isAnalyzing ? 'Analyzing...' : 'Start AI Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_selectedPatientId == null) ...[
              const SizedBox(height: 8),
              Text(
                'Please select a patient first',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Analiz Sonuçları
                if (_analysisResult != null) _buildAnalysisResult(),
              ],
            ),
          ),

          // 2) Sohbet (AI Asistan)
          _buildChatTab(context),

          // 3) Risk Analizi (özet)
          _buildRiskOnlyTab(context),

          // 4) Tedavi Önerici
          _buildTreatmentAdvisorTab(context),
        ],
      ),
    );
  }

  Future<void> _addTreatmentHomework() async {
    if (_selectedPatientId == null) return;
    // Demo: CBT düşünce kaydı ödevi
    final svc = HomeworkService();
    await svc.assign(
      clientId: _selectedPatientId!,
      clinicianId: 'demo_clinician',
      templateId: 'cbt_thought_record',
      customInstructions: 'Haftada 3 kayıt oluşturun. Otomatik düşünce → kanıtlar → alternatif düşünce.',
      dueDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ödev eklendi: CBT Düşünce Kaydı')),
      );
    }
  }

  Future<void> _generateAISuggestions() async {
    if (_selectedPatientId == null) return;
    
    // Semptomları analiz et
    final symptoms = _symptomsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    
    // AI ödev önerileri oluştur
    final generator = AIHomeworkGenerator();
    final suggestions = await generator.generateSmartAssignments(
      patientId: _selectedPatientId!,
      primaryDiagnosis: _analysisResult?.possibleDiagnoses.isNotEmpty == true 
          ? _analysisResult!.possibleDiagnoses.first.name 
          : 'Genel',
      symptoms: symptoms,
      difficulty: 'Orta',
      maxDuration: 30,
      count: 3,
    );
    
    if (mounted) {
      _showAISuggestionsDialog(suggestions);
    }
  }

  void _showAISuggestionsDialog(List<HomeworkAssignment> suggestions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤖 AI Ödev Önerileri'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hastanın semptomlarına göre ${suggestions.length} ödev önerisi:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...suggestions.map((assignment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _getCategoryIcon(assignment.category),
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(assignment.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assignment.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(assignment.difficulty),
                            backgroundColor: _getDifficultyColor(assignment.difficulty),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${assignment.estimatedDuration} dk'),
                            backgroundColor: Colors.grey[200],
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addSuggestedAssignment(assignment),
                  ),
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addAllSuggestions(suggestions);
            },
            child: const Text('Hepsini Ekle'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Depresyon': return Icons.mood_bad;
      case 'Anksiyete': return Icons.psychology;
      case 'Travma': return Icons.healing;
      case 'Genel': return Icons.assignment;
      default: return Icons.task_alt;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Kolay': return Colors.green[200]!;
      case 'Orta': return Colors.orange[200]!;
      case 'Zor': return Colors.red[200]!;
      default: return Colors.grey[200]!;
    }
  }

  Future<void> _addSuggestedAssignment(HomeworkAssignment assignment) async {
    final svc = HomeworkService();
    await svc.addAssignment(assignment);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ödev eklendi: ${assignment.title}')),
      );
    }
  }

  Future<void> _addAllSuggestions(List<HomeworkAssignment> suggestions) async {
    final svc = HomeworkService();
    for (var assignment in suggestions) {
      await svc.addAssignment(assignment);
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${suggestions.length} ödev eklendi')),
      );
    }
  }

  Future<void> _exportAnalysisPdf() async {
    if (_analysisResult == null) return;
    final r = _analysisResult!;
    final reportId = DateTime.now().microsecondsSinceEpoch.toString();
    final pseudo = r.patientName == null ? '-' : (context.read<PatientService>().getById(r.patientId!)?.name ?? r.patientName!);
    final role = context.read<RoleService>().currentRole;
    final region = context.read<RegionService>().currentRegionCode;
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('AI Tanı Raporu', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
            pw.SizedBox(height: 8),
            pw.Text('Hasta: ' + (r.patientName ?? '-')),
            pw.Text('Takma Ad: ' + pseudo),
            pw.Text('Tarih: ' + DateFormat('dd.MM.yyyy HH:mm').format(r.analysisDate)),
            pw.Text('Rapor ID: ' + reportId),
            pw.Text('Uzmanlık: ' + role + ' • Bölge: ' + region),
            pw.SizedBox(height: 12),
            pw.Text('Risk: ' + r.riskLevel.toString().split('.').last.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(r.riskAssessment),
            pw.SizedBox(height: 12),
            pw.Text('Olası Tanılar', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...r.possibleDiagnoses.map((d)=> pw.Bullet(text: d.name + ' (' + d.code + ') - ' + d.confidence.toString() + '%')),
            pw.SizedBox(height: 12),
            pw.Text('Öneriler', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ...r.recommendations.map((s)=> pw.Bullet(text: s)),
            if (r.importantNotes.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              pw.Text('Önemli Notlar', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
              pw.Text(r.importantNotes),
            ],
          ],
        ),
      ),
    ));
    final bytes = await pdf.save();
    // Demo: hastanın belgelerine kaydet
    if (r.patientId != null) {
      await context.read<PatientService>().addDoc(PatientDoc(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: r.patientId!,
        name: 'AI_Tani_Raporu_' + DateFormat('yyyyMMdd_HHmm').format(DateTime.now()) + '.pdf',
        mimeType: 'application/pdf',
        createdAt: DateTime.now(),
        data: bytes,
      ));
    }
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  Future<void> _exportAnalysisHtml() async {
    final r = _analysisResult!;
    final clinician = context.read<RoleService>().currentRole ?? 'Klinisyen';
    final reportId = DateTime.now().microsecondsSinceEpoch.toString();
    final region = context.read<RegionService>().currentRegionCode;
    final html = StringBuffer()
      ..writeln('<style>body{font-family:Arial,Helvetica,sans-serif;padding:16px;} h2{color:#6D4AFF} .badge{display:inline-block;padding:2px 6px;border-radius:6px;background:#eee} .card{border:1px solid #eee;border-radius:8px;padding:12px;margin:8px 0} .header{display:flex;align-items:center;gap:12px;margin-bottom:8px}</style>')
      ..writeln('<div class="header"><img src="https://dummyimage.com/48x48/6D4AFF/ffffff&text=AI" width="48" height="48"/><h2>AI Tanı Raporu</h2></div>')
      ..writeln('<div class="card"><b>Kurum:</b> PsyClinic AI • <b>Rapor ID:</b> '+reportId+'</div>')
      ..writeln('<div class="card"><b>Düzenleyen:</b> '+clinician+' • <b>Bölge:</b> '+region+'</div>')
      ..writeln('<p><b>Hasta:</b> ${r.patientName ?? '-'}<br/><b>Tarih:</b> ${DateFormat('dd.MM.yyyy HH:mm').format(r.analysisDate)}</p>')
      ..writeln('<p><b>Risk:</b> <span class="badge">${r.riskLevel.toString().split('.').last.toUpperCase()}</span></p>')
      ..writeln('<p>${r.riskAssessment}</p>')
      ..writeln('<h3>Olası Tanılar</h3><ul>')
      ..writeln(r.possibleDiagnoses.map((d)=> '<li>${d.name} (${d.code}) - ${d.confidence}%</li>').join())
      ..writeln('</ul><h3>Öneriler</h3><ul>')
      ..writeln(r.recommendations.map((s)=> '<li>${s}</li>').join())
      ..writeln('</ul>');
    if (r.importantNotes.isNotEmpty) {
      html.writeln('<h3 style="color:red">Önemli Notlar</h3><p>${r.importantNotes}</p>');
    }
    await Clipboard.setData(ClipboardData(text: html.toString()));
    // Demo: belge olarak da kaydet
    if (r.patientId != null) {
      await context.read<PatientService>().addDoc(PatientDoc(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: r.patientId!,
        name: 'AI_Tani_Raporu_' + DateFormat('yyyyMMdd_HHmm').format(DateTime.now()) + '.html',
        mimeType: 'text/html',
        createdAt: DateTime.now(),
        data: utf8.encode(html.toString()),
      ));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('HTML pano kopyalandı')),
      );
    }
  }

  Future<void> _addToNotes() async {
    final r = _analysisResult!;
    final note = StringBuffer()
      ..writeln('AI Tanı Notu — ${DateFormat('dd.MM.yyyy HH:mm').format(r.analysisDate)}')
      ..writeln('Hasta: ${r.patientName ?? '-'}')
      ..writeln('Risk: ${r.riskLevel.toString().split('.').last.toUpperCase()}')
      ..writeln('Olası tanılar: ${r.possibleDiagnoses.map((d)=> d.name).join(', ')}')
      ..writeln('Öneriler: ${r.recommendations.join('; ')}');
    await Clipboard.setData(ClipboardData(text: note.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not şablonu panoya kopyalandı (demo)')),
      );
    }
  }

  Widget _buildUploadsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yüklenen Dosyalar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._uploads.asMap().entries.map((e) {
              final index = e.key; final item = e.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(_iconForType(item.type), color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Switch(
                      value: item.includeInAnalysis,
                      onChanged: (v){ setState(()=> item.includeInAnalysis = v); },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Semptomlara ekle',
                      icon: const Icon(Icons.add_comment),
                      onPressed: (){
                        setState((){
                          final txt = item.extractedText.trim();
                          if (txt.isNotEmpty) {
                            _symptomsController.text = (_symptomsController.text + '\n' + txt).trim();
                          }
                        });
                      },
                    ),
                    IconButton(
                      tooltip: 'Sil',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: (){ setState(()=> _uploads.removeAt(index)); },
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddFileSheet() {
    final nameCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    String type = 'pdf';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx){
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16, right: 16, top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.upload_file),
                  const SizedBox(width: 8),
                  Text('Dosya Ekle', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'pdf', child: Text('PDF/Word')),
                      DropdownMenuItem(value: 'image', child: Text('Görüntü')),
                      DropdownMenuItem(value: 'audio', child: Text('Ses/Video')),
                    ],
                    onChanged: (v){ if(v!=null) { type = v; (ctx as Element).markNeedsBuild(); } },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosya Adı',
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Metin/Özet (otomatik çıkarım simüle)',
                  hintText: 'PDF/OCR/konuşma metni buraya gelir...\nAnalize eklemek için bu metin kullanılacak.',
                  prefixIcon: Icon(Icons.text_snippet),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  TextButton(onPressed: ()=> Navigator.pop(ctx), child: const Text('Vazgeç')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: (){
                      if(nameCtrl.text.trim().isEmpty){
                        Navigator.pop(ctx);
                        return;
                      }
                      setState((){
                        _uploads.add(_UploadedItem(
                          name: nameCtrl.text.trim(),
                          type: type,
                          extractedText: textCtrl.text.trim(),
                          includeInAnalysis: true,
                        ));
                      });
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Ekle'),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  IconData _iconForType(String t){
    switch(t){
      case 'pdf': return Icons.picture_as_pdf;
      case 'image': return Icons.image;
      case 'audio': return Icons.audiotrack;
      default: return Icons.insert_drive_file;
    }
  }

  Widget _buildChatTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Sohbet', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: const [
                ListTile(title: Text('AI: Size nasıl yardımcı olabilirim?')),
              ],
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: 'Soru/komut yazın... (örn. “Bu semptomlarla olası tanılar?”)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: const Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskOnlyTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Risk Analizi', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_analysisResult != null) _buildRiskAssessment() else const Text('Önce Tanı sekmesinde analiz yapın.'),
        ],
      ),
    );
  }

  Widget _buildTreatmentAdvisorTab(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tedavi Önerici', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_analysisResult != null) _buildRecommendations() else const Text('Önce Tanı sekmesinde analiz yapın.'),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Analiz Sonuçları',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Risk Değerlendirmesi
            _buildRiskAssessment(),
            const SizedBox(height: 16),
            
            // Olası Tanılar
            _buildPossibleDiagnoses(),
            const SizedBox(height: 16),
            
            // Öneriler
            _buildRecommendations(),
            const SizedBox(height: 16),
            
            // Önemli Notlar
            if (_analysisResult!.importantNotes.isNotEmpty) ...[
              _buildImportantNotes(),
              const SizedBox(height: 16),
            ],
            
            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveAnalysis,
                icon: const Icon(Icons.save),
                label: const Text('Analizi Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    final theme = Theme.of(context);
    Color riskColor;
    String riskText;
    
    switch (_analysisResult!.riskLevel) {
      case RiskLevel.low:
        riskColor = Colors.green;
        riskText = 'Düşük Risk';
        break;
      case RiskLevel.medium:
        riskColor = Colors.orange;
        riskText = 'Orta Risk';
        break;
      case RiskLevel.high:
        riskColor = Colors.red;
        riskText = 'Yüksek Risk';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: riskColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: riskColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Risk Değerlendirmesi: $riskText',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _analysisResult!.riskAssessment,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPossibleDiagnoses() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olası Tanılar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._analysisResult!.possibleDiagnoses.map((diagnosis) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${diagnosis.name} (${diagnosis.code}) - ${diagnosis.confidence}%',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecommendations() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Öneriler',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._analysisResult!.recommendations.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildImportantNotes() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Önemli Notlar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _analysisResult!.importantNotes,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _analyzeSymptoms() async {
    if (_symptomsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir semptom girin')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    // Simüle edilmiş AI analizi
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isAnalyzing = false;
      _analysisResult = _generateMockAnalysis();
      // Hasta ve zaman bilgisi iliştir
      _analysisResult = _analysisResult!.copyWith(
        patientId: _selectedPatientId,
        patientName: (_selectedPatientId==null) ? null : context.read<PatientService>().getById(_selectedPatientId!)?.name,
      );
      _history.insert(0, _analysisResult!);
    });
  }

  AIAnalysisResult _generateMockAnalysis() {
    final symptoms = _symptomsController.text.toLowerCase();
    
    // Basit semptom analizi
    RiskLevel riskLevel = RiskLevel.low;
    String riskAssessment = 'Hasta genel olarak stabil görünüyor.';
    List<Diagnosis> possibleDiagnoses = [];
    List<String> recommendations = [];
    String importantNotes = '';

    if (symptoms.contains('intihar') || symptoms.contains('ölüm')) {
      riskLevel = RiskLevel.high;
      riskAssessment = 'Yüksek risk: İntihar düşüncesi mevcut. Acil müdahale gerekebilir.';
      importantNotes = 'Hasta yakından takip edilmeli ve gerekirse acil servise yönlendirilmelidir.';
    } else if (symptoms.contains('panik') || symptoms.contains('anksiyete')) {
      riskLevel = RiskLevel.medium;
      riskAssessment = 'Orta risk: Anksiyete belirtileri mevcut.';
    }

    if (symptoms.contains('üzüntü') && symptoms.contains('umutsuzluk')) {
      possibleDiagnoses.add(Diagnosis('Depresyon', 'F32.1', 85));
    }
    if (symptoms.contains('anksiyete') || symptoms.contains('panik')) {
      possibleDiagnoses.add(Diagnosis('Anksiyete Bozukluğu', 'F41.1', 75));
    }
    if (symptoms.contains('travma')) {
      possibleDiagnoses.add(Diagnosis('PTSD', 'F43.1', 70));
    }

    recommendations.add('Detaylı psikiyatrik değerlendirme yapılmalı');
    recommendations.add('Hasta güvenliği planı oluşturulmalı');
    recommendations.add('Aile ile iletişim kurulmalı');
    recommendations.add('İlaç tedavisi değerlendirilmeli');

    return AIAnalysisResult(
      riskLevel: riskLevel,
      riskAssessment: riskAssessment,
      possibleDiagnoses: possibleDiagnoses,
      recommendations: recommendations,
      importantNotes: importantNotes,
      analysisDate: DateTime.now(),
    );
  }

  void _saveAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analiz kaydedildi')),
    );
  }

  void _showAnalysisHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analiz Geçmişi'),
        content: SizedBox(
          width: 500,
          child: _history.isEmpty
              ? const Text('Henüz analiz yok.')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, i) {
                    final h = _history[i];
                    return ListTile(
                      leading: Icon(
                        h.riskLevel == RiskLevel.high
                            ? Icons.block
                            : h.riskLevel == RiskLevel.medium
                                ? Icons.warning_amber_rounded
                                : Icons.verified,
                        color: h.riskLevel == RiskLevel.high
                            ? Colors.red
                            : h.riskLevel == RiskLevel.medium
                                ? Colors.orange
                                : Colors.green,
                      ),
                      title: Text(h.patientName ?? 'Seçili Hasta Yok'),
                      subtitle: Text(
                        'Tarih: ' + DateFormat('dd.MM.yyyy HH:mm').format(h.analysisDate) + ' • Olası: ' + (h.possibleDiagnoses.isNotEmpty ? h.possibleDiagnoses.first.name : '-')
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Tanı Asistanı Yardım'),
        content: const SingleChildScrollView(
          child: Text(
            'AI Tanı Asistanı, hastanın semptomlarını analiz ederek:\n\n'
            '• Risk değerlendirmesi yapar\n'
            '• Olası tanıları önerir\n'
            '• Tedavi önerileri sunar\n'
            '• Önemli notları belirtir\n\n'
            'Bu araç sadece destekleyici bir rol oynar ve kesin tanı koymaz. '
            'Son karar her zaman klinisyene aittir.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _historyController.dispose();
    _observationsController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

// AI Analiz Sonucu Modeli
class AIAnalysisResult {
  final RiskLevel riskLevel;
  final String riskAssessment;
  final List<Diagnosis> possibleDiagnoses;
  final List<String> recommendations;
  final String importantNotes;
  final DateTime analysisDate;
  final String? patientId;
  final String? patientName;

  AIAnalysisResult({
    required this.riskLevel,
    required this.riskAssessment,
    required this.possibleDiagnoses,
    required this.recommendations,
    required this.importantNotes,
    required this.analysisDate,
    this.patientId,
    this.patientName,
  });

  AIAnalysisResult copyWith({
    RiskLevel? riskLevel,
    String? riskAssessment,
    List<Diagnosis>? possibleDiagnoses,
    List<String>? recommendations,
    String? importantNotes,
    DateTime? analysisDate,
    String? patientId,
    String? patientName,
  }) {
    return AIAnalysisResult(
      riskLevel: riskLevel ?? this.riskLevel,
      riskAssessment: riskAssessment ?? this.riskAssessment,
      possibleDiagnoses: possibleDiagnoses ?? this.possibleDiagnoses,
      recommendations: recommendations ?? this.recommendations,
      importantNotes: importantNotes ?? this.importantNotes,
      analysisDate: analysisDate ?? this.analysisDate,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
    );
  }
}

class Diagnosis {
  final String name;
  final String code;
  final int confidence;

  Diagnosis(this.name, this.code, this.confidence);
}

enum RiskLevel {
  low,
  medium,
  high,
}

class _UploadedItem {
  final String name;
  final String type; // pdf | image | audio
  final String extractedText;
  bool includeInAnalysis;

  _UploadedItem({
    required this.name,
    required this.type,
    required this.extractedText,
    required this.includeInAnalysis,
  });
}
