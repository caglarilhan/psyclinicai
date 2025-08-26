import 'package:flutter/material.dart';
import '../../models/diagnosis_models.dart';
import '../../services/ai_diagnosis_service.dart';
import '../../utils/theme.dart';

class AIDiagnosisPanel extends StatefulWidget {
  final String clientId;
  final String therapistId;
  final VoidCallback? onDiagnosisComplete;
  final bool showQuickActions;

  const AIDiagnosisPanel({
    super.key,
    required this.clientId,
    required this.therapistId,
    this.onDiagnosisComplete,
    this.showQuickActions = true,
  });

  @override
  State<AIDiagnosisPanel> createState() => _AIDiagnosisPanelState();
}

class _AIDiagnosisPanelState extends State<AIDiagnosisPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  final AIDiagnosisService _aiService = AIDiagnosisService();
  
  // State variables
  bool _isAnalyzing = false;
  double _analysisProgress = 0.0;
  String _analysisMessage = '';
  DiagnosisResult? _lastResult;
  List<Symptom> _recentSymptoms = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _initializeData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _aiService.initialize();
      
      // Load recent symptoms
      _loadRecentSymptoms();
      
      _slideController.forward();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Diagnosis paneli başlatılamadı: $e')),
        );
      }
    }
  }

  void _loadRecentSymptoms() {
    // Mock recent symptoms - in real app, load from database
    _recentSymptoms = [
      Symptom(
        id: '1',
        name: 'Depresif ruh hali',
        description: 'Sürekli üzgün, umutsuz hissetme',
        type: SymptomType.mood,
        severity: SymptomSeverity.severe,
        relatedSymptoms: [],
        triggers: ['Stres', 'Yalnızlık'],
        alleviators: ['Sosyal aktivite', 'Egzersiz'],
        duration: TreatmentDuration.chronic,
        frequency: Frequency.daily,
        metadata: {'category': 'mood'},
      ),
      Symptom(
        id: '2',
        name: 'Uyku bozukluğu',
        description: 'Uykuya dalmada güçlük',
        type: SymptomType.sleep,
        severity: SymptomSeverity.moderate,
        relatedSymptoms: [],
        triggers: ['Anksiyete', 'Kafein'],
        alleviators: ['Rahatlatıcı aktiviteler', 'Düzenli uyku'],
        duration: TreatmentDuration.episodic,
        frequency: Frequency.daily,
        metadata: {'category': 'sleep'},
      ),
    ];
  }

  Future<void> _startQuickAnalysis() async {
    if (_recentSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hızlı analiz için semptom bulunamadı')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisProgress = 0.0;
      _analysisMessage = 'Hızlı analiz başlatılıyor...';
    });

    _pulseController.repeat();

    try {
      // Listen to progress updates
      _aiService.progressStream.listen((progress) {
        setState(() {
          _analysisProgress = progress.progress;
          _analysisMessage = progress.message;
        });
      });

      // Start quick analysis
      final result = await _aiService.analyzeSymptoms(
        clientId: widget.clientId,
        symptoms: _recentSymptoms,
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

      _pulseController.stop();

      // Show quick results
      _showQuickResults(result);

      // Notify parent
      widget.onDiagnosisComplete?.call();

    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _analysisProgress = 0.0;
        _analysisMessage = 'Analiz hatası: $e';
      });

      _pulseController.stop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hızlı analiz başarısız: $e')),
        );
      }
    }
  }

  void _showQuickResults(DiagnosisResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.psychology, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('Hızlı AI Analiz'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickResultRow('Güven', '${(result.confidence * 100).toStringAsFixed(0)}%'),
              _buildQuickResultRow('Risk Seviyesi', _getRiskText(result.riskAssessment.riskLevel)),
              _buildQuickResultRow('Önerilen Tanı', result.diagnosisSuggestions.first.diagnosis),
              const SizedBox(height: 16),
              
              if (result.riskAssessment.riskLevel == RiskLevel.high || 
                  result.riskAssessment.riskLevel == RiskLevel.critical)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Yüksek risk tespit edildi! Acil değerlendirme gerekli.',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
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
              _openFullDiagnosis();
            },
            child: const Text('Detaylı Analiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickResultRow(String label, String value) {
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
      default:
        return 'Bilinmiyor';
    }
  }

  void _openFullDiagnosis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('AI Tanı Sistemi'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('Detaylı AI Tanı ekranı burada açılacak'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Tanı Asistanı',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Semptomları analiz ederek tanı önerileri sunar',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              if (_isAnalyzing) ...[
                _buildAnalysisProgress(),
              ] else if (_lastResult != null) ...[
                _buildLastResultSummary(),
              ] else ...[
                _buildInitialState(),
              ],
              
              if (widget.showQuickActions) ...[
                const SizedBox(height: 20),
                _buildQuickActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisProgress() {
    return Column(
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (0.1 * _pulseController.value),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.blue,
                    size: 32,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Analizi Devam Ediyor...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _analysisProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _analysisMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastResultSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Son Analiz Tamamlandı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${_formatDate(_lastResult!.analysisDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildResultMetric(
                'Güven',
                '${(_lastResult!.confidence * 100).toStringAsFixed(0)}%',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResultMetric(
                'Risk',
                _getRiskText(_lastResult!.riskAssessment.riskLevel),
                _getRiskColor(_lastResult!.riskAssessment.riskLevel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResultMetric(
                'Tanı',
                '${_lastResult!.diagnosisSuggestions.length}',
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hızlı AI Analiz',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Son semptomları kullanarak hızlı tanı analizi yapın',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        
        if (_recentSymptoms.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Son Semptomlar:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ..._recentSymptoms.take(3).map((symptom) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    symptom.name,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(_mapSeverity(symptom.severity)).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    symptom.severity.name,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getSeverityColor(_mapSeverity(symptom.severity)),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _startQuickAnalysis,
            icon: _isAnalyzing 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
            label: Text(_isAnalyzing ? 'Analiz Ediliyor...' : 'Hızlı Analiz'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _openFullDiagnosis,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Detaylı'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
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
      default:
        return Colors.grey;
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
      default:
        return Colors.grey;
    }
  }

  DiagnosisSeverity _mapSeverity(SymptomSeverity severity) {
    switch (severity) {
      case SymptomSeverity.none:
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
