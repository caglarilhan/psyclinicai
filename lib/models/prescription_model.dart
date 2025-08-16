class PrescriptionModel {
  final String id;
  final String patientName;
  final String diagnosis;
  final List<MedicationModel> medications;
  final List<String> interactions;
  final DateTime createdAt;
  final String status;
  final String? notes;
  final String? doctorName;

  const PrescriptionModel({
    required this.id,
    required this.patientName,
    required this.diagnosis,
    required this.medications,
    required this.interactions,
    required this.createdAt,
    required this.status,
    this.notes,
    this.doctorName,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? '',
      patientName: json['patientName'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      medications: (json['medications'] as List<dynamic>?)
              ?.map((med) => MedicationModel.fromJson(med))
              .toList() ??
          [],
      interactions: List<String>.from(json['interactions'] ?? []),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'Active',
      notes: json['notes'],
      doctorName: json['doctorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'diagnosis': diagnosis,
      'medications': medications.map((med) => med.toJson()).toList(),
      'interactions': interactions,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'notes': notes,
      'doctorName': doctorName,
    };
  }

  @override
  String toString() {
    return 'PrescriptionModel(id: $id, patientName: $patientName, diagnosis: $diagnosis)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrescriptionModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  // Kopyalama metodu
  PrescriptionModel copyWith({
    String? id,
    String? patientName,
    String? diagnosis,
    List<MedicationModel>? medications,
    List<String>? interactions,
    DateTime? createdAt,
    String? status,
    String? notes,
    String? doctorName,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      diagnosis: diagnosis ?? this.diagnosis,
      medications: medications ?? this.medications,
      interactions: interactions ?? this.interactions,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}

class MedicationModel {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;
  final String? sideEffects;
  final String? contraindications;
  final Map<String, dynamic>? metadata;

  const MedicationModel({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
    this.sideEffects,
    this.contraindications,
    this.metadata,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'] ?? '',
      sideEffects: json['sideEffects'],
      contraindications: json['contraindications'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'MedicationModel(name: $name, dosage: $dosage, frequency: $frequency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationModel &&
        other.name == name &&
        other.dosage == dosage;
  }

  @override
  int get hashCode {
    return name.hashCode ^ dosage.hashCode;
  }

  // Kopyalama metodu
  MedicationModel copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    String? sideEffects,
    String? contraindications,
    Map<String, dynamic>? metadata,
  }) {
    return MedicationModel(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      sideEffects: sideEffects ?? this.sideEffects,
      contraindications: contraindications ?? this.contraindications,
      metadata: metadata ?? this.metadata,
    );
  }
}
