import 'package:flutter/material.dart';
import '../../models/finance_models.dart';
import '../../services/finance_service.dart';

class AddTransactionDialog extends StatefulWidget {
  final void Function(FinancialTransaction) onTransactionAdded;
  const AddTransactionDialog({super.key, required this.onTransactionAdded});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.income;
  TransactionCategory _category = TransactionCategory.sessionFee;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni İşlem'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<TransactionType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'İşlem Tipi', border: OutlineInputBorder()),
                items: TransactionType.values.map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(t == TransactionType.income ? 'Gelir' : 'Gider'),
                )).toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TransactionCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                items: TransactionCategory.values.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                )).toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Tutar (₺)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Geçerli bir tutar girin' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Ödeme Yöntemi', border: OutlineInputBorder()),
                items: PaymentMethod.values.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                )).toList(),
                onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
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
    final amount = double.parse(_amountController.text);
    final transaction = FinancialTransaction(
      id: 'new',
      type: _type,
      category: _category,
      amount: amount,
      description: _descriptionController.text,
      date: _date,
      paymentStatus: PaymentStatus.paid,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final added = FinanceService().addTransaction(transaction);
    widget.onTransactionAdded(added);
  }
}
