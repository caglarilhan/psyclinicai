class VitalSigns {
  final String id;
  final String patientId;
  final DateTime recordedAt;
  final String recordedBy; // clinician ID
  final VitalSignsData data;
  final String? notes;
  final VitalSignsStatus status;

  const VitalSigns({
    required this.id,
    required this.patientId,
    required this.recordedAt,
    required this.recordedBy,
    required this.data,
    this.notes,
    this.status = VitalSignsStatus.normal,
  });

  factory VitalSigns.fromJson(Map<String, dynamic> json) {
    return VitalSigns(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      recordedBy: json['recordedBy'] as String,
      data: VitalSignsData.fromJson(json['data'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
      status: VitalSignsStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VitalSignsStatus.normal,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'recordedAt': recordedAt.toIso8601String(),
      'recordedBy': recordedBy,
      'data': data.toJson(),
      'notes': notes,
      'status': status.name,
    };
  }

  VitalSigns copyWith({
    String? id,
    String? patientId,
    DateTime? recordedAt,
    String? recordedBy,
    VitalSignsData? data,
    String? notes,
    VitalSignsStatus? status,
  }) {
    return VitalSigns(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedBy: recordedBy ?? this.recordedBy,
      data: data ?? this.data,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

class VitalSignsData {
  final double? systolicBP; // mmHg
  final double? diastolicBP; // mmHg
  final int? heartRate; // bpm
  final double? temperature; // °C
  final int? respiratoryRate; // breaths/min
  final int? oxygenSaturation; // %
  final double? weight; // kg
  final double? height; // cm
  final double? painLevel; // 0-10 scale

  const VitalSignsData({
    this.systolicBP,
    this.diastolicBP,
    this.heartRate,
    this.temperature,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.weight,
    this.height,
    this.painLevel,
  });

  factory VitalSignsData.fromJson(Map<String, dynamic> json) {
    return VitalSignsData(
      systolicBP: json['systolicBP']?.toDouble(),
      diastolicBP: json['diastolicBP']?.toDouble(),
      heartRate: json['heartRate'] as int?,
      temperature: json['temperature']?.toDouble(),
      respiratoryRate: json['respiratoryRate'] as int?,
      oxygenSaturation: json['oxygenSaturation'] as int?,
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      painLevel: json['painLevel']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systolicBP': systolicBP,
      'diastolicBP': diastolicBP,
      'heartRate': heartRate,
      'temperature': temperature,
      'respiratoryRate': respiratoryRate,
      'oxygenSaturation': oxygenSaturation,
      'weight': weight,
      'height': height,
      'painLevel': painLevel,
    };
  }

  // BMI hesaplama
  double? get bmi {
    if (weight == null || height == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // Kan basıncı kategorisi
  BloodPressureCategory get bloodPressureCategory {
    if (systolicBP == null || diastolicBP == null) {
      return BloodPressureCategory.unknown;
    }

    if (systolicBP! < 120 && diastolicBP! < 80) {
      return BloodPressureCategory.normal;
    } else if (systolicBP! < 130 && diastolicBP! < 80) {
      return BloodPressureCategory.elevated;
    } else if (systolicBP! < 140 || diastolicBP! < 90) {
      return BloodPressureCategory.stage1Hypertension;
    } else if (systolicBP! < 180 || diastolicBP! < 120) {
      return BloodPressureCategory.stage2Hypertension;
    } else {
      return BloodPressureCategory.hypertensiveCrisis;
    }
  }

  // Nabız kategorisi
  HeartRateCategory get heartRateCategory {
    if (heartRate == null) return HeartRateCategory.unknown;
    
    if (heartRate! < 60) {
      return HeartRateCategory.bradycardia;
    } else if (heartRate! <= 100) {
      return HeartRateCategory.normal;
    } else {
      return HeartRateCategory.tachycardia;
    }
  }

  // Ateş kategorisi
  TemperatureCategory get temperatureCategory {
    if (temperature == null) return TemperatureCategory.unknown;
    
    if (temperature! < 36.0) {
      return TemperatureCategory.hypothermia;
    } else if (temperature! <= 37.5) {
      return TemperatureCategory.normal;
    } else if (temperature! <= 38.0) {
      return TemperatureCategory.lowGradeFever;
    } else if (temperature! <= 39.0) {
      return TemperatureCategory.fever;
    } else {
      return TemperatureCategory.highFever;
    }
  }
}

enum VitalSignsStatus {
  normal,
  abnormal,
  critical,
  requiresAttention,
}

enum BloodPressureCategory {
  normal,
  elevated,
  stage1Hypertension,
  stage2Hypertension,
  hypertensiveCrisis,
  unknown,
}

enum HeartRateCategory {
  normal,
  bradycardia,
  tachycardia,
  unknown,
}

enum TemperatureCategory {
  normal,
  hypothermia,
  lowGradeFever,
  fever,
  highFever,
  unknown,
}

class VitalSignsAlert {
  final String id;
  final String patientId;
  final String vitalSignsId;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final DateTime createdAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  const VitalSignsAlert({
    required this.id,
    required this.patientId,
    required this.vitalSignsId,
    required this.type,
    required this.severity,
    required this.message,
    required this.createdAt,
    this.isResolved = false,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory VitalSignsAlert.fromJson(Map<String, dynamic> json) {
    return VitalSignsAlert(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      vitalSignsId: json['vitalSignsId'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.vitalSignsAbnormal,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.medium,
      ),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isResolved: json['isResolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt'] as String) 
          : null,
      resolvedBy: json['resolvedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'vitalSignsId': vitalSignsId,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isResolved': isResolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      'resolvedBy': resolvedBy,
    };
  }
}

enum AlertType {
  vitalSignsAbnormal,
  bloodPressureHigh,
  heartRateAbnormal,
  temperatureHigh,
  oxygenSaturationLow,
  painLevelHigh,
}

enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}
