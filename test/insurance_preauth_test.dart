import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/insurance_preauth.dart';

void main() {
  InsurancePreAuth build({
    PreAuthStatus status = PreAuthStatus.submitted,
    DateTime? expiresAt,
  }) => InsurancePreAuth(
    id: 'pa1',
    patientId: 'p1',
    payer: 'Aetna',
    memberId: 'M-12345',
    serviceCode: '90837',
    requestedUnits: 12,
    status: status,
    requestedAt: DateTime.utc(2026, 6),
    expiresAt: expiresAt,
    referenceNumber: 'REF-001',
  );

  group('InsurancePreAuth', () {
    test('round-trips through JSON without losing fields', () {
      final p = build(
        status: PreAuthStatus.approved,
        expiresAt: DateTime.utc(2026, 12),
      );
      final back = InsurancePreAuth.fromJson(p.toJson());
      expect(back.id, 'pa1');
      expect(back.patientId, 'p1');
      expect(back.payer, 'Aetna');
      expect(back.memberId, 'M-12345');
      expect(back.serviceCode, '90837');
      expect(back.requestedUnits, 12);
      expect(back.status, PreAuthStatus.approved);
      expect(back.referenceNumber, 'REF-001');
    });

    test('isUsableAt returns true when approved and not expired', () {
      final p = build(
        status: PreAuthStatus.approved,
        expiresAt: DateTime.utc(2026, 12),
      );
      expect(p.isUsableAt(DateTime.utc(2026, 7)), isTrue);
    });

    test('isUsableAt returns false when expired even if approved', () {
      final p = build(
        status: PreAuthStatus.approved,
        expiresAt: DateTime.utc(2026, 5),
      );
      expect(p.isUsableAt(DateTime.utc(2026, 7)), isFalse);
    });

    test('isUsableAt returns false when not yet approved', () {
      final p = build();
      expect(p.isUsableAt(DateTime.utc(2026, 7)), isFalse);
    });

    test('isUsableAt is true when approved with no explicit expiry', () {
      final p = build(status: PreAuthStatus.approved);
      expect(p.isUsableAt(DateTime.utc(2030, 7)), isTrue);
    });

    test('awaitingDecision flips only while submitted', () {
      expect(build().awaitingDecision, isTrue);
      expect(build(status: PreAuthStatus.approved).awaitingDecision, isFalse);
    });

    test('PreAuthStatus.fromId round-trips, defaults to submitted', () {
      for (final s in PreAuthStatus.values) {
        expect(PreAuthStatus.fromId(s.name), s);
      }
      expect(PreAuthStatus.fromId('garbage'), PreAuthStatus.submitted);
      expect(PreAuthStatus.fromId(null), PreAuthStatus.submitted);
    });

    test('assert: requestedUnits must be positive', () {
      expect(
        () => InsurancePreAuth(
          id: 'x',
          patientId: 'p',
          payer: 'X',
          memberId: 'm',
          serviceCode: '90837',
          requestedUnits: 0,
          status: PreAuthStatus.submitted,
          requestedAt: DateTime.utc(2026, 6),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('assert: serviceCode must be short (PHI guard)', () {
      expect(
        () => InsurancePreAuth(
          id: 'x',
          patientId: 'p',
          payer: 'X',
          memberId: 'm',
          serviceCode: 'A' * 17,
          requestedUnits: 1,
          status: PreAuthStatus.submitted,
          requestedAt: DateTime.utc(2026, 6),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toJson omits decision/expiry/reference when not present', () {
      final json = build().toJson();
      expect(json.containsKey('decision_at'), isFalse);
      expect(json.containsKey('expires_at'), isFalse);
    });
  });
}
