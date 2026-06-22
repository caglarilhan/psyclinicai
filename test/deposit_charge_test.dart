import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/deposit_charge.dart';

DepositCharge _row({
  DepositStatus status = DepositStatus.pending,
  int amountCents = 2500,
}) => DepositCharge(
  id: 'd-1',
  clinicId: 'c1',
  patientId: 'p-1',
  appointmentId: 'appt-1',
  amountCents: amountCents,
  currency: 'EUR',
  status: status,
);

void main() {
  group('DepositCharge', () {
    test('refuses a negative amount at construction', () {
      expect(
        () => DepositCharge(
          id: 'd-x',
          clinicId: 'c1',
          patientId: 'p-1',
          appointmentId: 'appt-1',
          amountCents: -1,
          currency: 'EUR',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('JSON round-trip preserves status + timestamps', () {
      final row = DepositCharge(
        id: 'd-2',
        clinicId: 'c1',
        patientId: 'p-2',
        appointmentId: 'appt-2',
        amountCents: 5000,
        currency: 'USD',
        status: DepositStatus.captured,
        paymentIntentId: 'pi_123',
        noShowReasonCode: 'NO_SHOW_24H',
        capturedAt: DateTime.utc(2026, 6, 11, 10),
      );
      final round = DepositCharge.fromJson(row.toJson());
      expect(round.id, row.id);
      expect(round.status, DepositStatus.captured);
      expect(round.paymentIntentId, 'pi_123');
      expect(round.noShowReasonCode, 'NO_SHOW_24H');
      expect(round.capturedAt, row.capturedAt);
    });

    test('lifecycle: pending → held → captured is allowed', () {
      final pending = _row();
      expect(pending.transitionBlockedReason(DepositStatus.held), isNull);
      final held = pending.copyWith(status: DepositStatus.held);
      expect(held.transitionBlockedReason(DepositStatus.captured), isNull);
    });

    test('lifecycle: captured is a final state', () {
      final captured = _row(status: DepositStatus.captured);
      expect(
        captured.transitionBlockedReason(DepositStatus.refunded),
        contains('final state'),
      );
    });

    test('pending → captured is NOT allowed (must hold first)', () {
      final pending = _row();
      expect(
        pending.transitionBlockedReason(DepositStatus.captured),
        contains('must be held'),
      );
    });

    test('cancelled is final and immutable', () {
      final cancelled = _row(status: DepositStatus.cancelled);
      expect(
        cancelled.transitionBlockedReason(DepositStatus.held),
        contains('final state'),
      );
    });

    test('DepositStatus.fromId falls back to pending', () {
      expect(DepositStatus.fromId(null), DepositStatus.pending);
      expect(DepositStatus.fromId('garbage'), DepositStatus.pending);
      expect(DepositStatus.fromId('captured'), DepositStatus.captured);
    });
  });
}
