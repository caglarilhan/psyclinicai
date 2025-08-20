// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turkey_diagnosis_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurkeyDiagnosisSystem _$TurkeyDiagnosisSystemFromJson(
  Map<String, dynamic> json,
) => TurkeyDiagnosisSystem(
  id: json['id'] as String,
  icd10Code: json['icd10Code'] as String,
  icd10Name: json['icd10Name'] as String,
  turkishName: json['turkishName'] as String,
  englishName: json['englishName'] as String,
  category: json['category'] as String,
  subcategory: json['subcategory'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  diagnosticCriteria: (json['diagnosticCriteria'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  differentialDiagnoses: (json['differentialDiagnoses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  comorbidities: (json['comorbidities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  treatmentOptions: (json['treatmentOptions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  severity: json['severity'] as String,
  isReportable: json['isReportable'] as bool,
  requiredTests: (json['requiredTests'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  followUpRequirements: (json['followUpRequirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$TurkeyDiagnosisSystemToJson(
  TurkeyDiagnosisSystem instance,
) => <String, dynamic>{
  'id': instance.id,
  'icd10Code': instance.icd10Code,
  'icd10Name': instance.icd10Name,
  'turkishName': instance.turkishName,
  'englishName': instance.englishName,
  'category': instance.category,
  'subcategory': instance.subcategory,
  'symptoms': instance.symptoms,
  'diagnosticCriteria': instance.diagnosticCriteria,
  'differentialDiagnoses': instance.differentialDiagnoses,
  'comorbidities': instance.comorbidities,
  'riskFactors': instance.riskFactors,
  'treatmentOptions': instance.treatmentOptions,
  'medications': instance.medications,
  'severity': instance.severity,
  'isReportable': instance.isReportable,
  'requiredTests': instance.requiredTests,
  'followUpRequirements': instance.followUpRequirements,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};

TurkeyMedicalReport _$TurkeyMedicalReportFromJson(Map<String, dynamic> json) =>
    TurkeyMedicalReport(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      tcKimlikNo: json['tcKimlikNo'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorTitle: json['doctorTitle'] as String,
      hospitalCode: json['hospitalCode'] as String,
      clinicCode: json['clinicCode'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      status: $enumDecode(_$ReportStatusEnumMap, json['status']),
      diagnosis: json['diagnosis'] as String,
      diagnosisCode: json['diagnosisCode'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      findings: (json['findings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tests: (json['tests'] as List<dynamic>).map((e) => e as String).toList(),
      treatment: json['treatment'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: json['recommendations'] as String,
      notes: json['notes'] as String,
      isUrgent: json['isUrgent'] as bool,
      requiresFollowUp: json['requiresFollowUp'] as bool,
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
      mhrsId: json['mhrsId'] as String,
      eRaporId: json['eRaporId'] as String,
      attachments: (json['attachments'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$TurkeyMedicalReportToJson(
  TurkeyMedicalReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'patientName': instance.patientName,
  'tcKimlikNo': instance.tcKimlikNo,
  'doctorId': instance.doctorId,
  'doctorName': instance.doctorName,
  'doctorTitle': instance.doctorTitle,
  'hospitalCode': instance.hospitalCode,
  'clinicCode': instance.clinicCode,
  'reportDate': instance.reportDate.toIso8601String(),
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'type': _$ReportTypeEnumMap[instance.type]!,
  'status': _$ReportStatusEnumMap[instance.status]!,
  'diagnosis': instance.diagnosis,
  'diagnosisCode': instance.diagnosisCode,
  'symptoms': instance.symptoms,
  'findings': instance.findings,
  'tests': instance.tests,
  'treatment': instance.treatment,
  'medications': instance.medications,
  'recommendations': instance.recommendations,
  'notes': instance.notes,
  'isUrgent': instance.isUrgent,
  'requiresFollowUp': instance.requiresFollowUp,
  'followUpDate': instance.followUpDate?.toIso8601String(),
  'mhrsId': instance.mhrsId,
  'eRaporId': instance.eRaporId,
  'attachments': instance.attachments,
  'metadata': instance.metadata,
};

const _$ReportTypeEnumMap = {
  ReportType.consultation: 'consultation',
  ReportType.followUp: 'followUp',
  ReportType.emergency: 'emergency',
  ReportType.surgery: 'surgery',
  ReportType.pathology: 'pathology',
  ReportType.radiology: 'radiology',
  ReportType.laboratory: 'laboratory',
  ReportType.discharge: 'discharge',
  ReportType.death: 'death',
  ReportType.birth: 'birth',
  ReportType.vaccination: 'vaccination',
  ReportType.screening: 'screening',
};

const _$ReportStatusEnumMap = {
  ReportStatus.draft: 'draft',
  ReportStatus.pending: 'pending',
  ReportStatus.approved: 'approved',
  ReportStatus.rejected: 'rejected',
  ReportStatus.completed: 'completed',
  ReportStatus.cancelled: 'cancelled',
};

ReportTemplate _$ReportTemplateFromJson(Map<String, dynamic> json) =>
    ReportTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$ReportTypeEnumMap, json['type']),
      specialty: json['specialty'] as String,
      commonDiagnoses: (json['commonDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ReportSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredFields: (json['requiredFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$ReportTemplateToJson(ReportTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$ReportTypeEnumMap[instance.type]!,
      'specialty': instance.specialty,
      'commonDiagnoses': instance.commonDiagnoses,
      'sections': instance.sections,
      'requiredFields': instance.requiredFields,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastModified': instance.lastModified.toIso8601String(),
    };

ReportSection _$ReportSectionFromJson(
  Map<String, dynamic> json,
) => ReportSection(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$SectionTypeEnumMap, json['type']),
  isRequired: json['isRequired'] as bool,
  fields: (json['fields'] as List<dynamic>).map((e) => e as String).toList(),
  defaultValue: json['defaultValue'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  validation: json['validation'] as String,
);

Map<String, dynamic> _$ReportSectionToJson(ReportSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$SectionTypeEnumMap[instance.type]!,
      'isRequired': instance.isRequired,
      'fields': instance.fields,
      'defaultValue': instance.defaultValue,
      'options': instance.options,
      'validation': instance.validation,
    };

const _$SectionTypeEnumMap = {
  SectionType.text: 'text',
  SectionType.number: 'number',
  SectionType.date: 'date',
  SectionType.select: 'select',
  SectionType.multiselect: 'multiselect',
  SectionType.checkbox: 'checkbox',
  SectionType.radio: 'radio',
  SectionType.file: 'file',
};

ERaporIntegration _$ERaporIntegrationFromJson(Map<String, dynamic> json) =>
    ERaporIntegration(
      id: json['id'] as String,
      reportId: json['reportId'] as String,
      eRaporId: json['eRaporId'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      syncStatus: json['syncStatus'] as String,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ERaporIntegrationToJson(ERaporIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportId': instance.reportId,
      'eRaporId': instance.eRaporId,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'errors': instance.errors,
      'metadata': instance.metadata,
    };

DiagnosisCategory _$DiagnosisCategoryFromJson(Map<String, dynamic> json) =>
    DiagnosisCategory(
      id: json['id'] as String,
      categoryCode: json['categoryCode'] as String,
      categoryName: json['categoryName'] as String,
      turkishName: json['turkishName'] as String,
      description: json['description'] as String,
      subcategories: (json['subcategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      commonConditions: (json['commonConditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      severity: json['severity'] as String,
      isReportable: json['isReportable'] as bool,
      requiredActions: (json['requiredActions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DiagnosisCategoryToJson(DiagnosisCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryCode': instance.categoryCode,
      'categoryName': instance.categoryName,
      'turkishName': instance.turkishName,
      'description': instance.description,
      'subcategories': instance.subcategories,
      'commonConditions': instance.commonConditions,
      'severity': instance.severity,
      'isReportable': instance.isReportable,
      'requiredActions': instance.requiredActions,
    };

ReportableCondition _$ReportableConditionFromJson(Map<String, dynamic> json) =>
    ReportableCondition(
      id: json['id'] as String,
      conditionName: json['conditionName'] as String,
      icd10Code: json['icd10Code'] as String,
      type: $enumDecode(_$ReportableTypeEnumMap, json['type']),
      reportingAuthority: json['reportingAuthority'] as String,
      reportingFrequency: json['reportingFrequency'] as String,
      requiredData: (json['requiredData'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      reportingChannels: (json['reportingChannels'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      expiryDate: json['expiryDate'] == null
          ? null
          : DateTime.parse(json['expiryDate'] as String),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ReportableConditionToJson(
  ReportableCondition instance,
) => <String, dynamic>{
  'id': instance.id,
  'conditionName': instance.conditionName,
  'icd10Code': instance.icd10Code,
  'type': _$ReportableTypeEnumMap[instance.type]!,
  'reportingAuthority': instance.reportingAuthority,
  'reportingFrequency': instance.reportingFrequency,
  'requiredData': instance.requiredData,
  'reportingChannels': instance.reportingChannels,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'status': instance.status,
};

const _$ReportableTypeEnumMap = {
  ReportableType.infectiousDisease: 'infectiousDisease',
  ReportableType.chronicDisease: 'chronicDisease',
  ReportableType.occupationalDisease: 'occupationalDisease',
  ReportableType.environmentalDisease: 'environmentalDisease',
  ReportableType.maternalChild: 'maternalChild',
  ReportableType.injury: 'injury',
  ReportableType.death: 'death',
  ReportableType.birth: 'birth',
  ReportableType.vaccination: 'vaccination',
};

MedicalCertificate _$MedicalCertificateFromJson(Map<String, dynamic> json) =>
    MedicalCertificate(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      tcKimlikNo: json['tcKimlikNo'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorTitle: json['doctorTitle'] as String,
      hospitalCode: json['hospitalCode'] as String,
      clinicCode: json['clinicCode'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      type: $enumDecode(_$CertificateTypeEnumMap, json['type']),
      reason: json['reason'] as String,
      diagnosis: json['diagnosis'] as String,
      diagnosisCode: json['diagnosisCode'] as String,
      restrictions: json['restrictions'] as String,
      recommendations: json['recommendations'] as String,
      isUrgent: json['isUrgent'] as bool,
      mhrsId: json['mhrsId'] as String,
      eRaporId: json['eRaporId'] as String,
      status: $enumDecode(_$CertificateStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$MedicalCertificateToJson(MedicalCertificate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'tcKimlikNo': instance.tcKimlikNo,
      'doctorId': instance.doctorId,
      'doctorName': instance.doctorName,
      'doctorTitle': instance.doctorTitle,
      'hospitalCode': instance.hospitalCode,
      'clinicCode': instance.clinicCode,
      'issueDate': instance.issueDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'type': _$CertificateTypeEnumMap[instance.type]!,
      'reason': instance.reason,
      'diagnosis': instance.diagnosis,
      'diagnosisCode': instance.diagnosisCode,
      'restrictions': instance.restrictions,
      'recommendations': instance.recommendations,
      'isUrgent': instance.isUrgent,
      'mhrsId': instance.mhrsId,
      'eRaporId': instance.eRaporId,
      'status': _$CertificateStatusEnumMap[instance.status]!,
    };

const _$CertificateTypeEnumMap = {
  CertificateType.sickLeave: 'sickLeave',
  CertificateType.fitness: 'fitness',
  CertificateType.disability: 'disability',
  CertificateType.pregnancy: 'pregnancy',
  CertificateType.vaccination: 'vaccination',
  CertificateType.travel: 'travel',
  CertificateType.sports: 'sports',
  CertificateType.work: 'work',
  CertificateType.school: 'school',
  CertificateType.driving: 'driving',
};

const _$CertificateStatusEnumMap = {
  CertificateStatus.active: 'active',
  CertificateStatus.expired: 'expired',
  CertificateStatus.cancelled: 'cancelled',
  CertificateStatus.suspended: 'suspended',
  CertificateStatus.completed: 'completed',
};

DiagnosisStatistics _$DiagnosisStatisticsFromJson(
  Map<String, dynamic> json,
) => DiagnosisStatistics(
  id: json['id'] as String,
  diagnosisCode: json['diagnosisCode'] as String,
  diagnosisName: json['diagnosisName'] as String,
  totalCases: (json['totalCases'] as num).toInt(),
  newCases: (json['newCases'] as num).toInt(),
  resolvedCases: (json['resolvedCases'] as num).toInt(),
  averageAge: (json['averageAge'] as num).toDouble(),
  genderDistribution: Map<String, int>.from(json['genderDistribution'] as Map),
  ageGroupDistribution: Map<String, int>.from(
    json['ageGroupDistribution'] as Map,
  ),
  regionDistribution: Map<String, int>.from(json['regionDistribution'] as Map),
  severityDistribution: Map<String, int>.from(
    json['severityDistribution'] as Map,
  ),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$DiagnosisStatisticsToJson(
  DiagnosisStatistics instance,
) => <String, dynamic>{
  'id': instance.id,
  'diagnosisCode': instance.diagnosisCode,
  'diagnosisName': instance.diagnosisName,
  'totalCases': instance.totalCases,
  'newCases': instance.newCases,
  'resolvedCases': instance.resolvedCases,
  'averageAge': instance.averageAge,
  'genderDistribution': instance.genderDistribution,
  'ageGroupDistribution': instance.ageGroupDistribution,
  'regionDistribution': instance.regionDistribution,
  'severityDistribution': instance.severityDistribution,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
