import 'package:flutter/material.dart';
import '../../models/flag_ai_models.dart';
import '../../utils/theme.dart';
import '../../widgets/flag/flag_detection_panel.dart';
import '../../widgets/flag/flag_history_panel.dart';
import '../../widgets/flag/emergency_protocol_widget.dart';
import '../../widgets/flag/ai_model_performance_widget.dart';

// Flag AI Ana Ekran
class FlagScreen extends StatefulWidget {
  const FlagScreen({super.key});

  @override
  State<FlagScreen> createState() => _FlagScreenState();
}

class _FlagScreenState extends State<FlagScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  AIFlagDetection? _selectedFlag;
  String? _error;
  CrisisInterventionPlan? _interventionPlan;

  // Mock client data - gerçek uygulamada veritabanından gelecek
  final Map<String, dynamic> _mockClientData = {
    'id': 'client_001',
    'name': 'Ahmet Yılmaz',
    'age': 28,
    'gender': 'Erkek',
    'diagnosis': 'Major Depressive Disorder',
    'riskFactors': ['Previous suicide attempt', 'Family history', 'Substance use'],
    'protectiveFactors': ['Strong family support', 'Treatment compliance', 'Social network'],
    'currentMedications': ['Sertraline 100mg', 'Benzodiazepine PRN'],
    'lastSession': DateTime.now().subtract(const Duration(days: 2)),
    'nextSession': DateTime.now().add(const Duration(days: 5)),
  };

  final Map<String, dynamic> _mockSessionData = {
    'sessionId': 'session_001',
    'date': DateTime.now().subtract(const Duration(days: 2)),
    'duration': 50,
    'therapist': 'Dr. Ayşe Demir',
    'notes': '''
Danışan bugünkü seansında aşırı umutsuz ve karamsar görünüyordu. 
Ölüm düşüncelerini açıkça ifade etti ve "artık yaşamaya değer bulmuyorum" dedi.
Uyku düzeni bozulmuş, iştahı azalmış. İşe gitmek istemiyor, sosyal aktivitelerden kaçınıyor.
Aile desteği mevcut ancak yeterli değil gibi görünüyor.
    ''',
    'mood': 'Very Low',
    'anxiety': 'High',
    'suicidalThoughts': 'Present',
    'selfHarmRisk': 'Moderate',
    'violenceRisk': 'Low',
    'substanceUse': 'Occasional alcohol',
  };

  final Map<String, dynamic> _mockBehavioralData = {
    'recentBehaviors': [
      'Social withdrawal',
      'Decreased hygiene',
      'Sleep disturbances',
      'Loss of interest in activities',
      'Expressed hopelessness',
      'Verbalized death wishes',
    ],
    'environmentalFactors': {
      'recentStressors': [
        'Job loss 3 weeks ago',
        'Breakup with long-term partner',
        'Financial difficulties',
        'Family conflict',
      ],
      'supportSystems': [
        'Family (moderate support)',
        'Friends (limited contact)',
        'Mental health professional',
      ],
      'accessToMeans': {
        'firearms': 'No access',
        'medications': 'Prescribed medications only',
        'other': 'No immediate access',
      },
    },
    'vitalSigns': {
      'sleep': '4-5 hours per night (decreased from 7-8)',
      'appetite': 'Significantly decreased',
      'energy': 'Very low',
      'concentration': 'Poor',
    },
    'safetyAssessment': {
      'immediateRisk': 'Moderate',
      'protectiveFactors': [
        'No previous attempts',
        'Family awareness',
        'Regular therapy',
      ],
      'riskFactors': [
        'Current suicidal ideation',
        'Recent major stressors',
        'Depressive symptoms',
        'Social isolation',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onFlagDetected(AIFlagDetection flag) {
    setState(() {
      _selectedFlag = flag;
      _error = null;
    });

    // Otomatik olarak Emergency Protocol tab'ına geç
    _tabController.animateTo(2);

    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚨 ${_getFlagTypeText(flag.type)} tespit edildi!'),
        backgroundColor: _getRiskColor(flag.riskLevel),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Detaylar',
          textColor: Colors.white,
          onPressed: () {
            // Flag detaylarını göster
          },
        ),
      ),
    );
  }

  void _onError(String error) {
    setState(() {
      _error = error;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Hata: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _onFlagSelected(AIFlagDetection flag) {
    setState(() {
      _selectedFlag = flag;
    });

    // Flag detaylarını göster
    _showFlagDetails(flag);
  }

  void _onPlanCreated(CrisisInterventionPlan plan) {
    setState(() {
      _interventionPlan = plan;
    });

    // Başarı mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Kriz müdahale planı başarıyla oluşturuldu!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showFlagDetails(AIFlagDetection flag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getFlagIcon(flag.type),
              color: _getRiskColor(flag.riskLevel),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getFlagTypeText(flag.type),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Risk Seviyesi', flag.riskLevel.name, _getRiskColor(flag.riskLevel)),
              _buildDetailSection('Acil Durum', flag.emergencyLevel.name, _getEmergencyColor(flag.emergencyLevel)),
              _buildDetailSection('Güven Skoru', '${(flag.confidence.score * 100).toInt()}%', Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Özet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(flag.summary),
              const SizedBox(height: 16),
              if (flag.warningSigns.isNotEmpty) ...[
                Text(
                  '⚠️ Uyarı İşaretleri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 16),
              ],
              if (flag.protectiveFactors.isNotEmpty) ...[
                Text(
                  '🛡️ Koruyucu Faktörler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Kriz müdahale planı oluştur
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kriz Planı'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value.toUpperCase(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🚨 Flag AI Sistemi'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                icon: Icon(Icons.psychology),
                text: 'AI Risk Tespiti',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Flag Geçmişi',
              ),
              Tab(
                icon: Icon(Icons.emergency),
                text: '🚨 Acil Protokol',
              ),
              Tab(
                icon: Icon(Icons.analytics),
                text: '🤖 AI Performans',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // AI Risk Tespiti Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Info Card
                  _buildClientInfoCard(),
                  const SizedBox(height: 20),
                  // Flag Detection Panel
                  FlagDetectionPanel(
                    clientId: _mockClientData['id'],
                    clientData: _mockClientData,
                    sessionData: _mockSessionData,
                    behavioralData: _mockBehavioralData,
                    onFlagDetected: _onFlagDetected,
                    onError: _onError,
                  ),
                ],
              ),
            ),
            // Flag Geçmişi Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FlagHistoryPanel(
                clientId: _mockClientData['id'],
                onFlagSelected: _onFlagSelected,
                onError: _onError,
              ),
            ),
            // Acil Durum Protokolü Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _selectedFlag != null
                  ? EmergencyProtocolWidget(
                      flag: _selectedFlag!,
                      onPlanCreated: _onPlanCreated,
                      onError: _onError,
                    )
                  : _buildNoFlagSelectedState(),
            ),
            // AI Model Performans Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AIModelPerformanceWidget(
                onError: _onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.blue[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mockClientData['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    Text(
                      '${_mockClientData['age']} yaş, ${_mockClientData['gender']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Tanı', _mockClientData['diagnosis']),
          _buildInfoRow('Son Seans', _formatDateTime(_mockClientData['lastSession'])),
          _buildInfoRow('Sonraki Seans', _formatDateTime(_mockClientData['nextSession'])),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRiskCard(
                  'Risk Faktörleri',
                  _mockClientData['riskFactors'].length.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRiskCard(
                  'Koruyucu Faktörler',
                  _mockClientData['protectiveFactors'].length.toString(),
                  Icons.shield,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildNoFlagSelectedState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 64,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Flag Seçilmedi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.orange[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acil durum protokolü oluşturmak için önce bir flag tespit edin',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(0); // AI Risk Tespiti tab'ına git
            },
            icon: const Icon(Icons.psychology),
            label: const Text('Flag Tespit Et'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
