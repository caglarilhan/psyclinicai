import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/screens/treatment_plan_drafter/tp_drafter_screen.dart';
import 'package:psyclinicai/services/treatment_plan_drafter/tp_drafter_client.dart';

void main() {
  testWidgets('renders intake card + empty state',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = TpDrafterClient(
      draftUrl: 'https://example.test/tpDraftPlan',
      idTokenProvider: () async => 'tok',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TpDrafterScreen(client: client, tenantId: 't'),
      ),
    );
    await tester.pump();

    expect(find.text('Treatment plan drafter'), findsAtLeastNWidgets(1));
    expect(find.text('Plan intake'), findsOneWidget);
    expect(find.text('Draft plan'), findsOneWidget);
    expect(find.text('No draft yet'), findsOneWidget);
  });

  testWidgets('shows validation error when problems empty', (tester) async {
    tester.view.physicalSize = const Size(1600, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = TpDrafterClient(
      draftUrl: 'https://example.test/tpDraftPlan',
      idTokenProvider: () async => 'tok',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TpDrafterScreen(client: client, tenantId: 't'),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pump();

    expect(
      find.text('At least one presenting problem is required.'),
      findsOneWidget,
    );
  });
}
