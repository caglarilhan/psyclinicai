/// CI #6 close — smoke coverage for the Stanley-Brown safety plan
/// screen. This screen sits on the crisis-routing path: after a
/// risk signal fires or a C-SSRS escalation pushes a positive
/// finding, the clinician lands here to draft a plan WITH the
/// client. A render-failure regression would block that path
/// silently in production, so we own a smoke test even before the
/// full behavioural matrix lands.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart'
    show PatientDetailArgs;
import 'package:psyclinicai/screens/safety_plan/safety_plan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In-memory backing for the flutter_secure_storage method channel
  // so SafetyPlanRepository + IntakeRepository can initialise without
  // touching iOS Keychain / Android Keystore in CI.
  final secureStore = <String, String>{};

  Object? handleSecureStorage(MethodCall call) {
    final args = call.arguments as Map<Object?, Object?>;
    final key = args['key'] as String? ?? '';
    switch (call.method) {
      case 'read':
        return secureStore[key];
      case 'write':
        secureStore[key] = (args['value'] as String?) ?? '';
        return null;
      case 'delete':
        secureStore.remove(key);
        return null;
      case 'containsKey':
        return secureStore.containsKey(key);
      case 'readAll':
        return Map<String, String>.from(secureStore);
      case 'deleteAll':
        secureStore.clear();
        return null;
    }
    return null;
  }

  setUp(() {
    secureStore.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => handleSecureStorage(call),
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          null,
        );
  });

  Future<void> wide(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  Widget host() => const MaterialApp(
    home: SafetyPlanScreen(
      args: PatientDetailArgs(id: 'p1', name: 'Sven M.'),
    ),
  );

  testWidgets('renders the Stanley-Brown shell with the patient name', (
    tester,
  ) async {
    await wide(tester);
    await tester.pumpWidget(host());
    // Initial frame shows the loading spinner; pump until _init()
    // resolves and the form sections paint.
    await tester.pumpAndSettle();

    // "Safety plan" appears in the page title AND the breadcrumb
    // crumb, so the right assertion is "at least one".
    expect(find.text('Safety plan'), findsWidgets);
    expect(find.textContaining('Stanley-Brown'), findsOneWidget);
    // Patient name surfaces in the subtitle + the breadcrumb so the
    // clinician never confuses two patients mid-crisis.
    expect(find.textContaining('Sven M.'), findsWidgets);
  });

  testWidgets('exposes a Save CTA after _init resolves', (tester) async {
    await wide(tester);
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    // Save CTA must be visible — the clinician needs an explicit
    // persist gesture; we never auto-save a crisis plan to the wire.
    // FilledButton.icon wraps the label/icon in a FilledButton; we
    // assert on the visible text + the save icon together so the
    // smoke test does not pin a specific widget tree depth.
    expect(find.text('Save'), findsOneWidget);
    expect(find.byIcon(Icons.save_outlined), findsOneWidget);
  });
}
