// Sprint 31 F-013 regression — static-contract guard for the SQLCipher
// fix shipped in Sprint 30 S-06. The real encryption proof runs on an
// iOS Simulator + Android emulator per the manual procedure in
// `docs/security/sqlcipher-keychain-audit.md` §3; this file is the CI
// safety net that catches a refactor accidentally dropping the
// `password:` parameter or reverting to plain sqflite.
//
// Skill-panel coverage: tdd-guide + senior-security + healthcare-phi-
// compliance. The asserts model the boundary contract; they do NOT try
// to exercise SQLCipher itself (that needs a platform channel).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OfflineService SQLCipher contract (Sprint 30 S-06)', () {
    final source = File('lib/services/offline_service.dart').readAsStringSync();

    test('imports sqflite_sqlcipher, never plain sqflite', () {
      expect(
        source.contains("package:sqflite_sqlcipher/sqflite.dart"),
        true,
        reason:
            'offline_service must import sqflite_sqlcipher so openDatabase '
            'enforces PRAGMA key (S-06 HIPAA §164.312(a)(2)(iv)).',
      );
      // The forbidden pattern is an actual `import 'package:sqflite/...'`
      // statement. Doc-comments that mention the old package by name are
      // fine (and we keep one in offline_service.dart so future readers
      // know what was replaced).
      final plainSqfliteImport = RegExp(
        r'''import\s+["']package:sqflite/sqflite\.dart["']''',
      );
      expect(
        plainSqfliteImport.hasMatch(source),
        false,
        reason:
            'plain sqflite import is forbidden — it writes plaintext SQLite '
            'on disk and re-opens F-013.',
      );
    });

    test('imports LocalDbKeyService and passes password to openDatabase', () {
      expect(
        source.contains("LocalDbKeyService"),
        true,
        reason:
            'OfflineService must call LocalDbKeyService.getOrCreatePassphrase '
            '— hard-coded keys defeat the keychain binding.',
      );
      expect(
        source.contains("password: passphrase"),
        true,
        reason:
            'openDatabase must receive `password: passphrase` — without it '
            'sqflite_sqlcipher falls back to plaintext mode.',
      );
    });

    test('uses v2 DB filename so plaintext v1 file is never re-opened', () {
      expect(
        source.contains("psyclinic_offline_v2.db"),
        true,
        reason:
            'v2 filename guarantees the legacy plaintext file is not opened '
            'as an encrypted DB (which would silent-corrupt rows).',
      );
    });

    test('pubspec declares sqflite_sqlcipher', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec.contains('sqflite_sqlcipher:'),
        true,
        reason: 'sqflite_sqlcipher must be a declared dep.',
      );
    });

    test('LocalDbKeyService source uses Random.secure (no PRNG drift)', () {
      final keySvc = File(
        'lib/services/security/local_db_key_service.dart',
      ).readAsStringSync();
      expect(
        keySvc.contains('Random.secure()'),
        true,
        reason:
            'Random.secure is mandatory — a non-CSPRNG passphrase is a '
            'CWE-338 finding and would re-open F-013 at audit time.',
      );
      expect(
        keySvc.contains('FlutterSecureStorage'),
        true,
        reason:
            'Passphrase must live in Keychain/Keystore via '
            'flutter_secure_storage, not SharedPreferences.',
      );
    });
  });
}
