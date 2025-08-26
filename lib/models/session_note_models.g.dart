// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_note_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionNote _$SessionNoteFromJson(Map<String, dynamic> json) => SessionNote(
  id: json['id'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  sessionId: json['sessionId'] as String,
  type: $enumDecode(_$SessionNoteTypeEnumMap, json['type']),
  status: $enumDecode(_$SessionStatusEnumMap, json['status']),
  notes: json['notes'] as String,
  aiSummary: json['aiSummary'] as String?,
  aiStatus: $enumDecode(_$AIAnalysisStatusEnumMap, json['aiStatus']),
  sessionDate: DateTime.parse(json['sessionDate'] as String),
  duration: (json['duration'] as num).toInt(),
  location: json['location'] as String?,
  modality: json['modality'] as String?,
  additionalData: json['additionalData'] as Map<String, dynamic>?,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SessionNoteToJson(SessionNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'sessionId': instance.sessionId,
      'type': _$SessionNoteTypeEnumMap[instance.type]!,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'aiSummary': instance.aiSummary,
      'aiStatus': _$AIAnalysisStatusEnumMap[instance.aiStatus]!,
      'sessionDate': instance.sessionDate.toIso8601String(),
      'duration': instance.duration,
      'location': instance.location,
      'modality': instance.modality,
      'additionalData': instance.additionalData,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$SessionNoteTypeEnumMap = {
  SessionNoteType.initial: 'initial',
  SessionNoteType.follow_up: 'follow_up',
  SessionNoteType.crisis: 'crisis',
  SessionNoteType.termination: 'termination',
  SessionNoteType.supervision: 'supervision',
  SessionNoteType.group: 'group',
  SessionNoteType.family: 'family',
  SessionNoteType.assessment: 'assessment',
};

const _$SessionStatusEnumMap = {
  SessionStatus.scheduled: 'scheduled',
  SessionStatus.in_progress: 'in_progress',
  SessionStatus.completed: 'completed',
  SessionStatus.cancelled: 'cancelled',
  SessionStatus.no_show: 'no_show',
  SessionStatus.rescheduled: 'rescheduled',
};

const _$AIAnalysisStatusEnumMap = {
  AIAnalysisStatus.pending: 'pending',
  AIAnalysisStatus.processing: 'processing',
  AIAnalysisStatus.completed: 'completed',
  AIAnalysisStatus.failed: 'failed',
  AIAnalysisStatus.reviewed: 'reviewed',
};

AISessionAnalysis _$AISessionAnalysisFromJson(Map<String, dynamic> json) =>
    AISessionAnalysis(
      id: json['id'] as String,
      sessionNoteId: json['sessionNoteId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      status: $enumDecode(_$AIAnalysisStatusEnumMap, json['status']),
      affect: json['affect'] as String?,
      theme: json['theme'] as String?,
      diagnosisSuggestion: json['diagnosisSuggestion'] as String?,
      diagnosisStandard: $enumDecode(
        _$DiagnosisStandardEnumMap,
        json['diagnosisStandard'],
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      keyTopics: (json['keyTopics'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      strengths: (json['strengths'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      emotionalAnalysis: json['emotionalAnalysis'] as Map<String, dynamic>,
      behavioralPatterns: json['behavioralPatterns'] as Map<String, dynamic>,
      therapeuticProgress: json['therapeuticProgress'] as Map<String, dynamic>,
      rawAnalysis: json['rawAnalysis'] as String?,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
      analyzedBy: json['analyzedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$AISessionAnalysisToJson(
  AISessionAnalysis instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionNoteId': instance.sessionNoteId,
  'clientId': instance.clientId,
  'therapistId': instance.therapistId,
  'status': _$AIAnalysisStatusEnumMap[instance.status]!,
  'affect': instance.affect,
  'theme': instance.theme,
  'diagnosisSuggestion': instance.diagnosisSuggestion,
  'diagnosisStandard': _$DiagnosisStandardEnumMap[instance.diagnosisStandard]!,
  'confidenceScore': instance.confidenceScore,
  'keyTopics': instance.keyTopics,
  'riskFactors': instance.riskFactors,
  'strengths': instance.strengths,
  'recommendations': instance.recommendations,
  'emotionalAnalysis': instance.emotionalAnalysis,
  'behavioralPatterns': instance.behavioralPatterns,
  'therapeuticProgress': instance.therapeuticProgress,
  'rawAnalysis': instance.rawAnalysis,
  'analyzedAt': instance.analyzedAt.toIso8601String(),
  'analyzedBy': instance.analyzedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};

const _$DiagnosisStandardEnumMap = {
  DiagnosisStandard.dsm_5_tr: 'dsm_5_tr',
  DiagnosisStandard.icd_11: 'icd_11',
  DiagnosisStandard.icd_10: 'icd_10',
  DiagnosisStandard.mixed: 'mixed',
};

SessionTemplate _$SessionTemplateFromJson(Map<String, dynamic> json) =>
    SessionTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$SessionNoteTypeEnumMap, json['type']),
      templateContent: json['templateContent'] as String,
      requiredFields: (json['requiredFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      optionalFields: (json['optionalFields'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      defaultValues: json['defaultValues'] as Map<String, dynamic>,
      isActive: json['isActive'] as bool,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionTemplateToJson(SessionTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$SessionNoteTypeEnumMap[instance.type]!,
      'templateContent': instance.templateContent,
      'requiredFields': instance.requiredFields,
      'optionalFields': instance.optionalFields,
      'defaultValues': instance.defaultValues,
      'isActive': instance.isActive,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

SessionSummary _$SessionSummaryFromJson(Map<String, dynamic> json) =>
    SessionSummary(
      id: json['id'] as String,
      sessionNoteId: json['sessionNoteId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      summaryText: json['summaryText'] as String,
      affect: json['affect'] as String?,
      theme: json['theme'] as String?,
      diagnosisSuggestion: json['diagnosisSuggestion'] as String?,
      keyPoints: (json['keyPoints'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      actionItems: (json['actionItems'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      followUpTasks: (json['followUpTasks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      progressNotes: json['progressNotes'] as Map<String, dynamic>,
      isReviewed: json['isReviewed'] as bool,
      reviewedBy: json['reviewedBy'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionSummaryToJson(SessionSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionNoteId': instance.sessionNoteId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'summaryText': instance.summaryText,
      'affect': instance.affect,
      'theme': instance.theme,
      'diagnosisSuggestion': instance.diagnosisSuggestion,
      'keyPoints': instance.keyPoints,
      'actionItems': instance.actionItems,
      'followUpTasks': instance.followUpTasks,
      'progressNotes': instance.progressNotes,
      'isReviewed': instance.isReviewed,
      'reviewedBy': instance.reviewedBy,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

SessionFlag _$SessionFlagFromJson(Map<String, dynamic> json) => SessionFlag(
  id: json['id'] as String,
  sessionNoteId: json['sessionNoteId'] as String,
  clientId: json['clientId'] as String,
  therapistId: json['therapistId'] as String,
  flagType: json['flagType'] as String,
  severity: json['severity'] as String,
  description: json['description'] as String,
  recommendation: json['recommendation'] as String?,
  isAcknowledged: json['isAcknowledged'] as bool,
  acknowledgedBy: json['acknowledgedBy'] as String?,
  acknowledgedAt: json['acknowledgedAt'] == null
      ? null
      : DateTime.parse(json['acknowledgedAt'] as String),
  requiresFollowUp: json['requiresFollowUp'] as bool,
  followUpDate: json['followUpDate'] == null
      ? null
      : DateTime.parse(json['followUpDate'] as String),
  followUpNotes: json['followUpNotes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  metadata: json['metadata'] as Map<String, dynamic>,
);

Map<String, dynamic> _$SessionFlagToJson(SessionFlag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionNoteId': instance.sessionNoteId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'flagType': instance.flagType,
      'severity': instance.severity,
      'description': instance.description,
      'recommendation': instance.recommendation,
      'isAcknowledged': instance.isAcknowledged,
      'acknowledgedBy': instance.acknowledgedBy,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'requiresFollowUp': instance.requiresFollowUp,
      'followUpDate': instance.followUpDate?.toIso8601String(),
      'followUpNotes': instance.followUpNotes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

SessionProgress _$SessionProgressFromJson(Map<String, dynamic> json) =>
    SessionProgress(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      sessionNoteId: json['sessionNoteId'] as String,
      sessionNumber: (json['sessionNumber'] as num).toInt(),
      progressType: json['progressType'] as String,
      progressDescription: json['progressDescription'] as String,
      metrics: json['metrics'] as Map<String, dynamic>,
      goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
      achievedGoals: (json['achievedGoals'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      nextGoals: (json['nextGoals'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      therapistNotes: json['therapistNotes'] as String?,
      sessionDate: DateTime.parse(json['sessionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionProgressToJson(SessionProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'sessionNoteId': instance.sessionNoteId,
      'sessionNumber': instance.sessionNumber,
      'progressType': instance.progressType,
      'progressDescription': instance.progressDescription,
      'metrics': instance.metrics,
      'goals': instance.goals,
      'achievedGoals': instance.achievedGoals,
      'nextGoals': instance.nextGoals,
      'therapistNotes': instance.therapistNotes,
      'sessionDate': instance.sessionDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

SessionExport _$SessionExportFromJson(Map<String, dynamic> json) =>
    SessionExport(
      id: json['id'] as String,
      sessionNoteId: json['sessionNoteId'] as String,
      clientId: json['clientId'] as String,
      therapistId: json['therapistId'] as String,
      exportType: json['exportType'] as String,
      exportFormat: json['exportFormat'] as String,
      filePath: json['filePath'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      exportOptions: json['exportOptions'] as Map<String, dynamic>,
      isGenerated: json['isGenerated'] as bool,
      generatedAt: json['generatedAt'] == null
          ? null
          : DateTime.parse(json['generatedAt'] as String),
      generatedBy: json['generatedBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionExportToJson(SessionExport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionNoteId': instance.sessionNoteId,
      'clientId': instance.clientId,
      'therapistId': instance.therapistId,
      'exportType': instance.exportType,
      'exportFormat': instance.exportFormat,
      'filePath': instance.filePath,
      'downloadUrl': instance.downloadUrl,
      'exportOptions': instance.exportOptions,
      'isGenerated': instance.isGenerated,
      'generatedAt': instance.generatedAt?.toIso8601String(),
      'generatedBy': instance.generatedBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

RegionalConfig _$RegionalConfigFromJson(Map<String, dynamic> json) =>
    RegionalConfig(
      region: json['region'] as String,
      diagnosisStandard: $enumDecode(
        _$DiagnosisStandardEnumMap,
        json['diagnosisStandard'],
      ),
      language: json['language'] as String,
      legalCompliance: (json['legalCompliance'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      aiPromptSuffix: json['aiPromptSuffix'] as String,
      hosting: json['hosting'] as String,
      customSettings: json['customSettings'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$RegionalConfigToJson(
  RegionalConfig instance,
) => <String, dynamic>{
  'region': instance.region,
  'diagnosisStandard': _$DiagnosisStandardEnumMap[instance.diagnosisStandard]!,
  'language': instance.language,
  'legalCompliance': instance.legalCompliance,
  'aiPromptSuffix': instance.aiPromptSuffix,
  'hosting': instance.hosting,
  'customSettings': instance.customSettings,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'metadata': instance.metadata,
};
