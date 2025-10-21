class AssessmentSurvey {
  final String id;
  final String name;
  final String description;
  final SurveyType type;
  final List<SurveyQuestion> questions;
  final SurveySettings settings;
  final String? instructions;
  final String? completionMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final bool isActive;
  final List<String> targetDisorders;
  final List<String> targetAudience;

  const AssessmentSurvey({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.questions,
    required this.settings,
    this.instructions,
    this.completionMessage,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.isActive = true,
    this.targetDisorders = const [],
    this.targetAudience = const [],
  });

  factory AssessmentSurvey.fromJson(Map<String, dynamic> json) {
    return AssessmentSurvey(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: SurveyType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SurveyType.symptom,
      ),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => SurveyQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      settings: SurveySettings.fromJson(json['settings'] as Map<String, dynamic>),
      instructions: json['instructions'] as String?,
      completionMessage: json['completionMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      createdBy: json['createdBy'] as String,
      isActive: json['isActive'] as bool? ?? true,
      targetDisorders: List<String>.from(json['targetDisorders'] as List? ?? []),
      targetAudience: List<String>.from(json['targetAudience'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'questions': questions.map((q) => q.toJson()).toList(),
      'settings': settings.toJson(),
      'instructions': instructions,
      'completionMessage': completionMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'isActive': isActive,
      'targetDisorders': targetDisorders,
      'targetAudience': targetAudience,
    };
  }
}

class SurveyQuestion {
  final String id;
  final String text;
  final QuestionType type;
  final List<QuestionOption>? options;
  final bool isRequired;
  final int order;
  final String? helpText;
  final Map<String, dynamic>? scoring;
  final String? category;

  const SurveyQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.isRequired = true,
    required this.order,
    this.helpText,
    this.scoring,
    this.category,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    return SurveyQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: json['options'] != null 
          ? (json['options'] as List<dynamic>)
              .map((o) => QuestionOption.fromJson(o as Map<String, dynamic>))
              .toList()
          : null,
      isRequired: json['isRequired'] as bool? ?? true,
      order: json['order'] as int,
      helpText: json['helpText'] as String?,
      scoring: json['scoring'] != null 
          ? Map<String, dynamic>.from(json['scoring'] as Map) 
          : null,
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.name,
      'options': options?.map((o) => o.toJson()).toList(),
      'isRequired': isRequired,
      'order': order,
      'helpText': helpText,
      'scoring': scoring,
      'category': category,
    };
  }
}

class QuestionOption {
  final String id;
  final String text;
  final int value;
  final String? description;
  final bool isOther;

  const QuestionOption({
    required this.id,
    required this.text,
    required this.value,
    this.description,
    this.isOther = false,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] as String,
      text: json['text'] as String,
      value: json['value'] as int,
      description: json['description'] as String?,
      isOther: json['isOther'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'value': value,
      'description': description,
      'isOther': isOther,
    };
  }
}

class SurveySettings {
  final bool allowSkip;
  final bool showProgress;
  final bool randomizeQuestions;
  final bool saveProgress;
  final Duration? timeLimit;
  final int? maxAttempts;
  final bool requireCompletion;
  final String? thankYouMessage;
  final List<String>? completionActions;

  const SurveySettings({
    this.allowSkip = false,
    this.showProgress = true,
    this.randomizeQuestions = false,
    this.saveProgress = true,
    this.timeLimit,
    this.maxAttempts,
    this.requireCompletion = true,
    this.thankYouMessage,
    this.completionActions,
  });

  factory SurveySettings.fromJson(Map<String, dynamic> json) {
    return SurveySettings(
      allowSkip: json['allowSkip'] as bool? ?? false,
      showProgress: json['showProgress'] as bool? ?? true,
      randomizeQuestions: json['randomizeQuestions'] as bool? ?? false,
      saveProgress: json['saveProgress'] as bool? ?? true,
      timeLimit: json['timeLimit'] != null 
          ? Duration(minutes: json['timeLimit'] as int) 
          : null,
      maxAttempts: json['maxAttempts'] as int?,
      requireCompletion: json['requireCompletion'] as bool? ?? true,
      thankYouMessage: json['thankYouMessage'] as String?,
      completionActions: json['completionActions'] != null 
          ? List<String>.from(json['completionActions'] as List) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowSkip': allowSkip,
      'showProgress': showProgress,
      'randomizeQuestions': randomizeQuestions,
      'saveProgress': saveProgress,
      'timeLimit': timeLimit?.inMinutes,
      'maxAttempts': maxAttempts,
      'requireCompletion': requireCompletion,
      'thankYouMessage': thankYouMessage,
      'completionActions': completionActions,
    };
  }
}

class SurveyResponse {
  final String id;
  final String surveyId;
  final String patientId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final Map<String, dynamic> responses;
  final SurveyStatus status;
  final Map<String, dynamic> scores;
  final String? interpretation;
  final String? notes;
  final Duration? duration;

  const SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.patientId,
    required this.startedAt,
    this.completedAt,
    required this.responses,
    this.status = SurveyStatus.inProgress,
    this.scores = const {},
    this.interpretation,
    this.notes,
    this.duration,
  });

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      patientId: json['patientId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      responses: Map<String, dynamic>.from(json['responses'] as Map),
      status: SurveyStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SurveyStatus.inProgress,
      ),
      scores: Map<String, dynamic>.from(json['scores'] as Map? ?? {}),
      interpretation: json['interpretation'] as String?,
      notes: json['notes'] as String?,
      duration: json['duration'] != null 
          ? Duration(minutes: json['duration'] as int) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'patientId': patientId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'responses': responses,
      'status': status.name,
      'scores': scores,
      'interpretation': interpretation,
      'notes': notes,
      'duration': duration?.inMinutes,
    };
  }

  // Calculate completion percentage
  double get completionPercentage {
    if (responses.isEmpty) return 0.0;
    // This would need to be calculated based on survey questions
    return 100.0; // Placeholder
  }
}

class SurveySchedule {
  final String id;
  final String surveyId;
  final String patientId;
  final ScheduleType type;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final ScheduleStatus status;
  final String? reminderMessage;
  final int reminderCount;
  final DateTime? lastReminderSent;
  final Map<String, dynamic> metadata;

  const SurveySchedule({
    required this.id,
    required this.surveyId,
    required this.patientId,
    required this.type,
    required this.scheduledAt,
    this.completedAt,
    this.status = ScheduleStatus.pending,
    this.reminderMessage,
    this.reminderCount = 0,
    this.lastReminderSent,
    this.metadata = const {},
  });

  factory SurveySchedule.fromJson(Map<String, dynamic> json) {
    return SurveySchedule(
      id: json['id'] as String,
      surveyId: json['surveyId'] as String,
      patientId: json['patientId'] as String,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScheduleType.manual,
      ),
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      status: ScheduleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScheduleStatus.pending,
      ),
      reminderMessage: json['reminderMessage'] as String?,
      reminderCount: json['reminderCount'] as int? ?? 0,
      lastReminderSent: json['lastReminderSent'] != null 
          ? DateTime.parse(json['lastReminderSent'] as String) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surveyId': surveyId,
      'patientId': patientId,
      'type': type.name,
      'scheduledAt': scheduledAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'reminderMessage': reminderMessage,
      'reminderCount': reminderCount,
      'lastReminderSent': lastReminderSent?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Check if schedule is overdue
  bool get isOverdue {
    return status == ScheduleStatus.pending && 
           scheduledAt.isBefore(DateTime.now());
  }
}

enum SurveyType {
  symptom,
  outcome,
  satisfaction,
  screening,
  diagnostic,
  followUp,
}

enum QuestionType {
  multipleChoice,
  likertScale,
  ratingScale,
  text,
  number,
  date,
  boolean,
}

enum SurveyStatus {
  notStarted,
  inProgress,
  completed,
  abandoned,
  expired,
}

enum ScheduleType {
  manual,
  automatic,
  recurring,
  eventBased,
}

enum ScheduleStatus {
  pending,
  sent,
  completed,
  cancelled,
  expired,
}
