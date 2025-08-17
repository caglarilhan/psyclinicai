import 'package:json_annotation/json_annotation.dart';

part 'gdpr_compliance_models.g.dart';

@JsonSerializable()
class GDPRCompliance {
  final String id;
  final String organizationId;
  final String country;
  final DateTime lastAssessmentDate;
  final DateTime nextAssessmentDate;
  final ComplianceStatus status;
  final List<DataProcessingActivity> processingActivities;
  final List<DataSubjectRights> dataSubjectRights;
  final List<DataBreach> dataBreaches;
  final DataProtectionOfficer dataProtectionOfficer;
  final List<ConsentRecord> consentRecords;
  final List<DataRetentionPolicy> retentionPolicies;

  const GDPRCompliance({
    required this.id,
    required this.organizationId,
    required this.country,
    required this.lastAssessmentDate,
    required this.nextAssessmentDate,
    required this.status,
    required this.processingActivities,
    required this.dataSubjectRights,
    required this.dataBreaches,
    required this.dataProtectionOfficer,
    required this.consentRecords,
    required this.retentionPolicies,
  });

  factory GDPRCompliance.fromJson(Map<String, dynamic> json) =>
      _$GDPRComplianceFromJson(json);

  Map<String, dynamic> toJson() => _$GDPRComplianceToJson(this);

  bool get isCompliant => status == ComplianceStatus.compliant;
  bool get needsAssessment => DateTime.now().isAfter(nextAssessmentDate);
}

@JsonSerializable()
class DataProcessingActivity {
  final String id;
  final String name;
  final String purpose;
  final String legalBasis;
  final List<String> dataCategories;
  final List<String> recipients;
  final String retentionPeriod;
  final List<String> securityMeasures;
  final ProcessingRisk riskLevel;
  final DateTime lastReviewDate;

  const DataProcessingActivity({
    required this.id,
    required this.name,
    required this.purpose,
    required this.legalBasis,
    required this.dataCategories,
    required this.recipients,
    required this.retentionPeriod,
    required this.securityMeasures,
    required this.riskLevel,
    required this.lastReviewDate,
  });

  factory DataProcessingActivity.fromJson(Map<String, dynamic> json) =>
      _$DataProcessingActivityFromJson(json);

  Map<String, dynamic> toJson() => _$DataProcessingActivityToJson(this);
}

@JsonSerializable()
class DataSubjectRights {
  final String id;
  final String patientId;
  final List<RightType> rights;
  final DateTime requestDate;
  final String requestDescription;
  final RequestStatus status;
  final DateTime responseDate;
  final String responseDetails;
  final String notes;

  const DataSubjectRights({
    required this.id,
    required this.patientId,
    required this.rights,
    required this.requestDate,
    required this.requestDescription,
    required this.status,
    required this.responseDate,
    required this.responseDetails,
    required this.notes,
  });

  factory DataSubjectRights.fromJson(Map<String, dynamic> json) =>
      _$DataSubjectRightsFromJson(json);

  Map<String, dynamic> toJson() => _$DataSubjectRightsToJson(this);
}

@JsonSerializable()
class DataBreach {
  final String id;
  final DateTime discoveredDate;
  final DateTime reportedDate;
  final BreachType type;
  final BreachSeverity severity;
  final String description;
  final int affectedIndividuals;
  final List<String> affectedDataTypes;
  final String containmentActions;
  final String notificationDetails;
  final BreachStatus status;
  final DateTime resolvedDate;

  const DataBreach({
    required this.id,
    required this.discoveredDate,
    required this.reportedDate,
    required this.type,
    required this.severity,
    required this.description,
    required this.affectedIndividuals,
    required this.affectedDataTypes,
    required this.containmentActions,
    required this.notificationDetails,
    required this.status,
    required this.resolvedDate,
  });

  factory DataBreach.fromJson(Map<String, dynamic> json) =>
      _$DataBreachFromJson(json);

  Map<String, dynamic> toJson() => _$DataBreachToJson(this);
}

@JsonSerializable()
class DataProtectionOfficer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String title;
  final DateTime appointmentDate;
  final List<String> certifications;
  final String responsibilities;
  final bool isExternal;

  const DataProtectionOfficer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.appointmentDate,
    required this.certifications,
    required this.responsibilities,
    required this.isExternal,
  });

  factory DataProtectionOfficer.fromJson(Map<String, dynamic> json) =>
      _$DataProtectionOfficerFromJson(json);

  Map<String, dynamic> toJson() => _$DataProtectionOfficerToJson(this);
}

@JsonSerializable()
class ConsentRecord {
  final String id;
  final String patientId;
  final String consentType;
  final DateTime consentDate;
  final DateTime expiryDate;
  final bool isActive;
  final String consentText;
  final List<String> purposes;
  final ConsentMethod method;
  final String recordedBy;
  final DateTime withdrawalDate;
  final String withdrawalReason;

  const ConsentRecord({
    required this.id,
    required this.patientId,
    required this.consentType,
    required this.consentDate,
    required this.expiryDate,
    required this.isActive,
    required this.consentText,
    required this.purposes,
    required this.method,
    required this.recordedBy,
    required this.withdrawalDate,
    required this.withdrawalReason,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) =>
      _$ConsentRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentRecordToJson(this);
}

@JsonSerializable()
class DataRetentionPolicy {
  final String id;
  final String dataType;
  final String retentionPeriod;
  final String legalBasis;
  final String disposalMethod;
  final DateTime lastReviewDate;
  final String reviewedBy;
  final List<String> exceptions;
  final String notes;

  const DataRetentionPolicy({
    required this.id,
    required this.dataType,
    required this.retentionPeriod,
    required this.legalBasis,
    required this.disposalMethod,
    required this.lastReviewDate,
    required this.reviewedBy,
    required this.exceptions,
    required this.notes,
  });

  factory DataRetentionPolicy.fromJson(Map<String, dynamic> json) =>
      _$DataRetentionPolicyFromJson(json);

  Map<String, dynamic> toJson() => _$DataRetentionPolicyToJson(this);
}

enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
  pending,
}

enum ProcessingRisk {
  low,
  medium,
  high,
  critical,
}

enum RightType {
  access,
  rectification,
  erasure,
  restriction,
  portability,
  objection,
  automatedDecision,
  withdrawal,
}

enum RequestStatus {
  pending,
  processing,
  completed,
  rejected,
  onHold,
}

enum BreachType {
  unauthorizedAccess,
  dataLoss,
  systemFailure,
  humanError,
  maliciousAttack,
  other,
}

enum BreachSeverity {
  low,
  medium,
  high,
  critical,
}

enum BreachStatus {
  discovered,
  reported,
  investigating,
  contained,
  resolved,
  closed,
}

enum ConsentMethod {
  written,
  electronic,
  verbal,
  implied,
  optOut,
}
