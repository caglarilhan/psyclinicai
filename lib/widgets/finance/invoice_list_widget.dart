import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../utils/date_utils.dart';
import 'package:share_plus/share_plus.dart';

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Henüz fatura bulunmuyor', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
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
              backgroundColor: _invoiceStatusColor(i.status).withOpacity(0.1),
              child: Icon(Icons.receipt, color: _invoiceStatusColor(i.status)),
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
                    color: _invoiceStatusColor(i.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _invoiceStatusText(i.status),
                    style: TextStyle(
                      fontSize: 12,
                      color: _invoiceStatusColor(i.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {},
            // Actions: PDF/Share
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'PDF (stub)',
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () {
                    // PDF export stub
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF export yakında (stub)')),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Paylaş',
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    Share.share('Fatura ${i.invoiceNumber} | Toplam: ₺${i.totalAmount.toStringAsFixed(2)} | Vade: ${AppDateUtils.formatDate(i.dueDate)}');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Color _invoiceStatusColor(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.paid:
      return const Color(0xFF10B981);
    case InvoiceStatus.overdue:
      return const Color(0xFFEF4444);
    case InvoiceStatus.sent:
      return const Color(0xFF3B82F6);
    case InvoiceStatus.cancelled:
      return const Color(0xFF9CA3AF);
    case InvoiceStatus.draft:
      return const Color(0xFFF59E0B);
  }
}

String _invoiceStatusText(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.paid:
      return 'Ödendi';
    case InvoiceStatus.overdue:
      return 'Gecikmiş';
    case InvoiceStatus.sent:
      return 'Gönderildi';
    case InvoiceStatus.cancelled:
      return 'İptal Edildi';
    case InvoiceStatus.draft:
      return 'Taslak';
  }
}
