import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/screens/ai_scribe/ai_scribe_screen.dart';
import 'package:psyclinicai/services/ai_scribe/ai_scribe_client.dart';

void main() {
  testWidgets('renders empty state until a transcript is drafted',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = AiScribeClient(
      baseUrl: 'https://example.test/aiScribeDraftSoap',
      idTokenProvider: () async => 'tok',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AiScribeScreen(client: client, tenantId: 'tenant-x'),
      ),
    );
    await tester.pump();

    expect(find.text('Ambient Clinical Scribe'), findsOneWidget);
    expect(find.text('Session intake'), findsOneWidget);
    expect(find.text('Draft SOAP'), findsOneWidget);
    expect(find.text('No draft yet'), findsOneWidget);
  });

  testWidgets('shows validation error when fields blank', (tester) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = AiScribeClient(
      baseUrl: 'https://example.test/aiScribeDraftSoap',
      idTokenProvider: () async => 'tok',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AiScribeScreen(client: client, tenantId: 'tenant-x'),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Draft SOAP'));
    await tester.pump();

    expect(find.text('Session id + transcript are required.'),
        findsOneWidget);
  });
}
