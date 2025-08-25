// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'us_state_law_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StateLegalRequirement _$StateLegalRequirementFromJson(
  Map<String, dynamic> json,
) => StateLegalRequirement(
  id: json['id'] as String,
  state: $enumDecode(_$USStateEnumMap, json['state']),
  type: $enumDecode(_$LegalRequirementTypeEnumMap, json['type']),
  severity: $enumDecode(_$LegalSeverityEnumMap, json['severity']),
  title: json['title'] as String,
  description: json['description'] as String,
  legalReference: json['legalReference'] as String,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  exceptions: (json['exceptions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  penalties: (json['penalties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  expirationDate: json['expirationDate'] == null
      ? null
      : DateTime.parse(json['expirationDate'] as String),
  isActive: json['isActive'] as bool,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$StateLegalRequirementToJson(
  StateLegalRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': _$USStateEnumMap[instance.state]!,
  'type': _$LegalRequirementTypeEnumMap[instance.type]!,
  'severity': _$LegalSeverityEnumMap[instance.severity]!,
  'title': instance.title,
  'description': instance.description,
  'legalReference': instance.legalReference,
  'requirements': instance.requirements,
  'exceptions': instance.exceptions,
  'penalties': instance.penalties,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'expirationDate': instance.expirationDate?.toIso8601String(),
  'isActive': instance.isActive,
  'tags': instance.tags,
};

const _$USStateEnumMap = {
  USState.alabama: 'AL',
  USState.alaska: 'AK',
  USState.arizona: 'AZ',
  USState.arkansas: 'AR',
  USState.california: 'CA',
  USState.colorado: 'CO',
  USState.connecticut: 'CT',
  USState.delaware: 'DE',
  USState.florida: 'FL',
  USState.georgia: 'GA',
  USState.hawaii: 'HI',
  USState.idaho: 'ID',
  USState.illinois: 'IL',
  USState.indiana: 'IN',
  USState.iowa: 'IA',
  USState.kansas: 'KS',
  USState.kentucky: 'KY',
  USState.louisiana: 'LA',
  USState.maine: 'ME',
  USState.maryland: 'MD',
  USState.massachusetts: 'MA',
  USState.michigan: 'MI',
  USState.minnesota: 'MN',
  USState.mississippi: 'MS',
  USState.missouri: 'MO',
  USState.montana: 'MT',
  USState.nebraska: 'NE',
  USState.nevada: 'NV',
  USState.newHampshire: 'NH',
  USState.newJersey: 'NJ',
  USState.newMexico: 'NM',
  USState.newYork: 'NY',
  USState.northCarolina: 'NC',
  USState.northDakota: 'ND',
  USState.ohio: 'OH',
  USState.oklahoma: 'OK',
  USState.oregon: 'OR',
  USState.pennsylvania: 'PA',
  USState.rhodeIsland: 'RI',
  USState.southCarolina: 'SC',
  USState.southDakota: 'SD',
  USState.tennessee: 'TN',
  USState.texas: 'TX',
  USState.utah: 'UT',
  USState.vermont: 'VT',
  USState.virginia: 'VA',
  USState.washington: 'WA',
  USState.westVirginia: 'WV',
  USState.wisconsin: 'WI',
  USState.wyoming: 'WY',
  USState.districtOfColumbia: 'DC',
  USState.americanSamoa: 'AS',
  USState.guam: 'GU',
  USState.northernMarianaIslands: 'MP',
  USState.puertoRico: 'PR',
  USState.usVirginIslands: 'VI',
};

const _$LegalRequirementTypeEnumMap = {
  LegalRequirementType.hipaa: 'hipaa',
  LegalRequirementType.statePrivacy: 'state_privacy',
  LegalRequirementType.mentalHealth: 'mental_health',
  LegalRequirementType.minors: 'minors',
  LegalRequirementType.telehealth: 'telehealth',
  LegalRequirementType.prescription: 'prescription',
  LegalRequirementType.billing: 'billing',
  LegalRequirementType.licensing: 'licensing',
  LegalRequirementType.reporting: 'reporting',
  LegalRequirementType.consent: 'consent',
};

const _$LegalSeverityEnumMap = {
  LegalSeverity.critical: 'critical',
  LegalSeverity.high: 'high',
  LegalSeverity.medium: 'medium',
  LegalSeverity.low: 'low',
  LegalSeverity.informational: 'informational',
};

HIPAARequirement _$HIPAARequirementFromJson(Map<String, dynamic> json) =>
    HIPAARequirement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      severity: $enumDecode(_$LegalSeverityEnumMap, json['severity']),
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      safeguards: (json['safeguards'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      violations: (json['violations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      penalties: (json['penalties'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$HIPAARequirementToJson(HIPAARequirement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'severity': _$LegalSeverityEnumMap[instance.severity]!,
      'requirements': instance.requirements,
      'safeguards': instance.safeguards,
      'violations': instance.violations,
      'penalties': instance.penalties,
      'effectiveDate': instance.effectiveDate.toIso8601String(),
      'isActive': instance.isActive,
    };

TelehealthLegalRequirement _$TelehealthLegalRequirementFromJson(
  Map<String, dynamic> json,
) => TelehealthLegalRequirement(
  id: json['id'] as String,
  state: $enumDecode(_$USStateEnumMap, json['state']),
  title: json['title'] as String,
  description: json['description'] as String,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  restrictions: (json['restrictions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  allowedPractitioners: (json['allowedPractitioners'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  allowedServices: (json['allowedServices'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  documentation: (json['documentation'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  consent: (json['consent'] as List<dynamic>).map((e) => e as String).toList(),
  billing: (json['billing'] as List<dynamic>).map((e) => e as String).toList(),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$TelehealthLegalRequirementToJson(
  TelehealthLegalRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': _$USStateEnumMap[instance.state]!,
  'title': instance.title,
  'description': instance.description,
  'requirements': instance.requirements,
  'restrictions': instance.restrictions,
  'allowedPractitioners': instance.allowedPractitioners,
  'allowedServices': instance.allowedServices,
  'documentation': instance.documentation,
  'consent': instance.consent,
  'billing': instance.billing,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'isActive': instance.isActive,
};

MentalHealthLegalRequirement _$MentalHealthLegalRequirementFromJson(
  Map<String, dynamic> json,
) => MentalHealthLegalRequirement(
  id: json['id'] as String,
  state: $enumDecode(_$USStateEnumMap, json['state']),
  title: json['title'] as String,
  description: json['description'] as String,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  patientRights: (json['patientRights'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  providerObligations: (json['providerObligations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  emergencyProcedures: (json['emergencyProcedures'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  reportingObligations: (json['reportingObligations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidentiality: (json['confidentiality'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$MentalHealthLegalRequirementToJson(
  MentalHealthLegalRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': _$USStateEnumMap[instance.state]!,
  'title': instance.title,
  'description': instance.description,
  'requirements': instance.requirements,
  'patientRights': instance.patientRights,
  'providerObligations': instance.providerObligations,
  'emergencyProcedures': instance.emergencyProcedures,
  'reportingObligations': instance.reportingObligations,
  'confidentiality': instance.confidentiality,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'isActive': instance.isActive,
};

MinorConsentRequirement _$MinorConsentRequirementFromJson(
  Map<String, dynamic> json,
) => MinorConsentRequirement(
  id: json['id'] as String,
  state: $enumDecode(_$USStateEnumMap, json['state']),
  title: json['title'] as String,
  description: json['description'] as String,
  ageOfMajority: (json['ageOfMajority'] as num).toInt(),
  emancipatedMinors: (json['emancipatedMinors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  matureMinors: (json['matureMinors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  parentalConsent: (json['parentalConsent'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  exceptions: (json['exceptions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  documentation: (json['documentation'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$MinorConsentRequirementToJson(
  MinorConsentRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': _$USStateEnumMap[instance.state]!,
  'title': instance.title,
  'description': instance.description,
  'ageOfMajority': instance.ageOfMajority,
  'emancipatedMinors': instance.emancipatedMinors,
  'matureMinors': instance.matureMinors,
  'parentalConsent': instance.parentalConsent,
  'exceptions': instance.exceptions,
  'documentation': instance.documentation,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'isActive': instance.isActive,
};

PrescriptionLegalRequirement _$PrescriptionLegalRequirementFromJson(
  Map<String, dynamic> json,
) => PrescriptionLegalRequirement(
  id: json['id'] as String,
  state: $enumDecode(_$USStateEnumMap, json['state']),
  title: json['title'] as String,
  description: json['description'] as String,
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  controlledSubstances: (json['controlledSubstances'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  prescribingLimits: (json['prescribingLimits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  documentation: (json['documentation'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoring: (json['monitoring'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  penalties: (json['penalties'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$PrescriptionLegalRequirementToJson(
  PrescriptionLegalRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'state': _$USStateEnumMap[instance.state]!,
  'title': instance.title,
  'description': instance.description,
  'requirements': instance.requirements,
  'controlledSubstances': instance.controlledSubstances,
  'prescribingLimits': instance.prescribingLimits,
  'documentation': instance.documentation,
  'monitoring': instance.monitoring,
  'penalties': instance.penalties,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'isActive': instance.isActive,
};

LegalComplianceChecklistItem _$LegalComplianceChecklistItemFromJson(
  Map<String, dynamic> json,
) => LegalComplianceChecklistItem(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$LegalRequirementTypeEnumMap, json['type']),
  severity: $enumDecode(_$LegalSeverityEnumMap, json['severity']),
  state: $enumDecodeNullable(_$USStateEnumMap, json['state']),
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isRequired: json['isRequired'] as bool,
  isCompleted: json['isCompleted'] as bool,
  completedDate: json['completedDate'] == null
      ? null
      : DateTime.parse(json['completedDate'] as String),
  completedBy: json['completedBy'] as String?,
  notes: json['notes'] as String?,
  evidence: (json['evidence'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  isOverdue: json['isOverdue'] as bool,
);

Map<String, dynamic> _$LegalComplianceChecklistItemToJson(
  LegalComplianceChecklistItem instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$LegalRequirementTypeEnumMap[instance.type]!,
  'severity': _$LegalSeverityEnumMap[instance.severity]!,
  'state': _$USStateEnumMap[instance.state],
  'requirements': instance.requirements,
  'isRequired': instance.isRequired,
  'isCompleted': instance.isCompleted,
  'completedDate': instance.completedDate?.toIso8601String(),
  'completedBy': instance.completedBy,
  'notes': instance.notes,
  'evidence': instance.evidence,
  'dueDate': instance.dueDate.toIso8601String(),
  'isOverdue': instance.isOverdue,
};

LegalComplianceAuditResult _$LegalComplianceAuditResultFromJson(
  Map<String, dynamic> json,
) => LegalComplianceAuditResult(
  id: json['id'] as String,
  auditId: json['auditId'] as String,
  state: $enumDecode(_$USStateEnumMap, json['state']),
  auditDate: DateTime.parse(json['auditDate'] as String),
  auditor: json['auditor'] as String,
  checklistItems: (json['checklistItems'] as List<dynamic>)
      .map(
        (e) => LegalComplianceChecklistItem.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  totalItems: (json['totalItems'] as num).toInt(),
  completedItems: (json['completedItems'] as num).toInt(),
  overdueItems: (json['overdueItems'] as num).toInt(),
  compliancePercentage: (json['compliancePercentage'] as num).toDouble(),
  criticalIssues: (json['criticalIssues'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  overallRisk: $enumDecode(_$LegalSeverityEnumMap, json['overallRisk']),
  nextAuditDate: DateTime.parse(json['nextAuditDate'] as String),
);

Map<String, dynamic> _$LegalComplianceAuditResultToJson(
  LegalComplianceAuditResult instance,
) => <String, dynamic>{
  'id': instance.id,
  'auditId': instance.auditId,
  'state': _$USStateEnumMap[instance.state]!,
  'auditDate': instance.auditDate.toIso8601String(),
  'auditor': instance.auditor,
  'checklistItems': instance.checklistItems,
  'totalItems': instance.totalItems,
  'completedItems': instance.completedItems,
  'overdueItems': instance.overdueItems,
  'compliancePercentage': instance.compliancePercentage,
  'criticalIssues': instance.criticalIssues,
  'recommendations': instance.recommendations,
  'overallRisk': _$LegalSeverityEnumMap[instance.overallRisk]!,
  'nextAuditDate': instance.nextAuditDate.toIso8601String(),
};

LegalRequirementUpdate _$LegalRequirementUpdateFromJson(
  Map<String, dynamic> json,
) => LegalRequirementUpdate(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$LegalRequirementTypeEnumMap, json['type']),
  state: $enumDecodeNullable(_$USStateEnumMap, json['state']),
  severity: $enumDecode(_$LegalSeverityEnumMap, json['severity']),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  changes: (json['changes'] as List<dynamic>).map((e) => e as String).toList(),
  impact: (json['impact'] as List<dynamic>).map((e) => e as String).toList(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  notificationDate: DateTime.parse(json['notificationDate'] as String),
  isRead: json['isRead'] as bool,
  requiresAction: json['requiresAction'] as bool,
);

Map<String, dynamic> _$LegalRequirementUpdateToJson(
  LegalRequirementUpdate instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$LegalRequirementTypeEnumMap[instance.type]!,
  'state': _$USStateEnumMap[instance.state],
  'severity': _$LegalSeverityEnumMap[instance.severity]!,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'changes': instance.changes,
  'impact': instance.impact,
  'actions': instance.actions,
  'notificationDate': instance.notificationDate.toIso8601String(),
  'isRead': instance.isRead,
  'requiresAction': instance.requiresAction,
};
