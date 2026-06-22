import '../../models/prescription.dart';
import '_xml_escape.dart';
import 'erx_adapter.dart';

/// EU eHDSI / NCPeH-B (National Contact Point) adapter (Sprint 12 stub).
///
/// Real implementation will compose an HL7 CDA ePrescription document
/// and POST it to the NCPeH gateway. Sprint 12 stub validates the
/// market + items, builds a deterministic payload string, and returns
/// a synthetic acknowledgement so the UI can be exercised end-to-end.
class EhdsiAdapter implements ErxAdapter {
  const EhdsiAdapter();

  @override
  PrescriptionMarket get market => PrescriptionMarket.eu;

  @override
  String? validateForMarket(Prescription rx) {
    if (rx.market != market) {
      return 'EhdsiAdapter rejected: prescription.market=${rx.market.id}';
    }
    for (final item in rx.items) {
      // eHDSI expects ATC codes (Anatomical Therapeutic Chemical).
      // We normalise to uppercase before checking so casing typos
      // upstream do not silently fail validation.
      if (!RegExp(
        r'^[A-Z]\d{2}[A-Z]{2}\d{2}$',
      ).hasMatch(item.drugCode.toUpperCase())) {
        return 'Item ${item.drugName} drugCode "${item.drugCode}" is not '
            'a valid ATC code (expected e.g. N06AB04).';
      }
    }
    return null;
  }

  @override
  String buildPayload(Prescription rx) {
    final items = rx.items
        .map(
          (i) =>
              '<item code="${xmlEscape(i.drugCode)}" '
              'dose="${xmlEscape(i.dose)}" '
              'duration="${i.durationDays}d"/>',
        )
        .join();
    return '<eHDSI version="2.4" market="eu">'
        '<patient id="${xmlEscape(rx.patientId)}"/>'
        '<prescriber id="${xmlEscape(rx.clinicianId)}"/>'
        '<items>$items</items>'
        '</eHDSI>';
  }

  @override
  Future<ErxTransmissionResult> transmit(Prescription rx) async {
    if (rx.status != PrescriptionStatus.signed) {
      throw StateError(
        'EhdsiAdapter: prescription must be signed before transmit '
        '(got ${rx.status.id}).',
      );
    }
    final error = validateForMarket(rx);
    if (error != null) throw StateError(error);
    return ErxTransmissionResult(
      externalReference: 'EHDSI-STUB-${rx.id}',
      acknowledgedAt: DateTime.now().toUtc(),
    );
  }
}
