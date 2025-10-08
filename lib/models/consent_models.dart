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

class ConsentDbRecord {
  final String consentId; // uuid
  final String versionTextId;
  final String clientName;
  final String clientIdentifier; // optional external identifier
  final String therapistName;
  final DateTime signedAt;
  final String signatureData; // base64 png / vector strokes
  final String ipAddress;
  final String userAgent;

  ConsentDbRecord({
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

/*
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
*/
