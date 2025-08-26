// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_analytics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalyticsDashboard _$AnalyticsDashboardFromJson(Map<String, dynamic> json) =>
    AnalyticsDashboard(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$DashboardTypeEnumMap, json['type']),
      widgets: (json['widgets'] as List<dynamic>)
          .map((e) => DashboardWidget.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>,
      isDefault: json['isDefault'] as bool,
      isPublic: json['isPublic'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AnalyticsDashboardToJson(AnalyticsDashboard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$DashboardTypeEnumMap[instance.type]!,
      'widgets': instance.widgets,
      'settings': instance.settings,
      'isDefault': instance.isDefault,
      'isPublic': instance.isPublic,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$DashboardTypeEnumMap = {
  DashboardType.overview: 'overview',
  DashboardType.financial: 'financial',
  DashboardType.patients: 'patients',
  DashboardType.operations: 'operations',
  DashboardType.quality: 'quality',
  DashboardType.staff: 'staff',
  DashboardType.custom: 'custom',
};

DashboardWidget _$DashboardWidgetFromJson(Map<String, dynamic> json) =>
    DashboardWidget(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      visualizationType: $enumDecode(
        _$VisualizationTypeEnumMap,
        json['visualizationType'],
      ),
      data: json['data'] as Map<String, dynamic>,
      configuration: json['configuration'] as Map<String, dynamic>,
      positionX: (json['positionX'] as num).toInt(),
      positionY: (json['positionY'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      isVisible: json['isVisible'] as bool,
      isRefreshable: json['isRefreshable'] as bool,
      refreshInterval: (json['refreshInterval'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DashboardWidgetToJson(
  DashboardWidget instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'visualizationType': _$VisualizationTypeEnumMap[instance.visualizationType]!,
  'data': instance.data,
  'configuration': instance.configuration,
  'positionX': instance.positionX,
  'positionY': instance.positionY,
  'width': instance.width,
  'height': instance.height,
  'isVisible': instance.isVisible,
  'isRefreshable': instance.isRefreshable,
  'refreshInterval': instance.refreshInterval,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$VisualizationTypeEnumMap = {
  VisualizationType.line: 'line',
  VisualizationType.bar: 'bar',
  VisualizationType.pie: 'pie',
  VisualizationType.area: 'area',
  VisualizationType.table: 'table',
  VisualizationType.gauge: 'gauge',
  VisualizationType.trend: 'trend',
};

FinancialAnalytics _$FinancialAnalyticsFromJson(Map<String, dynamic> json) =>
    FinancialAnalytics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      netProfit: (json['netProfit'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      revenueGrowth: (json['revenueGrowth'] as num).toDouble(),
      expenseGrowth: (json['expenseGrowth'] as num).toDouble(),
      revenueByService: (json['revenueByService'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      expensesByCategory: (json['expensesByCategory'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      profitByService: (json['profitByService'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      keyMetrics: (json['keyMetrics'] as List<dynamic>)
          .map((e) => FinancialMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FinancialAnalyticsToJson(FinancialAnalytics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'totalRevenue': instance.totalRevenue,
      'totalExpenses': instance.totalExpenses,
      'netProfit': instance.netProfit,
      'profitMargin': instance.profitMargin,
      'revenueGrowth': instance.revenueGrowth,
      'expenseGrowth': instance.expenseGrowth,
      'revenueByService': instance.revenueByService,
      'expensesByCategory': instance.expensesByCategory,
      'profitByService': instance.profitByService,
      'keyMetrics': instance.keyMetrics,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

FinancialMetric _$FinancialMetricFromJson(Map<String, dynamic> json) =>
    FinancialMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
      isPositive: json['isPositive'] as bool,
      trend: json['trend'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$FinancialMetricToJson(FinancialMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'unit': instance.unit,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'isPositive': instance.isPositive,
      'trend': instance.trend,
      'metadata': instance.metadata,
    };

const _$PriorityLevelEnumMap = {
  PriorityLevel.low: 'low',
  PriorityLevel.medium: 'medium',
  PriorityLevel.high: 'high',
  PriorityLevel.critical: 'critical',
};

PatientAnalytics _$PatientAnalyticsFromJson(Map<String, dynamic> json) =>
    PatientAnalytics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalPatients: (json['totalPatients'] as num).toInt(),
      newPatients: (json['newPatients'] as num).toInt(),
      activePatients: (json['activePatients'] as num).toInt(),
      dischargedPatients: (json['dischargedPatients'] as num).toInt(),
      averageSessionDuration: (json['averageSessionDuration'] as num)
          .toDouble(),
      patientSatisfactionScore: (json['patientSatisfactionScore'] as num)
          .toDouble(),
      patientsByAge: Map<String, int>.from(json['patientsByAge'] as Map),
      patientsByGender: Map<String, int>.from(json['patientsByGender'] as Map),
      patientsByDiagnosis: Map<String, int>.from(
        json['patientsByDiagnosis'] as Map,
      ),
      patientsByTreatment: Map<String, int>.from(
        json['patientsByTreatment'] as Map,
      ),
      keyMetrics: (json['keyMetrics'] as List<dynamic>)
          .map((e) => PatientMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PatientAnalyticsToJson(PatientAnalytics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'totalPatients': instance.totalPatients,
      'newPatients': instance.newPatients,
      'activePatients': instance.activePatients,
      'dischargedPatients': instance.dischargedPatients,
      'averageSessionDuration': instance.averageSessionDuration,
      'patientSatisfactionScore': instance.patientSatisfactionScore,
      'patientsByAge': instance.patientsByAge,
      'patientsByGender': instance.patientsByGender,
      'patientsByDiagnosis': instance.patientsByDiagnosis,
      'patientsByTreatment': instance.patientsByTreatment,
      'keyMetrics': instance.keyMetrics,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PatientMetric _$PatientMetricFromJson(Map<String, dynamic> json) =>
    PatientMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
      isPositive: json['isPositive'] as bool,
      trend: json['trend'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PatientMetricToJson(PatientMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'unit': instance.unit,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'isPositive': instance.isPositive,
      'trend': instance.trend,
      'metadata': instance.metadata,
    };

OperationalAnalytics _$OperationalAnalyticsFromJson(
  Map<String, dynamic> json,
) => OperationalAnalytics(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  totalSessions: (json['totalSessions'] as num).toInt(),
  completedSessions: (json['completedSessions'] as num).toInt(),
  cancelledSessions: (json['cancelledSessions'] as num).toInt(),
  averageSessionDuration: (json['averageSessionDuration'] as num).toDouble(),
  resourceUtilization: (json['resourceUtilization'] as num).toDouble(),
  efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
  sessionsByType: Map<String, int>.from(json['sessionsByType'] as Map),
  sessionsByTherapist: Map<String, int>.from(
    json['sessionsByTherapist'] as Map,
  ),
  utilizationByResource: (json['utilizationByResource'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  keyMetrics: (json['keyMetrics'] as List<dynamic>)
      .map((e) => OperationalMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OperationalAnalyticsToJson(
  OperationalAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'totalSessions': instance.totalSessions,
  'completedSessions': instance.completedSessions,
  'cancelledSessions': instance.cancelledSessions,
  'averageSessionDuration': instance.averageSessionDuration,
  'resourceUtilization': instance.resourceUtilization,
  'efficiencyScore': instance.efficiencyScore,
  'sessionsByType': instance.sessionsByType,
  'sessionsByTherapist': instance.sessionsByTherapist,
  'utilizationByResource': instance.utilizationByResource,
  'keyMetrics': instance.keyMetrics,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

OperationalMetric _$OperationalMetricFromJson(Map<String, dynamic> json) =>
    OperationalMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
      isPositive: json['isPositive'] as bool,
      trend: json['trend'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$OperationalMetricToJson(OperationalMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'unit': instance.unit,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'isPositive': instance.isPositive,
      'trend': instance.trend,
      'metadata': instance.metadata,
    };

QualityAnalytics _$QualityAnalyticsFromJson(Map<String, dynamic> json) =>
    QualityAnalytics(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      overallQualityScore: (json['overallQualityScore'] as num).toDouble(),
      treatmentEffectiveness: (json['treatmentEffectiveness'] as num)
          .toDouble(),
      patientOutcomes: (json['patientOutcomes'] as num).toDouble(),
      safetyScore: (json['safetyScore'] as num).toDouble(),
      complianceScore: (json['complianceScore'] as num).toDouble(),
      qualityByService: (json['qualityByService'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      qualityByTherapist: (json['qualityByTherapist'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      qualityByLocation: (json['qualityByLocation'] as Map<String, dynamic>)
          .map((k, e) => MapEntry(k, (e as num).toDouble())),
      keyMetrics: (json['keyMetrics'] as List<dynamic>)
          .map((e) => QualityMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QualityAnalyticsToJson(QualityAnalytics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'overallQualityScore': instance.overallQualityScore,
      'treatmentEffectiveness': instance.treatmentEffectiveness,
      'patientOutcomes': instance.patientOutcomes,
      'safetyScore': instance.safetyScore,
      'complianceScore': instance.complianceScore,
      'qualityByService': instance.qualityByService,
      'qualityByTherapist': instance.qualityByTherapist,
      'qualityByLocation': instance.qualityByLocation,
      'keyMetrics': instance.keyMetrics,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

QualityMetric _$QualityMetricFromJson(Map<String, dynamic> json) =>
    QualityMetric(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
      isPositive: json['isPositive'] as bool,
      trend: json['trend'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$QualityMetricToJson(QualityMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'unit': instance.unit,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'isPositive': instance.isPositive,
      'trend': instance.trend,
      'metadata': instance.metadata,
    };

StaffAnalytics _$StaffAnalyticsFromJson(
  Map<String, dynamic> json,
) => StaffAnalytics(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  totalStaff: (json['totalStaff'] as num).toInt(),
  activeStaff: (json['activeStaff'] as num).toInt(),
  newStaff: (json['newStaff'] as num).toInt(),
  departedStaff: (json['departedStaff'] as num).toInt(),
  averagePerformanceScore: (json['averagePerformanceScore'] as num).toDouble(),
  trainingCompletionRate: (json['trainingCompletionRate'] as num).toDouble(),
  satisfactionScore: (json['satisfactionScore'] as num).toDouble(),
  staffByRole: Map<String, int>.from(json['staffByRole'] as Map),
  staffByDepartment: Map<String, int>.from(json['staffByDepartment'] as Map),
  performanceByRole: (json['performanceByRole'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  keyMetrics: (json['keyMetrics'] as List<dynamic>)
      .map((e) => StaffMetric.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$StaffAnalyticsToJson(StaffAnalytics instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'totalStaff': instance.totalStaff,
      'activeStaff': instance.activeStaff,
      'newStaff': instance.newStaff,
      'departedStaff': instance.departedStaff,
      'averagePerformanceScore': instance.averagePerformanceScore,
      'trainingCompletionRate': instance.trainingCompletionRate,
      'satisfactionScore': instance.satisfactionScore,
      'staffByRole': instance.staffByRole,
      'staffByDepartment': instance.staffByDepartment,
      'performanceByRole': instance.performanceByRole,
      'keyMetrics': instance.keyMetrics,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

StaffMetric _$StaffMetricFromJson(Map<String, dynamic> json) => StaffMetric(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  value: (json['value'] as num).toDouble(),
  unit: json['unit'] as String,
  change: (json['change'] as num).toDouble(),
  changePercent: (json['changePercent'] as num).toDouble(),
  priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
  isPositive: json['isPositive'] as bool,
  trend: json['trend'] as String,
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$StaffMetricToJson(StaffMetric instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'unit': instance.unit,
      'change': instance.change,
      'changePercent': instance.changePercent,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'isPositive': instance.isPositive,
      'trend': instance.trend,
      'metadata': instance.metadata,
    };

PredictiveAnalytics _$PredictiveAnalyticsFromJson(Map<String, dynamic> json) =>
    PredictiveAnalytics(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      predictionType: json['predictionType'] as String,
      predictionDate: DateTime.parse(json['predictionDate'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      predictedValues: json['predictedValues'] as Map<String, dynamic>,
      factors: json['factors'] as Map<String, dynamic>,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
      isActionable: json['isActionable'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PredictiveAnalyticsToJson(
  PredictiveAnalytics instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'predictionType': instance.predictionType,
  'predictionDate': instance.predictionDate.toIso8601String(),
  'confidence': instance.confidence,
  'predictedValues': instance.predictedValues,
  'factors': instance.factors,
  'recommendations': instance.recommendations,
  'priority': _$PriorityLevelEnumMap[instance.priority]!,
  'isActionable': instance.isActionable,
  'metadata': instance.metadata,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

AnalyticsReport _$AnalyticsReportFromJson(Map<String, dynamic> json) =>
    AnalyticsReport(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dashboardType: $enumDecode(_$DashboardTypeEnumMap, json['dashboardType']),
      timePeriod: $enumDecode(_$TimePeriodEnumMap, json['timePeriod']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      data: json['data'] as Map<String, dynamic>,
      insights: (json['insights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$AnalyticsReportToJson(AnalyticsReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'dashboardType': _$DashboardTypeEnumMap[instance.dashboardType]!,
      'timePeriod': _$TimePeriodEnumMap[instance.timePeriod]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'data': instance.data,
      'insights': instance.insights,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TimePeriodEnumMap = {
  TimePeriod.today: 'today',
  TimePeriod.week: 'week',
  TimePeriod.month: 'month',
  TimePeriod.quarter: 'quarter',
  TimePeriod.year: 'year',
  TimePeriod.custom: 'custom',
};

QuickAction _$QuickActionFromJson(Map<String, dynamic> json) => QuickAction(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  icon: json['icon'] as String,
  action: json['action'] as String,
  parameters: json['parameters'] as Map<String, dynamic>,
  isEnabled: json['isEnabled'] as bool,
  priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$QuickActionToJson(QuickAction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'action': instance.action,
      'parameters': instance.parameters,
      'isEnabled': instance.isEnabled,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'metadata': instance.metadata,
    };

SmartFilter _$SmartFilterFromJson(Map<String, dynamic> json) => SmartFilter(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  field: json['field'] as String,
  operator: json['operator'] as String,
  value: json['value'],
  isActive: json['isActive'] as bool,
  priority: $enumDecode(_$PriorityLevelEnumMap, json['priority']),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SmartFilterToJson(SmartFilter instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'field': instance.field,
      'operator': instance.operator,
      'value': instance.value,
      'isActive': instance.isActive,
      'priority': _$PriorityLevelEnumMap[instance.priority]!,
      'metadata': instance.metadata,
    };
