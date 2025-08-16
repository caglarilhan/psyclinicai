import 'package:flutter/material.dart';
import '../../models/flag_ai_models.dart';
import '../../services/flag_ai_service.dart';
import '../../utils/theme.dart';

// Flag Geçmişi Panel Widget'ı
class FlagHistoryPanel extends StatefulWidget {
  final String clientId;
  final Function(AIFlagDetection) onFlagSelected;
  final Function(String) onError;

  const FlagHistoryPanel({
    super.key,
    required this.clientId,
    required this.onFlagSelected,
    required this.onError,
  });

  @override
  State<FlagHistoryPanel> createState() => _FlagHistoryPanelState();
}

class _FlagHistoryPanelState extends State<FlagHistoryPanel>
    with TickerProviderStateMixin {
  final FlagAIService _flagService = FlagAIService();
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isInitialized = false;
  FlagHistory? _flagHistory;
  String? _error;
  List<AIFlagDetection> _filteredFlags = [];
  String _selectedFilter = 'all';
  String _searchQuery = '';

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
    super.dispose();
  }

  Future<void> _initializeService() async {
    try {
      await _flagService.initialize();
      await _loadFlagHistory();
      
      setState(() {
        _isInitialized = true;
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

  Future<void> _loadFlagHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock flag history - gerçek uygulamada veritabanından gelecek
      final mockFlags = [
        AIFlagDetection(
          id: 'flag_001',
          type: FlagType.suicideRisk,
          riskLevel: RiskLevel.high,
          emergencyLevel: EmergencyLevel.urgent,
          confidence: AIConfidenceScore(
            score: 0.89,
            confidence: 'Yüksek',
            factors: ['Behavioral patterns', 'Recent stressors'],
            explanation: 'High confidence based on multiple indicators',
          ),
          riskFactors: [],
          summary: 'High suicide risk detected',
          detailedAnalysis: 'Detailed analysis of suicide risk factors',
          warningSigns: ['Hopelessness', 'Social withdrawal'],
          protectiveFactors: ['Family support', 'Previous coping'],
          recommendedInterventions: [InterventionType.crisisIntervention],
          aiMetadata: {},
          detectedAt: DateTime.now().subtract(const Duration(days: 2)),
          expiresAt: DateTime.now().add(const Duration(days: 5)),
          isActive: true,
          status: 'resolved',
        ),
        AIFlagDetection(
          id: 'flag_002',
          type: FlagType.violenceRisk,
          riskLevel: RiskLevel.moderate,
          emergencyLevel: EmergencyLevel.urgent,
          confidence: AIConfidenceScore(
            score: 0.76,
            confidence: 'Orta',
            factors: ['Aggressive behavior', 'Verbal threats'],
            explanation: 'Moderate confidence based on behavioral indicators',
          ),
          riskFactors: [],
          summary: 'Moderate violence risk detected',
          detailedAnalysis: 'Analysis of violence risk factors',
          warningSigns: ['Verbal aggression', 'Irritability'],
          protectiveFactors: ['No history of violence', 'Support system'],
          recommendedInterventions: [InterventionType.therapySession],
          aiMetadata: {},
          detectedAt: DateTime.now().subtract(const Duration(days: 5)),
          expiresAt: DateTime.now().add(const Duration(days: 2)),
          isActive: false,
          status: 'resolved',
        ),
        AIFlagDetection(
          id: 'flag_003',
          type: FlagType.severeDepression,
          riskLevel: RiskLevel.moderate,
          emergencyLevel: EmergencyLevel.none,
          confidence: AIConfidenceScore(
            score: 0.82,
            confidence: 'Yüksek',
            factors: ['Depressive symptoms', 'Functional impairment'],
            explanation: 'High confidence based on symptom severity',
          ),
          riskFactors: [],
          summary: 'Moderate depression risk detected',
          detailedAnalysis: 'Analysis of depression symptoms and severity',
          warningSigns: ['Low mood', 'Sleep problems', 'Loss of interest'],
          protectiveFactors: ['Treatment compliance', 'Social support'],
          recommendedInterventions: [InterventionType.therapySession, InterventionType.medicationAdjustment],
          aiMetadata: {},
          detectedAt: DateTime.now().subtract(const Duration(days: 1)),
          expiresAt: DateTime.now().add(const Duration(days: 6)),
          isActive: true,
          status: 'active',
        ),
      ];

      final mockHistory = FlagHistory(
        id: 'history_${widget.clientId}',
        clientId: widget.clientId,
        detections: mockFlags,
        interventions: [],
        statistics: {
          'total_flags': mockFlags.length,
          'active_flags': mockFlags.where((f) => f.isActive).length,
          'resolved_flags': mockFlags.where((f) => f.status == 'resolved').length,
          'high_risk_flags': mockFlags.where((f) => f.riskLevel == RiskLevel.high || f.riskLevel == RiskLevel.critical).length,
        },
        patterns: [
          'Suicide risk patterns',
          'Depression cycles',
          'Stress response patterns',
        ],
        trends: [
          'Decreasing risk over time',
          'Improved coping mechanisms',
          'Better treatment compliance',
        ],
        firstDetection: mockFlags.map((f) => f.detectedAt).reduce((a, b) => a.isBefore(b) ? a : b),
        lastDetection: mockFlags.map((f) => f.detectedAt).reduce((a, b) => a.isAfter(b) ? a : b),
        totalFlags: mockFlags.length,
        resolvedFlags: mockFlags.where((f) => f.status == 'resolved').length,
        escalatedFlags: mockFlags.where((f) => f.status == 'escalated').length,
        metadata: {},
      );

      setState(() {
        _flagHistory = mockHistory;
        _filteredFlags = mockFlags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Flag geçmişi yüklenemedi: $e';
        _isLoading = false;
      });
      widget.onError('Flag geçmişi yüklenemedi: $e');
    }
  }

  void _filterFlags() {
    if (_flagHistory == null) return;

    List<AIFlagDetection> filtered = _flagHistory!.detections;

    // Status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((flag) {
        switch (_selectedFilter) {
          case 'active':
            return flag.isActive;
          case 'resolved':
            return flag.status == 'resolved';
          case 'escalated':
            return flag.status == 'escalated';
          case 'high_risk':
            return flag.riskLevel == RiskLevel.high || 
                   flag.riskLevel == RiskLevel.critical || 
                   flag.riskLevel == RiskLevel.emergency;
          default:
            return true;
        }
      }).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((flag) {
        return flag.type.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               flag.summary.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               flag.detailedAnalysis.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredFlags = filtered;
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
              if (_isInitialized && _isLoading) _buildLoadingState(),
              if (_isInitialized && !_isLoading && _error != null) _buildErrorState(),
              if (_isInitialized && !_isLoading && _error == null) ...[
                _buildStatistics(),
                const SizedBox(height: 20),
                _buildFilters(),
                const SizedBox(height: 20),
                _buildFlagList(),
              ],
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
            Icons.history,
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
                'Flag Geçmişi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Text(
                'AI tespit edilen risklerin geçmişi ve analizi',
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
            'Flag Geçmişi Yükleniyor...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        ),
      ),
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
            onPressed: _loadFlagHistory,
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

  Widget _buildStatistics() {
    if (_flagHistory == null) return const SizedBox.shrink();

    final stats = _flagHistory!.statistics;
    
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
          Text(
            'Genel İstatistikler',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Toplam Flag',
                  '${stats['total_flags']}',
                  Icons.flag,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Aktif Flag',
                  '${stats['active_flags']}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Çözülen Flag',
                  '${stats['resolved_flags']}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Yüksek Risk',
                  '${stats['high_risk_flags']}',
                  Icons.dangerous,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtreler',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  _searchQuery = value;
                  _filterFlags();
                },
                decoration: InputDecoration(
                  hintText: 'Flag ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                _filterFlags();
              },
              items: [
                DropdownMenuItem(value: 'all', child: Text('Tümü')),
                DropdownMenuItem(value: 'active', child: Text('Aktif')),
                DropdownMenuItem(value: 'resolved', child: Text('Çözülen')),
                DropdownMenuItem(value: 'escalated', child: Text('Escalate')),
                DropdownMenuItem(value: 'high_risk', child: Text('Yüksek Risk')),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlagList() {
    if (_filteredFlags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Flag Bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seçilen filtrelere uygun flag bulunamadı',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flag Listesi (${_filteredFlags.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredFlags.length,
          itemBuilder: (context, index) {
            final flag = _filteredFlags[index];
            return _buildFlagCard(flag);
          },
        ),
      ],
    );
  }

  Widget _buildFlagCard(AIFlagDetection flag) {
    final riskColor = _getRiskColor(flag.riskLevel);
    final isActive = flag.isActive;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isActive ? riskColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? riskColor.withOpacity(0.3) : Colors.grey[200]!,
          width: isActive ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFlagIcon(flag.type),
            color: riskColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getFlagTypeText(flag.type),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: riskColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                flag.riskLevel.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              flag.summary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(flag.detectedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.psychology,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${(flag.confidence.score * 100).toInt()}% Güven',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: () => widget.onFlagSelected(flag),
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
        return Icons.anxiety;
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
}
