import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/prescription.dart';
import 'package:psyclinicai/services/erx/ehdsi_adapter.dart';
import 'package:psyclinicai/services/erx/medula_adapter.dart';

Prescription _signed({
  PrescriptionMarket market = PrescriptionMarket.eu,
  String drugCode = 'N06AB04',
  int durationDays = 30,
}) =>
    Prescription(
      id: 'rx-${market.id}',
      clinicId: 'c1',
      patientId: 'p-1',
      clinicianId: 'doc-1',
      market: market,
      status: PrescriptionStatus.signed,
      items: [
        PrescriptionItem(
          drugCode: drugCode,
          drugName: 'Citalopram',
          dose: '20 mg',
          frequency: 'once daily',
          durationDays: durationDays,
        ),
      ],
    );

void main() {
  group('EhdsiAdapter', () {
    const adapter = EhdsiAdapter();

    test('accepts a well-formed EU prescription', () {
      expect(adapter.validateForMarket(_signed()), isNull);
    });

    test('rejects a non-EU market', () {
      expect(
        adapter.validateForMarket(_signed(market: PrescriptionMarket.tr)),
        contains('rejected'),
      );
    });

    test('rejects a non-ATC drug code', () {
      expect(
        adapter.validateForMarket(_signed(drugCode: '12345678')),
        contains('ATC'),
      );
    });

    test('payload mentions the market and the drug code', () {
      final payload = adapter.buildPayload(_signed());
      expect(payload, contains('market="eu"'));
      expect(payload, contains('code="N06AB04"'));
    });

    test('transmit returns a deterministic synthetic id', () async {
      final rx = _signed();
      final result = await adapter.transmit(rx);
      expect(result.externalReference, 'EHDSI-STUB-${rx.id}');
    });

    test('transmit refuses a draft prescription', () async {
      final draft = _signed().copyWith(status: PrescriptionStatus.draft);
      expect(adapter.transmit(draft), throwsA(isA<StateError>()));
    });
  });

  group('MedulaAdapter', () {
    const adapter = MedulaAdapter();

    test('accepts an 8-digit MKYS code, 30-day duration', () {
      final rx = _signed(
        market: PrescriptionMarket.tr,
        drugCode: '87654321',
      );
      expect(adapter.validateForMarket(rx), isNull);
    });

    test('rejects an EU prescription', () {
      expect(
        adapter.validateForMarket(_signed()),
        contains('rejected'),
      );
    });

    test('rejects > 90-day prescriptions', () {
      final rx = _signed(
        market: PrescriptionMarket.tr,
        drugCode: '12345678',
        durationDays: 120,
      );
      expect(
        adapter.validateForMarket(rx),
        contains('1-90 day'),
      );
    });

    test('payload is SOAP-shaped with namespace', () {
      final rx = _signed(
        market: PrescriptionMarket.tr,
        drugCode: '12345678',
      );
      final payload = adapter.buildPayload(rx);
      expect(payload, contains('xmlns="http://medula.sgk.gov.tr"'));
      expect(payload, contains('mkys="12345678"'));
    });

    test('transmit returns the deterministic MEDULA id', () async {
      final rx = _signed(
        market: PrescriptionMarket.tr,
        drugCode: '12345678',
      );
      final result = await adapter.transmit(rx);
      expect(result.externalReference, 'MEDULA-STUB-${rx.id}');
    });
  });
}
