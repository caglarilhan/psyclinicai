class TreatmentPlan {
  final String id;
  final String patientId;
  final String clinicianId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String primaryDiagnosis;
  final List<String> secondaryDiagnoses;
  final String clinicalFormulation;
  final List<TreatmentGoal> goals;
  final List<TreatmentIntervention> interventions;
  final String? prognosis;
  final String? notes;
  final TreatmentPlanStatus status;
  final DateTime? reviewDate;
  final String? reviewNotes;

  const TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.createdAt,
    this.updatedAt,
    required this.primaryDiagnosis,
    this.secondaryDiagnoses = const [],
    required this.clinicalFormulation,
    this.goals = const [],
    this.interventions = const [],
    this.prognosis,
    this.notes,
    this.status = TreatmentPlanStatus.active,
    this.reviewDate,
    this.reviewNotes,
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      primaryDiagnosis: json['primaryDiagnosis'] as String,
      secondaryDiagnoses: List<String>.from(json['secondaryDiagnoses'] as List? ?? []),
      clinicalFormulation: json['clinicalFormulation'] as String,
      goals: (json['goals'] as List<dynamic>?)
          ?.map((goal) => TreatmentGoal.fromJson(goal as Map<String, dynamic>))
          .toList() ?? [],
      interventions: (json['interventions'] as List<dynamic>?)
          ?.map((intervention) => TreatmentIntervention.fromJson(intervention as Map<String, dynamic>))
          .toList() ?? [],
      prognosis: json['prognosis'] as String?,
      notes: json['notes'] as String?,
      status: TreatmentPlanStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TreatmentPlanStatus.active,
      ),
      reviewDate: json['reviewDate'] != null 
          ? DateTime.parse(json['reviewDate'] as String) 
          : null,
      reviewNotes: json['reviewNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'clinicianId': clinicianId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'primaryDiagnosis': primaryDiagnosis,
      'secondaryDiagnoses': secondaryDiagnoses,
      'clinicalFormulation': clinicalFormulation,
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'interventions': interventions.map((intervention) => intervention.toJson()).toList(),
      'prognosis': prognosis,
      'notes': notes,
      'status': status.name,
      'reviewDate': reviewDate?.toIso8601String(),
      'reviewNotes': reviewNotes,
    };
  }

  // Calculate overall progress
  double get overallProgress {
    if (goals.isEmpty) return 0.0;
    final totalProgress = goals.map((goal) => goal.progress).reduce((a, b) => a + b);
    return totalProgress / goals.length;
  }

  // Get active goals
  List<TreatmentGoal> get activeGoals {
    return goals.where((goal) => goal.status == GoalStatus.active).toList();
  }

  // Get completed goals
  List<TreatmentGoal> get completedGoals {
    return goals.where((goal) => goal.status == GoalStatus.completed).toList();
  }
}

class TreatmentGoal {
  final String id;
  final String description;
  final GoalCategory category;
  final GoalPriority priority;
  final DateTime targetDate;
  final GoalStatus status;
  final int progress; // 0-100
  final String? notes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<String> milestones;
  final String? measurementMethod;

  const TreatmentGoal({
    required this.id,
    required this.description,
    required this.category,
    required this.priority,
    required this.targetDate,
    this.status = GoalStatus.active,
    this.progress = 0,
    this.notes,
    required this.createdAt,
    this.completedAt,
    this.milestones = const [],
    this.measurementMethod,
  });

  factory TreatmentGoal.fromJson(Map<String, dynamic> json) {
    return TreatmentGoal(
      id: json['id'] as String,
      description: json['description'] as String,
      category: GoalCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GoalCategory.symptomReduction,
      ),
      priority: GoalPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => GoalPriority.medium,
      ),
      targetDate: DateTime.parse(json['targetDate'] as String),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GoalStatus.active,
      ),
      progress: json['progress'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      milestones: List<String>.from(json['milestones'] as List? ?? []),
      measurementMethod: json['measurementMethod'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'targetDate': targetDate.toIso8601String(),
      'status': status.name,
      'progress': progress,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'milestones': milestones,
      'measurementMethod': measurementMethod,
    };
  }

  // Check if goal is overdue
  bool get isOverdue {
    return status == GoalStatus.active && targetDate.isBefore(DateTime.now());
  }

  // Check if goal is due soon (within 7 days)
  bool get isDueSoon {
    final sevenDaysFromNow = DateTime.now().add(const Duration(days: 7));
    return status == GoalStatus.active && 
           targetDate.isAfter(DateTime.now()) && 
           targetDate.isBefore(sevenDaysFromNow);
  }
}

class TreatmentIntervention {
  final String id;
  final String name;
  final InterventionType type;
  final String description;
  final InterventionFrequency frequency;
  final Duration duration;
  final String? instructions;
  final String? expectedOutcome;
  final InterventionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final List<String> contraindications;

  const TreatmentIntervention({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.frequency,
    required this.duration,
    this.instructions,
    this.expectedOutcome,
    this.status = InterventionStatus.active,
    required this.startDate,
    this.endDate,
    this.notes,
    this.contraindications = const [],
  });

  factory TreatmentIntervention.fromJson(Map<String, dynamic> json) {
    return TreatmentIntervention(
      id: json['id'] as String,
      name: json['name'] as String,
      type: InterventionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InterventionType.psychotherapy,
      ),
      description: json['description'] as String,
      frequency: InterventionFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => InterventionFrequency.weekly,
      ),
      duration: Duration(minutes: json['duration'] as int),
      instructions: json['instructions'] as String?,
      expectedOutcome: json['expectedOutcome'] as String?,
      status: InterventionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InterventionStatus.active,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      notes: json['notes'] as String?,
      contraindications: List<String>.from(json['contraindications'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'frequency': frequency.name,
      'duration': duration.inMinutes,
      'instructions': instructions,
      'expectedOutcome': expectedOutcome,
      'status': status.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'contraindications': contraindications,
    };
  }

  // Check if intervention is active
  bool get isActive {
    return status == InterventionStatus.active && 
           (endDate == null || endDate!.isAfter(DateTime.now()));
  }
}

class TreatmentProgress {
  final String id;
  final String treatmentPlanId;
  final DateTime assessmentDate;
  final String assessedBy;
  final Map<String, dynamic> goalProgress;
  final Map<String, dynamic> interventionEffectiveness;
  final String overallAssessment;
  final String? recommendations;
  final String? notes;
  final DateTime nextReviewDate;

  const TreatmentProgress({
    required this.id,
    required this.treatmentPlanId,
    required this.assessmentDate,
    required this.assessedBy,
    required this.goalProgress,
    required this.interventionEffectiveness,
    required this.overallAssessment,
    this.recommendations,
    this.notes,
    required this.nextReviewDate,
  });

  factory TreatmentProgress.fromJson(Map<String, dynamic> json) {
    return TreatmentProgress(
      id: json['id'] as String,
      treatmentPlanId: json['treatmentPlanId'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      assessedBy: json['assessedBy'] as String,
      goalProgress: Map<String, dynamic>.from(json['goalProgress'] as Map),
      interventionEffectiveness: Map<String, dynamic>.from(json['interventionEffectiveness'] as Map),
      overallAssessment: json['overallAssessment'] as String,
      recommendations: json['recommendations'] as String?,
      notes: json['notes'] as String?,
      nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'treatmentPlanId': treatmentPlanId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'assessedBy': assessedBy,
      'goalProgress': goalProgress,
      'interventionEffectiveness': interventionEffectiveness,
      'overallAssessment': overallAssessment,
      'recommendations': recommendations,
      'notes': notes,
      'nextReviewDate': nextReviewDate.toIso8601String(),
    };
  }
}

enum TreatmentPlanStatus {
  draft,
  active,
  completed,
  suspended,
  discontinued,
}

enum GoalCategory {
  symptomReduction,
  functionalImprovement,
  skillDevelopment,
  relationshipImprovement,
  medicationCompliance,
  lifestyleChange,
  crisisPrevention,
  other,
}

enum GoalPriority {
  low,
  medium,
  high,
  critical,
}

enum GoalStatus {
  active,
  completed,
  suspended,
  discontinued,
  modified,
}

enum InterventionType {
  psychotherapy,
  medication,
  psychoeducation,
  familyTherapy,
  groupTherapy,
  behavioralIntervention,
  cognitiveIntervention,
  mindfulness,
  relaxation,
  other,
}

enum InterventionFrequency {
  daily,
  twiceDaily,
  weekly,
  biweekly,
  monthly,
  asNeeded,
  continuous,
}

enum InterventionStatus {
  active,
  completed,
  suspended,
  discontinued,
  modified,
}