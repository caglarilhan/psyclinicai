import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/stripe_connect_account.dart';

void main() {
  group('StripeConnectStatus', () {
    test('fromId falls back to none for unknown values', () {
      expect(StripeConnectStatus.fromId('mystery'), StripeConnectStatus.none);
      expect(
        StripeConnectStatus.fromId('enabled'),
        StripeConnectStatus.enabled,
      );
    });
  });

  group('StripeConnectAccount', () {
    test('isReady requires enabled + charges + payouts', () {
      const a = StripeConnectAccount(
        tenantId: 't-1',
        status: StripeConnectStatus.enabled,
        chargesEnabled: true,
        payoutsEnabled: true,
      );
      expect(a.isReady, isTrue);
      expect(a.copyWith(chargesEnabled: false).isReady, isFalse);
      expect(a.copyWith(payoutsEnabled: false).isReady, isFalse);
      expect(
        a.copyWith(status: StripeConnectStatus.restricted).isReady,
        isFalse,
      );
    });

    test('hasBlockingRequirements true when list non-empty', () {
      const a = StripeConnectAccount(
        tenantId: 't-1',
        status: StripeConnectStatus.restricted,
        requirementsDue: ['external_account'],
      );
      expect(a.hasBlockingRequirements, isTrue);
      expect(
        a.copyWith(requirementsDue: const []).hasBlockingRequirements,
        isFalse,
      );
    });

    test('JSON round-trip preserves fields', () {
      final a = StripeConnectAccount(
        tenantId: 't-1',
        status: StripeConnectStatus.restricted,
        accountId: 'acct_X',
        requirementsDue: const ['external_account'],
        lastSyncAt: DateTime.utc(2026, 6, 1, 12),
        dashboardUrl: 'https://example/dash',
        chargesEnabled: false,
        payoutsEnabled: false,
      );
      final b = StripeConnectAccount.fromJson(a.toJson());
      expect(b.tenantId, a.tenantId);
      expect(b.status, a.status);
      expect(b.accountId, a.accountId);
      expect(b.requirementsDue, a.requirementsDue);
      expect(b.lastSyncAt, a.lastSyncAt);
      expect(b.dashboardUrl, a.dashboardUrl);
    });

    test('demo seed exposes restricted state with 3 requirements', () {
      final demo = StripeConnectAccount.demo('demo-tenant-xyz');
      expect(demo.status, StripeConnectStatus.restricted);
      expect(demo.requirementsDue.length, 3);
      expect(demo.accountId, startsWith('acct_demo_'));
    });
  });
}
