import 'package:flutter/foundation.dart';
// import 'package:pdf_text/pdf_text.dart'; // Paket mevcut değil, demo modda çalışıyor
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io';

class RealPDFReaderService extends ChangeNotifier {
  static final RealPDFReaderService _instance = RealPDFReaderService._internal();
  factory RealPDFReaderService() => _instance;
  RealPDFReaderService._internal();

  bool _isProcessing = false;
  String? _lastExtractedText;
  Map<String, dynamic> _lastMetadata = {};

  bool get isProcessing => _isProcessing;
  String? get lastExtractedText => _lastExtractedText;
  Map<String, dynamic> get lastMetadata => _lastMetadata;

  void initialize() {
    // Servis başlatma
  }

  // PDF'den metin çıkarma (Demo mod)
  Future<String> extractTextFromPDF(Uint8List pdfData) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Demo mod: PDF paketi mevcut değil, demo metin döndür
      await Future.delayed(const Duration(seconds: 2)); // Simülasyon
      
      // Metadata çıkar
      _lastMetadata = {
        'page_count': 1,
        'extraction_date': DateTime.now().toIso8601String(),
        'file_size': pdfData.length,
        'mode': 'demo',
      };

      _lastExtractedText = _getDemoText();
      return _lastExtractedText!;

    } catch (e) {
      if (kDebugMode) {
        print('PDF metin çıkarma hatası: $e');
      }
      
      // Fallback: Demo metin
      _lastExtractedText = _getDemoText();
      return _lastExtractedText!;
      
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Dosyadan PDF okuma
  Future<String> extractTextFromFile(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    return await extractTextFromPDF(bytes);
  }

  // FilePicker ile PDF seçme
  Future<String?> pickAndExtractPDF() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes != null) {
          return await extractTextFromPDF(file.bytes!);
        }
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('PDF seçme hatası: $e');
      }
      return null;
    }
  }

  // Metin temizleme ve iyileştirme
  String cleanExtractedText(String rawText) {
    // Gereksiz boşlukları temizle
    String cleaned = rawText.replaceAll(RegExp(r'\s+'), ' ');
    
    // Satır sonlarını düzenle
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    
    // Özel karakterleri temizle
    cleaned = cleaned.replaceAll(RegExp(r'[^\w\s\.,;:!?\-\(\)\[\]\/]'), '');
    
    return cleaned.trim();
  }

  // PDF sayfa sayısı (Demo mod)
  Future<int> getPageCount(Uint8List pdfData) async {
    try {
      // Demo mod: Sabit sayfa sayısı döndür
      return 1;
    } catch (e) {
      return 0;
    }
  }

  // PDF boyutu kontrolü
  bool isValidPDFSize(Uint8List pdfData) {
    const maxSize = 10 * 1024 * 1024; // 10MB
    return pdfData.length <= maxSize;
  }

  // Demo metin (fallback)
  String _getDemoText() {
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
}
