import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'cpt_lookup_service.dart';
import 'icd10_lookup_service.dart';

/// Generates a professional superbill PDF (out-of-network insurance receipt).
class SuperbillPdfService {
  SuperbillPdfService();

  Future<Uint8List> renderBytes(SuperbillData data) async {
    final doc = pw.Document(
      title: 'Superbill ${data.invoiceNumber}',
      author: data.provider.fullName,
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => [
          _buildHeader(data),
          pw.SizedBox(height: 20),
          _buildProviderAndPatient(data),
          pw.SizedBox(height: 18),
          _buildDiagnoses(data),
          pw.SizedBox(height: 14),
          _buildServiceLines(data),
          pw.SizedBox(height: 14),
          _buildTotals(data),
          pw.SizedBox(height: 24),
          _buildSignatureBlock(data),
          pw.SizedBox(height: 18),
          _buildDisclaimer(),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> printOrShare(SuperbillData data) async {
    final bytes = await renderBytes(data);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  // ---- Sections ----------------------------------------------------------

  pw.Widget _buildHeader(SuperbillData d) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SUPERBILL',
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.2,
                    color: const PdfColor.fromInt(0xFF6B46C1))),
            pw.SizedBox(height: 2),
            pw.Text('Out-of-network insurance reimbursement receipt',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _kvPair('Invoice #', d.invoiceNumber),
            _kvPair('Issued', DateFormat('yyyy-MM-dd').format(d.issuedAt)),
            _kvPair('Service Date',
                DateFormat('yyyy-MM-dd').format(d.serviceDate)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildProviderAndPatient(SuperbillData d) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _card('PROVIDER', [
            d.provider.fullName,
            if (d.provider.credentials.isNotEmpty) d.provider.credentials,
            if (d.provider.npi.isNotEmpty) 'NPI: ${d.provider.npi}',
            if (d.provider.taxId.isNotEmpty) 'Tax ID / EIN: ${d.provider.taxId}',
            if (d.provider.addressLine1.isNotEmpty) d.provider.addressLine1,
            if (d.provider.addressLine2.isNotEmpty) d.provider.addressLine2,
            if (d.provider.phone.isNotEmpty) 'Phone: ${d.provider.phone}',
            if (d.provider.email.isNotEmpty) 'Email: ${d.provider.email}',
          ]),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: _card('PATIENT', [
            d.patient.fullName,
            if (d.patient.dob != null)
              'DOB: ${DateFormat('yyyy-MM-dd').format(d.patient.dob!)}',
            if (d.patient.memberId.isNotEmpty) 'Member ID: ${d.patient.memberId}',
            if (d.patient.insurer.isNotEmpty) 'Insurer: ${d.patient.insurer}',
            if (d.patient.addressLine1.isNotEmpty) d.patient.addressLine1,
            if (d.patient.addressLine2.isNotEmpty) d.patient.addressLine2,
          ]),
        ),
      ],
    );
  }

  pw.Widget _buildDiagnoses(SuperbillData d) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle('DIAGNOSES (ICD-10-CM)'),
          pw.SizedBox(height: 6),
          ...d.diagnoses.asMap().entries.map((e) {
            final idx = e.key + 1;
            final dx = e.value;
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Text(
                '$idx. ${dx.code}   ${dx.label}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            );
          }),
        ],
      ),
    );
  }

  pw.Widget _buildServiceLines(SuperbillData d) {
    final headers = ['Date', 'CPT', 'Description', 'Dx Ptr', 'Units', 'Charge'];
    final rows = d.serviceLines
        .map((line) => [
              DateFormat('MM/dd/yyyy').format(line.date),
              line.cpt.code,
              line.cpt.shortLabel,
              line.diagnosisPointers.join(','),
              line.units.toString(),
              '\$${line.totalCharge.toStringAsFixed(2)}',
            ])
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('SERVICES RENDERED'),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          headerStyle: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF6B46C1),
          ),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
          cellAlignments: const {
            3: pw.Alignment.center,
            4: pw.Alignment.center,
            5: pw.Alignment.centerRight,
          },
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1.4),
            2: pw.FlexColumnWidth(4),
            3: pw.FlexColumnWidth(1.2),
            4: pw.FlexColumnWidth(),
            5: pw.FlexColumnWidth(1.6),
          },
        ),
      ],
    );
  }

  pw.Widget _buildTotals(SuperbillData d) {
    final total = d.serviceLines.fold<double>(0, (s, l) => s + l.totalCharge);
    final paid = d.amountPaid;
    final balance = (total - paid).clamp(0, double.infinity).toDouble();
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _totalRow('Total charges', total),
              _totalRow('Amount paid', paid, color: PdfColors.green700),
              pw.Container(height: 6),
              _totalRow('Balance due', balance,
                  bold: true, color: const PdfColor.fromInt(0xFF6B46C1)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureBlock(SuperbillData d) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 1,
                color: PdfColors.grey600,
                margin: const pw.EdgeInsets.only(bottom: 4),
              ),
              pw.Text(
                d.provider.fullName +
                    (d.provider.credentials.isNotEmpty
                        ? ', ${d.provider.credentials}'
                        : ''),
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Provider signature',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
        pw.SizedBox(width: 24),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                height: 1,
                color: PdfColors.grey600,
                margin: const pw.EdgeInsets.only(bottom: 4),
              ),
              pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('Date',
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(
        'This superbill is generated as a draft by PsyClinicAI. The provider is '
        'responsible for verifying all CPT and ICD-10 codes, charges, and patient '
        'information before submitting to an insurer. PsyClinicAI does not file '
        "claims on the provider's behalf.",
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
      ),
    );
  }

  // ---- Helpers -----------------------------------------------------------

  pw.Widget _kvPair(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text('$k: ',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey700)),
            pw.Text(v,
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );

  pw.Widget _card(String title, List<String> lines) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          pw.SizedBox(height: 6),
          ...lines.where((l) => l.isNotEmpty).map((l) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 1),
                child: pw.Text(l, style: const pw.TextStyle(fontSize: 10)),
              )),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.8,
          color: PdfColors.grey700,
        ),
      );

  pw.Widget _totalRow(String label, double value,
      {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(width: 100),
          pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: color)),
          pw.SizedBox(width: 16),
          pw.Container(
            width: 100,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '\$${value.toStringAsFixed(2)}',
              style: pw.TextStyle(
                  fontSize: bold ? 12 : 10,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class SuperbillData {
  SuperbillData({
    required this.invoiceNumber,
    required this.issuedAt,
    required this.serviceDate,
    required this.provider,
    required this.patient,
    required this.diagnoses,
    required this.serviceLines,
    this.amountPaid = 0,
  });

  final String invoiceNumber;
  final DateTime issuedAt;
  final DateTime serviceDate;
  final ProviderInfo provider;
  final PatientInfo patient;
  final List<Icd10Code> diagnoses;
  final List<ServiceLine> serviceLines;
  final double amountPaid;
}

class ProviderInfo {
  ProviderInfo({
    required this.fullName,
    this.credentials = '',
    this.npi = '',
    this.taxId = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phone = '',
    this.email = '',
  });

  final String fullName;
  final String credentials;
  final String npi;
  final String taxId;
  final String addressLine1;
  final String addressLine2;
  final String phone;
  final String email;
}

class PatientInfo {
  PatientInfo({
    required this.fullName,
    this.dob,
    this.memberId = '',
    this.insurer = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
  });

  final String fullName;
  final DateTime? dob;
  final String memberId;
  final String insurer;
  final String addressLine1;
  final String addressLine2;
}

class ServiceLine {
  ServiceLine({
    required this.date,
    required this.cpt,
    required this.units,
    required this.chargePerUnit,
    this.diagnosisPointers = const [1],
  });

  final DateTime date;
  final CptCode cpt;
  final int units;
  final double chargePerUnit;
  final List<int> diagnosisPointers;

  double get totalCharge => chargePerUnit * units;
}
