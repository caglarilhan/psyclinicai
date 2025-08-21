// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advanced_patient_tracking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientTrackingProfile _$PatientTrackingProfileFromJson(
  Map<String, dynamic> json,
) => PatientTrackingProfile(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  clinicianId: json['clinicianId'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  status: json['status'] as String,
  activeModules: (json['activeModules'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  alerts: (json['alerts'] as List<dynamic>).map((e) => e as String).toList(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PatientTrackingProfileToJson(
  PatientTrackingProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'clinicianId': instance.clinicianId,
  'startDate': instance.startDate.toIso8601String(),
  'lastUpdated': instance.lastUpdated.toIso8601String(),
  'status': instance.status,
  'activeModules': instance.activeModules,
  'alerts': instance.alerts,
  'metadata': instance.metadata,
};

MoodTimeline _$MoodTimelineFromJson(Map<String, dynamic> json) => MoodTimeline(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  entries: (json['entries'] as List<dynamic>)
      .map((e) => MoodEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  trends: (json['trends'] as List<dynamic>)
      .map((e) => MoodTrend.fromJson(e as Map<String, dynamic>))
      .toList(),
  alerts: (json['alerts'] as List<dynamic>)
      .map((e) => MoodAlert.fromJson(e as Map<String, dynamic>))
      .toList(),
  analysis: MoodAnalysis.fromJson(json['analysis'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MoodTimelineToJson(MoodTimeline instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'entries': instance.entries,
      'trends': instance.trends,
      'alerts': instance.alerts,
      'analysis': instance.analysis,
    };

MoodEntry _$MoodEntryFromJson(Map<String, dynamic> json) => MoodEntry(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  moodScore: (json['moodScore'] as num).toDouble(),
  moodType: json['moodType'] as String,
  symptoms: (json['symptoms'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String?,
  location: json['location'] as String?,
  context: json['context'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$MoodEntryToJson(MoodEntry instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'moodScore': instance.moodScore,
  'moodType': instance.moodType,
  'symptoms': instance.symptoms,
  'notes': instance.notes,
  'location': instance.location,
  'context': instance.context,
};

MoodTrend _$MoodTrendFromJson(Map<String, dynamic> json) => MoodTrend(
  id: json['id'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  direction: json['direction'] as String,
  changeRate: (json['changeRate'] as num).toDouble(),
  contributingFactors: (json['contributingFactors'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$MoodTrendToJson(MoodTrend instance) => <String, dynamic>{
  'id': instance.id,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'direction': instance.direction,
  'changeRate': instance.changeRate,
  'contributingFactors': instance.contributingFactors,
  'confidence': instance.confidence,
  'recommendations': instance.recommendations,
};

MoodAlert _$MoodAlertFromJson(Map<String, dynamic> json) => MoodAlert(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  type: json['type'] as String,
  message: json['message'] as String,
  severity: (json['severity'] as num).toDouble(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  isAcknowledged: json['isAcknowledged'] as bool,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  acknowledgedBy: json['acknowledgedBy'] as String?,
);

Map<String, dynamic> _$MoodAlertToJson(MoodAlert instance) => <String, dynamic>{
  'id': instance.id,
  'timestamp': instance.timestamp.toIso8601String(),
  'type': instance.type,
  'message': instance.message,
  'severity': instance.severity,
  'actions': instance.actions,
  'isAcknowledged': instance.isAcknowledged,
  'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
  'acknowledgedBy': instance.acknowledgedBy,
};

MoodAnalysis _$MoodAnalysisFromJson(Map<String, dynamic> json) => MoodAnalysis(
  id: json['id'] as String,
  analysisDate: DateTime.parse(json['analysisDate'] as String),
  averageMood: (json['averageMood'] as num).toDouble(),
  moodStability: (json['moodStability'] as num).toDouble(),
  patterns: (json['patterns'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$MoodAnalysisToJson(MoodAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'analysisDate': instance.analysisDate.toIso8601String(),
      'averageMood': instance.averageMood,
      'moodStability': instance.moodStability,
      'patterns': instance.patterns,
      'triggers': instance.triggers,
      'recommendations': instance.recommendations,
      'confidence': instance.confidence,
    };

QualityOfLifePanel _$QualityOfLifePanelFromJson(Map<String, dynamic> json) =>
    QualityOfLifePanel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      assessments: (json['assessments'] as List<dynamic>)
          .map(
            (e) => QualityOfLifeAssessment.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      trend: QualityOfLifeTrend.fromJson(json['trend'] as Map<String, dynamic>),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$QualityOfLifePanelToJson(QualityOfLifePanel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'assessments': instance.assessments,
      'trend': instance.trend,
      'recommendations': instance.recommendations,
    };

QualityOfLifeAssessment _$QualityOfLifeAssessmentFromJson(
  Map<String, dynamic> json,
) => QualityOfLifeAssessment(
  id: json['id'] as String,
  assessmentDate: DateTime.parse(json['assessmentDate'] as String),
  scale: json['scale'] as String,
  domainScores: (json['domainScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  overallScore: (json['overallScore'] as num).toDouble(),
  notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
  clinicianNotes: json['clinicianNotes'] as String?,
);

Map<String, dynamic> _$QualityOfLifeAssessmentToJson(
  QualityOfLifeAssessment instance,
) => <String, dynamic>{
  'id': instance.id,
  'assessmentDate': instance.assessmentDate.toIso8601String(),
  'scale': instance.scale,
  'domainScores': instance.domainScores,
  'overallScore': instance.overallScore,
  'notes': instance.notes,
  'clinicianNotes': instance.clinicianNotes,
};

QualityOfLifeTrend _$QualityOfLifeTrendFromJson(Map<String, dynamic> json) =>
    QualityOfLifeTrend(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      domainChanges: (json['domainChanges'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      overallChange: (json['overallChange'] as num).toDouble(),
      significantChanges: (json['significantChanges'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contributingFactors: (json['contributingFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$QualityOfLifeTrendToJson(QualityOfLifeTrend instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'domainChanges': instance.domainChanges,
      'overallChange': instance.overallChange,
      'significantChanges': instance.significantChanges,
      'contributingFactors': instance.contributingFactors,
    };

PolypharmacyTracker _$PolypharmacyTrackerFromJson(Map<String, dynamic> json) =>
    PolypharmacyTracker(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      activeMedications: (json['activeMedications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      medicationCount: (json['medicationCount'] as num).toInt(),
      riskLevel: json['riskLevel'] as String,
      interactions: (json['interactions'] as List<dynamic>)
          .map((e) => DrugInteraction.fromJson(e as Map<String, dynamic>))
          .toList(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => SideEffect.fromJson(e as Map<String, dynamic>))
          .toList(),
      adherenceScore: (json['adherenceScore'] as num).toDouble(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PolypharmacyTrackerToJson(
  PolypharmacyTracker instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'activeMedications': instance.activeMedications,
  'medicationCount': instance.medicationCount,
  'riskLevel': instance.riskLevel,
  'interactions': instance.interactions,
  'sideEffects': instance.sideEffects,
  'adherenceScore': instance.adherenceScore,
  'recommendations': instance.recommendations,
  'alerts': instance.alerts,
};

SideEffect _$SideEffectFromJson(Map<String, dynamic> json) => SideEffect(
  id: json['id'] as String,
  medicationId: json['medicationId'] as String,
  medicationName: json['medicationName'] as String,
  symptom: json['symptom'] as String,
  severity: json['severity'] as String,
  onsetDate: DateTime.parse(json['onsetDate'] as String),
  resolutionDate: json['resolutionDate'] == null
      ? null
      : DateTime.parse(json['resolutionDate'] as String),
  notes: json['notes'] as String?,
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$SideEffectToJson(SideEffect instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'medicationName': instance.medicationName,
      'symptom': instance.symptom,
      'severity': instance.severity,
      'onsetDate': instance.onsetDate.toIso8601String(),
      'resolutionDate': instance.resolutionDate?.toIso8601String(),
      'notes': instance.notes,
      'actions': instance.actions,
    };

FamilyObservationModule _$FamilyObservationModuleFromJson(
  Map<String, dynamic> json,
) => FamilyObservationModule(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  familyMembers: (json['familyMembers'] as List<dynamic>)
      .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
      .toList(),
  assessments: (json['assessments'] as List<dynamic>)
      .map((e) => FamilyAssessment.fromJson(e as Map<String, dynamic>))
      .toList(),
  alerts: (json['alerts'] as List<dynamic>)
      .map((e) => FamilyAlert.fromJson(e as Map<String, dynamic>))
      .toList(),
  supportLevel: json['supportLevel'] as String,
);

Map<String, dynamic> _$FamilyObservationModuleToJson(
  FamilyObservationModule instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'familyMembers': instance.familyMembers,
  'assessments': instance.assessments,
  'alerts': instance.alerts,
  'supportLevel': instance.supportLevel,
};

FamilyMember _$FamilyMemberFromJson(Map<String, dynamic> json) => FamilyMember(
  id: json['id'] as String,
  name: json['name'] as String,
  relationship: json['relationship'] as String,
  age: (json['age'] as num).toInt(),
  contactInfo: json['contactInfo'] as String?,
  isPrimaryCaregiver: json['isPrimaryCaregiver'] as bool,
  observations: (json['observations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastContact: DateTime.parse(json['lastContact'] as String),
);

Map<String, dynamic> _$FamilyMemberToJson(FamilyMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'relationship': instance.relationship,
      'age': instance.age,
      'contactInfo': instance.contactInfo,
      'isPrimaryCaregiver': instance.isPrimaryCaregiver,
      'observations': instance.observations,
      'lastContact': instance.lastContact.toIso8601String(),
    };

FamilyAssessment _$FamilyAssessmentFromJson(Map<String, dynamic> json) =>
    FamilyAssessment(
      id: json['id'] as String,
      assessmentDate: DateTime.parse(json['assessmentDate'] as String),
      familyMemberId: json['familyMemberId'] as String,
      familyMemberName: json['familyMemberName'] as String,
      scaleScores: (json['scaleScores'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      observations: (json['observations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      concerns: (json['concerns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FamilyAssessmentToJson(FamilyAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assessmentDate': instance.assessmentDate.toIso8601String(),
      'familyMemberId': instance.familyMemberId,
      'familyMemberName': instance.familyMemberName,
      'scaleScores': instance.scaleScores,
      'observations': instance.observations,
      'concerns': instance.concerns,
      'recommendations': instance.recommendations,
    };

FamilyAlert _$FamilyAlertFromJson(Map<String, dynamic> json) => FamilyAlert(
  id: json['id'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  familyMemberId: json['familyMemberId'] as String,
  familyMemberName: json['familyMemberName'] as String,
  type: json['type'] as String,
  message: json['message'] as String,
  severity: (json['severity'] as num).toDouble(),
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  isAcknowledged: json['isAcknowledged'] as bool,
);

Map<String, dynamic> _$FamilyAlertToJson(FamilyAlert instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'familyMemberId': instance.familyMemberId,
      'familyMemberName': instance.familyMemberName,
      'type': instance.type,
      'message': instance.message,
      'severity': instance.severity,
      'actions': instance.actions,
      'isAcknowledged': instance.isAcknowledged,
    };

PatientTrackingSummary _$PatientTrackingSummaryFromJson(
  Map<String, dynamic> json,
) => PatientTrackingSummary(
  id: json['id'] as String,
  patientId: json['patientId'] as String,
  summaryDate: DateTime.parse(json['summaryDate'] as String),
  overallStatus: json['overallStatus'] as String,
  moodAnalysis: MoodAnalysis.fromJson(
    json['moodAnalysis'] as Map<String, dynamic>,
  ),
  qualityOfLifeTrend: QualityOfLifeTrend.fromJson(
    json['qualityOfLifeTrend'] as Map<String, dynamic>,
  ),
  polypharmacyRisk: json['polypharmacyRisk'] as String,
  familySupport: json['familySupport'] as String,
  criticalAlerts: (json['criticalAlerts'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommendations: (json['recommendations'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  overallProgress: (json['overallProgress'] as num).toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PatientTrackingSummaryToJson(
  PatientTrackingSummary instance,
) => <String, dynamic>{
  'id': instance.id,
  'patientId': instance.patientId,
  'summaryDate': instance.summaryDate.toIso8601String(),
  'overallStatus': instance.overallStatus,
  'moodAnalysis': instance.moodAnalysis,
  'qualityOfLifeTrend': instance.qualityOfLifeTrend,
  'polypharmacyRisk': instance.polypharmacyRisk,
  'familySupport': instance.familySupport,
  'criticalAlerts': instance.criticalAlerts,
  'recommendations': instance.recommendations,
  'overallProgress': instance.overallProgress,
  'metadata': instance.metadata,
};
