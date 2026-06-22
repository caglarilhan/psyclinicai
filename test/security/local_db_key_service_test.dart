import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/security/local_db_key_service.dart';

/// In-memory backing store for the secure-storage method channel. Lets us
/// run the [LocalDbKeyService] without touching Keychain / Keystore in CI.
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

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late _MemoryStore mem;
  late LocalDbKeyService svc;

  setUp(() {
    mem = _MemoryStore();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => mem.handle(call));
    svc = LocalDbKeyService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('LocalDbKeyService', () {
    test('generates a non-empty passphrase on first call', () async {
      final pass = await svc.getOrCreatePassphrase();
      expect(pass.isNotEmpty, true);
    });

    test('passphrase is stable across calls (idempotent)', () async {
      final first = await svc.getOrCreatePassphrase();
      final second = await svc.getOrCreatePassphrase();
      expect(first, second);
    });

    test('passphrase decodes to exactly 32 bytes (256-bit key)', () async {
      final pass = await svc.getOrCreatePassphrase();
      final bytes = base64Url.decode(pass);
      expect(bytes.length, 32);
    });

    test(
      'two distinct services on a fresh store yield different keys',
      () async {
        final firstKey = await svc.getOrCreatePassphrase();
        mem = _MemoryStore(); // simulate device reset
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              channel,
              (call) async => mem.handle(call),
            );
        final fresh = LocalDbKeyService();
        final newKey = await fresh.getOrCreatePassphrase();
        expect(firstKey, isNot(equals(newKey)));
      },
    );

    test('rotate forces a fresh key on next call', () async {
      final before = await svc.getOrCreatePassphrase();
      await svc.rotate();
      final after = await svc.getOrCreatePassphrase();
      expect(before, isNot(equals(after)));
    });

    test('passphrase uses URL-safe base64 (no + or /)', () async {
      final pass = await svc.getOrCreatePassphrase();
      // base64Url alphabet: A-Z, a-z, 0-9, -, _, and `=` for padding.
      expect(
        RegExp(r'^[A-Za-z0-9_\-=]+$').hasMatch(pass),
        true,
        reason: 'passphrase contained non-URL-safe characters: $pass',
      );
      expect(pass.contains('+'), false);
      expect(pass.contains('/'), false);
    });

    // L-10 fix coverage — graceful rotation with grace-period
    // recovery slot, matching the BYOK rotation flow.
    group('rotateAndGetNew (L-10)', () {
      test(
        'archives the previous passphrase + returns a fresh value',
        () async {
          final original = await svc.getOrCreatePassphrase();
          final next = await svc.rotateAndGetNew();
          expect(next, isNot(equals(original)));
          // The previous slot now holds the OLD passphrase so the
          // caller can recover if PRAGMA rekey crashes mid-flight.
          expect(await svc.readPreviousPassphrase(), original);
          // getOrCreatePassphrase now returns the new value.
          expect(await svc.getOrCreatePassphrase(), next);
        },
      );

      test(
        'rotating from an empty store does not record a previous slot',
        () async {
          final next = await svc.rotateAndGetNew();
          expect(next.isNotEmpty, isTrue);
          expect(await svc.readPreviousPassphrase(), isNull);
        },
      );

      test('commitRotation drops the previous slot (idempotent)', () async {
        await svc.getOrCreatePassphrase();
        await svc.rotateAndGetNew();
        expect(await svc.readPreviousPassphrase(), isNotNull);
        await svc.commitRotation();
        expect(await svc.readPreviousPassphrase(), isNull);
        // Calling again is a no-op (idempotent).
        await svc.commitRotation();
        expect(await svc.readPreviousPassphrase(), isNull);
      });

      test('classic rotate() also wipes the previous slot', () async {
        await svc.getOrCreatePassphrase();
        await svc.rotateAndGetNew();
        expect(await svc.readPreviousPassphrase(), isNotNull);
        await svc.rotate();
        expect(await svc.readPreviousPassphrase(), isNull);
      });
    });
  });
}
