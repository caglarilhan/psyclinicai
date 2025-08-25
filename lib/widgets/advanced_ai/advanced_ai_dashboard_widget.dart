import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/advanced_ai_service.dart';
import '../../models/advanced_ai_models.dart';

class AdvancedAIDashboardWidget extends StatefulWidget {
  const AdvancedAIDashboardWidget({super.key});

  @override
  State<AdvancedAIDashboardWidget> createState() => _AdvancedAIDashboardWidgetState();
}

class _AdvancedAIDashboardWidgetState extends State<AdvancedAIDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _metricController;
  String _selectedView = 'overview';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _metricController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _metricController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdvancedAIService>(
      builder: (context, aiService, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '🤖 Advanced AI Dashboard',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Align(alignment: Alignment.centerRight, child: _buildViewSelector())),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Genel Bakış'),
                    Tab(text: 'Tahmin Analizi'),
                    Tab(text: 'NLP & Metin'),
                    Tab(text: 'Görsel Analiz'),
                    Tab(text: 'Ses Analizi'),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Content
                SizedBox(
                  height: 450,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(aiService),
                      _buildPredictiveAnalyticsTab(aiService),
                      _buildNLPTab(aiService),
                      _buildComputerVisionTab(aiService),
                      _buildVoiceAnalysisTab(aiService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewSelector() {
    return DropdownButton<String>(
      value: _selectedView,
      items: const [
        DropdownMenuItem(value: 'overview', child: Text('Genel Bakış')),
        DropdownMenuItem(value: 'detailed', child: Text('Detaylı')),
        DropdownMenuItem(value: 'analytics', child: Text('Analitik')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedView = value!;
        });
      },
    );
  }

  Widget _buildOverviewTab(AdvancedAIService aiService) {
    final predictiveModels = aiService.predictiveModels;
    final relapsePredictions = aiService.relapsePredictions;
    final icdExtractions = aiService.icdExtractions;
    final facialAnalyses = aiService.facialAnalyses;
    final voiceAnalyses = aiService.voiceAnalyses;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(child: _buildMetricCard('AI Modelleri', predictiveModels.length.toString(), Icons.psychology)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Tahminler', relapsePredictions.length.toString(), Icons.trending_up)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('ICD Çıkarımları', icdExtractions.length.toString(), Icons.medical_services)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Yüz Analizleri', facialAnalyses.length.toString(), Icons.face)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Ses Analizleri', voiceAnalyses.length.toString(), Icons.record_voice_over)),
            ],
          ),
          const SizedBox(height: 24),

          // Model Performance Chart
          _buildModelPerformanceChart(predictiveModels),
          const SizedBox(height: 24),

          // Recent Predictions
          _buildRecentPredictions(relapsePredictions),
        ],
      ),
    );
  }

  Widget _buildPredictiveAnalyticsTab(AdvancedAIService aiService) {
    final relapsePredictions = aiService.relapsePredictions;

    return Column(
      children: [
        // Prediction Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _generateRelapsePrediction(context),
              icon: const Icon(Icons.add),
              label: const Text('Tahmin Oluştur'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _viewPredictionHistory(context),
              icon: const Icon(Icons.history),
              label: const Text('Geçmiş Tahminler'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Predictions List
        Expanded(
          child: ListView.builder(
            itemCount: relapsePredictions.length,
            itemBuilder: (context, index) {
              final prediction = relapsePredictions[index];
              return _buildRelapsePredictionCard(prediction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNLPTab(AdvancedAIService aiService) {
    final icdExtractions = aiService.icdExtractions;
    final sentimentAnalyses = aiService.sentimentAnalyses;

    return Column(
      children: [
        // NLP Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _extractICDCodes(context),
              icon: const Icon(Icons.text_fields),
              label: const Text('ICD Kodları Çıkar'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _analyzeSentiment(context),
              icon: const Icon(Icons.sentiment_satisfied),
              label: const Text('Duygu Analizi'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tab for different NLP results
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'ICD Çıkarımları'),
                  Tab(text: 'Duygu Analizleri'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildICDExtractionsList(icdExtractions),
                    _buildSentimentAnalysesList(sentimentAnalyses),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComputerVisionTab(AdvancedAIService aiService) {
    final facialAnalyses = aiService.facialAnalyses;

    return Column(
      children: [
        // Vision Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _analyzeFacialExpressions(context),
              icon: const Icon(Icons.face),
              label: const Text('Yüz Analizi'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _viewVisionModels(context),
              icon: const Icon(Icons.model_training),
              label: const Text('Modelleri Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Facial Analyses List
        Expanded(
          child: ListView.builder(
            itemCount: facialAnalyses.length,
            itemBuilder: (context, index) {
              final analysis = facialAnalyses[index];
              return _buildFacialAnalysisCard(analysis);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceAnalysisTab(AdvancedAIService aiService) {
    final voiceAnalyses = aiService.voiceAnalyses;

    return Column(
      children: [
        // Voice Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _analyzeVoice(context),
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Ses Analizi'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _viewVoiceModels(context),
              icon: const Icon(Icons.model_training),
              label: const Text('Modelleri Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Voice Analyses List
        Expanded(
          child: ListView.builder(
            itemCount: voiceAnalyses.length,
            itemBuilder: (context, index) {
              final analysis = voiceAnalyses[index];
              return _buildVoiceAnalysisCard(analysis);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelPerformanceChart(List<PredictiveModel> models) {
    if (models.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Henüz AI modeli yüklenmedi'),
        ),
      );
    }

    final modelNames = models.map((m) => m.name.substring(0, 15)).toList();
    final accuracies = models.map((m) => m.performance.accuracy).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Performansı (Doğruluk)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1.0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < modelNames.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                modelNames[value.toInt()],
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
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
                          return Text('${(value * 100).toInt()}%');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: accuracies.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Theme.of(context).primaryColor,
                          width: 20,
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

  Widget _buildRecentPredictions(List<RelapsePrediction> predictions) {
    if (predictions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Henüz tahmin oluşturulmadı'),
        ),
      );
    }

    final recentPredictions = predictions.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Tahminler',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...recentPredictions.map((prediction) => _buildPredictionItem(prediction)),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(RelapsePrediction prediction) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getRiskLevelColor(prediction.riskLevel),
        child: Text(
          '${(prediction.relapseRisk * 100).toInt()}%',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
      title: Text('Hasta ${prediction.patientId.substring(0, 8)}'),
      subtitle: Text(
        'Risk Seviyesi: ${prediction.riskLevel.name}\n'
        'Tahmin Tarihi: ${_formatDateTime(prediction.predictedDate)}',
      ),
      trailing: Icon(
        _getRiskLevelIcon(prediction.riskLevel),
        color: _getRiskLevelColor(prediction.riskLevel),
      ),
    );
  }

  Widget _buildRelapsePredictionCard(RelapsePrediction prediction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('Hasta ${prediction.patientId.substring(0, 8)}'),
        subtitle: Text('Risk: ${(prediction.relapseRisk * 100).toInt()}% - ${prediction.riskLevel.name}'),
        leading: CircleAvatar(
          backgroundColor: _getRiskLevelColor(prediction.riskLevel),
          child: Text(
            '${(prediction.relapseRisk * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Güven: ${(prediction.confidence * 100).toInt()}%'),
                Text('Tahmin Tarihi: ${_formatDateTime(prediction.predictedDate)}'),
                const SizedBox(height: 8),
                Text('Risk Faktörleri:', style: Theme.of(context).textTheme.titleSmall),
                ...prediction.riskFactors.map((factor) => Text('• $factor')),
                const SizedBox(height: 8),
                Text('Koruyucu Faktörler:', style: Theme.of(context).textTheme.titleSmall),
                ...prediction.protectiveFactors.map((factor) => Text('• $factor')),
                const SizedBox(height: 16),
                Text('Önerilen Stratejiler:', style: Theme.of(context).textTheme.titleSmall),
                ...prediction.mitigations.map((mitigation) => 
                  ListTile(
                    title: Text(mitigation.strategy),
                    subtitle: Text(mitigation.description),
                    trailing: Text('${(mitigation.effectiveness * 100).toInt()}%'),
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildICDExtractionsList(List<ICDCodeExtraction> extractions) {
    if (extractions.isEmpty) {
      return const Center(child: Text('Henüz ICD kodu çıkarılmadı'));
    }

    return ListView.builder(
      itemCount: extractions.length,
      itemBuilder: (context, index) {
        final extraction = extractions[index];
        return _buildICDExtractionCard(extraction);
      },
    );
  }

  Widget _buildICDExtractionCard(ICDCodeExtraction extraction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('Seans ${extraction.sessionId.substring(0, 8)}'),
        subtitle: Text('${extraction.extractedCodes.length} kod çıkarıldı'),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${(extraction.confidence * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Orijinal Metin:', style: Theme.of(context).textTheme.titleSmall),
                Text(extraction.originalText, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text('Çıkarılan Kodlar:', style: Theme.of(context).textTheme.titleSmall),
                ...extraction.extractedCodes.map((code) => 
                  Card(
                    child: ListTile(
                      title: Text('${code.icdCode} - ${code.description}'),
                      subtitle: Text('Güven: ${(code.confidence * 100).toInt()}% - Şiddet: ${code.severity}'),
                      trailing: Text(code.modifier ?? ''),
                    ),
                  )
                ),
                if (extraction.reasoning != null) ...[
                  const SizedBox(height: 16),
                  Text('Gerekçe:', style: Theme.of(context).textTheme.titleSmall),
                  Text(extraction.reasoning!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentAnalysesList(List<SentimentAnalysis> analyses) {
    if (analyses.isEmpty) {
      return const Center(child: Text('Henüz duygu analizi yapılmadı'));
    }

    return ListView.builder(
      itemCount: analyses.length,
      itemBuilder: (context, index) {
        final analysis = analyses[index];
        return _buildSentimentAnalysisCard(analysis);
      },
    );
  }

  Widget _buildSentimentAnalysisCard(SentimentAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('Metin ${analysis.textId.substring(0, 8)}'),
        subtitle: Text('Ana Duygu: ${analysis.primarySentiment.name}'),
        leading: CircleAvatar(
          backgroundColor: _getSentimentColor(analysis.primarySentiment),
          child: Icon(
            _getSentimentIcon(analysis.primarySentiment),
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Metin:', style: Theme.of(context).textTheme.titleSmall),
                Text(analysis.text, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text('Duygu Skorları:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.sentimentScores.entries.map((entry) => 
                  ListTile(
                    title: Text(entry.key.name),
                    trailing: Text('${(entry.value * 100).toInt()}%'),
                  )
                ),
                const SizedBox(height: 16),
                Text('Tespit Edilen Duygular:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.emotions.map((emotion) => 
                  ListTile(
                    title: Text(emotion.type.name),
                    subtitle: Text('Yoğunluk: ${(emotion.intensity * 100).toInt()}%'),
                    trailing: Text('${(emotion.confidence * 100).toInt()}%'),
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacialAnalysisCard(FacialExpressionAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('Seans ${analysis.sessionId.substring(0, 8)}'),
        subtitle: Text('${analysis.emotions.length} duygu tespit edildi'),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${(analysis.confidence * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tespit Edilen Duygular:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.emotions.map((emotion) => 
                  ListTile(
                    title: Text(emotion.emotion.name),
                    subtitle: Text('Yoğunluk: ${(emotion.intensity * 100).toInt()}%'),
                    trailing: Text('${(emotion.confidence * 100).toInt()}%'),
                  )
                ),
                const SizedBox(height: 16),
                Text('Yüz Aksiyonları:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.actions.map((action) => 
                  ListTile(
                    title: Text(action.actionUnit),
                    subtitle: Text(action.description),
                    trailing: Text('${(action.intensity * 100).toInt()}%'),
                  )
                ),
                const SizedBox(height: 16),
                Text('Kalite Metrikleri:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.qualityMetrics.map((metric) => Text('• $metric')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceAnalysisCard(VoiceAnalysis analysis) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text('Seans ${analysis.sessionId.substring(0, 8)}'),
        subtitle: Text('${analysis.emotions.length} ses duygusu tespit edildi'),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${(analysis.confidence * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ses Özellikleri:', style: Theme.of(context).textTheme.titleSmall),
                ListTile(
                  title: Text('Pitch: ${analysis.characteristics.pitch.toStringAsFixed(1)} Hz'),
                  subtitle: Text('Konuşma Hızı: ${analysis.characteristics.speakingRate.toStringAsFixed(1)} WPM'),
                ),
                ListTile(
                  title: Text('Ses: ${analysis.characteristics.volume.toStringAsFixed(1)} dB'),
                  subtitle: Text('Netlik: ${(analysis.characteristics.clarity * 100).toInt()}%'),
                ),
                const SizedBox(height: 16),
                Text('Ses Duyguları:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.emotions.map((emotion) => 
                  ListTile(
                    title: Text(emotion.emotion.name),
                    subtitle: Text('Yoğunluk: ${(emotion.intensity * 100).toInt()}%'),
                    trailing: Text('${(emotion.confidence * 100).toInt()}%'),
                  )
                ),
                const SizedBox(height: 16),
                Text('Kalite Metrikleri:', style: Theme.of(context).textTheme.titleSmall),
                ...analysis.qualityMetrics.map((metric) => Text('• $metric')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Utility Methods
  Color _getRiskLevelColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.moderate:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.purple;
    }
  }

  IconData _getRiskLevelIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.moderate:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }

  Color _getSentimentColor(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.positive:
        return Colors.green;
      case SentimentType.negative:
        return Colors.red;
      case SentimentType.neutral:
        return Colors.grey;
      case SentimentType.mixed:
        return Colors.purple;
    }
  }

  IconData _getSentimentIcon(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.positive:
        return Icons.sentiment_satisfied;
      case SentimentType.negative:
        return Icons.sentiment_dissatisfied;
      case SentimentType.neutral:
        return Icons.sentiment_neutral;
      case SentimentType.mixed:
        return Icons.sentiment_satisfied_alt;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  // Action Handlers
  void _generateRelapsePrediction(BuildContext context) {
    // TODO: Implement relapse prediction generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahmin oluşturma özelliği yakında eklenecek')),
    );
  }

  void _viewPredictionHistory(BuildContext context) {
    // TODO: Implement prediction history view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tahmin geçmişi yakında eklenecek')),
    );
  }

  void _extractICDCodes(BuildContext context) {
    // TODO: Implement ICD code extraction
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ICD kodu çıkarma özelliği yakında eklenecek')),
    );
  }

  void _analyzeSentiment(BuildContext context) {
    // TODO: Implement sentiment analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duygu analizi özelliği yakında eklenecek')),
    );
  }

  void _analyzeFacialExpressions(BuildContext context) {
    // TODO: Implement facial expression analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yüz analizi özelliği yakında eklenecek')),
    );
  }

  void _viewVisionModels(BuildContext context) {
    // TODO: Implement vision models view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Görsel modeller yakında eklenecek')),
    );
  }

  void _analyzeVoice(BuildContext context) {
    // TODO: Implement voice analysis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ses analizi özelliği yakında eklenecek')),
    );
  }

  void _viewVoiceModels(BuildContext context) {
    // TODO: Implement voice models view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ses modelleri yakında eklenecek')),
    );
  }
}
