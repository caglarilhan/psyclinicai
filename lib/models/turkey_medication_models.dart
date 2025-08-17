import 'package:json_annotation/json_annotation.dart';

part 'turkey_medication_models.g.dart';

@JsonSerializable()
class TurkeyMedicationDatabase {
  final String id;
  final String medicationName;
  final String genericName;
  final String brandName;
  final String atcCode;
  final String atcName;
  final String activeIngredient;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> dosageForms;
  final List<DosageInfo> dosages;
  final List<String> manufacturers;
  final String prescriptionType;
  final bool isReimbursed;
  final double reimbursementRate;
  final String reimbursementCondition;
  final DateTime lastUpdated;
  final String source;

  const TurkeyMedicationDatabase({
    required this.id,
    required this.medicationName,
    required this.genericName,
    required this.brandName,
    required this.atcCode,
    required this.atcName,
    required this.activeIngredient,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.dosageForms,
    required this.dosages,
    required this.manufacturers,
    required this.prescriptionType,
    required this.isReimbursed,
    required this.reimbursementRate,
    required this.reimbursementCondition,
    required this.lastUpdated,
    required this.source,
  });

  factory TurkeyMedicationDatabase.fromJson(Map<String, dynamic> json) =>
      _$TurkeyMedicationDatabaseFromJson(json);

  Map<String, dynamic> toJson() => _$TurkeyMedicationDatabaseToJson(this);
}

@JsonSerializable()
class DosageInfo {
  final String id;
  final String ageGroup;
  final String condition;
  final String dosage;
  final String frequency;
  final int duration;
  final String route;
  final String specialInstructions;
  final List<String> warnings;

  const DosageInfo({
    required this.id,
    required this.ageGroup,
    required this.condition,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.route,
    required this.specialInstructions,
    required this.warnings,
  });

  factory DosageInfo.fromJson(Map<String, dynamic> json) =>
      _$DosageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DosageInfoToJson(this);
}

@JsonSerializable()
class TurkeyPrescription {
  final String id;
  final String patientId;
  final String patientName;
  final String tcKimlikNo;
  final String doctorId;
  final String doctorName;
  final String doctorTitle;
  final String hospitalCode;
  final String clinicCode;
  final DateTime prescriptionDate;
  final DateTime expiryDate;
  final List<PrescriptionMedication> medications;
  final String diagnosis;
  final String diagnosisCode;
  final String notes;
  final String prescriptionType;
  final bool isUrgent;
  final bool isReimbursed;
  final String reimbursementStatus;
  final String mhrsId;
  final String eReceteId;
  final PrescriptionStatus status;

  const TurkeyPrescription({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.tcKimlikNo,
    required this.doctorId,
    required this.doctorName,
    required this.doctorTitle,
    required this.hospitalCode,
    required this.clinicCode,
    required this.prescriptionDate,
    required this.expiryDate,
    required this.medications,
    required this.diagnosis,
    required this.diagnosisCode,
    required this.notes,
    required this.prescriptionType,
    required this.isUrgent,
    required this.isReimbursed,
    required this.reimbursementStatus,
    required this.mhrsId,
    required this.eReceteId,
    required this.status,
  });

  factory TurkeyPrescription.fromJson(Map<String, dynamic> json) =>
      _$TurkeyPrescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$TurkeyPrescriptionToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get hasReimbursedMedications => medications.any((m) => m.isReimbursed);
}

@JsonSerializable()
class PrescriptionMedication {
  final String id;
  final String medicationId;
  final String medicationName;
  final String genericName;
  final String atcCode;
  final String dosage;
  final String frequency;
  final int duration;
  final String route;
  final String instructions;
  final int quantity;
  final String unit;
  final bool isReimbursed;
  final double reimbursementRate;
  final String reimbursementCondition;
  final List<String> warnings;
  final List<String> contraindications;

  const PrescriptionMedication({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.genericName,
    required this.atcCode,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.route,
    required this.instructions,
    required this.quantity,
    required this.unit,
    required this.isReimbursed,
    required this.reimbursementRate,
    required this.reimbursementCondition,
    required this.warnings,
    required this.contraindications,
  });

  factory PrescriptionMedication.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionMedicationToJson(this);
}

@JsonSerializable()
class DrugInteraction {
  final String id;
  final String medication1;
  final String medication2;
  final InteractionSeverity severity;
  final String description;
  final String mechanism;
  final List<String> symptoms;
  final List<String> recommendations;
  final String evidence;
  final DateTime lastUpdated;

  const DrugInteraction({
    required this.id,
    required this.medication1,
    required this.medication2,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.symptoms,
    required this.recommendations,
    required this.evidence,
    required this.lastUpdated,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$DrugInteractionToJson(this);
}

@JsonSerializable()
class MedicationAllergy {
  final String id;
  final String patientId;
  final String medicationName;
  final String activeIngredient;
  final AllergySeverity severity;
  final List<String> symptoms;
  final DateTime onsetDate;
  final String reactionType;
  final List<String> alternativeMedications;
  final String notes;

  const MedicationAllergy({
    required this.id,
    required this.patientId,
    required this.medicationName,
    required this.activeIngredient,
    required this.severity,
    required this.symptoms,
    required this.onsetDate,
    required this.reactionType,
    required this.alternativeMedications,
    required this.notes,
  });

  factory MedicationAllergy.fromJson(Map<String, dynamic> json) =>
      _$MedicationAllergyFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationAllergyToJson(this);
}

@JsonSerializable()
class EReceteIntegration {
  final String id;
  final String prescriptionId;
  final String eReceteId;
  final bool isActive;
  final DateTime lastSync;
  final String syncStatus;
  final List<String> errors;
  final Map<String, dynamic> metadata;

  const EReceteIntegration({
    required this.id,
    required this.prescriptionId,
    required this.eReceteId,
    required this.isActive,
    required this.lastSync,
    required this.syncStatus,
    required this.errors,
    required this.metadata,
  });

  factory EReceteIntegration.fromJson(Map<String, dynamic> json) =>
      _$EReceteIntegrationFromJson(json);

  Map<String, dynamic> toJson() => _$EReceteIntegrationToJson(this);
}

@JsonSerializable()
class MedicationReimbursement {
  final String id;
  final String medicationId;
  final String medicationName;
  final bool isReimbursed;
  final double reimbursementRate;
  final String reimbursementCondition;
  final List<String> requiredDocuments;
  final List<String> restrictions;
  final DateTime effectiveDate;
  final DateTime? expiryDate;
  final String status;

  const MedicationReimbursement({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.isReimbursed,
    required this.reimbursementRate,
    required this.reimbursementCondition,
    required this.requiredDocuments,
    required this.restrictions,
    required this.effectiveDate,
    this.expiryDate,
    required this.status,
  });

  factory MedicationReimbursement.fromJson(Map<String, dynamic> json) =>
      _$MedicationReimbursementFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationReimbursementToJson(this);
}

@JsonSerializable()
class PrescriptionTemplate {
  final String id;
  final String name;
  final String description;
  final String specialty;
  final List<String> commonDiagnoses;
  final List<TemplateMedication> medications;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastModified;

  const PrescriptionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.specialty,
    required this.commonDiagnoses,
    required this.medications,
    required this.notes,
    required this.isActive,
    required this.createdAt,
    required this.lastModified,
  });

  factory PrescriptionTemplate.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionTemplateToJson(this);
}

@JsonSerializable()
class TemplateMedication {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final int duration;
  final String instructions;
  final bool isOptional;

  const TemplateMedication({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.isOptional,
  });

  factory TemplateMedication.fromJson(Map<String, dynamic> json) =>
      _$TemplateMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateMedicationToJson(this);
}

// Enums
enum InteractionSeverity {
  minor,
  moderate,
  major,
  contraindicated,
}

enum AllergySeverity {
  mild,
  moderate,
  severe,
  lifeThreatening,
}

enum PrescriptionStatus {
  active,
  expired,
  cancelled,
  completed,
  suspended,
}

enum PrescriptionType {
  regular,
  urgent,
  controlled,
  narcotic,
  psychotropic,
}
