import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/us_billing_models.dart';

class USBillingDashboardWidget extends StatelessWidget {
  const USBillingDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Claims Durumu', Icons.receipt_long),
          const SizedBox(height: 12),
          _summaryRow(context),
          const SizedBox(height: 24),
          _sectionHeader('Ödeme Dağılımı', Icons.pie_chart),
          const SizedBox(height: 12),
          SizedBox(height: 240, child: _paymentPie()),
          const SizedBox(height: 24),
          _sectionHeader('CPT Kullanımı', Icons.bar_chart),
          const SizedBox(height: 12),
          SizedBox(height: 240, child: _cptBar()),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _summaryRow(BuildContext context) {
    Widget card(String title, String value, Color color, IconData icon) {
      return Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        card('Submitted', '128', Colors.blue, Icons.send),
        card('Paid', '104', Colors.green, Icons.payments),
        card('Denied', '12', Colors.red, Icons.block),
      ],
    );
  }

  Widget _paymentPie() {
    final sections = [
      PieChartSectionData(value: 65, color: Colors.green, title: 'Paid'),
      PieChartSectionData(value: 25, color: Colors.orange, title: 'Patient'),
      PieChartSectionData(value: 10, color: Colors.red, title: 'Denied'),
    ];
    return PieChart(PieChartData(sections: sections, sectionsSpace: 2, centerSpaceRadius: 32));
  }

  Widget _cptBar() {
    final data = {'90834': 40.0, '90837': 60.0, '99214': 25.0, '90791': 15.0};
    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
          final keys = data.keys.toList();
          if (v.toInt() >= 0 && v.toInt() < keys.length) return Text(keys[v.toInt()]);
          return const SizedBox.shrink();
        })),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: data.values.toList().asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: e.value, width: 20, color: Colors.blue)
      ])).toList(),
    ));
  }
}


