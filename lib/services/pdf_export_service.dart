import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image/image.dart' as img;
import '../config/env_config.dart';
import 'ai_logger.dart';
import 'ai_performance_monitor.dart';

class PDFExportService {
  static final PDFExportService _instance = PDFExportService._internal();
  factory PDFExportService() => _instance;
  PDFExportService._internal();

  final AILogger _logger = AILogger();
  final AIPerformanceMonitor _performanceMonitor = AIPerformanceMonitor();

  // PDF tema ve stilleri
  static const PdfColor _primaryColor = PdfColor(0.2, 0.4, 0.8);
  static const PdfColor _secondaryColor = PdfColor(0.6, 0.8, 1.0);
  static const PdfColor _accentColor = PdfColor(0.9, 0.6, 0.2);
  static const PdfColor _textColor = PdfColor(0.1, 0.1, 0.1);
  static const PdfColor _lightGray = PdfColor(0.9, 0.9, 0.9);

  // Seans notu PDF'i oluştur
  Future<File> generateSessionReport({
    required String clientName,
    required String sessionDate,
    required String sessionNotes,
    required String therapistName,
    String? aiSummary,
    Map<String, dynamic>? clientInfo,
    Map<String, dynamic>? sessionMetrics,
  }) async {
    _performanceMonitor.startOperation(
      'generate_session_report',
      context: 'pdf_export',
      metadata: {
        'client_name': clientName,
        'notes_length': sessionNotes.length,
        'has_ai_summary': aiSummary != null,
      },
    );

    try {
      _logger.info(
        'Generating session report PDF',
        context: 'pdf_export',
        data: {'client_name': clientName, 'session_date': sessionDate},
      );

      final pdf = pw.Document(
        title: 'Seans Raporu - $clientName',
        author: therapistName,
        creator: 'PsyClinicAI',
        subject: 'Psikoterapi Seans Raporu',
      );

      // PDF sayfalarını oluştur
      pdf.addPage(_buildSessionReportPage(
        clientName: clientName,
        sessionDate: sessionDate,
        sessionNotes: sessionNotes,
        therapistName: therapistName,
        aiSummary: aiSummary,
        clientInfo: clientInfo,
        sessionMetrics: sessionMetrics,
      ));

      // Dosyayı kaydet
      final file = await _savePDF(pdf, 'seans_raporu_${clientName}_$sessionDate');
      
      _performanceMonitor.endOperation(
        'generate_session_report',
        context: 'pdf_export',
        resultMetadata: {
          'success': true,
          'file_size': await file.length(),
          'file_path': file.path,
        },
      );

      _logger.info(
        'Session report PDF generated successfully',
        context: 'pdf_export',
        data: {'file_path': file.path, 'file_size': await file.length()},
      );

      return file;
    } catch (e) {
      _logger.error(
        'Failed to generate session report PDF',
        context: 'pdf_export',
        data: {'client_name': clientName, 'error': e.toString()},
        error: e,
      );

      _performanceMonitor.endOperation(
        'generate_session_report',
        context: 'pdf_export',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );

      rethrow;
    }
  }

  // Tedavi planı PDF'i oluştur
  Future<File> generateTreatmentPlan({
    required String clientName,
    required String diagnosis,
    required List<String> goals,
    required List<String> interventions,
    required String therapistName,
    String? notes,
    Map<String, dynamic>? timeline,
  }) async {
    _performanceMonitor.startOperation(
      'generate_treatment_plan',
      context: 'pdf_export',
      metadata: {
        'client_name': clientName,
        'diagnosis': diagnosis,
        'goals_count': goals.length,
        'interventions_count': interventions.length,
      },
    );

    try {
      final pdf = pw.Document(
        title: 'Tedavi Planı - $clientName',
        author: therapistName,
        creator: 'PsyClinicAI',
        subject: 'Psikoterapi Tedavi Planı',
      );

      pdf.addPage(_buildTreatmentPlanPage(
        clientName: clientName,
        diagnosis: diagnosis,
        goals: goals,
        interventions: interventions,
        therapistName: therapistName,
        notes: notes,
        timeline: timeline,
      ));

      final file = await _savePDF(pdf, 'tedavi_plani_${clientName}_${DateTime.now().millisecondsSinceEpoch}');
      
      _performanceMonitor.endOperation(
        'generate_treatment_plan',
        context: 'pdf_export',
        resultMetadata: {
          'success': true,
          'file_size': await file.length(),
          'file_path': file.path,
        },
      );

      return file;
    } catch (e) {
      _performanceMonitor.endOperation(
        'generate_treatment_plan',
        context: 'pdf_export',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }

  // İlerleme raporu PDF'i oluştur
  Future<File> generateProgressReport({
    required String clientName,
    required List<Map<String, dynamic>> sessions,
    required Map<String, dynamic> progressMetrics,
    required String therapistName,
    String? summary,
    Map<String, dynamic>? recommendations,
  }) async {
    _performanceMonitor.startOperation(
      'generate_progress_report',
      context: 'pdf_export',
      metadata: {
        'client_name': clientName,
        'sessions_count': sessions.length,
        'has_summary': summary != null,
      },
    );

    try {
      final pdf = pw.Document(
        title: 'İlerleme Raporu - $clientName',
        author: therapistName,
        creator: 'PsyClinicAI',
        subject: 'Psikoterapi İlerleme Raporu',
      );

      pdf.addPage(_buildProgressReportPage(
        clientName: clientName,
        sessions: sessions,
        progressMetrics: progressMetrics,
        therapistName: therapistName,
        summary: summary,
        recommendations: recommendations,
      ));

      final file = await _savePDF(pdf, 'ilerleme_raporu_${clientName}_${DateTime.now().millisecondsSinceEpoch}');
      
      _performanceMonitor.endOperation(
        'generate_progress_report',
        context: 'pdf_export',
        resultMetadata: {
          'success': true,
          'file_size': await file.length(),
          'file_path': file.path,
        },
      );

      return file;
    } catch (e) {
      _performanceMonitor.endOperation(
        'generate_progress_report',
        context: 'pdf_export',
        resultMetadata: {
          'success': false,
          'error': e.toString(),
        },
      );
      rethrow;
    }
  }

  // Seans raporu sayfası oluştur
  pw.Page _buildSessionReportPage({
    required String clientName,
    required String sessionDate,
    required String sessionNotes,
    required String therapistName,
    String? aiSummary,
    Map<String, dynamic>? clientInfo,
    Map<String, dynamic>? sessionMetrics,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(clientName, sessionDate, therapistName),
            
            pw.SizedBox(height: 30),
            
            // Client Info
            if (clientInfo != null) ...[
              _buildClientInfoSection(clientInfo),
              pw.SizedBox(height: 20),
            ],
            
            // Session Notes
            _buildSectionTitle('Seans Notları'),
            pw.SizedBox(height: 10),
            _buildTextContent(sessionNotes),
            
            pw.SizedBox(height: 20),
            
            // AI Summary
            if (aiSummary != null) ...[
              _buildSectionTitle('AI Analizi'),
              pw.SizedBox(height: 10),
              _buildAISummarySection(aiSummary),
              pw.SizedBox(height: 20),
            ],
            
            // Session Metrics
            if (sessionMetrics != null) ...[
              _buildSectionTitle('Seans Metrikleri'),
              pw.SizedBox(height: 10),
              _buildMetricsSection(sessionMetrics),
              pw.SizedBox(height: 20),
            ],
            
            // Footer
            _buildFooter(),
          ],
        );
      },
    );
  }

  // Tedavi planı sayfası oluştur
  pw.Page _buildTreatmentPlanPage({
    required String clientName,
    required String diagnosis,
    required List<String> goals,
    required List<String> interventions,
    required String therapistName,
    String? notes,
    Map<String, dynamic>? timeline,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(clientName, 'Tedavi Planı', therapistName),
            
            pw.SizedBox(height: 30),
            
            // Diagnosis
            _buildSectionTitle('Tanı'),
            pw.SizedBox(height: 10),
            _buildTextContent(diagnosis),
            
            pw.SizedBox(height: 20),
            
            // Goals
            _buildSectionTitle('Hedefler'),
            pw.SizedBox(height: 10),
            _buildListContent(goals),
            
            pw.SizedBox(height: 20),
            
            // Interventions
            _buildSectionTitle('Müdahaleler'),
            pw.SizedBox(height: 10),
            _buildListContent(interventions),
            
            if (timeline != null) ...[
              pw.SizedBox(height: 20),
              _buildSectionTitle('Zaman Çizelgesi'),
              pw.SizedBox(height: 10),
              _buildTimelineSection(timeline),
            ],
            
            if (notes != null) ...[
              pw.SizedBox(height: 20),
              _buildSectionTitle('Notlar'),
              pw.SizedBox(height: 10),
              _buildTextContent(notes),
            ],
            
            pw.SizedBox(height: 20),
            _buildFooter(),
          ],
        );
      },
    );
  }

  // İlerleme raporu sayfası oluştur
  pw.Page _buildProgressReportPage({
    required String clientName,
    required List<Map<String, dynamic>> sessions,
    required Map<String, dynamic> progressMetrics,
    required String therapistName,
    String? summary,
    Map<String, dynamic>? recommendations,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(clientName, 'İlerleme Raporu', therapistName),
            
            pw.SizedBox(height: 30),
            
            // Progress Summary
            if (summary != null) ...[
              _buildSectionTitle('İlerleme Özeti'),
              pw.SizedBox(height: 10),
              _buildTextContent(summary),
              pw.SizedBox(height: 20),
            ],
            
            // Progress Metrics
            _buildSectionTitle('İlerleme Metrikleri'),
            pw.SizedBox(height: 10),
            _buildMetricsSection(progressMetrics),
            
            pw.SizedBox(height: 20),
            
            // Recent Sessions
            _buildSectionTitle('Son Seanslar'),
            pw.SizedBox(height: 10),
            _buildSessionsSection(sessions),
            
            if (recommendations != null) ...[
              pw.SizedBox(height: 20),
              _buildSectionTitle('Öneriler'),
              pw.SizedBox(height: 10),
              _buildRecommendationsSection(recommendations),
            ],
            
            pw.SizedBox(height: 20),
            _buildFooter(),
          ],
        );
      },
    );
  }

  // Header oluştur
  pw.Widget _buildHeader(String clientName, String title, String therapistName) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'PsyClinicAI',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                ),
                child: pw.Text(
                  DateTime.now().day.toString().padLeft(2, '0') + '/' +
                  DateTime.now().month.toString().padLeft(2, '0') + '/' +
                  DateTime.now().year.toString(),
                  style: pw.TextStyle(
                    color: _primaryColor,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Danışan: $clientName',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Terapist: $therapistName',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Section title oluştur
  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: pw.BoxDecoration(
        color: _secondaryColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          color: _primaryColor,
          fontSize: 16,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  // Text content oluştur
  pw.Widget _buildTextContent(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _secondaryColor, width: 1),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: _textColor,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  // List content oluştur
  pw.Widget _buildListContent(List<String> items) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _secondaryColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.map((item) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '• ',
                style: pw.TextStyle(
                  color: _accentColor,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  item,
                  style: pw.TextStyle(
                    color: _textColor,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // AI Summary section oluştur
  pw.Widget _buildAISummarySection(String aiSummary) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _accentColor, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Icon(
                pw.IconData(0xe3b3), // AI icon
                color: _accentColor,
                size: 20,
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'AI Analizi',
                style: pw.TextStyle(
                  color: _accentColor,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            aiSummary,
            style: pw.TextStyle(
              color: _textColor,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Metrics section oluştur
  pw.Widget _buildMetricsSection(Map<String, dynamic> metrics) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _secondaryColor, width: 1),
      ),
      child: pw.Column(
        children: metrics.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                entry.key,
                style: pw.TextStyle(
                  color: _textColor,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.w500,
                ),
              ),
              pw.Text(
                entry.value.toString(),
                style: pw.TextStyle(
                  color: _primaryColor,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // Client info section oluştur
  pw.Widget _buildClientInfoSection(Map<String, dynamic> clientInfo) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _secondaryColor, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Danışan Bilgileri',
            style: pw.TextStyle(
              color: _primaryColor,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          ...clientInfo.entries.map((entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    color: _textColor,
                    fontSize: 11,
                  ),
                ),
                pw.Text(
                  entry.value.toString(),
                  style: pw.TextStyle(
                    color: _textColor,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.w500,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  // Timeline section oluştur
  pw.Widget _buildTimelineSection(Map<String, dynamic> timeline) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _secondaryColor, width: 1),
      ),
      child: pw.Column(
        children: timeline.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: pw.BoxDecoration(
                  color: _accentColor,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      entry.key,
                      style: pw.TextStyle(
                        color: _primaryColor,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      entry.value.toString(),
                      style: pw.TextStyle(
                        color: _textColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // Sessions section oluştur
  pw.Widget _buildSessionsSection(List<Map<String, dynamic>> sessions) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: _secondaryColor, width: 1),
      ),
      child: pw.Column(
        children: sessions.take(5).map((session) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  session['date'] ?? 'Tarih belirtilmemiş',
                  style: pw.TextStyle(
                    color: _primaryColor,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  session['notes'] ?? 'Not bulunamadı',
                  style: pw.TextStyle(
                    color: _textColor,
                    fontSize: 10,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  // Recommendations section oluştur
  pw.Widget _buildRecommendationsSection(Map<String, dynamic> recommendations) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
        border: pw.Border.all(color: PdfColors.green, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: recommendations.entries.map((entry) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                entry.key,
                style: pw.TextStyle(
                  color: PdfColors.green,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                entry.value.toString(),
                style: pw.TextStyle(
                  color: _textColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // Footer oluştur
  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: _lightGray,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Divider(color: _secondaryColor, thickness: 1),
          pw.SizedBox(height: 10),
          pw.Text(
            'Bu rapor PsyClinicAI sistemi tarafından otomatik olarak oluşturulmuştur.',
            style: pw.TextStyle(
              color: _textColor,
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Rapor tarihi: ${DateTime.now().toString().substring(0, 19)}',
            style: pw.TextStyle(
              color: _textColor,
              fontSize: 9,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // PDF'i kaydet
  Future<File> _savePDF(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  // PDF'i aç
  Future<void> openPDF(File file) async {
    try {
      await OpenFile.open(file.path);
      _logger.info(
        'PDF opened successfully',
        context: 'pdf_export',
        data: {'file_path': file.path},
      );
    } catch (e) {
      _logger.error(
        'Failed to open PDF',
        context: 'pdf_export',
        data: {'file_path': file.path, 'error': e.toString()},
        error: e,
      );
      rethrow;
    }
  }

  // PDF'i paylaş
  Future<void> sharePDF(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'PsyClinicAI Raporu');
      _logger.info(
        'PDF shared successfully',
        context: 'pdf_export',
        data: {'file_path': file.path},
      );
    } catch (e) {
      _logger.error(
        'Failed to share PDF',
        context: 'pdf_export',
        data: {'file_path': file.path, 'error': e.toString()},
        error: e,
      );
      rethrow;
    }
  }

  // Performance monitoring getter'ları
  AIPerformanceMonitor get performanceMonitor => _performanceMonitor;
  AILogger get logger => _logger;

  // Performance statistics
  Map<String, dynamic> getPerformanceStatistics({String? context}) {
    return _performanceMonitor.getPerformanceStatistics(context: context);
  }

  // Export performance data
  Map<String, dynamic> exportPerformanceData() {
    return _performanceMonitor.exportPerformanceData();
  }
}
