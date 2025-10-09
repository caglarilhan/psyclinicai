import 'dart:convert';

enum AnalyticsPeriod { daily, weekly, monthly, yearly }
enum AnalyticsMetric { sessions, revenue, patients, satisfaction, retention }

class ClinicalKPI {
  final String id;
  final String metricName;
  final double value;
  final double? previousValue;
  final double? targetValue;
  final AnalyticsPeriod period;
  final DateTime date;
  final Map<String, dynamic> metadata;

  ClinicalKPI({
    required this.id,
    required this.metricName,
    required this.value,
    this.previousValue,
    this.targetValue,
    required this.period,
    required this.date,
    this.metadata = const {},
  });

  double get changePercentage {
    if (previousValue == null || previousValue == 0) return 0;
    return ((value - previousValue!) / previousValue!) * 100;
  }

  bool get isPositiveChange => changePercentage > 0;
  bool get isNegativeChange => changePercentage < 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricName': metricName,
      'value': value,
      'previousValue': previousValue,
      'targetValue': targetValue,
      'period': period.name,
      'date': date.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ClinicalKPI.fromJson(Map<String, dynamic> json) {
    return ClinicalKPI(
      id: json['id'],
      metricName: json['metricName'],
      value: json['value'].toDouble(),
      previousValue: json['previousValue']?.toDouble(),
      targetValue: json['targetValue']?.toDouble(),
      period: AnalyticsPeriod.values.firstWhere((e) => e.name == json['period']),
      date: DateTime.parse(json['date']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class TrendAnalysis {
  final String id;
  final AnalyticsMetric metric;
  final AnalyticsPeriod period;
  final List<DataPoint> dataPoints;
  final TrendDirection direction;
  final double trendStrength;
  final String interpretation;
  final DateTime analyzedAt;

  TrendAnalysis({
    required this.id,
    required this.metric,
    required this.period,
    required this.dataPoints,
    required this.direction,
    required this.trendStrength,
    required this.interpretation,
    required this.analyzedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metric': metric.name,
      'period': period.name,
      'dataPoints': dataPoints.map((dp) => dp.toJson()).toList(),
      'direction': direction.name,
      'trendStrength': trendStrength,
      'interpretation': interpretation,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) {
    return TrendAnalysis(
      id: json['id'],
      metric: AnalyticsMetric.values.firstWhere((e) => e.name == json['metric']),
      period: AnalyticsPeriod.values.firstWhere((e) => e.name == json['period']),
      dataPoints: (json['dataPoints'] as List)
          .map((dp) => DataPoint.fromJson(dp))
          .toList(),
      direction: TrendDirection.values.firstWhere((e) => e.name == json['direction']),
      trendStrength: json['trendStrength'].toDouble(),
      interpretation: json['interpretation'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }
}

class DataPoint {
  final DateTime date;
  final double value;
  final Map<String, dynamic> metadata;

  DataPoint({
    required this.date,
    required this.value,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'metadata': metadata,
    };
  }

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      date: DateTime.parse(json['date']),
      value: json['value'].toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }
}

enum TrendDirection { increasing, decreasing, stable, volatile }

class PatientOutcomeMetrics {
  final String id;
  final String patientId;
  final String assessmentType;
  final double baselineScore;
  final double currentScore;
  final double improvementPercentage;
  final int sessionsCompleted;
  final DateTime baselineDate;
  final DateTime currentDate;
  final String outcomeCategory;

  PatientOutcomeMetrics({
    required this.id,
    required this.patientId,
    required this.assessmentType,
    required this.baselineScore,
    required this.currentScore,
    required this.improvementPercentage,
    required this.sessionsCompleted,
    required this.baselineDate,
    required this.currentDate,
    required this.outcomeCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'assessmentType': assessmentType,
      'baselineScore': baselineScore,
      'currentScore': currentScore,
      'improvementPercentage': improvementPercentage,
      'sessionsCompleted': sessionsCompleted,
      'baselineDate': baselineDate.toIso8601String(),
      'currentDate': currentDate.toIso8601String(),
      'outcomeCategory': outcomeCategory,
    };
  }

  factory PatientOutcomeMetrics.fromJson(Map<String, dynamic> json) {
    return PatientOutcomeMetrics(
      id: json['id'],
      patientId: json['patientId'],
      assessmentType: json['assessmentType'],
      baselineScore: json['baselineScore'].toDouble(),
      currentScore: json['currentScore'].toDouble(),
      improvementPercentage: json['improvementPercentage'].toDouble(),
      sessionsCompleted: json['sessionsCompleted'],
      baselineDate: DateTime.parse(json['baselineDate']),
      currentDate: DateTime.parse(json['currentDate']),
      outcomeCategory: json['outcomeCategory'],
    );
  }
}

class RevenueAnalytics {
  final String id;
  final AnalyticsPeriod period;
  final double totalRevenue;
  final double recurringRevenue;
  final double oneTimeRevenue;
  final int totalSessions;
  final double averageSessionValue;
  final double revenueGrowth;
  final DateTime periodStart;
  final DateTime periodEnd;

  RevenueAnalytics({
    required this.id,
    required this.period,
    required this.totalRevenue,
    required this.recurringRevenue,
    required this.oneTimeRevenue,
    required this.totalSessions,
    required this.averageSessionValue,
    required this.revenueGrowth,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period.name,
      'totalRevenue': totalRevenue,
      'recurringRevenue': recurringRevenue,
      'oneTimeRevenue': oneTimeRevenue,
      'totalSessions': totalSessions,
      'averageSessionValue': averageSessionValue,
      'revenueGrowth': revenueGrowth,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      id: json['id'],
      period: AnalyticsPeriod.values.firstWhere((e) => e.name == json['period']),
      totalRevenue: json['totalRevenue'].toDouble(),
      recurringRevenue: json['recurringRevenue'].toDouble(),
      oneTimeRevenue: json['oneTimeRevenue'].toDouble(),
      totalSessions: json['totalSessions'],
      averageSessionValue: json['averageSessionValue'].toDouble(),
      revenueGrowth: json['revenueGrowth'].toDouble(),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
    );
  }
}

class PatientRetentionMetrics {
  final String id;
  final AnalyticsPeriod period;
  final int newPatients;
  final int retainedPatients;
  final int lostPatients;
  final double retentionRate;
  final double churnRate;
  final double averageLifetimeValue;
  final DateTime periodStart;
  final DateTime periodEnd;

  PatientRetentionMetrics({
    required this.id,
    required this.period,
    required this.newPatients,
    required this.retainedPatients,
    required this.lostPatients,
    required this.retentionRate,
    required this.churnRate,
    required this.averageLifetimeValue,
    required this.periodStart,
    required this.periodEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period.name,
      'newPatients': newPatients,
      'retainedPatients': retainedPatients,
      'lostPatients': lostPatients,
      'retentionRate': retentionRate,
      'churnRate': churnRate,
      'averageLifetimeValue': averageLifetimeValue,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory PatientRetentionMetrics.fromJson(Map<String, dynamic> json) {
    return PatientRetentionMetrics(
      id: json['id'],
      period: AnalyticsPeriod.values.firstWhere((e) => e.name == json['period']),
      newPatients: json['newPatients'],
      retainedPatients: json['retainedPatients'],
      lostPatients: json['lostPatients'],
      retentionRate: json['retentionRate'].toDouble(),
      churnRate: json['churnRate'].toDouble(),
      averageLifetimeValue: json['averageLifetimeValue'].toDouble(),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
    );
  }
}

class AnalyticsDashboard {
  final String id;
  final String userId;
  final List<ClinicalKPI> kpis;
  final List<TrendAnalysis> trends;
  final RevenueAnalytics revenue;
  final PatientRetentionMetrics retention;
  final List<PatientOutcomeMetrics> patientOutcomes;
  final DateTime generatedAt;
  final AnalyticsPeriod period;

  AnalyticsDashboard({
    required this.id,
    required this.userId,
    required this.kpis,
    required this.trends,
    required this.revenue,
    required this.retention,
    required this.patientOutcomes,
    required this.generatedAt,
    required this.period,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'kpis': kpis.map((kpi) => kpi.toJson()).toList(),
      'trends': trends.map((trend) => trend.toJson()).toList(),
      'revenue': revenue.toJson(),
      'retention': retention.toJson(),
      'patientOutcomes': patientOutcomes.map((outcome) => outcome.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
      'period': period.name,
    };
  }

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboard(
      id: json['id'],
      userId: json['userId'],
      kpis: (json['kpis'] as List)
          .map((kpi) => ClinicalKPI.fromJson(kpi))
          .toList(),
      trends: (json['trends'] as List)
          .map((trend) => TrendAnalysis.fromJson(trend))
          .toList(),
      revenue: RevenueAnalytics.fromJson(json['revenue']),
      retention: PatientRetentionMetrics.fromJson(json['retention']),
      patientOutcomes: (json['patientOutcomes'] as List)
          .map((outcome) => PatientOutcomeMetrics.fromJson(outcome))
          .toList(),
      generatedAt: DateTime.parse(json['generatedAt']),
      period: AnalyticsPeriod.values.firstWhere((e) => e.name == json['period']),
    );
  }
}