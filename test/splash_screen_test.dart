/// CI #6 close — smoke coverage for the launch splash. The screen
/// triggers a Timer-driven navigator push after 1.4s; we don't
/// settle that here (it would trip MissingPluginException), but
/// the brand row + scale animation must paint on the first frame
/// or the cold-start UX degrades to a white flash.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/splash/splash_screen.dart';

void main() {
  testWidgets('renders the brand row on the first frame', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SplashScreen(),
        // The screen fires a Timer-driven Navigator.pushReplacementNamed
        // to /landing after 1.4s. Provide a stub so the navigator
        // settles cleanly instead of asserting "no generator for route".
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(body: Text('STUB ${settings.name}')),
        ),
      ),
    );
    await tester.pump();

    // Brand wordmark — regression here would mean the splash failed
    // to wire the brand asset.
    expect(find.text('PsyClinicAI'), findsOneWidget);

    // Drain the Timer-driven push so the binding does not complain
    // about a pending timer when the test exits.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('STUB /landing'), findsOneWidget);
  });
}
