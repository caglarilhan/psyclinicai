import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AdvancedAnalyticsDashboardScreen extends StatefulWidget {
  const AdvancedAnalyticsDashboardScreen({super.key});

  @override
  State<AdvancedAnalyticsDashboardScreen> createState() => _AdvancedAnalyticsDashboardScreenState();
}

class _AdvancedAnalyticsDashboardScreenState extends State<AdvancedAnalyticsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gelişmiş Analitik Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Gelişmiş Analitik bileşenleri yakında eklenecek.'),
      ),
    );
  }
}
