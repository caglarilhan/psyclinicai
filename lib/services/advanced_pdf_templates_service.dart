import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/session_models.dart';
import '../models/patient_models.dart';
import '../models/medication_models.dart';

/// Advanced PDF Templates Service with professional designs
class AdvancedPDFTemplatesService {
  // Template configurations
  static const Map<String, Map<String, dynamic>> _templateConfigs = {
    'professional': {
      'name': 'Professional',
      'description': 'Clean, modern design for corporate clients',
      'primaryColor': PdfColors.blue900,
      'secondaryColor': PdfColors.grey300,
      'fontFamily': 'Helvetica',
      'logoPosition': 'top-right',
      'watermark': false,
    },
    'medical': {
      'name': 'Medical',
      'description': 'Healthcare-focused design with medical symbols',
      'primaryColor': PdfColors.green800,
      'secondaryColor': PdfColors.grey200,
      'fontFamily': 'Helvetica',
      'logoPosition': 'top-left',
      'watermark': true,
    },
    'minimalist': {
      'name': 'Minimalist',
      'description': 'Simple, elegant design with focus on content',
      'primaryColor': PdfColors.black,
      'secondaryColor': PdfColors.grey100,
      'fontFamily': 'Helvetica',
      'logoPosition': 'top-center',
      'watermark': false,
    },
    'corporate': {
      'name': 'Corporate',
      'description': 'Business-oriented design with branding elements',
      'primaryColor': PdfColors.blue900,
      'secondaryColor': PdfColors.blueGrey100,
      'fontFamily': 'Helvetica',
      'logoPosition': 'top-right',
      'watermark': true,
    },
    'creative': {
      'name': 'Creative',
      'description': 'Artistic design with modern typography',
      'primaryColor': PdfColors.purple800,
      'secondaryColor': PdfColors.purple100,
      'fontFamily': 'Helvetica',
      'logoPosition': 'top-left',
      'watermark': false,
    },
  };

  /// Generate professional session report
  Future<File> generateProfessionalSessionReport({
    required SessionData session,
    required PatientData patient,
    required String templateName,
    String? clinicLogo,
    String? clinicName,
    String? therapistName,
    Map<String, dynamic>? customBranding,
  }) async {
    final config = _templateConfigs[templateName] ?? _templateConfigs['professional']!;
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );

    // Add pages based on content length
    final pages = <pw.Page>[];
    
    // Header page
    pages.add(_buildHeaderPage(
      session: session,
      patient: patient,
      config: config,
      clinicLogo: clinicLogo,
      clinicName: clinicName,
      therapistName: therapistName,
      customBranding: customBranding,
    ));

    // Session details page
    pages.add(_buildSessionDetailsPage(
      session: session,
      patient: patient,
      config: config,
      customBranding: customBranding,
    ));

    // Assessment and progress page
    if (session.assessments.isNotEmpty || session.progressNotes.isNotEmpty) {
      pages.add(_buildAssessmentPage(
        session: session,
        patient: patient,
        config: config,
        customBranding: customBranding,
      ));
    }

    // Treatment plan page
    if (session.treatmentPlan.isNotEmpty) {
      pages.add(_buildTreatmentPlanPage(
        session: session,
        patient: patient,
        config: config,
        customBranding: customBranding,
      ));
    }

    // Recommendations page
    if (session.recommendations.isNotEmpty) {
      pages.add(_buildRecommendationsPage(
        session: session,
        patient: patient,
        config: config,
        customBranding: customBranding,
      ));
    }

    // Footer page
    pages.add(_buildFooterPage(
      session: session,
      patient: patient,
      config: config,
      customBranding: customBranding,
    ));

    for (final page in pages) {
      pdf.addPage(page);
    }

    // Save to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/professional_session_report_${session.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Generate comprehensive patient report
  Future<File> generateComprehensivePatientReport({
    required PatientData patient,
    required List<SessionData> sessions,
    required String templateName,
    String? clinicLogo,
    String? clinicName,
    String? therapistName,
    Map<String, dynamic>? customBranding,
  }) async {
    final config = _templateConfigs[templateName] ?? _templateConfigs['medical']!;
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );

    final pages = <pw.Page>[];

    // Patient overview page
    pages.add(_buildPatientOverviewPage(
      patient: patient,
      config: config,
      clinicLogo: clinicLogo,
      clinicName: clinicName,
      customBranding: customBranding,
    ));

    // Treatment history page
    pages.add(_buildTreatmentHistoryPage(
      patient: patient,
      sessions: sessions,
      config: config,
      customBranding: customBranding,
    ));

    // Progress analysis page
    pages.add(_buildProgressAnalysisPage(
      patient: patient,
      sessions: sessions,
      config: config,
      customBranding: customBranding,
    ));

    // Current status page
    pages.add(_buildCurrentStatusPage(
      patient: patient,
      sessions: sessions,
      config: config,
      customBranding: customBranding,
    ));

    // Future recommendations page
    pages.add(_buildFutureRecommendationsPage(
      patient: patient,
      sessions: sessions,
      config: config,
      customBranding: customBranding,
    ));

    for (final page in pages) {
      pdf.addPage(page);
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/comprehensive_patient_report_${patient.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Generate medication interaction report
  Future<File> generateMedicationInteractionReport({
    required List<DrugInteraction> interactions,
    required PatientData patient,
    required String templateName,
    String? clinicLogo,
    String? clinicName,
    String? therapistName,
    Map<String, dynamic>? customBranding,
  }) async {
    final config = _templateConfigs[templateName] ?? _templateConfigs['medical']!;
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
      ),
    );

    final pages = <pw.Page>[];

    // Interaction summary page
    pages.add(_buildInteractionSummaryPage(
      interactions: interactions,
      patient: patient,
      config: config,
      clinicLogo: clinicLogo,
      clinicName: clinicName,
      customBranding: customBranding,
    ));

    // Detailed interactions page
    pages.add(_buildDetailedInteractionsPage(
      interactions: interactions,
      patient: patient,
      config: config,
      customBranding: customBranding,
    ));

    // Risk assessment page
    pages.add(_buildRiskAssessmentPage(
      interactions: interactions,
      patient: patient,
      config: config,
      customBranding: customBranding,
    ));

    // Recommendations page
    pages.add(_buildInteractionRecommendationsPage(
      interactions: interactions,
      patient: patient,
      config: config,
      customBranding: customBranding,
    ));

    for (final page in pages) {
      pdf.addPage(page);
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/medication_interaction_report_${patient.id}.pdf');
    return file;
  }

  // Private helper methods for building pages

  pw.Page _buildHeaderPage({
    required SessionData session,
    required PatientData patient,
    required Map<String, dynamic> config,
    String? clinicLogo,
    String? clinicName,
    String? therapistName,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with logo and clinic info
            _buildHeaderSection(
              clinicLogo: clinicLogo,
              clinicName: clinicName ?? 'PsyClinicAI',
              therapistName: therapistName,
              config: config,
              customBranding: customBranding,
            ),
            
            pw.SizedBox(height: 40),
            
            // Title
            pw.Text(
              'Session Report',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: config['primaryColor'],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Patient information
            _buildPatientInfoSection(patient, config),
            
            pw.SizedBox(height: 30),
            
            // Session information
            _buildSessionInfoSection(session, config),
            
            pw.SizedBox(height: 40),
            
            // Watermark if enabled
            if (config['watermark'] == true)
              _buildWatermark(config),
          ],
        ),
      ),
    );
  }

  pw.Page _buildSessionDetailsPage({
    required SessionData session,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Session Details', config),
            
            pw.SizedBox(height: 30),
            
            // Session notes
            if (session.notes.isNotEmpty) ...[
              _buildSectionTitle('Session Notes', config),
              pw.SizedBox(height: 15),
              _buildTextContent(session.notes, config),
              pw.SizedBox(height: 25),
            ],
            
            // Goals and objectives
            if (session.goals.isNotEmpty) ...[
              _buildSectionTitle('Goals & Objectives', config),
              pw.SizedBox(height: 15),
              _buildGoalsList(session.goals, config),
              pw.SizedBox(height: 25),
            ],
            
            // Interventions used
            if (session.interventions.isNotEmpty) ...[
              _buildSectionTitle('Interventions Used', config),
              pw.SizedBox(height: 15),
              _buildInterventionsList(session.interventions, config),
              pw.SizedBox(height: 25),
            ],
            
            // Patient response
            if (session.patientResponse.isNotEmpty) ...[
              _buildSectionTitle('Patient Response', config),
              pw.SizedBox(height: 15),
              _buildTextContent(session.patientResponse, config),
            ],
          ],
        ),
      ),
    );
  }

  pw.Page _buildAssessmentPage({
    required SessionData session,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Assessment & Progress', config),
            
            pw.SizedBox(height: 30),
            
            // Assessments
            if (session.assessments.isNotEmpty) ...[
              _buildSectionTitle('Clinical Assessments', config),
              pw.SizedBox(height: 15),
              _buildAssessmentsList(session.assessments, config),
              pw.SizedBox(height: 25),
            ],
            
            // Progress notes
            if (session.progressNotes.isNotEmpty) ...[
              _buildSectionTitle('Progress Notes', config),
              pw.SizedBox(height: 15),
              _buildProgressNotesList(session.progressNotes, config),
              pw.SizedBox(height: 25),
            ],
            
            // Symptom tracking
            if (session.symptoms.isNotEmpty) ...[
              _buildSectionTitle('Symptom Tracking', config),
              pw.SizedBox(height: 15),
              _buildSymptomsList(session.symptoms, config),
            ],
          ],
        ),
      ),
    );
  }

  pw.Page _buildTreatmentPlanPage({
    required SessionData session,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Treatment Plan', config),
            
            pw.SizedBox(height: 30),
            
            // Treatment plan details
            _buildSectionTitle('Current Treatment Plan', config),
            pw.SizedBox(height: 15),
            _buildTextContent(session.treatmentPlan, config),
            
            pw.SizedBox(height: 25),
            
            // Next steps
            if (session.nextSteps.isNotEmpty) ...[
              _buildSectionTitle('Next Steps', config),
              pw.SizedBox(height: 15),
              _buildNextStepsList(session.nextSteps, config),
              pw.SizedBox(height: 25),
            ],
            
            // Homework assignments
            if (session.homework.isNotEmpty) ...[
              _buildSectionTitle('Homework Assignments', config),
              pw.SizedBox(height: 15),
              _buildHomeworkList(session.homework, config),
            ],
          ],
        ),
      ),
    );
  }

  pw.Page _buildRecommendationsPage({
    required SessionData session,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Recommendations', config),
            
            pw.SizedBox(height: 30),
            
            // Clinical recommendations
            _buildSectionTitle('Clinical Recommendations', config),
            pw.SizedBox(height: 15),
            _buildTextContent(session.recommendations, config),
            
            pw.SizedBox(height: 25),
            
            // Follow-up plan
            if (session.followUpPlan.isNotEmpty) ...[
              _buildSectionTitle('Follow-up Plan', config),
              pw.SizedBox(height: 15),
              _buildTextContent(session.followUpPlan, config),
              pw.SizedBox(height: 25),
            ],
            
            // Referrals
            if (session.referrals.isNotEmpty) ...[
              _buildSectionTitle('Referrals', config),
              pw.SizedBox(height: 15),
              _buildReferralsList(session.referrals, config),
            ],
          ],
        ),
      ),
    );
  }

  pw.Page _buildFooterPage({
    required SessionData session,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPageHeader('Report Summary', config),
            
            pw.SizedBox(height: 30),
            
            // Summary
            _buildSectionTitle('Session Summary', config),
            pw.SizedBox(height: 15),
            _buildTextContent(session.summary ?? 'No summary available.', config),
            
            pw.SizedBox(height: 40),
            
            // Footer information
            _buildFooterSection(config, customBranding),
            
            pw.SizedBox(height: 20),
            
            // Page numbers
            pw.Center(
              child: pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for building UI components

  pw.Widget _buildHeaderSection({
    String? clinicLogo,
    required String clinicName,
    String? therapistName,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Clinic logo and name
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (clinicLogo != null)
              pw.Image(
                pw.MemoryImage(File(clinicLogo).readAsBytesSync()),
                width: 80,
                height: 80,
              ),
            pw.SizedBox(height: 10),
            pw.Text(
              clinicName,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: config['primaryColor'],
              ),
            ),
          ],
        ),
        
        // Therapist information
        if (therapistName != null)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Therapist:',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey600,
                ),
              ),
              pw.Text(
                therapistName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: config['primaryColor'],
                ),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildPatientInfoSection(PatientData patient, Map<String, dynamic> config) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: config['secondaryColor'],
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Patient Information', config),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name:', patient.name),
                    _buildInfoRow('Age:', '${patient.age} years'),
                    _buildInfoRow('Gender:', patient.gender),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('ID:', patient.id),
                    _buildInfoRow('Date of Birth:', patient.dateOfBirth),
                    _buildInfoRow('Contact:', patient.phoneNumber),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSessionInfoSection(SessionData session, Map<String, dynamic> config) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: config['secondaryColor'],
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Session Information', config),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Session ID:', session.id),
                    _buildInfoRow('Date:', session.date.toString()),
                    _buildInfoRow('Duration:', '${session.duration} minutes'),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Type:', session.type),
                    _buildInfoRow('Status:', session.status),
                    _buildInfoRow('Location:', session.location),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPageHeader(String title, Map<String, dynamic> config) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 0),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: config['primaryColor'],
            width: 2,
          ),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 28,
          fontWeight: pw.FontWeight.bold,
          color: config['primaryColor'],
        ),
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title, Map<String, dynamic> config) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: config['primaryColor'],
      ),
    );
  }

  pw.Widget _buildTextContent(String content, Map<String, dynamic> config) {
    return pw.Text(
      content,
      style: pw.TextStyle(
        fontSize: 12,
        color: PdfColors.black,
        height: 1.5,
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
                          child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.black,
                ),
              ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGoalsList(List<String> goals, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: goals.map((goal) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  goal,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildInterventionsList(List<String> interventions, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: interventions.map((intervention) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  intervention,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildAssessmentsList(List<String> assessments, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: assessments.map((assessment) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  assessment,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildProgressNotesList(List<String> progressNotes, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: progressNotes.map((note) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  note,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildSymptomsList(List<String> symptoms, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: symptoms.map((symptom) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  symptom,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildNextStepsList(List<String> nextSteps, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: nextSteps.map((step) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  step,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildHomeworkList(List<String> homework, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: homework.map((assignment) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  assignment,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildReferralsList(List<String> referrals, Map<String, dynamic> config) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: referrals.map((referral) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration: pw.BoxDecoration(
                color: config['primaryColor'],
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
                              child: pw.Text(
                  referral,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.black,
                  ),
                ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  pw.Widget _buildFooterSection(Map<String, dynamic> config, Map<String, dynamic>? customBranding) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: config['secondaryColor'],
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Report Generated by PsyClinicAI',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: config['primaryColor'],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generated on: ${DateTime.now().toString()}',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
          if (customBranding != null && customBranding['footerText'] != null) ...[
            pw.SizedBox(height: 10),
            pw.Text(
              customBranding['footerText'],
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildWatermark(Map<String, dynamic> config) {
    return pw.Positioned(
      right: 50,
      top: 100,
      child: pw.Transform.rotate(
        angle: -0.785398, // -45 degrees in radians
        child: pw.Text(
          'CONFIDENTIAL',
          style: pw.TextStyle(
            fontSize: 48,
            color: PdfColors.grey300,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Additional methods for other report types would go here...
  // These are placeholder methods that would need to be implemented
  // based on the specific requirements for each report type

  pw.Page _buildPatientOverviewPage({
    required PatientData patient,
    required Map<String, dynamic> config,
    String? clinicLogo,
    String? clinicName,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for patient overview page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Patient Overview Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildTreatmentHistoryPage({
    required PatientData patient,
    required List<SessionData> sessions,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for treatment history page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Treatment History Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildProgressAnalysisPage({
    required PatientData patient,
    required List<SessionData> sessions,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for progress analysis page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Progress Analysis Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildCurrentStatusPage({
    required PatientData patient,
    required List<SessionData> sessions,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for current status page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Current Status Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildFutureRecommendationsPage({
    required PatientData patient,
    required List<SessionData> sessions,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for future recommendations page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Future Recommendations Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildInteractionSummaryPage({
    required List<DrugInteraction> interactions,
    required PatientData patient,
    required Map<String, dynamic> config,
    String? clinicLogo,
    String? clinicName,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for interaction summary page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Interaction Summary Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildDetailedInteractionsPage({
    required List<DrugInteraction> interactions,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for detailed interactions page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Detailed Interactions Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildRiskAssessmentPage({
    required List<DrugInteraction> interactions,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for risk assessment page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Risk Assessment Page - To be implemented'),
      ),
    );
  }

  pw.Page _buildInteractionRecommendationsPage({
    required List<DrugInteraction> interactions,
    required PatientData patient,
    required Map<String, dynamic> config,
    Map<String, dynamic>? customBranding,
  }) {
    // Implementation for interaction recommendations page
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Container(
        padding: const pw.EdgeInsets.all(40),
        child: pw.Text('Interaction Recommendations Page - To be implemented'),
      ),
    );
  }

  /// Get available template configurations
  Map<String, Map<String, dynamic>> getAvailableTemplates() {
    return _templateConfigs;
  }

  /// Get template configuration by name
  Map<String, dynamic>? getTemplateConfig(String templateName) {
    return _templateConfigs[templateName];
  }
}
