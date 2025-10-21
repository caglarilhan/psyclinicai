import 'package:uuid/uuid.dart';

class Patient {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? gender;
  final String? notes;
  final bool kvkkConsent;
  final List<String> allergies;
  final List<String> currentMedications;
  final List<String> diagnosis;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    String? id,
    required this.fullName,
    this.email,
    this.phone,
    this.birthDate,
    this.gender,
    this.notes,
    this.kvkkConsent = false,
    this.allergies = const [],
    this.currentMedications = const [],
    this.diagnosis = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Patient copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? gender,
    String? notes,
    bool? kvkkConsent,
    List<String>? allergies,
    List<String>? currentMedications,
    List<String>? diagnosis,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      kvkkConsent: kvkkConsent ?? this.kvkkConsent,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      diagnosis: diagnosis ?? this.diagnosis,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'notes': notes,
      'kvkkConsent': kvkkConsent,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'diagnosis': diagnosis,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      notes: json['notes'],
      kvkkConsent: json['kvkkConsent'] ?? false,
      allergies: List<String>.from(json['allergies'] ?? []),
      currentMedications: List<String>.from(json['currentMedications'] ?? []),
      diagnosis: List<String>.from(json['diagnosis'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convenience getter for name (alias for fullName)
  String get name => fullName;
}
