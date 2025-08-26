import 'package:json_annotation/json_annotation.dart';

part 'session_note_models.g.dart';

/// Session Note Type - Seans notu türleri
enum SessionNoteType {
  @JsonValue('initial') initial,           // İlk seans
  @JsonValue('follow_up') follow_up,       // Takip seansı
  @JsonValue('crisis') crisis,             // Kriz seansı
  @JsonValue('termination') termination,   // Sonlandırma seansı
  @JsonValue('supervision') supervision,   // Süpervizyon seansı
  @JsonValue('group') group,               // Grup seansı
  @JsonValue('family') family,             // Aile seansı
  @JsonValue('assessment') assessment,     // Değerlendirme seansı
}

/// Session Status - Seans durumu
enum SessionStatus {
  @JsonValue('scheduled') scheduled,       // Planlanmış
  @JsonValue('in_progress') in_progress,   // Devam ediyor
  @JsonValue('completed') completed,       // Tamamlandı
  @JsonValue('cancelled') cancelled,       // İptal edildi
  @JsonValue('no_show') no_show,          // Gelmedi
  @JsonValue('rescheduled') rescheduled,   // Ertelendi
}

/// AI Analysis Status - AI analiz durumu
enum AIAnalysisStatus {
  @JsonValue('pending') pending,           // Bekliyor
  @JsonValue('processing') processing,     // İşleniyor
  @JsonValue('completed') completed,       // Tamamlandı
  @JsonValue('failed') failed,             // Başarısız
  @JsonValue('reviewed') reviewed,         // İncelendi
}

/// Diagnosis Standard - Tanı standardı
enum DiagnosisStandard {
  @JsonValue('dsm_5_tr') dsm_5_tr,         // DSM-5-TR
  @JsonValue('icd_11') icd_11,             // ICD-11
  @JsonValue('icd_10') icd_10,             // ICD-10
  @JsonValue('mixed') mixed,               // Karışık
}

/// Session Note - Seans notu
@JsonSerializable()
class SessionNote {
  final String id;
  final String clientId;
  final String therapistId;
  final String sessionId;
  final SessionNoteType type;
  final SessionStatus status;
  final String notes;
  final String? aiSummary;
  final AIAnalysisStatus aiStatus;
  final DateTime sessionDate;
  final int duration; // minutes
  final String? location;
  final String? modality; // in-person, video, phone
  final Map<String, dynamic>? additionalData;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionNote({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.sessionId,
    required this.type,
    required this.status,
    required this.notes,
    this.aiSummary,
    required this.aiStatus,
    required this.sessionDate,
    required this.duration,
    this.location,
    this.modality,
    this.additionalData,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory SessionNote.fromJson(Map<String, dynamic> json) =>
      _$SessionNoteFromJson(json);

  Map<String, dynamic> toJson() => _$SessionNoteToJson(this);
}

/// AI Session Analysis - AI seans analizi
@JsonSerializable()
class AISessionAnalysis {
  final String id;
  final String sessionNoteId;
  final String clientId;
  final String therapistId;
  final AIAnalysisStatus status;
  final String? affect; // Duygu durumu
  final String? theme; // Ana tema
  final String? diagnosisSuggestion;
  final DiagnosisStandard diagnosisStandard;
  final double confidenceScore;
  final List<String> keyTopics;
  final List<String> riskFactors;
  final List<String> strengths;
  final List<String> recommendations;
  final Map<String, dynamic> emotionalAnalysis;
  final Map<String, dynamic> behavioralPatterns;
  final Map<String, dynamic> therapeuticProgress;
  final String? rawAnalysis;
  final DateTime analyzedAt;
  final String analyzedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const AISessionAnalysis({
    required this.id,
    required this.sessionNoteId,
    required this.clientId,
    required this.therapistId,
    required this.status,
    this.affect,
    this.theme,
    this.diagnosisSuggestion,
    required this.diagnosisStandard,
    required this.confidenceScore,
    required this.keyTopics,
    required this.riskFactors,
    required this.strengths,
    required this.recommendations,
    required this.emotionalAnalysis,
    required this.behavioralPatterns,
    required this.therapeuticProgress,
    this.rawAnalysis,
    required this.analyzedAt,
    required this.analyzedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory AISessionAnalysis.fromJson(Map<String, dynamic> json) =>
      _$AISessionAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$AISessionAnalysisToJson(this);
}

/// Session Template - Seans şablonu
@JsonSerializable()
class SessionTemplate {
  final String id;
  final String name;
  final String description;
  final SessionNoteType type;
  final String templateContent;
  final List<String> requiredFields;
  final List<String> optionalFields;
  final Map<String, dynamic> defaultValues;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.templateContent,
    required this.requiredFields,
    required this.optionalFields,
    required this.defaultValues,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory SessionTemplate.fromJson(Map<String, dynamic> json) =>
      _$SessionTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$SessionTemplateToJson(this);
}

/// Session Summary - Seans özeti
@JsonSerializable()
class SessionSummary {
  final String id;
  final String sessionNoteId;
  final String clientId;
  final String therapistId;
  final String summaryText;
  final String? affect;
  final String? theme;
  final String? diagnosisSuggestion;
  final List<String> keyPoints;
  final List<String> actionItems;
  final List<String> followUpTasks;
  final Map<String, dynamic> progressNotes;
  final bool isReviewed;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionSummary({
    required this.id,
    required this.sessionNoteId,
    required this.clientId,
    required this.therapistId,
    required this.summaryText,
    this.affect,
    this.theme,
    this.diagnosisSuggestion,
    required this.keyPoints,
    required this.actionItems,
    required this.followUpTasks,
    required this.progressNotes,
    required this.isReviewed,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SessionSummaryToJson(this);
}

/// Session Flag - Seans bayrağı (risk işaretleri)
@JsonSerializable()
class SessionFlag {
  final String id;
  final String sessionNoteId;
  final String clientId;
  final String therapistId;
  final String flagType;
  final String severity; // low, medium, high, critical
  final String description;
  final String? recommendation;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;
  final bool requiresFollowUp;
  final DateTime? followUpDate;
  final String? followUpNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionFlag({
    required this.id,
    required this.sessionNoteId,
    required this.clientId,
    required this.therapistId,
    required this.flagType,
    required this.severity,
    required this.description,
    this.recommendation,
    required this.isAcknowledged,
    this.acknowledgedBy,
    this.acknowledgedAt,
    required this.requiresFollowUp,
    this.followUpDate,
    this.followUpNotes,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory SessionFlag.fromJson(Map<String, dynamic> json) =>
      _$SessionFlagFromJson(json);

  Map<String, dynamic> toJson() => _$SessionFlagToJson(this);
}

/// Session Progress - Seans ilerlemesi
@JsonSerializable()
class SessionProgress {
  final String id;
  final String clientId;
  final String therapistId;
  final String sessionNoteId;
  final int sessionNumber;
  final String progressType; // improvement, stable, decline
  final String progressDescription;
  final Map<String, dynamic> metrics;
  final List<String> goals;
  final List<String> achievedGoals;
  final List<String> nextGoals;
  final String? therapistNotes;
  final DateTime sessionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionProgress({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.sessionNoteId,
    required this.sessionNumber,
    required this.progressType,
    required this.progressDescription,
    required this.metrics,
    required this.goals,
    required this.achievedGoals,
    required this.nextGoals,
    this.therapistNotes,
    required this.sessionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory SessionProgress.fromJson(Map<String, dynamic> json) =>
      _$SessionProgressFromJson(json);

  Map<String, dynamic> toJson() => _$SessionProgressToJson(this);
}

/// Session Export - Seans dışa aktarım
@JsonSerializable()
class SessionExport {
  final String id;
  final String sessionNoteId;
  final String clientId;
  final String therapistId;
  final String exportType; // pdf, docx, json
  final String exportFormat;
  final String? filePath;
  final String? downloadUrl;
  final Map<String, dynamic> exportOptions;
  final bool isGenerated;
  final DateTime? generatedAt;
  final String? generatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const SessionExport({
    required this.id,
    required this.sessionNoteId,
    required this.clientId,
    required this.therapistId,
    required this.exportType,
    required this.exportFormat,
    this.filePath,
    this.downloadUrl,
    required this.exportOptions,
    required this.isGenerated,
    this.generatedAt,
    this.generatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory SessionExport.fromJson(Map<String, dynamic> json) =>
      _$SessionExportFromJson(json);

  Map<String, dynamic> toJson() => _$SessionExportToJson(this);
}

/// Regional Configuration - Bölgesel konfigürasyon
@JsonSerializable()
class RegionalConfig {
  final String region;
  final DiagnosisStandard diagnosisStandard;
  final String language;
  final List<String> legalCompliance;
  final String aiPromptSuffix;
  final String hosting;
  final Map<String, dynamic> customSettings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const RegionalConfig({
    required this.region,
    required this.diagnosisStandard,
    required this.language,
    required this.legalCompliance,
    required this.aiPromptSuffix,
    required this.hosting,
    required this.customSettings,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  factory RegionalConfig.fromJson(Map<String, dynamic> json) =>
      _$RegionalConfigFromJson(json);

  Map<String, dynamic> toJson() => _$RegionalConfigToJson(this);
}
