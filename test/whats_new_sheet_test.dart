/// Coverage for the in-app "What's new" sheet: renders the
/// release metadata, lists every bullet, and the "Got it" button
/// stamps the version into [ReleaseNotesSeenRepository] so the
/// sheet does not re-pop on the next dashboard mount.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/data/release_notes_seen_repository.dart';
import 'package:psyclinicai/services/release_notes.dart';
import 'package:psyclinicai/widgets/whats_new_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const fakeRelease = Release(
    version: '0.9.9',
    date: '2026-07-01',
    tag: 'Test release',
    bullets: ['First wonder', 'Second wonder'],
  );

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Material(child: child)),
  );

  testWidgets('renders the release header + every bullet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_wns_render');
    await tester.pumpWidget(
      wrap(WhatsNewSheet(release: fakeRelease, repo: repo)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('What’s new in v0.9.9'), findsOneWidget);
    expect(find.textContaining('Test release'), findsOneWidget);
    expect(find.text('First wonder'), findsOneWidget);
    expect(find.text('Second wonder'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('Got it tap marks the version as seen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = ReleaseNotesSeenRepository(storageKey: 'rn_wns_dismiss');
    await tester.pumpWidget(
      wrap(WhatsNewSheet(release: fakeRelease, repo: repo)),
    );
    await tester.pumpAndSettle();

    expect(await repo.lastSeen(), isNull);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(await repo.lastSeen(), '0.9.9');
  });

  group('ReleaseNotes canonical ledger', () {
    test('latest matches releases.first', () {
      expect(ReleaseNotes.latest.version, ReleaseNotes.releases.first.version);
    });

    test('every release ships at least one bullet', () {
      for (final r in ReleaseNotes.releases) {
        expect(r.bullets, isNotEmpty, reason: 'v${r.version} has no bullets');
      }
    });

    test('every version string is unique', () {
      final versions = ReleaseNotes.releases.map((r) => r.version).toList();
      expect(versions.toSet().length, versions.length);
    });
  });
}
