/// CI #6 close — smoke coverage for the three remaining
/// patients-subdir screens: PatientListScreen, PatientDetailScreen,
/// IntakeFormScreen. Sister screens (PatientChartScreen,
/// ConsentCenterScreen) already have dedicated tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/patients/intake_form_screen.dart';
import 'package:psyclinicai/screens/patients/patient_detail_screen.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In-memory backing for the flutter_secure_storage method channel
  // so IntakeRepository can initialise without touching Keychain.
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
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            'plugins.it_nomads.com/flutter_secure_storage',
          ),
          (call) async => handleSecureStorage(call),
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel(
            'plugins.it_nomads.com/flutter_secure_storage',
          ),
          null,
        );
  });

  Future<void> wide(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('PatientListScreen renders demo roster when Firebase is off', (
    tester,
  ) async {
    await wide(tester);
    await tester.pumpWidget(
      const MaterialApp(home: PatientListScreen()),
    );
    await tester.pumpAndSettle();

    // Title + search hint anchor on stable copy.
    expect(find.text('Patients'), findsWidgets);
    expect(
      find.textContaining('Search the roster'),
      findsWidgets,
    );
    // Three demo patients ship in the fallback. Sample one.
    expect(find.textContaining('John Demo'), findsWidgets);
  });

  testWidgets('PatientDetailScreen renders the patient name', (tester) async {
    await wide(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: PatientDetailScreen(
          args: PatientDetailArgs(id: 'demo-1', name: 'John Demo'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('John Demo'), findsWidgets);
  });

  testWidgets('IntakeFormScreen renders the AppShell + safety baseline', (
    tester,
  ) async {
    await wide(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: IntakeFormScreen(
          args: PatientDetailArgs(id: 'demo-1', name: 'John Demo'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Intake'), findsWidgets);
    // AppShell subtitle anchors the three-block structure of the
    // form ("demographics, safety baseline, consent"). Regression
    // here would mean the screen header drifted.
    expect(find.textContaining('demographics'), findsWidgets);
  });
}
