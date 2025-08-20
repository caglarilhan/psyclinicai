import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/eu_health_system_models.dart';

class EUEPrescriptionDashboardWidget extends StatelessWidget {
  const EUEPrescriptionDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ePrescription Durumu', Icons.local_pharmacy),
          const SizedBox(height: 12),
          _summaryRow(context),
          const SizedBox(height: 24),
          _sectionHeader('Ülke Bazlı Kullanım', Icons.public),
          const SizedBox(height: 12),
          SizedBox(height: 240, child: _countryBar()),
          const SizedBox(height: 24),
          _sectionHeader('SNOMED → ICD-10 Eşlemeleri', Icons.swap_horiz),
          const SizedBox(height: 12),
          _mappingList(),
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
        card('Aktif Ülkeler', '8', Colors.blue, Icons.public),
        card('eRecete Oranı', '%72', Colors.green, Icons.timeline),
        card('Eşleme Kapsamı', '%89', Colors.purple, Icons.integration_instructions),
      ],
    );
  }

  Widget _countryBar() {
    final data = {'DE': 80.0, 'FR': 70.0, 'ES': 65.0, 'IT': 60.0, 'NL': 75.0};
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
        BarChartRodData(toY: e.value, width: 20, color: Colors.purple)
      ])).toList(),
    ));
  }

  Widget _mappingList() {
    final mappings = [
      {'snomed': '35489007', 'icd10': 'F32.1', 'display': 'Depressive episode'},
      {'snomed': '300895004', 'icd10': 'F41.1', 'display': 'Generalized anxiety disorder'},
      {'snomed': '19160005', 'icd10': 'F20.0', 'display': 'Paranoid schizophrenia'},
    ];
    return Card(
      child: Column(children: mappings.map((m) => ListTile(
        leading: const Icon(Icons.code),
        title: Text('${m['snomed']} → ${m['icd10']}'),
        subtitle: Text(m['display']!),
      )).toList()),
    );
  }
}


