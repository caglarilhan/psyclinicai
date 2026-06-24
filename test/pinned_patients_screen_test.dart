/// Coverage for PinnedPatientsScreen — empty-state copy, pinned-id
/// rows in offline mode, Unpin row button removes the entry, and
/// "Unpin all" bulk action clears everything.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/settings/pinned_patients_screen.dart';
import 'package:psyclinicai/services/data/patient_pin_repository.dart';
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

  Future<void> pumpAt(WidgetTester tester, Widget home) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1400, 1400),
          disableAnimations: true,
        ),
        child: MaterialApp(home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty pin set renders the no-pinned empty state', (
    tester,
  ) async {
    final repo = await _seed('pp_screen_empty');
    await pumpAt(tester, PinnedPatientsScreen(repo: repo));
    expect(find.text('No pinned patients'), findsOneWidget);
    expect(find.text('Open roster'), findsOneWidget);
  });

  testWidgets('renders count badge + each pinned id row', (tester) async {
    final repo = await _seed(
      'pp_screen_basic',
      pins: ['pat-1', 'pat-2', 'pat-3'],
    );
    await pumpAt(tester, PinnedPatientsScreen(repo: repo));
    expect(find.text('3 pinned'), findsOneWidget);
    expect(find.text('pat-1'), findsOneWidget);
    expect(find.text('pat-2'), findsOneWidget);
    expect(find.text('pat-3'), findsOneWidget);
  });

  testWidgets('Unpin all clears every row', (tester) async {
    final repo = await _seed('pp_screen_unpin_all', pins: ['pat-1', 'pat-2']);
    await pumpAt(tester, PinnedPatientsScreen(repo: repo));
    expect(find.text('2 pinned'), findsOneWidget);
    await tester.tap(find.text('Unpin all'));
    await tester.pumpAndSettle();
    expect(find.text('No pinned patients'), findsOneWidget);
    expect(repo.current, isEmpty);
  });

  testWidgets('per-row Unpin removes just that entry', (tester) async {
    final repo = await _seed('pp_screen_unpin_one', pins: ['pat-1', 'pat-2']);
    await pumpAt(tester, PinnedPatientsScreen(repo: repo));
    await tester.tap(find.byTooltip('Unpin').first);
    await tester.pumpAndSettle();
    expect(repo.current, hasLength(1));
  });
}
