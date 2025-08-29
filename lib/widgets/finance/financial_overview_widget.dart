import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class FinancialOverviewWidget extends StatelessWidget {
  final FinancialMetrics metrics;
  const FinancialOverviewWidget({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final canViewAmounts = _hasFullFinanceAccess();
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Toplam Gelir', canViewAmounts ? '₺${metrics.totalIncome.toStringAsFixed(2)}' : '₺****', Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Toplam Gider', canViewAmounts ? '₺${metrics.totalExpenses.toStringAsFixed(2)}' : '₺****', Colors.red)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Net Kar', canViewAmounts ? '₺${metrics.netProfit.toStringAsFixed(2)}' : '₺****', metrics.netProfit >= 0 ? Colors.green : Colors.red)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Kar Marjı', metrics.profitMarginText, AppTheme.primaryColor)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('İşlem Sayısı', '${metrics.totalTransactions}', Colors.blueGrey)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Gecikmiş Fatura', '${metrics.overdueInvoices}', Colors.orange)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasFullFinanceAccess() {
    // Basit kontrol: admin veya finance role'ü tam görüntüler
    final roles = AppConstants.userRoles.map((e) => e.toLowerCase()).toList();
    return roles.contains('admin') || roles.contains('finance') || roles.contains('owner');
  }
}
