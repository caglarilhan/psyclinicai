class PsychiatricDiagnosis {
  final String id;
  final String patientId;
  final String psychiatristId;
  final String diagnosis;
  final String icdCode;
  final String dsmCode;
  final DiagnosisType type;
  final DiagnosisSeverity severity;
  final DateTime diagnosedAt;
  final String? differentialDiagnosis;
  final String? rationale;
  final String? prognosis;
  final String? treatmentPlan;
  final String? notes;
  final Map<String, dynamic> metadata;

  const PsychiatricDiagnosis({
    required this.id,
    required this.patientId,
    required this.psychiatristId,
    required this.diagnosis,
    required this.icdCode,
    required this.dsmCode,
    required this.type,
    required this.severity,
    required this.diagnosedAt,
    this.differentialDiagnosis,
    this.rationale,
    this.prognosis,
    this.treatmentPlan,
    this.notes,
    this.metadata = const {},
  });

  factory PsychiatricDiagnosis.fromJson(Map<String, dynamic> json) {
    return PsychiatricDiagnosis(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      psychiatristId: json['psychiatristId'] as String,
      diagnosis: json['diagnosis'] as String,
      icdCode: json['icdCode'] as String,
      dsmCode: json['dsmCode'] as String,
      type: DiagnosisType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DiagnosisType.primary,
      ),
      severity: DiagnosisSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => DiagnosisSeverity.mild,
      ),
      diagnosedAt: DateTime.parse(json['diagnosedAt'] as String),
      differentialDiagnosis: json['differentialDiagnosis'] as String?,
      rationale: json['rationale'] as String?,
      prognosis: json['prognosis'] as String?,
      treatmentPlan: json['treatmentPlan'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'diagnosis': diagnosis,
      'icdCode': icdCode,
      'dsmCode': dsmCode,
      'type': type.name,
      'severity': severity.name,
      'diagnosedAt': diagnosedAt.toIso8601String(),
      'differentialDiagnosis': differentialDiagnosis,
      'rationale': rationale,
      'prognosis': prognosis,
      'treatmentPlan': treatmentPlan,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class TreatmentPlan {
  final String id;
  final String patientId;
  final String psychiatristId;
  final String diagnosisId;
  final String title;
  final String description;
  final TreatmentType type;
  final TreatmentPhase phase;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> goals;
  final List<String> interventions;
  final List<String> medications;
  final List<String> therapies;
  final String? monitoring;
  final String? notes;
  final TreatmentStatus status;
  final Map<String, dynamic> metadata;

  const TreatmentPlan({
    required this.id,
    required this.patientId,
    required this.psychiatristId,
    required this.diagnosisId,
    required this.title,
    required this.description,
    required this.type,
    required this.phase,
    required this.startDate,
    this.endDate,
    this.goals = const [],
    this.interventions = const [],
    this.medications = const [],
    this.therapies = const [],
    this.monitoring,
    this.notes,
    this.status = TreatmentStatus.active,
    this.metadata = const {},
  });

  factory TreatmentPlan.fromJson(Map<String, dynamic> json) {
    return TreatmentPlan(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      psychiatristId: json['psychiatristId'] as String,
      diagnosisId: json['diagnosisId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: TreatmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TreatmentType.medication,
      ),
      phase: TreatmentPhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => TreatmentPhase.initial,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String) 
          : null,
      goals: List<String>.from(json['goals'] as List? ?? []),
      interventions: List<String>.from(json['interventions'] as List? ?? []),
      medications: List<String>.from(json['medications'] as List? ?? []),
      therapies: List<String>.from(json['therapies'] as List? ?? []),
      monitoring: json['monitoring'] as String?,
      notes: json['notes'] as String?,
      status: TreatmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TreatmentStatus.active,
      ),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'diagnosisId': diagnosisId,
      'title': title,
      'description': description,
      'type': type.name,
      'phase': phase.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'goals': goals,
      'interventions': interventions,
      'medications': medications,
      'therapies': therapies,
      'monitoring': monitoring,
      'notes': notes,
      'status': status.name,
      'metadata': metadata,
    };
  }

  // Check if treatment plan is active
  bool get isActive {
    return status == TreatmentStatus.active;
  }

  // Check if treatment plan is completed
  bool get isCompleted {
    return status == TreatmentStatus.completed;
  }
}

class TreatmentProgress {
  final String id;
  final String treatmentPlanId;
  final String patientId;
  final String psychiatristId;
  final DateTime date;
  final ProgressType type;
  final String parameter;
  final String value;
  final String unit;
  final String? notes;
  final String? actionTaken;
  final Map<String, dynamic> metadata;

  const TreatmentProgress({
    required this.id,
    required this.treatmentPlanId,
    required this.patientId,
    required this.psychiatristId,
    required this.date,
    required this.type,
    required this.parameter,
    required this.value,
    required this.unit,
    this.notes,
    this.actionTaken,
    this.metadata = const {},
  });

  factory TreatmentProgress.fromJson(Map<String, dynamic> json) {
    return TreatmentProgress(
      id: json['id'] as String,
      treatmentPlanId: json['treatmentPlanId'] as String,
      patientId: json['patientId'] as String,
      psychiatristId: json['psychiatristId'] as String,
      date: DateTime.parse(json['date'] as String),
      type: ProgressType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ProgressType.clinical,
      ),
      parameter: json['parameter'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String,
      notes: json['notes'] as String?,
      actionTaken: json['actionTaken'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'treatmentPlanId': treatmentPlanId,
      'patientId': patientId,
      'psychiatristId': psychiatristId,
      'date': date.toIso8601String(),
      'type': type.name,
      'parameter': parameter,
      'value': value,
      'unit': unit,
      'notes': notes,
      'actionTaken': actionTaken,
      'metadata': metadata,
    };
  }
}

class PsychiatricConsultation {
  final String id;
  final String patientId;
  final String requestingPhysicianId;
  final String consultingPsychiatristId;
  final String reason;
  final String question;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final ConsultationStatus status;
  final String? assessment;
  final String? recommendations;
  final String? followUp;
  final String? notes;
  final Map<String, dynamic> metadata;

  const PsychiatricConsultation({
    required this.id,
    required this.patientId,
    required this.requestingPhysicianId,
    required this.consultingPsychiatristId,
    required this.reason,
    required this.question,
    required this.requestedAt,
    this.completedAt,
    this.status = ConsultationStatus.pending,
    this.assessment,
    this.recommendations,
    this.followUp,
    this.notes,
    this.metadata = const {},
  });

  factory PsychiatricConsultation.fromJson(Map<String, dynamic> json) {
    return PsychiatricConsultation(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      requestingPhysicianId: json['requestingPhysicianId'] as String,
      consultingPsychiatristId: json['consultingPsychiatristId'] as String,
      reason: json['reason'] as String,
      question: json['question'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
      status: ConsultationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsultationStatus.pending,
      ),
      assessment: json['assessment'] as String?,
      recommendations: json['recommendations'] as String?,
      followUp: json['followUp'] as String?,
      notes: json['notes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'requestingPhysicianId': requestingPhysicianId,
      'consultingPsychiatristId': consultingPsychiatristId,
      'reason': reason,
      'question': question,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status.name,
      'assessment': assessment,
      'recommendations': recommendations,
      'followUp': followUp,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // Check if consultation is pending
  bool get isPending {
    return status == ConsultationStatus.pending;
  }

  // Check if consultation is completed
  bool get isCompleted {
    return status == ConsultationStatus.completed;
  }
}

enum DiagnosisType {
  primary,
  secondary,
  differential,
  ruleOut,
}

enum DiagnosisSeverity {
  mild,
  moderate,
  severe,
  critical,
}

enum TreatmentType {
  medication,
  therapy,
  combined,
  supportive,
  other,
}

enum TreatmentPhase {
  initial,
  acute,
  maintenance,
  recovery,
  followUp,
}

enum TreatmentStatus {
  active,
  completed,
  suspended,
  discontinued,
}

enum ProgressType {
  clinical,
  laboratory,
  behavioral,
  functional,
  other,
}

enum ConsultationStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}
