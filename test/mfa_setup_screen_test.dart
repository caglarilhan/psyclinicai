import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/auth/mfa_setup_screen.dart';
import 'package:psyclinicai/services/mfa/totp_service.dart';

Future<void> _pump(WidgetTester tester, {TotpService? svc}) async {
  tester.view.physicalSize = const Size(1400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      home: MfaSetupScreen(totpOverride: svc ?? TotpService(random: Random(7))),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MfaSetupScreen wizard', () {
    testWidgets('starts on idle pane with Not enabled status', (tester) async {
      await _pump(tester);
      expect(find.text('Not enabled'), findsOneWidget);
      expect(find.text('Set up an authenticator app'), findsOneWidget);
      expect(find.text('Start TOTP setup'), findsOneWidget);
    });

    testWidgets('idle → scan reveals QR + manual secret', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Start TOTP setup'));
      await tester.pumpAndSettle();
      expect(find.text('1 · Scan the QR code'), findsOneWidget);
      expect(find.text('Manual secret'), findsOneWidget);
      expect(find.text('I have scanned the code'), findsOneWidget);
    });

    testWidgets('verify pane rejects an empty code with a helpful error',
        (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Start TOTP setup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I have scanned the code'));
      await tester.pumpAndSettle();
      expect(find.text('2 · Verify the 6-digit code'), findsOneWidget);
      final verifyBtn = find.descendant(
        of: find.byWidgetPredicate((w) => w is FilledButton),
        matching: find.text('Verify'),
      );
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();
      expect(find.textContaining('did not match'), findsOneWidget);
    });
  });
}
