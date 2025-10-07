class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double taxRate; // KDV/VAT e.g. 0.20

  const InvoiceItem({required this.description, required this.quantity, required this.unitPrice, required this.taxRate});

  double get lineTotalExcl => quantity * unitPrice;
  double get taxAmount => lineTotalExcl * taxRate;
  double get lineTotalIncl => lineTotalExcl + taxAmount;
}

class Invoice {
  final String id;
  final String country; // TR/US/EU/...
  final String clientName;
  final String clientEmail;
  final DateTime issueDate;
  final List<InvoiceItem> items;
  final String currency; // TRY/USD/EUR
  final String note;

  // TR e-Arşiv alanları (opsiyonel)
  final String? trTaxId; // TCKN/VKN
  final String? trEArsivType; // e.g. TEMEL/TICARI (placeholder)

  const Invoice({
    required this.id,
    required this.country,
    required this.clientName,
    required this.clientEmail,
    required this.issueDate,
    required this.items,
    required this.currency,
    required this.note,
    this.trTaxId,
    this.trEArsivType,
  });

  double get totalExcl => items.fold(0.0, (p, e) => p + e.lineTotalExcl);
  double get totalTax => items.fold(0.0, (p, e) => p + e.taxAmount);
  double get totalIncl => items.fold(0.0, (p, e) => p + e.lineTotalIncl);
}

class PaymentIntent {
  final String id;
  final String invoiceId;
  final String provider; // stripe/iyzico/mock
  final String status; // created/approved/failed
  final double amount;
  final String currency;

  const PaymentIntent({required this.id, required this.invoiceId, required this.provider, required this.status, required this.amount, required this.currency});
}


