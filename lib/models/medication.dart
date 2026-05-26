/// A medication on a patient's regimen (psychiatry / prescriber workflow).
/// Manual entry only — no AI suggestion of medications (clinical safety).
class Medication {
  Medication({
    required this.id,
    required this.patientId,
    required this.name,
    this.dose = '',
    this.frequency = '',
    required this.startedOn,
    this.active = true,
    this.notes = '',
  });

  final String id;
  final String patientId;
  final String name;
  final String dose;
  final String frequency;
  final DateTime startedOn;
  final bool active;
  final String notes;

  Medication copyWith({bool? active}) => Medication(
        id: id,
        patientId: patientId,
        name: name,
        dose: dose,
        frequency: frequency,
        startedOn: startedOn,
        active: active ?? this.active,
        notes: notes,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'name': name,
        'dose': dose,
        'frequency': frequency,
        'startedOn': startedOn.toIso8601String(),
        'active': active,
        'notes': notes,
      };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        patientId: json['patientId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        dose: json['dose'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        startedOn: DateTime.tryParse(json['startedOn'] as String? ?? '') ??
            DateTime.now(),
        active: json['active'] as bool? ?? true,
        notes: json['notes'] as String? ?? '',
      );
}
