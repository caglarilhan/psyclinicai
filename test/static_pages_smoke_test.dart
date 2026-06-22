/// CI #6 close — render-only smoke coverage for the 15 static
/// marketing/legal pages. These are stateless content pages that
/// the landing footer and AppShell user-menu route into; a single
/// broken layout in one of them would be invisible to the
/// existing test suite because no widget test references them.
///
/// Each test pumps the page, settles one frame, and asserts a
/// canary string. The goal is regression detection, not behaviour
/// coverage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/static/about_page.dart';
import 'package:psyclinicai/screens/static/baa_page.dart';
import 'package:psyclinicai/screens/static/changelog_page.dart';
import 'package:psyclinicai/screens/static/compare_page.dart';
import 'package:psyclinicai/screens/static/contact_page.dart';
import 'package:psyclinicai/screens/static/dpa_page.dart';
import 'package:psyclinicai/screens/static/faq_page.dart';
import 'package:psyclinicai/screens/static/not_found_page.dart';
import 'package:psyclinicai/screens/static/press_page.dart';
import 'package:psyclinicai/screens/static/pricing_page.dart';
import 'package:psyclinicai/screens/static/privacy_page.dart';
import 'package:psyclinicai/screens/static/roadmap_page.dart';
import 'package:psyclinicai/screens/static/security_page.dart';
import 'package:psyclinicai/screens/static/status_page.dart';
import 'package:psyclinicai/screens/static/tos_page.dart';

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  // Tall viewport: legal pages overflow the default 600x800 in tests.
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pump();
}

void main() {
  testWidgets('about page renders', (tester) async {
    await _pumpPage(tester, const AboutPage());
    expect(find.text('PsyClinicAI'), findsWidgets);
  });

  testWidgets('changelog page renders', (tester) async {
    await _pumpPage(tester, const ChangelogPage());
    expect(find.textContaining('Changelog'), findsWidgets);
  });

  testWidgets('compare page renders', (tester) async {
    await _pumpPage(tester, const ComparePage());
    expect(find.textContaining('PsyClinicAI'), findsWidgets);
  });

  testWidgets('contact page renders', (tester) async {
    await _pumpPage(tester, const ContactPage());
    expect(find.textContaining('Contact'), findsWidgets);
  });

  testWidgets('faq page renders', (tester) async {
    await _pumpPage(tester, const FaqPage());
    // FaqPage title is "Answers we get every week." — check the
    // semantic prefix rather than the literal FAQ acronym.
    expect(find.textContaining('Answers'), findsWidgets);
  });

  testWidgets('not-found page renders', (tester) async {
    await _pumpPage(tester, const NotFoundPage());
    expect(find.textContaining('404'), findsWidgets);
  });

  testWidgets('press page renders', (tester) async {
    await _pumpPage(tester, const PressPage());
    expect(find.textContaining('Press'), findsWidgets);
  });

  testWidgets('pricing page renders', (tester) async {
    await _pumpPage(tester, const PricingPage());
    // Title copy lives in lib/screens/static/pricing_page.dart:
    // "Simple pricing. No per-patient surprise."
    expect(find.textContaining('Simple pricing'), findsWidgets);
  });

  testWidgets('privacy page renders', (tester) async {
    await _pumpPage(tester, const PrivacyPage());
    expect(find.textContaining('Privacy'), findsWidgets);
  });

  testWidgets('roadmap page renders', (tester) async {
    await _pumpPage(tester, const RoadmapPage());
    expect(find.textContaining('Roadmap'), findsWidgets);
  });

  testWidgets('security page renders', (tester) async {
    await _pumpPage(tester, const SecurityPage());
    expect(find.textContaining('Security'), findsWidgets);
  });

  testWidgets('status page renders', (tester) async {
    await _pumpPage(tester, const StatusPage());
    // StatusPage flips between "All systems operational." and
    // "Investigating issue." depending on _allGreen — assert on the
    // common substring "operational" / "Investigating" pair.
    final allGreen = find.textContaining('operational');
    final issue = find.textContaining('Investigating');
    expect(
      tester.any(allGreen) || tester.any(issue),
      isTrue,
      reason: 'StatusPage must render one of the two title variants.',
    );
  });

  testWidgets('tos page renders', (tester) async {
    await _pumpPage(tester, const TosPage());
    expect(find.textContaining('Terms'), findsWidgets);
  });

  testWidgets('baa page renders (HIPAA legal)', (tester) async {
    await _pumpPage(tester, const BaaPage());
    expect(find.textContaining('BAA'), findsWidgets);
  });

  testWidgets('dpa page renders (GDPR legal)', (tester) async {
    await _pumpPage(tester, const DpaPage());
    expect(find.textContaining('DPA'), findsWidgets);
  });
}
