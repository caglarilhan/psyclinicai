/// E1 — pins the web-fallback contract for [SecurePrefs] so a future
/// plugin upgrade or refactor cannot silently change the IndexedDB
/// namespace or drop the best-effort disclaimer the audit relies on.
///
/// `flutter_secure_storage` on the web build encrypts with a
/// non-extractable AES-GCM key (Web Crypto) but persists the
/// ciphertext + IV in IndexedDB. PsyClinicAI pins
/// `securePrefsWebNamespace = 'psyclinicai_secure_v1'` so the
/// IndexedDB table name is PsyClinicAI-specific instead of the
/// plugin's vague `FlutterEncryptedStorage` default — auditable
/// + immune to plugin-default drift.
library;

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/secure_prefs.dart';

void main() {
  group('SecurePrefs web fallback contract', () {
    test('webOptions are pinned to the PsyClinicAI namespace', () {
      final storage = SecurePrefs.defaultStorageForTesting();
      expect(storage.webOptions, isA<WebOptions>());
      expect(
        storage.webOptions.dbName,
        'psyclinicai_secure_v1',
        reason:
            'Web IndexedDB namespace MUST be PsyClinicAI-specific so '
            'an auditor can find it by name and a plugin-default flip '
            'cannot orphan existing entries.',
      );
      expect(
        storage.webOptions.publicKey,
        'psyclinicai_secure_v1',
        reason: 'publicKey identifies the wrapping key — keep it pinned.',
      );
    });

    test(
      'the namespace constant matches the WebOptions it feeds (drift guard)',
      () {
        expect(securePrefsWebNamespace, 'psyclinicai_secure_v1');
        final storage = SecurePrefs.defaultStorageForTesting();
        expect(storage.webOptions.dbName, securePrefsWebNamespace);
        expect(storage.webOptions.publicKey, securePrefsWebNamespace);
      },
    );

    test(
      'doc comment still surfaces the web best-effort disclaimer + namespace',
      () {
        // Read the source so a future tidy-up that strips the
        // disclaimer fails this test loudly. The audit answer for
        // "where do you tell clinicians the web build is best-effort?"
        // points at lines pinned here.
        final src = File(
          'lib/services/data/secure_prefs.dart',
        ).readAsStringSync();
        expect(
          src.contains('best-effort'),
          isTrue,
          reason: 'Web best-effort disclaimer removed from doc comment.',
        );
        expect(
          src.contains('psyclinicai_secure_v1'),
          isTrue,
          reason:
              'The pinned IndexedDB namespace is missing from the doc; '
              'either restore the comment or update this test.',
        );
        expect(
          src.contains('IndexedDB') || src.contains('localStorage'),
          isTrue,
          reason: 'Doc comment must name the underlying web store.',
        );
      },
    );
  });
}
