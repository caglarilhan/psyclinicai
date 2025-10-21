import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/pdf_analysis_service.dart';
import '../../services/patient_service.dart';
import '../../models/patient.dart';
import '../../models/advanced_drug_info.dart';
import '../../services/ai_drug_interaction_service.dart';
import '../../services/drug_database_service.dart';
import '../../models/smart_prescription_models.dart';

class SmartPrescriptionScreen extends StatefulWidget {
  const SmartPrescriptionScreen({super.key});

  @override
  State<SmartPrescriptionScreen> createState() => _SmartPrescriptionScreenState();
}

class _SmartPrescriptionScreenState extends State<SmartPrescriptionScreen> {
  Patient? _selectedPatient;
  PatientReportAnalysis? _currentAnalysis;
  List<SmartPrescriptionRecommendation> _recommendations = [];
  bool _isLoadingPdf = false;
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    // İlk hasta seçimi için demo hasta yükleyebiliriz
    final patientService = Provider.of<PatientService>(context, listen: false);
    if (patientService.patients.isNotEmpty) {
      final patientItem = patientService.patients.first;
      _selectedPatient = Patient(
        id: patientItem.id,
        fullName: patientItem.name,
        email: patientItem.email,
        phone: patientItem.phone,
        birthDate: patientItem.birthDate,
        gender: patientItem.gender,
        notes: patientItem.notes,
        kvkkConsent: patientItem.kvkkConsent,
        allergies: patientItem.allergies,
        currentMedications: patientItem.currentMedications,
        diagnosis: patientItem.diagnosis,
      );
    }
  }

  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _isLoadingPdf = true;
        _currentAnalysis = null;
        _recommendations = [];
      });

      final pdfContent = String.fromCharCodes(result.files.single.bytes!);
      await _analyzePdf(pdfContent);
    }
  }

  Future<void> _loadDemoPdf() async {
    if (_selectedPatient == null) {
      _showSnackBar('Lütfen önce bir hasta seçin.');
      return;
    }

    setState(() {
      _isLoadingPdf = true;
      _currentAnalysis = null;
      _recommendations = [];
    });

    final pdfAnalysisService = Provider.of<PDFAnalysisService>(context, listen: false);
    final demoPdfContent = pdfAnalysisService.generateDemoPdfContent(_selectedPatient!);
    await _analyzePdf(demoPdfContent);
  }

  Future<void> _analyzePdf(String pdfContent) async {
    if (_selectedPatient == null) {
      _showSnackBar('Lütfen önce bir hasta seçin.');
      setState(() => _isLoadingPdf = false);
      return;
    }

    final pdfAnalysisService = Provider.of<PDFAnalysisService>(context, listen: false);
    final result = await pdfAnalysisService.analyzePatientPdf(pdfContent, _selectedPatient!);

    setState(() {
      _currentAnalysis = PatientReportAnalysis(
        patientId: _selectedPatient!.id,
        summary: result.summary,
        detectedDiagnoses: result.detectedDiagnoses,
        detectedSymptoms: result.detectedSymptoms,
        detectedMedications: result.detectedMedications,
        detectedAllergies: result.detectedAllergies,
        vitalSigns: result.vitalSigns,
        confidenceScore: result.confidenceScore,
      );
      _isLoadingPdf = false;
    });

    _showSnackBar('PDF analizi tamamlandı!');
  }

  Future<void> _getAIDrugRecommendations() async {
    if (_currentAnalysis == null) {
      _showSnackBar('Lütfen önce bir PDF analizi yapın.');
      return;
    }
    if (_selectedPatient == null) {
      _showSnackBar('Lütfen önce bir hasta seçin.');
      return;
    }

    setState(() {
      _isLoadingRecommendations = true;
      _recommendations = [];
    });

    final aiInteractionService = Provider.of<AIDrugInteractionService>(context, listen: false);
    // Analiz sonucundan tespit edilen tanıyı kullan
    final primaryDiagnosis = _currentAnalysis!.detectedDiagnoses.isNotEmpty
        ? _currentAnalysis!.detectedDiagnoses.first
        : 'Genel';

    final recommendations = await aiInteractionService.getAIDrugRecommendations(
      _selectedPatient!.id,
      [primaryDiagnosis],
      ['Genel semptomlar'],
      _selectedPatient!.allergies,
    );

    // Recommendations zaten SmartPrescriptionRecommendation listesi
    _recommendations = recommendations;

    setState(() {
      _isLoadingRecommendations = false;
    });
    _showSnackBar('AI ilaç önerileri alındı!');
  }

  void _createPrescription() {
    if (_recommendations.isEmpty) {
      _showSnackBar('Lütfen reçeteye eklenecek ilaçları seçin.');
      return;
    }
    if (_selectedPatient == null) {
      _showSnackBar('Lütfen bir hasta seçin.');
      return;
    }

    // Burada seçilen ilaçlarla reçete oluşturma mantığı uygulanır.
    print('Reçete Oluşturuldu:');
    print('Hasta: ${_selectedPatient!.fullName}');
    for (var rec in _recommendations) {
      print('- ${rec.drugName} (${rec.dosage})');
    }
    _showSnackBar('Reçete başarıyla oluşturuldu (simüle)!');

    // Ekranı temizle
    setState(() {
      _currentAnalysis = null;
      _recommendations = [];
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientService = Provider.of<PatientService>(context);
    final drugDatabaseService = Provider.of<DrugDatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Akıllı Reçete'),
        actions: [
          DropdownButton<Patient>(
            value: _selectedPatient,
            hint: const Text('Hasta Seç', style: TextStyle(color: Colors.white)),
            dropdownColor: Theme.of(context).cardColor,
            onChanged: (Patient? newValue) {
              setState(() {
                _selectedPatient = newValue;
                _currentAnalysis = null;
                _recommendations = [];
              });
            },
            items: patientService.patients.map<DropdownMenuItem<Patient>>((patientItem) {
              final patient = Patient(
                id: patientItem.id,
                fullName: patientItem.name,
                email: patientItem.email,
                phone: patientItem.phone,
                birthDate: patientItem.birthDate,
                gender: patientItem.gender,
                notes: patientItem.notes,
                kvkkConsent: patientItem.kvkkConsent,
                allergies: patientItem.allergies,
                currentMedications: patientItem.currentMedications,
                diagnosis: patientItem.diagnosis,
              );
              return DropdownMenuItem<Patient>(
                value: patient,
                child: Text(patient.fullName, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _pickPdf,
            tooltip: 'PDF Yükle',
          ),
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: _loadDemoPdf,
            tooltip: 'Demo PDF Yükle',
          ),
        ],
      ),
      body: _selectedPatient == null
          ? const Center(child: Text('Lütfen reçete oluşturmak için bir hasta seçin.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PDF Analiz Bölümü
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PDF Analizi', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          _isLoadingPdf
                              ? const Center(child: CircularProgressIndicator())
                              : _currentAnalysis == null
                                  ? const Text('Henüz bir PDF yüklenmedi veya analiz edilmedi.')
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Analiz Özeti: ${_currentAnalysis!.summary}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Text('Tespit Edilen Tanılar: ${_currentAnalysis!.detectedDiagnoses.join(', ')}'),
                                        Text('Tespit Edilen Semptomlar: ${_currentAnalysis!.detectedSymptoms.join(', ')}'),
                                        Text('Tespit Edilen Mevcut İlaçlar: ${_currentAnalysis!.detectedMedications.join(', ')}'),
                                        Text('Tespit Edilen Alerjiler: ${_currentAnalysis!.detectedAllergies.join(', ')}'),
                                        Text('Vital Bulgular: ${_currentAnalysis!.vitalSigns.entries.map((e) => '${e.key}: ${e.value}').join(', ')}'),
                                        Text('Güven Skoru: %${(_currentAnalysis!.confidenceScore * 100).toStringAsFixed(0)}'),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _getAIDrugRecommendations,
                                          child: const Text('AI İlaç Önerileri Al'),
                                        ),
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ),

                  // AI Öneriler Bölümü
                  if (_recommendations.isNotEmpty)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI İlaç Önerileri', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 16),
                            _isLoadingRecommendations
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                                    children: _recommendations.map((rec) => _buildRecommendationCard(rec)).toList(),
                                  ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _createPrescription,
                              child: const Text('Reçete Oluştur'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRecommendationCard(SmartPrescriptionRecommendation rec) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rec.drugName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Dozaj: ${rec.dosage}'),
            Text('Sıklık: ${rec.frequency}'),
            Text('Süre: ${rec.duration}'),
            Text('Neden: ${rec.reason}'),
            Text('Takip: ${rec.monitoring}'),
            Text('Güven Skoru: %${(rec.confidence * 100).toStringAsFixed(0)}'),
            if (rec.contraindications.isNotEmpty)
              Text('Kontrendikasyonlar: ${rec.contraindications.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
