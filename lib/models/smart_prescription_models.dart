import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class PatientReportAnalysis {
  final String id;
  final String patientId;
  final String summary;
  final List<String> detectedDiagnoses;
  final List<String> detectedSymptoms;
  final List<String> detectedMedications;
  final List<String> detectedAllergies;
  final Map<String, String> vitalSigns;
  final double confidenceScore;
  final DateTime analyzedAt;

  PatientReportAnalysis({
    String? id,
    required this.patientId,
    required this.summary,
    this.detectedDiagnoses = const [],
    this.detectedSymptoms = const [],
    this.detectedMedications = const [],
    this.detectedAllergies = const [],
    this.vitalSigns = const {},
    this.confidenceScore = 0.0,
    DateTime? analyzedAt,
  }) : id = id ?? const Uuid().v4(),
       analyzedAt = analyzedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'summary': summary,
      'detectedDiagnoses': detectedDiagnoses,
      'detectedSymptoms': detectedSymptoms,
      'detectedMedications': detectedMedications,
      'detectedAllergies': detectedAllergies,
      'vitalSigns': vitalSigns,
      'confidenceScore': confidenceScore,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory PatientReportAnalysis.fromJson(Map<String, dynamic> json) {
    return PatientReportAnalysis(
      id: json['id'],
      patientId: json['patientId'],
      summary: json['summary'],
      detectedDiagnoses: List<String>.from(json['detectedDiagnoses'] ?? []),
      detectedSymptoms: List<String>.from(json['detectedSymptoms'] ?? []),
      detectedMedications: List<String>.from(json['detectedMedications'] ?? []),
      detectedAllergies: List<String>.from(json['detectedAllergies'] ?? []),
      vitalSigns: Map<String, String>.from(json['vitalSigns'] ?? {}),
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }
}

class SmartPrescriptionRecommendation {
  final String id;
  final String drugName;
  final String dosage;
  final String frequency;
  final String duration;
  final String reason;
  final String monitoring;
  final List<String> contraindications;
  final double confidence;
  final String category;
  final String atcCode;
  final String manufacturer;

  SmartPrescriptionRecommendation({
    String? id,
    required this.drugName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.reason,
    required this.monitoring,
    this.contraindications = const [],
    required this.confidence,
    required this.category,
    required this.atcCode,
    required this.manufacturer,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'drugName': drugName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'reason': reason,
      'monitoring': monitoring,
      'contraindications': contraindications,
      'confidence': confidence,
      'category': category,
      'atcCode': atcCode,
      'manufacturer': manufacturer,
    };
  }

  factory SmartPrescriptionRecommendation.fromJson(Map<String, dynamic> json) {
    return SmartPrescriptionRecommendation(
      id: json['id'],
      drugName: json['drugName'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      reason: json['reason'],
      monitoring: json['monitoring'],
      contraindications: List<String>.from(json['contraindications'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      category: json['category'],
      atcCode: json['atcCode'],
      manufacturer: json['manufacturer'],
    );
  }
}
