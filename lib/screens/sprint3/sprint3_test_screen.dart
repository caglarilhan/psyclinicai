import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/sprint3/sprint3_dashboard_widget.dart';
import '../../services/clinical_decision_support_service.dart';
import '../../services/performance_optimization_service.dart';
import '../../services/documentation_service.dart';

class Sprint3TestScreen extends StatelessWidget {
  const Sprint3TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Sprint 3 Test Ekranı'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ClinicalDecisionSupportService()),
          ChangeNotifierProvider(create: (_) => PerformanceOptimizationService()),
          ChangeNotifierProvider(create: (_) => DocumentationService()),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Sprint3DashboardWidget(),
              const SizedBox(height: 24),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Sprint 3 Test Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu ekran Sprint 3 Dashboard Widget\'ının test edilmesi için oluşturulmuştur.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Test Edilen Özellikler:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('✅ CDSS Dashboard Tab'),
            const Text('✅ Performance Dashboard Tab'),
            const Text('✅ Documentation Dashboard Tab'),
            const Text('✅ Summary Dashboard Tab'),
            const Text('✅ Metric Cards ve Animasyonlar'),
            const Text('✅ Service Integration'),
          ],
        ),
      ),
    );
  }
}
