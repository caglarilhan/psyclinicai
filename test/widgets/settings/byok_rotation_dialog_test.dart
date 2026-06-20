import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/byok_rotation_service.dart';
import 'package:psyclinicai/widgets/settings/byok_rotation_dialog.dart';

class _MemoryStore {
  final Map<String, String> _store = {};
  Object? handle(MethodCall call) {
    final args = call.arguments as Map<Object?, Object?>;
    final key = args['key'] as String? ?? '';
    switch (call.method) {
      case 'read':
        return _store[key];
      case 'write':
        _store[key] = (args['value'] as String?) ?? '';
        return null;
      case 'delete':
        _store.remove(key);
        return null;
      case 'readAll':
        return Map<String, String>.from(_store);
      case 'deleteAll':
        _store.clear();
        return null;
    }
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late _MemoryStore mem;
  late ByokRotationService svc;

  setUp(() {
    mem = _MemoryStore();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => mem.handle(call));
    svc = ByokRotationService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<void> openDialog(
    WidgetTester tester,
    ByokProvider provider,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showByokRotateDialog(
                  ctx,
                  provider,
                  service: svc,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders title with provider name + grace-window copy',
      (tester) async {
    await openDialog(tester, ByokProvider.anthropic);
    expect(find.text('Rotate Anthropic Claude key'), findsOneWidget);
    expect(find.textContaining('24 hours'), findsOneWidget);
  });

  testWidgets('Cancel closes the dialog', (tester) async {
    await openDialog(tester, ByokProvider.openai);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Rotate OpenAI key'), findsNothing);
  });

  testWidgets('empty key submission shows inline error, keeps dialog open',
      (tester) async {
    await openDialog(tester, ByokProvider.anthropic);
    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();
    expect(find.text('Enter the new key.'), findsOneWidget);
    expect(find.text('Rotate Anthropic Claude key'), findsOneWidget);
  });

  testWidgets('short key submission shows length error', (tester) async {
    await openDialog(tester, ByokProvider.cohere);
    await tester.enterText(find.byType(TextField), 'too-short');
    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Key is too short'), findsOneWidget);
  });

  testWidgets('valid key persists through service + closes dialog',
      (tester) async {
    await openDialog(tester, ByokProvider.anthropic);
    await tester.enterText(
      find.byType(TextField),
      'sk-ant-validkey-validkey-validkey',
    );
    await tester.tap(find.text('Rotate'));
    await tester.pumpAndSettle();
    expect(find.text('Rotate Anthropic Claude key'), findsNothing);
    expect(
      await svc.currentKey(ByokProvider.anthropic),
      'sk-ant-validkey-validkey-validkey',
    );
  });

  test('byokProviderLabel covers all enum values', () {
    for (final p in ByokProvider.values) {
      expect(byokProviderLabel(p).isNotEmpty, true);
    }
  });
}
