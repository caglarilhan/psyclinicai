// Tedavi Planı Modelleri - Psikolog/Psikiyatrist Odaklı

class TreatmentPlan {
  final String id;
  final String clientId;
  final String therapistId;
  final String title;
  final String description;
  final TreatmentType type;
  final TreatmentModality modality;
  final DateTime startDate;
  final DateTime? endDate;
  final int estimatedSessions;
  final int completedSessions;
  final TreatmentStatus status;
  final List<TreatmentGoal> goals;
  final List<TreatmentIntervention> interventions;
  final List<TreatmentProgress> progress;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreatmentPlan({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.title,
    required this.description,
    required this.type,
    required this.modality,
    required this.startDate,
    this.endDate,
    required this.estimatedSessions,
    this.completedSessions = 0,
    this.status = TreatmentStatus.active,
    required this.goals,
    required this.interventions,
    this.progress = const [],
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (estimatedSessions == 0) return 0.0;
    return (completedSessions / estimatedSessions * 100).clamp(0.0, 100.0);
  }

  bool get isCompleted => status == TreatmentStatus.completed;
  bool get isActive => status == TreatmentStatus.active;
  bool get isPaused => status == TreatmentStatus.paused;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'title': title,
      'description': description,
      'type': type.name,
      'modality': modality.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'estimatedSessions': estimatedSessions,
      'completedSessions': completedSessions,
      'status': status.name,
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'interventions': interventions.map((intervention) => intervention.toJson()).toList(),
      'progress': progress.map((p) => p.toJson()).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      title: json['title'],
      description: json['description'],
      type: TreatmentType.values.firstWhere((e) => e.name == json['type']),
      modality: TreatmentModality.values.firstWhere((e) => e.name == json['modality']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      estimatedSessions: json['estimatedSessions'],
      completedSessions: json['completedSessions'] ?? 0,
      status: TreatmentStatus.values.firstWhere((e) => e.name == json['status']),
      goals: (json['goals'] as List).map((g) => TreatmentGoal.fromJson(g)).toList(),
      interventions: (json['interventions'] as List).map((i) => TreatmentIntervention.fromJson(i)).toList(),
      progress: (json['progress'] as List).map((p) => TreatmentProgress.fromJson(p)).toList(),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum TreatmentType {
  individual,     // Bireysel terapi
  group,          // Grup terapisi
  family,         // Aile terapisi
  couple,         // Çift terapisi
  cognitive,      // Bilişsel terapi
  behavioral,     // Davranışçı terapi
  psychodynamic,  // Psikodinamik terapi
  humanistic,     // Hümanistik terapi
  integrative,    // Entegratif terapi
  medication,     // İlaç tedavisi
  combined,       // Kombine tedavi
}

enum TreatmentModality {
  inPerson,       // Yüz yüze
  telehealth,     // Uzaktan
  hybrid,         // Hibrit
  intensive,      // Yoğun
  maintenance,    // Sürdürme
}

enum TreatmentStatus {
  active,         // Aktif
  paused,         // Duraklatıldı
  completed,      // Tamamlandı
  cancelled,      // İptal edildi
  onHold,         // Beklemede
}

class TreatmentGoal {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final GoalPriority priority;
  final DateTime targetDate;
  final bool isAchieved;
  final DateTime? achievedDate;
  final String notes;

  TreatmentGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.targetDate,
    this.isAchieved = false,
    this.achievedDate,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'targetDate': targetDate.toIso8601String(),
      'isAchieved': isAchieved,
      'achievedDate': achievedDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory TreatmentGoal.fromJson(Map<String, dynamic> json) {
    return TreatmentGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: GoalType.values.firstWhere((e) => e.name == json['type']),
      priority: GoalPriority.values.firstWhere((e) => e.name == json['priority']),
      targetDate: DateTime.parse(json['targetDate']),
      isAchieved: json['isAchieved'] ?? false,
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

enum GoalPriority {
  low,            // Düşük
  medium,         // Orta
  high,           // Yüksek
  critical,       // Kritik
}

class TreatmentIntervention {
  final String id;
  final String title;
  final String description;
  final InterventionType type;
  final InterventionCategory category;
  final DateTime scheduledDate;
  final bool isCompleted;
  final DateTime? completedDate;
  final String notes;
  final Map<String, dynamic> outcomes;

  TreatmentIntervention({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.scheduledDate,
    this.isCompleted = false,
    this.completedDate,
    this.notes = '',
    this.outcomes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'notes': notes,
      'outcomes': outcomes,
    };
  }

  factory TreatmentIntervention.fromJson(Map<String, dynamic> json) {
    return TreatmentIntervention(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: InterventionType.values.firstWhere((e) => e.name == json['type']),
      category: InterventionCategory.values.firstWhere((e) => e.name == json['category']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      isCompleted: json['isCompleted'] ?? false,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      notes: json['notes'] ?? '',
      outcomes: Map<String, dynamic>.from(json['outcomes'] ?? {}),
    );
  }
}

enum InterventionType {
  session,        // Seans
  homework,       // Ev ödevi
  exercise,       // Egzersiz
  psychoeducation, // Psikoeğitim
  relaxation,     // Gevşeme
  exposure,       // Maruz bırakma
  cognitive,      // Bilişsel
  behavioral,     // Davranışsal
  medication,     // İlaç
  assessment,     // Değerlendirme
}

enum InterventionCategory {
  therapeutic,    // Terapötik
  educational,    // Eğitimsel
  behavioral,     // Davranışsal
  cognitive,      // Bilişsel
  emotional,      // Duygusal
  social,         // Sosyal
  physical,       // Fiziksel
  medication,     // İlaç
}

class TreatmentProgress {
  final String id;
  final DateTime date;
  final String sessionId;
  final ProgressType type;
  final String description;
  final Map<String, dynamic> metrics;
  final String notes;
  final String therapistId;

  TreatmentProgress({
    required this.id,
    required this.date,
    required this.sessionId,
    required this.type,
    required this.description,
    required this.metrics,
    this.notes = '',
    required this.therapistId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'sessionId': sessionId,
      'type': type.name,
      'description': description,
      'metrics': metrics,
      'notes': notes,
      'therapistId': therapistId,
    };
  }

  factory TreatmentProgress.fromJson(Map<String, dynamic> json) {
    return TreatmentProgress(
      id: json['id'],
      date: DateTime.parse(json['date']),
      sessionId: json['sessionId'],
      type: ProgressType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'],
      metrics: Map<String, dynamic>.from(json['metrics']),
      notes: json['notes'] ?? '',
      therapistId: json['therapistId'],
    );
  }
}

enum ProgressType {
  improvement,    // İyileşme
  regression,     // Gerileme
  stable,         // Stabil
  breakthrough,   // Atılım
  challenge,      // Zorluk
  milestone,      // Kilometre taşı
}

// Tedavi Planı Şablonları
class TreatmentPlanTemplates {
  static TreatmentPlan createDepressionPlan({
    required String clientId,
    required String therapistId,
  }) {
    return TreatmentPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      therapistId: therapistId,
      title: 'Depresyon Tedavi Planı',
      description: 'Major depresif bozukluk için bilişsel davranışçı terapi planı',
      type: TreatmentType.cognitive,
      modality: TreatmentModality.inPerson,
      startDate: DateTime.now(),
      estimatedSessions: 16,
      goals: [
        TreatmentGoal(
          id: 'goal_1',
          title: 'Depresif belirtileri azaltma',
          description: 'PHQ-9 skorunu 10\'dan 5\'in altına düşürme',
          type: GoalType.symptom,
          priority: GoalPriority.high,
          targetDate: DateTime.now().add(const Duration(days: 56)),
        ),
        TreatmentGoal(
          id: 'goal_2',
          title: 'Günlük aktivitelere katılım',
          description: 'Haftalık aktivite sayısını 3\'e çıkarma',
          type: GoalType.functional,
          priority: GoalPriority.medium,
          targetDate: DateTime.now().add(const Duration(days: 42)),
        ),
        TreatmentGoal(
          id: 'goal_3',
          title: 'Olumsuz düşünce kalıplarını değiştirme',
          description: 'Bilişsel çarpıtmaları tanıma ve düzeltme',
          type: GoalType.cognitive,
          priority: GoalPriority.high,
          targetDate: DateTime.now().add(const Duration(days: 70)),
        ),
      ],
      interventions: [
        TreatmentIntervention(
          id: 'intervention_1',
          title: 'Psikoeğitim',
          description: 'Depresyon hakkında bilgilendirme',
          type: InterventionType.psychoeducation,
          category: InterventionCategory.educational,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
        ),
        TreatmentIntervention(
          id: 'intervention_2',
          title: 'Bilişsel yeniden yapılandırma',
          description: 'Olumsuz düşünce kalıplarını değiştirme',
          type: InterventionType.cognitive,
          category: InterventionCategory.cognitive,
          scheduledDate: DateTime.now().add(const Duration(days: 7)),
        ),
        TreatmentIntervention(
          id: 'intervention_3',
          title: 'Davranış aktivasyonu',
          description: 'Günlük aktiviteleri artırma',
          type: InterventionType.behavioral,
          category: InterventionCategory.behavioral,
          scheduledDate: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static TreatmentPlan createAnxietyPlan({
    required String clientId,
    required String therapistId,
  }) {
    return TreatmentPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      therapistId: therapistId,
      title: 'Anksiyete Tedavi Planı',
      description: 'Yaygın anksiyete bozukluğu için bilişsel davranışçı terapi planı',
      type: TreatmentType.cognitive,
      modality: TreatmentModality.inPerson,
      startDate: DateTime.now(),
      estimatedSessions: 12,
      goals: [
        TreatmentGoal(
          id: 'goal_1',
          title: 'Anksiyete belirtilerini azaltma',
          description: 'GAD-7 skorunu 8\'den 4\'ün altına düşürme',
          type: GoalType.symptom,
          priority: GoalPriority.high,
          targetDate: DateTime.now().add(const Duration(days: 42)),
        ),
        TreatmentGoal(
          id: 'goal_2',
          title: 'Endişe kontrolü',
          description: 'Endişe döngülerini kırma tekniklerini öğrenme',
          type: GoalType.cognitive,
          priority: GoalPriority.high,
          targetDate: DateTime.now().add(const Duration(days: 56)),
        ),
        TreatmentGoal(
          id: 'goal_3',
          title: 'Gevşeme teknikleri',
          description: 'Günlük gevşeme pratiği yapma',
          type: GoalType.behavioral,
          priority: GoalPriority.medium,
          targetDate: DateTime.now().add(const Duration(days: 28)),
        ),
      ],
      interventions: [
        TreatmentIntervention(
          id: 'intervention_1',
          title: 'Anksiyete psikoeğitimi',
          description: 'Anksiyete hakkında bilgilendirme',
          type: InterventionType.psychoeducation,
          category: InterventionCategory.educational,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
        ),
        TreatmentIntervention(
          id: 'intervention_2',
          title: 'Gevşeme eğitimi',
          description: 'Derin nefes ve progresif kas gevşemesi',
          type: InterventionType.relaxation,
          category: InterventionCategory.therapeutic,
          scheduledDate: DateTime.now().add(const Duration(days: 7)),
        ),
        TreatmentIntervention(
          id: 'intervention_3',
          title: 'Endişe yönetimi',
          description: 'Endişe döngülerini kırma teknikleri',
          type: InterventionType.cognitive,
          category: InterventionCategory.cognitive,
          scheduledDate: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static TreatmentPlan createTraumaPlan({
    required String clientId,
    required String therapistId,
  }) {
    return TreatmentPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      therapistId: therapistId,
      title: 'Travma Tedavi Planı',
      description: 'Travma sonrası stres bozukluğu için EMDR ve CBT kombinasyonu',
      type: TreatmentType.integrative,
      modality: TreatmentModality.inPerson,
      startDate: DateTime.now(),
      estimatedSessions: 20,
      goals: [
        TreatmentGoal(
          id: 'goal_1',
          title: 'Travma belirtilerini azaltma',
          description: 'PCL-5 skorunu 15\'ten 5\'in altına düşürme',
          type: GoalType.symptom,
          priority: GoalPriority.critical,
          targetDate: DateTime.now().add(const Duration(days: 112)),
        ),
        TreatmentGoal(
          id: 'goal_2',
          title: 'Travma işleme',
          description: 'Travmatik anıları işleme ve entegre etme',
          type: GoalType.emotional,
          priority: GoalPriority.high,
          targetDate: DateTime.now().add(const Duration(days: 84)),
        ),
        TreatmentGoal(
          id: 'goal_3',
          title: 'Güvenlik hissi',
          description: 'Güvenlik ve kontrol hissini geri kazanma',
          type: GoalType.emotional,
          priority: GoalPriority.high,
          targetDate: DateTime.now().add(const Duration(days: 56)),
        ),
      ],
      interventions: [
        TreatmentIntervention(
          id: 'intervention_1',
          title: 'Travma psikoeğitimi',
          description: 'Travma ve PTSD hakkında bilgilendirme',
          type: InterventionType.psychoeducation,
          category: InterventionCategory.educational,
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
        ),
        TreatmentIntervention(
          id: 'intervention_2',
          title: 'Güvenlik planı',
          description: 'Güvenlik ve başa çıkma stratejileri',
          type: InterventionType.cognitive,
          category: InterventionCategory.therapeutic,
          scheduledDate: DateTime.now().add(const Duration(days: 7)),
        ),
        TreatmentIntervention(
          id: 'intervention_3',
          title: 'EMDR terapi',
          description: 'Göz hareketleri ile duyarsızlaştırma',
          type: InterventionType.session,
          category: InterventionCategory.therapeutic,
          scheduledDate: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}