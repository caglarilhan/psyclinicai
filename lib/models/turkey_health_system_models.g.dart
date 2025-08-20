// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turkey_health_system_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurkeyHealthSystemIntegration _$TurkeyHealthSystemIntegrationFromJson(
  Map<String, dynamic> json,
) => TurkeyHealthSystemIntegration(
  id: json['id'] as String,
  organizationId: json['organizationId'] as String,
  hospitalCode: json['hospitalCode'] as String,
  clinicCode: json['clinicCode'] as String,
  doctorCode: json['doctorCode'] as String,
  activeModules: (json['activeModules'] as List<dynamic>)
      .map((e) => HealthSystemModule.fromJson(e as Map<String, dynamic>))
      .toList(),
  integrations: (json['integrations'] as List<dynamic>)
      .map((e) => IntegrationStatus.fromJson(e as Map<String, dynamic>))
      .toList(),
  complianceRequirements: (json['complianceRequirements'] as List<dynamic>)
      .map((e) => ComplianceRequirement.fromJson(e as Map<String, dynamic>))
      .toList(),
  reportingRequirements: (json['reportingRequirements'] as List<dynamic>)
      .map((e) => ReportingRequirement.fromJson(e as Map<String, dynamic>))
      .toList(),
  configuration: json['configuration'] as Map<String, dynamic>,
);

Map<String, dynamic> _$TurkeyHealthSystemIntegrationToJson(
  TurkeyHealthSystemIntegration instance,
) => <String, dynamic>{
  'id': instance.id,
  'organizationId': instance.organizationId,
  'hospitalCode': instance.hospitalCode,
  'clinicCode': instance.clinicCode,
  'doctorCode': instance.doctorCode,
  'activeModules': instance.activeModules,
  'integrations': instance.integrations,
  'complianceRequirements': instance.complianceRequirements,
  'reportingRequirements': instance.reportingRequirements,
  'configuration': instance.configuration,
};

HealthSystemModule _$HealthSystemModuleFromJson(Map<String, dynamic> json) =>
    HealthSystemModule(
      id: json['id'] as String,
      type: $enumDecode(_$ModuleTypeEnumMap, json['type']),
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      version: json['version'] as String,
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      settings: json['settings'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$HealthSystemModuleToJson(HealthSystemModule instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ModuleTypeEnumMap[instance.type]!,
      'name': instance.name,
      'description': instance.description,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'version': instance.version,
      'features': instance.features,
      'settings': instance.settings,
    };

const _$ModuleTypeEnumMap = {
  ModuleType.mhrs: 'mhrs',
  ModuleType.sgk: 'sgk',
  ModuleType.eNabiz: 'eNabiz',
  ModuleType.eRecete: 'eRecete',
  ModuleType.eTahlil: 'eTahlil',
  ModuleType.eRapor: 'eRapor',
  ModuleType.eKurum: 'eKurum',
  ModuleType.eDoktor: 'eDoktor',
};

IntegrationStatus _$IntegrationStatusFromJson(Map<String, dynamic> json) =>
    IntegrationStatus(
      id: json['id'] as String,
      type: $enumDecode(_$IntegrationTypeEnumMap, json['type']),
      name: json['name'] as String,
      state: $enumDecode(_$IntegrationStateEnumMap, json['state']),
      lastSync: DateTime.parse(json['lastSync'] as String),
      lastError: json['lastError'] as String,
      syncFrequency: (json['syncFrequency'] as num).toInt(),
      isEnabled: json['isEnabled'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$IntegrationStatusToJson(IntegrationStatus instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$IntegrationTypeEnumMap[instance.type]!,
      'name': instance.name,
      'state': _$IntegrationStateEnumMap[instance.state]!,
      'lastSync': instance.lastSync.toIso8601String(),
      'lastError': instance.lastError,
      'syncFrequency': instance.syncFrequency,
      'isEnabled': instance.isEnabled,
      'metadata': instance.metadata,
    };

const _$IntegrationTypeEnumMap = {
  IntegrationType.mhrs: 'mhrs',
  IntegrationType.sgk: 'sgk',
  IntegrationType.eNabiz: 'eNabiz',
  IntegrationType.eRecete: 'eRecete',
  IntegrationType.eTahlil: 'eTahlil',
  IntegrationType.eRapor: 'eRapor',
  IntegrationType.eKurum: 'eKurum',
  IntegrationType.eDoktor: 'eDoktor',
  IntegrationType.custom: 'custom',
};

const _$IntegrationStateEnumMap = {
  IntegrationState.active: 'active',
  IntegrationState.inactive: 'inactive',
  IntegrationState.error: 'error',
  IntegrationState.syncing: 'syncing',
  IntegrationState.disabled: 'disabled',
};

ComplianceRequirement _$ComplianceRequirementFromJson(
  Map<String, dynamic> json,
) => ComplianceRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ComplianceTypeEnumMap, json['type']),
  regulation: json['regulation'] as String,
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  expiryDate: DateTime.parse(json['expiryDate'] as String),
  status: $enumDecode(_$ComplianceStatusEnumMap, json['status']),
  requirements: (json['requirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  evidence: (json['evidence'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  responsiblePerson: json['responsiblePerson'] as String,
);

Map<String, dynamic> _$ComplianceRequirementToJson(
  ComplianceRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$ComplianceTypeEnumMap[instance.type]!,
  'regulation': instance.regulation,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'expiryDate': instance.expiryDate.toIso8601String(),
  'status': _$ComplianceStatusEnumMap[instance.status]!,
  'requirements': instance.requirements,
  'evidence': instance.evidence,
  'responsiblePerson': instance.responsiblePerson,
};

const _$ComplianceTypeEnumMap = {
  ComplianceType.saglikBakanligi: 'saglikBakanligi',
  ComplianceType.sgk: 'sgk',
  ComplianceType.tibbiDeontoloji: 'tibbiDeontoloji',
  ComplianceType.veriGuvenligi: 'veriGuvenligi',
  ComplianceType.hastaHaklari: 'hastaHaklari',
  ComplianceType.ilacGuvenligi: 'ilacGuvenligi',
  ComplianceType.enfeksiyonKontrolu: 'enfeksiyonKontrolu',
};

const _$ComplianceStatusEnumMap = {
  ComplianceStatus.compliant: 'compliant',
  ComplianceStatus.nonCompliant: 'nonCompliant',
  ComplianceStatus.partiallyCompliant: 'partiallyCompliant',
  ComplianceStatus.underReview: 'underReview',
  ComplianceStatus.pending: 'pending',
};

ReportingRequirement _$ReportingRequirementFromJson(
  Map<String, dynamic> json,
) => ReportingRequirement(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  type: $enumDecode(_$ReportTypeEnumMap, json['type']),
  frequency: json['frequency'] as String,
  nextDueDate: DateTime.parse(json['nextDueDate'] as String),
  format: json['format'] as String,
  recipients: (json['recipients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isMandatory: json['isMandatory'] as bool,
  template: json['template'] as String,
  dataRequirements: json['dataRequirements'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ReportingRequirementToJson(
  ReportingRequirement instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'type': _$ReportTypeEnumMap[instance.type]!,
  'frequency': instance.frequency,
  'nextDueDate': instance.nextDueDate.toIso8601String(),
  'format': instance.format,
  'recipients': instance.recipients,
  'isMandatory': instance.isMandatory,
  'template': instance.template,
  'dataRequirements': instance.dataRequirements,
};

const _$ReportTypeEnumMap = {
  ReportType.saglikBakanligi: 'saglikBakanligi',
  ReportType.sgk: 'sgk',
  ReportType.hastane: 'hastane',
  ReportType.klinik: 'klinik',
  ReportType.doktor: 'doktor',
  ReportType.hasta: 'hasta',
  ReportType.ilac: 'ilac',
  ReportType.enfeksiyon: 'enfeksiyon',
};

MHRSIntegration _$MHRSIntegrationFromJson(Map<String, dynamic> json) =>
    MHRSIntegration(
      id: json['id'] as String,
      hospitalCode: json['hospitalCode'] as String,
      clinicCode: json['clinicCode'] as String,
      doctorCode: json['doctorCode'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      appointments: (json['appointments'] as List<dynamic>)
          .map((e) => AppointmentData.fromJson(e as Map<String, dynamic>))
          .toList(),
      patients: (json['patients'] as List<dynamic>)
          .map((e) => PatientData.fromJson(e as Map<String, dynamic>))
          .toList(),
      prescriptions: (json['prescriptions'] as List<dynamic>)
          .map((e) => PrescriptionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      syncStatus: json['syncStatus'] as String,
    );

Map<String, dynamic> _$MHRSIntegrationToJson(MHRSIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hospitalCode': instance.hospitalCode,
      'clinicCode': instance.clinicCode,
      'doctorCode': instance.doctorCode,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'appointments': instance.appointments,
      'patients': instance.patients,
      'prescriptions': instance.prescriptions,
      'syncStatus': instance.syncStatus,
    };

AppointmentData _$AppointmentDataFromJson(Map<String, dynamic> json) =>
    AppointmentData(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      status: $enumDecode(_$AppointmentStatusEnumMap, json['status']),
      notes: json['notes'] as String,
      mhrsId: json['mhrsId'] as String,
    );

Map<String, dynamic> _$AppointmentDataToJson(AppointmentData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'appointmentTime': instance.appointmentTime,
      'status': _$AppointmentStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'mhrsId': instance.mhrsId,
    };

const _$AppointmentStatusEnumMap = {
  AppointmentStatus.scheduled: 'scheduled',
  AppointmentStatus.confirmed: 'confirmed',
  AppointmentStatus.completed: 'completed',
  AppointmentStatus.cancelled: 'cancelled',
  AppointmentStatus.noShow: 'noShow',
  AppointmentStatus.rescheduled: 'rescheduled',
};

PatientData _$PatientDataFromJson(Map<String, dynamic> json) => PatientData(
  id: json['id'] as String,
  tcKimlikNo: json['tcKimlikNo'] as String,
  name: json['name'] as String,
  surname: json['surname'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  gender: json['gender'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  insuranceType: json['insuranceType'] as String,
  mhrsId: json['mhrsId'] as String,
);

Map<String, dynamic> _$PatientDataToJson(PatientData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tcKimlikNo': instance.tcKimlikNo,
      'name': instance.name,
      'surname': instance.surname,
      'birthDate': instance.birthDate.toIso8601String(),
      'gender': instance.gender,
      'phone': instance.phone,
      'address': instance.address,
      'insuranceType': instance.insuranceType,
      'mhrsId': instance.mhrsId,
    };

PrescriptionData _$PrescriptionDataFromJson(Map<String, dynamic> json) =>
    PrescriptionData(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
      medications: (json['medications'] as List<dynamic>)
          .map((e) => MedicationData.fromJson(e as Map<String, dynamic>))
          .toList(),
      diagnosis: json['diagnosis'] as String,
      doctorNotes: json['doctorNotes'] as String,
      mhrsId: json['mhrsId'] as String,
    );

Map<String, dynamic> _$PrescriptionDataToJson(PrescriptionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'patientName': instance.patientName,
      'prescriptionDate': instance.prescriptionDate.toIso8601String(),
      'medications': instance.medications,
      'diagnosis': instance.diagnosis,
      'doctorNotes': instance.doctorNotes,
      'mhrsId': instance.mhrsId,
    };

MedicationData _$MedicationDataFromJson(Map<String, dynamic> json) =>
    MedicationData(
      id: json['id'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: (json['duration'] as num).toInt(),
      instructions: json['instructions'] as String,
      atcCode: json['atcCode'] as String,
    );

Map<String, dynamic> _$MedicationDataToJson(MedicationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationName': instance.medicationName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'instructions': instance.instructions,
      'atcCode': instance.atcCode,
    };

SGKIntegration _$SGKIntegrationFromJson(Map<String, dynamic> json) =>
    SGKIntegration(
      id: json['id'] as String,
      hospitalCode: json['hospitalCode'] as String,
      clinicCode: json['clinicCode'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      insuranceData: (json['insuranceData'] as List<dynamic>)
          .map((e) => InsuranceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      reimbursements: (json['reimbursements'] as List<dynamic>)
          .map((e) => ReimbursementData.fromJson(e as Map<String, dynamic>))
          .toList(),
      syncStatus: json['syncStatus'] as String,
    );

Map<String, dynamic> _$SGKIntegrationToJson(SGKIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'hospitalCode': instance.hospitalCode,
      'clinicCode': instance.clinicCode,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'insuranceData': instance.insuranceData,
      'reimbursements': instance.reimbursements,
      'syncStatus': instance.syncStatus,
    };

InsuranceData _$InsuranceDataFromJson(Map<String, dynamic> json) =>
    InsuranceData(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      insuranceType: json['insuranceType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      coveredServices: (json['coveredServices'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      coveragePercentage: (json['coveragePercentage'] as num).toDouble(),
    );

Map<String, dynamic> _$InsuranceDataToJson(InsuranceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'insuranceType': instance.insuranceType,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'coveredServices': instance.coveredServices,
      'coveragePercentage': instance.coveragePercentage,
    };

ReimbursementData _$ReimbursementDataFromJson(Map<String, dynamic> json) =>
    ReimbursementData(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      serviceType: json['serviceType'] as String,
      serviceDate: DateTime.parse(json['serviceDate'] as String),
      cost: (json['cost'] as num).toDouble(),
      reimbursedAmount: (json['reimbursedAmount'] as num).toDouble(),
      status: json['status'] as String,
      reimbursementDate: DateTime.parse(json['reimbursementDate'] as String),
    );

Map<String, dynamic> _$ReimbursementDataToJson(ReimbursementData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'serviceType': instance.serviceType,
      'serviceDate': instance.serviceDate.toIso8601String(),
      'cost': instance.cost,
      'reimbursedAmount': instance.reimbursedAmount,
      'status': instance.status,
      'reimbursementDate': instance.reimbursementDate.toIso8601String(),
    };
