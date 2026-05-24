class Patient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime birthDate;
  final String gender;
  final String? notes;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.gender,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'notes': notes,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      notes: json['notes'] as String?,
    );
  }
}




