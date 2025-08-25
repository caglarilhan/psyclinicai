import 'package:json_annotation/json_annotation.dart';

part 'us_state_law_models.g.dart';

/// US State enumeration with legal compliance requirements
enum USState {
  @JsonValue('AL') alabama,
  @JsonValue('AK') alaska,
  @JsonValue('AZ') arizona,
  @JsonValue('AR') arkansas,
  @JsonValue('CA') california,
  @JsonValue('CO') colorado,
  @JsonValue('CT') connecticut,
  @JsonValue('DE') delaware,
  @JsonValue('FL') florida,
  @JsonValue('GA') georgia,
  @JsonValue('HI') hawaii,
  @JsonValue('ID') idaho,
  @JsonValue('IL') illinois,
  @JsonValue('IN') indiana,
  @JsonValue('IA') iowa,
  @JsonValue('KS') kansas,
  @JsonValue('KY') kentucky,
  @JsonValue('LA') louisiana,
  @JsonValue('ME') maine,
  @JsonValue('MD') maryland,
  @JsonValue('MA') massachusetts,
  @JsonValue('MI') michigan,
  @JsonValue('MN') minnesota,
  @JsonValue('MS') mississippi,
  @JsonValue('MO') missouri,
  @JsonValue('MT') montana,
  @JsonValue('NE') nebraska,
  @JsonValue('NV') nevada,
  @JsonValue('NH') newHampshire,
  @JsonValue('NJ') newJersey,
  @JsonValue('NM') newMexico,
  @JsonValue('NY') newYork,
  @JsonValue('NC') northCarolina,
  @JsonValue('ND') northDakota,
  @JsonValue('OH') ohio,
  @JsonValue('OK') oklahoma,
  @JsonValue('OR') oregon,
  @JsonValue('PA') pennsylvania,
  @JsonValue('RI') rhodeIsland,
  @JsonValue('SC') southCarolina,
  @JsonValue('SD') southDakota,
  @JsonValue('TN') tennessee,
  @JsonValue('TX') texas,
  @JsonValue('UT') utah,
  @JsonValue('VT') vermont,
  @JsonValue('VA') virginia,
  @JsonValue('WA') washington,
  @JsonValue('WV') westVirginia,
  @JsonValue('WI') wisconsin,
  @JsonValue('WY') wyoming,
  @JsonValue('DC') districtOfColumbia,
  @JsonValue('AS') americanSamoa,
  @JsonValue('GU') guam,
  @JsonValue('MP') northernMarianaIslands,
  @JsonValue('PR') puertoRico,
  @JsonValue('VI') usVirginIslands,
}

/// Legal requirement categories
enum LegalRequirementType {
  @JsonValue('hipaa') hipaa,
  @JsonValue('state_privacy') statePrivacy,
  @JsonValue('mental_health') mentalHealth,
  @JsonValue('minors') minors,
  @JsonValue('telehealth') telehealth,
  @JsonValue('prescription') prescription,
  @JsonValue('billing') billing,
  @JsonValue('licensing') licensing,
  @JsonValue('reporting') reporting,
  @JsonValue('consent') consent,
}

/// Severity levels for legal requirements
enum LegalSeverity {
  @JsonValue('critical') critical,
  @JsonValue('high') high,
  @JsonValue('medium') medium,
  @JsonValue('low') low,
  @JsonValue('informational') informational,
}

/// State-specific legal requirement
@JsonSerializable()
class StateLegalRequirement {
  final String id;
  final USState state;
  final LegalRequirementType type;
  final LegalSeverity severity;
  final String title;
  final String description;
  final String legalReference;
  final List<String> requirements;
  final List<String> exceptions;
  final List<String> penalties;
  final DateTime effectiveDate;
  final DateTime? expirationDate;
  final bool isActive;
  final List<String> tags;

  const StateLegalRequirement({
    required this.id,
    required this.state,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.legalReference,
    required this.requirements,
    required this.exceptions,
    required this.penalties,
    required this.effectiveDate,
    this.expirationDate,
    required this.isActive,
    required this.tags,
  });

  factory StateLegalRequirement.fromJson(Map<String, dynamic> json) =>
      _$StateLegalRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$StateLegalRequirementToJson(this);
}

/// HIPAA compliance requirements
@JsonSerializable()
class HIPAARequirement {
  final String id;
  final String title;
  final String description;
  final LegalSeverity severity;
  final List<String> requirements;
  final List<String> safeguards;
  final List<String> violations;
  final List<String> penalties;
  final DateTime effectiveDate;
  final bool isActive;

  const HIPAARequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.requirements,
    required this.safeguards,
    required this.violations,
    required this.penalties,
    required this.effectiveDate,
    required this.isActive,
  });

  factory HIPAARequirement.fromJson(Map<String, dynamic> json) =>
      _$HIPAARequirementFromJson(json);

  Map<String, dynamic> toJson() => _$HIPAARequirementToJson(this);
}

/// Telehealth legal requirements by state
@JsonSerializable()
class TelehealthLegalRequirement {
  final String id;
  final USState state;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> restrictions;
  final List<String> allowedPractitioners;
  final List<String> allowedServices;
  final List<String> documentation;
  final List<String> consent;
  final List<String> billing;
  final DateTime effectiveDate;
  final bool isActive;

  const TelehealthLegalRequirement({
    required this.id,
    required this.state,
    required this.title,
    required this.description,
    required this.requirements,
    required this.restrictions,
    required this.allowedPractitioners,
    required this.allowedServices,
    required this.documentation,
    required this.consent,
    required this.billing,
    required this.effectiveDate,
    required this.isActive,
  });

  factory TelehealthLegalRequirement.fromJson(Map<String, dynamic> json) =>
      _$TelehealthLegalRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$TelehealthLegalRequirementToJson(this);
}

/// Mental health specific legal requirements
@JsonSerializable()
class MentalHealthLegalRequirement {
  final String id;
  final USState state;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> patientRights;
  final List<String> providerObligations;
  final List<String> emergencyProcedures;
  final List<String> reportingObligations;
  final List<String> confidentiality;
  final DateTime effectiveDate;
  final bool isActive;

  const MentalHealthLegalRequirement({
    required this.id,
    required this.state,
    required this.title,
    required this.description,
    required this.requirements,
    required this.patientRights,
    required this.providerObligations,
    required this.emergencyProcedures,
    required this.reportingObligations,
    required this.confidentiality,
    required this.effectiveDate,
    required this.isActive,
  });

  factory MentalHealthLegalRequirement.fromJson(Map<String, dynamic> json) =>
      _$MentalHealthLegalRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$MentalHealthLegalRequirementToJson(this);
}

/// Minor consent requirements by state
@JsonSerializable()
class MinorConsentRequirement {
  final String id;
  final USState state;
  final String title;
  final String description;
  final int ageOfMajority;
  final List<String> emancipatedMinors;
  final List<String> matureMinors;
  final List<String> parentalConsent;
  final List<String> exceptions;
  final List<String> documentation;
  final DateTime effectiveDate;
  final bool isActive;

  const MinorConsentRequirement({
    required this.id,
    required this.state,
    required this.title,
    required this.description,
    required this.ageOfMajority,
    required this.emancipatedMinors,
    required this.matureMinors,
    required this.parentalConsent,
    required this.exceptions,
    required this.documentation,
    required this.effectiveDate,
    required this.isActive,
  });

  factory MinorConsentRequirement.fromJson(Map<String, dynamic> json) =>
      _$MinorConsentRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$MinorConsentRequirementToJson(this);
}

/// Prescription drug legal requirements
@JsonSerializable()
class PrescriptionLegalRequirement {
  final String id;
  final USState state;
  final String title;
  final String description;
  final List<String> requirements;
  final List<String> controlledSubstances;
  final List<String> prescribingLimits;
  final List<String> documentation;
  final List<String> monitoring;
  final List<String> penalties;
  final DateTime effectiveDate;
  final bool isActive;

  const PrescriptionLegalRequirement({
    required this.id,
    required this.state,
    required this.title,
    required this.description,
    required this.requirements,
    required this.controlledSubstances,
    required this.prescribingLimits,
    required this.documentation,
    required this.monitoring,
    required this.penalties,
    required this.effectiveDate,
    required this.isActive,
  });

  factory PrescriptionLegalRequirement.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionLegalRequirementFromJson(json);

  Map<String, dynamic> toJson() => _$PrescriptionLegalRequirementToJson(this);
}

/// Legal compliance checklist item
@JsonSerializable()
class LegalComplianceChecklistItem {
  final String id;
  final String title;
  final String description;
  final LegalRequirementType type;
  final LegalSeverity severity;
  final USState? state;
  final List<String> requirements;
  final bool isRequired;
  final bool isCompleted;
  final DateTime? completedDate;
  final String? completedBy;
  final String? notes;
  final List<String> evidence;
  final DateTime dueDate;
  final bool isOverdue;

  const LegalComplianceChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    this.state,
    required this.requirements,
    required this.isRequired,
    required this.isCompleted,
    this.completedDate,
    this.completedBy,
    this.notes,
    required this.evidence,
    required this.dueDate,
    required this.isOverdue,
  });

  factory LegalComplianceChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$LegalComplianceChecklistItemFromJson(json);

  Map<String, dynamic> toJson() => _$LegalComplianceChecklistItemToJson(this);
}

/// Legal compliance audit result
@JsonSerializable()
class LegalComplianceAuditResult {
  final String id;
  final String auditId;
  final USState state;
  final DateTime auditDate;
  final String auditor;
  final List<LegalComplianceChecklistItem> checklistItems;
  final int totalItems;
  final int completedItems;
  final int overdueItems;
  final double compliancePercentage;
  final List<String> criticalIssues;
  final List<String> recommendations;
  final LegalSeverity overallRisk;
  final DateTime nextAuditDate;

  const LegalComplianceAuditResult({
    required this.id,
    required this.auditId,
    required this.state,
    required this.auditDate,
    required this.auditor,
    required this.checklistItems,
    required this.totalItems,
    required this.completedItems,
    required this.overdueItems,
    required this.compliancePercentage,
    required this.criticalIssues,
    required this.recommendations,
    required this.overallRisk,
    required this.nextAuditDate,
  });

  factory LegalComplianceAuditResult.fromJson(Map<String, dynamic> json) =>
      _$LegalComplianceAuditResultFromJson(json);

  Map<String, dynamic> toJson() => _$LegalComplianceAuditResultToJson(this);
}

/// Legal requirement update notification
@JsonSerializable()
class LegalRequirementUpdate {
  final String id;
  final String title;
  final String description;
  final LegalRequirementType type;
  final USState? state;
  final LegalSeverity severity;
  final DateTime effectiveDate;
  final List<String> changes;
  final List<String> impact;
  final List<String> actions;
  final DateTime notificationDate;
  final bool isRead;
  final bool requiresAction;

  const LegalRequirementUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.state,
    required this.severity,
    required this.effectiveDate,
    required this.changes,
    required this.impact,
    required this.actions,
    required this.notificationDate,
    required this.isRead,
    required this.requiresAction,
  });

  factory LegalRequirementUpdate.fromJson(Map<String, dynamic> json) =>
      _$LegalRequirementUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$LegalRequirementUpdateToJson(this);
}
