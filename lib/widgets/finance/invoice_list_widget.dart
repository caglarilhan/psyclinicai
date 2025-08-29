import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../utils/date_utils.dart';

class InvoiceListWidget extends StatelessWidget {
  final List<Invoice> invoices;
  final VoidCallback onInvoiceAdded;
  final VoidCallback onInvoiceUpdated;
  final VoidCallback onInvoiceDeleted;

  const InvoiceListWidget({
    super.key,
    required this.invoices,
    required this.onInvoiceAdded,
    required this.onInvoiceUpdated,
    required this.onInvoiceDeleted,
  });

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return const Center(child: Text('Henüz fatura bulunmuyor'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final i = invoices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: i.statusColor.withOpacity(0.1),
              child: Icon(Icons.receipt, color: i.statusColor),
            ),
            title: Text(i.invoiceNumber),
            subtitle: Text('Müşteri: ${i.clientId} • Vade: ${AppDateUtils.formatDate(i.dueDate)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₺${i.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: i.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    i.statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: i.statusColor,
                      fontWeight: FontWeight.w500,
                    ),
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
