class DiagnosisModel {
  final String code;
  final String name;
  final String description;
  final String category;
  final String severity;
  final String standard;
  final List<String> symptoms;
  final List<String> treatments;
  final Map<String, dynamic>? metadata;

  const DiagnosisModel({
    required this.code,
    required this.name,
    required this.description,
    required this.category,
    required this.severity,
    required this.standard,
    required this.symptoms,
    required this.treatments,
    this.metadata,
  });

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      severity: json['severity'] ?? '',
      standard: json['standard'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      treatments: List<String>.from(json['treatments'] ?? []),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'category': category,
      'severity': severity,
      'standard': standard,
      'symptoms': symptoms,
      'treatments': treatments,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'DiagnosisModel(code: $code, name: $name, standard: $standard)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiagnosisModel &&
        other.code == code &&
        other.standard == standard;
  }

  @override
  int get hashCode {
    return code.hashCode ^ standard.hashCode;
  }

  // Kopyalama metodu
  DiagnosisModel copyWith({
    String? code,
    String? name,
    String? description,
    String? category,
    String? severity,
    String? standard,
    List<String>? symptoms,
    List<String>? treatments,
    Map<String, dynamic>? metadata,
  }) {
    return DiagnosisModel(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      standard: standard ?? this.standard,
      symptoms: symptoms ?? this.symptoms,
      treatments: treatments ?? this.treatments,
      metadata: metadata ?? this.metadata,
    );
  }
}
