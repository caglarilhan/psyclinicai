// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gdpr_compliance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GDPRCompliance _$GDPRComplianceFromJson(Map<String, dynamic> json) =>
    GDPRCompliance(
      id: json['id'] as String,
      organizationId: json['organizationId'] as String,
      country: json['country'] as String,
      lastAssessmentDate: DateTime.parse(json['lastAssessmentDate'] as String),
      nextAssessmentDate: DateTime.parse(json['nextAssessmentDate'] as String),
      status: $enumDecode(_$ComplianceStatusEnumMap, json['status']),
      processingActivities: (json['processingActivities'] as List<dynamic>)
          .map(
            (e) => DataProcessingActivity.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      dataSubjectRights: (json['dataSubjectRights'] as List<dynamic>)
          .map((e) => DataSubjectRights.fromJson(e as Map<String, dynamic>))
          .toList(),
      dataBreaches: (json['dataBreaches'] as List<dynamic>)
          .map((e) => DataBreach.fromJson(e as Map<String, dynamic>))
          .toList(),
      dataProtectionOfficer: DataProtectionOfficer.fromJson(
        json['dataProtectionOfficer'] as Map<String, dynamic>,
      ),
      consentRecords: (json['consentRecords'] as List<dynamic>)
          .map((e) => ConsentRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      retentionPolicies: (json['retentionPolicies'] as List<dynamic>)
          .map((e) => DataRetentionPolicy.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GDPRComplianceToJson(GDPRCompliance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organizationId': instance.organizationId,
      'country': instance.country,
      'lastAssessmentDate': instance.lastAssessmentDate.toIso8601String(),
      'nextAssessmentDate': instance.nextAssessmentDate.toIso8601String(),
      'status': _$ComplianceStatusEnumMap[instance.status]!,
      'processingActivities': instance.processingActivities,
      'dataSubjectRights': instance.dataSubjectRights,
      'dataBreaches': instance.dataBreaches,
      'dataProtectionOfficer': instance.dataProtectionOfficer,
      'consentRecords': instance.consentRecords,
      'retentionPolicies': instance.retentionPolicies,
    };

const _$ComplianceStatusEnumMap = {
  ComplianceStatus.compliant: 'compliant',
  ComplianceStatus.nonCompliant: 'nonCompliant',
  ComplianceStatus.partiallyCompliant: 'partiallyCompliant',
  ComplianceStatus.underReview: 'underReview',
  ComplianceStatus.pending: 'pending',
};

DataProcessingActivity _$DataProcessingActivityFromJson(
  Map<String, dynamic> json,
) => DataProcessingActivity(
  id: json['id'] as String,
  name: json['name'] as String,
  purpose: json['purpose'] as String,
  legalBasis: json['legalBasis'] as String,
  dataCategories: (json['dataCategories'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recipients: (json['recipients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  retentionPeriod: json['retentionPeriod'] as String,
  securityMeasures: (json['securityMeasures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskLevel: $enumDecode(_$ProcessingRiskEnumMap, json['riskLevel']),
  lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
);

Map<String, dynamic> _$DataProcessingActivityToJson(
  DataProcessingActivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'purpose': instance.purpose,
  'legalBasis': instance.legalBasis,
  'dataCategories': instance.dataCategories,
  'recipients': instance.recipients,
  'retentionPeriod': instance.retentionPeriod,
  'securityMeasures': instance.securityMeasures,
  'riskLevel': _$ProcessingRiskEnumMap[instance.riskLevel]!,
  'lastReviewDate': instance.lastReviewDate.toIso8601String(),
};

const _$ProcessingRiskEnumMap = {
  ProcessingRisk.low: 'low',
  ProcessingRisk.medium: 'medium',
  ProcessingRisk.high: 'high',
  ProcessingRisk.critical: 'critical',
};

DataSubjectRights _$DataSubjectRightsFromJson(Map<String, dynamic> json) =>
    DataSubjectRights(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      rights: (json['rights'] as List<dynamic>)
          .map((e) => $enumDecode(_$RightTypeEnumMap, e))
          .toList(),
      requestDate: DateTime.parse(json['requestDate'] as String),
      requestDescription: json['requestDescription'] as String,
      status: $enumDecode(_$RequestStatusEnumMap, json['status']),
      responseDate: DateTime.parse(json['responseDate'] as String),
      responseDetails: json['responseDetails'] as String,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$DataSubjectRightsToJson(DataSubjectRights instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'rights': instance.rights.map((e) => _$RightTypeEnumMap[e]!).toList(),
      'requestDate': instance.requestDate.toIso8601String(),
      'requestDescription': instance.requestDescription,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'responseDate': instance.responseDate.toIso8601String(),
      'responseDetails': instance.responseDetails,
      'notes': instance.notes,
    };

const _$RightTypeEnumMap = {
  RightType.access: 'access',
  RightType.rectification: 'rectification',
  RightType.erasure: 'erasure',
  RightType.restriction: 'restriction',
  RightType.portability: 'portability',
  RightType.objection: 'objection',
  RightType.automatedDecision: 'automatedDecision',
  RightType.withdrawal: 'withdrawal',
};

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.processing: 'processing',
  RequestStatus.completed: 'completed',
  RequestStatus.rejected: 'rejected',
  RequestStatus.onHold: 'onHold',
};

DataBreach _$DataBreachFromJson(Map<String, dynamic> json) => DataBreach(
  id: json['id'] as String,
  discoveredDate: DateTime.parse(json['discoveredDate'] as String),
  reportedDate: DateTime.parse(json['reportedDate'] as String),
  type: $enumDecode(_$BreachTypeEnumMap, json['type']),
  severity: $enumDecode(_$BreachSeverityEnumMap, json['severity']),
  description: json['description'] as String,
  affectedIndividuals: (json['affectedIndividuals'] as num).toInt(),
  affectedDataTypes: (json['affectedDataTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  containmentActions: json['containmentActions'] as String,
  notificationDetails: json['notificationDetails'] as String,
  status: $enumDecode(_$BreachStatusEnumMap, json['status']),
  resolvedDate: DateTime.parse(json['resolvedDate'] as String),
);

Map<String, dynamic> _$DataBreachToJson(DataBreach instance) =>
    <String, dynamic>{
      'id': instance.id,
      'discoveredDate': instance.discoveredDate.toIso8601String(),
      'reportedDate': instance.reportedDate.toIso8601String(),
      'type': _$BreachTypeEnumMap[instance.type]!,
      'severity': _$BreachSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'affectedIndividuals': instance.affectedIndividuals,
      'affectedDataTypes': instance.affectedDataTypes,
      'containmentActions': instance.containmentActions,
      'notificationDetails': instance.notificationDetails,
      'status': _$BreachStatusEnumMap[instance.status]!,
      'resolvedDate': instance.resolvedDate.toIso8601String(),
    };

const _$BreachTypeEnumMap = {
  BreachType.unauthorizedAccess: 'unauthorizedAccess',
  BreachType.dataLoss: 'dataLoss',
  BreachType.systemFailure: 'systemFailure',
  BreachType.humanError: 'humanError',
  BreachType.maliciousAttack: 'maliciousAttack',
  BreachType.other: 'other',
};

const _$BreachSeverityEnumMap = {
  BreachSeverity.low: 'low',
  BreachSeverity.medium: 'medium',
  BreachSeverity.high: 'high',
  BreachSeverity.critical: 'critical',
};

const _$BreachStatusEnumMap = {
  BreachStatus.discovered: 'discovered',
  BreachStatus.reported: 'reported',
  BreachStatus.investigating: 'investigating',
  BreachStatus.contained: 'contained',
  BreachStatus.resolved: 'resolved',
  BreachStatus.closed: 'closed',
};

DataProtectionOfficer _$DataProtectionOfficerFromJson(
  Map<String, dynamic> json,
) => DataProtectionOfficer(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  title: json['title'] as String,
  appointmentDate: DateTime.parse(json['appointmentDate'] as String),
  certifications: (json['certifications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responsibilities: json['responsibilities'] as String,
  isExternal: json['isExternal'] as bool,
);

Map<String, dynamic> _$DataProtectionOfficerToJson(
  DataProtectionOfficer instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'title': instance.title,
  'appointmentDate': instance.appointmentDate.toIso8601String(),
  'certifications': instance.certifications,
  'responsibilities': instance.responsibilities,
  'isExternal': instance.isExternal,
};

ConsentRecord _$ConsentRecordFromJson(Map<String, dynamic> json) =>
    ConsentRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      consentType: json['consentType'] as String,
      consentDate: DateTime.parse(json['consentDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      isActive: json['isActive'] as bool,
      consentText: json['consentText'] as String,
      purposes: (json['purposes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      method: $enumDecode(_$ConsentMethodEnumMap, json['method']),
      recordedBy: json['recordedBy'] as String,
      withdrawalDate: DateTime.parse(json['withdrawalDate'] as String),
      withdrawalReason: json['withdrawalReason'] as String,
    );

Map<String, dynamic> _$ConsentRecordToJson(ConsentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'consentType': instance.consentType,
      'consentDate': instance.consentDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'isActive': instance.isActive,
      'consentText': instance.consentText,
      'purposes': instance.purposes,
      'method': _$ConsentMethodEnumMap[instance.method]!,
      'recordedBy': instance.recordedBy,
      'withdrawalDate': instance.withdrawalDate.toIso8601String(),
      'withdrawalReason': instance.withdrawalReason,
    };

const _$ConsentMethodEnumMap = {
  ConsentMethod.written: 'written',
  ConsentMethod.electronic: 'electronic',
  ConsentMethod.verbal: 'verbal',
  ConsentMethod.implied: 'implied',
  ConsentMethod.optOut: 'optOut',
};

DataRetentionPolicy _$DataRetentionPolicyFromJson(Map<String, dynamic> json) =>
    DataRetentionPolicy(
      id: json['id'] as String,
      dataType: json['dataType'] as String,
      retentionPeriod: json['retentionPeriod'] as String,
      legalBasis: json['legalBasis'] as String,
      disposalMethod: json['disposalMethod'] as String,
      lastReviewDate: DateTime.parse(json['lastReviewDate'] as String),
      reviewedBy: json['reviewedBy'] as String,
      exceptions: (json['exceptions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$DataRetentionPolicyToJson(
  DataRetentionPolicy instance,
) => <String, dynamic>{
  'id': instance.id,
  'dataType': instance.dataType,
  'retentionPeriod': instance.retentionPeriod,
  'legalBasis': instance.legalBasis,
  'disposalMethod': instance.disposalMethod,
  'lastReviewDate': instance.lastReviewDate.toIso8601String(),
  'reviewedBy': instance.reviewedBy,
  'exceptions': instance.exceptions,
  'notes': instance.notes,
};
