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
      return const Center(child: Text('Henüz işlem bulunmuyor'));
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
              backgroundColor: t.typeColor.withOpacity(0.1),
              child: Icon(
                t.isIncome ? Icons.trending_up : Icons.trending_down,
                color: t.typeColor,
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
                    color: t.typeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  t.paymentStatusText,
                  style: TextStyle(
                    color: t.paymentStatusColor,
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
}
