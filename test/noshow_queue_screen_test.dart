import 'dart:convert';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:psyclinicai/screens/noshow/noshow_queue_screen.dart';
import 'package:psyclinicai/services/noshow/noshow_predict_client.dart';
import 'package:psyclinicai/services/noshow/noshow_recent_repository.dart';

/// The dashboard's `_RecentPredictionsPanel` reaches for
/// `FirebaseFirestore.instance` by default. Tests must inject a fake
/// repo so we don't hit the real Firestore initialization on the test
/// isolate.
NoShowRecentRepository _fakeRepo() =>
    NoShowRecentRepository(db: FakeFirebaseFirestore());

void main() {
  testWidgets('renders feature card + Score button', (tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = NoShowPredictClient(
      predictUrl: 'https://example.test/noshowPredict',
      idTokenProvider: () async => 'tok',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NoShowQueueScreen(
          client: client,
          tenantId: 't',
          recentRepo: _fakeRepo(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No-show risk queue'), findsOneWidget);
    expect(find.text('Appointment + history'), findsOneWidget);
    expect(find.text('Score risk'), findsOneWidget);
    // Score panel not visible until a successful predict
    expect(find.text('Recovery playbook'), findsNothing);
  });

  testWidgets('renders score panel after successful predict', (tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final client = NoShowPredictClient(
      predictUrl: 'https://example.test/noshowPredict',
      idTokenProvider: () async => 'tok',
      httpClient: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'probability': 0.22,
            'tier': 'medium',
            'modelVersion': 'v1-baseline-2026-06',
            'playbook': {
              'confirmCadenceHours': [48, 24, 4],
              'smsConfirmHours': 24,
              'callConfirmHours': 4,
              'depositRequired': false,
              'waitlistOfferOnCancel': true,
              'estUsdSavedPerSlot': 60,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NoShowQueueScreen(
          client: client,
          tenantId: 't',
          recentRepo: _fakeRepo(),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextField, 'Appointment id'),
      'appt-1',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Patient id'),
      'pt-1',
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.online_prediction));
    await tester.pump();
    await tester.pump();

    expect(find.text('Recovery playbook'), findsOneWidget);
    expect(find.textContaining('MEDIUM'), findsOneWidget);
  });
}
