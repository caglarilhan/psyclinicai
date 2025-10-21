import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'drug_database_service.dart';

class DrugRecognitionResult {
  final String? drugName;
  final String? dosage;
  final String? manufacturer;
  final double confidence;
  final List<String> recognizedTexts;
  final DrugInfo? matchedDrug;

  DrugRecognitionResult({
    this.drugName,
    this.dosage,
    this.manufacturer,
    required this.confidence,
    required this.recognizedTexts,
    this.matchedDrug,
  });
}

class DrugImageRecognitionService extends ChangeNotifier {
  static final DrugImageRecognitionService _instance = DrugImageRecognitionService._internal();
  factory DrugImageRecognitionService() => _instance;
  DrugImageRecognitionService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();
  final DrugDatabaseService _drugService = DrugDatabaseService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  void initialize() {
    // Servis başlatma
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }

  // Kamera ile fotoğraf çekme
  Future<DrugRecognitionResult?> captureAndRecognizeDrug() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) return null;

      return await _recognizeDrugFromImage(File(image.path));
    } catch (e) {
      if (kDebugMode) {
        print('Kamera ile fotoğraf çekme hatası: $e');
      }
      return null;
    }
  }

  // Galeri'den fotoğraf seçme
  Future<DrugRecognitionResult?> selectAndRecognizeDrug() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return null;

      return await _recognizeDrugFromImage(File(image.path));
    } catch (e) {
      if (kDebugMode) {
        print('Galeri\'den fotoğraf seçme hatası: $e');
      }
      return null;
    }
  }

  // Resimden ilaç tanıma
  Future<DrugRecognitionResult> _recognizeDrugFromImage(File imageFile) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // OCR ile metin tanıma
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      final recognizedTexts = <String>[];
      String? drugName;
      String? dosage;
      String? manufacturer;

      // Tanınan metinleri analiz et
      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          final text = line.text.trim();
          if (text.isNotEmpty) {
            recognizedTexts.add(text);
            
            // İlaç adı tespiti
            if (drugName == null) {
              drugName = _extractDrugName(text);
            }
            
            // Dozaj tespiti
            if (dosage == null) {
              dosage = _extractDosage(text);
            }
            
            // Üretici tespiti
            if (manufacturer == null) {
              manufacturer = _extractManufacturer(text);
            }
          }
        }
      }

      // Veritabanında eşleşen ilaç ara
      DrugInfo? matchedDrug;
      if (drugName != null) {
        matchedDrug = _findMatchingDrug(drugName, dosage);
      }

      // Güven skoru hesapla
      double confidence = _calculateConfidence(recognizedTexts, drugName, dosage);

      return DrugRecognitionResult(
        drugName: drugName,
        dosage: dosage,
        manufacturer: manufacturer,
        confidence: confidence,
        recognizedTexts: recognizedTexts,
        matchedDrug: matchedDrug,
      );

    } catch (e) {
      if (kDebugMode) {
        print('İlaç tanıma hatası: $e');
      }
      return DrugRecognitionResult(
        confidence: 0.0,
        recognizedTexts: [],
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  String? _extractDrugName(String text) {
    // İlaç adı pattern'leri
    final patterns = [
      RegExp(r'([A-Z][a-z]+(?: [A-Z][a-z]+)*)', caseSensitive: false), // Büyük harfle başlayan kelimeler
      RegExp(r'([A-Z]{2,}[a-z]*)', caseSensitive: false), // Kısaltmalar
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final candidate = match.group(1);
        if (candidate != null && candidate.length > 2) {
          return candidate;
        }
      }
    }

    return null;
  }

  String? _extractDosage(String text) {
    // Dozaj pattern'leri
    final patterns = [
      RegExp(r'(\d+(?:\.\d+)?\s*(?:mg|g|ml|mcg|µg))', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d+)?\s*(?:mg|g|ml|mcg|µg)/\d+(?:\.\d+)?\s*(?:mg|g|ml|mcg|µg))', caseSensitive: false),
    ];

    for (var pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  String? _extractManufacturer(String text) {
    // Üretici firma pattern'leri
    final manufacturerKeywords = [
      'Pfizer', 'Novartis', 'Roche', 'Sanofi', 'GSK', 'Merck', 'Johnson',
      'Bayer', 'AstraZeneca', 'Abbott', 'Eli Lilly', 'Bristol Myers',
      'Takeda', 'Boehringer', 'Servier', 'Lundbeck', 'Teva', 'Sandoz',
      'Abdi İbrahim', 'Bilim İlaç', 'Eczacıbaşı', 'İlko', 'Deva',
    ];

    for (var keyword in manufacturerKeywords) {
      if (text.toLowerCase().contains(keyword.toLowerCase())) {
        return keyword;
      }
    }

    return null;
  }

  DrugInfo? _findMatchingDrug(String? drugName, String? dosage) {
    if (drugName == null) return null;

    final searchResults = _drugService.searchDrugs(drugName);
    
    if (searchResults.isEmpty) return null;

    // Tam eşleşme ara
    for (var drug in searchResults) {
      if (drug.genericName.toLowerCase() == drugName.toLowerCase() ||
          drug.brandName.toLowerCase() == drugName.toLowerCase()) {
        return drug;
      }
    }

    // Kısmi eşleşme ara
    for (var drug in searchResults) {
      if (drug.genericName.toLowerCase().contains(drugName.toLowerCase()) ||
          drug.brandName.toLowerCase().contains(drugName.toLowerCase())) {
        return drug;
      }
    }

    return searchResults.first; // En iyi eşleşme
  }

  double _calculateConfidence(List<String> texts, String? drugName, String? dosage) {
    double confidence = 0.0;

    // Temel güven skoru
    if (texts.isNotEmpty) confidence += 0.3;
    if (drugName != null) confidence += 0.4;
    if (dosage != null) confidence += 0.3;

    // Metin kalitesi
    final totalTextLength = texts.fold(0, (sum, text) => sum + text.length);
    if (totalTextLength > 20) confidence += 0.1;
    if (totalTextLength > 50) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  // Demo resim tanıma (test için)
  Future<DrugRecognitionResult> recognizeDemoDrug() async {
    _isProcessing = true;
    notifyListeners();

    // Demo veri
    await Future.delayed(const Duration(seconds: 2));

    final result = DrugRecognitionResult(
      drugName: 'Parasetamol',
      dosage: '500mg',
      manufacturer: 'Bilim İlaç',
      confidence: 0.85,
      recognizedTexts: [
        'PAROL',
        '500mg',
        'Parasetamol',
        'Bilim İlaç San. ve Tic. A.Ş.',
        'Tablet',
        '30 tablet',
      ],
      matchedDrug: _drugService.getDrugById('tr_paracetamol'),
    );

    _isProcessing = false;
    notifyListeners();

    return result;
  }
}
