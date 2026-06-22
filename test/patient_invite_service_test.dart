import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/portal/patient_invite_service.dart';

void main() {
  group('patient invite — Sprint 27 F-012', () {
    final t0 = DateTime.utc(2026, 6, 16, 12, 0);

    test('notFound when state is null', () {
      expect(checkInvite(state: null, now: t0), InviteCheckResult.notFound);
    });

    test('valid on first tap while inside the 24h window', () {
      final state = InviteState(
        id: 'inv_synthetic_1',
        createdAt: t0,
        expiresAt: defaultExpiry(t0),
        consumedAt: null,
      );
      expect(
        checkInvite(state: state, now: t0.add(const Duration(hours: 1))),
        InviteCheckResult.valid,
      );
    });

    test('consumed when consumed_at is set (second tap → 410)', () {
      final state = InviteState(
        id: 'inv_synthetic_1',
        createdAt: t0,
        expiresAt: defaultExpiry(t0),
        consumedAt: t0.add(const Duration(minutes: 5)),
      );
      expect(
        checkInvite(state: state, now: t0.add(const Duration(minutes: 10))),
        InviteCheckResult.consumed,
      );
    });

    test('expired when now == expires_at or later', () {
      final state = InviteState(
        id: 'inv_synthetic_1',
        createdAt: t0,
        expiresAt: defaultExpiry(t0),
        consumedAt: null,
      );
      expect(
        checkInvite(state: state, now: t0.add(const Duration(hours: 24))),
        InviteCheckResult.expired,
      );
      expect(
        checkInvite(
          state: state,
          now: t0.add(const Duration(hours: 24, minutes: 1)),
        ),
        InviteCheckResult.expired,
      );
    });

    test('defaultExpiry == issuedAt + 24h', () {
      expect(defaultExpiry(t0).difference(t0), const Duration(hours: 24));
    });
  });
}
