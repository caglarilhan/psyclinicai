import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/l10n/app_localizations.dart';
import 'package:psyclinicai/screens/patient_portal/portal_landing_screen.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        '/portal': (_) => const PortalLandingScreen(),
        '/dashboard': (_) =>
            const Scaffold(body: Center(child: Text('dashboard-stub'))),
      },
      initialRoute: '/portal',
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('PortalLandingScreen', () {
    testWidgets(
        'no clinician session — patient view renders transparency cards',
        (tester) async {
      // FirebaseAuthService.instance.profile is null when Firebase has
      // not been bootstrapped (test runtime). That maps to the
      // "patient view" branch of the gate.
      await _pump(tester);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('First-visit questionnaire'), findsOneWidget);
      expect(find.text('Progress questionnaires'), findsOneWidget);
      expect(find.text('Upcoming sessions'), findsOneWidget);
      expect(find.text('Request your data'), findsOneWidget);
      expect(find.text('Close your account'), findsOneWidget);

      // The legal-rights chips should surface so the patient learns
      // which GDPR article each card maps to.
      expect(find.textContaining('GDPR Art. 7'), findsOneWidget);
      expect(find.textContaining('GDPR Art. 17'), findsOneWidget);
    });
  });
}
