/// E3 — string-shape regression for the `consent_entries` Firestore
/// rules block. Real emulator-driven coverage would need
/// `firebase-rules-unit-testing` which is a much larger dev-deps
/// graft; this lightweight guard catches the most common silent
/// breakage: someone removes the rule, weakens the deletion gate,
/// or drops the KVKK kind from the allowed-kinds list.
///
/// Pair with an emulator test when the test runner adds rules
/// coverage (TBD).
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String rules;

  setUpAll(() {
    rules = File('firestore.rules').readAsStringSync();
  });

  group('firestore.rules — consent_entries (KVKK md. 6 + GDPR Art. 7)', () {
    test('declares a match block for consent_entries', () {
      expect(
        rules.contains('match /consent_entries/{entryId}'),
        isTrue,
        reason: 'consent_entries match block removed from firestore.rules',
      );
    });

    test('kvkk_md6_health kind is in the allowed-kinds set', () {
      expect(
        rules.contains("'kvkk_md6_health'"),
        isTrue,
        reason:
            'KVKK md. 6 consent kind missing from the allowed-kinds '
            'whitelist — clients can no longer record the rıza.',
      );
    });

    test('every shipped ConsentKind id is in the allowed-kinds set', () {
      // Mirror lib/models/consent_entry.dart `ConsentKind` ids — the
      // rule whitelist and the enum must stay in sync.
      const expectedIds = <String>[
        'hipaa_nopp',
        'gdpr_processing',
        'kvkk_md6_health',
        'ai_processing',
        'audio_recording',
        'telehealth',
        'marketing',
      ];
      for (final id in expectedIds) {
        expect(
          rules.contains("'$id'"),
          isTrue,
          reason: 'ConsentKind id "$id" missing from allowed-kinds set.',
        );
      }
    });

    test('delete is blocked on consent_entries', () {
      final block = _consentEntriesBlock(rules);
      expect(
        block.contains('allow delete: if false;'),
        isTrue,
        reason:
            'consent_entries lost its hard-delete gate — KVKK md. 7 '
            '+ GDPR Art. 30 trail can be erased silently.',
      );
    });

    test('update gate is restricted to the revokedAt field only', () {
      final block = _consentEntriesBlock(rules);
      expect(
        block.contains('affectedKeys()'),
        isTrue,
        reason: 'update gate dropped affectedKeys() diff check.',
      );
      expect(
        block.contains("hasOnly(['revokedAt'])"),
        isTrue,
        reason:
            'update gate no longer pins revokedAt-only diff — other '
            'fields could now be rewritten after the fact.',
      );
      expect(
        block.contains('resource.data.revokedAt == null'),
        isTrue,
        reason:
            'two-step revoke is reachable — a second flip would '
            'overwrite the original revocation timestamp.',
      );
    });

    test('create gate pins tenant + non-empty signature + policyVersion', () {
      final block = _consentEntriesBlock(rules);
      expect(
        block.contains('request.resource.data.clinic_id == request.auth.uid'),
        isTrue,
        reason: 'create no longer enforces tenant scoping.',
      );
      expect(
        block.contains('request.resource.data.signature.size() > 0'),
        isTrue,
        reason: 'create no longer requires a non-empty signature.',
      );
      expect(
        block.contains('request.resource.data.policyVersion.size() > 0'),
        isTrue,
        reason: 'create no longer requires a non-empty policyVersion.',
      );
    });
  });
}

/// Extracts the `match /consent_entries/{entryId} { … }` block body
/// so per-block assertions don't accidentally match content in a
/// neighbouring collection's rules. Walks balanced braces and skips
/// past the placeholder `{entryId}` segment in the match header.
String _consentEntriesBlock(String source) {
  final start = source.indexOf('match /consent_entries/{entryId}');
  if (start == -1) {
    throw StateError('consent_entries match block not found');
  }
  // Skip the variable's `{entryId}` braces: the block-opening `{`
  // sits after them, on the same line.
  final headerEnd = source.indexOf('}', start) + 1;
  final blockOpen = source.indexOf('{', headerEnd);
  if (blockOpen == -1) {
    throw StateError('consent_entries block opener not found');
  }
  var depth = 0;
  for (var i = blockOpen; i < source.length; i++) {
    final c = source[i];
    if (c == '{') depth++;
    if (c == '}') {
      depth--;
      if (depth == 0) return source.substring(blockOpen, i + 1);
    }
  }
  throw StateError('consent_entries block has no matching close brace');
}
