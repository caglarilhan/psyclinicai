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

  testWidgets('tos page carries the Demo/BYOK/Pro tier disclosure', (
    tester,
  ) async {
    await _pumpPage(tester, const TosPage());
    expect(
      find.textContaining('Demo tier'),
      findsWidgets,
      reason:
          'ToS section 3 discloses that Demo tier calls Groq/Gemini and does '
          'not process PHI — required for the BAA delegation posture',
    );
    expect(
      find.textContaining('BYOK'),
      findsWidgets,
      reason: 'ToS must name the BYOK tier so BAA delegation is unambiguous',
    );
  });

  testWidgets('privacy page discloses Groq + Gemini sub-processors', (
    tester,
  ) async {
    await _pumpPage(tester, const PrivacyPage());
    expect(
      find.textContaining('Groq'),
      findsWidgets,
      reason: 'Privacy §4 must name Groq as a Demo-tier sub-processor',
    );
    expect(
      find.textContaining('Gemini'),
      findsWidgets,
      reason: 'Privacy §4 must name Gemini as a Demo-tier sub-processor',
    );
  });

  testWidgets('baa page renders (HIPAA legal)', (tester) async {
    await _pumpPage(tester, const BaaPage());
    expect(find.textContaining('BAA'), findsWidgets);
  });

  testWidgets('baa page documents BYOK BAA delegation', (tester) async {
    await _pumpPage(tester, const BaaPage());
    expect(
      find.textContaining('BYOK'),
      findsWidgets,
      reason:
          'BAA page Subcontractors section must explain that BYOK-tier '
          'clinicians sign the upstream Anthropic BAA directly',
    );
  });

  testWidgets('dpa page renders (GDPR legal)', (tester) async {
    await _pumpPage(tester, const DpaPage());
    expect(find.textContaining('DPA'), findsWidgets);
  });

  testWidgets('dpa page lists Demo-tier LLM sub-processors', (tester) async {
    await _pumpPage(tester, const DpaPage());
    expect(
      find.textContaining('Groq'),
      findsWidgets,
      reason: 'DPA sub-processor summary must name Groq',
    );
    expect(
      find.textContaining('Gemini'),
      findsWidgets,
      reason: 'DPA sub-processor summary must name Gemini',
    );
  });
}
