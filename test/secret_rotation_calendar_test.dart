import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/secret_rotation_calendar.dart';

void main() {
  group('SecretRotationCalendar — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(SecretRotationCalendar.records, isNotEmpty);
    });

    test('every record has a unique id', () {
      final ids = SecretRotationCalendar.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final r in SecretRotationCalendar.records) {
        expect(SecretRotationCalendar.byId(r.id), same(r));
      }
      expect(SecretRotationCalendar.byId('does-not-exist'), isNull);
    });

    test('reminderDays < rotationDays for every record', () {
      for (final r in SecretRotationCalendar.records) {
        expect(
          r.reminderDays,
          lessThan(r.rotationDays),
          reason: '${r.id}: reminder window must be inside the rotation cycle',
        );
        expect(r.reminderDays, greaterThan(0), reason: r.id);
        expect(r.rotationDays, greaterThan(0), reason: r.id);
      }
    });

    test('every record has owner + label + storage + anchors populated', () {
      for (final r in SecretRotationCalendar.records) {
        expect(r.owner, isNotEmpty, reason: r.id);
        expect(r.label, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });

    test('payment-touch secrets rotate ≤ 90 days (PCI DSS §3.7)', () {
      const paymentTouchIds = ['stripe-api-key', 'stripe-webhook-secret'];
      for (final id in paymentTouchIds) {
        final r = SecretRotationCalendar.byId(id)!;
        expect(
          r.rotationDays,
          lessThanOrEqualTo(90),
          reason: '$id is payment-touch; PCI §3.7 caps cadence at 90 days',
        );
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob,
          contains('PCI DSS'),
          reason: '$id must cite PCI DSS in its regulatoryRefs',
        );
      }
    });

    test('vendor LLM keys rotate ≤ 90 days', () {
      for (final id in ['anthropic-api-key', 'openai-api-key']) {
        final r = SecretRotationCalendar.byId(id)!;
        expect(r.rotationDays, lessThanOrEqualTo(90), reason: id);
      }
    });

    test('signing keys rotate at least annually (NIST SP 800-57)', () {
      for (final r in SecretRotationCalendar.records) {
        if (r.secretClass != SecretClass.signingKey) continue;
        expect(
          r.rotationDays,
          lessThanOrEqualTo(365),
          reason: '${r.id}: signing keys must rotate ≤ 1 year',
        );
      }
    });

    test('reviewer / owner roles span beyond a single owner', () {
      final owners = SecretRotationCalendar.records.map((r) => r.owner).toSet();
      expect(
        owners.length,
        greaterThanOrEqualTo(3),
        reason:
            'all secrets assigned to a single role = bus factor 1; spread '
            'across CISO / CTO / CFO / tenant admin',
      );
    });

    test('BYOK customer key never lives in our cloud KMS', () {
      final byok = SecretRotationCalendar.byId('byok-customer-llm-key')!;
      expect(byok.storage, SecretStorage.onDeviceSqlcipher);
      expect(byok.owner, 'tenant_admin');
    });
  });

  group('daysUntilRotation', () {
    test('positive when rotation is in the future', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      final today = DateTime.parse('2026-07-01');
      expect(
        daysUntilRotation(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: today,
        ),
        60, // 30 elapsed + 60 remaining = 90 day cycle
      );
    });

    test('zero on the rotation day', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      final today = DateTime.parse('2026-08-30');
      expect(
        daysUntilRotation(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: today,
        ),
        0,
      );
    });

    test('negative when overdue', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      final today = DateTime.parse('2026-09-10');
      expect(
        daysUntilRotation(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: today,
        ),
        -11,
      );
    });
  });

  group('isInReminderWindow', () {
    test('false when rotation is still far away', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      expect(
        isInReminderWindow(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: DateTime.parse('2026-06-10'),
        ),
        isFalse,
      );
    });

    test('true when exactly at reminder offset', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      // 90 day cycle, 14 day reminder → fire from day 76 onwards
      expect(
        isInReminderWindow(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: DateTime.parse('2026-08-16'), // day 76
        ),
        isTrue,
      );
    });

    test('true on the rotation day itself', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      expect(
        isInReminderWindow(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: DateTime.parse('2026-08-30'),
        ),
        isTrue,
      );
    });

    test('false when overdue (caller escalates instead of reminding)', () {
      final r = SecretRotationCalendar.byId('stripe-api-key')!;
      expect(
        isInReminderWindow(
          record: r,
          lastRotatedIso: '2026-06-01',
          today: DateTime.parse('2026-09-10'),
        ),
        isFalse,
      );
    });
  });
}
