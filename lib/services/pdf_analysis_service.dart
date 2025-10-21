import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/advanced_drug_info.dart';
import '../services/ai_drug_interaction_service.dart';
import '../models/smart_prescription_models.dart';
import '../models/patient.dart';

class PdfAnalysisResult {
  final String patientId;
  final String summary;
  final List<String> detectedDiagnoses;
  final List<String> detectedSymptoms;
  final List<String> detectedMedications;
  final List<String> detectedAllergies;
  final Map<String, String> vitalSigns;
  final double confidenceScore;

  PdfAnalysisResult({
    required this.patientId,
    required this.summary,
    this.detectedDiagnoses = const [],
    this.detectedSymptoms = const [],
    this.detectedMedications = const [],
    this.detectedAllergies = const [],
    this.vitalSigns = const {},
    this.confidenceScore = 0.0,
  });
}

class PDFAnalysisService extends ChangeNotifier {
  static final PDFAnalysisService _instance = PDFAnalysisService._internal();
  factory PDFAnalysisService() => _instance;
  PDFAnalysisService._internal();

  final AIDrugInteractionService _interactionService = AIDrugInteractionService();
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void initialize() {
    // Servis başlatma
  }

  // PDF'den metin çıkarma ve analiz
  Future<PdfAnalysisResult> analyzePatientPdf(
    String pdfContent,
    Patient patient,
  ) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Simüle edilmiş bir PDF analiz fonksiyonu
      print('Analyzing PDF content for patient ${patient.fullName}...');
      print('PDF Content Snippet: ${pdfContent.substring(0, pdfContent.length > 200 ? 200 : pdfContent.length)}...');

      List<String> detectedDiagnoses = [];
      List<String> detectedSymptoms = [];
      List<String> detectedMedications = [];
      List<String> detectedAllergies = [];
      Map<String, String> vitalSigns = {};
      String summary = 'PDF analizi tamamlandı. Önemli bulgular çıkarıldı.';
      double confidenceScore = 0.85; // Simüle edilmiş güven skoru

      // Basit keyword tabanlı tespitler
      if (pdfContent.toLowerCase().contains('diabetes') || pdfContent.toLowerCase().contains('diyabet')) {
        detectedDiagnoses.add('Tip 2 Diabetes Mellitus');
        detectedMedications.add('Metformin');
      }
      if (pdfContent.toLowerCase().contains('hypertension') || pdfContent.toLowerCase().contains('hipertansiyon')) {
        detectedDiagnoses.add('Esansiyel Hipertansiyon');
        detectedMedications.add('Lisinopril');
      }
      if (pdfContent.toLowerCase().contains('hypothyroidism') || pdfContent.toLowerCase().contains('hipotiroidizm')) {
        detectedDiagnoses.add('Subklinik Hipotiroidizm');
        detectedMedications.add('Levotiroksin');
      }
      if (pdfContent.toLowerCase().contains('baş ağrısı') || pdfContent.toLowerCase().contains('headache')) {
        detectedSymptoms.add('Baş Ağrısı');
      }
      if (pdfContent.toLowerCase().contains('yorgunluk') || pdfContent.toLowerCase().contains('fatigue')) {
        detectedSymptoms.add('Yorgunluk');
      }
      if (pdfContent.toLowerCase().contains('alerji') || pdfContent.toLowerCase().contains('allergy')) {
        if (pdfContent.toLowerCase().contains('penicillin')) {
          detectedAllergies.add('Penisilin');
        }
      }

      // Vital bulgular için regex (basit örnekler)
      RegExp bpRegex = RegExp(r'Kan Basıncı:\s*(\d{2,3}/\d{2,3})\s*mmHg');
      RegExp hrRegex = RegExp(r'Nabız:\s*(\d{2,3})\s*bpm');
      RegExp tempRegex = RegExp(r'Ateş:\s*(\d{2}\.\d)\s*°C');

      Match? bpMatch = bpRegex.firstMatch(pdfContent);
      if (bpMatch != null) {
        vitalSigns['bloodPressure'] = bpMatch.group(1)!;
      }
      Match? hrMatch = hrRegex.firstMatch(pdfContent);
      if (hrMatch != null) {
        vitalSigns['heartRate'] = hrMatch.group(1)!;
      }
      Match? tempMatch = tempRegex.firstMatch(pdfContent);
      if (tempMatch != null) {
        vitalSigns['temperature'] = tempMatch.group(1)!;
      }

      // Daha gelişmiş bir özetleme LLM ile yapılabilir
      summary = 'Hasta raporu analizi tamamlandı. Tespit edilen tanılar: ${detectedDiagnoses.join(', ')}. '
                'Belirtiler: ${detectedSymptoms.join(', ')}. Mevcut ilaçlar: ${detectedMedications.join(', ')}. '
                'Alerjiler: ${detectedAllergies.join(', ')}. Vital Bulgular: ${vitalSigns.entries.map((e) => '${e.key}: ${e.value}').join(', ')}.';

      return PdfAnalysisResult(
        patientId: patient.id,
        summary: summary,
        detectedDiagnoses: detectedDiagnoses,
        detectedSymptoms: detectedSymptoms,
        detectedMedications: detectedMedications,
        detectedAllergies: detectedAllergies,
        vitalSigns: vitalSigns,
        confidenceScore: confidenceScore,
      );

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Demo PDF içeriği oluşturma
  String generateDemoPdfContent(Patient patient) {
    return """
    Hasta Adı: ${patient.fullName}
    Doğum Tarihi: ${patient.birthDate?.toIso8601String().split('T').first ?? 'Bilinmiyor'}
    Cinsiyet: ${patient.gender ?? 'Bilinmiyor'}

    Klinik Notlar:
    Hasta ${patient.fullName}, 45 yaşında erkek hasta. Son 6 aydır artan yorgunluk, kilo alımı ve konsantrasyon güçlüğü şikayetleri ile başvurdu.
    Özgeçmişinde Tip 2 Diabetes Mellitus (Metformin kullanıyor), Esansiyel Hipertansiyon (Lisinopril kullanıyor) ve Subklinik Hipotiroidizm (Levotiroksin kullanıyor) mevcut.
    Alerji öyküsü: Penisilin alerjisi var.

    Fizik Muayene:
    Kan Basıncı: 140/90 mmHg
    Nabız: 85 bpm
    Ateş: 36.8 °C
    Boy: 175 cm
    Kilo: 90 kg

    Laboratuvar Sonuçları:
    Glukoz: 180 mg/dL (Yüksek)
    HbA1c: 8.2% (Yüksek)
    TSH: 7.5 mIU/L (Yüksek)
    Serbest T4: Normal
    Kreatinin: 1.1 mg/dL (Normal)

    Değerlendirme:
    Hastanın mevcut şikayetleri ve laboratuvar sonuçları, diyabet ve hipotiroidizm kontrolünün yetersiz olduğunu düşündürmektedir.
    Hipertansiyonu da kontrol altında değildir. İlaç dozlarının gözden geçirilmesi ve yaşam tarzı değişiklikleri önerilmektedir.
    """;
  }

  // PDF'den metin çıkarma (demo)
  Future<String> _extractTextFromPDF(Uint8List pdfData) async {
    // Gerçek uygulamada pdf_text_extraction paketi kullanılır
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon
    
    // Demo PDF içeriği
    return '''
HASTA RAPORU
Hasta Adı: Ahmet Yılmaz
Yaş: 45
Cinsiyet: Erkek
Tarih: 15.12.2024

LABORATUVAR SONUÇLARI:
- Hemoglobin: 12.5 g/dL (Normal: 12-16)
- Glukoz: 180 mg/dL (Yüksek: >126)
- Kreatinin: 1.2 mg/dL (Normal: 0.7-1.3)
- ALT: 45 U/L (Normal: 7-56)
- TSH: 4.5 mIU/L (Yüksek: >4.0)

VİTAL BULGULAR:
- Kan Basıncı: 150/95 mmHg (Yüksek)
- Nabız: 85/dk
- Ateş: 36.8°C
- Oksijen Saturasyonu: %98

MEVCUT İLAÇLAR:
- Metformin 500mg günde 2 kez
- Lisinopril 10mg günde 1 kez

ALERJİLER:
- Penisilin
- Sülfonamid

TANI:
- Tip 2 Diabetes Mellitus
- Hipertansiyon
- Subklinik Hipotiroidizm

SEMPTOMLAR:
- Poliüri
- Polidipsi
- Yorgunluk
- Baş ağrısı

ÖNERİLER:
- Kan şekeri takibi
- Kan basıncı kontrolü
- Tiroid fonksiyon testleri
- Diyet ve egzersiz
''';
  }

  // AI analiz (demo)
  Future<PatientReportAnalysis> _performAIAnalysis(
    String patientId,
    String extractedText,
    String reportType,
  ) async {
    await Future.delayed(const Duration(seconds: 3)); // AI işleme simülasyonu

    // Metin analizi (gerçek uygulamada NLP/LLM kullanılır)
    final diagnoses = _extractDiagnoses(extractedText);
    final symptoms = _extractSymptoms(extractedText);
    final medications = _extractMedications(extractedText);
    final allergies = _extractAllergies(extractedText);
    final vitalSigns = _extractVitalSigns(extractedText);
    final recommendations = _extractRecommendations(extractedText);

    return PatientReportAnalysis(
      patientId: patientId,
      summary: 'PDF analizi tamamlandı: $reportType',
      detectedDiagnoses: diagnoses,
      detectedSymptoms: symptoms,
      detectedMedications: medications,
      detectedAllergies: allergies,
      vitalSigns: vitalSigns,
      confidenceScore: 0.85,
    );
  }

  List<String> _extractDiagnoses(String text) {
    final diagnoses = <String>[];
    
    if (text.toLowerCase().contains('diabetes') || text.toLowerCase().contains('şeker')) {
      diagnoses.add('Tip 2 Diabetes Mellitus');
    }
    if (text.toLowerCase().contains('hipertansiyon') || text.toLowerCase().contains('yüksek tansiyon')) {
      diagnoses.add('Hipertansiyon');
    }
    if (text.toLowerCase().contains('hipotiroidizm') || text.toLowerCase().contains('tiroid')) {
      diagnoses.add('Subklinik Hipotiroidizm');
    }
    if (text.toLowerCase().contains('depresyon')) {
      diagnoses.add('Depresyon');
    }
    if (text.toLowerCase().contains('anksiyete')) {
      diagnoses.add('Anksiyete Bozukluğu');
    }

    return diagnoses;
  }

  List<String> _extractSymptoms(String text) {
    final symptoms = <String>[];
    
    if (text.toLowerCase().contains('poliüri')) symptoms.add('Poliüri');
    if (text.toLowerCase().contains('polidipsi')) symptoms.add('Polidipsi');
    if (text.toLowerCase().contains('yorgunluk')) symptoms.add('Yorgunluk');
    if (text.toLowerCase().contains('baş ağrısı')) symptoms.add('Baş Ağrısı');
    if (text.toLowerCase().contains('uykusuzluk')) symptoms.add('Uykusuzluk');
    if (text.toLowerCase().contains('iştahsızlık')) symptoms.add('İştahsızlık');

    return symptoms;
  }

  List<String> _extractMedications(String text) {
    final medications = <String>[];
    
    if (text.toLowerCase().contains('metformin')) {
      medications.add('Metformin 500mg');
    }
    if (text.toLowerCase().contains('lisinopril')) {
      medications.add('Lisinopril 10mg');
    }
    if (text.toLowerCase().contains('fluoksetin')) {
      medications.add('Fluoksetin 20mg');
    }
    if (text.toLowerCase().contains('parasetamol')) {
      medications.add('Parasetamol 500mg');
    }

    return medications;
  }

  List<String> _extractAllergies(String text) {
    final allergies = <String>[];
    
    if (text.toLowerCase().contains('penisilin')) {
      allergies.add('Penisilin');
    }
    if (text.toLowerCase().contains('sülfonamid')) {
      allergies.add('Sülfonamid');
    }
    if (text.toLowerCase().contains('aspirin')) {
      allergies.add('Aspirin');
    }

    return allergies;
  }

  Map<String, String> _extractVitalSigns(String text) {
    final vitalSigns = <String, String>{};
    
    // Kan basıncı
    final bpMatch = RegExp(r'(\d+)/(\d+)\s*mmHg').firstMatch(text);
    if (bpMatch != null) {
      vitalSigns['blood_pressure'] = '${bpMatch.group(1)}/${bpMatch.group(2)} mmHg';
    }
    
    // Nabız
    final pulseMatch = RegExp(r'(\d+)/dk').firstMatch(text);
    if (pulseMatch != null) {
      vitalSigns['pulse'] = '${pulseMatch.group(1)}/dk';
    }
    
    // Ateş
    final tempMatch = RegExp(r'(\d+\.\d+)°C').firstMatch(text);
    if (tempMatch != null) {
      vitalSigns['temperature'] = '${tempMatch.group(1)}°C';
    }

    return vitalSigns;
  }

  List<String> _extractRecommendations(String text) {
    final recommendations = <String>[];
    
    if (text.toLowerCase().contains('kan şekeri takibi')) {
      recommendations.add('Kan şekeri takibi');
    }
    if (text.toLowerCase().contains('kan basıncı kontrolü')) {
      recommendations.add('Kan basıncı kontrolü');
    }
    if (text.toLowerCase().contains('diyet ve egzersiz')) {
      recommendations.add('Diyet ve egzersiz');
    }

    return recommendations;
  }

  // Akıllı ilaç önerileri
  Future<List<SmartPrescriptionRecommendation>> generateSmartPrescriptions(
    PatientReportAnalysis analysis,
  ) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // AI işleme simülasyonu

      final recommendations = <SmartPrescriptionRecommendation>[];

      // Tanılara göre öneriler
      for (var diagnosis in analysis.detectedDiagnoses) {
        switch (diagnosis) {
          case 'Tip 2 Diabetes Mellitus':
            recommendations.add(SmartPrescriptionRecommendation(
              id: 'tr_metformin',
              drugName: 'Metformin',
              dosage: '500mg',
              frequency: 'Günde 2 kez',
              duration: 'Sürekli',
              reason: 'Kan şekeri kontrolü için birinci basamak tedavi',
              monitoring: 'Kan şekeri, böbrek fonksiyonları',
              contraindications: ['Böbrek yetmezliği', 'Karaciğer yetmezliği'],
              confidence: 0.9,
              category: 'Antidiabetik',
              atcCode: 'A10BA02',
              manufacturer: 'Demo Üretici',
            ));
            break;

          case 'Hipertansiyon':
            recommendations.add(SmartPrescriptionRecommendation(
              id: 'tr_lisinopril',
              drugName: 'Lisinopril',
              dosage: '10mg',
              frequency: 'Günde 1 kez',
              duration: 'Sürekli',
              reason: 'Kan basıncı kontrolü için ACE inhibitörü',
              monitoring: 'Kan basıncı, böbrek fonksiyonları',
              contraindications: ['Hamilelik', 'Bilateral renal artery stenosis'],
              confidence: 0.85,
              category: 'ACE İnhibitörü',
              atcCode: 'C09AA03',
              manufacturer: 'Demo Üretici',
            ));
            break;

          case 'Depresyon':
            recommendations.add(SmartPrescriptionRecommendation(
              id: 'tr_fluoxetine',
              drugName: 'Fluoksetin',
              dosage: '20mg',
              frequency: 'Günde 1 kez',
              duration: '6-12 ay',
              reason: 'Depresyon tedavisi için SSRI',
              monitoring: 'Ruh hali, intihar düşünceleri',
              contraindications: ['MAO inhibitörü kullanımı'],
              confidence: 0.8,
              category: 'SSRI',
              atcCode: 'N06AB03',
              manufacturer: 'Demo Üretici',
            ));
            break;
        }
      }

      // Semptomlara göre öneriler
      for (var symptom in analysis.detectedSymptoms) {
        switch (symptom) {
          case 'Baş Ağrısı':
            recommendations.add(SmartPrescriptionRecommendation(
              id: 'tr_paracetamol',
              drugName: 'Parasetamol',
              dosage: '500mg',
              frequency: 'Günde 3 kez',
              duration: '3-5 gün',
              reason: 'Baş ağrısı için analjezik',
              monitoring: 'Ağrı skorları',
              contraindications: ['Karaciğer yetmezliği'],
              confidence: 0.75,
              category: 'Analjezik',
              atcCode: 'N02BE01',
              manufacturer: 'Demo Üretici',
            ));
            break;
        }
      }

      // Laboratuvar sonuçlarına göre öneriler
      if (analysis.vitalSigns['blood_pressure'] != null) {
        final bp = analysis.vitalSigns['blood_pressure'] as Map<String, dynamic>;
        final systolic = bp['systolic'] as int;
        
        if (systolic > 140) {
          recommendations.add(SmartPrescriptionRecommendation(
            id: 'tr_amlodipine',
            drugName: 'Amlodipin',
            dosage: '5mg',
            frequency: 'Günde 1 kez',
            duration: 'Sürekli',
            reason: 'Yüksek sistolik kan basıncı için kalsiyum kanal blokeri',
            monitoring: 'Kan basıncı, periferik ödem',
            contraindications: ['Kardiyojenik şok'],
            confidence: 0.8,
            category: 'Kalsiyum Kanal Blokeri',
            atcCode: 'C08CA01',
            manufacturer: 'Demo Üretici',
          ));
        }
      }

      // Etkileşim kontrolü
      final filteredRecommendations = <SmartPrescriptionRecommendation>[];
      for (var rec in recommendations) {
        final isCompatible = await _interactionService.checkDrugCompatibility(
          rec.id,
          analysis.detectedMedications,
          analysis.detectedAllergies,
          analysis.detectedDiagnoses,
        );
        
        if (isCompatible) {
          filteredRecommendations.add(rec);
        }
      }

      return filteredRecommendations;

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Demo PDF oluşturma
  Future<Uint8List> createDemoPatientReport() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('HASTA RAPORU', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              
              pw.Text('Hasta Adı: Ahmet Yılmaz', style: pw.TextStyle(fontSize: 14)),
              pw.Text('Yaş: 45', style: pw.TextStyle(fontSize: 14)),
              pw.Text('Cinsiyet: Erkek', style: pw.TextStyle(fontSize: 14)),
              pw.Text('Tarih: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 20),
              
              pw.Header(
                level: 1,
                child: pw.Text('LABORATUVAR SONUÇLARI', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text('• Hemoglobin: 12.5 g/dL (Normal: 12-16)', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Glukoz: 180 mg/dL (Yüksek: >126)', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Kreatinin: 1.2 mg/dL (Normal: 0.7-1.3)', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• ALT: 45 U/L (Normal: 7-56)', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• TSH: 4.5 mIU/L (Yüksek: >4.0)', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              
              pw.Header(
                level: 1,
                child: pw.Text('VİTAL BULGULAR', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text('• Kan Basıncı: 150/95 mmHg (Yüksek)', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Nabız: 85/dk', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Ateş: 36.8°C', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Oksijen Saturasyonu: %98', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              
              pw.Header(
                level: 1,
                child: pw.Text('TANI', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              
              pw.Text('• Tip 2 Diabetes Mellitus', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Hipertansiyon', style: pw.TextStyle(fontSize: 12)),
              pw.Text('• Subklinik Hipotiroidizm', style: pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
    
    return pdf.save();
  }
}
