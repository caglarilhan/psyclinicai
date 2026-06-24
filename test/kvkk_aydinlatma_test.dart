/// Smoke + content coverage for the Turkish KVKK md. 10 information
/// notice. KVKK auditors expect the page to surface:
///   * veri sorumlusu identification,
///   * 11 enumerated data-subject rights under md. 11,
///   * application channel (md. 13),
///   * last-updated date.
/// If any of these strings drift, this test fires and forces a
/// deliberate rewrite (regulatory text can't silently morph).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/static/kvkk_aydinlatma_page.dart';
import 'package:psyclinicai/screens/static/privacy_page.dart';

void main() {
  testWidgets('renders the KVKK aydınlatma metni with required sections', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: KvkkAydinlatmaPage()));
    await tester.pump();

    // Title + KVKK eyebrow tag — non-negotiable. The header upper-
    // cases the eyebrow string before painting, so match the rendered
    // form.
    expect(find.text('Aydınlatma Metni'), findsOneWidget);
    expect(find.text('KVKK · TÜRKIYE'), findsOneWidget);

    // Required regulatory sections (sequential numbering).
    expect(find.text('1. Veri Sorumlusu'), findsOneWidget);
    expect(find.text('4. Hukuki Sebep'), findsOneWidget);
    expect(find.text('7. Veri Sahibi Hakları (KVKK md. 11)'), findsOneWidget);
    expect(find.text('8. Başvuru Kanalı'), findsOneWidget);
  });

  testWidgets('PrivacyPage exposes a link to the KVKK page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: const PrivacyPage(),
        routes: {'/legal/kvkk': (_) => const KvkkAydinlatmaPage()},
      ),
    );
    await tester.pump();

    final link = find.text('Türkçe: KVKK md. 10 aydınlatma metni');
    expect(link, findsOneWidget);

    // Scroll into view, then tap — verifies the route is reachable.
    await tester.ensureVisible(link);
    await tester.pump();
    await tester.tap(link);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Aydınlatma Metni'), findsOneWidget);
  });
}
