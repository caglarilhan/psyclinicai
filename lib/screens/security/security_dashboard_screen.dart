import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class SecurityDashboardScreen extends StatelessWidget {
  const SecurityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik & Uyumluluk'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Güvenlik ve uyumluluk bileşenleri yakında eklenecek.'),
      ),
    );
  }
}


