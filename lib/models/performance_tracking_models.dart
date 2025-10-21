class PerformanceMetric {
  final String id;
  final String clinicianId;
  final MetricType type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String? notes;
  final Map<String, dynamic> metadata;

  const PerformanceMetric({
    required this.id,
    required this.clinicianId,
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    this.notes,
    this.metadata = const {},
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      type: MetricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MetricType.productivity,
      ),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicianId': clinicianId,
      'type': type.name,
      'value': value,
      'unit': unit,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class BurnoutAssessment {
  final String id;
  final String clinicianId;
  final AssessmentType type;
  final Map<String, dynamic> responses;
  final Map<String, dynamic> scores;
  final String? interpretation;
  final BurnoutLevel level;
  final DateTime completedAt;
  final String? notes;
  final Map<String, dynamic> recommendations;

  const BurnoutAssessment({
    required this.id,
    required this.clinicianId,
    required this.type,
    required this.responses,
    required this.scores,
    this.interpretation,
    required this.level,
    required this.completedAt,
    this.notes,
    this.recommendations = const {},
  });

  factory BurnoutAssessment.fromJson(Map<String, dynamic> json) {
    return BurnoutAssessment(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      type: AssessmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssessmentType.mbi,
      ),
      responses: Map<String, dynamic>.from(json['responses'] as Map),
      scores: Map<String, dynamic>.from(json['scores'] as Map),
      interpretation: json['interpretation'] as String?,
      level: BurnoutLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => BurnoutLevel.low,
      ),
      completedAt: DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
      recommendations: Map<String, dynamic>.from(json['recommendations'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicianId': clinicianId,
      'type': type.name,
      'responses': responses,
      'scores': scores,
      'interpretation': interpretation,
      'level': level.name,
      'completedAt': completedAt.toIso8601String(),
      'notes': notes,
      'recommendations': recommendations,
    };
  }
}

class WorkloadRecord {
  final String id;
  final String clinicianId;
  final DateTime date;
  final int totalHours;
  final int patientHours;
  final int adminHours;
  final int supervisionHours;
  final int researchHours;
  final int otherHours;
  final int patientCount;
  final int sessionCount;
  final double stressLevel;
  final String? notes;
  final Map<String, dynamic> metadata;

  const WorkloadRecord({
    required this.id,
    required this.clinicianId,
    required this.date,
    required this.totalHours,
    required this.patientHours,
    required this.adminHours,
    required this.supervisionHours,
    required this.researchHours,
    required this.otherHours,
    required this.patientCount,
    required this.sessionCount,
    required this.stressLevel,
    this.notes,
    this.metadata = const {},
  });

  factory WorkloadRecord.fromJson(Map<String, dynamic> json) {
    return WorkloadRecord(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalHours: json['totalHours'] as int,
      patientHours: json['patientHours'] as int,
      adminHours: json['adminHours'] as int,
      supervisionHours: json['supervisionHours'] as int,
      researchHours: json['researchHours'] as int,
      otherHours: json['otherHours'] as int,
      patientCount: json['patientCount'] as int,
      sessionCount: json['sessionCount'] as int,
      stressLevel: (json['stressLevel'] as num).toDouble(),
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicianId': clinicianId,
      'date': date.toIso8601String(),
      'totalHours': totalHours,
      'patientHours': patientHours,
      'adminHours': adminHours,
      'supervisionHours': supervisionHours,
      'researchHours': researchHours,
      'otherHours': otherHours,
      'patientCount': patientCount,
      'sessionCount': sessionCount,
      'stressLevel': stressLevel,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Calculate workload percentage
  double get workloadPercentage {
    return (totalHours / 40) * 100; // Assuming 40 hours as full workload
  }

  // Check if workload is excessive
  bool get isExcessive {
    return totalHours > 50 || stressLevel > 7.0;
  }
}

class PerformanceGoal {
  final String id;
  final String clinicianId;
  final String title;
  final String description;
  final GoalType type;
  final double targetValue;
  final String unit;
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;
  final double currentValue;
  final DateTime? achievedAt;
  final String? notes;
  final Map<String, dynamic> metadata;

  const PerformanceGoal({
    required this.id,
    required this.clinicianId,
    required this.title,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.unit,
    required this.startDate,
    required this.endDate,
    this.status = GoalStatus.active,
    this.currentValue = 0.0,
    this.achievedAt,
    this.notes,
    this.metadata = const {},
  });

  factory PerformanceGoal.fromJson(Map<String, dynamic> json) {
    return PerformanceGoal(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => GoalType.productivity,
      ),
      targetValue: (json['targetValue'] as num).toDouble(),
      unit: json['unit'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      currentValue: (json['currentValue'] as num).toDouble(),
      achievedAt: json['achievedAt'] != null 
          ? DateTime.parse(json['achievedAt'] as String) 
          : null,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicianId': clinicianId,
      'title': title,
      'description': description,
      'type': type.name,
      'targetValue': targetValue,
      'unit': unit,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
      'currentValue': currentValue,
      'achievedAt': achievedAt?.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue) * 100;
  }

  // Check if goal is achieved
  bool get isAchieved {
    return currentValue >= targetValue;
  }

  // Check if goal is overdue
  bool get isOverdue {
    return status == GoalStatus.active && 
           endDate.isBefore(DateTime.now()) && 
           !isAchieved;
  }
}

class WellnessCheck {
  final String id;
  final String clinicianId;
  final DateTime date;
  final double moodScore;
  final double energyScore;
  final double stressScore;
  final double sleepScore;
  final double workLifeBalanceScore;
  final String? notes;
  final List<String> concerns;
  final List<String> positiveAspects;
  final Map<String, dynamic> metadata;

  const WellnessCheck({
    required this.id,
    required this.clinicianId,
    required this.date,
    required this.moodScore,
    required this.energyScore,
    required this.stressScore,
    required this.sleepScore,
    required this.workLifeBalanceScore,
    this.notes,
    this.concerns = const [],
    this.positiveAspects = const [],
    this.metadata = const {},
  });

  factory WellnessCheck.fromJson(Map<String, dynamic> json) {
    return WellnessCheck(
      id: json['id'] as String,
      clinicianId: json['clinicianId'] as String,
      date: DateTime.parse(json['date'] as String),
      moodScore: (json['moodScore'] as num).toDouble(),
      energyScore: (json['energyScore'] as num).toDouble(),
      stressScore: (json['stressScore'] as num).toDouble(),
      sleepScore: (json['sleepScore'] as num).toDouble(),
      workLifeBalanceScore: (json['workLifeBalanceScore'] as num).toDouble(),
      notes: json['notes'] as String?,
      concerns: List<String>.from(json['concerns'] as List? ?? []),
      positiveAspects: List<String>.from(json['positiveAspects'] as List? ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinicianId': clinicianId,
      'date': date.toIso8601String(),
      'moodScore': moodScore,
      'energyScore': energyScore,
      'stressScore': stressScore,
      'sleepScore': sleepScore,
      'workLifeBalanceScore': workLifeBalanceScore,
      'notes': notes,
      'concerns': concerns,
      'positiveAspects': positiveAspects,
      'metadata': metadata,
    };
  }

  // Calculate overall wellness score
  double get overallScore {
    return (moodScore + energyScore + sleepScore + workLifeBalanceScore - stressScore) / 5;
  }

  // Check if wellness is concerning
  bool get isConcerning {
    return overallScore < 4.0 || stressScore > 7.0;
  }
}

enum MetricType {
  productivity,
  quality,
  efficiency,
  satisfaction,
  burnout,
  stress,
  workload,
  other,
}

enum AssessmentType {
  mbi,
  mbiGs,
  olbi,
  cbi,
  custom,
}

enum BurnoutLevel {
  low,
  moderate,
  high,
  severe,
}

enum GoalType {
  productivity,
  quality,
  efficiency,
  satisfaction,
  burnout,
  stress,
  workload,
  other,
}

enum GoalStatus {
  active,
  achieved,
  failed,
  paused,
  cancelled,
}
