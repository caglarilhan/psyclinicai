class PatientEducationModule {
  final String id;
  final String title;
  final String description;
  final String category;
  final String difficulty; // Kolay, Orta, Zor
  final int estimatedDuration; // dakika
  final String content; // HTML/Markdown content
  final List<String> topics;
  final List<String> targetAudience; // Hasta, Aile, Hemşire, vb.
  final String language;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  const PatientEducationModule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
    required this.content,
    required this.topics,
    required this.targetAudience,
    this.language = 'tr',
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.metadata = const {},
  });

  factory PatientEducationModule.fromJson(Map<String, dynamic> json) {
    return PatientEducationModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      estimatedDuration: json['estimatedDuration'] as int,
      content: json['content'] as String,
      topics: List<String>.from(json['topics'] as List),
      targetAudience: List<String>.from(json['targetAudience'] as List),
      language: json['language'] as String? ?? 'tr',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
      isActive: json['isActive'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'content': content,
      'topics': topics,
      'targetAudience': targetAudience,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  PatientEducationModule copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? difficulty,
    int? estimatedDuration,
    String? content,
    List<String>? topics,
    List<String>? targetAudience,
    String? language,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return PatientEducationModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      content: content ?? this.content,
      topics: topics ?? this.topics,
      targetAudience: targetAudience ?? this.targetAudience,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PatientEducationProgress {
  final String id;
  final String patientId;
  final String moduleId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int progressPercentage; // 0-100
  final List<String> completedTopics;
  final Map<String, dynamic> quizResults;
  final String? notes;
  final EducationStatus status;

  const PatientEducationProgress({
    required this.id,
    required this.patientId,
    required this.moduleId,
    required this.startedAt,
    this.completedAt,
    this.progressPercentage = 0,
    this.completedTopics = const [],
    this.quizResults = const {},
    this.notes,
    this.status = EducationStatus.inProgress,
  });

  factory PatientEducationProgress.fromJson(Map<String, dynamic> json) {
    return PatientEducationProgress(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      moduleId: json['moduleId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      progressPercentage: json['progressPercentage'] as int? ?? 0,
      completedTopics: List<String>.from(json['completedTopics'] as List? ?? []),
      quizResults: Map<String, dynamic>.from(json['quizResults'] as Map? ?? {}),
      notes: json['notes'] as String?,
      status: EducationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EducationStatus.inProgress,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'moduleId': moduleId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'progressPercentage': progressPercentage,
      'completedTopics': completedTopics,
      'quizResults': quizResults,
      'notes': notes,
      'status': status.name,
    };
  }

  PatientEducationProgress copyWith({
    String? id,
    String? patientId,
    String? moduleId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? progressPercentage,
    List<String>? completedTopics,
    Map<String, dynamic>? quizResults,
    String? notes,
    EducationStatus? status,
  }) {
    return PatientEducationProgress(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      moduleId: moduleId ?? this.moduleId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedTopics: completedTopics ?? this.completedTopics,
      quizResults: quizResults ?? this.quizResults,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

class EducationQuiz {
  final String id;
  final String moduleId;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String? imageUrl;

  const EducationQuiz({
    required this.id,
    required this.moduleId,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    this.imageUrl,
  });

  factory EducationQuiz.fromJson(Map<String, dynamic> json) {
    return EducationQuiz(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'imageUrl': imageUrl,
    };
  }
}

class EducationRecommendation {
  final String id;
  final String patientId;
  final String moduleId;
  final String reason;
  final DateTime recommendedAt;
  final String recommendedBy; // clinician ID
  final bool isViewed;
  final DateTime? viewedAt;

  const EducationRecommendation({
    required this.id,
    required this.patientId,
    required this.moduleId,
    required this.reason,
    required this.recommendedAt,
    required this.recommendedBy,
    this.isViewed = false,
    this.viewedAt,
  });

  factory EducationRecommendation.fromJson(Map<String, dynamic> json) {
    return EducationRecommendation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      moduleId: json['moduleId'] as String,
      reason: json['reason'] as String,
      recommendedAt: DateTime.parse(json['recommendedAt'] as String),
      recommendedBy: json['recommendedBy'] as String,
      isViewed: json['isViewed'] as bool? ?? false,
      viewedAt: json['viewedAt'] != null 
          ? DateTime.parse(json['viewedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'moduleId': moduleId,
      'reason': reason,
      'recommendedAt': recommendedAt.toIso8601String(),
      'recommendedBy': recommendedBy,
      'isViewed': isViewed,
      'viewedAt': viewedAt?.toIso8601String(),
    };
  }
}

enum EducationStatus {
  notStarted,
  inProgress,
  completed,
  paused,
  abandoned,
}

enum EducationCategory {
  diabetes,
  hypertension,
  mentalHealth,
  medication,
  nutrition,
  exercise,
  generalHealth,
  emergency,
}
