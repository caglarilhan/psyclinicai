/// Coverage for PinnedPatientsCard — hidden when no patient is
/// pinned, demo-mode (no Firebase) fallback copy, and the header
/// renders the count + Open roster link.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/patient_pin_repository.dart';
import 'package:psyclinicai/widgets/dashboard/pinned_patients_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PatientPinRepository> _seed(
  String bucket, {
  List<String> pins = const [],
}) async {
  final repo = PatientPinRepository(storageKey: bucket);
  await repo.initialize();
  for (final id in pins) {
    await repo.pin(id);
  }
  return repo;
}

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

  Widget app(Widget home) => MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData(
        size: Size(1200, 1200),
        disableAnimations: true,
      ),
      child: Scaffold(body: home),
    ),
  );

  testWidgets('empty pin set renders nothing', (tester) async {
    final repo = await _seed('pp_test_empty_card');
    await tester.pumpWidget(app(PinnedPatientsCard(pinRepo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Open roster'), findsNothing);
    expect(find.textContaining('Pinned patients'), findsNothing);
  });

  testWidgets('renders header with count + Open roster link (demo mode)', (
    tester,
  ) async {
    final repo = await _seed('pp_test_demo_header', pins: ['pat-1', 'pat-2']);
    await tester.pumpWidget(app(PinnedPatientsCard(pinRepo: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Pinned patients (2)'), findsOneWidget);
    expect(find.text('Open roster'), findsOneWidget);
  });

  testWidgets('demo-mode fallback explains the next step', (tester) async {
    final repo = await _seed('pp_test_demo_copy', pins: ['pat-1']);
    await tester.pumpWidget(app(PinnedPatientsCard(pinRepo: repo)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Open the roster'), findsOneWidget);
    expect(find.textContaining('1 pinned patient'), findsOneWidget);
  });

  testWidgets('pluralises in demo copy', (tester) async {
    final repo = await _seed('pp_test_demo_plural', pins: ['a', 'b', 'c']);
    await tester.pumpWidget(app(PinnedPatientsCard(pinRepo: repo)));
    await tester.pumpAndSettle();
    expect(find.textContaining('3 pinned patients'), findsOneWidget);
  });
}
