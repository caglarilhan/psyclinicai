import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/real_time_session_ai_service.dart';
import '../../services/consent_service.dart';
import '../../services/regional_config_service.dart';
import '../../models/real_time_session_models.dart';
import '../../models/consent_models.dart';
import '../../widgets/session/ai_summary_panel.dart';
import '../../widgets/session/session_note_editor.dart';
import '../../widgets/session/pdf_export_panel.dart';
import '../../utils/ai_logger.dart';

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

class _SessionScreenState extends State<SessionScreen>
    with TickerProviderStateMixin {
  final RealTimeSessionAIService _aiService = RealTimeSessionAIService();
  final AILogger _logger = AILogger();
  
  late TabController _tabController;
  late AnimationController _sessionController;
  late AnimationController _aiController;
  
  // Session state
  SessionState _sessionState = SessionState.preparing;
  DateTime _sessionStartTime = DateTime.now();
  DateTime? _sessionEndTime;
  Duration _sessionDuration = Duration.zero;
  
  // Session data
  String _sessionNotes = '';
  Map<String, dynamic> _sessionData = {};
  List<SessionInsight> _sessionInsights = [];
  List<RiskIndicator> _riskIndicators = [];
  List<InterventionSuggestion> _interventions = [];
  
  // AI analysis
  bool _isAnalyzing = false;
  String _currentAnalysis = '';
  Map<String, dynamic> _aiRecommendations = {};
  
  // Real-time monitoring
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  List<EmotionalState> _emotionalStates = [];
  List<RiskAssessment> _riskAssessments = [];
  
  // UI state
  bool _showConsentDialog = false;
  bool _showRiskAlert = false;
  String _selectedTab = 'notes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _sessionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _aiController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _initializeSession();
    _checkConsent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sessionController.dispose();
    _aiController.dispose();
    _monitoringTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    try {
      setState(() => _sessionState = SessionState.preparing);
      
      // Initialize AI service for this session
      await _aiService.initializeSession(widget.sessionId, widget.clientId);
      
      // Load existing session data if any
      await _loadExistingSessionData();
      
      setState(() => _sessionState = SessionState.ready);
      _sessionController.forward();
      
      _logger.info('Session initialized', context: 'SessionScreen', data: {
        'sessionId': widget.sessionId,
        'clientId': widget.clientId,
      });
      
    } catch (e) {
      _logger.error('Failed to initialize session', context: 'SessionScreen', error: e);
      setState(() => _sessionState = SessionState.error);
    }
  }

  Future<void> _loadExistingSessionData() async {
    try {
      // Load session notes, insights, etc.
      // This would typically come from a database
      _sessionNotes = '';
      _sessionData = {
        'clientId': widget.clientId,
        'sessionId': widget.sessionId,
        'startTime': _sessionStartTime.toIso8601String(),
        'therapistId': 'current_therapist_id', // Get from auth service
      };
      
    } catch (e) {
      _logger.warning('No existing session data found', context: 'SessionScreen');
    }
  }

  Future<void> _checkConsent() async {
    try {
      final consentService = Provider.of<ConsentService>(context, listen: false);
      final hasConsent = consentService.hasValidConsent(
        widget.clientId, 
        'therapy_session', 
        'TR' // Get from regional config
      );
      
      if (!hasConsent) {
        setState(() => _showConsentDialog = true);
      }
      
    } catch (e) {
      _logger.error('Failed to check consent', context: 'SessionScreen', error: e);
    }
  }

  void _startSession() {
    setState(() {
      _sessionState = SessionState.active;
      _sessionStartTime = DateTime.now();
      _isMonitoring = true;
    });
    
    _startRealTimeMonitoring();
    _sessionController.forward();
    
    _logger.info('Session started', context: 'SessionScreen', data: {
      'sessionId': widget.sessionId,
      'startTime': _sessionStartTime.toIso8601String(),
    });
  }

  void _pauseSession() {
    setState(() {
      _sessionState = SessionState.paused;
      _isMonitoring = false;
    });
    
    _stopRealTimeMonitoring();
    
    _logger.info('Session paused', context: 'SessionScreen');
  }

  void _resumeSession() {
    setState(() {
      _sessionState = SessionState.active;
      _isMonitoring = true;
    });
    
    _startRealTimeMonitoring();
    
    _logger.info('Session resumed', context: 'SessionScreen');
  }

  void _endSession() async {
    try {
      setState(() {
        _sessionState = SessionState.ending;
        _sessionEndTime = DateTime.now();
        _isMonitoring = false;
      });
      
      _stopRealTimeMonitoring();
      _sessionDuration = _sessionEndTime!.difference(_sessionStartTime);
      
      // Final AI analysis
      await _performFinalAnalysis();
      
      // Save session data
      await _saveSessionData();
      
      setState(() => _sessionState = SessionState.completed);
      
      _logger.info('Session ended', context: 'SessionScreen', data: {
        'sessionId': widget.sessionId,
        'duration': _sessionDuration.inMinutes,
        'endTime': _sessionEndTime!.toIso8601String(),
      });
      
    } catch (e) {
      _logger.error('Failed to end session', context: 'SessionScreen', error: e);
      setState(() => _sessionState = SessionState.error);
    }
  }

  void _startRealTimeMonitoring() {
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isMonitoring && mounted) {
        _performRealTimeAnalysis();
      }
    });
  }

  void _stopRealTimeMonitoring() {
    _monitoringTimer?.cancel();
  }

  Future<void> _performRealTimeAnalysis() async {
    try {
      setState(() => _isAnalyzing = true);
      
      final analysis = await _aiService.analyzeSessionData(
        sessionId: widget.sessionId,
        clientId: widget.clientId,
        sessionData: _sessionData,
        notes: _sessionNotes,
      );
      
      if (analysis != null) {
        setState(() {
          _sessionInsights.addAll(analysis.insights);
          _riskIndicators.addAll(analysis.riskIndicators);
          _interventions.addAll(analysis.interventionSuggestions);
          _currentAnalysis = analysis.summary;
          _aiRecommendations = analysis.recommendations;
        });
        
        // Check for high-risk indicators
        _checkRiskLevels(analysis.riskIndicators);
      }
      
    } catch (e) {
      _logger.error('Real-time analysis failed', context: 'SessionScreen', error: e);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _performFinalAnalysis() async {
    try {
      setState(() => _isAnalyzing = true);
      
      final finalAnalysis = await _aiService.analyzeSessionData(
        sessionId: widget.sessionId,
        clientId: widget.clientId,
        sessionData: _sessionData,
        notes: _sessionNotes,
        isFinalAnalysis: true,
      );
      
      if (finalAnalysis != null) {
        setState(() {
          _sessionInsights.addAll(finalAnalysis.insights);
          _riskIndicators.addAll(finalAnalysis.riskIndicators);
          _interventions.addAll(finalAnalysis.interventionSuggestions);
          _currentAnalysis = finalAnalysis.summary;
          _aiRecommendations = finalAnalysis.recommendations;
        });
      }
      
    } catch (e) {
      _logger.error('Final analysis failed', context: 'SessionScreen', error: e);
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _checkRiskLevels(List<RiskIndicator> indicators) {
    final highRiskIndicators = indicators.where((i) => i.level == RiskLevel.high).toList();
    
    if (highRiskIndicators.isNotEmpty) {
      setState(() => _showRiskAlert = true);
      
      // Log high-risk situation
      _logger.warning('High-risk indicators detected', context: 'SessionScreen', data: {
        'sessionId': widget.sessionId,
        'indicators': highRiskIndicators.map((i) => i.type).toList(),
      });
    }
  }

  Future<void> _saveSessionData() async {
    try {
      // Save to local storage and sync with server
      _sessionData['endTime'] = _sessionEndTime!.toIso8601String();
      _sessionData['duration'] = _sessionDuration.inMinutes;
      _sessionData['notes'] = _sessionNotes;
      _sessionData['insights'] = _sessionInsights.map((i) => i.toJson()).toList();
      _sessionData['riskIndicators'] = _riskIndicators.map((r) => r.toJson()).toList();
      _sessionData['interventions'] = _interventions.map((i) => i.toJson()).toList();
      _sessionData['aiAnalysis'] = _currentAnalysis;
      _sessionData['aiRecommendations'] = _aiRecommendations;
      
      // TODO: Save to database/service
      
      _logger.info('Session data saved', context: 'SessionScreen');
      
    } catch (e) {
      _logger.error('Failed to save session data', context: 'SessionScreen', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seans: ${widget.clientName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          _buildSessionStatusChip(),
          const SizedBox(width: 16),
          _buildSessionControls(),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSessionStatusChip() {
    Color chipColor;
    String statusText;
    
    switch (_sessionState) {
      case SessionState.preparing:
        chipColor = Colors.orange;
        statusText = 'Hazırlanıyor';
        break;
      case SessionState.ready:
        chipColor = Colors.blue;
        statusText = 'Hazır';
        break;
      case SessionState.active:
        chipColor = Colors.green;
        statusText = 'Aktif';
        break;
      case SessionState.paused:
        chipColor = Colors.yellow;
        statusText = 'Duraklatıldı';
        break;
      case SessionState.ending:
        chipColor = Colors.red;
        statusText = 'Bitiriliyor';
        break;
      case SessionState.completed:
        chipColor = Colors.grey;
        statusText = 'Tamamlandı';
        break;
      case SessionState.error:
        chipColor = Colors.red;
        statusText = 'Hata';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildSessionControls() {
    switch (_sessionState) {
      case SessionState.ready:
        return ElevatedButton.icon(
          onPressed: _startSession,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Başlat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
        
      case SessionState.active:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _pauseSession,
              icon: const Icon(Icons.pause),
              label: const Text('Duraklat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _endSession,
              icon: const Icon(Icons.stop),
              label: const Text('Bitir'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
        
      case SessionState.paused:
        return ElevatedButton.icon(
          onPressed: _resumeSession,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Devam Et'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBody() {
    if (_sessionState == SessionState.error) {
      return _buildErrorView();
    }
    
    if (_sessionState == SessionState.preparing) {
      return _buildLoadingView();
    }
    
    return Column(
      children: [
        _buildSessionInfo(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNotesTab(),
              _buildAIAnalysisTab(),
              _buildMonitoringTab(),
              _buildExportTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seans Bilgileri',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('Başlangıç: ${_formatDateTime(_sessionStartTime)}'),
                if (_sessionEndTime != null)
                  Text('Bitiş: ${_formatDateTime(_sessionEndTime!)}'),
                if (_sessionDuration.inMinutes > 0)
                  Text('Süre: ${_formatDuration(_sessionDuration)}'),
              ],
            ),
          ),
          if (_isAnalyzing)
            const Column(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(height: 4),
                Text('AI Analiz...', style: TextStyle(fontSize: 12)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SessionNoteEditor(
      initialNotes: _sessionNotes,
      onNotesChanged: (notes) {
        setState(() => _sessionNotes = notes);
      },
      onSave: () {
        // Auto-save is handled by onNotesChanged
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notlar kaydedildi')),
        );
      },
    );
  }

  Widget _buildAIAnalysisTab() {
    return AISummaryPanel(
      summary: _currentAnalysis,
      insights: _sessionInsights,
      riskIndicators: _riskIndicators,
      interventions: _interventions,
      recommendations: _aiRecommendations,
      isLoading: _isAnalyzing,
      onRefresh: _performRealTimeAnalysis,
    );
  }

  Widget _buildMonitoringTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmotionalStateChart(),
          const SizedBox(height: 24),
          _buildRiskAssessmentChart(),
          const SizedBox(height: 24),
          _buildInterventionList(),
        ],
      ),
    );
  }

  Widget _buildEmotionalStateChart() {
    if (_emotionalStates.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Henüz duygusal durum verisi yok')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duygusal Durum Trendi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _emotionalStates.length) {
                            return Text(
                              _formatTime(_emotionalStates[value.toInt()].timestamp),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _emotionalStates.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.intensity.toDouble());
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
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

  Widget _buildRiskAssessmentChart() {
    if (_riskAssessments.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Henüz risk değerlendirme verisi yok')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Risk Değerlendirme',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _riskAssessments.length) {
                            return Text(
                              _formatTime(_riskAssessments[value.toInt()].timestamp),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _riskAssessments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final assessment = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: assessment.riskScore.toDouble(),
                          color: _getRiskColor(assessment.riskScore),
                          width: 20,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionList() {
    if (_interventions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Henüz müdahale önerisi yok')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Müdahale Önerileri',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _interventions.length,
              itemBuilder: (context, index) {
                final intervention = _interventions[index];
                return ListTile(
                  leading: Icon(
                    _getInterventionIcon(intervention.type),
                    color: _getInterventionColor(intervention.priority),
                  ),
                  title: Text(intervention.title),
                  subtitle: Text(intervention.description),
                  trailing: Chip(
                    label: Text(intervention.priority.name),
                    backgroundColor: _getInterventionColor(intervention.priority).withOpacity(0.2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportTab() {
    return PDFExportPanel(
      sessionData: _sessionData,
      sessionNotes: _sessionNotes,
      sessionInsights: _sessionInsights,
      riskIndicators: _riskIndicators,
      interventions: _interventions,
      aiAnalysis: _currentAnalysis,
      aiRecommendations: _aiRecommendations,
      clientName: widget.clientName,
      sessionDuration: _sessionDuration,
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getTabIndex(_selectedTab),
      onTap: (index) {
        _tabController.animateTo(index);
        setState(() => _selectedTab = _getTabName(index));
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_note),
          label: 'Notlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology),
          label: 'AI Analiz',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monitor_heart),
          label: 'İzleme',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.picture_as_pdf),
          label: 'PDF',
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Seans hazırlanıyor...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Seans yüklenirken hata oluştu'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeSession,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getRiskColor(int riskScore) {
    if (riskScore <= 3) return Colors.green;
    if (riskScore <= 6) return Colors.orange;
    return Colors.red;
  }

  Color _getInterventionColor(InterventionPriority priority) {
    switch (priority) {
      case InterventionPriority.low:
        return Colors.green;
      case InterventionPriority.medium:
        return Colors.orange;
      case InterventionPriority.high:
        return Colors.red;
      case InterventionPriority.critical:
        return Colors.purple;
    }
  }

  IconData _getInterventionIcon(InterventionType type) {
    switch (type) {
      case InterventionType.safety:
        return Icons.security;
      case InterventionType.therapeutic:
        return Icons.healing;
      case InterventionType.crisis:
        return Icons.warning;
      case InterventionType.referral:
        return Icons.people;
    }
  }

  int _getTabIndex(String tabName) {
    switch (tabName) {
      case 'notes': return 0;
      case 'ai_analysis': return 1;
      case 'monitoring': return 2;
      case 'export': return 3;
      default: return 0;
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0: return 'notes';
      case 1: return 'ai_analysis';
      case 2: return 'monitoring';
      case 3: return 'export';
      default: return 'notes';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}s ${minutes}dk';
    }
    return '${minutes}dk';
  }
}

enum SessionState {
  preparing,
  ready,
  active,
  paused,
  ending,
  completed,
  error,
}
