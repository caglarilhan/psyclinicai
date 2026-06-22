/// CI #6 close — smoke coverage for the 5-step onboarding wizard.
/// Lands every new clinician on the first run; broken render here
/// blocks activation completely.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // ApiKeyStorage flows through flutter_secure_storage; stub the
    // channel so a "save BYOK" branch never hits Keychain in CI.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => null,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  testWidgets('renders the welcome row + skip CTA on first frame', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: const OnboardingScreen(),
        // Wire stub routes for the eventual finish/skip pushes so
        // the test does not crash the navigator if the timer fires.
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(body: Text('STUB ${settings.name}')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to PsyClinicAI'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });
}
