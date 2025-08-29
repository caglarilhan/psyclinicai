enum PrescriptionStatus {
  active,
  completed,
  cancelled,
  expired,
  suspended,
}

enum PrescriptionType {
  initial,
  renewal,
  modification,
  emergency,
  maintenance,
}

enum MedicationCategory {
  antidepressant,
  antipsychotic,
  anxiolytic,
  moodStabilizer,
  stimulant,
  sedative,
  hypnotic,
  anticonvulsant,
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

enum Frequency {
  onceDaily,
  twiceDaily,
  threeTimesDaily,
  fourTimesDaily,
  asNeeded,
  everyOtherDay,
  weekly,
  monthly,
  custom,
}

class Prescription {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime prescriptionDate;
  final DateTime? expiryDate;
  final PrescriptionStatus status;
  final PrescriptionType type;
  final String? diagnosis;
  final String? notes;
  final List<PrescribedMedication> medications;
  final List<String> warnings;
  final List<String> contraindications;
  final String? pharmacyNotes;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Prescription({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.prescriptionDate,
    this.expiryDate,
    required this.status,
    required this.type,
    this.diagnosis,
    this.notes,
    required this.medications,
    this.warnings = const [],
    this.contraindications = const [],
    this.pharmacyNotes,
    this.requiresFollowUp = false,
    this.followUpDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Prescription copyWith({
    String? id,
    String? clientId,
    String? therapistId,
    DateTime? prescriptionDate,
    DateTime? expiryDate,
    PrescriptionStatus? status,
    PrescriptionType? type,
    String? diagnosis,
    String? notes,
    List<PrescribedMedication>? medications,
    List<String>? warnings,
    List<String>? contraindications,
    String? pharmacyNotes,
    bool? requiresFollowUp,
    DateTime? followUpDate,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      therapistId: therapistId ?? this.therapistId,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      type: type ?? this.type,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      medications: medications ?? this.medications,
      warnings: warnings ?? this.warnings,
      contraindications: contraindications ?? this.contraindications,
      pharmacyNotes: pharmacyNotes ?? this.pharmacyNotes,
      requiresFollowUp: requiresFollowUp ?? this.requiresFollowUp,
      followUpDate: followUpDate ?? this.followUpDate,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'prescriptionDate': prescriptionDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'diagnosis': diagnosis,
      'notes': notes,
      'medications': medications.map((m) => m.toJson()).toList(),
      'warnings': warnings,
      'contraindications': contraindications,
      'pharmacyNotes': pharmacyNotes,
      'requiresFollowUp': requiresFollowUp,
      'followUpDate': followUpDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String) 
          : null,
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PrescriptionStatus.active,
      ),
      type: PrescriptionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PrescriptionType.initial,
      ),
      diagnosis: json['diagnosis'] as String?,
      notes: json['notes'] as String?,
      medications: (json['medications'] as List)
          .map((m) => PrescribedMedication.fromJson(m))
          .toList(),
      warnings: List<String>.from(json['warnings'] as List? ?? []),
      contraindications: List<String>.from(json['contraindications'] as List? ?? []),
      pharmacyNotes: json['pharmacyNotes'] as String?,
      requiresFollowUp: json['requiresFollowUp'] as bool? ?? false,
      followUpDate: json['followUpDate'] != null 
          ? DateTime.parse(json['followUpDate'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get needsRenewal {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Prescription && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Prescription(id: $id, clientId: $clientId, status: $status)';
  }
}

class PrescribedMedication {
  final String id;
  final String medicationId;
  final String medicationName;
  final String genericName;
  final String dosage;
  final DosageForm dosageForm;
  final Frequency frequency;
  final int quantity;
  final int refills;
  final String? instructions;
  final String? specialInstructions;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isPRN;
  final String? reason;
  final List<String> sideEffects;
  final List<String> interactions;
  final Map<String, dynamic>? metadata;

  const PrescribedMedication({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.genericName,
    required this.dosage,
    required this.dosageForm,
    required this.frequency,
    required this.quantity,
    this.refills = 0,
    this.instructions,
    this.specialInstructions,
    required this.startDate,
    this.endDate,
    this.isPRN = false,
    this.reason,
    this.sideEffects = const [],
    this.interactions = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'genericName': genericName,
      'dosage': dosage,
      'dosageForm': dosageForm.name,
      'frequency': frequency.name,
      'quantity': quantity,
      'refills': refills,
      'instructions': instructions,
      'specialInstructions': specialInstructions,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isPRN': isPRN,
      'reason': reason,
      'sideEffects': sideEffects,
      'interactions': interactions,
      'metadata': metadata,
    };
  }

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) {
    return PrescribedMedication(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      dosageForm: DosageForm.values.firstWhere(
        (e) => e.name == json['dosageForm'],
        orElse: () => DosageForm.tablet,
      ),
      frequency: Frequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => Frequency.onceDaily,
      ),
      quantity: json['quantity'] as int,
      refills: json['refills'] as int? ?? 0,
      instructions: json['instructions'] as String?,
      specialInstructions: json['specialInstructions'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      isPRN: json['isPRN'] as bool? ?? false,
      reason: json['reason'] as String?,
      sideEffects: List<String>.from(json['sideEffects'] as List? ?? []),
      interactions: List<String>.from(json['interactions'] as List? ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String get frequencyText {
    switch (frequency) {
      case Frequency.onceDaily:
        return 'Günde 1 kez';
      case Frequency.twiceDaily:
        return 'Günde 2 kez';
      case Frequency.threeTimesDaily:
        return 'Günde 3 kez';
      case Frequency.fourTimesDaily:
        return 'Günde 4 kez';
      case Frequency.asNeeded:
        return 'Gerektiğinde';
      case Frequency.everyOtherDay:
        return 'Günaşırı';
      case Frequency.weekly:
        return 'Haftada 1 kez';
      case Frequency.monthly:
        return 'Ayda 1 kez';
      case Frequency.custom:
        return 'Özel';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrescribedMedication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PrescribedMedication(id: $id, name: $medicationName, dosage: $dosage)';
  }
}

class Medication {
  final String id;
  final String name;
  final String genericName;
  final MedicationCategory category;
  final DosageForm dosageForm;
  final List<String> availableDosages;
  final String description;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final List<String> warnings;
  final String? pregnancyCategory;
  final String? breastfeedingInfo;
  final String? pediatricInfo;
  final String? geriatricInfo;
  final String? renalInfo;
  final String? hepaticInfo;
  final String? manufacturer;
  final String? brandNames;
  final bool isGeneric;
  final bool isControlled;
  final Map<String, dynamic>? metadata;

  const Medication({
    required this.id,
    required this.name,
    required this.genericName,
    required this.category,
    required this.dosageForm,
    required this.availableDosages,
    required this.description,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.warnings,
    this.pregnancyCategory,
    this.breastfeedingInfo,
    this.pediatricInfo,
    this.geriatricInfo,
    this.renalInfo,
    this.hepaticInfo,
    this.manufacturer,
    this.brandNames,
    this.isGeneric = false,
    this.isControlled = false,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'category': category.name,
      'dosageForm': dosageForm.name,
      'availableDosages': availableDosages,
      'description': description,
      'indications': indications,
      'contraindications': contraindications,
      'sideEffects': sideEffects,
      'interactions': interactions,
      'warnings': warnings,
      'pregnancyCategory': pregnancyCategory,
      'breastfeedingInfo': breastfeedingInfo,
      'pediatricInfo': pediatricInfo,
      'geriatricInfo': geriatricInfo,
      'renalInfo': renalInfo,
      'hepaticInfo': hepaticInfo,
      'manufacturer': manufacturer,
      'brandNames': brandNames,
      'isGeneric': isGeneric,
      'isControlled': isControlled,
      'metadata': metadata,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      genericName: json['genericName'] as String,
      category: MedicationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MedicationCategory.other,
      ),
      dosageForm: DosageForm.values.firstWhere(
        (e) => e.name == json['dosageForm'],
        orElse: () => DosageForm.tablet,
      ),
      availableDosages: List<String>.from(json['availableDosages'] as List),
      description: json['description'] as String,
      indications: List<String>.from(json['indications'] as List),
      contraindications: List<String>.from(json['contraindications'] as List),
      sideEffects: List<String>.from(json['sideEffects'] as List),
      interactions: List<String>.from(json['interactions'] as List),
      warnings: List<String>.from(json['warnings'] as List),
      pregnancyCategory: json['pregnancyCategory'] as String?,
      breastfeedingInfo: json['breastfeedingInfo'] as String?,
      pediatricInfo: json['pediatricInfo'] as String?,
      geriatricInfo: json['geriatricInfo'] as String?,
      renalInfo: json['renalInfo'] as String?,
      hepaticInfo: json['hepaticInfo'] as String?,
      manufacturer: json['manufacturer'] as String?,
      brandNames: json['brandNames'] as String?,
      isGeneric: json['isGeneric'] as bool? ?? false,
      isControlled: json['isControlled'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  String get categoryText {
    switch (category) {
      case MedicationCategory.antidepressant:
        return 'Antidepresan';
      case MedicationCategory.antipsychotic:
        return 'Antipsikotik';
      case MedicationCategory.anxiolytic:
        return 'Anksiyolitik';
      case MedicationCategory.moodStabilizer:
        return 'Duygu Durumu Düzenleyici';
      case MedicationCategory.stimulant:
        return 'Uyarıcı';
      case MedicationCategory.sedative:
        return 'Sakinleştirici';
      case MedicationCategory.hypnotic:
        return 'Uyku İlacı';
      case MedicationCategory.anticonvulsant:
        return 'Antikonvülsan';
      case MedicationCategory.other:
        return 'Diğer';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, category: $category)';
  }
}

class AIPrescriptionSuggestion {
  final String id;
  final String medicationId;
  final String medicationName;
  final String reason;
  final String dosage;
  final Frequency frequency;
  final int duration;
  final double confidence;
  final List<String> evidence;
  final List<String> alternatives;
  final List<String> warnings;
  final String? notes;
  final DateTime generatedAt;
  final String modelVersion;

  const AIPrescriptionSuggestion({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.reason,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.confidence,
    required this.evidence,
    required this.alternatives,
    required this.warnings,
    this.notes,
    required this.generatedAt,
    required this.modelVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'reason': reason,
      'dosage': dosage,
      'frequency': frequency.name,
      'duration': duration,
      'confidence': confidence,
      'evidence': evidence,
      'alternatives': alternatives,
      'warnings': warnings,
      'notes': notes,
      'generatedAt': generatedAt.toIso8601String(),
      'modelVersion': modelVersion,
    };
  }

  factory AIPrescriptionSuggestion.fromJson(Map<String, dynamic> json) {
    return AIPrescriptionSuggestion(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      reason: json['reason'] as String,
      dosage: json['dosage'] as String,
      frequency: Frequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => Frequency.onceDaily,
      ),
      duration: json['duration'] as int,
      confidence: json['confidence'] as double,
      evidence: List<String>.from(json['evidence'] as List),
      alternatives: List<String>.from(json['alternatives'] as List),
      warnings: List<String>.from(json['warnings'] as List),
      notes: json['notes'] as String?,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      modelVersion: json['modelVersion'] as String,
    );
  }
}
