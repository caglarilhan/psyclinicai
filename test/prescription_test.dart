import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/prescription.dart';

Prescription _rx({
  PrescriptionStatus status = PrescriptionStatus.draft,
  PrescriptionMarket market = PrescriptionMarket.eu,
}) => Prescription(
  id: 'rx-1',
  clinicId: 'c1',
  patientId: 'p-1',
  clinicianId: 'doc-1',
  market: market,
  status: status,
  items: const [
    PrescriptionItem(
      drugCode: 'N06AB04',
      drugName: 'Citalopram',
      dose: '20 mg',
      frequency: 'once daily',
      durationDays: 30,
    ),
  ],
);

void main() {
  group('Prescription', () {
    test('refuses an empty item list at construction', () {
      expect(
        () => Prescription(
          id: 'rx-x',
          clinicId: 'c1',
          patientId: 'p-1',
          clinicianId: 'doc-1',
          market: PrescriptionMarket.eu,
          items: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('JSON round-trip preserves market + status + signature', () {
      final row = _rx().copyWith(
        status: PrescriptionStatus.signed,
        signedAt: DateTime.utc(2026, 6, 10, 10),
        signatureHash: 'sha256:abc',
      );
      final round = Prescription.fromJson(row.toJson());
      expect(round.id, row.id);
      expect(round.market, PrescriptionMarket.eu);
      expect(round.status, PrescriptionStatus.signed);
      expect(round.signatureHash, 'sha256:abc');
      expect(round.items.first.drugCode, 'N06AB04');
    });

    test('isImmutable flips once signed', () {
      expect(_rx().isImmutable, isFalse);
      expect(_rx(status: PrescriptionStatus.signed).isImmutable, isTrue);
      expect(_rx(status: PrescriptionStatus.dispensed).isImmutable, isTrue);
    });

    test('lifecycle: draft → signed → transmitted → dispensed is allowed', () {
      expect(_rx().transitionBlockedReason(PrescriptionStatus.signed), isNull);
      expect(
        _rx(
          status: PrescriptionStatus.signed,
        ).transitionBlockedReason(PrescriptionStatus.transmitted),
        isNull,
      );
      expect(
        _rx(
          status: PrescriptionStatus.transmitted,
        ).transitionBlockedReason(PrescriptionStatus.dispensed),
        isNull,
      );
    });

    test('draft cannot skip straight to transmitted', () {
      expect(
        _rx().transitionBlockedReason(PrescriptionStatus.transmitted),
        contains('signed or cancelled first'),
      );
    });

    test('dispensed is a final state', () {
      expect(
        _rx(
          status: PrescriptionStatus.dispensed,
        ).transitionBlockedReason(PrescriptionStatus.cancelled),
        contains('final state'),
      );
    });

    test('PrescriptionMarket.fromId falls back to eu', () {
      expect(PrescriptionMarket.fromId(null), PrescriptionMarket.eu);
      expect(PrescriptionMarket.fromId('garbage'), PrescriptionMarket.eu);
      expect(PrescriptionMarket.fromId('tr'), PrescriptionMarket.tr);
    });

    test('items list is unmodifiable — external mutation is rejected', () {
      final rx = _rx();
      expect(
        () => rx.items.add(
          const PrescriptionItem(
            drugCode: 'N06AB06',
            drugName: 'Sertraline',
            dose: '50 mg',
            frequency: 'once daily',
            durationDays: 30,
          ),
        ),
        throwsUnsupportedError,
      );
    });

    test('PrescriptionItem PRN + maxDosesPer24h round-trip', () {
      const item = PrescriptionItem(
        drugCode: 'N05BA12',
        drugName: 'Alprazolam',
        dose: '0.5 mg',
        frequency: 'as needed',
        durationDays: 14,
        isPrn: true,
        maxDosesPer24h: 3,
        controlledSchedule: ControlledSchedule.scheduleIV,
      );
      final round = PrescriptionItem.fromJson(item.toJson());
      expect(round.isPrn, isTrue);
      expect(round.maxDosesPer24h, 3);
      expect(round.controlledSchedule, ControlledSchedule.scheduleIV);
      expect(round.isControlled, isTrue);
    });

    test('asCorrection chains supersedesId on a finalised rx', () {
      final signed = _rx(status: PrescriptionStatus.signed);
      final corrected = signed.asCorrection(
        newId: 'rx-2',
        newItems: const [
          PrescriptionItem(
            drugCode: 'N06AB06',
            drugName: 'Sertraline',
            dose: '50 mg',
            frequency: 'once daily',
            durationDays: 30,
          ),
        ],
      );
      expect(corrected.id, 'rx-2');
      expect(corrected.supersedesId, signed.id);
      expect(corrected.status, PrescriptionStatus.draft);
    });

    test('asCorrection refuses to chain off a draft', () {
      expect(
        () => _rx().asCorrection(
          newId: 'rx-2',
          newItems: const [
            PrescriptionItem(
              drugCode: 'N06AB06',
              drugName: 'Sertraline',
              dose: '50 mg',
              frequency: 'once daily',
              durationDays: 30,
            ),
          ],
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
