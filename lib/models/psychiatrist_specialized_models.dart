import 'dart:convert';

enum MedicationType { antidepressant, anxiolytic, antipsychotic, moodStabilizer, stimulant, other }
enum SideEffectSeverity { none, mild, moderate, severe, lifeThreatening }
enum LabTestType { blood, urine, ecg, eeg, mri, ct, other }

class Medication {
  final String id;
  final String name;
  final String genericName;
  final MedicationType type;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final Map<String, String> dosing; // age/condition -> dose
  final List<String> interactions;
  final String pregnancyCategory;
  final bool requiresMonitoring;
  final List<LabTestType> requiredLabs;
  final String halfLife;
  final String metabolism;

  Medication({
    required this.id,
    required this.name,
    required this.genericName,
    required this.type,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.dosing,
    required this.interactions,
    required this.pregnancyCategory,
    required this.requiresMonitoring,
    required this.requiredLabs,
    required this.halfLife,
    required this.metabolism,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'type': type.name,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'dosing': dosing,
      'interactions': interactions,
      'pregnancyCategory': pregnancyCategory,
      'requiresMonitoring': requiresMonitoring,
      'requiredLabs': requiredLabs.map((e) => e.name).toList(),
      'halfLife': halfLife,
      'metabolism': metabolism,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      genericName: json['genericName'],
      type: MedicationType.values.firstWhere((e) => e.name == json['type']),
      indications: List<String>.from(json['indications']),
      contraindications: List<String>.from(json['contraindications']),
      sideEffects: List<String>.from(json['sideEffects']),
      dosing: Map<String, String>.from(json['dosing']),
      interactions: List<String>.from(json['interactions']),
      pregnancyCategory: json['pregnancyCategory'],
      requiresMonitoring: json['requiresMonitoring'],
      requiredLabs: (json['requiredLabs'] as List).map((e) => LabTestType.values.firstWhere((t) => t.name == e)).toList(),
      halfLife: json['halfLife'],
      metabolism: json['metabolism'],
    );
  }
}

class Prescription {
  final String id;
  final String patientId;
  final String psychiatristId;
  final List<PrescribedMedication> medications;
  final DateTime prescribedAt;
  final DateTime? validUntil;
  final String instructions;
  final String diagnosis;
  final bool isRefillable;
  final int refillCount;
  final String? pharmacyNotes;
  final Map<String, dynamic> metadata;

  Prescription({
    required this.id,
    required this.patientId,
    required this.psychiatristId,
    required this.medications,
    required this.prescribedAt,
    this.validUntil,
    required this.instructions,
    required this.diagnosis,
    this.isRefillable = false,
    this.refillCount = 0,
    this.pharmacyNotes,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'medications': medications.map((m) => m.toJson()).toList(),
      'prescribedAt': prescribedAt.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'instructions': instructions,
      'diagnosis': diagnosis,
      'isRefillable': isRefillable,
      'refillCount': refillCount,
      'pharmacyNotes': pharmacyNotes,
      'metadata': metadata,
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patientId'],
      psychiatristId: json['psychiatristId'],
      medications: (json['medications'] as List).map((m) => PrescribedMedication.fromJson(m)).toList(),
      prescribedAt: DateTime.parse(json['prescribedAt']),
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil']) : null,
      instructions: json['instructions'],
      diagnosis: json['diagnosis'],
      isRefillable: json['isRefillable'] ?? false,
      refillCount: json['refillCount'] ?? 0,
      pharmacyNotes: json['pharmacyNotes'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class PrescribedMedication {
  final String medicationId;
  final String medicationName;
  final double dosage;
  final String dosageUnit;
  final String frequency;
  final String route; // oral, IM, IV, etc.
  final DateTime startDate;
  final DateTime? endDate;
  final String instructions;
  final int quantity;
  final int daysSupply;

  PrescribedMedication({
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.dosageUnit,
    required this.frequency,
    required this.route,
    required this.startDate,
    this.endDate,
    required this.instructions,
    required this.quantity,
    required this.daysSupply,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'frequency': frequency,
      'route': route,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'instructions': instructions,
      'quantity': quantity,
      'daysSupply': daysSupply,
    };
  }

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) {
    return PrescribedMedication(
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      dosage: json['dosage'].toDouble(),
      dosageUnit: json['dosageUnit'],
      frequency: json['frequency'],
      route: json['route'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      instructions: json['instructions'],
      quantity: json['quantity'],
      daysSupply: json['daysSupply'],
    );
  }
}

class SideEffectReport {
  final String id;
  final String patientId;
  final String prescriptionId;
  final String medicationName;
  final String sideEffect;
  final SideEffectSeverity severity;
  final DateTime reportedAt;
  final String reportedBy;
  final String description;
  final bool requiresAction;
  final String? actionTaken;
  final DateTime? resolvedAt;
  final Map<String, dynamic> metadata;

  SideEffectReport({
    required this.id,
    required this.patientId,
    required this.prescriptionId,
    required this.medicationName,
    required this.sideEffect,
    required this.severity,
    required this.reportedAt,
    required this.reportedBy,
    required this.description,
    this.requiresAction = false,
    this.actionTaken,
    this.resolvedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'prescriptionId': prescriptionId,
      'medicationName': medicationName,
      'sideEffect': sideEffect,
      'severity': severity.name,
      'reportedAt': reportedAt.toIso8601String(),
      'reportedBy': reportedBy,
      'description': description,
      'requiresAction': requiresAction,
      'actionTaken': actionTaken,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory SideEffectReport.fromJson(Map<String, dynamic> json) {
    return SideEffectReport(
      id: json['id'],
      patientId: json['patientId'],
      prescriptionId: json['prescriptionId'],
      medicationName: json['medicationName'],
      sideEffect: json['sideEffect'],
      severity: SideEffectSeverity.values.firstWhere((e) => e.name == json['severity']),
      reportedAt: DateTime.parse(json['reportedAt']),
      reportedBy: json['reportedBy'],
      description: json['description'],
      requiresAction: json['requiresAction'] ?? false,
      actionTaken: json['actionTaken'],
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
      metadata: json['metadata'] ?? {},
    );
  }
}

class LabTest {
  final String id;
  final String patientId;
  final String psychiatristId;
  final LabTestType type;
  final String testName;
  final DateTime orderedAt;
  final DateTime? completedAt;
  final String? results;
  final String? interpretation;
  final bool isAbnormal;
  final String? abnormalValues;
  final String? recommendations;
  final Map<String, dynamic> metadata;

  LabTest({
    required this.id,
    required this.patientId,
    required this.psychiatristId,
    required this.type,
    required this.testName,
    required this.orderedAt,
    this.completedAt,
    this.results,
    this.interpretation,
    this.isAbnormal = false,
    this.abnormalValues,
    this.recommendations,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'type': type.name,
      'testName': testName,
      'orderedAt': orderedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'results': results,
      'interpretation': interpretation,
      'isAbnormal': isAbnormal,
      'abnormalValues': abnormalValues,
      'recommendations': recommendations,
      'metadata': metadata,
    };
  }

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      id: json['id'],
      patientId: json['patientId'],
      psychiatristId: json['psychiatristId'],
      type: LabTestType.values.firstWhere((e) => e.name == json['type']),
      testName: json['testName'],
      orderedAt: DateTime.parse(json['orderedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      results: json['results'],
      interpretation: json['interpretation'],
      isAbnormal: json['isAbnormal'] ?? false,
      abnormalValues: json['abnormalValues'],
      recommendations: json['recommendations'],
      metadata: json['metadata'] ?? {},
    );
  }
}

class MedicationInteraction {
  final String id;
  final String medication1;
  final String medication2;
  final String interactionType;
  final String severity;
  final String description;
  final String clinicalSignificance;
  final String management;
  final List<String> references;

  MedicationInteraction({
    required this.id,
    required this.medication1,
    required this.medication2,
    required this.interactionType,
    required this.severity,
    required this.description,
    required this.clinicalSignificance,
    required this.management,
    this.references = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication1': medication1,
      'medication2': medication2,
      'interactionType': interactionType,
      'severity': severity,
      'description': description,
      'clinicalSignificance': clinicalSignificance,
      'management': management,
      'references': references,
    };
  }

  factory MedicationInteraction.fromJson(Map<String, dynamic> json) {
    return MedicationInteraction(
      id: json['id'],
      medication1: json['medication1'],
      medication2: json['medication2'],
      interactionType: json['interactionType'],
      severity: json['severity'],
      description: json['description'],
      clinicalSignificance: json['clinicalSignificance'],
      management: json['management'],
      references: List<String>.from(json['references'] ?? []),
    );
  }
}

class PsychiatricAssessment {
  final String id;
  final String patientId;
  final String psychiatristId;
  final DateTime assessmentDate;
  final String mentalStatusExam;
  final Map<String, dynamic> cognitiveAssessment;
  final Map<String, dynamic> moodAssessment;
  final Map<String, dynamic> anxietyAssessment;
  final Map<String, dynamic> psychoticSymptoms;
  final Map<String, dynamic> substanceUse;
  final Map<String, dynamic> riskAssessment;
  final List<String> differentialDiagnoses;
  final String primaryDiagnosis;
  final String treatmentPlan;
  final List<String> recommendations;
  final DateTime nextAppointment;
  final Map<String, dynamic> metadata;

  PsychiatricAssessment({
    required this.id,
    required this.patientId,
    required this.psychiatristId,
    required this.assessmentDate,
    required this.mentalStatusExam,
    required this.cognitiveAssessment,
    required this.moodAssessment,
    required this.anxietyAssessment,
    required this.psychoticSymptoms,
    required this.substanceUse,
    required this.riskAssessment,
    required this.differentialDiagnoses,
    required this.primaryDiagnosis,
    required this.treatmentPlan,
    required this.recommendations,
    required this.nextAppointment,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'mentalStatusExam': mentalStatusExam,
      'cognitiveAssessment': cognitiveAssessment,
      'moodAssessment': moodAssessment,
      'anxietyAssessment': anxietyAssessment,
      'psychoticSymptoms': psychoticSymptoms,
      'substanceUse': substanceUse,
      'riskAssessment': riskAssessment,
      'differentialDiagnoses': differentialDiagnoses,
      'primaryDiagnosis': primaryDiagnosis,
      'treatmentPlan': treatmentPlan,
      'recommendations': recommendations,
      'nextAppointment': nextAppointment.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory PsychiatricAssessment.fromJson(Map<String, dynamic> json) {
    return PsychiatricAssessment(
      id: json['id'],
      patientId: json['patientId'],
      psychiatristId: json['psychiatristId'],
      assessmentDate: DateTime.parse(json['assessmentDate']),
      mentalStatusExam: json['mentalStatusExam'],
      cognitiveAssessment: Map<String, dynamic>.from(json['cognitiveAssessment']),
      moodAssessment: Map<String, dynamic>.from(json['moodAssessment']),
      anxietyAssessment: Map<String, dynamic>.from(json['anxietyAssessment']),
      psychoticSymptoms: Map<String, dynamic>.from(json['psychoticSymptoms']),
      substanceUse: Map<String, dynamic>.from(json['substanceUse']),
      riskAssessment: Map<String, dynamic>.from(json['riskAssessment']),
      differentialDiagnoses: List<String>.from(json['differentialDiagnoses']),
      primaryDiagnosis: json['primaryDiagnosis'],
      treatmentPlan: json['treatmentPlan'],
      recommendations: List<String>.from(json['recommendations']),
      nextAppointment: DateTime.parse(json['nextAppointment']),
      metadata: json['metadata'] ?? {},
    );
  }
}
