import 'package:flutter/foundation.dart';

enum MedicationStatus { active, paused, discontinued, completed }
enum AdherenceLevel { excellent, good, fair, poor, critical }
enum SideEffectSeverity { mild, moderate, severe, lifeThreatening }
enum MedicationType { tablet, capsule, liquid, injection, patch, inhaler, other }

class MedicationRecord {
  final String id;
  final String patientId;
  final String nurseId;
  final String medicationName;
  final String genericName;
  final String dosage;
  final String frequency;
  final MedicationType type;
  final DateTime prescribedDate;
  final DateTime? endDate;
  MedicationStatus status;
  final String prescribedBy;
  final String? indication;
  final String? instructions;
  final List<MedicationDose> doses;
  final List<SideEffectRecord> sideEffects;
  final AdherenceLevel adherenceLevel;
  final double adherencePercentage;
  final String? notes;

  MedicationRecord({
    required this.id,
    required this.patientId,
    required this.nurseId,
    required this.medicationName,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.type,
    required this.prescribedDate,
    this.endDate,
    this.status = MedicationStatus.active,
    required this.prescribedBy,
    this.indication,
    this.instructions,
    this.doses = const [],
    this.sideEffects = const [],
    this.adherenceLevel = AdherenceLevel.excellent,
    this.adherencePercentage = 100.0,
    this.notes,
  });

  MedicationRecord copyWith({
    String? id,
    String? patientId,
    String? nurseId,
    String? medicationName,
    String? genericName,
    String? dosage,
    String? frequency,
    MedicationType? type,
    DateTime? prescribedDate,
    DateTime? endDate,
    MedicationStatus? status,
    String? prescribedBy,
    String? indication,
    String? instructions,
    List<MedicationDose>? doses,
    List<SideEffectRecord>? sideEffects,
    AdherenceLevel? adherenceLevel,
    double? adherencePercentage,
    String? notes,
  }) {
    return MedicationRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      medicationName: medicationName ?? this.medicationName,
      genericName: genericName ?? this.genericName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      type: type ?? this.type,
      prescribedDate: prescribedDate ?? this.prescribedDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      indication: indication ?? this.indication,
      instructions: instructions ?? this.instructions,
      doses: doses ?? this.doses,
      sideEffects: sideEffects ?? this.sideEffects,
      adherenceLevel: adherenceLevel ?? this.adherenceLevel,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'nurseId': nurseId,
      'medicationName': medicationName,
      'genericName': genericName,
      'dosage': dosage,
      'frequency': frequency,
      'type': type.toString().split('.').last,
      'prescribedDate': prescribedDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'prescribedBy': prescribedBy,
      'indication': indication,
      'instructions': instructions,
      'doses': doses.map((dose) => dose.toJson()).toList(),
      'sideEffects': sideEffects.map((effect) => effect.toJson()).toList(),
      'adherenceLevel': adherenceLevel.toString().split('.').last,
      'adherencePercentage': adherencePercentage,
      'notes': notes,
    };
  }

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      medicationName: json['medicationName'] as String,
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      type: MedicationType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'] as String),
      prescribedDate: DateTime.parse(json['prescribedDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      status: MedicationStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'] as String),
      prescribedBy: json['prescribedBy'] as String,
      indication: json['indication'] as String?,
      instructions: json['instructions'] as String?,
      doses: (json['doses'] as List)
          .map((dose) => MedicationDose.fromJson(dose as Map<String, dynamic>))
          .toList(),
      sideEffects: (json['sideEffects'] as List)
          .map((effect) => SideEffectRecord.fromJson(effect as Map<String, dynamic>))
          .toList(),
      adherenceLevel: AdherenceLevel.values.firstWhere(
          (e) => e.toString().split('.').last == json['adherenceLevel'] as String),
      adherencePercentage: json['adherencePercentage'] as double,
      notes: json['notes'] as String?,
    );
  }
}

class MedicationDose {
  final String id;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final bool wasTaken;
  final String? actualDosage;
  final String? notes;
  final String? recordedBy;

  MedicationDose({
    required this.id,
    required this.scheduledTime,
    this.takenTime,
    this.wasTaken = false,
    this.actualDosage,
    this.notes,
    this.recordedBy,
  });

  MedicationDose copyWith({
    String? id,
    DateTime? scheduledTime,
    DateTime? takenTime,
    bool? wasTaken,
    String? actualDosage,
    String? notes,
    String? recordedBy,
  }) {
    return MedicationDose(
      id: id ?? this.id,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      wasTaken: wasTaken ?? this.wasTaken,
      actualDosage: actualDosage ?? this.actualDosage,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'wasTaken': wasTaken,
      'actualDosage': actualDosage,
      'notes': notes,
      'recordedBy': recordedBy,
    };
  }

  factory MedicationDose.fromJson(Map<String, dynamic> json) {
    return MedicationDose(
      id: json['id'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'] as String)
          : null,
      wasTaken: json['wasTaken'] as bool,
      actualDosage: json['actualDosage'] as String?,
      notes: json['notes'] as String?,
      recordedBy: json['recordedBy'] as String?,
    );
  }
}

class SideEffectRecord {
  final String id;
  final String medicationId;
  final String patientId;
  final String nurseId;
  final String sideEffect;
  final SideEffectSeverity severity;
  final DateTime onsetDate;
  final DateTime? resolutionDate;
  final String? description;
  final String? actionTaken;
  final bool requiresMedicalAttention;
  final String? notes;

  SideEffectRecord({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.nurseId,
    required this.sideEffect,
    required this.severity,
    required this.onsetDate,
    this.resolutionDate,
    this.description,
    this.actionTaken,
    this.requiresMedicalAttention = false,
    this.notes,
  });

  SideEffectRecord copyWith({
    String? id,
    String? medicationId,
    String? patientId,
    String? nurseId,
    String? sideEffect,
    SideEffectSeverity? severity,
    DateTime? onsetDate,
    DateTime? resolutionDate,
    String? description,
    String? actionTaken,
    bool? requiresMedicalAttention,
    String? notes,
  }) {
    return SideEffectRecord(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      sideEffect: sideEffect ?? this.sideEffect,
      severity: severity ?? this.severity,
      onsetDate: onsetDate ?? this.onsetDate,
      resolutionDate: resolutionDate ?? this.resolutionDate,
      description: description ?? this.description,
      actionTaken: actionTaken ?? this.actionTaken,
      requiresMedicalAttention: requiresMedicalAttention ?? this.requiresMedicalAttention,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'patientId': patientId,
      'nurseId': nurseId,
      'sideEffect': sideEffect,
      'severity': severity.toString().split('.').last,
      'onsetDate': onsetDate.toIso8601String(),
      'resolutionDate': resolutionDate?.toIso8601String(),
      'description': description,
      'actionTaken': actionTaken,
      'requiresMedicalAttention': requiresMedicalAttention,
      'notes': notes,
    };
  }

  factory SideEffectRecord.fromJson(Map<String, dynamic> json) {
    return SideEffectRecord(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      sideEffect: json['sideEffect'] as String,
      severity: SideEffectSeverity.values.firstWhere(
          (e) => e.toString().split('.').last == json['severity'] as String),
      onsetDate: DateTime.parse(json['onsetDate'] as String),
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.parse(json['resolutionDate'] as String)
          : null,
      description: json['description'] as String?,
      actionTaken: json['actionTaken'] as String?,
      requiresMedicalAttention: json['requiresMedicalAttention'] as bool,
      notes: json['notes'] as String?,
    );
  }
}

class MedicationInteraction {
  final String id;
  final String medication1Id;
  final String medication2Id;
  final String interactionType;
  final String severity;
  final String description;
  final String? clinicalSignificance;
  final String? management;
  final DateTime detectedAt;
  final String? detectedBy;

  MedicationInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication2Id,
    required this.interactionType,
    required this.severity,
    required this.description,
    this.clinicalSignificance,
    this.management,
    required this.detectedAt,
    this.detectedBy,
  });

  MedicationInteraction copyWith({
    String? id,
    String? medication1Id,
    String? medication2Id,
    String? interactionType,
    String? severity,
    String? description,
    String? clinicalSignificance,
    String? management,
    DateTime? detectedAt,
    String? detectedBy,
  }) {
    return MedicationInteraction(
      id: id ?? this.id,
      medication1Id: medication1Id ?? this.medication1Id,
      medication2Id: medication2Id ?? this.medication2Id,
      interactionType: interactionType ?? this.interactionType,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      clinicalSignificance: clinicalSignificance ?? this.clinicalSignificance,
      management: management ?? this.management,
      detectedAt: detectedAt ?? this.detectedAt,
      detectedBy: detectedBy ?? this.detectedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication1Id': medication1Id,
      'medication2Id': medication2Id,
      'interactionType': interactionType,
      'severity': severity,
      'description': description,
      'clinicalSignificance': clinicalSignificance,
      'management': management,
      'detectedAt': detectedAt.toIso8601String(),
      'detectedBy': detectedBy,
    };
  }

  factory MedicationInteraction.fromJson(Map<String, dynamic> json) {
    return MedicationInteraction(
      id: json['id'] as String,
      medication1Id: json['medication1Id'] as String,
      medication2Id: json['medication2Id'] as String,
      interactionType: json['interactionType'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      clinicalSignificance: json['clinicalSignificance'] as String?,
      management: json['management'] as String?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      detectedBy: json['detectedBy'] as String?,
    );
  }
}

class MedicationEducation {
  final String id;
  final String medicationId;
  final String patientId;
  final String nurseId;
  final String title;
  final String content;
  final List<String> topics;
  final DateTime assignedDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final String? quizResults;
  final String? notes;

  MedicationEducation({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.nurseId,
    required this.title,
    required this.content,
    required this.topics,
    required this.assignedDate,
    this.completedDate,
    this.isCompleted = false,
    this.quizResults,
    this.notes,
  });

  MedicationEducation copyWith({
    String? id,
    String? medicationId,
    String? patientId,
    String? nurseId,
    String? title,
    String? content,
    List<String>? topics,
    DateTime? assignedDate,
    DateTime? completedDate,
    bool? isCompleted,
    String? quizResults,
    String? notes,
  }) {
    return MedicationEducation(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      title: title ?? this.title,
      content: content ?? this.content,
      topics: topics ?? this.topics,
      assignedDate: assignedDate ?? this.assignedDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      quizResults: quizResults ?? this.quizResults,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'patientId': patientId,
      'nurseId': nurseId,
      'title': title,
      'content': content,
      'topics': topics,
      'assignedDate': assignedDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'quizResults': quizResults,
      'notes': notes,
    };
  }

  factory MedicationEducation.fromJson(Map<String, dynamic> json) {
    return MedicationEducation(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      patientId: json['patientId'] as String,
      nurseId: json['nurseId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      topics: List<String>.from(json['topics'] as List),
      assignedDate: DateTime.parse(json['assignedDate'] as String),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool,
      quizResults: json['quizResults'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
