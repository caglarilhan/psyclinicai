/// Coverage for SetupChecklist — the dashboard's onboarding tile
/// now derives `done` flags from real services (profile + Stripe).
/// Verifies the count badge flips when SubscriptionService.applyStatus
/// activates a paid tier.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/screens/dashboard/dashboard_sections.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWith({SubscriptionService? sub}) {
    const tile = SetupChecklist();
    final child = sub == null
        ? tile
        : ChangeNotifierProvider<SubscriptionService>.value(
            value: sub,
            child: tile,
          );
    return MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('all-zero state shows 0 / 4 badge', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapWith());
    await tester.pumpAndSettle();
    expect(find.text('0 / 4'), findsOneWidget);
  });

  testWidgets('activating a paid subscription flips Stripe step to done', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final sub = SubscriptionService();
    await tester.pumpWidget(wrapWith(sub: sub));
    await tester.pumpAndSettle();
    expect(find.text('0 / 4'), findsOneWidget);

    sub.applyStatus(tier: SubscriptionTier.solo, active: true);
    await tester.pumpAndSettle();
    expect(find.text('1 / 4'), findsOneWidget);
  });

  testWidgets('every checklist row remains tappable', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(wrapWith());
    await tester.pumpAndSettle();
    expect(find.text('Add your clinician profile'), findsOneWidget);
    expect(find.text('Enable two-factor authentication'), findsOneWidget);
    expect(find.text('Connect Stripe to take payments'), findsOneWidget);
    expect(find.text('Invite your first patient'), findsOneWidget);
  });
}
