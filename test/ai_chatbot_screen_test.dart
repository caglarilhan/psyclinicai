/// CI #6 close — smoke coverage for the AI Copilot chatbot screen.
/// Sits inside AppShell with a Send button + suggestion chips; a
/// render failure would silently break the clinician's primary
/// quick-question surface.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/ai_chatbot/ai_chatbot_screen.dart';

void main() {
  testWidgets('renders the AppShell + Send button on first frame', (
    tester,
  ) async {
    // Tall viewport — the empty-state suggestions column overflows
    // on the default 600x800 test viewport. Wider + taller mirrors
    // the desktop breakpoint where the screen is designed for.
    await tester.binding.setSurfaceSize(const Size(1400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: AIChatbotScreen()),
    );
    await tester.pumpAndSettle();

    // Title surfaces in the AppShell page header + the breadcrumb.
    expect(find.text('AI Copilot'), findsWidgets);
    // The compose input → Send button is the primary CTA on this
    // screen; we only check for presence (not for tap behaviour,
    // which needs a real ChatService mock to be meaningful).
    expect(find.byIcon(Icons.send), findsOneWidget);
  });
}
