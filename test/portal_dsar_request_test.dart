import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/portal_dsar_request.dart';

PortalDsarRequest _row({
  PortalDsarState state = PortalDsarState.submitted,
  PortalDsarKind kind = PortalDsarKind.access,
  DateTime? submittedAt,
}) => PortalDsarRequest(
  id: 'dsar-1',
  userId: 'u-1',
  patientId: 'p-1',
  kind: kind,
  state: state,
  submittedAt: submittedAt,
);

void main() {
  group('PortalDsarRequest', () {
    test('deadline is exactly 30 days after submittedAt', () {
      final r = _row(submittedAt: DateTime.utc(2026, 6));
      expect(r.deadline, DateTime.utc(2026, 7));
    });

    test('isOverdue flips after the 30-day window for an open request', () {
      final r = _row(submittedAt: DateTime.utc(2026, 5));
      expect(r.isOverdue(DateTime.utc(2026, 6, 5)), isTrue);
    });

    test('fulfilled requests are never overdue', () {
      final r = _row(
        state: PortalDsarState.fulfilled,
        submittedAt: DateTime.utc(2026),
      );
      expect(r.isOverdue(DateTime.utc(2026, 6, 5)), isFalse);
    });

    test('lifecycle: submitted → underReview → fulfilled is allowed', () {
      expect(
        _row().transitionBlockedReason(PortalDsarState.underReview),
        isNull,
      );
      expect(
        _row(
          state: PortalDsarState.underReview,
        ).transitionBlockedReason(PortalDsarState.fulfilled),
        isNull,
      );
    });

    test('submitted cannot skip straight to fulfilled', () {
      expect(
        _row().transitionBlockedReason(PortalDsarState.fulfilled),
        contains('underReview'),
      );
    });

    test('JSON round-trip preserves kind + state + notes', () {
      final row = _row(kind: PortalDsarKind.erasure).copyWith(
        state: PortalDsarState.fulfilled,
        notes: 'Patient archive sent',
        fulfilledAt: DateTime.utc(2026, 6, 20),
      );
      final round = PortalDsarRequest.fromJson(row.toJson());
      expect(round.kind, PortalDsarKind.erasure);
      expect(round.state, PortalDsarState.fulfilled);
      expect(round.notes, 'Patient archive sent');
      expect(round.fulfilledAt, row.fulfilledAt);
    });
  });
}
