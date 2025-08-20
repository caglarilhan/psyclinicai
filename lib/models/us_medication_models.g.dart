// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'us_medication_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

USMedicationRecord _$USMedicationRecordFromJson(Map<String, dynamic> json) =>
    USMedicationRecord(
      id: json['id'] as String,
      medicationName: json['medicationName'] as String,
      rxNormCode: json['rxNormCode'] as String,
      ndcCode: json['ndcCode'] as String,
      genericName: json['genericName'] as String,
      brandName: json['brandName'] as String,
      indications: (json['indications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      contraindications: (json['contraindications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      sideEffects: (json['sideEffects'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      interactions: (json['interactions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deaSchedule: $enumDecode(_$DEAScheduleEnumMap, json['deaSchedule']),
      formulary: (json['formulary'] as List<dynamic>)
          .map((e) => FormularyEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$USMedicationRecordToJson(USMedicationRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationName': instance.medicationName,
      'rxNormCode': instance.rxNormCode,
      'ndcCode': instance.ndcCode,
      'genericName': instance.genericName,
      'brandName': instance.brandName,
      'indications': instance.indications,
      'contraindications': instance.contraindications,
      'sideEffects': instance.sideEffects,
      'interactions': instance.interactions,
      'deaSchedule': _$DEAScheduleEnumMap[instance.deaSchedule]!,
      'formulary': instance.formulary,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

const _$DEAScheduleEnumMap = {
  DEASchedule.none: 'none',
  DEASchedule.scheduleI: 'scheduleI',
  DEASchedule.scheduleII: 'scheduleII',
  DEASchedule.scheduleIII: 'scheduleIII',
  DEASchedule.scheduleIV: 'scheduleIV',
  DEASchedule.scheduleV: 'scheduleV',
};

FormularyEntry _$FormularyEntryFromJson(Map<String, dynamic> json) =>
    FormularyEntry(
      id: json['id'] as String,
      payerName: json['payerName'] as String,
      tier: json['tier'] as String,
      priorAuthRequired: json['priorAuthRequired'] as bool,
      stepTherapyRequired: json['stepTherapyRequired'] as bool,
      quantityLimit: json['quantityLimit'] as bool,
      notes: json['notes'] as String,
    );

Map<String, dynamic> _$FormularyEntryToJson(FormularyEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payerName': instance.payerName,
      'tier': instance.tier,
      'priorAuthRequired': instance.priorAuthRequired,
      'stepTherapyRequired': instance.stepTherapyRequired,
      'quantityLimit': instance.quantityLimit,
      'notes': instance.notes,
    };

USPrescription _$USPrescriptionFromJson(Map<String, dynamic> json) =>
    USPrescription(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      prescriberNPI: json['prescriberNPI'] as String,
      prescriberDEA: json['prescriberDEA'] as String,
      pharmacyNCPDPId: json['pharmacyNCPDPId'] as String,
      prescriptionDate: DateTime.parse(json['prescriptionDate'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => USPrescriptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isElectronic: json['isElectronic'] as bool,
      pdmpChecked: json['pdmpChecked'] as bool,
      pdmpState: json['pdmpState'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$USPrescriptionToJson(USPrescription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'prescriberNPI': instance.prescriberNPI,
      'prescriberDEA': instance.prescriberDEA,
      'pharmacyNCPDPId': instance.pharmacyNCPDPId,
      'prescriptionDate': instance.prescriptionDate.toIso8601String(),
      'items': instance.items,
      'isElectronic': instance.isElectronic,
      'pdmpChecked': instance.pdmpChecked,
      'pdmpState': instance.pdmpState,
      'status': instance.status,
    };

USPrescriptionItem _$USPrescriptionItemFromJson(Map<String, dynamic> json) =>
    USPrescriptionItem(
      id: json['id'] as String,
      rxNormCode: json['rxNormCode'] as String,
      ndcCode: json['ndcCode'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      quantity: (json['quantity'] as num).toInt(),
      refills: (json['refills'] as num).toInt(),
      route: json['route'] as String,
      directions: json['directions'] as String,
      substitutionAllowed: json['substitutionAllowed'] as bool,
    );

Map<String, dynamic> _$USPrescriptionItemToJson(USPrescriptionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rxNormCode': instance.rxNormCode,
      'ndcCode': instance.ndcCode,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'quantity': instance.quantity,
      'refills': instance.refills,
      'route': instance.route,
      'directions': instance.directions,
      'substitutionAllowed': instance.substitutionAllowed,
    };

PDMPQuery _$PDMPQueryFromJson(Map<String, dynamic> json) => PDMPQuery(
  id: json['id'] as String,
  state: json['state'] as String,
  queryDate: DateTime.parse(json['queryDate'] as String),
  patientId: json['patientId'] as String,
  prescriberNPI: json['prescriberNPI'] as String,
  status: $enumDecode(_$PDMPStatusEnumMap, json['status']),
  findings: (json['findings'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  notes: json['notes'] as String,
);

Map<String, dynamic> _$PDMPQueryToJson(PDMPQuery instance) => <String, dynamic>{
  'id': instance.id,
  'state': instance.state,
  'queryDate': instance.queryDate.toIso8601String(),
  'patientId': instance.patientId,
  'prescriberNPI': instance.prescriberNPI,
  'status': _$PDMPStatusEnumMap[instance.status]!,
  'findings': instance.findings,
  'notes': instance.notes,
};

const _$PDMPStatusEnumMap = {
  PDMPStatus.notRequired: 'notRequired',
  PDMPStatus.required: 'required',
  PDMPStatus.completed: 'completed',
  PDMPStatus.failed: 'failed',
};
