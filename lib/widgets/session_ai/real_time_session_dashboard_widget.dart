import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/session_ai_models.dart';
import '../../services/real_time_session_ai_service.dart';
import '../../utils/ai_logger.dart';

class RealTimeSessionDashboardWidget extends StatefulWidget {
  final String sessionId;
  final String clientId;
  final String therapistId;

  const RealTimeSessionDashboardWidget({
    super.key,
    required this.sessionId,
    required this.clientId,
    required this.therapistId,
  });

  @override
  State<RealTimeSessionDashboardWidget> createState() => _RealTimeSessionDashboardWidgetState();
}

class _RealTimeSessionDashboardWidgetState extends State<RealTimeSessionDashboardWidget>
    with TickerProviderStateMixin {
  final RealTimeSessionAIService _sessionAIService = RealTimeSessionAIService();
  final AILogger _logger = AILogger();
  
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  RealTimeSessionAnalysis? _currentAnalysis;
  List<Alert> _activeAlerts = [];
  List<InterventionSuggestion> _interventions = [];
  List<EmotionalState> _emotionalHistory = [];
  
  bool _isAnalysisActive = false;
  bool _isLoading = true;
  String _selectedView = 'overview';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _initializeSession();
    _setupStreams();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    try {
      setState(() => _isLoading = true);
      
      // Start session analysis
      await _sessionAIService.startSessionAnalysis(
        sessionId: widget.sessionId,
        clientId: widget.clientId,
        therapistId: widget.therapistId,
        clientHistory: {
          'diagnosis': 'Depresyon',
          'previousSessions': 5,
          'currentMedications': ['SSRI'],
          'riskFactors': ['Suicidal thoughts'],
        },
        sessionGoals: [
          'Depresif semptomları azaltmak',
          'Coping stratejileri geliştirmek',
          'Sosyal aktivitelere katılımı artırmak',
        ],
      );
      
      setState(() {
        _isAnalysisActive = true;
        _isLoading = false;
      });
      
      _fadeController.forward();
      
    } catch (e) {
      _logger.error('Failed to initialize session', context: 'RealTimeSessionDashboard', error: e);
      setState(() => _isLoading = false);
    }
  }

  void _setupStreams() {
    // Listen to real-time analysis
    _sessionAIService.analysisStream.listen((analysis) {
      setState(() {
        _currentAnalysis = analysis;
        _emotionalHistory.addAll(analysis.emotionalStates);
        if (_emotionalHistory.length > 20) {
          _emotionalHistory = _emotionalHistory.skip(_emotionalHistory.length - 20).toList();
        }
      });
    });

    // Listen to alerts
    _sessionAIService.alertStream.listen((alert) {
      setState(() {
        _activeAlerts.add(alert);
        if (_activeAlerts.length > 10) {
          _activeAlerts = _activeAlerts.skip(_activeAlerts.length - 10).toList();
        }
      });
      
      // Trigger pulse animation for critical alerts
      if (alert.priority == AlertPriority.critical) {
        _pulseController.repeat();
      }
    });

    // Listen to intervention suggestions
    _sessionAIService.interventionStream.listen((intervention) {
      setState(() {
        _interventions.add(intervention);
        if (_interventions.length > 10) {
          _interventions = _interventions.skip(_interventions.length - 10).toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seans AI Dashboard - ${widget.sessionId}'),
        actions: [
          IconButton(
            icon: Icon(_isAnalysisActive ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleAnalysis,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedView = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'overview', child: Text('Genel Bakış')),
              const PopupMenuItem(value: 'emotions', child: Text('Duygusal Analiz')),
              const PopupMenuItem(value: 'risks', child: Text('Risk Değerlendirmesi')),
              const PopupMenuItem(value: 'interventions', child: Text('Müdahale Önerileri')),
              const PopupMenuItem(value: 'progress', child: Text('İlerleme Takibi')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getViewTitle(_selectedView)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeController,
              child: _buildSelectedView(),
            ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'overview':
        return _buildOverviewView();
      case 'emotions':
        return _buildEmotionsView();
      case 'risks':
        return _buildRisksView();
      case 'interventions':
        return _buildInterventionsView();
      case 'progress':
        return _buildProgressView();
      default:
        return _buildOverviewView();
    }
  }

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCards(),
          const SizedBox(height: 24),
          _buildActiveAlerts(),
          const SizedBox(height: 24),
          _buildRecentInterventions(),
          const SizedBox(height: 24),
          _buildEmotionalTrend(),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatusCard(
          'Seans Durumu',
          _currentAnalysis?.phase.toString().split('.').last ?? 'Başlatılıyor',
          Icons.psychology,
          Colors.blue,
        ),
        _buildStatusCard(
          'Risk Seviyesi',
          _getRiskLevelText(),
          Icons.warning,
          _getRiskLevelColor(),
        ),
        _buildStatusCard(
          'Duygusal Durum',
          _getEmotionalStateText(),
          Icons.sentiment_satisfied,
          _getEmotionalStateColor(),
        ),
        _buildStatusCard(
          'AI Analiz',
          _isAnalysisActive ? 'Aktif' : 'Pasif',
          Icons.smart_toy,
          _isAnalysisActive ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlerts() {
    if (_activeAlerts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Aktif uyarı yok'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Aktif Uyarılar (${_activeAlerts.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._activeAlerts.map((alert) => _buildAlertItem(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Alert alert) {
    final color = _getAlertColor(alert.priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getAlertIcon(alert.type),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  alert.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alert.priority.toString().split('.').last,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInterventions() {
    if (_interventions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Henüz müdahale önerisi yok'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Son Müdahale Önerileri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._interventions.take(3).map((intervention) => _buildInterventionItem(intervention)),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionItem(InterventionSuggestion intervention) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInterventionIcon(intervention.type),
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  intervention.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              Text(
                '${(intervention.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            intervention.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Zamanlama: ${intervention.timing.toString().split('.').last}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalTrend() {
    if (_emotionalHistory.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('Henüz duygusal veri yok'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duygusal Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _emotionalHistory.length) {
                            return Text('${value.toInt() + 1}');
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(1));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _buildEmotionalSpots(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildEmotionalSpots() {
    return _emotionalHistory.asMap().entries.map((entry) {
      final index = entry.key;
      final emotion = entry.value;
      return FlSpot(index.toDouble(), emotion.intensity);
    }).toList();
  }

  Widget _buildEmotionsView() {
    if (_emotionalHistory.isEmpty) {
      return const Center(child: Text('Henüz duygusal veri yok'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _emotionalHistory.length,
      itemBuilder: (context, index) {
        final emotion = _emotionalHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getEmotionColor(emotion.emotion),
              child: Icon(
                _getEmotionIcon(emotion.emotion),
                color: Colors.white,
              ),
            ),
            title: Text(emotion.emotion.toString().split('.').last),
            subtitle: Text('Yoğunluk: ${(emotion.intensity * 100).toStringAsFixed(0)}%'),
            trailing: Text(
              '${emotion.confidence.toStringAsFixed(2)}',
              style: TextStyle(
                color: emotion.isReliable ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRisksView() {
    if (_currentAnalysis?.riskIndicators.isEmpty ?? true) {
      return const Center(child: Text('Risk göstergesi yok'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _currentAnalysis!.riskIndicators.length,
      itemBuilder: (context, index) {
        final risk = _currentAnalysis!.riskIndicators[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRiskColor(risk.severity),
              child: Icon(
                _getRiskIcon(risk.type),
                color: Colors.white,
              ),
            ),
            title: Text(risk.description),
            subtitle: Text('Güven: ${(risk.confidence * 100).toStringAsFixed(0)}%'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRiskColor(risk.severity),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                risk.severity.toString().split('.').last,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterventionsView() {
    if (_interventions.isEmpty) {
      return const Center(child: Text('Henüz müdahale önerisi yok'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _interventions.length,
      itemBuilder: (context, index) {
        final intervention = _interventions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: Icon(
              _getInterventionIcon(intervention.type),
              color: Colors.blue,
            ),
            title: Text(intervention.title),
            subtitle: Text('Güven: ${(intervention.confidence * 100).toStringAsFixed(0)}%'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Açıklama: ${intervention.description}'),
                    const SizedBox(height: 8),
                    Text('Gerekçe: ${intervention.rationale}'),
                    const SizedBox(height: 8),
                    Text('Teknikler: ${intervention.techniques.join(', ')}'),
                    const SizedBox(height: 8),
                    Text('Beklenen Sonuç: ${intervention.expectedOutcome}'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressView() {
    if (_currentAnalysis == null) {
      return const Center(child: Text('Henüz ilerleme verisi yok'));
    }

    final progress = _currentAnalysis!.progress;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Genel İlerleme',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress.overallProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress.overallProgress),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress.overallProgress * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (progress.milestones.isNotEmpty) ...[
            Text(
              'Kilometre Taşları',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...progress.milestones.map((milestone) => _buildMilestoneItem(milestone)),
            const SizedBox(height: 16),
          ],
          if (progress.nextSteps.isNotEmpty) ...[
            Text(
              'Sonraki Adımlar',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(progress.nextSteps),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(Milestone milestone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.flag, color: Colors.green),
        title: Text(milestone.title),
        subtitle: Text(milestone.description),
        trailing: Text(
          '${(milestone.significance * 100).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  // Helper methods
  String _getViewTitle(String view) {
    switch (view) {
      case 'overview': return 'Genel Bakış';
      case 'emotions': return 'Duygusal Analiz';
      case 'risks': return 'Risk Değerlendirmesi';
      case 'interventions': return 'Müdahale Önerileri';
      case 'progress': return 'İlerleme Takibi';
      default: return 'Genel Bakış';
    }
  }

  String _getRiskLevelText() {
    if (_currentAnalysis == null) return 'Bilinmiyor';
    
    final hasCritical = _currentAnalysis!.riskIndicators.any((r) => r.severity == RiskSeverity.critical);
    final hasHigh = _currentAnalysis!.riskIndicators.any((r) => r.severity == RiskSeverity.high);
    
    if (hasCritical) return 'Kritik';
    if (hasHigh) return 'Yüksek';
    return 'Düşük';
  }

  Color _getRiskLevelColor() {
    if (_currentAnalysis == null) return Colors.grey;
    
    final hasCritical = _currentAnalysis!.riskIndicators.any((r) => r.severity == RiskSeverity.critical);
    final hasHigh = _currentAnalysis!.riskIndicators.any((r) => r.severity == RiskSeverity.high);
    
    if (hasCritical) return Colors.red;
    if (hasHigh) return Colors.orange;
    return Colors.green;
  }

  String _getEmotionalStateText() {
    if (_emotionalHistory.isEmpty) return 'Bilinmiyor';
    
    final latestEmotion = _emotionalHistory.last;
    return latestEmotion.emotion.toString().split('.').last;
  }

  Color _getEmotionalStateColor() {
    if (_emotionalHistory.isEmpty) return Colors.grey;
    
    final latestEmotion = _emotionalHistory.last;
    return _getEmotionColor(latestEmotion.emotion);
  }

  Color _getEmotionColor(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.joy:
      case EmotionType.excitement:
      case EmotionType.hope:
      case EmotionType.pride:
        return Colors.green;
      case EmotionType.sadness:
      case EmotionType.depression:
      case EmotionType.despair:
      case EmotionType.guilt:
      case EmotionType.shame:
        return Colors.blue;
      case EmotionType.anger:
      case EmotionType.fear:
      case EmotionType.anxiety:
      case EmotionType.frustration:
        return Colors.red;
      case EmotionType.calm:
      case EmotionType.confusion:
      case EmotionType.surprise:
      case EmotionType.disgust:
      case EmotionType.love:
      case EmotionType.hate:
      case EmotionType.envy:
        return Colors.orange;
    }
  }

  IconData _getEmotionIcon(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.joy:
      case EmotionType.excitement:
      case EmotionType.hope:
        return Icons.sentiment_very_satisfied;
      case EmotionType.sadness:
      case EmotionType.depression:
      case EmotionType.despair:
        return Icons.sentiment_very_dissatisfied;
      case EmotionType.anger:
      case EmotionType.fear:
      case EmotionType.anxiety:
        return Icons.sentiment_dissatisfied;
      case EmotionType.calm:
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getRiskColor(RiskSeverity severity) {
    switch (severity) {
      case RiskSeverity.low:
        return Colors.green;
      case RiskSeverity.medium:
        return Colors.orange;
      case RiskSeverity.high:
        return Colors.red;
      case RiskSeverity.critical:
        return Colors.purple;
    }
  }

  IconData _getRiskIcon(RiskType type) {
    switch (type) {
      case RiskType.selfHarm:
      case RiskType.suicidalThoughts:
        return Icons.warning;
      case RiskType.harmToOthers:
      case RiskType.domesticViolence:
        return Icons.security;
      case RiskType.substanceAbuse:
        return Icons.local_bar;
      case RiskType.psychoticSymptoms:
        return Icons.psychology;
      default:
        return Icons.info;
    }
  }

  Color _getAlertColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.low:
        return Colors.blue;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.high:
        return Colors.red;
      case AlertPriority.critical:
        return Colors.purple;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.risk:
        return Icons.warning;
      case AlertType.crisis:
        return Icons.emergency;
      case AlertType.progress:
        return Icons.trending_up;
      case AlertType.technique:
        return Icons.lightbulb;
      case AlertType.reminder:
        return Icons.notifications;
      default:
        return Icons.info;
    }
  }

  IconData _getInterventionIcon(InterventionType type) {
    switch (type) {
      case InterventionType.cognitive:
        return Icons.psychology;
      case InterventionType.behavioral:
        return Icons.touch_app;
      case InterventionType.emotional:
        return Icons.favorite;
      case InterventionType.mindfulness:
        return Icons.self_improvement;
      case InterventionType.crisis:
        return Icons.emergency;
      default:
        return Icons.healing;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.7) return Colors.green;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  void _toggleAnalysis() {
    setState(() {
      _isAnalysisActive = !_isAnalysisActive;
    });
    
    if (_isAnalysisActive) {
      _sessionAIService.enable();
    } else {
      _sessionAIService.disable();
    }
  }
}
