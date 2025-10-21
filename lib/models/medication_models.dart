class MedicationRecord {
  final String id;
  final String patientId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String route; // oral, IV, IM, etc.
  final DateTime startDate;
  final DateTime? endDate;
  final String prescribedBy; // clinician ID
  final String? notes;
  final MedicationStatus status;
  final List<MedicationDose> doses;

  const MedicationRecord({
    required this.id,
    required this.patientId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.startDate,
    this.endDate,
    required this.prescribedBy,
    this.notes,
    this.status = MedicationStatus.active,
    this.doses = const [],
  });

  factory MedicationRecord.fromJson(Map<String, dynamic> json) {
    return MedicationRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      route: json['route'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      prescribedBy: json['prescribedBy'] as String,
      notes: json['notes'] as String?,
      status: MedicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MedicationStatus.active,
      ),
      doses: (json['doses'] as List<dynamic>?)
          ?.map((dose) => MedicationDose.fromJson(dose as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'prescribedBy': prescribedBy,
      'notes': notes,
      'status': status.name,
      'doses': doses.map((dose) => dose.toJson()).toList(),
    };
  }

  MedicationRecord copyWith({
    String? id,
    String? patientId,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? route,
    DateTime? startDate,
    DateTime? endDate,
    String? prescribedBy,
    String? notes,
    MedicationStatus? status,
    List<MedicationDose>? doses,
  }) {
    return MedicationRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      doses: doses ?? this.doses,
    );
  }

  // İlaç uyumluluk oranı hesaplama
  double get adherenceRate {
    if (doses.isEmpty) return 0.0;
    
    final totalDoses = doses.length;
    final takenDoses = doses.where((dose) => dose.status == DoseStatus.taken).length;
    
    return takenDoses / totalDoses;
  }

  // Son doz zamanı
  DateTime? get lastDoseTime {
    if (doses.isEmpty) return null;
    
    final takenDoses = doses
        .where((dose) => dose.status == DoseStatus.taken)
        .toList()
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
    
    return takenDoses.isNotEmpty ? takenDoses.first.scheduledTime : null;
  }

  // Kaçırılan doz sayısı
  int get missedDosesCount {
    return doses.where((dose) => dose.status == DoseStatus.missed).length;
  }
}

class MedicationDose {
  final String id;
  final String medicationRecordId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;
  final String? notes;
  final String? takenBy; // nurse/patient ID

  const MedicationDose({
    required this.id,
    required this.medicationRecordId,
    required this.scheduledTime,
    this.takenTime,
    this.status = DoseStatus.scheduled,
    this.notes,
    this.takenBy,
  });

  factory MedicationDose.fromJson(Map<String, dynamic> json) {
    return MedicationDose(
      id: json['id'] as String,
      medicationRecordId: json['medicationRecordId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] != null 
          ? DateTime.parse(json['takenTime'] as String) 
          : null,
      status: DoseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DoseStatus.scheduled,
      ),
      notes: json['notes'] as String?,
      takenBy: json['takenBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationRecordId': medicationRecordId,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'takenBy': takenBy,
    };
  }

  MedicationDose copyWith({
    String? id,
    String? medicationRecordId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
    String? notes,
    String? takenBy,
  }) {
    return MedicationDose(
      id: id ?? this.id,
      medicationRecordId: medicationRecordId ?? this.medicationRecordId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      takenBy: takenBy ?? this.takenBy,
    );
  }
}

enum MedicationStatus {
  active,
  completed,
  discontinued,
  suspended,
}

enum DoseStatus {
  scheduled,
  taken,
  missed,
  skipped,
}

class MedicationInteraction {
  final String id;
  final String medication1Id;
  final String medication2Id;
  final String medication1Name;
  final String medication2Name;
  final InteractionSeverity severity;
  final String description;
  final String? recommendation;
  final DateTime detectedAt;

  const MedicationInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication2Id,
    required this.medication1Name,
    required this.medication2Name,
    required this.severity,
    required this.description,
    this.recommendation,
    required this.detectedAt,
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
      recommendation: json['recommendation'] as String?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
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
      'recommendation': recommendation,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }
}

enum InteractionSeverity {
  none,
  minor,
  mild,
  moderate,
  major,
  contraindicated,
}

class MedicationAlert {
  final String id;
  final String patientId;
  final String medicationRecordId;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const MedicationAlert({
    required this.id,
    required this.patientId,
    required this.medicationRecordId,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory MedicationAlert.fromJson(Map<String, dynamic> json) {
    return MedicationAlert(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationRecordId: json['medicationRecordId'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.missedDose,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationRecordId': medicationRecordId,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }
}

enum AlertType {
  missedDose,
  overdueDose,
  drugInteraction,
  allergyAlert,
  dosageError,
  refillNeeded,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

enum MedicationClass {
  antidepressant,
  anxiolytic,
  antipsychotic,
  moodStabilizer,
  stimulant,
  sedative,
  analgesic,
  anticonvulsant,
  other,
}

// Eksik modeller - MedicationService için
class DrugInteraction {
  final String id;
  final String medication1Id;
  final String medication2Id;
  final String medication1Name;
  final String medication2Name;
  final InteractionSeverity severity;
  final InteractionType type;
  final String? mechanism;
  final String description;
  final String? clinicalSignificance;
  final List<String>? symptoms;
  final List<String>? recommendations;
  final List<String>? alternatives;
  final List<String>? monitoring;
  final String? evidence;
  final String? source;
  final String? recommendation;
  final DateTime detectedAt;

  DrugInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication2Id,
    required this.medication1Name,
    required this.medication2Name,
    required this.severity,
    required this.type,
    this.mechanism,
    required this.description,
    this.clinicalSignificance,
    this.symptoms,
    this.recommendations,
    this.alternatives,
    this.monitoring,
    this.evidence,
    this.source,
    this.recommendation,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      id: json['id'] as String,
      medication1Id: json['medication1Id'] as String,
      medication2Id: json['medication2Id'] as String,
      medication1Name: json['medication1Name'] as String,
      medication2Name: json['medication2Name'] as String,
      severity: InteractionSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => InteractionSeverity.moderate,
      ),
      type: InteractionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InteractionType.pharmacokinetic,
      ),
      mechanism: json['mechanism'] as String?,
      description: json['description'] as String,
      clinicalSignificance: json['clinicalSignificance'] as String?,
      symptoms: (json['symptoms'] as List?)?.cast<String>(),
      recommendations: (json['recommendations'] as List?)?.cast<String>(),
      alternatives: (json['alternatives'] as List?)?.cast<String>(),
      monitoring: (json['monitoring'] as List?)?.cast<String>(),
      evidence: json['evidence'] as String?,
      source: json['source'] as String?,
      recommendation: json['recommendation'] as String?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
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
      'type': type.name,
      'mechanism': mechanism,
      'description': description,
      'clinicalSignificance': clinicalSignificance,
      'symptoms': symptoms,
      'recommendations': recommendations,
      'alternatives': alternatives,
      'monitoring': monitoring,
      'evidence': evidence,
      'source': source,
      'recommendation': recommendation,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }
}

enum InteractionType {
  pharmacokinetic,
  pharmacodynamic,
  chemical,
  physical,
}

class DosageTitration {
  final String id;
  final String medicationId;
  final TitrationStrategy strategy;
  final double startingDose;
  final double targetDose;
  final double currentDose;
  final int titrationDays;
  final DateTime startDate;
  final DateTime? completionDate;
  final String? notes;

  const DosageTitration({
    required this.id,
    required this.medicationId,
    required this.strategy,
    required this.startingDose,
    required this.targetDose,
    required this.currentDose,
    required this.titrationDays,
    required this.startDate,
    this.completionDate,
    this.notes,
  });

  factory DosageTitration.fromJson(Map<String, dynamic> json) {
    return DosageTitration(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      strategy: TitrationStrategy.values.firstWhere(
        (e) => e.name == json['strategy'],
        orElse: () => TitrationStrategy.startLowGoSlow,
      ),
      startingDose: json['startingDose'] as double,
      targetDose: json['targetDose'] as double,
      currentDose: json['currentDose'] as double,
      titrationDays: json['titrationDays'] as int,
      startDate: DateTime.parse(json['startDate'] as String),
      completionDate: json['completionDate'] != null 
          ? DateTime.parse(json['completionDate'] as String) 
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'strategy': strategy.name,
      'startingDose': startingDose,
      'targetDose': targetDose,
      'currentDose': currentDose,
      'titrationDays': titrationDays,
      'startDate': startDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

enum TitrationStrategy {
  startLowGoSlow,
  rapidTitration,
  maintenanceDose,
  prnDosing,
}

class Prescription {
  final String id;
  final String patientId;
  final String clinicianId;
  final List<PrescribedMedication> medications;
  final DateTime prescribedDate;
  final PrescriptionStatus status;
  final String? notes;
  final DateTime? expiryDate;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.medications,
    required this.prescribedDate,
    this.status = PrescriptionStatus.pending,
    this.notes,
    this.expiryDate,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      medications: (json['medications'] as List<dynamic>)
          .map((m) => PrescribedMedication.fromJson(m as Map<String, dynamic>))
          .toList(),
      prescribedDate: DateTime.parse(json['prescribedDate'] as String),
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrescriptionStatus.pending,
      ),
      notes: json['notes'] as String?,
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'clinicianId': clinicianId,
      'medications': medications.map((m) => m.toJson()).toList(),
      'prescribedDate': prescribedDate.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}

class PrescribedMedication {
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String route;
  final int quantity;
  final String? instructions;

  const PrescribedMedication({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.route,
    required this.quantity,
    this.instructions,
  });

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) {
    return PrescribedMedication(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      route: json['route'] as String,
      quantity: json['quantity'] as int,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'quantity': quantity,
      'instructions': instructions,
    };
  }
}

enum PrescriptionStatus {
  pending,
  approved,
  dispensed,
  cancelled,
  expired,
}

class MedicationAdherence {
  final String id;
  final String patientId;
  final String medicationId;
  final AdherenceStatus status;
  final double adherenceRate;
  final List<AdherenceEvent> events;
  final DateTime lastUpdated;

  const MedicationAdherence({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.status,
    required this.adherenceRate,
    required this.events,
    required this.lastUpdated,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      status: AdherenceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AdherenceStatus.good,
      ),
      adherenceRate: json['adherenceRate'] as double,
      events: (json['events'] as List<dynamic>)
          .map((e) => AdherenceEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationId': medicationId,
      'status': status.name,
      'adherenceRate': adherenceRate,
      'events': events.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  MedicationAdherence copyWith({
    String? id,
    String? patientId,
    String? medicationId,
    AdherenceStatus? status,
    double? adherenceRate,
    List<AdherenceEvent>? events,
    DateTime? lastUpdated,
  }) {
    return MedicationAdherence(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      medicationId: medicationId ?? this.medicationId,
      status: status ?? this.status,
      adherenceRate: adherenceRate ?? this.adherenceRate,
      events: events ?? this.events,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AdherenceEvent {
  final String id;
  final AdherenceEventType type;
  final DateTime timestamp;
  final String? notes;

  const AdherenceEvent({
    required this.id,
    required this.type,
    required this.timestamp,
    this.notes,
  });

  factory AdherenceEvent.fromJson(Map<String, dynamic> json) {
    return AdherenceEvent(
      id: json['id'] as String,
      type: AdherenceEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AdherenceEventType.taken,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}

enum AdherenceEventType {
  taken,
  missed,
  delayed,
  skipped,
  doubled,
  other,
}

enum AdherenceStatus {
  excellent,
  good,
  fair,
  poor,
  nonAdherent,
}

// Diğer eksik modeller
class Medication {
  final String id;
  final String name;
  final String genericName;
  final String? brandName;
  final String? atcCode;
  final String? rxNormCode;
  final String? dinCode;
  final String? barcode;
  final MedicationClass? medicationClass;
  final List<String>? activeIngredients;
  final List<String>? inactiveIngredients;
  final String? dosageForm;
  final List<String>? strengths;
  final String? manufacturer;
  final String? country;
  final bool? isControlled;
  final bool? requiresPrescription;
  final List<String>? indications;
  final List<String>? contraindications;
  final List<String>? sideEffects;
  final List<String>? warnings;
  final List<String>? precautions;
  final List<String>? drugInteractions;
  final List<String>? foodInteractions;
  final List<String>? labInteractions;
  final List<String>? monitoringRequirements;
  final List<String>? pregnancyCategory;
  final List<String>? breastfeedingCategory;
  final List<String>? pediatricUse;
  final List<String>? geriatricUse;
  final List<String>? renalAdjustment;
  final List<String>? hepaticAdjustment;
  final Map<String, dynamic>? metadata;
  final bool? isActive;
  final DateTime? lastUpdated;
  final List<String>? interactions;
  final String? category;
  final String? description;

  const Medication({
    required this.id,
    required this.name,
    required this.genericName,
    this.brandName,
    this.atcCode,
    this.rxNormCode,
    this.dinCode,
    this.barcode,
    this.medicationClass,
    this.activeIngredients,
    this.inactiveIngredients,
    this.dosageForm,
    this.strengths,
    this.manufacturer,
    this.country,
    this.isControlled,
    this.requiresPrescription,
    this.indications,
    this.contraindications,
    this.sideEffects,
    this.warnings,
    this.precautions,
    this.drugInteractions,
    this.foodInteractions,
    this.labInteractions,
    this.monitoringRequirements,
    this.pregnancyCategory,
    this.breastfeedingCategory,
    this.pediatricUse,
    this.geriatricUse,
    this.renalAdjustment,
    this.hepaticAdjustment,
    this.metadata,
    this.isActive,
    this.lastUpdated,
    this.interactions,
    this.category,
    this.description,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      brandName: json['brandName'] as String?,
      atcCode: json['atcCode'] as String?,
      rxNormCode: json['rxNormCode'] as String?,
      dinCode: json['dinCode'] as String?,
      barcode: json['barcode'] as String?,
      medicationClass: json['medicationClass'] != null 
          ? MedicationClass.values.firstWhere(
              (e) => e.name == json['medicationClass'],
              orElse: () => MedicationClass.other,
            )
          : null,
      activeIngredients: (json['activeIngredients'] as List?)?.cast<String>(),
      inactiveIngredients: (json['inactiveIngredients'] as List?)?.cast<String>(),
      dosageForm: json['dosageForm'] as String?,
      strengths: (json['strengths'] as List?)?.cast<String>(),
      manufacturer: json['manufacturer'] as String?,
      country: json['country'] as String?,
      isControlled: json['isControlled'] as bool?,
      requiresPrescription: json['requiresPrescription'] as bool?,
      indications: (json['indications'] as List?)?.cast<String>(),
      contraindications: (json['contraindications'] as List?)?.cast<String>(),
      sideEffects: (json['sideEffects'] as List?)?.cast<String>(),
      warnings: (json['warnings'] as List?)?.cast<String>(),
      precautions: (json['precautions'] as List?)?.cast<String>(),
      drugInteractions: (json['drugInteractions'] as List?)?.cast<String>(),
      foodInteractions: (json['foodInteractions'] as List?)?.cast<String>(),
      labInteractions: (json['labInteractions'] as List?)?.cast<String>(),
      monitoringRequirements: (json['monitoringRequirements'] as List?)?.cast<String>(),
      pregnancyCategory: (json['pregnancyCategory'] as List?)?.cast<String>(),
      breastfeedingCategory: (json['breastfeedingCategory'] as List?)?.cast<String>(),
      pediatricUse: (json['pediatricUse'] as List?)?.cast<String>(),
      geriatricUse: (json['geriatricUse'] as List?)?.cast<String>(),
      renalAdjustment: (json['renalAdjustment'] as List?)?.cast<String>(),
      hepaticAdjustment: (json['hepaticAdjustment'] as List?)?.cast<String>(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool?,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
      interactions: (json['interactions'] as List?)?.cast<String>(),
      category: json['category'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'brandName': brandName,
      'atcCode': atcCode,
      'rxNormCode': rxNormCode,
      'dinCode': dinCode,
      'barcode': barcode,
      'medicationClass': medicationClass?.name,
      'activeIngredients': activeIngredients,
      'inactiveIngredients': inactiveIngredients,
      'dosageForm': dosageForm,
      'strengths': strengths,
      'manufacturer': manufacturer,
      'country': country,
      'isControlled': isControlled,
      'requiresPrescription': requiresPrescription,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'warnings': warnings,
      'precautions': precautions,
      'drugInteractions': drugInteractions,
      'foodInteractions': foodInteractions,
      'labInteractions': labInteractions,
      'monitoringRequirements': monitoringRequirements,
      'pregnancyCategory': pregnancyCategory,
      'breastfeedingCategory': breastfeedingCategory,
      'pediatricUse': pediatricUse,
      'geriatricUse': geriatricUse,
      'renalAdjustment': renalAdjustment,
      'hepaticAdjustment': hepaticAdjustment,
      'metadata': metadata,
      'isActive': isActive,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'interactions': interactions,
      'category': category,
      'description': description,
    };
  }
}

class SideEffectReport {
  final String id;
  final String patientId;
  final String medicationId;
  final String sideEffect;
  final String severity;
  final DateTime reportedAt;
  final String? notes;

  const SideEffectReport({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.sideEffect,
    required this.severity,
    required this.reportedAt,
    this.notes,
  });

  factory SideEffectReport.fromJson(Map<String, dynamic> json) {
    return SideEffectReport(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      sideEffect: json['sideEffect'] as String,
      severity: json['severity'] as String,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationId': medicationId,
      'sideEffect': sideEffect,
      'severity': severity,
      'reportedAt': reportedAt.toIso8601String(),
      'notes': notes,
    };
  }
}

class MedicationReminder {
  final String id;
  final String patientId;
  final String medicationId;
  final DateTime reminderTime;
  final String message;
  final bool isActive;

  const MedicationReminder({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.reminderTime,
    required this.message,
    this.isActive = true,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      reminderTime: DateTime.parse(json['reminderTime'] as String),
      message: json['message'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationId': medicationId,
      'reminderTime': reminderTime.toIso8601String(),
      'message': message,
      'isActive': isActive,
    };
  }
}

class MedicationHistory {
  final String id;
  final String patientId;
  final String medicationId;
  final String action;
  final DateTime timestamp;
  final String? notes;

  const MedicationHistory({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.action,
    required this.timestamp,
    this.notes,
  });

  factory MedicationHistory.fromJson(Map<String, dynamic> json) {
    return MedicationHistory(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationId': medicationId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}

// Laboratory modelleri
class LaboratoryTest {
  final String id;
  final String name;
  final String category;
  final String? description;

  const LaboratoryTest({
    required this.id,
    required this.name,
    required this.category,
    this.description,
  });

  factory LaboratoryTest.fromJson(Map<String, dynamic> json) {
    return LaboratoryTest(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
    };
  }
}

class LaboratoryResult {
  final String id;
  final String testId;
  final String patientId;
  final String value;
  final String unit;
  final String referenceRange;
  final DateTime testDate;
  final String? notes;

  const LaboratoryResult({
    required this.id,
    required this.testId,
    required this.patientId,
    required this.value,
    required this.unit,
    required this.referenceRange,
    required this.testDate,
    this.notes,
  });

  factory LaboratoryResult.fromJson(Map<String, dynamic> json) {
    return LaboratoryResult(
      id: json['id'] as String,
      testId: json['testId'] as String,
      patientId: json['patientId'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      referenceRange: json['referenceRange'] as String,
      testDate: DateTime.parse(json['testDate'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'patientId': patientId,
      'value': value,
      'unit': unit,
      'referenceRange': referenceRange,
      'testDate': testDate.toIso8601String(),
      'notes': notes,
    };
  }
}

class MedicationMonitoring {
  final String id;
  final String patientId;
  final String medicationId;
  final String monitoringType;
  final String value;
  final DateTime monitoredAt;
  final String? notes;

  const MedicationMonitoring({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.monitoringType,
    required this.value,
    required this.monitoredAt,
    this.notes,
  });

  factory MedicationMonitoring.fromJson(Map<String, dynamic> json) {
    return MedicationMonitoring(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      medicationId: json['medicationId'] as String,
      monitoringType: json['monitoringType'] as String,
      value: json['value'] as String,
      monitoredAt: DateTime.parse(json['monitoredAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'medicationId': medicationId,
      'monitoringType': monitoringType,
      'value': value,
      'monitoredAt': monitoredAt.toIso8601String(),
      'notes': notes,
    };
  }
}