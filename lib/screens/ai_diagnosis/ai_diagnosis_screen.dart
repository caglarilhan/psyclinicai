import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/diagnosis_models.dart';
import '../../services/ai_diagnosis_service.dart';
import '../../utils/theme.dart';
import '../../widgets/ai_diagnosis/ai_diagnosis_panel.dart';

class AIDiagnosisScreen extends StatefulWidget {
  final String clientId;
  final String therapistId;

  const AIDiagnosisScreen({
    super.key,
    required this.clientId,
    required this.therapistId,
  });

  @override
  State<AIDiagnosisScreen> createState() => _AIDiagnosisScreenState();
}

class _AIDiagnosisScreenState extends State<AIDiagnosisScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _analysisAnimationController;
  late Animation<double> _fadeAnimation;

  final AIDiagnosisService _aiService = AIDiagnosisService();
  
  // State variables
  List<Symptom> _symptoms = [];
  DiagnosisResult? _lastResult;
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  String _analysisMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _analysisAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _analysisAnimationController, curve: Curves.easeInOut),
    );

    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _analysisAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isAnalyzing = true);

    try {
      await _aiService.initialize();
      
      // Load mock symptoms for demonstration
      _loadMockSymptoms();
      
      _analysisAnimationController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Diagnosis servisi başlatılamadı: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _loadMockSymptoms() {
    _symptoms = [
      Symptom(
        id: '1',
        name: 'Depresif ruh hali',
        description: 'Sürekli üzgün, umutsuz hissetme',
        type: SymptomType.mood,
        severity: SymptomSeverity.severe,
        relatedSymptoms: ['anhedonia', 'fatigue'],
        triggers: ['stress', 'isolation'],
        alleviators: ['therapy', 'medication'],
        duration: TreatmentDuration.chronic,
        frequency: Frequency.daily,
        metadata: const {},
      ),
      Symptom(
        id: '2',
        name: 'İlgi kaybı',
        description: 'Önceden keyif alınan aktivitelere karşı ilgisizlik',
        type: SymptomType.mood,
        severity: SymptomSeverity.moderate,
        relatedSymptoms: ['depression', 'isolation'],
        triggers: ['social_pressure', 'fatigue'],
        alleviators: ['social_support', 'medication'],
        duration: TreatmentDuration.subacute,
        frequency: Frequency.often,
        metadata: const {},
      ),
      Symptom(
        id: '3',
        name: 'Uyku bozukluğu',
        description: 'Uykuya dalmada güçlük ve erken uyanma',
        type: SymptomType.sleep,
        severity: SymptomSeverity.moderate,
        relatedSymptoms: ['insomnia', 'fatigue'],
        triggers: ['anxiety', 'stress'],
        alleviators: ['sleep_hygiene', 'medication'],
        duration: TreatmentDuration.subacute,
        frequency: Frequency.often,
        metadata: const {},
      ),
      Symptom(
        id: '4',
        name: 'Yorgunluk',
        description: 'Sürekli yorgun ve enerjisiz hissetme',
        type: SymptomType.energy,
        severity: SymptomSeverity.moderate,
        relatedSymptoms: ['sleep_disturbance', 'depression'],
        triggers: ['lack_of_sleep', 'medication'],
        alleviators: ['rest', 'exercise'],
        duration: TreatmentDuration.chronic,
        frequency: Frequency.daily,
        metadata: const {},
      ),
      Symptom(
        id: '5',
        name: 'Konsantrasyon güçlüğü',
        description: 'Düşünceleri toplamada ve karar vermede zorluk',
        type: SymptomType.cognitive,
        severity: SymptomSeverity.moderate,
        relatedSymptoms: ['attention_deficit', 'memory_problems'],
        triggers: ['stress', 'depression'],
        alleviators: ['cognitive_therapy', 'medication'],
        duration: TreatmentDuration.subacute,
        frequency: Frequency.often,
        metadata: const {},
      ),
    ];
  }

  Future<void> _startAIAnalysis() async {
    if (_symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analiz için en az bir semptom ekleyin')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisProgress = 0.0;
      _analysisMessage = 'AI analizi başlatılıyor...';
    });

    try {
      // Listen to progress updates
      _aiService.progressStream.listen((progress) {
        if (mounted) {
          setState(() {
            _analysisProgress = progress.progress;
            _analysisMessage = progress.message;
          });
        }
      });

      // Start AI analysis
      final result = await _aiService.analyzeSymptoms(
        clientId: widget.clientId,
        symptoms: _symptoms,
        clientHistory: {
          'age': 35,
          'gender': 'female',
          'previousDiagnosis': 'Anxiety Disorder',
          'currentMedications': ['Sertraline'],
          'previousAttempts': false,
          'familyHistory': ['Depression'],
        },
        therapistId: widget.therapistId,
      );

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
        _analysisProgress = 1.0;
        _analysisMessage = 'Analiz tamamlandı';
      });

      // Show results
      _showResultsDialog(result);

    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisProgress = 0.0;
        _analysisMessage = 'Analiz hatası: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI analizi başarısız: $e')),
        );
      }
    }
  }

  void _showResultsDialog(DiagnosisResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Tanı Sonuçları'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResultSection('Güven Seviyesi', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                _buildResultSection('AI Model', result.aiModel),
                _buildResultSection('İşlem Süresi', '${result.processingTime}ms'),
                const SizedBox(height: 16),
                
                Text(
                  'Tanı Önerileri (${result.diagnosisSuggestions.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...result.diagnosisSuggestions.map((s) => _buildDiagnosisCard(s)),
                
                const SizedBox(height: 16),
                Text(
                  'Risk Değerlendirmesi',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildRiskCard(result.riskAssessment),
                
                const SizedBox(height: 16),
                Text(
                  'Tedavi Planı',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildTreatmentCard(result.treatmentPlan),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveResults(result);
            },
            child: const Text('Sonuçları Kaydet'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDiagnosisCard(DiagnosisSuggestion diagnosis) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    diagnosis.diagnosis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(diagnosis.severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(diagnosis.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('ICD-10: ${diagnosis.icd10Code}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (diagnosis.notes != null) ...[
              const SizedBox(height: 4),
              Text(diagnosis.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(RiskAssessment assessment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: _getRiskColor(assessment.riskLevel),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getRiskIcon(assessment.riskLevel),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Risk Seviyesi: ${_getRiskText(assessment.riskLevel)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Aciliyet: ${_getUrgencyText(assessment.urgency)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            if (assessment.recommendations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Öneriler:',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
              ...assessment.recommendations.map((r) => Text(
                '• $r',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentCard(TreatmentPlan plan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tedavi Hedefleri (${plan.goals.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...plan.goals.map((g) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• ${g.description} (${g.timeline})'),
            )),
            
            const SizedBox(height: 12),
            Text(
              'Müdahaleler (${plan.interventions.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...plan.interventions.map((i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text('• ${i.name} - ${i.frequency}'),
            )),
            
            const SizedBox(height: 12),
            Text(
              'Timeline: ${plan.timeline.value} ${plan.timeline.unit.name}',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(DiagnosisSeverity severity) {
    switch (severity) {
      case DiagnosisSeverity.mild:
        return Colors.green;
      case DiagnosisSeverity.moderate:
        return Colors.orange;
      case DiagnosisSeverity.severe:
        return Colors.red;
      case DiagnosisSeverity.verySevere:
        return Colors.purple;
    }
  }

  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.purple;
    }
  }

  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }

  String _getRiskText(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Düşük';
      case RiskLevel.medium:
        return 'Orta';
      case RiskLevel.high:
        return 'Yüksek';
      case RiskLevel.critical:
        return 'Kritik';
    }
  }

  String _getUrgencyText(Urgency urgency) {
    switch (urgency) {
      case Urgency.routine:
        return 'Rutin';
      case Urgency.urgent:
        return 'Acil';
      case Urgency.immediate:
        return 'Anında';
    }
  }



  void _saveResults(DiagnosisResult result) {
    // TODO: Save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI tanı sonuçları kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tanı Sistemi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semptomlar', icon: Icon(Icons.medical_services)),
            Tab(text: 'AI Analiz', icon: Icon(Icons.psychology)),
            Tab(text: 'Sonuçlar', icon: Icon(Icons.assessment)),
            Tab(text: 'Ayarlar', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSymptomsTab(),
          _buildAnalysisTab(),
          _buildResultsTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAnalyzing ? null : _startAIAnalysis,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: _isAnalyzing 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.play_arrow),
        label: Text(_isAnalyzing ? 'Analiz Ediliyor...' : 'AI Analizi Başlat'),
      ),
    );
  }

  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semptomlar (${_symptoms.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: _addSymptom,
                icon: const Icon(Icons.add),
                label: const Text('Semptom Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_symptoms.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz semptom eklenmemiş',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI analizi için semptom ekleyin',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            ..._symptoms.map((symptom) => _buildSymptomCard(symptom)),
        ],
      ),
    );
  }

  Widget _buildSymptomCard(Symptom symptom) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    symptom.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(_mapSeverity(symptom.severity)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    symptom.severity.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(symptom.description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(symptom.type.name),
                  backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                ),
                const SizedBox(width: 8),
                Text(
                  symptom.duration.name,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (symptom.triggers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Tetikleyiciler: ${symptom.triggers.join(', ')}',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  DiagnosisSeverity _mapSeverity(SymptomSeverity severity) {
    switch (severity) {
      case SymptomSeverity.mild:
        return DiagnosisSeverity.mild;
      case SymptomSeverity.moderate:
        return DiagnosisSeverity.moderate;
      case SymptomSeverity.severe:
        return DiagnosisSeverity.severe;
      case SymptomSeverity.extreme:
        return DiagnosisSeverity.verySevere;
      default:
        return DiagnosisSeverity.mild;
    }
  }

  void _addSymptom() {
    // TODO: Implement symptom addition dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Semptom ekleme özelliği yakında eklenecek')),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Tanı Analizi',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          if (_symptoms.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.psychology_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Analiz için semptom ekleyin',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Hazır Semptomlar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${_symptoms.length} semptom tespit edildi',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'En yaygın şiddet: ${_symptoms.isNotEmpty ? _symptoms.map((s) => s.severity.name).join(', ') : 'Yok'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            if (_isAnalyzing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'AI Analizi Devam Ediyor...',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: _analysisProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(_analysisMessage),
                      const SizedBox(height: 8),
                      Text('${(_analysisProgress * 100).toStringAsFixed(0)}%'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.psychology,
                        size: 48,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'AI Analizi Hazır',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aşağıdaki butona tıklayarak AI destekli tanı analizini başlatabilirsiniz.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _startAIAnalysis,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Analizi Başlat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analiz Sonuçları',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          if (_lastResult == null)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.assessment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz analiz sonucu yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI analizi yaparak sonuçları görüntüleyin',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            _buildResultsSummary(_lastResult!),
        ],
      ),
    );
  }

  Widget _buildResultsSummary(DiagnosisResult result) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analiz Özeti',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildSummaryRow('Güven Seviyesi', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                _buildSummaryRow('AI Model', result.aiModel),
                _buildSummaryRow('Analiz Tarihi', _formatDate(result.analysisDate)),
                _buildSummaryRow('İşlem Süresi', '${result.processingTime}ms'),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanı Önerileri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...result.diagnosisSuggestions.map((d) => _buildDiagnosisCard(d)),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Risk Değerlendirmesi',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildRiskCard(result.riskAssessment),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tedavi Planı',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildTreatmentCard(result.treatmentPlan),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Tanı Ayarları',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Model Ayarları',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  const ListTile(
                    leading: Icon(Icons.psychology),
                    title: Text('AI Model'),
                    subtitle: Text('Claude-3.5-Sonnet'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  
                  const ListTile(
                    leading: Icon(Icons.speed),
                    title: Text('Analiz Hızı'),
                    subtitle: Text('Hızlı (Önerilen)'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  
                  const ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Güvenlik Seviyesi'),
                    subtitle: Text('Yüksek'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bildirim Ayarları',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Yüksek Risk Uyarıları'),
                    subtitle: const Text('Kritik risk durumlarında bildirim al'),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification settings
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Analiz Tamamlandı'),
                    subtitle: const Text('AI analizi bittiğinde bildirim al'),
                    value: true,
                    onChanged: (value) {
                      // TODO: Implement notification settings
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
