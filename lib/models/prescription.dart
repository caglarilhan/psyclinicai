/// Market-agnostic prescription (Sprint 12).
///
/// Sprint 1–11 shipped a US-leaning e-Rx scaffold. Sprint 12 turns
/// it into a portable model with adapter-specific outbound (eHDSI for
/// EU, MEDULA for TR, SureScripts for US). The model itself is
/// jurisdiction-agnostic; market routing is a single enum so a row
/// transmitted via one adapter can never be silently replayed via
/// another.
///
/// Lifecycle:
///   draft        — clinician composing, no signature yet
///   signed       — signature hash captured (eIDAS QES landing Sprint 14)
///   transmitted  — adapter handed the bundle to the national service
///   dispensed    — pharmacy confirmed dispense
///   cancelled    — clinician revoked OR rejected by national service
///
/// Signed rows are **immutable**. Corrections create a new draft and
/// set [supersedesId] to the cancelled row.
class Prescription {
  Prescription({
    required this.id,
    required this.clinicId,
    required this.patientId,
    required this.clinicianId,
    required this.market,
    required List<PrescriptionItem> items,
    this.status = PrescriptionStatus.draft,
    this.signedAt,
    this.signatureHash,
    this.externalReference,
    this.supersedesId,
    DateTime? createdAt,
  })  : items = List<PrescriptionItem>.unmodifiable(items),
        createdAt = createdAt ?? DateTime.now().toUtc() {
    if (items.isEmpty) {
      throw ArgumentError(
        'A prescription must include at least one item.',
      );
    }
  }

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] as String? ?? '',
        clinicId: json['clinicId'] as String? ?? '',
        patientId: json['patientId'] as String? ?? '',
        clinicianId: json['clinicianId'] as String? ?? '',
        market: PrescriptionMarket.fromId(json['market'] as String?),
        items: (json['items'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PrescriptionItem.fromJson)
            .toList(),
        status: PrescriptionStatus.fromId(json['status'] as String?),
        signedAt: DateTime.tryParse(json['signedAt'] as String? ?? ''),
        signatureHash: json['signatureHash'] as String?,
        externalReference: json['externalReference'] as String?,
        supersedesId: json['supersedesId'] as String?,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      );

  final String id;
  final String clinicId;
  final String patientId;
  final String clinicianId;
  final PrescriptionMarket market;
  final List<PrescriptionItem> items;
  final PrescriptionStatus status;
  final DateTime? signedAt;

  /// SHA-256 over canonical JSON of `items` + `patientId` +
  /// `clinicianId`. Tamper-evident: any post-sign edit is detectable.
  final String? signatureHash;

  /// National service id (eHDSI message id, MEDULA reçete no, ...).
  final String? externalReference;

  /// Set when this row replaces a cancelled prescription.
  final String? supersedesId;

  final DateTime createdAt;

  bool get isImmutable =>
      status == PrescriptionStatus.signed ||
      status == PrescriptionStatus.transmitted ||
      status == PrescriptionStatus.dispensed ||
      status == PrescriptionStatus.cancelled;

  /// Returns null when the transition is allowed; otherwise an
  /// explainer the UI can show.
  String? transitionBlockedReason(PrescriptionStatus next) {
    if (status == next) return 'Already in that state';
    switch (status) {
      case PrescriptionStatus.draft:
        if (next == PrescriptionStatus.signed ||
            next == PrescriptionStatus.cancelled) {
          return null;
        }
        return 'A draft must be signed or cancelled first';
      case PrescriptionStatus.signed:
        if (next == PrescriptionStatus.transmitted ||
            next == PrescriptionStatus.cancelled) {
          return null;
        }
        return 'A signed prescription can only be transmitted or cancelled';
      case PrescriptionStatus.transmitted:
        if (next == PrescriptionStatus.dispensed ||
            next == PrescriptionStatus.cancelled) {
          return null;
        }
        return 'A transmitted prescription waits for dispense or cancel';
      case PrescriptionStatus.dispensed:
      case PrescriptionStatus.cancelled:
        return 'This prescription is in a final state';
    }
  }

  Prescription copyWith({
    PrescriptionStatus? status,
    DateTime? signedAt,
    String? signatureHash,
    String? externalReference,
  }) =>
      Prescription(
        id: id,
        clinicId: clinicId,
        patientId: patientId,
        clinicianId: clinicianId,
        market: market,
        items: items,
        status: status ?? this.status,
        signedAt: signedAt ?? this.signedAt,
        signatureHash: signatureHash ?? this.signatureHash,
        externalReference: externalReference ?? this.externalReference,
        supersedesId: supersedesId,
        createdAt: createdAt,
      );

  /// Build a new draft prescription that replaces this row. The new
  /// row points back via [Prescription.supersedesId] so the audit
  /// trail keeps the linkage. The original must already be in a
  /// final state (signed onwards) — drafts are edited in place.
  Prescription asCorrection({
    required String newId,
    required List<PrescriptionItem> newItems,
  }) {
    if (status == PrescriptionStatus.draft) {
      throw StateError(
        'Cannot supersede a draft prescription; edit it in place.',
      );
    }
    return Prescription(
      id: newId,
      clinicId: clinicId,
      patientId: patientId,
      clinicianId: clinicianId,
      market: market,
      items: newItems,
      supersedesId: id,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clinicId': clinicId,
        'patientId': patientId,
        'clinicianId': clinicianId,
        'market': market.id,
        'items': items.map((e) => e.toJson()).toList(),
        'status': status.id,
        if (signedAt != null) 'signedAt': signedAt!.toIso8601String(),
        if (signatureHash != null) 'signatureHash': signatureHash,
        if (externalReference != null)
          'externalReference': externalReference,
        if (supersedesId != null) 'supersedesId': supersedesId,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// One drug on a prescription.
class PrescriptionItem {
  const PrescriptionItem({
    required this.drugCode,
    required this.drugName,
    required this.dose,
    required this.frequency,
    required this.durationDays,
    this.route = 'oral',
    this.instructions = '',
    this.isPrn = false,
    this.maxDosesPer24h,
    this.controlledSchedule = ControlledSchedule.none,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      PrescriptionItem(
        drugCode: json['drugCode'] as String? ?? '',
        drugName: json['drugName'] as String? ?? '',
        dose: json['dose'] as String? ?? '',
        frequency: json['frequency'] as String? ?? '',
        durationDays: (json['durationDays'] as num? ?? 0).toInt(),
        route: json['route'] as String? ?? 'oral',
        instructions: json['instructions'] as String? ?? '',
        isPrn: json['isPrn'] as bool? ?? false,
        maxDosesPer24h: (json['maxDosesPer24h'] as num?)?.toInt(),
        controlledSchedule:
            ControlledSchedule.fromId(json['controlledSchedule'] as String?),
      );

  /// Market-appropriate code (ATC for EU, MKYS for TR, NDC for US).
  final String drugCode;

  final String drugName;
  final String dose;
  final String frequency;
  final int durationDays;
  final String route;
  final String instructions;

  /// "Pro re nata" — take as needed. When true, [frequency] is
  /// advisory and [maxDosesPer24h] becomes the binding upper limit.
  final bool isPrn;

  /// Hard ceiling for PRN dosing in 24h — surfaced on the dispense
  /// label and persisted on the eHDSI / MEDULA envelope.
  final int? maxDosesPer24h;

  /// Controlled-substance schedule (US DEA; EU and TR map to the
  /// equivalent national scheme). Sprint 14+ surfaces a second-
  /// signature requirement for [ControlledSchedule.scheduleII] and
  /// [ControlledSchedule.scheduleIII].
  final ControlledSchedule controlledSchedule;

  /// True when the item is a controlled substance (any schedule
  /// except `none`).
  bool get isControlled =>
      controlledSchedule != ControlledSchedule.none;

  Map<String, dynamic> toJson() => {
        'drugCode': drugCode,
        'drugName': drugName,
        'dose': dose,
        'frequency': frequency,
        'durationDays': durationDays,
        'route': route,
        'instructions': instructions,
        'isPrn': isPrn,
        if (maxDosesPer24h != null) 'maxDosesPer24h': maxDosesPer24h,
        'controlledSchedule': controlledSchedule.id,
      };
}

enum ControlledSchedule {
  none('none'),
  scheduleII('II'),
  scheduleIII('III'),
  scheduleIV('IV'),
  scheduleV('V');

  const ControlledSchedule(this.id);
  final String id;

  static ControlledSchedule fromId(String? id) {
    for (final s in ControlledSchedule.values) {
      if (s.id == id) return s;
    }
    return ControlledSchedule.none;
  }
}

enum PrescriptionMarket {
  eu('eu'),
  tr('tr'),
  us('us');

  const PrescriptionMarket(this.id);
  final String id;

  static PrescriptionMarket fromId(String? id) {
    for (final m in PrescriptionMarket.values) {
      if (m.id == id) return m;
    }
    return PrescriptionMarket.eu;
  }
}

enum PrescriptionStatus {
  draft('draft'),
  signed('signed'),
  transmitted('transmitted'),
  dispensed('dispensed'),
  cancelled('cancelled');

  const PrescriptionStatus(this.id);
  final String id;

  static PrescriptionStatus fromId(String? id) {
    for (final s in PrescriptionStatus.values) {
      if (s.id == id) return s;
    }
    return PrescriptionStatus.draft;
  }
}
