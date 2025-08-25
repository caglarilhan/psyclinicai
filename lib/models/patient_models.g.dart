// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientData _$PatientDataFromJson(Map<String, dynamic> json) => PatientData(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  gender: json['gender'] as String,
  dateOfBirth: json['dateOfBirth'] as String,
  phoneNumber: json['phoneNumber'] as String,
  email: json['email'] as String,
  address: json['address'] as String,
  emergencyContact: json['emergencyContact'] as String,
  emergencyPhone: json['emergencyPhone'] as String,
  insuranceProvider: json['insuranceProvider'] as String,
  insuranceNumber: json['insuranceNumber'] as String,
  primaryDiagnosis: json['primaryDiagnosis'] as String,
  secondaryDiagnosis: json['secondaryDiagnosis'] as String,
  allergies: (json['allergies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medications: (json['medications'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  medicalHistory: json['medicalHistory'] as String,
  psychiatricHistory: json['psychiatricHistory'] as String,
  familyHistory: json['familyHistory'] as String,
  occupation: json['occupation'] as String,
  maritalStatus: json['maritalStatus'] as String,
  children: (json['children'] as num).toInt(),
  referralSource: json['referralSource'] as String,
  treatmentGoals: (json['treatmentGoals'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  riskFactors: (json['riskFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  protectiveFactors: (json['protectiveFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String,
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PatientDataToJson(PatientData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'dateOfBirth': instance.dateOfBirth,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'address': instance.address,
      'emergencyContact': instance.emergencyContact,
      'emergencyPhone': instance.emergencyPhone,
      'insuranceProvider': instance.insuranceProvider,
      'insuranceNumber': instance.insuranceNumber,
      'primaryDiagnosis': instance.primaryDiagnosis,
      'secondaryDiagnosis': instance.secondaryDiagnosis,
      'allergies': instance.allergies,
      'medications': instance.medications,
      'medicalHistory': instance.medicalHistory,
      'psychiatricHistory': instance.psychiatricHistory,
      'familyHistory': instance.familyHistory,
      'occupation': instance.occupation,
      'maritalStatus': instance.maritalStatus,
      'children': instance.children,
      'referralSource': instance.referralSource,
      'treatmentGoals': instance.treatmentGoals,
      'riskFactors': instance.riskFactors,
      'protectiveFactors': instance.protectiveFactors,
      'notes': instance.notes,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
