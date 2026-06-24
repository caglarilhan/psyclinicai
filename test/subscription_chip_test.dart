/// Coverage for SubscriptionChip — renders the tier label,
/// updates on tier change, and stays silent when no Provider is
/// present so widget tests can pump it standalone.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';
import 'package:psyclinicai/widgets/subscription_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWith(SubscriptionService svc) => MaterialApp(
    home: ChangeNotifierProvider<SubscriptionService>.value(
      value: svc,
      child: const Scaffold(body: Center(child: SubscriptionChip())),
    ),
  );

  testWidgets('renders Free / Trial label by default', (tester) async {
    final svc = SubscriptionService();
    await tester.pumpWidget(wrapWith(svc));
    await tester.pumpAndSettle();
    expect(find.text('Free / Trial'), findsOneWidget);
  });

  testWidgets('renders Solo label after applyStatus(solo, active)', (
    tester,
  ) async {
    final svc = SubscriptionService()
      ..applyStatus(tier: SubscriptionTier.solo, active: true);
    await tester.pumpWidget(wrapWith(svc));
    await tester.pumpAndSettle();
    expect(find.text('Solo'), findsOneWidget);
  });

  testWidgets('listens for changes via Provider', (tester) async {
    final svc = SubscriptionService();
    await tester.pumpWidget(wrapWith(svc));
    await tester.pumpAndSettle();
    expect(find.text('Free / Trial'), findsOneWidget);
    expect(find.text('Practice'), findsNothing);

    svc.applyStatus(tier: SubscriptionTier.practice, active: true);
    await tester.pumpAndSettle();
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Free / Trial'), findsNothing);
  });

  testWidgets('renders nothing when Provider is absent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: SubscriptionChip())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Free / Trial'), findsNothing);
    expect(find.text('Solo'), findsNothing);
  });
}
