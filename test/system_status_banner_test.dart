/// Coverage for SystemStatusBanner — hidden on all-green, surfaces
/// the impacted subsystem message + "View status" CTA when any
/// subsystem flips, and live-updates when severity changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/system_status_service.dart';
import 'package:psyclinicai/widgets/system_status_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SystemStatusService.instance.debugReset);

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          child,
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    ),
  );

  testWidgets('renders nothing when every subsystem is operational', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const SystemStatusBanner()));
    await tester.pumpAndSettle();
    expect(find.text('View status'), findsNothing);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('surfaces a single degraded subsystem with its message', (
    tester,
  ) async {
    SystemStatusService.instance.setSeverity(
      SystemId.anthropic,
      StatusSeverity.degraded,
      message: 'Latency spike',
    );
    await tester.pumpWidget(wrap(const SystemStatusBanner()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Anthropic API: Degraded'), findsOneWidget);
    expect(find.textContaining('Latency spike'), findsOneWidget);
    expect(find.text('View status'), findsOneWidget);
  });

  testWidgets('summarises multiple impacted subsystems', (tester) async {
    final svc = SystemStatusService.instance
      ..setSeverity(SystemId.anthropic, StatusSeverity.degraded)
      ..setSeverity(SystemId.stripe, StatusSeverity.down);
    expect(svc.nonOperational, hasLength(2));

    await tester.pumpWidget(wrap(const SystemStatusBanner()));
    await tester.pumpAndSettle();
    expect(find.textContaining('2 subsystems impacted'), findsOneWidget);
    expect(find.textContaining('Anthropic API'), findsOneWidget);
    expect(find.textContaining('Stripe billing'), findsOneWidget);
  });

  testWidgets('rebuilds live when severity changes', (tester) async {
    await tester.pumpWidget(wrap(const SystemStatusBanner()));
    await tester.pumpAndSettle();
    expect(find.text('View status'), findsNothing);

    SystemStatusService.instance.setSeverity(
      SystemId.email,
      StatusSeverity.degraded,
    );
    await tester.pumpAndSettle();
    expect(find.text('View status'), findsOneWidget);
  });
}
