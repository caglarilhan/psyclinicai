/// CI #6 close — smoke coverage for the Treatment Plan screen
/// (the "golden thread": diagnosis → goals → progress for a
/// patient). Mocks the offline-storage method channels so
/// HomeworkRepository + IntakeRepository can initialise.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart'
    show PatientDetailArgs;
import 'package:psyclinicai/screens/treatment_plan/treatment_plan_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('renders the diagnosis → goals → progress shell', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: TreatmentPlanScreen(
          args: PatientDetailArgs(id: 'demo-1', name: 'John Demo'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Treatment plan'), findsWidgets);
    // Subtitle copy anchors the three-stage flow.
    expect(
      find.textContaining('diagnosis → goals → progress'),
      findsWidgets,
    );
    // Patient name surfaces in the subtitle + breadcrumb crumb.
    expect(find.textContaining('John Demo'), findsWidgets);
  });
}
