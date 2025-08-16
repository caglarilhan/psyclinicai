import 'package:flutter/material.dart';

enum ClientStatus {
  active,
  inactive,
  discharged,
  onHold,
  emergency
}

enum ClientRiskLevel {
  low,
  medium,
  high,
  critical
}

class ClientModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final ClientStatus status;
  final ClientRiskLevel riskLevel;
  final String? primaryDiagnosis;
  final String? secondaryDiagnosis;
  final List<String> medications;
  final List<String> allergies;
  final String? notes;
  final DateTime firstSessionDate;
  final DateTime? lastSessionDate;
  final int totalSessions;
  final String assignedTherapistId;
  final Map<String, dynamic> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    this.phoneNumber,
    this.email,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    this.status = ClientStatus.active,
    this.riskLevel = ClientRiskLevel.low,
    this.primaryDiagnosis,
    this.secondaryDiagnosis,
    this.medications = const [],
    this.allergies = const [],
    this.notes,
    required this.firstSessionDate,
    this.lastSessionDate,
    this.totalSessions = 0,
    required this.assignedTherapistId,
    this.customFields = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get displayName => middleName != null ? '$firstName $middleName $lastName' : fullName;
  
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool get isActive => status == ClientStatus.active;
  bool get isHighRisk => riskLevel == ClientRiskLevel.high || riskLevel == ClientRiskLevel.critical;

  ClientModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? middleName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    ClientStatus? status,
    ClientRiskLevel? riskLevel,
    String? primaryDiagnosis,
    String? secondaryDiagnosis,
    List<String>? medications,
    List<String>? allergies,
    String? notes,
    DateTime? firstSessionDate,
    DateTime? lastSessionDate,
    int? totalSessions,
    String? assignedTherapistId,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      status: status ?? this.status,
      riskLevel: riskLevel ?? this.riskLevel,
      primaryDiagnosis: primaryDiagnosis ?? this.primaryDiagnosis,
      secondaryDiagnosis: secondaryDiagnosis ?? this.secondaryDiagnosis,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
      firstSessionDate: firstSessionDate ?? this.firstSessionDate,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      totalSessions: totalSessions ?? this.totalSessions,
      assignedTherapistId: assignedTherapistId ?? this.assignedTherapistId,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'status': status.name,
      'riskLevel': riskLevel.name,
      'primaryDiagnosis': primaryDiagnosis,
      'secondaryDiagnosis': secondaryDiagnosis,
      'medications': medications,
      'allergies': allergies,
      'notes': notes,
      'firstSessionDate': firstSessionDate.toIso8601String(),
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'totalSessions': totalSessions,
      'assignedTherapistId': assignedTherapistId,
      'customFields': customFields,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      middleName: json['middleName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      status: ClientStatus.values.firstWhere((e) => e.name == json['status']),
      riskLevel: ClientRiskLevel.values.firstWhere((e) => e.name == json['riskLevel']),
      primaryDiagnosis: json['primaryDiagnosis'],
      secondaryDiagnosis: json['secondaryDiagnosis'],
      medications: List<String>.from(json['medications'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      notes: json['notes'],
      firstSessionDate: DateTime.parse(json['firstSessionDate']),
      lastSessionDate: json['lastSessionDate'] != null ? DateTime.parse(json['lastSessionDate']) : null,
      totalSessions: json['totalSessions'] ?? 0,
      assignedTherapistId: json['assignedTherapistId'],
      customFields: Map<String, dynamic>.from(json['customFields'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ClientSession {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime sessionDate;
  final Duration duration;
  final String sessionType;
  final String notes;
  final Map<String, dynamic> aiSummary;
  final List<String> goals;
  final List<String> achievements;
  final String? nextSessionPlan;
  final DateTime createdAt;

  ClientSession({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.sessionDate,
    required this.duration,
    required this.sessionType,
    required this.notes,
    required this.aiSummary,
    this.goals = const [],
    this.achievements = const [],
    this.nextSessionPlan,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'sessionDate': sessionDate.toIso8601String(),
      'duration': duration.inMinutes,
      'sessionType': sessionType,
      'notes': notes,
      'aiSummary': aiSummary,
      'goals': goals,
      'achievements': achievements,
      'nextSessionPlan': nextSessionPlan,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ClientSession.fromJson(Map<String, dynamic> json) {
    return ClientSession(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      sessionDate: DateTime.parse(json['sessionDate']),
      duration: Duration(minutes: json['duration']),
      sessionType: json['sessionType'],
      notes: json['notes'],
      aiSummary: Map<String, dynamic>.from(json['aiSummary']),
      goals: List<String>.from(json['goals'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      nextSessionPlan: json['nextSessionPlan'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
