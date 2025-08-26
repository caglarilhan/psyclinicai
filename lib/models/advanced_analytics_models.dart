import 'package:json_annotation/json_annotation.dart';

part 'advanced_analytics_models.g.dart';

/// Analytics Dashboard Type - Kullanıcı dostu kategoriler
enum DashboardType {
  @JsonValue('overview') overview,           // Genel Bakış
  @JsonValue('financial') financial,         // Finansal
  @JsonValue('patients') patients,           // Hasta
  @JsonValue('operations') operations,       // Operasyonel
  @JsonValue('quality') quality,             // Kalite
  @JsonValue('staff') staff,                 // Personel
  @JsonValue('custom') custom,               // Özel
}

/// Data Visualization Type - Basit grafik türleri
enum VisualizationType {
  @JsonValue('line') line,                   // Çizgi grafik
  @JsonValue('bar') bar,                     // Sütun grafik
  @JsonValue('pie') pie,                     // Pasta grafik
  @JsonValue('area') area,                   // Alan grafik
  @JsonValue('table') table,                 // Tablo
  @JsonValue('gauge') gauge,                 // Gösterge
  @JsonValue('trend') trend,                 // Trend
}

/// Time Period - Basit zaman seçenekleri
enum TimePeriod {
  @JsonValue('today') today,                 // Bugün
  @JsonValue('week') week,                   // Bu Hafta
  @JsonValue('month') month,                 // Bu Ay
  @JsonValue('quarter') quarter,             // Bu Çeyrek
  @JsonValue('year') year,                   // Bu Yıl
  @JsonValue('custom') custom,               // Özel
}

/// Priority Level - Basit öncelik sistemi
enum PriorityLevel {
  @JsonValue('low') low,                     // Düşük
  @JsonValue('medium') medium,               // Orta
  @JsonValue('high') high,                   // Yüksek
  @JsonValue('critical') critical,           // Kritik
}

/// Analytics Dashboard - Ana dashboard
@JsonSerializable()
class AnalyticsDashboard {
  final String id;
  final String name;
  final String description;
  final DashboardType type;
  final List<DashboardWidget> widgets;
  final Map<String, dynamic> settings;
  final bool isDefault;
  final bool isPublic;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnalyticsDashboard({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.widgets,
    required this.settings,
    required this.isDefault,
    required this.isPublic,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsDashboardToJson(this);
}

/// Dashboard Widget - Dashboard bileşeni
@JsonSerializable()
class DashboardWidget {
  final String id;
  final String name;
  final String description;
  final VisualizationType visualizationType;
  final Map<String, dynamic> data;
  final Map<String, dynamic> configuration;
  final int positionX;
  final int positionY;
  final int width;
  final int height;
  final bool isVisible;
  final bool isRefreshable;
  final int refreshInterval; // seconds
  final DateTime createdAt;
  final DateTime updatedAt;

  const DashboardWidget({
    required this.id,
    required this.name,
    required this.description,
    required this.visualizationType,
    required this.data,
    required this.configuration,
    required this.positionX,
    required this.positionY,
    required this.width,
    required this.height,
    required this.isVisible,
    required this.isRefreshable,
    required this.refreshInterval,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DashboardWidget.fromJson(Map<String, dynamic> json) =>
      _$DashboardWidgetFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardWidgetToJson(this);
}

/// Financial Analytics - Finansal analitikler
@JsonSerializable()
class FinancialAnalytics {
  final String id;
  final DateTime date;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final double revenueGrowth;
  final double expenseGrowth;
  final Map<String, double> revenueByService;
  final Map<String, double> expensesByCategory;
  final Map<String, double> profitByService;
  final List<FinancialMetric> keyMetrics;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FinancialAnalytics({
    required this.id,
    required this.date,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.revenueGrowth,
    required this.expenseGrowth,
    required this.revenueByService,
    required this.expensesByCategory,
    required this.profitByService,
    required this.keyMetrics,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FinancialAnalytics.fromJson(Map<String, dynamic> json) =>
      _$FinancialAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialAnalyticsToJson(this);
}

/// Financial Metric - Finansal metrik
@JsonSerializable()
class FinancialMetric {
  final String id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final double change;
  final double changePercent;
  final PriorityLevel priority;
  final bool isPositive;
  final String trend; // 'up', 'down', 'stable'
  final Map<String, dynamic> metadata;

  const FinancialMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.change,
    required this.changePercent,
    required this.priority,
    required this.isPositive,
    required this.trend,
    required this.metadata,
  });

  factory FinancialMetric.fromJson(Map<String, dynamic> json) =>
      _$FinancialMetricFromJson(json);

  Map<String, dynamic> toJson() => _$FinancialMetricToJson(this);
}

/// Patient Analytics - Hasta analitikleri
@JsonSerializable()
class PatientAnalytics {
  final String id;
  final DateTime date;
  final int totalPatients;
  final int newPatients;
  final int activePatients;
  final int dischargedPatients;
  final double averageSessionDuration;
  final double patientSatisfactionScore;
  final Map<String, int> patientsByAge;
  final Map<String, int> patientsByGender;
  final Map<String, int> patientsByDiagnosis;
  final Map<String, int> patientsByTreatment;
  final List<PatientMetric> keyMetrics;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientAnalytics({
    required this.id,
    required this.date,
    required this.totalPatients,
    required this.newPatients,
    required this.activePatients,
    required this.dischargedPatients,
    required this.averageSessionDuration,
    required this.patientSatisfactionScore,
    required this.patientsByAge,
    required this.patientsByGender,
    required this.patientsByDiagnosis,
    required this.patientsByTreatment,
    required this.keyMetrics,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PatientAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PatientAnalyticsToJson(this);
}

/// Patient Metric - Hasta metrik
@JsonSerializable()
class PatientMetric {
  final String id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final double change;
  final double changePercent;
  final PriorityLevel priority;
  final bool isPositive;
  final String trend;
  final Map<String, dynamic> metadata;

  const PatientMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.change,
    required this.changePercent,
    required this.priority,
    required this.isPositive,
    required this.trend,
    required this.metadata,
  });

  factory PatientMetric.fromJson(Map<String, dynamic> json) =>
      _$PatientMetricFromJson(json);

  Map<String, dynamic> toJson() => _$PatientMetricToJson(this);
}

/// Operational Analytics - Operasyonel analitikler
@JsonSerializable()
class OperationalAnalytics {
  final String id;
  final DateTime date;
  final int totalSessions;
  final int completedSessions;
  final int cancelledSessions;
  final double averageSessionDuration;
  final double resourceUtilization;
  final double efficiencyScore;
  final Map<String, int> sessionsByType;
  final Map<String, int> sessionsByTherapist;
  final Map<String, double> utilizationByResource;
  final List<OperationalMetric> keyMetrics;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OperationalAnalytics({
    required this.id,
    required this.date,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.averageSessionDuration,
    required this.resourceUtilization,
    required this.efficiencyScore,
    required this.sessionsByType,
    required this.sessionsByTherapist,
    required this.utilizationByResource,
    required this.keyMetrics,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OperationalAnalytics.fromJson(Map<String, dynamic> json) =>
      _$OperationalAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$OperationalAnalyticsToJson(this);
}

/// Operational Metric - Operasyonel metrik
@JsonSerializable()
class OperationalMetric {
  final String id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final double change;
  final double changePercent;
  final PriorityLevel priority;
  final bool isPositive;
  final String trend;
  final Map<String, dynamic> metadata;

  const OperationalMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.change,
    required this.changePercent,
    required this.priority,
    required this.isPositive,
    required this.trend,
    required this.metadata,
  });

  factory OperationalMetric.fromJson(Map<String, dynamic> json) =>
      _$OperationalMetricFromJson(json);

  Map<String, dynamic> toJson() => _$OperationalMetricToJson(this);
}

/// Quality Analytics - Kalite analitikleri
@JsonSerializable()
class QualityAnalytics {
  final String id;
  final DateTime date;
  final double overallQualityScore;
  final double treatmentEffectiveness;
  final double patientOutcomes;
  final double safetyScore;
  final double complianceScore;
  final Map<String, double> qualityByService;
  final Map<String, double> qualityByTherapist;
  final Map<String, double> qualityByLocation;
  final List<QualityMetric> keyMetrics;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QualityAnalytics({
    required this.id,
    required this.date,
    required this.overallQualityScore,
    required this.treatmentEffectiveness,
    required this.patientOutcomes,
    required this.safetyScore,
    required this.complianceScore,
    required this.qualityByService,
    required this.qualityByTherapist,
    required this.qualityByLocation,
    required this.keyMetrics,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QualityAnalytics.fromJson(Map<String, dynamic> json) =>
      _$QualityAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$QualityAnalyticsToJson(this);
}

/// Quality Metric - Kalite metrik
@JsonSerializable()
class QualityMetric {
  final String id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final double change;
  final double changePercent;
  final PriorityLevel priority;
  final bool isPositive;
  final String trend;
  final Map<String, dynamic> metadata;

  const QualityMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.change,
    required this.changePercent,
    required this.priority,
    required this.isPositive,
    required this.trend,
    required this.metadata,
  });

  factory QualityMetric.fromJson(Map<String, dynamic> json) =>
      _$QualityMetricFromJson(json);

  Map<String, dynamic> toJson() => _$QualityMetricToJson(this);
}

/// Staff Analytics - Personel analitikleri
@JsonSerializable()
class StaffAnalytics {
  final String id;
  final DateTime date;
  final int totalStaff;
  final int activeStaff;
  final int newStaff;
  final int departedStaff;
  final double averagePerformanceScore;
  final double trainingCompletionRate;
  final double satisfactionScore;
  final Map<String, int> staffByRole;
  final Map<String, int> staffByDepartment;
  final Map<String, double> performanceByRole;
  final List<StaffMetric> keyMetrics;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StaffAnalytics({
    required this.id,
    required this.date,
    required this.totalStaff,
    required this.activeStaff,
    required this.newStaff,
    required this.departedStaff,
    required this.averagePerformanceScore,
    required this.trainingCompletionRate,
    required this.satisfactionScore,
    required this.staffByRole,
    required this.staffByDepartment,
    required this.performanceByRole,
    required this.keyMetrics,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StaffAnalytics.fromJson(Map<String, dynamic> json) =>
      _$StaffAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$StaffAnalyticsToJson(this);
}

/// Staff Metric - Personel metrik
@JsonSerializable()
class StaffMetric {
  final String id;
  final String name;
  final String description;
  final double value;
  final String unit;
  final double change;
  final double changePercent;
  final PriorityLevel priority;
  final bool isPositive;
  final String trend;
  final Map<String, dynamic> metadata;

  const StaffMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.unit,
    required this.change,
    required this.changePercent,
    required this.priority,
    required this.isPositive,
    required this.trend,
    required this.metadata,
  });

  factory StaffMetric.fromJson(Map<String, dynamic> json) =>
      _$StaffMetricFromJson(json);

  Map<String, dynamic> toJson() => _$StaffMetricToJson(this);
}

/// Predictive Analytics - Tahmin analitikleri
@JsonSerializable()
class PredictiveAnalytics {
  final String id;
  final String name;
  final String description;
  final String predictionType;
  final DateTime predictionDate;
  final double confidence;
  final Map<String, dynamic> predictedValues;
  final Map<String, dynamic> factors;
  final List<String> recommendations;
  final PriorityLevel priority;
  final bool isActionable;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PredictiveAnalytics({
    required this.id,
    required this.name,
    required this.description,
    required this.predictionType,
    required this.predictionDate,
    required this.confidence,
    required this.predictedValues,
    required this.factors,
    required this.recommendations,
    required this.priority,
    required this.isActionable,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PredictiveAnalytics.fromJson(Map<String, dynamic> json) =>
      _$PredictiveAnalyticsFromJson(json);

  Map<String, dynamic> toJson() => _$PredictiveAnalyticsToJson(this);
}

/// Analytics Report - Analitik raporu
@JsonSerializable()
class AnalyticsReport {
  final String id;
  final String name;
  final String description;
  final DashboardType dashboardType;
  final TimePeriod timePeriod;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnalyticsReport({
    required this.id,
    required this.name,
    required this.description,
    required this.dashboardType,
    required this.timePeriod,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.insights,
    required this.recommendations,
    required this.metadata,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) =>
      _$AnalyticsReportFromJson(json);

  Map<String, dynamic> toJson() => _$AnalyticsReportToJson(this);
}

/// Quick Action - Hızlı işlem
@JsonSerializable()
class QuickAction {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String action;
  final Map<String, dynamic> parameters;
  final bool isEnabled;
  final PriorityLevel priority;
  final Map<String, dynamic> metadata;

  const QuickAction({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.action,
    required this.parameters,
    required this.isEnabled,
    required this.priority,
    required this.metadata,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) =>
      _$QuickActionFromJson(json);

  Map<String, dynamic> toJson() => _$QuickActionToJson(this);
}

/// Smart Filter - Akıllı filtre
@JsonSerializable()
class SmartFilter {
  final String id;
  final String name;
  final String description;
  final String field;
  final String operator;
  final dynamic value;
  final bool isActive;
  final PriorityLevel priority;
  final Map<String, dynamic> metadata;

  const SmartFilter({
    required this.id,
    required this.name,
    required this.description,
    required this.field,
    required this.operator,
    required this.value,
    required this.isActive,
    required this.priority,
    required this.metadata,
  });

  factory SmartFilter.fromJson(Map<String, dynamic> json) =>
      _$SmartFilterFromJson(json);

  Map<String, dynamic> toJson() => _$SmartFilterToJson(this);
}
