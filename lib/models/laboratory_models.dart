import 'package:json_annotation/json_annotation.dart';

part 'laboratory_models.g.dart';

@JsonSerializable()
class LaboratoryTest {
  final String id;
  final String name;
  final String code;
  final String category;
  final String description;
  final String specimenType;
  final List<String> preparationInstructions;
  final String turnaroundTime;
  final List<String> normalRanges;
  final List<String> criticalValues;
  final List<String> units;
  final List<String> methodologies;
  final List<String> relatedTests;
  final List<String> clinicalIndications;
  final List<String> contraindications;
  final List<String> interferingFactors;
  final List<String> medications;
  final bool requiresFasting;
  final bool requiresSpecialHandling;
  final String cost;
  final String insuranceCode;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime lastUpdated;

  const LaboratoryTest({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.description,
    required this.specimenType,
    required this.preparationInstructions,
    required this.turnaroundTime,
    required this.normalRanges,
    required this.criticalValues,
    required this.units,
    required this.methodologies,
    required this.relatedTests,
    required this.clinicalIndications,
    required this.contraindications,
    required this.interferingFactors,
    required this.medications,
    required this.requiresFasting,
    required this.requiresSpecialHandling,
    required this.cost,
    required this.insuranceCode,
    this.metadata = const {},
    required this.isActive,
    required this.lastUpdated,
  });

  factory LaboratoryTest.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryTestFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryTestToJson(this);
}

@JsonSerializable()
class LaboratoryResult {
  final String id;
  final String patientId;
  final String testId;
  final String testName;
  final String testCode;
  final DateTime collectionDate;
  final DateTime? receivedDate;
  final DateTime resultDate;
  final String resultValue;
  final String unit;
  final String referenceRange;
  final ResultFlag flag;
  final String interpretation;
  final String status;
  final String performedBy;
  final String verifiedBy;
  final String notes;
  final List<String> criticalValues;
  final List<String> alerts;
  final Map<String, dynamic> metadata;

  const LaboratoryResult({
    required this.id,
    required this.patientId,
    required this.testId,
    required this.testName,
    required this.testCode,
    required this.collectionDate,
    this.receivedDate,
    required this.resultDate,
    required this.resultValue,
    required this.unit,
    required this.referenceRange,
    required this.flag,
    required this.interpretation,
    required this.status,
    required this.performedBy,
    required this.verifiedBy,
    required this.notes,
    required this.criticalValues,
    required this.alerts,
    this.metadata = const {},
  });

  factory LaboratoryResult.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryResultFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryResultToJson(this);
}

@JsonSerializable()
class LaboratoryPanel {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<String> testIds;
  final List<LaboratoryTest> tests;
  final String category;
  final String specimenType;
  final List<String> preparationInstructions;
  final String turnaroundTime;
  final String cost;
  final String insuranceCode;
  final List<String> clinicalIndications;
  final List<String> contraindications;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime lastUpdated;

  const LaboratoryPanel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.testIds,
    required this.tests,
    required this.category,
    required this.specimenType,
    required this.preparationInstructions,
    required this.turnaroundTime,
    required this.cost,
    required this.insuranceCode,
    required this.clinicalIndications,
    required this.contraindications,
    this.metadata = const {},
    required this.isActive,
    required this.lastUpdated,
  });

  factory LaboratoryPanel.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryPanelFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryPanelToJson(this);
}

@JsonSerializable()
class LaboratoryOrder {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime orderDate;
  final DateTime? scheduledDate;
  final DateTime? collectionDate;
  final List<String> testIds;
  final List<LaboratoryTest> tests;
  final String priority;
  final String status;
  final String clinicalIndication;
  final String diagnosis;
  final List<String> medications;
  final List<String> allergies;
  final List<String> specialInstructions;
  final String collectionLocation;
  final String collectionInstructions;
  final String notes;
  final Map<String, dynamic> metadata;

  const LaboratoryOrder({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.orderDate,
    this.scheduledDate,
    this.collectionDate,
    required this.testIds,
    required this.tests,
    required this.priority,
    required this.status,
    required this.clinicalIndication,
    required this.diagnosis,
    required this.medications,
    required this.allergies,
    required this.specialInstructions,
    required this.collectionLocation,
    required this.collectionInstructions,
    required this.notes,
    this.metadata = const {},
  });

  factory LaboratoryOrder.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryOrderFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryOrderToJson(this);
}

@JsonSerializable()
class MedicationMonitoring {
  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final List<String> requiredTests;
  final List<LaboratoryTest> tests;
  final String monitoringFrequency;
  final String baselineRequired;
  final List<String> criticalValues;
  final List<String> actionRequired;
  final List<String> monitoringParameters;
  final String duration;
  final String notes;
  final Map<String, dynamic> metadata;

  const MedicationMonitoring({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.requiredTests,
    required this.tests,
    required this.monitoringFrequency,
    required this.baselineRequired,
    required this.criticalValues,
    required this.actionRequired,
    required this.monitoringParameters,
    required this.duration,
    required this.notes,
    this.metadata = const {},
  });

  factory MedicationMonitoring.fromJson(Map<String, dynamic> json) =>
      _$MedicationMonitoringFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationMonitoringToJson(this);
}

@JsonSerializable()
class LaboratoryAlert {
  final String id;
  final String patientId;
  final String testId;
  final String testName;
  final String alertType;
  final AlertSeverity severity;
  final String description;
  final String recommendation;
  final DateTime alertDate;
  final bool isAcknowledged;
  final DateTime? acknowledgedAt;
  final String acknowledgedBy;
  final String action;
  final String notes;
  final Map<String, dynamic> metadata;

  const LaboratoryAlert({
    required this.id,
    required this.patientId,
    required this.testId,
    required this.testName,
    required this.alertType,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.alertDate,
    required this.isAcknowledged,
    this.acknowledgedAt,
    required this.acknowledgedBy,
    required this.action,
    required this.notes,
    this.metadata = const {},
  });

  factory LaboratoryAlert.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryAlertFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryAlertToJson(this);
}

@JsonSerializable()
class LaboratoryTrend {
  final String id;
  final String patientId;
  final String testId;
  final String testName;
  final List<LaboratoryResult> results;
  final DateTime startDate;
  final DateTime endDate;
  final String trend;
  final String interpretation;
  final List<String> significantChanges;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const LaboratoryTrend({
    required this.id,
    required this.patientId,
    required this.testId,
    required this.testName,
    required this.results,
    required this.startDate,
    required this.endDate,
    required this.trend,
    required this.interpretation,
    required this.significantChanges,
    required this.recommendations,
    this.metadata = const {},
  });

  factory LaboratoryTrend.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryTrendFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryTrendToJson(this);
}

@JsonSerializable()
class LaboratoryReport {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime reportDate;
  final List<LaboratoryResult> results;
  final List<LaboratoryAlert> alerts;
  final List<LaboratoryTrend> trends;
  final String summary;
  final String interpretation;
  final List<String> recommendations;
  final List<String> followUpTests;
  final String status;
  final String notes;
  final Map<String, dynamic> metadata;

  const LaboratoryReport({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.reportDate,
    required this.results,
    required this.alerts,
    required this.trends,
    required this.summary,
    required this.interpretation,
    required this.recommendations,
    required this.followUpTests,
    required this.status,
    required this.notes,
    this.metadata = const {},
  });

  factory LaboratoryReport.fromJson(Map<String, dynamic> json) =>
      _$LaboratoryReportFromJson(json);

  Map<String, dynamic> toJson() => _$LaboratoryReportToJson(this);
}

// Enums
enum ResultFlag {
  normal,
  high,
  low,
  criticalHigh,
  criticalLow,
  abnormal,
  indeterminate,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum TestCategory {
  hematology,
  chemistry,
  immunology,
  microbiology,
  molecular,
  toxicology,
  therapeuticDrugMonitoring,
  other,
}

enum TestStatus {
  ordered,
  collected,
  inProgress,
  completed,
  cancelled,
  error,
}

enum TestPriority {
  routine,
  urgent,
  stat,
  timed,
}
