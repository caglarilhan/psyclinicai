import 'package:json_annotation/json_annotation.dart';

part 'eu_health_system_models.g.dart';

@JsonSerializable()
class EUHealthSystemIntegration {
  final String id;
  final String organizationId;
  final List<EUPrescriptionIntegration> ePrescription; // ePrescription/eDispensation
  final List<SNOMEDMapping> snomedMappings; // SNOMED CT
  final List<EUComplianceRequirement> complianceRequirements; // GDPR, eIDAS
  final List<EUReportingRequirement> reportingRequirements; // National Health Services
  final Map<String, dynamic> configuration;

  const EUHealthSystemIntegration({
    required this.id,
    required this.organizationId,
    required this.ePrescription,
    required this.snomedMappings,
    required this.complianceRequirements,
    required this.reportingRequirements,
    required this.configuration,
  });

  factory EUHealthSystemIntegration.fromJson(Map<String, dynamic> json) => _$EUHealthSystemIntegrationFromJson(json);
  Map<String, dynamic> toJson() => _$EUHealthSystemIntegrationToJson(this);
}

@JsonSerializable()
class EUPrescriptionIntegration {
  final String id;
  final String country; // DE, FR, ES, IT, NL, SE, etc.
  final bool isActive;
  final DateTime lastSync;
  final String standard; // EPS (UK), GEMATIK (DE), DMP (FR)
  final Map<String, dynamic> metadata;

  const EUPrescriptionIntegration({
    required this.id,
    required this.country,
    required this.isActive,
    required this.lastSync,
    required this.standard,
    required this.metadata,
  });

  factory EUPrescriptionIntegration.fromJson(Map<String, dynamic> json) => _$EUPrescriptionIntegrationFromJson(json);
  Map<String, dynamic> toJson() => _$EUPrescriptionIntegrationToJson(this);
}

@JsonSerializable()
class SNOMEDMapping {
  final String id;
  final String snomedCode;
  final String icd10Code;
  final String display;
  final String locale;

  const SNOMEDMapping({
    required this.id,
    required this.snomedCode,
    required this.icd10Code,
    required this.display,
    required this.locale,
  });

  factory SNOMEDMapping.fromJson(Map<String, dynamic> json) => _$SNOMEDMappingFromJson(json);
  Map<String, dynamic> toJson() => _$SNOMEDMappingToJson(this);
}

@JsonSerializable()
class EUComplianceRequirement {
  final String id;
  final String title; // GDPR Art. 9 health data, eIDAS signatures
  final String description;
  final String regulation;
  final DateTime effectiveDate;
  final String status; // compliant, pending, non-compliant
  final List<String> controls; // DPIA, DPO, consent management

  const EUComplianceRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.regulation,
    required this.effectiveDate,
    required this.status,
    required this.controls,
  });

  factory EUComplianceRequirement.fromJson(Map<String, dynamic> json) => _$EUComplianceRequirementFromJson(json);
  Map<String, dynamic> toJson() => _$EUComplianceRequirementToJson(this);
}

@JsonSerializable()
class EUReportingRequirement {
  final String id;
  final String title; // NHS/Regional
  final String description;
  final String authority; // NHS England, Gematik, CNAM, etc.
  final String frequency; // monthly, quarterly, annually
  final DateTime nextDueDate;

  const EUReportingRequirement({
    required this.id,
    required this.title,
    required this.description,
    required this.authority,
    required this.frequency,
    required this.nextDueDate,
  });

  factory EUReportingRequirement.fromJson(Map<String, dynamic> json) => _$EUReportingRequirementFromJson(json);
  Map<String, dynamic> toJson() => _$EUReportingRequirementToJson(this);
}
