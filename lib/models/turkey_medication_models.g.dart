// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'turkey_medication_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TurkeyMedicationDatabase _$TurkeyMedicationDatabaseFromJson(
  Map<String, dynamic> json,
) => TurkeyMedicationDatabase(
  id: json['id'] as String,
  medicationName: json['medicationName'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  atcCode: json['atcCode'] as String,
  atcName: json['atcName'] as String,
  activeIngredient: json['activeIngredient'] as String,
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  interactions: (json['interactions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosageForms: (json['dosageForms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosages: (json['dosages'] as List<dynamic>)
      .map((e) => DosageInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  manufacturers: (json['manufacturers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  prescriptionType: json['prescriptionType'] as String,
  isReimbursed: json['isReimbursed'] as bool,
  reimbursementRate: (json['reimbursementRate'] as num).toDouble(),
  reimbursementCondition: json['reimbursementCondition'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  source: json['source'] as String,
);

Map<String, dynamic> _$TurkeyMedicationDatabaseToJson(
  TurkeyMedicationDatabase instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationName': instance.medicationName,
  'genericName': instance.genericName,
  'brandName': instance.brandName,
  'atcCode': instance.atcCode,
  'atcName': instance.atcName,
  'activeIngredient': instance.activeIngredient,
  'indications': instance.indications,
  'contraindications': instance.contraindications,
  'sideEffects': instance.sideEffects,
  'interactions': instance.interactions,
  'dosageForms': instance.dosageForms,
  'dosages': instance.dosages,
  'manufacturers': instance.manufacturers,
  'prescriptionType': instance.prescriptionType,
  'isReimbursed': instance.isReimbursed,
  'reimbursementRate': instance.reimbursementRate,
  'reimbursementCondition': instance.reimbursementCondition,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'source': instance.source,
};

DosageInfo _$DosageInfoFromJson(Map<String, dynamic> json) => DosageInfo(
  id: json['id'] as String,
  ageGroup: json['ageGroup'] as String,
  condition: json['condition'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  duration: (json['duration'] as num).toInt(),
  route: json['route'] as String,
  specialInstructions: json['specialInstructions'] as String,
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$DosageInfoToJson(DosageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ageGroup': instance.ageGroup,
      'condition': instance.condition,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'route': instance.route,
      'specialInstructions': instance.specialInstructions,
      'warnings': instance.warnings,
    };

TurkeyPrescription _$TurkeyPrescriptionFromJson(Map<String, dynamic> json) =>
    TurkeyPrescription(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      tcKimlikNo: json['tcKimlikNo'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorTitle: json['doctorTitle'] as String,
      hospitalCode: json['hospitalCode'] as String,
      clinicCode: json['clinicCode'] as String,
      prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      medications: (json['medications'] as List<dynamic>)
          .map(
            (e) => PrescriptionMedication.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      diagnosis: json['diagnosis'] as String,
      diagnosisCode: json['diagnosisCode'] as String,
      notes: json['notes'] as String,
      prescriptionType: json['prescriptionType'] as String,
      isUrgent: json['isUrgent'] as bool,
      isReimbursed: json['isReimbursed'] as bool,
      reimbursementStatus: json['reimbursementStatus'] as String,
      mhrsId: json['mhrsId'] as String,
      eReceteId: json['eReceteId'] as String,
      status: $enumDecode(_$PrescriptionStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$TurkeyPrescriptionToJson(TurkeyPrescription instance) =>
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
      'prescriptionDate': instance.prescriptionDate.toIso8601String(),
      'expiryDate': instance.expiryDate.toIso8601String(),
      'medications': instance.medications,
      'diagnosis': instance.diagnosis,
      'diagnosisCode': instance.diagnosisCode,
      'notes': instance.notes,
      'prescriptionType': instance.prescriptionType,
      'isUrgent': instance.isUrgent,
      'isReimbursed': instance.isReimbursed,
      'reimbursementStatus': instance.reimbursementStatus,
      'mhrsId': instance.mhrsId,
      'eReceteId': instance.eReceteId,
      'status': _$PrescriptionStatusEnumMap[instance.status]!,
    };

const _$PrescriptionStatusEnumMap = {
  PrescriptionStatus.active: 'active',
  PrescriptionStatus.expired: 'expired',
  PrescriptionStatus.cancelled: 'cancelled',
  PrescriptionStatus.completed: 'completed',
  PrescriptionStatus.suspended: 'suspended',
};

PrescriptionMedication _$PrescriptionMedicationFromJson(
  Map<String, dynamic> json,
) => PrescriptionMedication(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  genericName: json['genericName'] as String,
  atcCode: json['atcCode'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  duration: (json['duration'] as num).toInt(),
  route: json['route'] as String,
  instructions: json['instructions'] as String,
  quantity: (json['quantity'] as num).toInt(),
  unit: json['unit'] as String,
  isReimbursed: json['isReimbursed'] as bool,
  reimbursementRate: (json['reimbursementRate'] as num).toDouble(),
  reimbursementCondition: json['reimbursementCondition'] as String,
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PrescriptionMedicationToJson(
  PrescriptionMedication instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'genericName': instance.genericName,
  'atcCode': instance.atcCode,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'duration': instance.duration,
  'route': instance.route,
  'instructions': instance.instructions,
  'quantity': instance.quantity,
  'unit': instance.unit,
  'isReimbursed': instance.isReimbursed,
  'reimbursementRate': instance.reimbursementRate,
  'reimbursementCondition': instance.reimbursementCondition,
  'warnings': instance.warnings,
  'contraindications': instance.contraindications,
};

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) =>
    DrugInteraction(
      id: json['id'] as String,
      medication1: json['medication1'] as String,
      medication2: json['medication2'] as String,
      severity: $enumDecode(_$InteractionSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      mechanism: json['mechanism'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evidence: json['evidence'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$DrugInteractionToJson(DrugInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medication1': instance.medication1,
      'medication2': instance.medication2,
      'severity': _$InteractionSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'mechanism': instance.mechanism,
      'symptoms': instance.symptoms,
      'recommendations': instance.recommendations,
      'evidence': instance.evidence,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$InteractionSeverityEnumMap = {
  InteractionSeverity.minor: 'minor',
  InteractionSeverity.moderate: 'moderate',
  InteractionSeverity.major: 'major',
  InteractionSeverity.contraindicated: 'contraindicated',
};

MedicationAllergy _$MedicationAllergyFromJson(Map<String, dynamic> json) =>
    MedicationAllergy(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationName: json['medicationName'] as String,
      activeIngredient: json['activeIngredient'] as String,
      severity: $enumDecode(_$AllergySeverityEnumMap, json['severity']),
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      onsetDate: DateTime.parse(json['onsetDate'] as String),
      reactionType: json['reactionType'] as String,
      alternativeMedications: (json['alternativeMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$MedicationAllergyToJson(MedicationAllergy instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'medicationName': instance.medicationName,
      'activeIngredient': instance.activeIngredient,
      'severity': _$AllergySeverityEnumMap[instance.severity]!,
      'symptoms': instance.symptoms,
      'onsetDate': instance.onsetDate.toIso8601String(),
      'reactionType': instance.reactionType,
      'alternativeMedications': instance.alternativeMedications,
      'notes': instance.notes,
    };

const _$AllergySeverityEnumMap = {
  AllergySeverity.mild: 'mild',
  AllergySeverity.moderate: 'moderate',
  AllergySeverity.severe: 'severe',
  AllergySeverity.lifeThreatening: 'lifeThreatening',
};

EReceteIntegration _$EReceteIntegrationFromJson(Map<String, dynamic> json) =>
    EReceteIntegration(
      id: json['id'] as String,
      prescriptionId: json['prescriptionId'] as String,
      eReceteId: json['eReceteId'] as String,
      isActive: json['isActive'] as bool,
      lastSync: DateTime.parse(json['lastSync'] as String),
      syncStatus: json['syncStatus'] as String,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EReceteIntegrationToJson(EReceteIntegration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'prescriptionId': instance.prescriptionId,
      'eReceteId': instance.eReceteId,
      'isActive': instance.isActive,
      'lastSync': instance.lastSync.toIso8601String(),
      'syncStatus': instance.syncStatus,
      'errors': instance.errors,
      'metadata': instance.metadata,
    };

MedicationReimbursement _$MedicationReimbursementFromJson(
  Map<String, dynamic> json,
) => MedicationReimbursement(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  isReimbursed: json['isReimbursed'] as bool,
  reimbursementRate: (json['reimbursementRate'] as num).toDouble(),
  reimbursementCondition: json['reimbursementCondition'] as String,
  requiredDocuments: (json['requiredDocuments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  restrictions: (json['restrictions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$MedicationReimbursementToJson(
  MedicationReimbursement instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'isReimbursed': instance.isReimbursed,
  'reimbursementRate': instance.reimbursementRate,
  'reimbursementCondition': instance.reimbursementCondition,
  'requiredDocuments': instance.requiredDocuments,
  'restrictions': instance.restrictions,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'expiryDate': instance.expiryDate?.toIso8601String(),
  'status': instance.status,
};

PrescriptionTemplate _$PrescriptionTemplateFromJson(
  Map<String, dynamic> json,
) => PrescriptionTemplate(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  specialty: json['specialty'] as String,
  commonDiagnoses: (json['commonDiagnoses'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => TemplateMedication.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastModified: DateTime.parse(json['lastModified'] as String),
);

Map<String, dynamic> _$PrescriptionTemplateToJson(
  PrescriptionTemplate instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'specialty': instance.specialty,
  'commonDiagnoses': instance.commonDiagnoses,
  'medications': instance.medications,
  'notes': instance.notes,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastModified': instance.lastModified.toIso8601String(),
};

TemplateMedication _$TemplateMedicationFromJson(Map<String, dynamic> json) =>
    TemplateMedication(
      id: json['id'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: (json['duration'] as num).toInt(),
      instructions: json['instructions'] as String,
      isOptional: json['isOptional'] as bool,
    );

Map<String, dynamic> _$TemplateMedicationToJson(TemplateMedication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationName': instance.medicationName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'instructions': instance.instructions,
      'isOptional': instance.isOptional,
    };
