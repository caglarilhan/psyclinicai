import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/main.dart';

void main() {
  testWidgets('App boots and shows MaterialApp', (tester) async {
    await tester.pumpWidget(const PsyClinicAIApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}


