import 'package:json_annotation/json_annotation.dart';

part 'turkey_health_system_models.g.dart';

@JsonSerializable()
class TurkeyHealthSystemIntegration {
  final String id;
  final String organizationId;
  final String hospitalCode;
  final String clinicCode;
  final String doctorCode;
  final List<HealthSystemModule> activeModules;
  final List<IntegrationStatus> integrations;
  final List<ComplianceRequirement> complianceRequirements;
  final List<ReportingRequirement> reportingRequirements;
  final Map<String, dynamic> configuration;

  const TurkeyHealthSystemIntegration({
    required this.id,
    required this.organizationId,
    required this.hospitalCode,
    required this.clinicCode,
    required this.doctorCode,
    required this.activeModules,
    required this.integrations,
    required this.complianceRequirements,
    required this.reportingRequirements,
    required this.configuration,
  });

  factory TurkeyHealthSystemIntegration.fromJson(Map<String, dynamic> json) =>
      _$TurkeyHealthSystemIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$TurkeyHealthSystemIntegrationToJson(this);
}

@JsonSerializable()
class HealthSystemModule {
  final String id;
  final ModuleType type;
  final String name;
  final String description;
  final bool isActive;
  final DateTime lastSync;
  final String version;
  final List<String> features;
  final Map<String, dynamic> settings;

  const HealthSystemModule({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.isActive,
    required this.lastSync,
    required this.version,
    required this.features,
    required this.settings,
  });

  factory HealthSystemModule.fromJson(Map<String, dynamic> json) =>
      _$HealthSystemModuleFromJson(json);

  Map<String, dynamic> toJson() => _$HealthSystemModuleToJson(this);
}

@JsonSerializable()
class IntegrationStatus {
  final String id;
  final IntegrationType type;
  final String name;
  final IntegrationState state;
  final DateTime lastSync;
  final String lastError;
  final int syncFrequency;
  final bool isEnabled;
  final Map<String, dynamic> metadata;

  const IntegrationStatus({
    required this.id,
    required this.type,
    required this.name,
    required this.state,
    required this.lastSync,
    required this.lastError,
    required this.syncFrequency,
    required this.isEnabled,
    required this.metadata,
  });

  factory IntegrationStatus.fromJson(Map<String, dynamic> json) =>
      _$IntegrationStatusFromJson(json);

  Map<String, dynamic> toJson() => _$IntegrationStatusToJson(this);
}

@JsonSerializable()
class ComplianceRequirement {
  final String id;
  final String title;
  final String description;
  final ComplianceType type;
  final String regulation;
  final DateTime effectiveDate;
  final DateTime expiryDate;
  final ComplianceStatus status;
  final List<String> requirements;
  final List<String> evidence;
  final String responsiblePerson;

  const ComplianceRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.regulation,
    required this.effectiveDate,
    required this.expiryDate,
    required this.status,
    required this.requirements,
    required this.evidence,
    required this.responsiblePerson,
  });

  factory ComplianceRequirement.fromJson(Map<String, dynamic> json) =>
      _$ComplianceRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$ComplianceRequirementToJson(this);
}

@JsonSerializable()
class ReportingRequirement {
  final String id;
  final String title;
  final String description;
  final ReportType type;
  final String frequency;
  final DateTime nextDueDate;
  final String format;
  final List<String> recipients;
  final bool isMandatory;
  final String template;
  final Map<String, dynamic> dataRequirements;

  const ReportingRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.frequency,
    required this.nextDueDate,
    required this.format,
    required this.recipients,
    required this.isMandatory,
    required this.template,
    required this.dataRequirements,
  });

  factory ReportingRequirement.fromJson(Map<String, dynamic> json) =>
      _$ReportingRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$ReportingRequirementToJson(this);
}

@JsonSerializable()
class MHRSIntegration {
  final String id;
  final String hospitalCode;
  final String clinicCode;
  final String doctorCode;
  final bool isActive;
  final DateTime lastSync;
  final List<AppointmentData> appointments;
  final List<PatientData> patients;
  final List<PrescriptionData> prescriptions;
  final String syncStatus;

  const MHRSIntegration({
    required this.id,
    required this.hospitalCode,
    required this.clinicCode,
    required this.doctorCode,
    required this.isActive,
    required this.lastSync,
    required this.appointments,
    required this.patients,
    required this.prescriptions,
    required this.syncStatus,
  });

  factory MHRSIntegration.fromJson(Map<String, dynamic> json) =>
      _$MHRSIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$MHRSIntegrationToJson(this);
}

@JsonSerializable()
class AppointmentData {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentStatus status;
  final String notes;
  final String mhrsId;

  const AppointmentData({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.notes,
    required this.mhrsId,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) =>
      _$AppointmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentDataToJson(this);
}

@JsonSerializable()
class PatientData {
  final String id;
  final String tcKimlikNo;
  final String name;
  final String surname;
  final DateTime birthDate;
  final String gender;
  final String phone;
  final String address;
  final String insuranceType;
  final String mhrsId;

  const PatientData({
    required this.id,
    required this.tcKimlikNo,
    required this.name,
    required this.surname,
    required this.birthDate,
    required this.gender,
    required this.phone,
    required this.address,
    required this.insuranceType,
    required this.mhrsId,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) =>
      _$PatientDataFromJson(json);

  Map<String, dynamic> toJson() => _$PatientDataToJson(this);
}

@JsonSerializable()
class PrescriptionData {
  final String id;
  final String patientId;
  final String patientName;
  final DateTime prescriptionDate;
  final List<MedicationData> medications;
  final String diagnosis;
  final String doctorNotes;
  final String mhrsId;

  const PrescriptionData({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.prescriptionDate,
    required this.medications,
    required this.diagnosis,
    required this.doctorNotes,
    required this.mhrsId,
  });

  factory PrescriptionData.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionDataFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionDataToJson(this);
}

@JsonSerializable()
class MedicationData {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int duration;
  final String instructions;
  final String atcCode;

  const MedicationData({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.atcCode,
  });

  factory MedicationData.fromJson(Map<String, dynamic> json) =>
      _$MedicationDataFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationDataToJson(this);
}

@JsonSerializable()
class SGKIntegration {
  final String id;
  final String hospitalCode;
  final String clinicCode;
  final bool isActive;
  final DateTime lastSync;
  final List<InsuranceData> insuranceData;
  final List<ReimbursementData> reimbursements;
  final String syncStatus;

  const SGKIntegration({
    required this.id,
    required this.hospitalCode,
    required this.clinicCode,
    required this.isActive,
    required this.lastSync,
    required this.insuranceData,
    required this.reimbursements,
    required this.syncStatus,
  });

  factory SGKIntegration.fromJson(Map<String, dynamic> json) =>
      _$SGKIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$SGKIntegrationToJson(this);
}

@JsonSerializable()
class InsuranceData {
  final String id;
  final String patientId;
  final String insuranceType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final List<String> coveredServices;
  final double coveragePercentage;

  const InsuranceData({
    required this.id,
    required this.patientId,
    required this.insuranceType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.coveredServices,
    required this.coveragePercentage,
  });

  factory InsuranceData.fromJson(Map<String, dynamic> json) =>
      _$InsuranceDataFromJson(json);

  Map<String, dynamic> toJson() => _$InsuranceDataToJson(this);
}

@JsonSerializable()
class ReimbursementData {
  final String id;
  final String patientId;
  final String serviceType;
  final DateTime serviceDate;
  final double cost;
  final double reimbursedAmount;
  final String status;
  final DateTime reimbursementDate;

  const ReimbursementData({
    required this.id,
    required this.patientId,
    required this.serviceType,
    required this.serviceDate,
    required this.cost,
    required this.reimbursedAmount,
    required this.status,
    required this.reimbursementDate,
  });

  factory ReimbursementData.fromJson(Map<String, dynamic> json) =>
      _$ReimbursementDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReimbursementDataToJson(this);
}

// Enums
enum ModuleType {
  mhrs,
  sgk,
  eNabiz,
  eRecete,
  eTahlil,
  eRapor,
  eKurum,
  eDoktor,
}

enum IntegrationType {
  mhrs,
  sgk,
  eNabiz,
  eRecete,
  eTahlil,
  eRapor,
  eKurum,
  eDoktor,
  custom,
}

enum IntegrationState {
  active,
  inactive,
  error,
  syncing,
  disabled,
}

enum ComplianceType {
  sağlıkBakanlığı,
  sgk,
  tıbbiDeontoloji,
  veriGüvenliği,
  hastaHakları,
  ilaçGüvenliği,
  enfeksiyonKontrolü,
}

enum ComplianceStatus {
  compliant,
  nonCompliant,
  partiallyCompliant,
  underReview,
  pending,
}

enum ReportType {
  sağlıkBakanlığı,
  sgk,
  hastane,
  klinik,
  doktor,
  hasta,
  ilaç,
  enfeksiyon,
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled,
  noShow,
  rescheduled,
}
