import 'package:json_annotation/json_annotation.dart';

part 'medication_models.g.dart';

@JsonSerializable()
class Medication {
  final String id;
  final String name;
  final String genericName;
  final String brandName;
  final String atcCode;
  final String rxNormCode;
  final String dinCode;
  final String barcode;
  final MedicationClass medicationClass;
  final List<String> activeIngredients;
  final List<String> inactiveIngredients;
  final String dosageForm;
  final List<String> strengths;
  final String manufacturer;
  final String country;
  final bool isControlled;
  final bool requiresPrescription;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> warnings;
  final List<String> precautions;
  final List<String> drugInteractions;
  final List<String> foodInteractions;
  final List<String> labInteractions;
  final List<String> monitoringRequirements;
  final List<String> pregnancyCategory;
  final List<String> breastfeedingCategory;
  final List<String> pediatricUse;
  final List<String> geriatricUse;
  final List<String> renalAdjustment;
  final List<String> hepaticAdjustment;
  final Map<String, dynamic> metadata;
  final bool isActive;
  final DateTime lastUpdated;

  const Medication({
    required this.id,
    required this.name,
    required this.genericName,
    required this.brandName,
    required this.atcCode,
    required this.rxNormCode,
    required this.dinCode,
    required this.barcode,
    required this.medicationClass,
    required this.activeIngredients,
    required this.inactiveIngredients,
    required this.dosageForm,
    required this.strengths,
    required this.manufacturer,
    required this.country,
    required this.isControlled,
    required this.requiresPrescription,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.warnings,
    required this.precautions,
    required this.drugInteractions,
    required this.foodInteractions,
    required this.labInteractions,
    required this.monitoringRequirements,
    required this.pregnancyCategory,
    required this.breastfeedingCategory,
    required this.pediatricUse,
    required this.geriatricUse,
    required this.renalAdjustment,
    required this.hepaticAdjustment,
    this.metadata = const {},
    required this.isActive,
    required this.lastUpdated,
  });

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationToJson(this);
}

@JsonSerializable()
class Prescription {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime prescriptionDate;
  final DateTime? expiryDate;
  final PrescriptionStatus status;
  final List<PrescribedMedication> medications;
  final String diagnosis;
  final String clinicalNotes;
  final List<String> allergies;
  final List<String> contraindications;
  final List<String> warnings;
  final List<String> instructions;
  final int refillsAllowed;
  final int refillsUsed;
  final String pharmacy;
  final String prescriberSignature;
  final bool isElectronic;
  final String prescriptionNumber;
  final Map<String, dynamic> metadata;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.prescriptionDate,
    this.expiryDate,
    required this.status,
    required this.medications,
    required this.diagnosis,
    required this.clinicalNotes,
    required this.allergies,
    required this.contraindications,
    required this.warnings,
    required this.instructions,
    required this.refillsAllowed,
    required this.refillsUsed,
    required this.pharmacy,
    required this.prescriberSignature,
    required this.isElectronic,
    required this.prescriptionNumber,
    this.metadata = const {},
  });

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionToJson(this);
}

@JsonSerializable()
class PrescribedMedication {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String route;
  final String duration;
  final String instructions;
  final int quantity;
  final String strength;
  final List<String> specialInstructions;
  final List<String> sideEffects;
  final List<String> warnings;
  final bool requiresMonitoring;
  final List<String> monitoringTests;
  final List<String> followUpSchedule;
  final Map<String, dynamic> metadata;

  const PrescribedMedication({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.duration,
    required this.instructions,
    required this.quantity,
    required this.strength,
    required this.specialInstructions,
    required this.sideEffects,
    required this.warnings,
    required this.requiresMonitoring,
    required this.monitoringTests,
    required this.followUpSchedule,
    this.metadata = const {},
  });

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) =>
      _$PrescribedMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$PrescribedMedicationToJson(this);
}

@JsonSerializable()
class DrugInteraction {
  final String id;
  final String medication1Id;
  final String medication1Name;
  final String medication2Id;
  final String medication2Name;
  final InteractionSeverity severity;
  final InteractionType type;
  final String mechanism;
  final String description;
  final String clinicalSignificance;
  final List<String> symptoms;
  final List<String> recommendations;
  final List<String> alternatives;
  final List<String> monitoring;
  final String evidence;
  final String source;
  final Map<String, dynamic> metadata;

  const DrugInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication1Name,
    required this.medication2Id,
    required this.medication2Name,
    required this.severity,
    required this.type,
    required this.mechanism,
    required this.description,
    required this.clinicalSignificance,
    required this.symptoms,
    required this.recommendations,
    required this.alternatives,
    required this.monitoring,
    required this.evidence,
    required this.source,
    this.metadata = const {},
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$DrugInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$DrugInteractionToJson(this);
}

@JsonSerializable()
class DosageTitration {
  final String id;
  final String medicationId;
  final String medicationName;
  final String indication;
  final List<TitrationStep> steps;
  final TitrationStrategy strategy;
  final String rationale;
  final List<String> monitoringParameters;
  final List<String> adverseEffects;
  final List<String> contraindications;
  final String duration;
  final Map<String, dynamic> metadata;

  const DosageTitration({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.indication,
    required this.steps,
    required this.strategy,
    required this.rationale,
    required this.monitoringParameters,
    required this.adverseEffects,
    required this.contraindications,
    required this.duration,
    this.metadata = const {},
  });

  factory DosageTitration.fromJson(Map<String, dynamic> json) =>
      _$DosageTitrationFromJson(json);

  Map<String, dynamic> toJson() => _$DosageTitrationToJson(this);
}

@JsonSerializable()
class TitrationStep {
  final String id;
  final int stepNumber;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;
  final List<String> monitoring;
  final List<String> sideEffects;
  final List<String> warnings;
  final bool requiresAdjustment;
  final String adjustmentCriteria;
  final Map<String, dynamic> metadata;

  const TitrationStep({
    required this.id,
    required this.stepNumber,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    required this.monitoring,
    required this.sideEffects,
    required this.warnings,
    required this.requiresAdjustment,
    required this.adjustmentCriteria,
    this.metadata = const {},
  });

  factory TitrationStep.fromJson(Map<String, dynamic> json) =>
      _$TitrationStepFromJson(json);

  Map<String, dynamic> toJson() => _$TitrationStepToJson(this);
}

@JsonSerializable()
class MedicationAdherence {
  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final DateTime startDate;
  final DateTime? endDate;
  final AdherenceStatus status;
  final double adherenceRate;
  final List<AdherenceEvent> events;
  final List<String> barriers;
  final List<String> facilitators;
  final List<String> interventions;
  final String notes;
  final Map<String, dynamic> metadata;

  const MedicationAdherence({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.adherenceRate,
    required this.events,
    required this.barriers,
    required this.facilitators,
    required this.interventions,
    required this.notes,
    this.metadata = const {},
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) =>
      _$MedicationAdherenceFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationAdherenceToJson(this);

  MedicationAdherence copyWith({
    String? id,
    String? patientId,
    String? medicationId,
    String? medicationName,
    DateTime? startDate,
    DateTime? endDate,
    AdherenceStatus? status,
    double? adherenceRate,
    List<AdherenceEvent>? events,
    List<String>? barriers,
    List<String>? facilitators,
    List<String>? interventions,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return MedicationAdherence(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      events: events ?? this.events,
      barriers: barriers ?? this.barriers,
      facilitators: facilitators ?? this.facilitators,
      interventions: interventions ?? this.interventions,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class AdherenceEvent {
  final String id;
  final DateTime timestamp;
  final AdherenceEventType type;
  final String description;
  final String reason;
  final String action;
  final Map<String, dynamic> metadata;

  const AdherenceEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.reason,
    required this.action,
    this.metadata = const {},
  });

  factory AdherenceEvent.fromJson(Map<String, dynamic> json) =>
      _$AdherenceEventFromJson(json);

  Map<String, dynamic> toJson() => _$AdherenceEventToJson(this);
}

@JsonSerializable()
class SideEffectReport {
  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final DateTime reportDate;
  final String sideEffect;
  final SideEffectSeverity severity;
  final String description;
  final List<String> symptoms;
  final DateTime? onsetDate;
  final DateTime? resolutionDate;
  final String outcome;
  final bool requiredDiscontinuation;
  final bool requiredDoseReduction;
  final String action;
  final String notes;
  final Map<String, dynamic> metadata;

  const SideEffectReport({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.reportDate,
    required this.sideEffect,
    required this.severity,
    required this.description,
    required this.symptoms,
    this.onsetDate,
    this.resolutionDate,
    required this.outcome,
    required this.requiredDiscontinuation,
    required this.requiredDoseReduction,
    required this.action,
    required this.notes,
    this.metadata = const {},
  });

  factory SideEffectReport.fromJson(Map<String, dynamic> json) =>
      _$SideEffectReportFromJson(json);

  Map<String, dynamic> toJson() => _$SideEffectReportToJson(this);
}

@JsonSerializable()
class MedicationReminder {
  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime nextDoseTime;
  final List<DateTime> scheduledTimes;
  final ReminderStatus status;
  final List<String> notificationMethods;
  final bool isActive;
  final String notes;
  final Map<String, dynamic> metadata;

  const MedicationReminder({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.nextDoseTime,
    required this.scheduledTimes,
    required this.status,
    required this.notificationMethods,
    required this.isActive,
    required this.notes,
    this.metadata = const {},
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) =>
      _$MedicationReminderFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationReminderToJson(this);
}

@JsonSerializable()
class MedicationHistory {
  final String id;
  final String patientId;
  final String medicationId;
  final String medicationName;
  final DateTime startDate;
  final DateTime? endDate;
  final String reason;
  final String outcome;
  final List<String> sideEffects;
  final List<String> allergies;
  final List<String> interactions;
  final String notes;
  final Map<String, dynamic> metadata;

  const MedicationHistory({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.medicationName,
    required this.startDate,
    this.endDate,
    required this.reason,
    required this.outcome,
    required this.sideEffects,
    required this.allergies,
    required this.interactions,
    required this.notes,
    this.metadata = const {},
  });

  factory MedicationHistory.fromJson(Map<String, dynamic> json) =>
      _$MedicationHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationHistoryToJson(this);
}

// Enums
enum MedicationClass {
  antidepressants,
  antipsychotics,
  anxiolytics,
  moodStabilizers,
  stimulants,
  sedatives,
  hypnotics,
  anticonvulsants,
  other,
}

enum PrescriptionStatus {
  active,
  expired,
  cancelled,
  completed,
  suspended,
  pending,
}

enum InteractionSeverity {
  minor,
  moderate,
  major,
  contraindicated,
}

enum InteractionType {
  pharmacokinetic,
  pharmacodynamic,
  additive,
  antagonistic,
  synergistic,
  other,
}

enum TitrationStrategy {
  startLowGoSlow,
  rapidTitration,
  stepwise,
  individualized,
  other,
}

enum AdherenceStatus {
  excellent,
  good,
  fair,
  poor,
  nonAdherent,
}

enum AdherenceEventType {
  taken,
  missed,
  delayed,
  skipped,
  doubled,
  other,
}

enum SideEffectSeverity {
  mild,
  moderate,
  severe,
  lifeThreatening,
}

enum ReminderStatus {
  active,
  paused,
  completed,
  cancelled,
}

enum MedicationRoute {
  oral,
  sublingual,
  intramuscular,
  intravenous,
  subcutaneous,
  transdermal,
  nasal,
  rectal,
  other,
}

enum DosageForm {
  tablet,
  capsule,
  liquid,
  injection,
  patch,
  inhaler,
  suppository,
  other,
}
