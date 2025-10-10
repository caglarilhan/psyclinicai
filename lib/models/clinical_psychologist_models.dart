import 'dart:convert';

enum TestCategory { intelligence, personality, neuropsychological, developmental, behavioral, projective }
enum TestAdministrationType { individual, group, computer, paper }
enum ScoringMethod { automated, manual, computerAssisted }

class PsychologicalTest {
  final String id;
  final String name;
  final String abbreviation;
  final TestCategory category;
  final String description;
  final int ageRangeMin;
  final int ageRangeMax;
  final TestAdministrationType administrationType;
  final int estimatedDuration; // minutes
  final ScoringMethod scoringMethod;
  final List<String> qualifications; // required qualifications to administer
  final List<String> languages;
  final String publisher;
  final String copyrightYear;
  final Map<String, dynamic> norms;
  final List<String> subtests;
  final Map<String, dynamic> interpretation;

  PsychologicalTest({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.category,
    required this.description,
    required this.ageRangeMin,
    required this.ageRangeMax,
    required this.administrationType,
    required this.estimatedDuration,
    required this.scoringMethod,
    required this.qualifications,
    required this.languages,
    required this.publisher,
    required this.copyrightYear,
    required this.norms,
    required this.subtests,
    required this.interpretation,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'category': category.name,
      'description': description,
      'ageRangeMin': ageRangeMin,
      'ageRangeMax': ageRangeMax,
      'administrationType': administrationType.name,
      'estimatedDuration': estimatedDuration,
      'scoringMethod': scoringMethod.name,
      'qualifications': qualifications,
      'languages': languages,
      'publisher': publisher,
      'copyrightYear': copyrightYear,
      'norms': norms,
      'subtests': subtests,
      'interpretation': interpretation,
    };
  }

  factory PsychologicalTest.fromJson(Map<String, dynamic> json) {
    return PsychologicalTest(
      id: json['id'],
      name: json['name'],
      abbreviation: json['abbreviation'],
      category: TestCategory.values.firstWhere((e) => e.name == json['category']),
      description: json['description'],
      ageRangeMin: json['ageRangeMin'],
      ageRangeMax: json['ageRangeMax'],
      administrationType: TestAdministrationType.values.firstWhere((e) => e.name == json['administrationType']),
      estimatedDuration: json['estimatedDuration'],
      scoringMethod: ScoringMethod.values.firstWhere((e) => e.name == json['scoringMethod']),
      qualifications: List<String>.from(json['qualifications']),
      languages: List<String>.from(json['languages']),
      publisher: json['publisher'],
      copyrightYear: json['copyrightYear'],
      norms: Map<String, dynamic>.from(json['norms']),
      subtests: List<String>.from(json['subtests']),
      interpretation: Map<String, dynamic>.from(json['interpretation']),
    );
  }
}

class TestAdministration {
  final String id;
  final String testId;
  final String patientId;
  final String psychologistId;
  final DateTime administrationDate;
  final DateTime? completionDate;
  final TestAdministrationType administrationType;
  final String environment; // clinic, home, school, etc.
  final String examinerNotes;
  final Map<String, dynamic> rawScores;
  final Map<String, dynamic> scaledScores;
  final Map<String, dynamic> percentileRanks;
  final String interpretation;
  final List<String> recommendations;
  final bool isCompleted;
  final Map<String, dynamic> metadata;

  TestAdministration({
    required this.id,
    required this.testId,
    required this.patientId,
    required this.psychologistId,
    required this.administrationDate,
    this.completionDate,
    required this.administrationType,
    required this.environment,
    required this.examinerNotes,
    required this.rawScores,
    required this.scaledScores,
    required this.percentileRanks,
    required this.interpretation,
    required this.recommendations,
    this.isCompleted = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'testId': testId,
      'patientId': patientId,
      'psychologistId': psychologistId,
      'administrationDate': administrationDate.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'administrationType': administrationType.name,
      'environment': environment,
      'examinerNotes': examinerNotes,
      'rawScores': rawScores,
      'scaledScores': scaledScores,
      'percentileRanks': percentileRanks,
      'interpretation': interpretation,
      'recommendations': recommendations,
      'isCompleted': isCompleted,
      'metadata': metadata,
    };
  }

  factory TestAdministration.fromJson(Map<String, dynamic> json) {
    return TestAdministration(
      id: json['id'],
      testId: json['testId'],
      patientId: json['patientId'],
      psychologistId: json['psychologistId'],
      administrationDate: DateTime.parse(json['administrationDate']),
      completionDate: json['completionDate'] != null ? DateTime.parse(json['completionDate']) : null,
      administrationType: TestAdministrationType.values.firstWhere((e) => e.name == json['administrationType']),
      environment: json['environment'],
      examinerNotes: json['examinerNotes'],
      rawScores: Map<String, dynamic>.from(json['rawScores']),
      scaledScores: Map<String, dynamic>.from(json['scaledScores']),
      percentileRanks: Map<String, dynamic>.from(json['percentileRanks']),
      interpretation: json['interpretation'],
      recommendations: List<String>.from(json['recommendations']),
      isCompleted: json['isCompleted'] ?? false,
      metadata: json['metadata'] ?? {},
    );
  }
}

class PsychologicalReport {
  final String id;
  final String patientId;
  final String psychologistId;
  final DateTime reportDate;
  final String reportType; // initial, progress, final, etc.
  final String referralQuestion;
  final String background;
  final String behavioralObservations;
  final List<TestAdministration> testAdministrations;
  final String testResults;
  final String interpretation;
  final String diagnosticImpressions;
  final List<String> recommendations;
  final String prognosis;
  final String signature;
  final String licenseNumber;
  final bool isFinalized;
  final Map<String, dynamic> metadata;

  PsychologicalReport({
    required this.id,
    required this.patientId,
    required this.psychologistId,
    required this.reportDate,
    required this.reportType,
    required this.referralQuestion,
    required this.background,
    required this.behavioralObservations,
    required this.testAdministrations,
    required this.testResults,
    required this.interpretation,
    required this.diagnosticImpressions,
    required this.recommendations,
    required this.prognosis,
    required this.signature,
    required this.licenseNumber,
    this.isFinalized = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychologistId': psychologistId,
      'reportDate': reportDate.toIso8601String(),
      'reportType': reportType,
      'referralQuestion': referralQuestion,
      'background': background,
      'behavioralObservations': behavioralObservations,
      'testAdministrations': testAdministrations.map((t) => t.toJson()).toList(),
      'testResults': testResults,
      'interpretation': interpretation,
      'diagnosticImpressions': diagnosticImpressions,
      'recommendations': recommendations,
      'prognosis': prognosis,
      'signature': signature,
      'licenseNumber': licenseNumber,
      'isFinalized': isFinalized,
      'metadata': metadata,
    };
  }

  factory PsychologicalReport.fromJson(Map<String, dynamic> json) {
    return PsychologicalReport(
      id: json['id'],
      patientId: json['patientId'],
      psychologistId: json['psychologistId'],
      reportDate: DateTime.parse(json['reportDate']),
      reportType: json['reportType'],
      referralQuestion: json['referralQuestion'],
      background: json['background'],
      behavioralObservations: json['behavioralObservations'],
      testAdministrations: (json['testAdministrations'] as List).map((t) => TestAdministration.fromJson(t)).toList(),
      testResults: json['testResults'],
      interpretation: json['interpretation'],
      diagnosticImpressions: json['diagnosticImpressions'],
      recommendations: List<String>.from(json['recommendations']),
      prognosis: json['prognosis'],
      signature: json['signature'],
      licenseNumber: json['licenseNumber'],
      isFinalized: json['isFinalized'] ?? false,
      metadata: json['metadata'] ?? {},
    );
  }
}

class SupervisionSession {
  final String id;
  final String superviseeId;
  final String supervisorId;
  final DateTime sessionDate;
  final int duration; // minutes
  final String sessionType; // individual, group, case conference
  final List<String> casesDiscussed;
  final String sessionNotes;
  final List<String> learningObjectives;
  final List<String> competenciesAddressed;
  final String feedback;
  final List<String> actionItems;
  final DateTime nextSessionDate;
  final Map<String, dynamic> evaluation;
  final Map<String, dynamic> metadata;

  SupervisionSession({
    required this.id,
    required this.superviseeId,
    required this.supervisorId,
    required this.sessionDate,
    required this.duration,
    required this.sessionType,
    required this.casesDiscussed,
    required this.sessionNotes,
    required this.learningObjectives,
    required this.competenciesAddressed,
    required this.feedback,
    required this.actionItems,
    required this.nextSessionDate,
    required this.evaluation,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'superviseeId': superviseeId,
      'supervisorId': supervisorId,
      'sessionDate': sessionDate.toIso8601String(),
      'duration': duration,
      'sessionType': sessionType,
      'casesDiscussed': casesDiscussed,
      'sessionNotes': sessionNotes,
      'learningObjectives': learningObjectives,
      'competenciesAddressed': competenciesAddressed,
      'feedback': feedback,
      'actionItems': actionItems,
      'nextSessionDate': nextSessionDate.toIso8601String(),
      'evaluation': evaluation,
      'metadata': metadata,
    };
  }

  factory SupervisionSession.fromJson(Map<String, dynamic> json) {
    return SupervisionSession(
      id: json['id'],
      superviseeId: json['superviseeId'],
      supervisorId: json['supervisorId'],
      sessionDate: DateTime.parse(json['sessionDate']),
      duration: json['duration'],
      sessionType: json['sessionType'],
      casesDiscussed: List<String>.from(json['casesDiscussed']),
      sessionNotes: json['sessionNotes'],
      learningObjectives: List<String>.from(json['learningObjectives']),
      competenciesAddressed: List<String>.from(json['competenciesAddressed']),
      feedback: json['feedback'],
      actionItems: List<String>.from(json['actionItems']),
      nextSessionDate: DateTime.parse(json['nextSessionDate']),
      evaluation: Map<String, dynamic>.from(json['evaluation']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class CompetencyAssessment {
  final String id;
  final String psychologistId;
  final String supervisorId;
  final DateTime assessmentDate;
  final Map<String, int> competencyRatings; // competency -> rating (1-5)
  final List<String> strengths;
  final List<String> areasForImprovement;
  final List<String> developmentGoals;
  final String overallAssessment;
  final List<String> recommendations;
  final DateTime nextAssessmentDate;
  final Map<String, dynamic> metadata;

  CompetencyAssessment({
    required this.id,
    required this.psychologistId,
    required this.supervisorId,
    required this.assessmentDate,
    required this.competencyRatings,
    required this.strengths,
    required this.areasForImprovement,
    required this.developmentGoals,
    required this.overallAssessment,
    required this.recommendations,
    required this.nextAssessmentDate,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'psychologistId': psychologistId,
      'supervisorId': supervisorId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'competencyRatings': competencyRatings,
      'strengths': strengths,
      'areasForImprovement': areasForImprovement,
      'developmentGoals': developmentGoals,
      'overallAssessment': overallAssessment,
      'recommendations': recommendations,
      'nextAssessmentDate': nextAssessmentDate.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory CompetencyAssessment.fromJson(Map<String, dynamic> json) {
    return CompetencyAssessment(
      id: json['id'],
      psychologistId: json['psychologistId'],
      supervisorId: json['supervisorId'],
      assessmentDate: DateTime.parse(json['assessmentDate']),
      competencyRatings: Map<String, int>.from(json['competencyRatings']),
      strengths: List<String>.from(json['strengths']),
      areasForImprovement: List<String>.from(json['areasForImprovement']),
      developmentGoals: List<String>.from(json['developmentGoals']),
      overallAssessment: json['overallAssessment'],
      recommendations: List<String>.from(json['recommendations']),
      nextAssessmentDate: DateTime.parse(json['nextAssessmentDate']),
      metadata: json['metadata'] ?? {},
    );
  }
}

class TestBattery {
  final String id;
  final String name;
  final String description;
  final List<String> testIds;
  final String purpose;
  final int estimatedTotalDuration;
  final List<String> requiredQualifications;
  final Map<String, dynamic> administrationOrder;
  final List<String> interpretationGuidelines;
  final Map<String, dynamic> metadata;

  TestBattery({
    required this.id,
    required this.name,
    required this.description,
    required this.testIds,
    required this.purpose,
    required this.estimatedTotalDuration,
    required this.requiredQualifications,
    required this.administrationOrder,
    required this.interpretationGuidelines,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'testIds': testIds,
      'purpose': purpose,
      'estimatedTotalDuration': estimatedTotalDuration,
      'requiredQualifications': requiredQualifications,
      'administrationOrder': administrationOrder,
      'interpretationGuidelines': interpretationGuidelines,
      'metadata': metadata,
    };
  }

  factory TestBattery.fromJson(Map<String, dynamic> json) {
    return TestBattery(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      testIds: List<String>.from(json['testIds']),
      purpose: json['purpose'],
      estimatedTotalDuration: json['estimatedTotalDuration'],
      requiredQualifications: List<String>.from(json['requiredQualifications']),
      administrationOrder: Map<String, dynamic>.from(json['administrationOrder']),
      interpretationGuidelines: List<String>.from(json['interpretationGuidelines']),
      metadata: json['metadata'] ?? {},
    );
  }
}
