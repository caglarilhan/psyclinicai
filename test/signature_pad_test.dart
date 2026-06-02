import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/widgets/signature_pad.dart';

void main() {
  group('SignaturePadController', () {
    test('starts empty + accumulates strokes', () {
      final c = SignaturePadController();
      expect(c.isEmpty, isTrue);
      c.beginStroke(const Offset(10, 10));
      c.appendPoint(const Offset(20, 12));
      c.appendPoint(const Offset(30, 14));
      expect(c.isNotEmpty, isTrue);
      expect(c.strokes.length, 1);
      expect(c.strokes.first.length, 3);
    });

    test('beginStroke starts a new path even after points', () {
      final c = SignaturePadController()
        ..beginStroke(const Offset(0, 0))
        ..appendPoint(const Offset(1, 1))
        ..beginStroke(const Offset(50, 50));
      expect(c.strokes.length, 2);
    });

    test('clear empties + notifies', () {
      final c = SignaturePadController()
        ..beginStroke(const Offset(0, 0))
        ..appendPoint(const Offset(5, 5));
      var notified = 0;
      c.addListener(() => notified++);
      c.clear();
      expect(c.isEmpty, isTrue);
      expect(notified, 1);
    });

    test('appendPoint without a prior beginStroke still records', () {
      final c = SignaturePadController()..appendPoint(const Offset(1, 1));
      expect(c.strokes.length, 1);
    });
  });

  group('SignaturePad widget', () {
    testWidgets('renders empty hint when controller is empty',
        (tester) async {
      final c = SignaturePadController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SignaturePad(controller: c))),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Sign with Apple Pencil'), findsOneWidget);
    });

    testWidgets('drag generates strokes', (tester) async {
      final c = SignaturePadController();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SignaturePad(controller: c))),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SignaturePad), const Offset(100, 50));
      await tester.pumpAndSettle();
      expect(c.isNotEmpty, isTrue);
    });
  });
}
