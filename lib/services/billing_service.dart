import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/billing_models.dart';
import 'audit_log_service.dart';

class BillingService {
  static final BillingService _instance = BillingService._internal();
  factory BillingService() => _instance;
  BillingService._internal();

  Database? _db;
  final _init = Completer<void>();

  Future<void> _ensureInit() async {
    if (_db != null) return;
    if (!_init.isCompleted) {
      try {
        final dir = await getDatabasesPath();
        final path = p.join(dir, 'psyclinic_billing.db');
        _db = await openDatabase(path, version: 1, onCreate: (db, v) async {
          await db.execute('''
            CREATE TABLE invoices (
              id TEXT PRIMARY KEY,
              country TEXT NOT NULL,
              client_name TEXT NOT NULL,
              client_email TEXT NOT NULL,
              issue_date TEXT NOT NULL,
              items_json TEXT NOT NULL,
              currency TEXT NOT NULL,
              note TEXT NOT NULL,
              tr_tax_id TEXT,
              tr_earsiv_type TEXT,
              total_excl REAL NOT NULL,
              total_tax REAL NOT NULL,
              total_incl REAL NOT NULL
            );
          ''');
          await db.execute('''
            CREATE TABLE payment_intents (
              id TEXT PRIMARY KEY,
              invoice_id TEXT NOT NULL,
              provider TEXT NOT NULL,
              status TEXT NOT NULL,
              amount REAL NOT NULL,
              currency TEXT NOT NULL
            );
          ''');
        });
      } finally {
        if (!_init.isCompleted) _init.complete();
      }
    }
    return _init.future;
  }

  Future<void> saveInvoice(Invoice inv) async {
    await _ensureInit();
    final items = inv.items
        .map((e) => {
              'description': e.description,
              'quantity': e.quantity,
              'unitPrice': e.unitPrice,
              'taxRate': e.taxRate,
            })
        .toList();
    await _db!.insert(
      'invoices',
      {
        'id': inv.id,
        'country': inv.country,
        'client_name': inv.clientName,
        'client_email': inv.clientEmail,
        'issue_date': inv.issueDate.toIso8601String(),
        'items_json': jsonEncode(items),
        'currency': inv.currency,
        'note': inv.note,
        'tr_tax_id': inv.trTaxId,
        'tr_earsiv_type': inv.trEArsivType,
        'total_excl': inv.totalExcl,
        'total_tax': inv.totalTax,
        'total_incl': inv.totalIncl,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await AuditLogService().insertLog(
      action: 'billing.invoice.save',
      actor: inv.clientEmail,
      target: inv.clientName + '|' + inv.id,
      metadataJson: jsonEncode({'total': inv.totalIncl, 'currency': inv.currency}),
    );
  }

  Future<List<Invoice>> listInvoices({String? clientEmail, int limit = 100}) async {
    await _ensureInit();
    final where = <String>[];
    final args = <Object?>[];
    if (clientEmail != null) {
      where.add('client_email = ?');
      args.add(clientEmail);
    }
    final rows = await _db!.query('invoices', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args.isEmpty ? null : args, orderBy: 'issue_date DESC', limit: limit);
    return rows.map((m) {
      final items = (jsonDecode(m['items_json'] as String) as List)
          .map((e) => InvoiceItem(description: e['description'] as String, quantity: e['quantity'] as int, unitPrice: (e['unitPrice'] as num).toDouble(), taxRate: (e['taxRate'] as num).toDouble()))
          .toList();
      return Invoice(
        id: m['id'] as String,
        country: m['country'] as String,
        clientName: m['client_name'] as String,
        clientEmail: m['client_email'] as String,
        issueDate: DateTime.parse(m['issue_date'] as String),
        items: items,
        currency: m['currency'] as String,
        note: m['note'] as String,
        trTaxId: m['tr_tax_id'] as String?,
        trEArsivType: m['tr_earsiv_type'] as String?,
      );
    }).toList();
  }

  Future<PaymentIntent> createPaymentIntent({required Invoice invoice, String provider = 'mock'}) async {
    await _ensureInit();
    final intent = PaymentIntent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceId: invoice.id,
      provider: provider,
      status: 'created',
      amount: invoice.totalIncl,
      currency: invoice.currency,
    );
    await _db!.insert('payment_intents', {
      'id': intent.id,
      'invoice_id': intent.invoiceId,
      'provider': intent.provider,
      'status': intent.status,
      'amount': intent.amount,
      'currency': intent.currency,
    });
    await AuditLogService().insertLog(
      action: 'billing.payment_intent.create',
      actor: invoice.clientEmail,
      target: invoice.clientName + '|' + intent.id,
      metadataJson: jsonEncode({'provider': provider, 'amount': invoice.totalIncl}),
    );
    return intent;
  }
}


