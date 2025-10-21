// Laboratory modelleri - MedicationService için
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