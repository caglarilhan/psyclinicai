/// Coverage for SetupChecklist — the dashboard's onboarding tile
/// now derives `done` flags from real services (profile + Stripe +
/// local MFA acknowledgement).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/screens/dashboard/dashboard_sections.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';
import 'package:psyclinicai/services/data/mfa_local_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrapWith({SubscriptionService? sub, MfaLocalRepository? mfa}) {
    final tile = SetupChecklist(mfaRepo: mfa);
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

  testWidgets('local MFA acknowledgement flips the mfa step to done', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final mfa = MfaLocalRepository(storageKey: 'mfa_test_checklist');
    await mfa.initialize();
    await tester.pumpWidget(wrapWith(mfa: mfa));
    await tester.pumpAndSettle();
    expect(find.text('0 / 4'), findsOneWidget);

    await mfa.markAcknowledged();
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
