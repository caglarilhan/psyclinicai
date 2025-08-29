import 'package:flutter/material.dart';
import '../../models/finance_models.dart';

class FinancialChartsWidget extends StatelessWidget {
  final FinancialMetrics? metrics;
  final List transactions;
  final List invoices;

  const FinancialChartsWidget({
    super.key,
    required this.metrics,
    required this.transactions,
    required this.invoices,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PlaceholderChart(title: 'Aylık Gelir-Gider Trendleri'),
          SizedBox(height: 16),
          _PlaceholderChart(title: 'Kategori Bazında Dağılım'),
          SizedBox(height: 16),
          _PlaceholderChart(title: 'Fatura Durumu Dağılımı'),
        ],
      ),
    );
  }
}

class _PlaceholderChart extends StatelessWidget {
  final String title;
  const _PlaceholderChart({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
