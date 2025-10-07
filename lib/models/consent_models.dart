class ConsentVersionedText {
  final String id; // e.g. CONSENT_V1_EN
  final String locale; // en_US, tr_TR, de_DE
  final String title;
  final String body; // full consent text
  final DateTime effectiveAt;

  ConsentVersionedText({
    required this.id,
    required this.locale,
    required this.title,
    required this.body,
    required this.effectiveAt,
  });
}

class ConsentRecord {
  final String consentId; // uuid
  final String versionTextId;
  final String clientName;
  final String clientIdentifier; // optional external identifier
  final String therapistName;
  final DateTime signedAt;
  final String signatureData; // base64 png / vector strokes
  final String ipAddress;
  final String userAgent;

  ConsentRecord({
    required this.consentId,
    required this.versionTextId,
    required this.clientName,
    required this.clientIdentifier,
    required this.therapistName,
    required this.signedAt,
    required this.signatureData,
    required this.ipAddress,
    required this.userAgent,
  });
}

import 'package:json_annotation/json_annotation.dart';

part 'consent_models.g.dart';

@JsonSerializable()
class ConsentRecord {
  final String id;
  final String patientId;
  final String consentType;
  final String region;
  final String versionId;
  final DateTime consentDate;
  final DateTime? expiryDate;
  final bool isActive;
  final String consentText;
  final Map<String, dynamic> consentData;
  final List<String> purposes;
  final ConsentMethod method;
  final String recordedBy;
  final DateTime? revokedAt;
  final String? revokedBy;
  final String? revocationReason;
  final DateTime? lastModified;
  final String? lastModifiedBy;
  final List<ConsentModification> modificationHistory;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ConsentRecord({
    required this.id,
    required this.patientId,
    required this.consentType,
    required this.region,
    required this.versionId,
    required this.consentDate,
    this.expiryDate,
    required this.isActive,
    required this.consentText,
    required this.consentData,
    required this.purposes,
    required this.method,
    required this.recordedBy,
    this.revokedAt,
    this.revokedBy,
    this.revocationReason,
    this.lastModified,
    this.lastModifiedBy,
    this.modificationHistory = const [],
    this.notes,
    this.metadata = const {},
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) =>
      _$ConsentRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentRecordToJson(this);

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isRevoked => revokedAt != null;
  bool get isValid => isActive && !isExpired && !isRevoked;

  ConsentRecord copyWith({
    String? id,
    String? patientId,
    String? consentType,
    String? region,
    String? versionId,
    DateTime? consentDate,
    DateTime? expiryDate,
    bool? isActive,
    String? consentText,
    Map<String, dynamic>? consentData,
    List<String>? purposes,
    ConsentMethod? method,
    String? recordedBy,
    DateTime? revokedAt,
    String? revokedBy,
    String? revocationReason,
    DateTime? lastModified,
    String? lastModifiedBy,
    List<ConsentModification>? modificationHistory,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return ConsentRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      consentType: consentType ?? this.consentType,
      region: region ?? this.region,
      versionId: versionId ?? this.versionId,
      consentDate: consentDate ?? this.consentDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      consentText: consentText ?? this.consentText,
      consentData: consentData ?? this.consentData,
      purposes: purposes ?? this.purposes,
      method: method ?? this.method,
      recordedBy: recordedBy ?? this.recordedBy,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedBy: revokedBy ?? this.revokedBy,
      revocationReason: revocationReason ?? this.revocationReason,
      lastModified: lastModified ?? this.lastModified,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      modificationHistory: modificationHistory ?? this.modificationHistory,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
}

@JsonSerializable()
class ConsentVersion {
  final String id;
  final String templateId;
  final String versionNumber;
  final String content;
  final DateTime effectiveDate;
  final bool isActive;
  final DateTime? deprecatedDate;
  final String? deprecatedReason;
  final Map<String, dynamic> metadata;

  const ConsentVersion({
    required this.id,
    required this.templateId,
    required this.versionNumber,
    required this.content,
    required this.effectiveDate,
    required this.isActive,
    this.deprecatedDate,
    this.deprecatedReason,
    this.metadata = const {},
  });

  factory ConsentVersion.fromJson(Map<String, dynamic> json) =>
      _$ConsentVersionFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentVersionToJson(this);

  bool get isDeprecated => deprecatedDate != null;
}

@JsonSerializable()
class ConsentTemplate {
  final String id;
  final String name;
  final String region;
  final String version;
  final String content;
  final List<String> requiredFields;
  final String legalBasis;
  final String retentionPeriod;
  final bool isActive;
  final DateTime? effectiveDate;
  final DateTime? expiryDate;
  final Map<String, dynamic> metadata;

  const ConsentTemplate({
    required this.id,
    required this.name,
    required this.region,
    required this.version,
    required this.content,
    required this.requiredFields,
    required this.legalBasis,
    required this.retentionPeriod,
    required this.isActive,
    this.effectiveDate,
    this.expiryDate,
    this.metadata = const {},
  });

  factory ConsentTemplate.fromJson(Map<String, dynamic> json) =>
      _$ConsentTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentTemplateToJson(this);

  bool get isEffective => effectiveDate == null || effectiveDate!.isBefore(DateTime.now());
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isValid => isActive && isEffective && !isExpired;
}

@JsonSerializable()
class ConsentModification {
  final String id;
  final DateTime modifiedAt;
  final String modifiedBy;
  final String reason;
  final Map<String, dynamic> changes;
  final String? notes;
  final Map<String, dynamic> metadata;

  const ConsentModification({
    required this.id,
    required this.modifiedAt,
    required this.modifiedBy,
    required this.reason,
    required this.changes,
    this.notes,
    this.metadata = const {},
  });

  factory ConsentModification.fromJson(Map<String, dynamic> json) =>
      _$ConsentModificationFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentModificationToJson(this);
}

@JsonSerializable()
class ConsentComplianceReport {
  final String id;
  final DateTime generatedAt;
  final String? region;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalConsents;
  final int activeConsents;
  final int expiredConsents;
  final int revokedConsents;
  final double complianceRate;
  final List<String> recommendations;
  final Map<String, dynamic> metadata;

  const ConsentComplianceReport({
    required this.id,
    required this.generatedAt,
    this.region,
    this.startDate,
    this.endDate,
    required this.totalConsents,
    required this.activeConsents,
    required this.expiredConsents,
    required this.revokedConsents,
    required this.complianceRate,
    required this.recommendations,
    this.metadata = const {},
  });

  factory ConsentComplianceReport.fromJson(Map<String, dynamic> json) =>
      _$ConsentComplianceReportFromJson(json);

  Map<String, dynamic> toJson() => _$ConsentComplianceReportToJson(this);

  bool get isCompliant => complianceRate >= 0.8;
  String get complianceStatus {
    if (complianceRate >= 0.9) return 'Excellent';
    if (complianceRate >= 0.8) return 'Good';
    if (complianceRate >= 0.6) return 'Fair';
    return 'Poor';
  }
}

enum ConsentMethod {
  written,
  electronic,
  verbal,
  implied,
  optOut,
  digitalSignature,
  biometric,
  twoFactor,
}

enum ConsentStatus {
  active,
  expired,
  revoked,
  pending,
  underReview,
  suspended,
}

enum LegalBasis {
  explicitConsent,
  implicitConsent,
  contract,
  legitimateInterest,
  legalObligation,
  vitalInterest,
  publicInterest,
  acknowledgment,
}

enum RetentionPeriod {
  sixYears,
  tenYears,
  treatmentDurationPlusTenYears,
  treatmentDurationPlusLegalRequirements,
  indefinite,
  custom,
}
