class MedicationPrescription {
  final String id;
  final String patientId;
  final String psychiatristId;
  final String medicationName;
  final String genericName;
  final String dosage;
  final String frequency;
  final String route;
  final String duration;
  final DateTime prescribedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final PrescriptionStatus status;
  final String? instructions;
  final String? sideEffects;
  final String? contraindications;
  final String? monitoring;
  final String? notes;
  final Map<String, dynamic> metadata;

  const MedicationPrescription({
    required this.id,
    required this.patientId,
    required this.psychiatristId,
    required this.medicationName,
    required this.genericName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.duration,
    required this.prescribedAt,
    this.startDate,
    this.endDate,
    this.status = PrescriptionStatus.active,
    this.instructions,
    this.sideEffects,
    this.contraindications,
    this.monitoring,
    this.notes,
    this.metadata = const {},
  });

  factory MedicationPrescription.fromJson(Map<String, dynamic> json) {
    return MedicationPrescription(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      psychiatristId: json['psychiatristId'] as String,
      medicationName: json['medicationName'] as String,
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      route: json['route'] as String,
      duration: json['duration'] as String,
      prescribedAt: DateTime.parse(json['prescribedAt'] as String),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrescriptionStatus.active,
      ),
      instructions: json['instructions'] as String?,
      sideEffects: json['sideEffects'] as String?,
      contraindications: json['contraindications'] as String?,
      monitoring: json['monitoring'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'medicationName': medicationName,
      'genericName': genericName,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'duration': duration,
      'prescribedAt': prescribedAt.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'instructions': instructions,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
      'monitoring': monitoring,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if prescription is active
  bool get isActive {
    return status == PrescriptionStatus.active;
  }

  // Check if prescription is expired
  bool get isExpired {
    if (endDate == null) return false;
    return endDate!.isBefore(DateTime.now());
  }

  // Check if prescription needs review
  bool get needsReview {
    if (endDate == null) return false;
    final daysUntilExpiry = endDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7;
  }
}

class MedicationInteraction {
  final String id;
  final String medication1Id;
  final String medication2Id;
  final String medication1Name;
  final String medication2Name;
  final InteractionSeverity severity;
  final String description;
  final String mechanism;
  final String clinicalSignificance;
  final String management;
  final String? references;
  final DateTime detectedAt;
  final String detectedBy;
  final Map<String, dynamic> metadata;

  const MedicationInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication2Id,
    required this.medication1Name,
    required this.medication2Name,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.clinicalSignificance,
    required this.management,
    this.references,
    required this.detectedAt,
    required this.detectedBy,
    this.metadata = const {},
  });

  factory MedicationInteraction.fromJson(Map<String, dynamic> json) {
    return MedicationInteraction(
      id: json['id'] as String,
      medication1Id: json['medication1Id'] as String,
      medication2Id: json['medication2Id'] as String,
      medication1Name: json['medication1Name'] as String,
      medication2Name: json['medication2Name'] as String,
      severity: InteractionSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => InteractionSeverity.moderate,
      ),
      description: json['description'] as String,
      mechanism: json['mechanism'] as String,
      clinicalSignificance: json['clinicalSignificance'] as String,
      management: json['management'] as String,
      references: json['references'] as String?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      detectedBy: json['detectedBy'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication1Id': medication1Id,
      'medication2Id': medication2Id,
      'medication1Name': medication1Name,
      'medication2Name': medication2Name,
      'severity': severity.name,
      'description': description,
      'mechanism': mechanism,
      'clinicalSignificance': clinicalSignificance,
      'management': management,
      'references': references,
      'detectedAt': detectedAt.toIso8601String(),
      'detectedBy': detectedBy,
      'metadata': metadata,
    };
  }

  // Check if interaction is severe
  bool get isSevere {
    return severity == InteractionSeverity.severe || 
           severity == InteractionSeverity.contraindicated;
  }
}

class MedicationMonitoring {
  final String id;
  final String prescriptionId;
  final String patientId;
  final String psychiatristId;
  final MonitoringType type;
  final String parameter;
  final String value;
  final String unit;
  final DateTime measuredAt;
  final String? notes;
  final String? actionTaken;
  final Map<String, dynamic> metadata;

  const MedicationMonitoring({
    required this.id,
    required this.prescriptionId,
    required this.patientId,
    required this.psychiatristId,
    required this.type,
    required this.parameter,
    required this.value,
    required this.unit,
    required this.measuredAt,
    this.notes,
    this.actionTaken,
    this.metadata = const {},
  });

  factory MedicationMonitoring.fromJson(Map<String, dynamic> json) {
    return MedicationMonitoring(
      id: json['id'] as String,
      prescriptionId: json['prescriptionId'] as String,
      patientId: json['patientId'] as String,
      psychiatristId: json['psychiatristId'] as String,
      type: MonitoringType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MonitoringType.laboratory,
      ),
      parameter: json['parameter'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      notes: json['notes'] as String?,
      actionTaken: json['actionTaken'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'type': type.name,
      'parameter': parameter,
      'value': value,
      'unit': unit,
      'measuredAt': measuredAt.toIso8601String(),
      'notes': notes,
      'actionTaken': actionTaken,
      'metadata': metadata,
    };
  }
}

class MedicationAdherence {
  final String id;
  final String prescriptionId;
  final String patientId;
  final DateTime date;
  final bool taken;
  final String? reason;
  final String? notes;
  final Map<String, dynamic> metadata;

  const MedicationAdherence({
    required this.id,
    required this.prescriptionId,
    required this.patientId,
    required this.date,
    required this.taken,
    this.reason,
    this.notes,
    this.metadata = const {},
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'] as String,
      prescriptionId: json['prescriptionId'] as String,
      patientId: json['patientId'] as String,
      date: DateTime.parse(json['date'] as String),
      taken: json['taken'] as bool,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescriptionId': prescriptionId,
      'patientId': patientId,
      'date': date.toIso8601String(),
      'taken': taken,
      'reason': reason,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

enum PrescriptionStatus {
  active,
  suspended,
  discontinued,
  expired,
  completed,
}

enum InteractionSeverity {
  minor,
  moderate,
  major,
  severe,
  contraindicated,
}

enum MonitoringType {
  laboratory,
  vital,
  clinical,
  behavioral,
  other,
}
