import 'package:flutter/material.dart';
import 'screens/landing/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PsyClinicAIWebApp());
}

class PsyClinicAIWebApp extends StatelessWidget {
  const PsyClinicAIWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsyClinic AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E40AF))),
      home: const LandingScreen(),
      routes: {
        '/landing': (context) => const LandingScreen(),
      },
    );
  }
}



