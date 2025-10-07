import 'package:flutter/material.dart';
import '../../models/billing_models.dart';
import '../../services/billing_service.dart';
import '../../utils/theme.dart';

class InvoiceForm extends StatefulWidget {
  const InvoiceForm({super.key});

  @override
  State<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends State<InvoiceForm> {
  final _service = BillingService();
  final _country = TextEditingController(text: 'TR');
  final _clientName = TextEditingController();
  final _clientEmail = TextEditingController();
  final _currency = TextEditingController(text: 'TRY');
  final _note = TextEditingController();
  final _trTaxId = TextEditingController();
  final _trType = TextEditingController(text: 'TEMEL');

  final _desc = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _price = TextEditingController(text: '100');
  final _tax = TextEditingController(text: '0.20');

  final List<InvoiceItem> _items = [];
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fatura Oluştur', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _country, decoration: const InputDecoration(labelText: 'Ülke (TR/US/EU)'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _currency, decoration: const InputDecoration(labelText: 'Para Birimi (TRY/USD/EUR)'))),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _clientName, decoration: const InputDecoration(labelText: 'Müşteri Adı')),
          const SizedBox(height: 8),
          TextField(controller: _clientEmail, decoration: const InputDecoration(labelText: 'Müşteri E-posta')),
          const SizedBox(height: 8),
          if (_country.text.toUpperCase() == 'TR') ...[
            TextField(controller: _trTaxId, decoration: const InputDecoration(labelText: 'TCKN/VKN')),
            const SizedBox(height: 8),
            TextField(controller: _trType, decoration: const InputDecoration(labelText: 'e-Arşiv Türü (TEMEL/TICARI)')),
          ],
          const SizedBox(height: 12),
          Text('Kalem Ekle', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Açıklama'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _qty, decoration: const InputDecoration(labelText: 'Adet'))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _price, decoration: const InputDecoration(labelText: 'Birim Fiyat'))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _tax, decoration: const InputDecoration(labelText: 'Vergi Oranı (0.20)'))),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text('Ekle'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _items.map((e) => Chip(label: Text('${e.description} (${e.quantity}x)'))).toList()),
          const SizedBox(height: 12),
          TextField(controller: _note, maxLines: 3, decoration: const InputDecoration(labelText: 'Not')),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _items.isEmpty || _saving ? null : _saveInvoice,
              icon: _saving ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.receipt_long),
              label: Text(_saving ? 'Kaydediliyor...' : 'Fatura Kaydet + Ödeme Başlat'),
            ),
          )
        ],
      ),
    );
  }

  void _addItem() {
    final q = int.tryParse(_qty.text.trim()) ?? 1;
    final price = double.tryParse(_price.text.trim()) ?? 0;
    final tax = double.tryParse(_tax.text.trim()) ?? 0;
    setState(() {
      _items.add(InvoiceItem(description: _desc.text.trim(), quantity: q, unitPrice: price, taxRate: tax));
    });
    _desc.clear();
  }

  Future<void> _saveInvoice() async {
    setState(() => _saving = true);
    try {
      final inv = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        country: _country.text.trim().toUpperCase(),
        clientName: _clientName.text.trim(),
        clientEmail: _clientEmail.text.trim(),
        issueDate: DateTime.now(),
        items: _items,
        currency: _currency.text.trim().toUpperCase(),
        note: _note.text.trim(),
        trTaxId: _country.text.trim().toUpperCase() == 'TR' ? _trTaxId.text.trim() : null,
        trEArsivType: _country.text.trim().toUpperCase() == 'TR' ? _trType.text.trim() : null,
      );
      await _service.saveInvoice(inv);
      final intent = await _service.createPaymentIntent(invoice: inv, provider: inv.country == 'TR' ? 'iyzico' : 'stripe');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fatura kaydedildi. Ödeme intent: ${intent.id} (${intent.provider})')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
