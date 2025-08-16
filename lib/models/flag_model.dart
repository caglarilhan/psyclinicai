enum FlagType {
  suicide,
  crisis,
  selfHarm,
  violence,
}

enum FlagSeverity {
  low,
  medium,
  high,
}

enum FlagStatus {
  active,
  resolved,
  escalated,
}

class FlagModel {
  final String id;
  final String patientName;
  final FlagType flagType;
  final FlagSeverity severity;
  final String description;
  final List<String> symptoms;
  final List<String> riskFactors;
  final DateTime createdAt;
  final FlagStatus status;
  final List<String> interventions;
  final String? notes;
  final String? assignedTo;
  final DateTime? resolvedAt;

  const FlagModel({
    required this.id,
    required this.patientName,
    required this.flagType,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.riskFactors,
    required this.createdAt,
    required this.status,
    required this.interventions,
    this.notes,
    this.assignedTo,
    this.resolvedAt,
  });

  factory FlagModel.fromJson(Map<String, dynamic> json) {
    return FlagModel(
      id: json['id'] ?? '',
      patientName: json['patientName'] ?? '',
      flagType: FlagType.values.firstWhere(
        (e) => e.toString() == 'FlagType.${json['flagType']}',
        orElse: () => FlagType.crisis,
      ),
      severity: FlagSeverity.values.firstWhere(
        (e) => e.toString() == 'FlagSeverity.${json['severity']}',
        orElse: () => FlagSeverity.medium,
      ),
      description: json['description'] ?? '',
      symptoms: List<String>.from(json['symptoms'] ?? []),
      riskFactors: List<String>.from(json['riskFactors'] ?? []),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      status: FlagStatus.values.firstWhere(
        (e) => e.toString() == 'FlagStatus.${json['status']}',
        orElse: () => FlagStatus.active,
      ),
      interventions: List<String>.from(json['interventions'] ?? []),
      notes: json['notes'],
      assignedTo: json['assignedTo'],
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'flagType': flagType.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'description': description,
      'symptoms': symptoms,
      'riskFactors': riskFactors,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'interventions': interventions,
      'notes': notes,
      'assignedTo': assignedTo,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FlagModel(id: $id, patientName: $patientName, type: $flagType, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlagModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }

  // Kopyalama metodu
  FlagModel copyWith({
    String? id,
    String? patientName,
    FlagType? flagType,
    FlagSeverity? severity,
    String? description,
    List<String>? symptoms,
    List<String>? riskFactors,
    DateTime? createdAt,
    FlagStatus? status,
    List<String>? interventions,
    String? notes,
    String? assignedTo,
    DateTime? resolvedAt,
  }) {
    return FlagModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      flagType: flagType ?? this.flagType,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      riskFactors: riskFactors ?? this.riskFactors,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      interventions: interventions ?? this.interventions,
      notes: notes ?? this.notes,
      assignedTo: assignedTo ?? this.assignedTo,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  // Flag'ı çözüldü olarak işaretle
  FlagModel markAsResolved() {
    return copyWith(
      status: FlagStatus.resolved,
      resolvedAt: DateTime.now(),
    );
  }

  // Flag'ı eskalasyon için işaretle
  FlagModel markAsEscalated() {
    return copyWith(
      status: FlagStatus.escalated,
    );
  }

  // Flag'a atama yap
  FlagModel assignTo(String person) {
    return copyWith(
      assignedTo: person,
    );
  }

  // Acil durum kontrolü
  bool get isEmergency {
    return severity == FlagSeverity.high &&
        (flagType == FlagType.suicide || flagType == FlagType.violence);
  }

  // Zaman kontrolü (24 saat içinde oluşturulmuş mu?)
  bool get isRecent {
    return DateTime.now().difference(createdAt).inHours < 24;
  }

  // Risk skoru hesaplama
  int get riskScore {
    int score = 0;

    // Severity puanı
    switch (severity) {
      case FlagSeverity.low:
        score += 1;
        break;
      case FlagSeverity.medium:
        score += 3;
        break;
      case FlagSeverity.high:
        score += 5;
        break;
    }

    // Type puanı
    switch (flagType) {
      case FlagType.suicide:
        score += 5;
        break;
      case FlagType.violence:
        score += 4;
        break;
      case FlagType.crisis:
        score += 3;
        break;
      case FlagType.selfHarm:
        score += 2;
        break;
    }

    // Belirti sayısı
    score += symptoms.length;

    // Risk faktörü sayısı
    score += riskFactors.length;

    return score;
  }

  // Risk seviyesi string'i
  String get riskLevel {
    if (riskScore >= 10) return 'Kritik';
    if (riskScore >= 7) return 'Yüksek';
    if (riskScore >= 4) return 'Orta';
    return 'Düşük';
  }
}
