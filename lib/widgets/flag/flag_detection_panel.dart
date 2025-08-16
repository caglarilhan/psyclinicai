import 'package:flutter/material.dart';
import '../../models/flag_ai_models.dart';
import '../../services/flag_ai_service.dart';
import '../../utils/theme.dart';

// Dünya Standartlarında Flag Detection Panel
class FlagDetectionPanel extends StatefulWidget {
  final String clientId;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic> behavioralData;
  final Function(AIFlagDetection) onFlagDetected;
  final Function(String) onError;

  const FlagDetectionPanel({
    super.key,
    required this.clientId,
    required this.clientData,
    required this.sessionData,
    required this.behavioralData,
    required this.onFlagDetected,
    required this.onError,
  });

  @override
  State<FlagDetectionPanel> createState() => _FlagDetectionPanelState();
}

class _FlagDetectionPanelState extends State<FlagDetectionPanel>
    with TickerProviderStateMixin {
  final FlagAIService _flagService = FlagAIService();
  final TextEditingController _notesController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAnalyzing = false;
  bool _isInitialized = false;
  AIFlagDetection? _currentFlag;
  String? _error;
  Map<String, dynamic>? _serviceStatus;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeService();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _flagService.initialize();
      final status = _flagService.getServiceStatus();
      
      setState(() {
        _isInitialized = true;
        _serviceStatus = status;
      });

      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _error = 'Servis başlatılamadı: $e';
      });
      widget.onError('Servis başlatılamadı: $e');
    }
  }

  Future<void> _startFlagDetection() async {
    if (!_isInitialized) return;

    setState(() {
      _isAnalyzing = true;
      _error = null;
      _currentFlag = null;
    });

    try {
      final flag = await _flagService.detectFlag(
        clientId: widget.clientId,
        clientData: widget.clientData,
        sessionData: widget.sessionData,
        behavioralData: widget.behavioralData,
        countryCode: null, // Otomatik ülke tespiti
      );

      if (flag != null) {
        setState(() {
          _currentFlag = flag;
          _isAnalyzing = false;
        });

        widget.onFlagDetected(flag);
        
        // Başarı animasyonu
        _fadeController.forward();
      } else {
        setState(() {
          _error = 'Flag tespit edilemedi';
          _isAnalyzing = false;
        });
        widget.onError('Flag tespit edilemedi');
      }
    } catch (e) {
      setState(() {
        _error = 'Flag tespiti başarısız: $e';
        _isAnalyzing = false;
      });
      widget.onError('Flag tespiti başarısız: $e');
    }
  }

  void _resetDetection() {
    setState(() {
      _currentFlag = null;
      _error = null;
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (!_isInitialized) _buildInitializingState(),
              if (_isInitialized && !_isAnalyzing && _currentFlag == null && _error == null)
                _buildReadyState(),
              if (_isAnalyzing) _buildAnalyzingState(),
              if (_currentFlag != null) _buildFlagResult(),
              if (_error != null) _buildErrorState(),
              if (_isInitialized) _buildServiceStatus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Risk Tespit Sistemi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                'Dünya standartlarında AI destekli risk analizi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitializingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Flag AI Sistemi Başlatılıyor...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Uluslararası standartlar ve protokoller yükleniyor',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Sistem Hazır',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI analizi başlatmak için butona tıklayın',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startFlagDetection,
            icon: const Icon(Icons.psychology),
            label: const Text('AI Risk Analizi Başlat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'AI Analizi Yapılıyor...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Davranışsal veriler, kültürel bağlam ve uluslararası standartlar analiz ediliyor',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagResult() {
    if (_currentFlag == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFlagHeader(),
        const SizedBox(height: 20),
        _buildRiskAssessment(),
        const SizedBox(height: 20),
        _buildInterventionPlan(),
        const SizedBox(height: 20),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildFlagHeader() {
    final flag = _currentFlag!;
    final riskColor = _getRiskColor(flag.riskLevel);
    final emergencyColor = _getEmergencyColor(flag.emergencyLevel);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getFlagIcon(flag.type),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFlagTypeText(flag.type),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                    Text(
                      'Tespit: ${_formatDateTime(flag.detectedAt)}',
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
              _buildRiskBadge('Risk Seviyesi', flag.riskLevel.name, riskColor),
              const SizedBox(width: 12),
              _buildRiskBadge('Acil Durum', flag.emergencyLevel.name, emergencyColor),
              const SizedBox(width: 12),
              _buildRiskBadge('Güven', '${(flag.confidence.score * 100).toInt()}%', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskAssessment() {
    final flag = _currentFlag!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk Değerlendirmesi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flag.summary,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (flag.warningSigns.isNotEmpty) ...[
                Text(
                  '⚠️ Uyarı İşaretleri:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...flag.warningSigns.map((sign) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, size: 8, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(child: Text(sign)),
                    ],
                  ),
                )),
              ],
              const SizedBox(height: 16),
              if (flag.protectiveFactors.isNotEmpty) ...[
                Text(
                  '🛡️ Koruyucu Faktörler:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...flag.protectiveFactors.map((factor) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, size: 8, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(factor)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterventionPlan() {
    final flag = _currentFlag!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Önerilen Müdahaleler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...flag.recommendedInterventions.map((intervention) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getInterventionIcon(intervention),
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getInterventionText(intervention),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetDetection,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeni Analiz'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Kriz müdahale planı oluştur
            },
            icon: const Icon(Icons.emergency),
            label: const Text('Kriz Planı'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Hata Oluştu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Bilinmeyen hata',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startFlagDetection,
            child: const Text('Tekrar Dene'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatus() {
    if (_serviceStatus == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sistem Durumu',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _serviceStatus!['status'] == 'operational' ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Modeller: ${_serviceStatus!['ai_models']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 16),
              Text(
                'Protokoller: ${_serviceStatus!['emergency_protocols']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.none:
        return Colors.green;
      case RiskLevel.low:
        return Colors.blue;
      case RiskLevel.moderate:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.purple;
      case RiskLevel.emergency:
        return Colors.red[900]!;
    }
  }

  Color _getEmergencyColor(EmergencyLevel level) {
    switch (level) {
      case EmergencyLevel.none:
        return Colors.green;
      case EmergencyLevel.urgent:
        return Colors.orange;
      case EmergencyLevel.immediate:
        return Colors.red;
      case EmergencyLevel.critical:
        return Colors.purple;
      case EmergencyLevel.lifeThreatening:
        return Colors.red[900]!;
    }
  }

  IconData _getFlagIcon(FlagType type) {
    switch (type) {
      case FlagType.suicideRisk:
        return Icons.warning_amber;
      case FlagType.selfHarm:
        return Icons.healing;
      case FlagType.violenceRisk:
        return Icons.security;
      case FlagType.substanceAbuse:
        return Icons.local_hospital;
      case FlagType.psychosis:
        return Icons.psychology;
      case FlagType.manicEpisode:
        return Icons.trending_up;
      case FlagType.severeDepression:
        return Icons.sentiment_very_dissatisfied;
      case FlagType.anxietyCrisis:
        return Icons.psychology;
      case FlagType.eatingDisorder:
        return Icons.restaurant;
      case FlagType.personalityDisorder:
        return Icons.person;
      case FlagType.traumaResponse:
        return Icons.flash_on;
      case FlagType.griefReaction:
        return Icons.favorite_border;
      case FlagType.medicationIssue:
        return Icons.medication;
      case FlagType.medicalEmergency:
        return Icons.emergency;
      case FlagType.socialCrisis:
        return Icons.people;
      case FlagType.financialCrisis:
        return Icons.account_balance_wallet;
      case FlagType.legalIssue:
        return Icons.gavel;
      case FlagType.familyCrisis:
        return Icons.family_restroom;
      case FlagType.workCrisis:
        return Icons.work;
      case FlagType.academicCrisis:
        return Icons.school;
      case FlagType.relationshipCrisis:
        return Icons.favorite;
      case FlagType.other:
        return Icons.help;
    }
  }

  String _getFlagTypeText(FlagType type) {
    switch (type) {
      case FlagType.suicideRisk:
        return 'İntihar Riski';
      case FlagType.selfHarm:
        return 'Kendine Zarar Verme';
      case FlagType.violenceRisk:
        return 'Şiddet Riski';
      case FlagType.substanceAbuse:
        return 'Madde Bağımlılığı';
      case FlagType.psychosis:
        return 'Psikoz';
      case FlagType.manicEpisode:
        return 'Manik Atak';
      case FlagType.severeDepression:
        return 'Ağır Depresyon';
      case FlagType.anxietyCrisis:
        return 'Anksiyete Krizi';
      case FlagType.eatingDisorder:
        return 'Yeme Bozukluğu';
      case FlagType.personalityDisorder:
        return 'Kişilik Bozukluğu';
      case FlagType.traumaResponse:
        return 'Travma Tepkisi';
      case FlagType.griefReaction:
        return 'Yas Tepkisi';
      case FlagType.medicationIssue:
        return 'İlaç Sorunu';
      case FlagType.medicalEmergency:
        return 'Tıbbi Acil';
      case FlagType.socialCrisis:
        return 'Sosyal Kriz';
      case FlagType.financialCrisis:
        return 'Finansal Kriz';
      case FlagType.legalIssue:
        return 'Yasal Sorun';
      case FlagType.familyCrisis:
        return 'Aile Krizi';
      case FlagType.workCrisis:
        return 'İş Krizi';
      case FlagType.academicCrisis:
        return 'Akademik Kriz';
      case FlagType.relationshipCrisis:
        return 'İlişki Krizi';
      case FlagType.other:
        return 'Diğer';
    }
  }

  IconData _getInterventionIcon(InterventionType type) {
    switch (type) {
      case InterventionType.immediateSupport:
        return Icons.support_agent;
      case InterventionType.crisisIntervention:
        return Icons.emergency;
      case InterventionType.emergencyServices:
        return Icons.local_hospital;
      case InterventionType.hospitalization:
        return Icons.medical_services;
      case InterventionType.medicationAdjustment:
        return Icons.medication;
      case InterventionType.therapySession:
        return Icons.psychology;
      case InterventionType.familyIntervention:
        return Icons.family_restroom;
      case InterventionType.socialSupport:
        return Icons.people;
      case InterventionType.legalAssistance:
        return Icons.gavel;
      case InterventionType.financialAssistance:
        return Icons.account_balance_wallet;
      case InterventionType.other:
        return Icons.help;
    }
  }

  String _getInterventionText(InterventionType type) {
    switch (type) {
      case InterventionType.immediateSupport:
        return 'Anında Destek';
      case InterventionType.crisisIntervention:
        return 'Kriz Müdahalesi';
      case InterventionType.emergencyServices:
        return 'Acil Servisler';
      case InterventionType.hospitalization:
        return 'Hastaneye Yatış';
      case InterventionType.medicationAdjustment:
        return 'İlaç Ayarlaması';
      case InterventionType.therapySession:
        return 'Terapi Seansı';
      case InterventionType.familyIntervention:
        return 'Aile Müdahalesi';
      case InterventionType.socialSupport:
        return 'Sosyal Destek';
      case InterventionType.legalAssistance:
        return 'Yasal Yardım';
      case InterventionType.financialAssistance:
        return 'Finansal Yardım';
      case InterventionType.other:
        return 'Diğer';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
