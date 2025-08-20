// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'us_billing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

USBillingClaim _$USBillingClaimFromJson(Map<String, dynamic> json) =>
    USBillingClaim(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      payerName: json['payerName'] as String,
      serviceLines: (json['serviceLines'] as List<dynamic>)
          .map((e) => ServiceLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      placeOfService: json['placeOfService'] as String,
      modifiers: (json['modifiers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      diagnosisCode: json['diagnosisCode'] as String,
      renderingNPI: json['renderingNPI'] as String,
      billingNPI: json['billingNPI'] as String,
      facilityNPI: json['facilityNPI'] as String,
      totalCharge: (json['totalCharge'] as num).toDouble(),
      allowedAmount: (json['allowedAmount'] as num).toDouble(),
      patientResponsibility: (json['patientResponsibility'] as num).toDouble(),
      status: $enumDecode(_$ClaimStatusEnumMap, json['status']),
      submissionDate: DateTime.parse(json['submissionDate'] as String),
    );

Map<String, dynamic> _$USBillingClaimToJson(USBillingClaim instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'payerName': instance.payerName,
      'serviceLines': instance.serviceLines,
      'placeOfService': instance.placeOfService,
      'modifiers': instance.modifiers,
      'diagnosisCode': instance.diagnosisCode,
      'renderingNPI': instance.renderingNPI,
      'billingNPI': instance.billingNPI,
      'facilityNPI': instance.facilityNPI,
      'totalCharge': instance.totalCharge,
      'allowedAmount': instance.allowedAmount,
      'patientResponsibility': instance.patientResponsibility,
      'status': _$ClaimStatusEnumMap[instance.status]!,
      'submissionDate': instance.submissionDate.toIso8601String(),
    };

const _$ClaimStatusEnumMap = {
  ClaimStatus.draft: 'draft',
  ClaimStatus.submitted: 'submitted',
  ClaimStatus.accepted: 'accepted',
  ClaimStatus.denied: 'denied',
  ClaimStatus.paid: 'paid',
  ClaimStatus.partiallyPaid: 'partiallyPaid',
};

ServiceLine _$ServiceLineFromJson(Map<String, dynamic> json) => ServiceLine(
  id: json['id'] as String,
  cptCode: json['cptCode'] as String,
  hcpcsCode: json['hcpcsCode'] as String,
  units: (json['units'] as num).toInt(),
  chargeAmount: (json['chargeAmount'] as num).toDouble(),
  modifiers: (json['modifiers'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  diagnosisPointer: json['diagnosisPointer'] as String,
  telehealth: $enumDecode(_$TelehealthIndicatorEnumMap, json['telehealth']),
);

Map<String, dynamic> _$ServiceLineToJson(ServiceLine instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cptCode': instance.cptCode,
      'hcpcsCode': instance.hcpcsCode,
      'units': instance.units,
      'chargeAmount': instance.chargeAmount,
      'modifiers': instance.modifiers,
      'diagnosisPointer': instance.diagnosisPointer,
      'telehealth': _$TelehealthIndicatorEnumMap[instance.telehealth]!,
    };

const _$TelehealthIndicatorEnumMap = {
  TelehealthIndicator.none: 'none',
  TelehealthIndicator.audioOnly: 'audioOnly',
  TelehealthIndicator.video: 'video',
};

PriorAuthorization _$PriorAuthorizationFromJson(Map<String, dynamic> json) =>
    PriorAuthorization(
      id: json['id'] as String,
      payerName: json['payerName'] as String,
      cptCode: json['cptCode'] as String,
      authorizationNumber: json['authorizationNumber'] as String,
      validFrom: DateTime.parse(json['validFrom'] as String),
      validTo: DateTime.parse(json['validTo'] as String),
      notes: (json['notes'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecode(_$AuthorizationStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$PriorAuthorizationToJson(PriorAuthorization instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payerName': instance.payerName,
      'cptCode': instance.cptCode,
      'authorizationNumber': instance.authorizationNumber,
      'validFrom': instance.validFrom.toIso8601String(),
      'validTo': instance.validTo.toIso8601String(),
      'notes': instance.notes,
      'status': _$AuthorizationStatusEnumMap[instance.status]!,
    };

const _$AuthorizationStatusEnumMap = {
  AuthorizationStatus.requested: 'requested',
  AuthorizationStatus.approved: 'approved',
  AuthorizationStatus.denied: 'denied',
  AuthorizationStatus.expired: 'expired',
};

RemittanceAdvice _$RemittanceAdviceFromJson(Map<String, dynamic> json) =>
    RemittanceAdvice(
      id: json['id'] as String,
      claimId: json['claimId'] as String,
      receivedDate: DateTime.parse(json['receivedDate'] as String),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      patientResponsibility: (json['patientResponsibility'] as num).toDouble(),
      adjustments: (json['adjustments'] as List<dynamic>)
          .map((e) => Adjustment.fromJson(e as Map<String, dynamic>))
          .toList(),
      remarkCode: json['remarkCode'] as String,
    );

Map<String, dynamic> _$RemittanceAdviceToJson(RemittanceAdvice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'claimId': instance.claimId,
      'receivedDate': instance.receivedDate.toIso8601String(),
      'paidAmount': instance.paidAmount,
      'patientResponsibility': instance.patientResponsibility,
      'adjustments': instance.adjustments,
      'remarkCode': instance.remarkCode,
    };

Adjustment _$AdjustmentFromJson(Map<String, dynamic> json) => Adjustment(
  id: json['id'] as String,
  groupCode: json['groupCode'] as String,
  reasonCode: json['reasonCode'] as String,
  amount: (json['amount'] as num).toDouble(),
);

Map<String, dynamic> _$AdjustmentToJson(Adjustment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupCode': instance.groupCode,
      'reasonCode': instance.reasonCode,
      'amount': instance.amount,
    };
