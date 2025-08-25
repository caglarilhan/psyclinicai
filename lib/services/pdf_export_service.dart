import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import '../models/medication_models.dart';
import '../models/session_models.dart';
import '../models/patient_models.dart';

class PdfExportService {
  static const String _appName = 'PsyClinicAI';
  static const String _version = '2.0.0';
  
  // PDF Export Templates
  static const Map<String, String> _templates = {
    'session_report': 'Session Report Template',
    'medication_interaction': 'Drug Interaction Report',
    'prescription': 'Prescription Report',
    'patient_summary': 'Patient Summary Report',
    'treatment_plan': 'Treatment Plan Report',
  };

  /// Export session report to PDF
  Future<File?> exportSessionReport({
    required Session session,
    required Patient patient,
    required String template,
    String? customNotes,
  }) async {
    try {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission required for PDF export');
      }

      final pdf = pw.Document();
      
      // Add session report content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildSessionReportPage(
            session: session,
            patient: patient,
            template: template,
            customNotes: customNotes,
          ),
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/session_report_${session.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('PDF export failed: $e');
      return null;
    }
  }

  /// Export medication interaction report to PDF
  Future<File?> exportInteractionReport({
    required List<DrugInteraction> interactions,
    required Patient patient,
    required String template,
    String? additionalNotes,
  }) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission required for PDF export');
      }

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildInteractionReportPage(
            interactions: interactions,
            patient: patient,
            template: template,
            additionalNotes: additionalNotes,
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/interaction_report_${patient.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('Interaction report export failed: $e');
      return null;
    }
  }

  /// Export prescription report to PDF
  Future<File?> exportPrescriptionReport({
    required Prescription prescription,
    required Patient patient,
    required String template,
    List<DrugInteraction>? interactions,
  }) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission required for PDF export');
      }

      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildPrescriptionReportPage(
            prescription: prescription,
            patient: patient,
            template: template,
            interactions: interactions,
          ),
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/prescription_${prescription.id}_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      
      return file;
    } catch (e) {
      print('Prescription export failed: $e');
      return null;
    }
  }

  /// Build session report page
  pw.Widget _buildSessionReportPage({
    required Session session,
    required Patient patient,
    required String template,
    String? customNotes,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          pw.SizedBox(height: 20),
          
          // Patient Information
          _buildPatientInfo(patient),
          
          pw.SizedBox(height: 20),
          
          // Session Details
          _buildSessionDetails(session),
          
          if (customNotes != null) ...[
            pw.SizedBox(height: 20),
            _buildCustomNotes(customNotes),
          ],
          
          pw.SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  /// Build interaction report page
  pw.Widget _buildInteractionReportPage({
    required List<DrugInteraction> interactions,
    required Patient patient,
    required String template,
    String? additionalNotes,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          pw.SizedBox(height: 20),
          
          // Patient Information
          _buildPatientInfo(patient),
          
          pw.SizedBox(height: 20),
          
          // Interaction Summary
          _buildInteractionSummary(interactions),
          
          pw.SizedBox(height: 20),
          
          // Detailed Interactions
          _buildDetailedInteractions(interactions),
          
          if (additionalNotes != null) ...[
            pw.SizedBox(height: 20),
            _buildAdditionalNotes(additionalNotes),
          ],
          
          pw.SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  /// Build prescription report page
  pw.Widget _buildPrescriptionReportPage({
    required Prescription prescription,
    required Patient patient,
    required String template,
    List<DrugInteraction>? interactions,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          
          pw.SizedBox(height: 20),
          
          // Patient Information
          _buildPatientInfo(patient),
          
          pw.SizedBox(height: 20),
          
          // Prescription Details
          _buildPrescriptionDetails(prescription),
          
          if (interactions != null && interactions.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildPrescriptionInteractions(interactions),
          ],
          
          pw.SizedBox(height: 20),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  /// Build header section
  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _appName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Version $_version',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.blue700,
                  ),
                ),
              ],
            ),
          ),
          pw.Text(
            DateTime.now().toString().split(' ')[0],
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.blue700,
            ),
          ),
        ],
      ),
    );
  }

  /// Build patient information section
  pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Name: ${patient.fullName}'),
              ),
              pw.Expanded(
                child: pw.Text('ID: ${patient.id}'),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Age: ${patient.age}'),
              ),
              pw.Expanded(
                child: pw.Text('Gender: ${patient.gender}'),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text('Contact: ${patient.phoneNumber}'),
        ],
      ),
    );
  }

  /// Build session details section
  pw.Widget _buildSessionDetails(Session session) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Session Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Date: ${session.date.toString().split(' ')[0]}'),
          pw.SizedBox(height: 5),
          pw.Text('Duration: ${session.duration} minutes'),
          pw.SizedBox(height: 5),
          pw.Text('Type: ${session.type}'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Notes:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(session.notes ?? 'No notes available'),
        ],
      ),
    );
  }

  /// Build interaction summary section
  pw.Widget _buildInteractionSummary(List<DrugInteraction> interactions) {
    final severityCounts = <String, int>{};
    for (final interaction in interactions) {
      final severity = interaction.severity.name;
      severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Interaction Summary',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Total Interactions: ${interactions.length}'),
          pw.SizedBox(height: 10),
          ...severityCounts.entries.map((entry) => pw.Text(
            '${entry.key}: ${entry.value}',
            style: pw.TextStyle(
              color: _getSeverityColor(entry.key),
              fontWeight: pw.FontWeight.bold,
            ),
          )),
        ],
      ),
    );
  }

  /// Build detailed interactions section
  pw.Widget _buildDetailedInteractions(List<DrugInteraction> interactions) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Detailed Interactions',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          ...interactions.map((interaction) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 10),
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _getSeverityBackgroundColor(interaction.severity.name),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${interaction.medication1Name} + ${interaction.medication2Name}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: _getSeverityColor(interaction.severity.name),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Severity: ${interaction.severity.name}'),
                pw.SizedBox(height: 5),
                pw.Text('Type: ${interaction.type.name}'),
                pw.SizedBox(height: 5),
                pw.Text('Description: ${interaction.description}'),
                if (interaction.recommendations.isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text('Recommendations: ${interaction.recommendations.join(', ')}'),
                ],
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Build prescription details section
  pw.Widget _buildPrescriptionDetails(Prescription prescription) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Prescription Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Date: ${prescription.date.toString().split(' ')[0]}'),
          pw.SizedBox(height: 5),
          pw.Text('Status: ${prescription.status}'),
          pw.SizedBox(height: 10),
          pw.Text(
            'Medications:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          ...prescription.medications.map((med) => pw.Text(
            '• ${med.name} - ${med.dosage}',
          )),
        ],
      ),
    );
  }

  /// Build prescription interactions section
  pw.Widget _buildPrescriptionInteractions(List<DrugInteraction> interactions) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '⚠️ Drug Interactions Found',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange800,
            ),
          ),
          pw.SizedBox(height: 10),
          ...interactions.take(3).map((interaction) => pw.Text(
            '• ${interaction.medication1Name} + ${interaction.medication2Name}: ${interaction.severity.name}',
            style: pw.TextStyle(
              color: _getSeverityColor(interaction.severity.name),
            ),
          )),
          if (interactions.length > 3) ...[
            pw.SizedBox(height: 5),
            pw.Text(
              '... and ${interactions.length - 3} more interactions',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build custom notes section
  pw.Widget _buildCustomNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.green300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Additional Notes',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(notes),
        ],
      ),
    );
  }

  /// Build additional notes section
  pw.Widget _buildAdditionalNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Additional Notes',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(notes),
        ],
      ),
    );
  }

  /// Build footer section
  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Generated by $_appName v$_version',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'This document is for medical professionals only',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Get severity color for PDF
  PdfColor _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'minor':
        return PdfColors.blue;
      case 'moderate':
        return PdfColors.orange;
      case 'major':
        return PdfColors.red;
      case 'contraindicated':
        return PdfColors.purple;
      default:
        return PdfColors.grey;
    }
  }

  /// Get severity background color for PDF
  PdfColor _getSeverityBackgroundColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'minor':
        return PdfColors.blue50;
      case 'moderate':
        return PdfColors.orange50;
      case 'major':
        return PdfColors.red50;
      case 'contraindicated':
        return PdfColors.purple50;
      default:
        return PdfColors.grey50;
    }
  }

  /// Get available templates
  Map<String, String> getAvailableTemplates() {
    return Map.unmodifiable(_templates);
  }

  /// Get template by name
  String? getTemplate(String templateName) {
    return _templates[templateName];
  }
}
