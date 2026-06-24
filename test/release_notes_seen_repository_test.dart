/// Coverage for ReleaseNotesSeenRepository — lastSeen round-trip,
/// markSeen overwrite, shouldShow predicate, and the empty-string
/// safety case.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/release_notes_seen_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('lastSeen returns null on a fresh device', () async {
    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_fresh');
    expect(await repo.lastSeen(), isNull);
  });

  test('markSeen + lastSeen round-trip', () async {
    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_rt');
    await repo.markSeen('0.6.0');
    expect(await repo.lastSeen(), '0.6.0');
  });

  test('markSeen overwrites the prior value', () async {
    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_overwrite');
    await repo.markSeen('0.5.0');
    await repo.markSeen('0.6.0');
    expect(await repo.lastSeen(), '0.6.0');
  });

  test('shouldShow returns true when the current version is unseen', () async {
    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_unseen');
    expect(await repo.shouldShow('0.6.0'), isTrue);
  });

  test(
    'shouldShow returns false once the user has dismissed that version',
    () async {
      final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_seen');
      await repo.markSeen('0.6.0');
      expect(await repo.shouldShow('0.6.0'), isFalse);
    },
  );

  test(
    'shouldShow returns true again when the version bumps past lastSeen',
    () async {
      final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_bump');
      await repo.markSeen('0.5.0');
      expect(await repo.shouldShow('0.6.0'), isTrue);
    },
  );

  test('lastSeen treats stored empty string as null', () async {
    SharedPreferences.setMockInitialValues({'rn_test_empty': ''});
    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_test_empty');
    expect(await repo.lastSeen(), isNull);
  });
}
