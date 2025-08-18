import 'package:json_annotation/json_annotation.dart';

part 'us_medication_models.g.dart';

@JsonSerializable()
class USMedicationRecord {
  final String id;
  final String medicationName;
  final String rxNormCode; // RxCUI
  final String ndcCode; // National Drug Code
  final String genericName;
  final String brandName;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> sideEffects;
  final List<String> interactions;
  final DEASchedule deaSchedule; // Controlled substance schedule
  final List<FormularyEntry> formulary;
  final DateTime lastUpdated;

  const USMedicationRecord({
    required this.id,
    required this.medicationName,
    required this.rxNormCode,
    required this.ndcCode,
    required this.genericName,
    required this.brandName,
    required this.indications,
    required this.contraindications,
    required this.sideEffects,
    required this.interactions,
    required this.deaSchedule,
    required this.formulary,
    required this.lastUpdated,
  });

  factory USMedicationRecord.fromJson(Map<String, dynamic> json) => _$USMedicationRecordFromJson(json);
  Map<String, dynamic> toJson() => _$USMedicationRecordToJson(this);
}

@JsonSerializable()
class FormularyEntry {
  final String id;
  final String payerName;
  final String tier; // Tier 1-5
  final bool priorAuthRequired;
  final bool stepTherapyRequired;
  final bool quantityLimit;
  final String notes;

  const FormularyEntry({
    required this.id,
    required this.payerName,
    required this.tier,
    required this.priorAuthRequired,
    required this.stepTherapyRequired,
    required this.quantityLimit,
    required this.notes,
  });

  factory FormularyEntry.fromJson(Map<String, dynamic> json) => _$FormularyEntryFromJson(json);
  Map<String, dynamic> toJson() => _$FormularyEntryToJson(this);
}

@JsonSerializable()
class USPrescription {
  final String id;
  final String patientId;
  final String prescriberNPI;
  final String prescriberDEA;
  final String pharmacyNCPDPId;
  final DateTime prescriptionDate;
  final List<USPrescriptionItem> items;
  final bool isElectronic; // eRx NCPDP SCRIPT
  final bool pdmpChecked;
  final String pdmpState;
  final String status;

  const USPrescription({
    required this.id,
    required this.patientId,
    required this.prescriberNPI,
    required this.prescriberDEA,
    required this.pharmacyNCPDPId,
    required this.prescriptionDate,
    required this.items,
    required this.isElectronic,
    required this.pdmpChecked,
    required this.pdmpState,
    required this.status,
  });

  factory USPrescription.fromJson(Map<String, dynamic> json) => _$USPrescriptionFromJson(json);
  Map<String, dynamic> toJson() => _$USPrescriptionToJson(this);
}

@JsonSerializable()
class USPrescriptionItem {
  final String id;
  final String rxNormCode;
  final String ndcCode;
  final String dosage;
  final String frequency;
  final int quantity;
  final int refills;
  final String route;
  final String directions;
  final bool substitutionAllowed;

  const USPrescriptionItem({
    required this.id,
    required this.rxNormCode,
    required this.ndcCode,
    required this.dosage,
    required this.frequency,
    required this.quantity,
    required this.refills,
    required this.route,
    required this.directions,
    required this.substitutionAllowed,
  });

  factory USPrescriptionItem.fromJson(Map<String, dynamic> json) => _$USPrescriptionItemFromJson(json);
  Map<String, dynamic> toJson() => _$USPrescriptionItemToJson(this);
}

@JsonSerializable()
class PDMPQuery {
  final String id;
  final String state;
  final DateTime queryDate;
  final String patientId;
  final String prescriberNPI;
  final PDMPStatus status;
  final List<String> findings;
  final String notes;

  const PDMPQuery({
    required this.id,
    required this.state,
    required this.queryDate,
    required this.patientId,
    required this.prescriberNPI,
    required this.status,
    required this.findings,
    required this.notes,
  });

  factory PDMPQuery.fromJson(Map<String, dynamic> json) => _$PDMPQueryFromJson(json);
  Map<String, dynamic> toJson() => _$PDMPQueryToJson(this);
}

enum DEASchedule { none, scheduleI, scheduleII, scheduleIII, scheduleIV, scheduleV }

enum PDMPStatus { notRequired, required, completed, failed }
