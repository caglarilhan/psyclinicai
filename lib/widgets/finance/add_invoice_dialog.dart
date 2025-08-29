import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../services/finance_service.dart';

class AddInvoiceDialog extends StatefulWidget {
  final void Function(Invoice) onInvoiceAdded;
  const AddInvoiceDialog({super.key, required this.onInvoiceAdded});

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _totalController = TextEditingController();
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  @override
  void dispose() {
    _clientController.dispose();
    _invoiceNumberController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Fatura'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _invoiceNumberController,
                decoration: const InputDecoration(labelText: 'Fatura No', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clientController,
                decoration: const InputDecoration(labelText: 'Müşteri ID', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: 'Toplam (₺)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Geçerli bir tutar girin' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('İptal')),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Ekle'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final total = double.parse(_totalController.text);
    final invoice = Invoice(
      id: 'new',
      clientId: _clientController.text,
      therapistId: 'therapist_001',
      invoiceNumber: _invoiceNumberController.text,
      issueDate: _issueDate,
      dueDate: _dueDate,
      subtotal: total,
      taxAmount: 0.0,
      totalAmount: total,
      status: InvoiceStatus.sent,
      items: const [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final added = FinanceService().addInvoice(invoice);
    widget.onInvoiceAdded(added);
  }
}
