import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/billing_models.dart';

class InvoicePDFService {
  Future<Uint8List> generate(Invoice inv) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Padding(
        padding: const pw.EdgeInsets.all(24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            pw.SizedBox(height: 8),
            pw.Text('Issue: ${inv.issueDate.toLocal()}  •  Country: ${inv.country}  •  Currency: ${inv.currency}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 16),
            pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(inv.clientName),
            pw.Text(inv.clientEmail),
            if (inv.trTaxId != null) pw.Text('Tax ID: ${inv.trTaxId}'),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Unit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Tax', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...inv.items.map((it) => pw.TableRow(children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(it.description)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${it.quantity}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(it.unitPrice.toStringAsFixed(2))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('${(it.taxRate * 100).toStringAsFixed(0)}%')),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(it.lineTotalIncl.toStringAsFixed(2))),
                    ])),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Subtotal: ${inv.totalExcl.toStringAsFixed(2)}'),
                pw.Text('Tax: ${inv.totalTax.toStringAsFixed(2)}'),
                pw.Text('Total: ${inv.totalIncl.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ])
            ]),
            pw.SizedBox(height: 16),
            pw.Text(inv.note),
          ],
        ),
      ),
    ));
    return pdf.save();
  }
}


