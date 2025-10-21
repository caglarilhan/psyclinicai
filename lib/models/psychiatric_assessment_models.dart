class PsychiatricAssessment {
  final String id;
  final String patientId;
  final String clinicianId;
  final AssessmentType type;
  final DateTime assessmentDate;
  final String chiefComplaint;
  final String historyOfPresentIllness;
  final String psychiatricHistory;
  final String familyHistory;
  final String socialHistory;
  final String medicalHistory;
  final MentalStatusExamination mse;
  final List<String> diagnoses;
  final String clinicalFormulation;
  final String treatmentRecommendations;
  final String? notes;
  final AssessmentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PsychiatricAssessment({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.type,
    required this.assessmentDate,
    required this.chiefComplaint,
    required this.historyOfPresentIllness,
    required this.psychiatricHistory,
    required this.familyHistory,
    required this.socialHistory,
    required this.medicalHistory,
    required this.mse,
    required this.diagnoses,
    required this.clinicalFormulation,
    required this.treatmentRecommendations,
    this.notes,
    this.status = AssessmentStatus.draft,
    required this.createdAt,
    this.updatedAt,
  });

  factory PsychiatricAssessment.fromJson(Map<String, dynamic> json) {
    return PsychiatricAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      clinicianId: json['clinicianId'] as String,
      type: AssessmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssessmentType.initial,
      ),
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      chiefComplaint: json['chiefComplaint'] as String,
      historyOfPresentIllness: json['historyOfPresentIllness'] as String,
      psychiatricHistory: json['psychiatricHistory'] as String,
      familyHistory: json['familyHistory'] as String,
      socialHistory: json['socialHistory'] as String,
      medicalHistory: json['medicalHistory'] as String,
      mse: MentalStatusExamination.fromJson(json['mse'] as Map<String, dynamic>),
      diagnoses: List<String>.from(json['diagnoses'] as List),
      clinicalFormulation: json['clinicalFormulation'] as String,
      treatmentRecommendations: json['treatmentRecommendations'] as String,
      notes: json['notes'] as String?,
      status: AssessmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssessmentStatus.draft,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'clinicianId': clinicianId,
      'type': type.name,
      'assessmentDate': assessmentDate.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'historyOfPresentIllness': historyOfPresentIllness,
      'psychiatricHistory': psychiatricHistory,
      'familyHistory': familyHistory,
      'socialHistory': socialHistory,
      'medicalHistory': medicalHistory,
      'mse': mse.toJson(),
      'diagnoses': diagnoses,
      'clinicalFormulation': clinicalFormulation,
      'treatmentRecommendations': treatmentRecommendations,
      'notes': notes,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class MentalStatusExamination {
  final String appearance;
  final String behavior;
  final String speech;
  final String mood;
  final String affect;
  final String thoughtProcess;
  final String thoughtContent;
  final String perceptions;
  final String cognition;
  final String insight;
  final String judgment;
  final String suicidalIdeation;
  final String homicidalIdeation;
  final String substanceUse;
  final String? additionalNotes;

  const MentalStatusExamination({
    required this.appearance,
    required this.behavior,
    required this.speech,
    required this.mood,
    required this.affect,
    required this.thoughtProcess,
    required this.thoughtContent,
    required this.perceptions,
    required this.cognition,
    required this.insight,
    required this.judgment,
    required this.suicidalIdeation,
    required this.homicidalIdeation,
    required this.substanceUse,
    this.additionalNotes,
  });

  factory MentalStatusExamination.fromJson(Map<String, dynamic> json) {
    return MentalStatusExamination(
      appearance: json['appearance'] as String,
      behavior: json['behavior'] as String,
      speech: json['speech'] as String,
      mood: json['mood'] as String,
      affect: json['affect'] as String,
      thoughtProcess: json['thoughtProcess'] as String,
      thoughtContent: json['thoughtContent'] as String,
      perceptions: json['perceptions'] as String,
      cognition: json['cognition'] as String,
      insight: json['insight'] as String,
      judgment: json['judgment'] as String,
      suicidalIdeation: json['suicidalIdeation'] as String,
      homicidalIdeation: json['homicidalIdeation'] as String,
      substanceUse: json['substanceUse'] as String,
      additionalNotes: json['additionalNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appearance': appearance,
      'behavior': behavior,
      'speech': speech,
      'mood': mood,
      'affect': affect,
      'thoughtProcess': thoughtProcess,
      'thoughtContent': thoughtContent,
      'perceptions': perceptions,
      'cognition': cognition,
      'insight': insight,
      'judgment': judgment,
      'suicidalIdeation': suicidalIdeation,
      'homicidalIdeation': homicidalIdeation,
      'substanceUse': substanceUse,
      'additionalNotes': additionalNotes,
    };
  }
}

class PsychologicalTest {
  final String id;
  final String name;
  final String description;
  final TestCategory category;
  final int ageRangeMin;
  final int ageRangeMax;
  final Duration estimatedDuration;
  final List<String> languages;
  final List<TestQuestion> questions;
  final ScoringMethod scoringMethod;
  final String? instructions;
  final bool isActive;

  const PsychologicalTest({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.ageRangeMin,
    required this.ageRangeMax,
    required this.estimatedDuration,
    required this.languages,
    required this.questions,
    required this.scoringMethod,
    this.instructions,
    this.isActive = true,
  });

  factory PsychologicalTest.fromJson(Map<String, dynamic> json) {
    return PsychologicalTest(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: TestCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TestCategory.personality,
      ),
      ageRangeMin: json['ageRangeMin'] as int,
      ageRangeMax: json['ageRangeMax'] as int,
      estimatedDuration: Duration(minutes: json['estimatedDuration'] as int),
      languages: List<String>.from(json['languages'] as List),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => TestQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      scoringMethod: ScoringMethod.values.firstWhere(
        (e) => e.name == json['scoringMethod'],
        orElse: () => ScoringMethod.sum,
      ),
      instructions: json['instructions'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'ageRangeMin': ageRangeMin,
      'ageRangeMax': ageRangeMax,
      'estimatedDuration': estimatedDuration.inMinutes,
      'languages': languages,
      'questions': questions.map((q) => q.toJson()).toList(),
      'scoringMethod': scoringMethod.name,
      'instructions': instructions,
      'isActive': isActive,
    };
  }
}

class TestQuestion {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<String>? options;
  final int? correctAnswerIndex;
  final Map<String, int>? scoring;
  final String? explanation;

  const TestQuestion({
    required this.id,
    required this.questionText,
    required this.type,
    this.options,
    this.correctAnswerIndex,
    this.scoring,
    this.explanation,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    return TestQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      type: QuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: json['options'] != null 
          ? List<String>.from(json['options'] as List) 
          : null,
      correctAnswerIndex: json['correctAnswerIndex'] as int?,
      scoring: json['scoring'] != null 
          ? Map<String, int>.from(json['scoring'] as Map) 
          : null,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.name,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'scoring': scoring,
      'explanation': explanation,
    };
  }
}

class TestResult {
  final String id;
  final String testId;
  final String patientId;
  final String administeredBy;
  final DateTime administeredAt;
  final Map<String, dynamic> responses;
  final Map<String, dynamic> scores;
  final String interpretation;
  final String? recommendations;
  final TestValidity validity;
  final String? notes;

  const TestResult({
    required this.id,
    required this.testId,
    required this.patientId,
    required this.administeredBy,
    required this.administeredAt,
    required this.responses,
    required this.scores,
    required this.interpretation,
    this.recommendations,
    this.validity = TestValidity.valid,
    this.notes,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] as String,
      testId: json['testId'] as String,
      patientId: json['patientId'] as String,
      administeredBy: json['administeredBy'] as String,
      administeredAt: DateTime.parse(json['administeredAt'] as String),
      responses: Map<String, dynamic>.from(json['responses'] as Map),
      scores: Map<String, dynamic>.from(json['scores'] as Map),
      interpretation: json['interpretation'] as String,
      recommendations: json['recommendations'] as String?,
      validity: TestValidity.values.firstWhere(
        (e) => e.name == json['validity'],
        orElse: () => TestValidity.valid,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'patientId': patientId,
      'administeredBy': administeredBy,
      'administeredAt': administeredAt.toIso8601String(),
      'responses': responses,
      'scores': scores,
      'interpretation': interpretation,
      'recommendations': recommendations,
      'validity': validity.name,
      'notes': notes,
    };
  }
}

enum AssessmentType {
  initial,
  followUp,
  crisis,
  discharge,
  forensic,
}

enum AssessmentStatus {
  draft,
  completed,
  reviewed,
  finalized,
}

enum TestCategory {
  personality,
  cognitive,
  mood,
  anxiety,
  trauma,
  substance,
  developmental,
  neuropsychological,
}

enum QuestionType {
  multipleChoice,
  likertScale,
  trueFalse,
  openEnded,
  ratingScale,
}

enum ScoringMethod {
  sum,
  average,
  weighted,
  percentile,
  standardScore,
}

enum TestValidity {
  valid,
  questionable,
  invalid,
  incomplete,
}
