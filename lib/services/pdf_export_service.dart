import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFExportService {
  factory PDFExportService() => _instance;
  PDFExportService._internal();
  static final PDFExportService _instance = PDFExportService._internal();

  /// Seans notu PDF'i oluştur
  Future<Uint8List> generateSessionPDF({
    required String clientName,
    required String sessionId,
    required String sessionNotes,
    required String aiSummary,
    required DateTime sessionDate,
    required Duration sessionDuration,
    required String therapistName,
    List<Uint8List>? attachments,
  }) async {
    final pdf = pw.Document();

    // Font yükleme - Sistem fontlarını kullan
    pw.Font? ttf;
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      ttf = pw.Font.ttf(fontData);
    } catch (e) {
      // Font bulunamazsa default font kullan
      debugPrint('Font yüklenemedi, default font kullanılıyor: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Başlık sayfası
          _buildHeaderPage(
            clientName: clientName,
            sessionId: sessionId,
            sessionDate: sessionDate,
            therapistName: therapistName,
            ttf: ttf,
          ),

          // Seans notları sayfası
          _buildSessionNotesPage(
            sessionNotes: sessionNotes,
            sessionDuration: sessionDuration,
            ttf: ttf,
          ),

          // AI özeti sayfası
          if (aiSummary.isNotEmpty)
            _buildAISummaryPage(aiSummary: aiSummary, ttf: ttf),

          // Ekler sayfası (varsa)
          if ((attachments ?? []).isNotEmpty)
            _buildAttachmentsPage(attachments!, ttf),

          // Footer sayfası
          _buildFooterPage(ttf: ttf),
        ],
      ),
    );

    return pdf.save();
  }

  /// Başlık sayfası
  pw.Widget _buildHeaderPage({
    required String clientName,
    required String sessionId,
    required DateTime sessionDate,
    required String therapistName,
    pw.Font? ttf,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        children: [
          // Logo ve başlık
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Container(
                width: 60,
                height: 60,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text('🧠', style: const pw.TextStyle(fontSize: 30)),
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Text(
                'PsyClinic AI',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 30),

          // Ana başlık
          pw.Text(
            'SEANS RAPORU',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),

          pw.SizedBox(height: 40),

          // Bilgi tablosu
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                _buildInfoRow('Danışan Adı:', clientName, ttf),
                _buildInfoRow('Seans ID:', sessionId, ttf),
                _buildInfoRow(
                  'Seans Tarihi:',
                  '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}',
                  ttf,
                ),
                _buildInfoRow(
                  'Seans Saati:',
                  '${sessionDate.hour.toString().padLeft(2, '0')}:${sessionDate.minute.toString().padLeft(2, '0')}',
                  ttf,
                ),
                _buildInfoRow('Terapist:', therapistName, ttf),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Uyarı notu
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              border: pw.Border.all(color: PdfColors.orange),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Text(
              '⚠️ Bu rapor gizlilik kuralları çerçevesinde hazırlanmıştır. '
              'Sadece yetkili sağlık personeli tarafından kullanılmalıdır.',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                color: PdfColors.orange800,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Seans notları sayfası
  pw.Widget _buildSessionNotesPage({
    required String sessionNotes,
    required Duration sessionDuration,
    pw.Font? ttf,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Sayfa başlığı
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              children: [
                pw.Icon(
                  const pw.IconData(0xe3b9),
                  color: PdfColors.blue,
                ), // edit icon
                pw.SizedBox(width: 10),
                pw.Text(
                  'SEANS NOTLARI',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Seans süresi
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Row(
              children: [
                pw.Icon(
                  const pw.IconData(0xe425),
                  color: PdfColors.grey700,
                ), // timer icon
                pw.SizedBox(width: 8),
                pw.Text(
                  'Seans Süresi: ${_formatDuration(sessionDuration)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Notlar
          pw.Text(
            'Seans İçeriği:',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),

          pw.SizedBox(height: 10),

          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Text(
              sessionNotes.isEmpty ? 'Seans notu girilmemiş.' : sessionNotes,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                height: 1.5,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// AI özeti sayfası
  pw.Widget _buildAISummaryPage({required String aiSummary, pw.Font? ttf}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Sayfa başlığı
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              children: [
                pw.Icon(
                  const pw.IconData(0xe3b9),
                  color: PdfColors.green,
                ), // psychology icon
                pw.SizedBox(width: 10),
                pw.Text(
                  'AI DESTEKLİ ÖZET',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // AI özeti
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.green300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Text(
              aiSummary,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                height: 1.4,
                color: PdfColors.black,
              ),
            ),
          ),

          pw.SizedBox(height: 20),

          // AI uyarısı
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.yellow50,
              border: pw.Border.all(color: PdfColors.yellow),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Text(
              '🤖 Bu özet yapay zeka destekli olarak oluşturulmuştur. '
              'Klinik kararlar için terapistin değerlendirmesi gereklidir.',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 11,
                color: PdfColors.orange800,
                fontStyle: pw.FontStyle.italic,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Footer sayfası
  pw.Widget _buildFooterPage({pw.Font? ttf}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey, thickness: 1),

          pw.SizedBox(height: 20),

          // İmza alanı
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Terapist İmzası:',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                ],
              ),

              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Tarih:',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Container(width: 150, height: 1, color: PdfColors.black),
                ],
              ),
            ],
          ),

          pw.SizedBox(height: 40),

          // Alt bilgi
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'PsyClinic AI - Akıllı Klinik Yönetim Sistemi',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Bu rapor ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} tarihinde oluşturulmuştur.',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Onam: Bu raporun oluşturulmasına ilişkin bilgilendirilmiş onam alınmıştır.',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bilgi satırı oluştur
  pw.Widget _buildInfoRow(String label, String value, pw.Font? ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            ': $value',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Ekler sayfası (görseller)
  pw.Widget _buildAttachmentsPage(List<Uint8List> attachments, pw.Font? ttf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: const pw.BoxDecoration(
              color: PdfColors.purple50,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              children: [
                pw.Icon(
                  const pw.IconData(0xe3b6),
                  color: PdfColors.purple,
                ), // attachment icon
                pw.SizedBox(width: 10),
                pw.Text(
                  'EKLER',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.purple,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          ...attachments.map(
            (bytes) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Image(pw.MemoryImage(bytes), height: 300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Süre formatla
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// PDF'i yazdır
  Future<void> printPDF(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  /// PDF'i dosyaya kaydet
  Future<String> savePDFToFile(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  /// PDF'i paylaş — currently a stub. Wire up `share_plus` before
  /// calling this from a UI flow; failing loudly is safer than a
  /// silent no-op that lies about success (audit 2026-06-21 silent-
  /// fail item).
  Future<void> sharePDF(Uint8List pdfBytes, String fileName) async {
    throw UnimplementedError(
      'sharePDF: hook up share_plus in pdf_export_service before calling.',
    );
  }
}
