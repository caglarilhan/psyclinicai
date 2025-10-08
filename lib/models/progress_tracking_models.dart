// İlerleme Takibi Modelleri - Psikolog/Psikiyatrist Odaklı

class ProgressTracking {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime trackingDate;
  final ProgressType type;
  final String description;
  final Map<String, dynamic> metrics;
  final ProgressStatus status;
  final String notes;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressTracking({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.trackingDate,
    required this.type,
    required this.description,
    required this.metrics,
    required this.status,
    this.notes = '',
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'trackingDate': trackingDate.toIso8601String(),
      'type': type.name,
      'description': description,
      'metrics': metrics,
      'status': status.name,
      'notes': notes,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProgressTracking.fromJson(Map<String, dynamic> json) {
    return ProgressTracking(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      trackingDate: DateTime.parse(json['trackingDate']),
      type: ProgressType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      metrics: Map<String, dynamic>.from(json['metrics']),
      status: ProgressStatus.values.firstWhere((e) => e.name == json['status']),
      notes: json['notes'] ?? '',
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum ProgressType {
  symptom,        // Belirti takibi
  functional,     // İşlevsellik takibi
  behavioral,     // Davranışsal takip
  cognitive,      // Bilişsel takip
  emotional,      // Duygusal takip
  social,         // Sosyal takip
  occupational,   // Mesleki takip
  educational,    // Eğitimsel takip
  medication,     // İlaç takibi
  assessment,     // Değerlendirme takibi
  goal,           // Hedef takibi
  intervention,   // Müdahale takibi
}

enum ProgressStatus {
  improving,      // İyileşiyor
  stable,         // Stabil
  declining,      // Kötüleşiyor
  fluctuating,    // Dalgalanıyor
  plateau,        // Plato
  breakthrough,   // Atılım
}

class ProgressReport {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime reportDate;
  final DateTime startDate;
  final DateTime endDate;
  final ReportType type;
  final String summary;
  final List<ProgressMetric> metrics;
  final List<ProgressGoal> goals;
  final List<ProgressIntervention> interventions;
  final String recommendations;
  final String nextSteps;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProgressReport({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.reportDate,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.summary,
    required this.metrics,
    required this.goals,
    required this.interventions,
    required this.recommendations,
    required this.nextSteps,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'reportDate': reportDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.name,
      'summary': summary,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'interventions': interventions.map((i) => i.toJson()).toList(),
      'recommendations': recommendations,
      'nextSteps': nextSteps,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProgressReport.fromJson(Map<String, dynamic> json) {
    return ProgressReport(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      reportDate: DateTime.parse(json['reportDate']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      type: ReportType.values.firstWhere((e) => e.name == json['type']),
      summary: json['summary'],
      metrics: (json['metrics'] as List).map((m) => ProgressMetric.fromJson(m)).toList(),
      goals: (json['goals'] as List).map((g) => ProgressGoal.fromJson(g)).toList(),
      interventions: (json['interventions'] as List).map((i) => ProgressIntervention.fromJson(i)).toList(),
      recommendations: json['recommendations'],
      nextSteps: json['nextSteps'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum ReportType {
  weekly,         // Haftalık
  monthly,        // Aylık
  quarterly,      // Üç aylık
  annual,         // Yıllık
  discharge,      // Taburcu
  transfer,       // Transfer
  emergency,      // Acil
  custom,         // Özel
}

class ProgressMetric {
  final String id;
  final String name;
  final String description;
  final MetricType type;
  final double value;
  final double previousValue;
  final String unit;
  final DateTime measurementDate;
  final String source;

  ProgressMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.measurementDate,
    required this.source,
  });

  double get change => value - previousValue;
  double get changePercentage => previousValue != 0 ? (change / previousValue * 100) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'previousValue': previousValue,
      'unit': unit,
      'measurementDate': measurementDate.toIso8601String(),
      'source': source,
    };
  }

  factory ProgressMetric.fromJson(Map<String, dynamic> json) {
    return ProgressMetric(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: MetricType.values.firstWhere((e) => e.name == json['type']),
      value: json['value'].toDouble(),
      previousValue: json['previousValue'].toDouble(),
      unit: json['unit'],
      measurementDate: DateTime.parse(json['measurementDate']),
      source: json['source'],
    );
  }
}

enum MetricType {
  score,          // Skor
  percentage,     // Yüzde
  count,          // Sayı
  duration,       // Süre
  frequency,      // Sıklık
  intensity,      // Şiddet
  quality,        // Kalite
  satisfaction,   // Memnuniyet
}

class ProgressGoal {
  final String id;
  final String name;
  final String description;
  final GoalType type;
  final GoalStatus status;
  final double targetValue;
  final double currentValue;
  final DateTime targetDate;
  final DateTime? achievedDate;
  final String notes;

  ProgressGoal({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.targetValue,
    required this.currentValue,
    required this.targetDate,
    this.achievedDate,
    this.notes = '',
  });

  double get progressPercentage => targetValue != 0 ? (currentValue / targetValue * 100) : 0.0;
  bool get isAchieved => status == GoalStatus.achieved;
  bool get isOnTrack => progressPercentage >= 50.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'targetDate': targetDate.toIso8601String(),
      'achievedDate': achievedDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory ProgressGoal.fromJson(Map<String, dynamic> json) {
    return ProgressGoal(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      status: GoalStatus.values.firstWhere((e) => e.name == json['status']),
      targetValue: json['targetValue'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      targetDate: DateTime.parse(json['targetDate']),
      achievedDate: json['achievedDate'] != null ? DateTime.parse(json['achievedDate']) : null,
      notes: json['notes'] ?? '',
    );
  }
}

enum GoalType {
  symptom,        // Belirti azaltma
  functional,     // İşlevsellik
  behavioral,     // Davranışsal
  cognitive,      // Bilişsel
  emotional,      // Duygusal
  social,         // Sosyal
  occupational,   // Mesleki
  educational,    // Eğitimsel
}

enum GoalStatus {
  notStarted,     // Başlanmadı
  inProgress,     // Devam ediyor
  achieved,       // Başarıldı
  failed,         // Başarısız
  cancelled,      // İptal edildi
  onHold,         // Beklemede
}

class ProgressIntervention {
  final String id;
  final String name;
  final String description;
  final InterventionType type;
  final InterventionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final int sessions;
  final int completedSessions;
  final String outcomes;
  final String notes;

  ProgressIntervention({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.sessions,
    this.completedSessions = 0,
    this.outcomes = '',
    this.notes = '',
  });

  double get completionPercentage => sessions != 0 ? (completedSessions / sessions * 100) : 0.0;
  bool get isCompleted => status == InterventionStatus.completed;
  bool get isActive => status == InterventionStatus.active;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'sessions': sessions,
      'completedSessions': completedSessions,
      'outcomes': outcomes,
      'notes': notes,
    };
  }

  factory ProgressIntervention.fromJson(Map<String, dynamic> json) {
    return ProgressIntervention(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: InterventionType.values.firstWhere((e) => e.name == json['type']),
      status: InterventionStatus.values.firstWhere((e) => e.name == json['status']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      sessions: json['sessions'],
      completedSessions: json['completedSessions'] ?? 0,
      outcomes: json['outcomes'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

enum InterventionType {
  therapy,        // Terapi
  medication,     // İlaç
  education,      // Eğitim
  support,        // Destek
  monitoring,     // İzleme
  assessment,     // Değerlendirme
  referral,       // Yönlendirme
  consultation,   // Konsültasyon
}

enum InterventionStatus {
  planned,        // Planlandı
  active,         // Aktif
  completed,      // Tamamlandı
  cancelled,      // İptal edildi
  onHold,         // Beklemede
  transferred,    // Transfer edildi
}

class ProgressChart {
  final String id;
  final String clientId;
  final String metricName;
  final List<ProgressDataPoint> dataPoints;
  final ChartType type;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String description;

  ProgressChart({
    required this.id,
    required this.clientId,
    required this.metricName,
    required this.dataPoints,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'metricName': metricName,
      'dataPoints': dataPoints.map((dp) => dp.toJson()).toList(),
      'type': type.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'title': title,
      'description': description,
    };
  }

  factory ProgressChart.fromJson(Map<String, dynamic> json) {
    return ProgressChart(
      id: json['id'],
      clientId: json['clientId'],
      metricName: json['metricName'],
      dataPoints: (json['dataPoints'] as List).map((dp) => ProgressDataPoint.fromJson(dp)).toList(),
      type: ChartType.values.firstWhere((e) => e.name == json['type']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      title: json['title'],
      description: json['description'],
    );
  }
}

class ProgressDataPoint {
  final DateTime date;
  final double value;
  final String label;
  final Map<String, dynamic> metadata;

  ProgressDataPoint({
    required this.date,
    required this.value,
    required this.label,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
      'metadata': metadata,
    };
  }

  factory ProgressDataPoint.fromJson(Map<String, dynamic> json) {
    return ProgressDataPoint(
      date: DateTime.parse(json['date']),
      value: json['value'].toDouble(),
      label: json['label'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}

enum ChartType {
  line,           // Çizgi grafik
  bar,            // Çubuk grafik
  area,           // Alan grafik
  scatter,        // Dağılım grafik
  pie,            // Pasta grafik
  radar,          // Radar grafik
}

class ProgressSummary {
  final String clientId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalSessions;
  final int completedSessions;
  final double overallProgress;
  final List<ProgressMetric> keyMetrics;
  final List<ProgressGoal> goals;
  final List<ProgressIntervention> interventions;
  final String summary;
  final String recommendations;
  final String nextSteps;

  ProgressSummary({
    required this.clientId,
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.completedSessions,
    required this.overallProgress,
    required this.keyMetrics,
    required this.goals,
    required this.interventions,
    required this.summary,
    required this.recommendations,
    required this.nextSteps,
  });

  double get sessionCompletionRate => totalSessions != 0 ? (completedSessions / totalSessions * 100) : 0.0;
  int get achievedGoals => goals.where((g) => g.isAchieved).length;
  int get activeInterventions => interventions.where((i) => i.isActive).length;
}
