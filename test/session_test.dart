import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/screens/session/session_screen.dart';

void main() {
  group('SessionScreen Tests', () {
    testWidgets('SessionScreen should display client name in title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      expect(find.text('Test Client'), findsOneWidget);
    });

    testWidgets('SessionScreen should have session notes panel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      expect(find.text('Seans Notu'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('SessionScreen should have AI panel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      expect(find.text('AI Asistan'), findsOneWidget);
    });

    testWidgets('SessionScreen should have client info panel', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      expect(find.text('Danışan Bilgileri'), findsOneWidget);
    });

    testWidgets('SessionScreen should start session automatically', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      // Wait for session to start
      await tester.pumpAndSettle();

      // Check if session is active
      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('SessionScreen should allow typing notes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the text field and type
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test session notes');
      await tester.pump();

      expect(find.text('Test session notes'), findsOneWidget);
    });

    testWidgets('SessionScreen should show AI summary after generation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionScreen(
            sessionId: 'test_session_001',
            clientId: 'test_client_001',
            clientName: 'Test Client',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type some notes first
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test session notes');
      await tester.pump();

      // Find and tap the AI refresh button
      final aiButton = find.byIcon(Icons.refresh);
      await tester.tap(aiButton);
      await tester.pump();

      // Wait for AI processing
      await tester.pump(const Duration(seconds: 3));

      // Check if AI summary is displayed
      expect(find.text('AI özeti oluşturuldu'), findsOneWidget);
    });
  });
}
