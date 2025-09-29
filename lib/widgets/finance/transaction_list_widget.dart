import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../utils/date_utils.dart';

class TransactionListWidget extends StatelessWidget {
  final List<FinancialTransaction> transactions;
  final VoidCallback onTransactionAdded;
  final VoidCallback onTransactionUpdated;
  final VoidCallback onTransactionDeleted;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.onTransactionAdded,
    required this.onTransactionUpdated,
    required this.onTransactionDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.account_balance_wallet, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Henüz işlem bulunmuyor', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final t = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _typeColor(t).withOpacity(0.1),
              child: Icon(
                t.isIncome ? Icons.trending_up : Icons.trending_down,
                color: _typeColor(t),
              ),
            ),
            title: Text(t.description),
            subtitle: Text('${t.categoryText} • ${AppDateUtils.formatDate(t.date)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${t.isIncome ? '+' : '-'}₺${t.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _typeColor(t),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  t.paymentStatusText,
                  style: TextStyle(
                    color: _paymentStatusColor(t.paymentStatus),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Color _typeColor(FinancialTransaction t) {
    return t.isIncome ? const Color(0xFF10B981) : const Color(0xFFEF4444);
  }

  Color _paymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Color(0xFF10B981);
      case PaymentStatus.pending:
        return const Color(0xFFF59E0B);
      case PaymentStatus.overdue:
        return const Color(0xFFEF4444);
      case PaymentStatus.cancelled:
        return const Color(0xFF9CA3AF);
      case PaymentStatus.refunded:
        return const Color(0xFF3B82F6);
    }
  }
}
