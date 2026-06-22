/// CI #6 close — render smoke coverage for the trust-center
/// pages (HIPAA / GDPR collateral surface). These are the legal-
/// review entry points clinics ask procurement for; a broken
/// render here is high-touch for sales.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/screens/trust/incident_response_screen.dart';
import 'package:psyclinicai/screens/trust/security_controls_screen.dart';
import 'package:psyclinicai/screens/trust/subprocessors_screen.dart';
import 'package:psyclinicai/screens/trust/trust_center_screen.dart';
import 'package:psyclinicai/services/ai/rag_service.dart';

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  await tester.binding.setSurfaceSize(const Size(1400, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  // TrustCenterScreen embeds a RagStatusCard which expects
  // Provider<RagService> in scope. Inject a disabled instance — the
  // card will render its "RAG offline" branch, which is exactly the
  // render path we want to smoke-test.
  await tester.pumpWidget(
    Provider<RagService>.value(
      // `RagService()` with no client is the disabled instance — the
      // RagStatusCard renders its "RAG offline" branch, exactly the
      // path we want to smoke-test here.
      value: RagService(),
      child: MaterialApp(home: page),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('trust center renders the section catalog', (tester) async {
    await _pumpPage(tester, const TrustCenterScreen());
    expect(find.text('Trust Center'), findsWidgets);
    // The center indexes the legal + compliance subsections; sample
    // a few to detect a layout regression that drops one.
    expect(find.textContaining('HIPAA BAA'), findsWidgets);
    expect(find.textContaining('GDPR DPA'), findsWidgets);
    expect(find.textContaining('Audit log'), findsWidgets);
  });

  testWidgets('subprocessors page renders', (tester) async {
    await _pumpPage(tester, const SubprocessorsScreen());
    expect(find.text('Subprocessors'), findsWidgets);
  });

  testWidgets('security controls page renders', (tester) async {
    await _pumpPage(tester, const SecurityControlsScreen());
    expect(find.textContaining('Security'), findsWidgets);
  });

  testWidgets('incident response page renders', (tester) async {
    await _pumpPage(tester, const IncidentResponseScreen());
    expect(find.textContaining('Incident'), findsWidgets);
  });
}
