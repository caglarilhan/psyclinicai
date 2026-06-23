/// Widget coverage for ProUpgradeSheet — renders three paid tiers,
/// local-fallback path fires when checkout reports notConfigured,
/// Stripe error stays in-sheet, success path pops with the chosen
/// tier.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/settings/pro_upgrade_sheet.dart';
import 'package:psyclinicai/services/billing/checkout_service.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';

class _FakeCheckout extends CheckoutService {
  _FakeCheckout(this._impl) : super();
  final Future<void> Function(SubscriptionTier) _impl;

  @override
  Future<void> startCheckout(SubscriptionTier tier, {String? customerEmail}) =>
      _impl(tier);
}

Future<void> _pumpHost(
  WidgetTester tester,
  void Function(BuildContext) onTap,
) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => onTap(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders three tier tiles + Continue is enabled', (tester) async {
    final checkout = _FakeCheckout(
      (_) async => throw const CheckoutException('skip'),
    );
    await _pumpHost(tester, (context) {
      unawaited(
        showModalBottomSheet<SubscriptionTier>(
          context: context,
          isScrollControlled: true,
          builder: (_) => ProUpgradeSheet(checkoutService: checkout),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Solo'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Group'), findsOneWidget);
    final cont = find.text('Continue');
    expect(cont, findsOneWidget);
    final btn = find.ancestor(
      of: cont,
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect((tester.widget(btn.last) as ButtonStyleButton).enabled, isTrue);
  });

  testWidgets('notConfigured + localFallbackEnabled pops with selected tier', (
    tester,
  ) async {
    SubscriptionTier? captured;
    final checkout = _FakeCheckout(
      (_) async =>
          throw const CheckoutException('no backend', notConfigured: true),
    );
    await _pumpHost(tester, (context) async {
      captured = await showModalBottomSheet<SubscriptionTier>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ProUpgradeSheet(checkoutService: checkout),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(captured, SubscriptionTier.solo);
  });

  testWidgets('non-notConfigured error stays in-sheet and is rendered', (
    tester,
  ) async {
    final checkout = _FakeCheckout(
      (_) async => throw const CheckoutException('Stripe is down'),
    );
    await _pumpHost(tester, (context) {
      unawaited(
        showModalBottomSheet<SubscriptionTier>(
          context: context,
          isScrollControlled: true,
          builder: (_) => ProUpgradeSheet(checkoutService: checkout),
        ),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Stripe is down'), findsOneWidget);
    expect(find.text('Solo'), findsOneWidget);
  });

  testWidgets('picking Practice tier returns it via Stripe success path', (
    tester,
  ) async {
    SubscriptionTier? captured;
    final checkout = _FakeCheckout((_) async {
      return;
    });
    await _pumpHost(tester, (context) async {
      captured = await showModalBottomSheet<SubscriptionTier>(
        context: context,
        isScrollControlled: true,
        builder: (_) => ProUpgradeSheet(checkoutService: checkout),
      );
    });
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(captured, SubscriptionTier.practice);
  });
}
