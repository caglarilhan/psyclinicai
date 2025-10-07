class Drug {
  final String code; // e.g. RxCUI/ATC
  final String name;
  final String strength; // e.g. 20 mg
  final String form; // e.g. tablet

  const Drug({required this.code, required this.name, required this.strength, required this.form});
}

class DrugInteraction {
  final String aCode;
  final String bCode;
  final String severity; // minor/moderate/major/contraindicated
  final String note;

  const DrugInteraction({required this.aCode, required this.bCode, required this.severity, required this.note});
}

class PrescriptionItem {
  final Drug drug;
  final String dosage; // e.g. 1x1
  final String route; // PO/IM/IV
  final String frequency; // daily, bid, tid
  final int durationDays; // 7

  const PrescriptionItem({required this.drug, required this.dosage, required this.route, required this.frequency, required this.durationDays});
}

class Prescription {
  final String id;
  final String clientName;
  final String therapistName;
  final DateTime createdAt;
  final List<PrescriptionItem> items;
  final String notes;

  const Prescription({required this.id, required this.clientName, required this.therapistName, required this.createdAt, required this.items, required this.notes});
}


