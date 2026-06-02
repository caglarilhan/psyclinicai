import '../../models/prescription.dart';
import '_xml_escape.dart';
import 'erx_adapter.dart';

/// Sağlık Bakanlığı MEDULA adapter for TR market (Sprint 12 stub).
///
/// Real implementation will POST SOAP envelopes to the MEDULA web
/// service (SGK). Sprint 12 stub validates the market + items, builds
/// a deterministic XML payload, and returns a synthetic
/// acknowledgement.
class MedulaAdapter implements ErxAdapter {
  const MedulaAdapter();

  @override
  PrescriptionMarket get market => PrescriptionMarket.tr;

  @override
  String? validateForMarket(Prescription rx) {
    if (rx.market != market) {
      return 'MedulaAdapter rejected: prescription.market=${rx.market.id}';
    }
    for (final item in rx.items) {
      // MEDULA MKYS codes are an 8-digit numeric "barkod".
      if (!RegExp(r'^\d{8}$').hasMatch(item.drugCode)) {
        return 'Item ${item.drugName} drugCode "${item.drugCode}" is not '
            'a valid MKYS code (8 digits).';
      }
      if (item.durationDays <= 0 || item.durationDays > 90) {
        return 'MEDULA accepts 1-90 day prescriptions; got '
            '${item.durationDays}.';
      }
    }
    return null;
  }

  @override
  String buildPayload(Prescription rx) {
    final items = rx.items
        .map((i) =>
            '<ilac mkys="${xmlEscape(i.drugCode)}" '
            'doz="${xmlEscape(i.dose)}" '
            'sure="${i.durationDays}" '
            'yol="${xmlEscape(i.route)}"/>')
        .join();
    return '<recete xmlns="http://medula.sgk.gov.tr">'
        '<hasta tckn="${xmlEscape(rx.patientId)}"/>'
        '<hekim id="${xmlEscape(rx.clinicianId)}"/>'
        '<ilaclar>$items</ilaclar>'
        '</recete>';
  }

  @override
  Future<ErxTransmissionResult> transmit(Prescription rx) async {
    if (rx.status != PrescriptionStatus.signed) {
      throw StateError(
        'MedulaAdapter: prescription must be signed before transmit '
        '(got ${rx.status.id}).',
      );
    }
    final error = validateForMarket(rx);
    if (error != null) throw StateError(error);
    return ErxTransmissionResult(
      externalReference: 'MEDULA-STUB-${rx.id}',
      acknowledgedAt: DateTime.now().toUtc(),
    );
  }
}
