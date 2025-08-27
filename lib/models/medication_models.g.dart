// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Medication _$MedicationFromJson(Map<String, dynamic> json) => Medication(
  id: json['id'] as String,
  name: json['name'] as String,
  genericName: json['genericName'] as String,
  brandName: json['brandName'] as String,
  atcCode: json['atcCode'] as String,
  rxNormCode: json['rxNormCode'] as String,
  dinCode: json['dinCode'] as String,
  barcode: json['barcode'] as String,
  medicationClass: $enumDecode(
    _$MedicationClassEnumMap,
    json['medicationClass'],
  ),
  activeIngredients: (json['activeIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  inactiveIngredients: (json['inactiveIngredients'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  dosageForm: json['dosageForm'] as String,
  strengths: (json['strengths'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  manufacturer: json['manufacturer'] as String,
  country: json['country'] as String,
  isControlled: json['isControlled'] as bool,
  requiresPrescription: json['requiresPrescription'] as bool,
  indications: (json['indications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  precautions: (json['precautions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  drugInteractions: (json['drugInteractions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  foodInteractions: (json['foodInteractions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  labInteractions: (json['labInteractions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  monitoringRequirements: (json['monitoringRequirements'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pregnancyCategory: (json['pregnancyCategory'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  breastfeedingCategory: (json['breastfeedingCategory'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pediatricUse: (json['pediatricUse'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  geriatricUse: (json['geriatricUse'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  renalAdjustment: (json['renalAdjustment'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  hepaticAdjustment: (json['hepaticAdjustment'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  isActive: json['isActive'] as bool,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$MedicationToJson(Medication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'genericName': instance.genericName,
      'brandName': instance.brandName,
      'atcCode': instance.atcCode,
      'rxNormCode': instance.rxNormCode,
      'dinCode': instance.dinCode,
      'barcode': instance.barcode,
      'medicationClass': _$MedicationClassEnumMap[instance.medicationClass]!,
      'activeIngredients': instance.activeIngredients,
      'inactiveIngredients': instance.inactiveIngredients,
      'dosageForm': instance.dosageForm,
      'strengths': instance.strengths,
      'manufacturer': instance.manufacturer,
      'country': instance.country,
      'isControlled': instance.isControlled,
      'requiresPrescription': instance.requiresPrescription,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'sideEffects': instance.sideEffects,
      'warnings': instance.warnings,
      'precautions': instance.precautions,
      'drugInteractions': instance.drugInteractions,
      'foodInteractions': instance.foodInteractions,
      'labInteractions': instance.labInteractions,
      'monitoringRequirements': instance.monitoringRequirements,
      'pregnancyCategory': instance.pregnancyCategory,
      'breastfeedingCategory': instance.breastfeedingCategory,
      'pediatricUse': instance.pediatricUse,
      'geriatricUse': instance.geriatricUse,
      'renalAdjustment': instance.renalAdjustment,
      'hepaticAdjustment': instance.hepaticAdjustment,
      'metadata': instance.metadata,
      'isActive': instance.isActive,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$MedicationClassEnumMap = {
  MedicationClass.antidepressants: 'antidepressants',
  MedicationClass.antipsychotics: 'antipsychotics',
  MedicationClass.anxiolytics: 'anxiolytics',
  MedicationClass.moodStabilizers: 'moodStabilizers',
  MedicationClass.stimulants: 'stimulants',
  MedicationClass.sedatives: 'sedatives',
  MedicationClass.hypnotics: 'hypnotics',
  MedicationClass.anticonvulsants: 'anticonvulsants',
  MedicationClass.other: 'other',
};

Prescription _$PrescriptionFromJson(Map<String, dynamic> json) => Prescription(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
  expiryDate: json['expiryDate'] == null
      ? null
      : DateTime.parse(json['expiryDate'] as String),
  status: $enumDecode(_$PrescriptionStatusEnumMap, json['status']),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => PrescribedMedication.fromJson(e as Map<String, dynamic>))
      .toList(),
  diagnosis: json['diagnosis'] as String,
  clinicalNotes: json['clinicalNotes'] as String,
  allergies: (json['allergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  contraindications: (json['contraindications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  instructions: (json['instructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  refillsAllowed: (json['refillsAllowed'] as num).toInt(),
  refillsUsed: (json['refillsUsed'] as num).toInt(),
  pharmacy: json['pharmacy'] as String,
  prescriberSignature: json['prescriberSignature'] as String,
  isElectronic: json['isElectronic'] as bool,
  prescriptionNumber: json['prescriptionNumber'] as String,
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PrescriptionToJson(Prescription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'clinicianId': instance.clinicianId,
      'prescriptionDate': instance.prescriptionDate.toIso8601String(),
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'status': _$PrescriptionStatusEnumMap[instance.status]!,
      'medications': instance.medications,
      'diagnosis': instance.diagnosis,
      'clinicalNotes': instance.clinicalNotes,
      'allergies': instance.allergies,
      'contraindications': instance.contraindications,
      'warnings': instance.warnings,
      'instructions': instance.instructions,
      'refillsAllowed': instance.refillsAllowed,
      'refillsUsed': instance.refillsUsed,
      'pharmacy': instance.pharmacy,
      'prescriberSignature': instance.prescriberSignature,
      'isElectronic': instance.isElectronic,
      'prescriptionNumber': instance.prescriptionNumber,
      'metadata': instance.metadata,
    };

const _$PrescriptionStatusEnumMap = {
  PrescriptionStatus.active: 'active',
  PrescriptionStatus.expired: 'expired',
  PrescriptionStatus.cancelled: 'cancelled',
  PrescriptionStatus.completed: 'completed',
  PrescriptionStatus.suspended: 'suspended',
  PrescriptionStatus.pending: 'pending',
};

PrescribedMedication _$PrescribedMedicationFromJson(
  Map<String, dynamic> json,
) => PrescribedMedication(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  dosage: json['dosage'] as String,
  frequency: json['frequency'] as String,
  route: json['route'] as String,
  duration: json['duration'] as String,
  instructions: json['instructions'] as String,
  quantity: (json['quantity'] as num).toInt(),
  strength: json['strength'] as String,
  specialInstructions: (json['specialInstructions'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  sideEffects: (json['sideEffects'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  warnings: (json['warnings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  requiresMonitoring: json['requiresMonitoring'] as bool,
  monitoringTests: (json['monitoringTests'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  followUpSchedule: (json['followUpSchedule'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$PrescribedMedicationToJson(
  PrescribedMedication instance,
) => <String, dynamic>{
  'id': instance.id,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'dosage': instance.dosage,
  'frequency': instance.frequency,
  'route': instance.route,
  'duration': instance.duration,
  'instructions': instance.instructions,
  'quantity': instance.quantity,
  'strength': instance.strength,
  'specialInstructions': instance.specialInstructions,
  'sideEffects': instance.sideEffects,
  'warnings': instance.warnings,
  'requiresMonitoring': instance.requiresMonitoring,
  'monitoringTests': instance.monitoringTests,
  'followUpSchedule': instance.followUpSchedule,
  'metadata': instance.metadata,
};

DrugInteraction _$DrugInteractionFromJson(Map<String, dynamic> json) =>
    DrugInteraction(
      id: json['id'] as String,
      medication1Id: json['medication1Id'] as String,
      medication1Name: json['medication1Name'] as String,
      medication2Id: json['medication2Id'] as String,
      medication2Name: json['medication2Name'] as String,
      severity: json['severity'] as String,
      type: $enumDecode(_$InteractionTypeEnumMap, json['type']),
      mechanism: json['mechanism'] as String,
      description: json['description'] as String,
      clinicalSignificance: json['clinicalSignificance'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alternatives: (json['alternatives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      monitoring: (json['monitoring'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      evidence: json['evidence'] as String,
      source: json['source'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DrugInteractionToJson(DrugInteraction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medication1Id': instance.medication1Id,
      'medication1Name': instance.medication1Name,
      'medication2Id': instance.medication2Id,
      'medication2Name': instance.medication2Name,
      'severity': instance.severity,
      'type': _$InteractionTypeEnumMap[instance.type]!,
      'mechanism': instance.mechanism,
      'description': instance.description,
      'clinicalSignificance': instance.clinicalSignificance,
      'symptoms': instance.symptoms,
      'recommendations': instance.recommendations,
      'alternatives': instance.alternatives,
      'monitoring': instance.monitoring,
      'evidence': instance.evidence,
      'source': instance.source,
      'metadata': instance.metadata,
    };

const _$InteractionTypeEnumMap = {
  InteractionType.pharmacokinetic: 'pharmacokinetic',
  InteractionType.pharmacodynamic: 'pharmacodynamic',
  InteractionType.additive: 'additive',
  InteractionType.antagonistic: 'antagonistic',
  InteractionType.synergistic: 'synergistic',
  InteractionType.other: 'other',
};

DosageTitration _$DosageTitrationFromJson(Map<String, dynamic> json) =>
    DosageTitration(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      indication: json['indication'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map((e) => TitrationStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      strategy: $enumDecode(_$TitrationStrategyEnumMap, json['strategy']),
      rationale: json['rationale'] as String,
      monitoringParameters: (json['monitoringParameters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      adverseEffects: (json['adverseEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      duration: json['duration'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DosageTitrationToJson(DosageTitration instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'medicationName': instance.medicationName,
      'indication': instance.indication,
      'steps': instance.steps,
      'strategy': _$TitrationStrategyEnumMap[instance.strategy]!,
      'rationale': instance.rationale,
      'monitoringParameters': instance.monitoringParameters,
      'adverseEffects': instance.adverseEffects,
      'contraindications': instance.contraindications,
      'duration': instance.duration,
      'metadata': instance.metadata,
    };

const _$TitrationStrategyEnumMap = {
  TitrationStrategy.startLowGoSlow: 'startLowGoSlow',
  TitrationStrategy.rapidTitration: 'rapidTitration',
  TitrationStrategy.stepwise: 'stepwise',
  TitrationStrategy.individualized: 'individualized',
  TitrationStrategy.other: 'other',
};

TitrationStep _$TitrationStepFromJson(Map<String, dynamic> json) =>
    TitrationStep(
      id: json['id'] as String,
      stepNumber: (json['stepNumber'] as num).toInt(),
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String,
      monitoring: (json['monitoring'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      warnings: (json['warnings'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      requiresAdjustment: json['requiresAdjustment'] as bool,
      adjustmentCriteria: json['adjustmentCriteria'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$TitrationStepToJson(TitrationStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepNumber': instance.stepNumber,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'instructions': instance.instructions,
      'monitoring': instance.monitoring,
      'sideEffects': instance.sideEffects,
      'warnings': instance.warnings,
      'requiresAdjustment': instance.requiresAdjustment,
      'adjustmentCriteria': instance.adjustmentCriteria,
      'metadata': instance.metadata,
    };

MedicationAdherence _$MedicationAdherenceFromJson(Map<String, dynamic> json) =>
    MedicationAdherence(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      status: $enumDecode(_$AdherenceStatusEnumMap, json['status']),
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      events: (json['events'] as List<dynamic>)
          .map((e) => AdherenceEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      barriers: (json['barriers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      facilitators: (json['facilitators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interventions: (json['interventions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MedicationAdherenceToJson(
  MedicationAdherence instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'medicationId': instance.medicationId,
  'medicationName': instance.medicationName,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'status': _$AdherenceStatusEnumMap[instance.status]!,
  'adherenceRate': instance.adherenceRate,
  'events': instance.events,
  'barriers': instance.barriers,
  'facilitators': instance.facilitators,
  'interventions': instance.interventions,
  'notes': instance.notes,
  'metadata': instance.metadata,
};

const _$AdherenceStatusEnumMap = {
  AdherenceStatus.excellent: 'excellent',
  AdherenceStatus.good: 'good',
  AdherenceStatus.fair: 'fair',
  AdherenceStatus.poor: 'poor',
  AdherenceStatus.nonAdherent: 'nonAdherent',
};

AdherenceEvent _$AdherenceEventFromJson(Map<String, dynamic> json) =>
    AdherenceEvent(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecode(_$AdherenceEventTypeEnumMap, json['type']),
      description: json['description'] as String,
      reason: json['reason'] as String,
      action: json['action'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$AdherenceEventToJson(AdherenceEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$AdherenceEventTypeEnumMap[instance.type]!,
      'description': instance.description,
      'reason': instance.reason,
      'action': instance.action,
      'metadata': instance.metadata,
    };

const _$AdherenceEventTypeEnumMap = {
  AdherenceEventType.taken: 'taken',
  AdherenceEventType.missed: 'missed',
  AdherenceEventType.delayed: 'delayed',
  AdherenceEventType.skipped: 'skipped',
  AdherenceEventType.doubled: 'doubled',
  AdherenceEventType.other: 'other',
};

SideEffectReport _$SideEffectReportFromJson(Map<String, dynamic> json) =>
    SideEffectReport(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      sideEffect: json['sideEffect'] as String,
      severity: $enumDecode(_$SideEffectSeverityEnumMap, json['severity']),
      description: json['description'] as String,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      onsetDate: json['onsetDate'] == null
          ? null
          : DateTime.parse(json['onsetDate'] as String),
      resolutionDate: json['resolutionDate'] == null
          ? null
          : DateTime.parse(json['resolutionDate'] as String),
      outcome: json['outcome'] as String,
      requiredDiscontinuation: json['requiredDiscontinuation'] as bool,
      requiredDoseReduction: json['requiredDoseReduction'] as bool,
      action: json['action'] as String,
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$SideEffectReportToJson(SideEffectReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'medicationId': instance.medicationId,
      'medicationName': instance.medicationName,
      'reportDate': instance.reportDate.toIso8601String(),
      'sideEffect': instance.sideEffect,
      'severity': _$SideEffectSeverityEnumMap[instance.severity]!,
      'description': instance.description,
      'symptoms': instance.symptoms,
      'onsetDate': instance.onsetDate?.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'outcome': instance.outcome,
      'requiredDiscontinuation': instance.requiredDiscontinuation,
      'requiredDoseReduction': instance.requiredDoseReduction,
      'action': instance.action,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$SideEffectSeverityEnumMap = {
  SideEffectSeverity.mild: 'mild',
  SideEffectSeverity.moderate: 'moderate',
  SideEffectSeverity.severe: 'severe',
  SideEffectSeverity.lifeThreatening: 'lifeThreatening',
};

MedicationReminder _$MedicationReminderFromJson(Map<String, dynamic> json) =>
    MedicationReminder(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      nextDoseTime: DateTime.parse(json['nextDoseTime'] as String),
      scheduledTimes: (json['scheduledTimes'] as List<dynamic>)
          .map((e) => DateTime.parse(e as String))
          .toList(),
      status: $enumDecode(_$ReminderStatusEnumMap, json['status']),
      notificationMethods: (json['notificationMethods'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isActive: json['isActive'] as bool,
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MedicationReminderToJson(MedicationReminder instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'medicationId': instance.medicationId,
      'medicationName': instance.medicationName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'nextDoseTime': instance.nextDoseTime.toIso8601String(),
      'scheduledTimes': instance.scheduledTimes
          .map((e) => e.toIso8601String())
          .toList(),
      'status': _$ReminderStatusEnumMap[instance.status]!,
      'notificationMethods': instance.notificationMethods,
      'isActive': instance.isActive,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

const _$ReminderStatusEnumMap = {
  ReminderStatus.active: 'active',
  ReminderStatus.paused: 'paused',
  ReminderStatus.completed: 'completed',
  ReminderStatus.cancelled: 'cancelled',
};

MedicationHistory _$MedicationHistoryFromJson(Map<String, dynamic> json) =>
    MedicationHistory(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      reason: json['reason'] as String,
      outcome: json['outcome'] as String,
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      allergies: (json['allergies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interactions: (json['interactions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      notes: json['notes'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$MedicationHistoryToJson(MedicationHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'medicationId': instance.medicationId,
      'medicationName': instance.medicationName,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'reason': instance.reason,
      'outcome': instance.outcome,
      'sideEffects': instance.sideEffects,
      'allergies': instance.allergies,
      'interactions': instance.interactions,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };
