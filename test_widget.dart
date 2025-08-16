import 'package:flutter/material.dart';
import 'lib/screens/medication_guide/medication_guide_screen.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test App',
      home: MedicationGuideScreen(),
    );
  }
}
