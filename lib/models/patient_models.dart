import 'package:json_annotation/json_annotation.dart';

part 'patient_models.g.dart';

/// Patient data model for healthcare patients
@JsonSerializable()
class PatientData {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final String email;
  final String address;
  final String emergencyContact;
  final String emergencyPhone;
  final String insuranceProvider;
  final String insuranceNumber;
  final String primaryDiagnosis;
  final String secondaryDiagnosis;
  final List<String> allergies;
  final List<String> medications;
  final String medicalHistory;
  final String psychiatricHistory;
  final String familyHistory;
  final String occupation;
  final String maritalStatus;
  final int children;
  final String referralSource;
  final List<String> treatmentGoals;
  final List<String> riskFactors;
  final List<String> protectiveFactors;
  final String notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientData({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.insuranceProvider,
    required this.insuranceNumber,
    required this.primaryDiagnosis,
    required this.secondaryDiagnosis,
    required this.allergies,
    required this.medications,
    required this.medicalHistory,
    required this.psychiatricHistory,
    required this.familyHistory,
    required this.occupation,
    required this.maritalStatus,
    required this.children,
    required this.referralSource,
    required this.treatmentGoals,
    required this.riskFactors,
    required this.protectiveFactors,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PatientData.fromJson(Map<String, dynamic> json) =>
      _$PatientDataFromJson(json);

  Map<String, dynamic> toJson() => _$PatientDataToJson(this);
}
