// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laboratory_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaboratoryTest _$LaboratoryTestFromJson(Map<String, dynamic> json) =>
    LaboratoryTest(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      specimenType: json['specimenType'] as String,
      preparationInstructions:
          (json['preparationInstructions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      turnaroundTime: json['turnaroundTime'] as String,
      normalRanges: (json['normalRanges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      criticalValues: (json['criticalValues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      units: (json['units'] as List<dynamic>).map((e) => e as String).toList(),
      methodologies: (json['methodologies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      relatedTests: (json['relatedTests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      clinicalIndications: (json['clinicalIndications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interferingFactors: (json['interferingFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      requiresFasting: json['requiresFasting'] as bool,
      requiresSpecialHandling: json['requiresSpecialHandling'] as bool,
      cost: json['cost'] as String,
      insuranceCode: json['insuranceCode'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      isActive: json['isActive'] as bool,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$LaboratoryTestToJson(LaboratoryTest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'category': instance.category,
      'description': instance.description,
      'specimenType': instance.specimenType,
      'preparationInstructions': instance.preparationInstructions,
      'turnaroundTime': instance.turnaroundTime,
      'normalRanges': instance.normalRanges,
      'criticalValues': instance.criticalValues,
      'units': instance.units,
      'methodologies': instance.methodologies,
      'relatedTests': instance.relatedTests,
      'clinicalIndications': instance.clinicalIndications,
      'contraindications': instance.contraindications,
      'interferingFactors': instance.interferingFactors,
      'medications': instance.medications,
      'requiresFasting': instance.requiresFasting,
      'requiresSpecialHandling': instance.requiresSpecialHandling,
      'cost': instance.cost,
      'insuranceCode': instance.insuranceCode,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

LaboratoryResult _$LaboratoryResultFromJson(Map<String, dynamic> json) =>
    LaboratoryResult(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      testCode: json['testCode'] as String,
      collectionDate: DateTime.parse(json['collectionDate'] as String),
      receivedDate: json['receivedDate'] == null
          ? null
          : DateTime.parse(json['receivedDate'] as String),
      resultDate: DateTime.parse(json['resultDate'] as String),
      resultValue: json['resultValue'] as String,
      unit: json['unit'] as String,
      referenceRange: json['referenceRange'] as String,
      flag: $enumDecode(_$ResultFlagEnumMap, json['flag']),
      interpretation: json['interpretation'] as String,
      status: json['status'] as String,
      performedBy: json['performedBy'] as String,
      verifiedBy: json['verifiedBy'] as String,
      notes: json['notes'] as String,
      criticalValues: (json['criticalValues'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LaboratoryResultToJson(LaboratoryResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'testId': instance.testId,
      'testName': instance.testName,
      'testCode': instance.testCode,
      'collectionDate': instance.collectionDate.toIso8601String(),
      'receivedDate': instance.receivedDate?.toIso8601String(),
      'resultDate': instance.resultDate.toIso8601String(),
      'resultValue': instance.resultValue,
      'unit': instance.unit,
      'referenceRange': instance.referenceRange,
      'flag': _$ResultFlagEnumMap[instance.flag]!,
      'interpretation': instance.interpretation,
      'status': instance.status,
      'performedBy': instance.performedBy,
      'verifiedBy': instance.verifiedBy,
      'notes': instance.notes,
      'criticalValues': instance.criticalValues,
      'alerts': instance.alerts,
      'metadata': instance.metadata,
    };

const _$ResultFlagEnumMap = {
  ResultFlag.normal: 'normal',
  ResultFlag.high: 'high',
  ResultFlag.low: 'low',
  ResultFlag.criticalHigh: 'criticalHigh',
  ResultFlag.criticalLow: 'criticalLow',
  ResultFlag.abnormal: 'abnormal',
  ResultFlag.indeterminate: 'indeterminate',
};

LaboratoryPanel _$LaboratoryPanelFromJson(
  Map<String, dynamic> json,
) => LaboratoryPanel(
  id: json['id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  description: json['description'] as String,
  testIds: (json['testIds'] as List<dynamic>).map((e) => e as String).toList(),
  tests: (json['tests'] as List<dynamic>)
      .map((e) => LaboratoryTest.fromJson(e as Map<String, dynamic>))
      .toList(),
  category: json['category'] as String,
  specimenType: json['specimenType'] as String,
  preparationInstructions: (json['preparationInstructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  turnaroundTime: json['turnaroundTime'] as String,
  cost: json['cost'] as String,
  insuranceCode: json['insuranceCode'] as String,
  clinicalIndications: (json['clinicalIndications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$LaboratoryPanelToJson(LaboratoryPanel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'testIds': instance.testIds,
      'tests': instance.tests,
      'category': instance.category,
      'specimenType': instance.specimenType,
      'preparationInstructions': instance.preparationInstructions,
      'turnaroundTime': instance.turnaroundTime,
      'cost': instance.cost,
      'insuranceCode': instance.insuranceCode,
      'clinicalIndications': instance.clinicalIndications,
      'contraindications': instance.contraindications,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

LaboratoryOrder _$LaboratoryOrderFromJson(Map<String, dynamic> json) =>
    LaboratoryOrder(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      orderDate: DateTime.parse(json['orderDate'] as String),
      scheduledDate: json['scheduledDate'] == null
          ? null
          : DateTime.parse(json['scheduledDate'] as String),
      collectionDate: json['collectionDate'] == null
          ? null
          : DateTime.parse(json['collectionDate'] as String),
      testIds: (json['testIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tests: (json['tests'] as List<dynamic>)
          .map((e) => LaboratoryTest.fromJson(e as Map<String, dynamic>))
          .toList(),
      priority: json['priority'] as String,
      status: json['status'] as String,
      clinicalIndication: json['clinicalIndication'] as String,
      diagnosis: json['diagnosis'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allergies: (json['allergies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specialInstructions: (json['specialInstructions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      collectionLocation: json['collectionLocation'] as String,
      collectionInstructions: json['collectionInstructions'] as String,
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LaboratoryOrderToJson(LaboratoryOrder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'orderDate': instance.orderDate.toIso8601String(),
      'scheduledDate': instance.scheduledDate?.toIso8601String(),
      'collectionDate': instance.collectionDate?.toIso8601String(),
      'testIds': instance.testIds,
      'tests': instance.tests,
      'priority': instance.priority,
      'status': instance.status,
      'clinicalIndication': instance.clinicalIndication,
      'diagnosis': instance.diagnosis,
      'medications': instance.medications,
      'allergies': instance.allergies,
      'specialInstructions': instance.specialInstructions,
      'collectionLocation': instance.collectionLocation,
      'collectionInstructions': instance.collectionInstructions,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

MedicationMonitoring _$MedicationMonitoringFromJson(
  Map<String, dynamic> json,
) => MedicationMonitoring(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  requiredTests: (json['requiredTests'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  tests: (json['tests'] as List<dynamic>)
      .map((e) => LaboratoryTest.fromJson(e as Map<String, dynamic>))
      .toList(),
  monitoringFrequency: json['monitoringFrequency'] as String,
  baselineRequired: json['baselineRequired'] as String,
  criticalValues: (json['criticalValues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  actionRequired: (json['actionRequired'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringParameters: (json['monitoringParameters'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  duration: json['duration'] as String,
  notes: json['notes'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$MedicationMonitoringToJson(
  MedicationMonitoring instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'requiredTests': instance.requiredTests,
  'tests': instance.tests,
  'monitoringFrequency': instance.monitoringFrequency,
  'baselineRequired': instance.baselineRequired,
  'criticalValues': instance.criticalValues,
  'actionRequired': instance.actionRequired,
  'monitoringParameters': instance.monitoringParameters,
  'duration': instance.duration,
  'notes': instance.notes,
  'metadata': instance.metadata,
};

LaboratoryAlert _$LaboratoryAlertFromJson(Map<String, dynamic> json) =>
    LaboratoryAlert(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      alertType: json['alertType'] as String,
      severity: $enumDecode(_$AlertSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      recommendation: json['recommendation'] as String,
      alertDate: DateTime.parse(json['alertDate'] as String),
      isAcknowledged: json['isAcknowledged'] as bool,
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      acknowledgedBy: json['acknowledgedBy'] as String,
      action: json['action'] as String,
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LaboratoryAlertToJson(LaboratoryAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'testId': instance.testId,
      'testName': instance.testName,
      'alertType': instance.alertType,
      'severity': _$AlertSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'recommendation': instance.recommendation,
      'alertDate': instance.alertDate.toIso8601String(),
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'acknowledgedBy': instance.acknowledgedBy,
      'action': instance.action,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$AlertSeverityEnumMap = {
  AlertSeverity.low: 'low',
  AlertSeverity.medium: 'medium',
  AlertSeverity.high: 'high',
  AlertSeverity.critical: 'critical',
};

LaboratoryTrend _$LaboratoryTrendFromJson(Map<String, dynamic> json) =>
    LaboratoryTrend(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      testId: json['testId'] as String,
      testName: json['testName'] as String,
      results: (json['results'] as List<dynamic>)
          .map((e) => LaboratoryResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      trend: json['trend'] as String,
      interpretation: json['interpretation'] as String,
      significantChanges: (json['significantChanges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LaboratoryTrendToJson(LaboratoryTrend instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'testId': instance.testId,
      'testName': instance.testName,
      'results': instance.results,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'trend': instance.trend,
      'interpretation': instance.interpretation,
      'significantChanges': instance.significantChanges,
      'recommendations': instance.recommendations,
      'metadata': instance.metadata,
    };

LaboratoryReport _$LaboratoryReportFromJson(Map<String, dynamic> json) =>
    LaboratoryReport(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      results: (json['results'] as List<dynamic>)
          .map((e) => LaboratoryResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => LaboratoryAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      trends: (json['trends'] as List<dynamic>)
          .map((e) => LaboratoryTrend.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String,
      interpretation: json['interpretation'] as String,
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      followUpTests: (json['followUpTests'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$LaboratoryReportToJson(LaboratoryReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'reportDate': instance.reportDate.toIso8601String(),
      'results': instance.results,
      'alerts': instance.alerts,
      'trends': instance.trends,
      'summary': instance.summary,
      'interpretation': instance.interpretation,
      'recommendations': instance.recommendations,
      'followUpTests': instance.followUpTests,
      'status': instance.status,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };
