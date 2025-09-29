import 'package:flutter/material.dart';

// Ana analitik veri modeli
class AnalyticsData {
  final int totalSessions;
  final int activeClients;
  final double monthlyRevenue;
  final double satisfactionScore;
  final double sessionGrowth;
  final double clientGrowth;
  final double revenueGrowth;
  final double satisfactionGrowth;
  
  // Grafik verileri
  final List<ChartDataPoint> sessionTrends;
  final List<ChartDataPoint> revenueData;
  final List<PieChartData> clientDistribution;
  final List<RadarChartData> performanceComparison;
  
  // AI analiz verileri
  final List<AITrend> aiTrends;
  final List<AIInsight> aiInsights;
  final List<AIRecommendation> aiRecommendations;
  
  // Performans metrikleri
  final PerformanceMetrics clinicalMetrics;
  final PerformanceMetrics financialMetrics;
  final PerformanceMetrics operationalMetrics;
  final PerformanceMetrics qualityMetrics;
  
  // Detaylı analizler
  final List<SegmentationData> clientSegmentation;
  final TimeAnalysisData timeAnalysis;
  final RiskAnalysisData riskAnalysis;
  final PredictionModelData predictionModels;

  AnalyticsData({
    required this.totalSessions,
    required this.activeClients,
    required this.monthlyRevenue,
    required this.satisfactionScore,
    required this.sessionGrowth,
    required this.clientGrowth,
    required this.revenueGrowth,
    required this.satisfactionGrowth,
    required this.sessionTrends,
    required this.revenueData,
    required this.clientDistribution,
    required this.performanceComparison,
    required this.aiTrends,
    required this.aiInsights,
    required this.aiRecommendations,
    required this.clinicalMetrics,
    required this.financialMetrics,
    required this.operationalMetrics,
    required this.qualityMetrics,
    required this.clientSegmentation,
    required this.timeAnalysis,
    required this.riskAnalysis,
    required this.predictionModels,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      totalSessions: json['totalSessions'] ?? 0,
      activeClients: json['activeClients'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      satisfactionScore: (json['satisfactionScore'] ?? 0.0).toDouble(),
      sessionGrowth: (json['sessionGrowth'] ?? 0.0).toDouble(),
      clientGrowth: (json['clientGrowth'] ?? 0.0).toDouble(),
      revenueGrowth: (json['revenueGrowth'] ?? 0.0).toDouble(),
      satisfactionGrowth: (json['satisfactionGrowth'] ?? 0.0).toDouble(),
      sessionTrends: (json['sessionTrends'] as List?)
          ?.map((e) => ChartDataPoint.fromJson(e))
          .toList() ?? [],
      revenueData: (json['revenueData'] as List?)
          ?.map((e) => ChartDataPoint.fromJson(e))
          .toList() ?? [],
      clientDistribution: (json['clientDistribution'] as List?)
          ?.map((e) => PieChartData.fromJson(e))
          .toList() ?? [],
      performanceComparison: (json['performanceComparison'] as List?)
          ?.map((e) => RadarChartData.fromJson(e))
          .toList() ?? [],
      aiTrends: (json['aiTrends'] as List?)
          ?.map((e) => AITrend.fromJson(e))
          .toList() ?? [],
      aiInsights: (json['aiInsights'] as List?)
          ?.map((e) => AIInsight.fromJson(e))
          .toList() ?? [],
      aiRecommendations: (json['aiRecommendations'] as List?)
          ?.map((e) => AIRecommendation.fromJson(e))
          .toList() ?? [],
      clinicalMetrics: PerformanceMetrics.fromJson(json['clinicalMetrics'] ?? {}),
      financialMetrics: PerformanceMetrics.fromJson(json['financialMetrics'] ?? {}),
      operationalMetrics: PerformanceMetrics.fromJson(json['operationalMetrics'] ?? {}),
      qualityMetrics: PerformanceMetrics.fromJson(json['qualityMetrics'] ?? {}),
      clientSegmentation: (json['clientSegmentation'] as List?)
          ?.map((e) => SegmentationData.fromJson(e))
          .toList() ?? [],
      timeAnalysis: TimeAnalysisData.fromJson(json['timeAnalysis'] ?? {}),
      riskAnalysis: RiskAnalysisData.fromJson(json['riskAnalysis'] ?? {}),
      predictionModels: PredictionModelData.fromJson(json['predictionModels'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'activeClients': activeClients,
      'monthlyRevenue': monthlyRevenue,
      'satisfactionScore': satisfactionScore,
      'sessionGrowth': sessionGrowth,
      'clientGrowth': clientGrowth,
      'revenueGrowth': revenueGrowth,
      'satisfactionGrowth': satisfactionGrowth,
      'sessionTrends': sessionTrends.map((e) => e.toJson()).toList(),
      'revenueData': revenueData.map((e) => e.toJson()).toList(),
      'clientDistribution': clientDistribution.map((e) => e.toJson()).toList(),
      'performanceComparison': performanceComparison.map((e) => e.toJson()).toList(),
      'aiTrends': aiTrends.map((e) => e.toJson()).toList(),
      'aiInsights': aiInsights.map((e) => e.toJson()).toList(),
      'aiRecommendations': aiRecommendations.map((e) => e.toJson()).toList(),
      'clinicalMetrics': clinicalMetrics.toJson(),
      'financialMetrics': financialMetrics.toJson(),
      'operationalMetrics': operationalMetrics.toJson(),
      'qualityMetrics': qualityMetrics.toJson(),
      'clientSegmentation': clientSegmentation.map((e) => e.toJson()).toList(),
      'timeAnalysis': timeAnalysis.toJson(),
      'riskAnalysis': riskAnalysis.toJson(),
      'predictionModels': predictionModels.toJson(),
    };
  }
}

// Grafik veri noktası
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;
  final String? category;

  ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
    this.category,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'date': date?.toIso8601String(),
      'category': category,
    };
  }
}

// Pasta grafik verisi
class PieChartData {
  final String label;
  final double value;
  final Color color;
  final double percentage;

  PieChartData({
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  factory PieChartData.fromJson(Map<String, dynamic> json) {
    return PieChartData(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      color: Color(json['color'] ?? 0xFF000000),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'color': color.value,
      'percentage': percentage,
    };
  }
}

// Radar grafik verisi
class RadarChartData {
  final String label;
  final List<double> values;
  final Color color;

  RadarChartData({
    required this.label,
    required this.values,
    required this.color,
  });

  factory RadarChartData.fromJson(Map<String, dynamic> json) {
    return RadarChartData(
      label: json['label'] ?? '',
      values: (json['values'] as List?)?.map<double>((e) => (e ?? 0.0).toDouble()).toList() ?? [],
      color: Color(json['color'] ?? 0xFF000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'values': values,
      'color': color.value,
    };
  }
}

// AI Trend verisi
class AITrend {
  final String title;
  final String description;
  final TrendDirection direction;
  final double confidence;
  final List<String> factors;
  final DateTime detectedAt;

  AITrend({
    required this.title,
    required this.description,
    required this.direction,
    required this.confidence,
    required this.factors,
    required this.detectedAt,
  });

  factory AITrend.fromJson(Map<String, dynamic> json) {
    return AITrend(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      direction: TrendDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => TrendDirection.stable,
      ),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      factors: (json['factors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      detectedAt: DateTime.parse(json['detectedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'direction': direction.name,
      'confidence': confidence,
      'factors': factors,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }
}

// Trend yönü enum'u
enum TrendDirection { increasing, decreasing, stable, fluctuating }

// AI Insight verisi
class AIInsight {
  final String title;
  final String description;
  final InsightType type;
  final double impact;
  final List<String> recommendations;
  final DateTime generatedAt;

  AIInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.impact,
    required this.recommendations,
    required this.generatedAt,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: InsightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InsightType.general,
      ),
      impact: (json['impact'] ?? 0.0).toDouble(),
      recommendations: (json['recommendations'] as List?)?.map((e) => e.toString()).toList() ?? [],
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'impact': impact,
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}

// Insight türü enum'u
enum InsightType { clinical, financial, operational, quality, general }

// AI Recommendation verisi
class AIRecommendation {
  final String title;
  final String description;
  final RecommendationPriority priority;
  final double expectedImpact;
  final List<String> actionSteps;
  final DateTime validUntil;

  AIRecommendation({
    required this.title,
    required this.description,
    required this.priority,
    required this.expectedImpact,
    required this.actionSteps,
    required this.validUntil,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: RecommendationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => RecommendationPriority.medium,
      ),
      expectedImpact: (json['expectedImpact'] ?? 0.0).toDouble(),
      actionSteps: (json['actionSteps'] as List?)?.map((e) => e.toString()).toList() ?? [],
      validUntil: DateTime.parse(json['validUntil'] ?? DateTime.now().add(Duration(days: 30)).toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'expectedImpact': expectedImpact,
      'actionSteps': actionSteps,
      'validUntil': validUntil.toIso8601String(),
    };
  }
}

// Öneri önceliği enum'u
enum RecommendationPriority { low, medium, high, critical }

// Performans metrikleri
class PerformanceMetrics {
  final String name;
  final double currentValue;
  final double targetValue;
  final double previousValue;
  final MetricStatus status;
  final List<MetricDetail> details;

  PerformanceMetrics({
    required this.name,
    required this.currentValue,
    required this.targetValue,
    required this.previousValue,
    required this.status,
    required this.details,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      name: json['name'] ?? '',
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      targetValue: (json['targetValue'] ?? 0.0).toDouble(),
      previousValue: (json['previousValue'] ?? 0.0).toDouble(),
      status: MetricStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MetricStatus.neutral,
      ),
      details: (json['details'] as List?)
          ?.map((e) => MetricDetail.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'previousValue': previousValue,
      'status': status.name,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }

  double get progress => targetValue > 0 ? (currentValue / targetValue) * 100 : 0;
  double get change => previousValue > 0 ? ((currentValue - previousValue) / previousValue) * 100 : 0;
}

// Metrik durumu enum'u
enum MetricStatus { excellent, good, neutral, warning, critical }

// Metrik detayı
class MetricDetail {
  final String label;
  final double value;
  final String unit;
  final Color color;

  MetricDetail({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  factory MetricDetail.fromJson(Map<String, dynamic> json) {
    return MetricDetail(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      color: Color(json['color'] ?? 0xFF000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
      'unit': unit,
      'color': color.value,
    };
  }
}

// Segmentasyon verisi
class SegmentationData {
  final String segment;
  final int count;
  final double percentage;
  final double averageValue;
  final List<String> characteristics;

  SegmentationData({
    required this.segment,
    required this.count,
    required this.percentage,
    required this.averageValue,
    required this.characteristics,
  });

  factory SegmentationData.fromJson(Map<String, dynamic> json) {
    return SegmentationData(
      segment: json['segment'] ?? '',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      averageValue: (json['averageValue'] ?? 0.0).toDouble(),
      characteristics: (json['characteristics'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segment': segment,
      'count': count,
      'percentage': percentage,
      'averageValue': averageValue,
      'characteristics': characteristics,
    };
  }
}

// Zaman analizi verisi
class TimeAnalysisData {
  final Map<String, int> hourlyDistribution;
  final Map<String, int> dailyDistribution;
  final Map<String, int> monthlyDistribution;
  final List<PeakTime> peakTimes;
  final List<LowActivityTime> lowActivityTimes;

  TimeAnalysisData({
    required this.hourlyDistribution,
    required this.dailyDistribution,
    required this.monthlyDistribution,
    required this.peakTimes,
    required this.lowActivityTimes,
  });

  factory TimeAnalysisData.fromJson(Map<String, dynamic> json) {
    return TimeAnalysisData(
      hourlyDistribution: Map<String, int>.from(json['hourlyDistribution'] ?? {}),
      dailyDistribution: Map<String, int>.from(json['dailyDistribution'] ?? {}),
      monthlyDistribution: Map<String, int>.from(json['monthlyDistribution'] ?? {}),
      peakTimes: (json['peakTimes'] as List?)
          ?.map((e) => PeakTime.fromJson(e))
          .toList() ?? [],
      lowActivityTimes: (json['lowActivityTimes'] as List?)
          ?.map((e) => LowActivityTime.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hourlyDistribution': hourlyDistribution,
      'dailyDistribution': dailyDistribution,
      'monthlyDistribution': monthlyDistribution,
      'peakTimes': peakTimes.map((e) => e.toJson()).toList(),
      'lowActivityTimes': lowActivityTimes.map((e) => e.toJson()).toList(),
    };
  }
}

// Zirve zamanı
class PeakTime {
  final String timeSlot;
  final int activityLevel;
  final String reason;

  PeakTime({
    required this.timeSlot,
    required this.activityLevel,
    required this.reason,
  });

  factory PeakTime.fromJson(Map<String, dynamic> json) {
    return PeakTime(
      timeSlot: json['timeSlot'] ?? '',
      activityLevel: json['activityLevel'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': timeSlot,
      'activityLevel': activityLevel,
      'reason': reason,
    };
  }
}

// Düşük aktivite zamanı
class LowActivityTime {
  final String timeSlot;
  final int activityLevel;
  final String reason;

  LowActivityTime({
    required this.timeSlot,
    required this.activityLevel,
    required this.reason,
  });

  factory LowActivityTime.fromJson(Map<String, dynamic> json) {
    return LowActivityTime(
      timeSlot: json['timeSlot'] ?? '',
      activityLevel: json['activityLevel'] ?? 0,
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeSlot': timeSlot,
      'activityLevel': activityLevel,
      'reason': reason,
    };
  }
}

// Risk analizi verisi
class RiskAnalysisData {
  final double overallRiskScore;
  final List<RiskFactor> riskFactors;
  final List<RiskMitigation> mitigations;
  final DateTime lastUpdated;

  RiskAnalysisData({
    required this.overallRiskScore,
    required this.riskFactors,
    required this.mitigations,
    required this.lastUpdated,
  });

  factory RiskAnalysisData.fromJson(Map<String, dynamic> json) {
    return RiskAnalysisData(
      overallRiskScore: (json['overallRiskScore'] ?? 0.0).toDouble(),
      riskFactors: (json['riskFactors'] as List?)
          ?.map((e) => RiskFactor.fromJson(e))
          .toList() ?? [],
      mitigations: (json['mitigations'] as List?)
          ?.map((e) => RiskMitigation.fromJson(e))
          .toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallRiskScore': overallRiskScore,
      'riskFactors': riskFactors.map((e) => e.toJson()).toList(),
      'mitigations': mitigations.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

// Risk faktörü
class RiskFactor {
  final String name;
  final double probability;
  final double impact;
  final RiskLevel level;
  final String description;

  RiskFactor({
    required this.name,
    required this.probability,
    required this.impact,
    required this.level,
    required this.description,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      name: json['name'] ?? '',
      probability: (json['probability'] ?? 0.0).toDouble(),
      impact: (json['impact'] ?? 0.0).toDouble(),
      level: RiskLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => RiskLevel.low,
      ),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'probability': probability,
      'impact': impact,
      'level': level.name,
      'description': description,
    };
  }

  double get riskScore => probability * impact;
}

// Risk seviyesi enum'u
enum RiskLevel { low, medium, high, critical }

// Risk azaltma
class RiskMitigation {
  final String strategy;
  final double effectiveness;
  final double cost;
  final String description;

  RiskMitigation({
    required this.strategy,
    required this.effectiveness,
    required this.cost,
    required this.description,
  });

  factory RiskMitigation.fromJson(Map<String, dynamic> json) {
    return RiskMitigation(
      strategy: json['strategy'] ?? '',
      effectiveness: (json['effectiveness'] ?? 0.0).toDouble(),
      cost: (json['cost'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy,
      'effectiveness': effectiveness,
      'cost': cost,
      'description': description,
    };
  }
}

// Tahmin modeli verisi
class PredictionModelData {
  final String modelName;
  final double accuracy;
  final List<Prediction> predictions;
  final List<ModelFeature> features;
  final DateTime lastTrained;

  PredictionModelData({
    required this.modelName,
    required this.accuracy,
    required this.predictions,
    required this.features,
    required this.lastTrained,
  });

  factory PredictionModelData.fromJson(Map<String, dynamic> json) {
    return PredictionModelData(
      modelName: json['modelName'] ?? '',
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      predictions: (json['predictions'] as List?)
          ?.map((e) => Prediction.fromJson(e))
          .toList() ?? [],
      features: (json['features'] as List?)
          ?.map((e) => ModelFeature.fromJson(e))
          .toList() ?? [],
      lastTrained: DateTime.parse(json['lastTrained'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'accuracy': accuracy,
      'predictions': predictions.map((e) => e.toJson()).toList(),
      'features': features.map((e) => e.toJson()).toList(),
      'lastTrained': lastTrained.toIso8601String(),
    };
  }
}

// Tahmin
class Prediction {
  final String target;
  final double predictedValue;
  final double confidence;
  final DateTime predictionDate;
  final List<String> factors;

  Prediction({
    required this.target,
    required this.predictedValue,
    required this.confidence,
    required this.predictionDate,
    required this.factors,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      target: json['target'] ?? '',
      predictedValue: (json['predictedValue'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      predictionDate: DateTime.parse(json['predictionDate'] ?? DateTime.now().toIso8601String()),
      factors: (json['factors'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'predictedValue': predictedValue,
      'confidence': confidence,
      'predictionDate': predictionDate.toIso8601String(),
      'factors': factors,
    };
  }
}

// Model özelliği
class ModelFeature {
  final String name;
  final double importance;
  final String description;

  ModelFeature({
    required this.name,
    required this.importance,
    required this.description,
  });

  factory ModelFeature.fromJson(Map<String, dynamic> json) {
    return ModelFeature(
      name: json['name'] ?? '',
      importance: (json['importance'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'importance': importance,
      'description': description,
    };
  }
}
