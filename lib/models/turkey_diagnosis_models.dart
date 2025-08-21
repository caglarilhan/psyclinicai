import 'package:json_annotation/json_annotation.dart';

part 'turkey_diagnosis_models.g.dart';

@JsonSerializable()
class TurkeyDiagnosisSystem {
  final String id;
  final String icd10Code;
  final String icd10Name;
  final String turkishName;
  final String englishName;
  final String category;
  final String subcategory;
  final List<String> symptoms;
  final List<String> diagnosticCriteria;
  final List<String> differentialDiagnoses;
  final List<String> comorbidities;
  final List<String> riskFactors;
  final List<String> treatmentOptions;
  final List<String> medications;
  final String severity;
  final bool isReportable;
  final List<String> requiredTests;
  final List<String> followUpRequirements;
  final DateTime lastUpdated;

  const TurkeyDiagnosisSystem({
    required this.id,
    required this.icd10Code,
    required this.icd10Name,
    required this.turkishName,
    required this.englishName,
    required this.category,
    required this.subcategory,
    required this.symptoms,
    required this.diagnosticCriteria,
    required this.differentialDiagnoses,
    required this.comorbidities,
    required this.riskFactors,
    required this.treatmentOptions,
    required this.medications,
    required this.severity,
    required this.isReportable,
    required this.requiredTests,
    required this.followUpRequirements,
    required this.lastUpdated,
  });

  factory TurkeyDiagnosisSystem.fromJson(Map<String, dynamic> json) =>
      _$TurkeyDiagnosisSystemFromJson(json);

  Map<String, dynamic> toJson() => _$TurkeyDiagnosisSystemToJson(this);
}

@JsonSerializable()
class TurkeyMedicalReport {
  final String id;
  final String patientId;
  final String patientName;
  final String tcKimlikNo;
  final String doctorId;
  final String doctorName;
  final String doctorTitle;
  final String hospitalCode;
  final String clinicCode;
  final DateTime reportDate;
  final DateTime? expiryDate;
  final ReportType type;
  final ReportStatus status;
  final String diagnosis;
  final String diagnosisCode;
  final List<String> symptoms;
  final List<String> findings;
  final List<String> tests;
  final String treatment;
  final List<String> medications;
  final String recommendations;
  final String notes;
  final bool isUrgent;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final String mhrsId;
  final String eRaporId;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  const TurkeyMedicalReport({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.tcKimlikNo,
    required this.doctorId,
    required this.doctorName,
    required this.doctorTitle,
    required this.hospitalCode,
    required this.clinicCode,
    required this.reportDate,
    this.expiryDate,
    required this.type,
    required this.status,
    required this.diagnosis,
    required this.diagnosisCode,
    required this.symptoms,
    required this.findings,
    required this.tests,
    required this.treatment,
    required this.medications,
    required this.recommendations,
    required this.notes,
    required this.isUrgent,
    required this.requiresFollowUp,
    this.followUpDate,
    required this.mhrsId,
    required this.eRaporId,
    required this.attachments,
    required this.metadata,
  });

  factory TurkeyMedicalReport.fromJson(Map<String, dynamic> json) =>
      _$TurkeyMedicalReportFromJson(json);

  Map<String, dynamic> toJson() => _$TurkeyMedicalReportToJson(this);

  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get needsFollowUp => requiresFollowUp && (followUpDate == null || DateTime.now().isAfter(followUpDate!));
}

@JsonSerializable()
class ReportTemplate {
  final String id;
  final String name;
  final String description;
  final ReportType type;
  final String specialty;
  final List<String> commonDiagnoses;
  final List<ReportSection> sections;
  final List<String> requiredFields;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastModified;

  const ReportTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.specialty,
    required this.commonDiagnoses,
    required this.sections,
    required this.requiredFields,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.lastModified,
  });

  factory ReportTemplate.fromJson(Map<String, dynamic> json) =>
      _$ReportTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$ReportTemplateToJson(this);
}

@JsonSerializable()
class ReportSection {
  final String id;
  final String title;
  final String description;
  final SectionType type;
  final bool isRequired;
  final List<String> fields;
  final String defaultValue;
  final List<String> options;
  final String validation;

  const ReportSection({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.isRequired,
    required this.fields,
    required this.defaultValue,
    required this.options,
    required this.validation,
  });

  factory ReportSection.fromJson(Map<String, dynamic> json) =>
      _$ReportSectionFromJson(json);

  Map<String, dynamic> toJson() => _$ReportSectionToJson(this);
}

@JsonSerializable()
class ERaporIntegration {
  final String id;
  final String reportId;
  final String eRaporId;
  final bool isActive;
  final DateTime lastSync;
  final String syncStatus;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  const ERaporIntegration({
    required this.id,
    required this.reportId,
    required this.eRaporId,
    required this.isActive,
    required this.lastSync,
    required this.syncStatus,
    required this.errors,
    required this.metadata,
  });

  factory ERaporIntegration.fromJson(Map<String, dynamic> json) =>
      _$ERaporIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$ERaporIntegrationToJson(this);
}

@JsonSerializable()
class DiagnosisCategory {
  final String id;
  final String categoryCode;
  final String categoryName;
  final String turkishName;
  final String description;
  final List<String> subcategories;
  final List<String> commonConditions;
  final String severity;
  final bool isReportable;
  final List<String> requiredActions;

  const DiagnosisCategory({
    required this.id,
    required this.categoryCode,
    required this.categoryName,
    required this.turkishName,
    required this.description,
    required this.subcategories,
    required this.commonConditions,
    required this.severity,
    required this.isReportable,
    required this.requiredActions,
  });

  factory DiagnosisCategory.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisCategoryToJson(this);
}

@JsonSerializable()
class ReportableCondition {
  final String id;
  final String conditionName;
  final String icd10Code;
  final ReportableType type;
  final String reportingAuthority;
  final String reportingFrequency;
  final List<String> requiredData;
  final List<String> reportingChannels;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final String status;

  const ReportableCondition({
    required this.id,
    required this.conditionName,
    required this.icd10Code,
    required this.type,
    required this.reportingAuthority,
    required this.reportingFrequency,
    required this.requiredData,
    required this.reportingChannels,
    required this.effectiveDate,
    this.expiryDate,
    required this.status,
  });

  factory ReportableCondition.fromJson(Map<String, dynamic> json) =>
      _$ReportableConditionFromJson(json);

  Map<String, dynamic> toJson() => _$ReportableConditionToJson(this);
}

@JsonSerializable()
class MedicalCertificate {
  final String id;
  final String patientId;
  final String patientName;
  final String tcKimlikNo;
  final String doctorId;
  final String doctorName;
  final String doctorTitle;
  final String hospitalCode;
  final String clinicCode;
  final DateTime issueDate;
  final DateTime expiryDate;
  final CertificateType type;
  final String reason;
  final String diagnosis;
  final String diagnosisCode;
  final String restrictions;
  final String recommendations;
  final bool isUrgent;
  final String mhrsId;
  final String eRaporId;
  final CertificateStatus status;

  const MedicalCertificate({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.tcKimlikNo,
    required this.doctorId,
    required this.doctorName,
    required this.doctorTitle,
    required this.hospitalCode,
    required this.clinicCode,
    required this.issueDate,
    required this.expiryDate,
    required this.type,
    required this.reason,
    required this.diagnosis,
    required this.diagnosisCode,
    required this.restrictions,
    required this.recommendations,
    required this.isUrgent,
    required this.mhrsId,
    required this.eRaporId,
    required this.status,
  });

  factory MedicalCertificate.fromJson(Map<String, dynamic> json) =>
      _$MedicalCertificateFromJson(json);

  Map<String, dynamic> toJson() => _$MedicalCertificateToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isActive => status == CertificateStatus.active && !isExpired;
}

@JsonSerializable()
class DiagnosisStatistics {
  final String id;
  final String diagnosisCode;
  final String diagnosisName;
  final int totalCases;
  final int newCases;
  final int resolvedCases;
  final double averageAge;
  final Map<String, int> genderDistribution;
  final Map<String, int> ageGroupDistribution;
  final Map<String, int> regionDistribution;
  final Map<String, int> severityDistribution;
  final DateTime lastUpdated;

  const DiagnosisStatistics({
    required this.id,
    required this.diagnosisCode,
    required this.diagnosisName,
    required this.totalCases,
    required this.newCases,
    required this.resolvedCases,
    required this.averageAge,
    required this.genderDistribution,
    required this.ageGroupDistribution,
    required this.regionDistribution,
    required this.severityDistribution,
    required this.lastUpdated,
  });

  factory DiagnosisStatistics.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosisStatisticsToJson(this);

  double get resolutionRate => totalCases > 0 ? resolvedCases / totalCases : 0.0;
  double get newCaseRate => totalCases > 0 ? newCases / totalCases : 0.0;
}

// Enums
enum ReportType {
  consultation,
  followUp,
  emergency,
  surgery,
  pathology,
  radiology,
  laboratory,
  discharge,
  death,
  birth,
  vaccination,
  screening,
}

enum ReportStatus {
  draft,
  pending,
  approved,
  rejected,
  completed,
  cancelled,
}

enum SectionType {
  text,
  number,
  date,
  select,
  multiselect,
  checkbox,
  radio,
  file,
}

enum ReportableType {
  infectiousDisease,
  chronicDisease,
  occupationalDisease,
  environmentalDisease,
  maternalChild,
  injury,
  death,
  birth,
  vaccination,
}

enum CertificateType {
  sickLeave,
  fitness,
  disability,
  pregnancy,
  vaccination,
  travel,
  sports,
  work,
  school,
  driving,
}

enum CertificateStatus {
  active,
  expired,
  cancelled,
  suspended,
  completed,
}
