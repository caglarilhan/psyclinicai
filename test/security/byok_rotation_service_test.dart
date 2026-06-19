import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/byok_rotation_service.dart';

/// Mirrors the in-memory store used by [LocalDbKeyService] tests so the
/// secure-storage method channel returns sane data inside `flutter test`.
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
      case 'containsKey':
        return _store.containsKey(key);
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

  group('ByokRotationService (Sprint 32 P2)', () {
    test('first rotation persists key + leaves previous slot empty',
        () async {
      final r = await svc.rotate(
          ByokProvider.anthropic, 'sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx');
      expect(r.status, ByokRotationStatus.completed);
      expect(await svc.currentKey(ByokProvider.anthropic),
          'sk-ant-xxxxxxxxxxxxxxxxxxxxxxxx');
      expect(await svc.previousKeyIfValid(ByokProvider.anthropic), isNull);
    });

    test('second rotation moves the prior key to previous slot', () async {
      await svc.rotate(
          ByokProvider.anthropic, 'sk-ant-old-old-old-old-old-old');
      await svc.rotate(
          ByokProvider.anthropic, 'sk-ant-new-new-new-new-new-new');
      expect(await svc.currentKey(ByokProvider.anthropic),
          'sk-ant-new-new-new-new-new-new');
      expect(
          await svc.previousKeyIfValid(ByokProvider.anthropic,
              now: DateTime.now().toUtc().add(const Duration(hours: 1))),
          'sk-ant-old-old-old-old-old-old');
    });

    test('previous key is wiped after the grace window', () async {
      await svc.rotate(
          ByokProvider.openai, 'sk-openai-1111111111111111');
      await svc.rotate(
          ByokProvider.openai, 'sk-openai-2222222222222222');
      // Pretend a week passed.
      final future = DateTime.now().toUtc().add(const Duration(days: 7));
      expect(
          await svc.previousKeyIfValid(ByokProvider.openai, now: future),
          isNull,
          reason: 'must wipe previous key after grace window');
    });

    test('empty key rotation is rejected, current slot untouched', () async {
      await svc.rotate(
          ByokProvider.cohere, 'cohere-aaaaaaaaaaaaaaaa');
      final r = await svc.rotate(ByokProvider.cohere, '   ');
      expect(r.status, ByokRotationStatus.rejected);
      expect(r.reason, 'empty_key');
      expect(await svc.currentKey(ByokProvider.cohere),
          'cohere-aaaaaaaaaaaaaaaa');
    });

    test('short key rotation is rejected', () async {
      final r = await svc.rotate(ByokProvider.cohere, 'too-short');
      expect(r.status, ByokRotationStatus.rejected);
      expect(r.reason, 'key_too_short');
    });

    test('wipePrevious clears slot even mid-grace', () async {
      await svc.rotate(
          ByokProvider.anthropic, 'sk-ant-aaaaaaaaaaaaaaaa');
      await svc.rotate(
          ByokProvider.anthropic, 'sk-ant-bbbbbbbbbbbbbbbb');
      expect(await svc.previousKeyIfValid(ByokProvider.anthropic),
          isNotNull);
      await svc.wipePrevious(ByokProvider.anthropic);
      expect(await svc.previousKeyIfValid(ByokProvider.anthropic), isNull);
    });

    test('slots are namespaced per provider', () async {
      await svc.rotate(
          ByokProvider.anthropic, 'sk-ant-aaaaaaaaaaaaaaaa');
      await svc.rotate(ByokProvider.openai, 'sk-openai-bbbbbbbbbbbbbb');
      expect(await svc.currentKey(ByokProvider.anthropic),
          'sk-ant-aaaaaaaaaaaaaaaa');
      expect(await svc.currentKey(ByokProvider.openai),
          'sk-openai-bbbbbbbbbbbbbb');
    });
  });
}
