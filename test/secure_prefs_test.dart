/// Coverage for SecurePrefs — round-trip, contains, remove, clearAll,
/// and the test-instance override.
///
/// Uses the standard `flutter_secure_storage` MethodChannel mock so
/// the tests run on host without an emulator.
library;

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/secure_prefs.dart';

const _channelName = 'plugins.it_nomads.com/flutter_secure_storage';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(_channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late Map<String, String> backing;

  setUp(() {
    backing = <String, String>{};
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'read':
          final key = (call.arguments as Map)['key'] as String;
          return backing[key];
        case 'write':
          final args = call.arguments as Map;
          backing[args['key'] as String] = args['value'] as String;
          return null;
        case 'delete':
          final key = (call.arguments as Map)['key'] as String;
          backing.remove(key);
          return null;
        case 'containsKey':
          final key = (call.arguments as Map)['key'] as String;
          return backing.containsKey(key);
        case 'deleteAll':
          backing.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(backing);
        default:
          return null;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    SecurePrefs.setInstanceForTest(null);
  });

  test('getString returns null for a missing key', () async {
    final prefs = SecurePrefs();
    expect(await prefs.getString('missing'), isNull);
  });

  test('setString then getString round-trips the value', () async {
    final prefs = SecurePrefs();
    await prefs.setString('mfa.recovery_codes_v1', '{"codes":[]}');
    expect(await prefs.getString('mfa.recovery_codes_v1'), '{"codes":[]}');
  });

  test('containsKey reflects whether a key was written', () async {
    final prefs = SecurePrefs();
    expect(await prefs.containsKey('a'), isFalse);
    await prefs.setString('a', '1');
    expect(await prefs.containsKey('a'), isTrue);
  });

  test('remove drops a single key without touching neighbours', () async {
    final prefs = SecurePrefs();
    await prefs.setString('a', '1');
    await prefs.setString('b', '2');
    await prefs.remove('a');
    expect(await prefs.containsKey('a'), isFalse);
    expect(await prefs.getString('b'), '2');
  });

  test('clearAll wipes the facade', () async {
    final prefs = SecurePrefs();
    await prefs.setString('a', '1');
    await prefs.setString('b', '2');
    await prefs.clearAll();
    expect(await prefs.containsKey('a'), isFalse);
    expect(await prefs.containsKey('b'), isFalse);
  });

  test('setInstanceForTest swaps the singleton', () async {
    final custom = SecurePrefs(storage: const FlutterSecureStorage());
    SecurePrefs.setInstanceForTest(custom);
    expect(identical(SecurePrefs.instance, custom), isTrue);
  });
}
