import 'package:json_annotation/json_annotation.dart';

part 'us_billing_models.g.dart';

@JsonSerializable()
class USBillingClaim {
  final String id;
  final String patientId;
  final String payerName;
  final List<ServiceLine> serviceLines;
  final String placeOfService; // 02, 10, 11
  final List<String> modifiers; // -95, -GT
  final String diagnosisCode; // ICD-10-CM
  final String renderingNPI;
  final String billingNPI;
  final String facilityNPI;
  final double totalCharge;
  final double allowedAmount;
  final double patientResponsibility;
  final ClaimStatus status;
  final DateTime submissionDate;

  const USBillingClaim({
    required this.id,
    required this.patientId,
    required this.payerName,
    required this.serviceLines,
    required this.placeOfService,
    required this.modifiers,
    required this.diagnosisCode,
    required this.renderingNPI,
    required this.billingNPI,
    required this.facilityNPI,
    required this.totalCharge,
    required this.allowedAmount,
    required this.patientResponsibility,
    required this.status,
    required this.submissionDate,
  });

  factory USBillingClaim.fromJson(Map<String, dynamic> json) => _$USBillingClaimFromJson(json);
  Map<String, dynamic> toJson() => _$USBillingClaimToJson(this);
}

@JsonSerializable()
class ServiceLine {
  final String id;
  final String cptCode; // 90834, 90837, 99214
  final String hcpcsCode; // optional
  final int units;
  final double chargeAmount;
  final List<String> modifiers; // -95, -GT
  final String diagnosisPointer; // A, B, C, D
  final TelehealthIndicator telehealth;

  const ServiceLine({
    required this.id,
    required this.cptCode,
    required this.hcpcsCode,
    required this.units,
    required this.chargeAmount,
    required this.modifiers,
    required this.diagnosisPointer,
    required this.telehealth,
  });

  factory ServiceLine.fromJson(Map<String, dynamic> json) => _$ServiceLineFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceLineToJson(this);
}

@JsonSerializable()
class PriorAuthorization {
  final String id;
  final String payerName;
  final String cptCode;
  final String authorizationNumber;
  final DateTime validFrom;
  final DateTime validTo;
  final List<String> notes;
  final AuthorizationStatus status;

  const PriorAuthorization({
    required this.id,
    required this.payerName,
    required this.cptCode,
    required this.authorizationNumber,
    required this.validFrom,
    required this.validTo,
    required this.notes,
    required this.status,
  });

  factory PriorAuthorization.fromJson(Map<String, dynamic> json) => _$PriorAuthorizationFromJson(json);
  Map<String, dynamic> toJson() => _$PriorAuthorizationToJson(this);
}

@JsonSerializable()
class RemittanceAdvice {
  final String id;
  final String claimId;
  final DateTime receivedDate;
  final double paidAmount;
  final double patientResponsibility;
  final List<Adjustment> adjustments;
  final String remarkCode;

  const RemittanceAdvice({
    required this.id,
    required this.claimId,
    required this.receivedDate,
    required this.paidAmount,
    required this.patientResponsibility,
    required this.adjustments,
    required this.remarkCode,
  });

  factory RemittanceAdvice.fromJson(Map<String, dynamic> json) => _$RemittanceAdviceFromJson(json);
  Map<String, dynamic> toJson() => _$RemittanceAdviceToJson(this);
}

@JsonSerializable()
class Adjustment {
  final String id;
  final String groupCode; // PR, CO, OA, PI
  final String reasonCode; // CARC
  final double amount;

  const Adjustment({
    required this.id,
    required this.groupCode,
    required this.reasonCode,
    required this.amount,
  });

  factory Adjustment.fromJson(Map<String, dynamic> json) => _$AdjustmentFromJson(json);
  Map<String, dynamic> toJson() => _$AdjustmentToJson(this);
}

enum ClaimStatus { draft, submitted, accepted, denied, paid, partiallyPaid }

enum AuthorizationStatus { requested, approved, denied, expired }

enum TelehealthIndicator { none, audioOnly, video }
