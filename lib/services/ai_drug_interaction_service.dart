import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/advanced_drug_info.dart';
import '../models/smart_prescription_models.dart';

class DrugInteractionAnalysis {
  final List<DrugInteraction> interactions;
  final String overallRisk; // "low", "medium", "high"
  final String recommendation;
  final List<String> warnings;
  final double confidenceScore;

  DrugInteractionAnalysis({
    required this.interactions,
    required this.overallRisk,
    required this.recommendation,
    required this.warnings,
    required this.confidenceScore,
  });
}

class DrugRecommendation {
  final String drugId;
  final String reason;
  final String alternative;
  final String dosage;
  final String monitoring;
  final double confidence;

  DrugRecommendation({
    required this.drugId,
    required this.reason,
    required this.alternative,
    required this.dosage,
    required this.monitoring,
    required this.confidence,
  });
}

class AIDrugInteractionService extends ChangeNotifier {
  static final AIDrugInteractionService _instance = AIDrugInteractionService._internal();
  factory AIDrugInteractionService() => _instance;
  AIDrugInteractionService._internal();

  final Map<String, List<DrugInteraction>> _interactionDatabase = {};
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  void initialize() {
    _loadInteractionDatabase();
  }

  void _loadInteractionDatabase() {
    // Demo etkileşim veritabanı
    _interactionDatabase['tr_paracetamol'] = [
      DrugInteraction(
        drugId: 'tr_fluoxetine',
        interactionType: 'minor',
        description: 'Parasetamol ve fluoksetin birlikte kullanıldığında karaciğer enzimleri artabilir',
        mechanism: 'CYP2D6 enzim inhibisyonu',
        recommendation: 'Karaciğer fonksiyonlarını takip edin',
        severity: 'low',
      ),
      DrugInteraction(
        drugId: 'tr_omeprazole',
        interactionType: 'moderate',
        description: 'Omeprazol parasetamolün emilimini azaltabilir',
        mechanism: 'Mide pH değişikliği',
        recommendation: '2 saat arayla alın',
        severity: 'medium',
      ),
    ];

    _interactionDatabase['tr_fluoxetine'] = [
      DrugInteraction(
        drugId: 'tr_paracetamol',
        interactionType: 'minor',
        description: 'Fluoksetin parasetamolün metabolizmasını etkileyebilir',
        mechanism: 'CYP2D6 enzim inhibisyonu',
        recommendation: 'Karaciğer fonksiyonlarını takip edin',
        severity: 'low',
      ),
      DrugInteraction(
        drugId: 'tr_metformin',
        interactionType: 'major',
        description: 'Fluoksetin ve metformin birlikte kullanıldığında hipoglisemi riski artar',
        mechanism: 'İnsülin duyarlılığı artışı',
        recommendation: 'Kan şekeri sıkı takip edilmeli',
        severity: 'high',
      ),
    ];

    _interactionDatabase['tr_metformin'] = [
      DrugInteraction(
        drugId: 'tr_fluoxetine',
        interactionType: 'major',
        description: 'Metformin ve fluoksetin birlikte kullanıldığında hipoglisemi riski artar',
        mechanism: 'İnsülin duyarlılığı artışı',
        recommendation: 'Kan şekeri sıkı takip edilmeli',
        severity: 'high',
      ),
    ];

    _interactionDatabase['tr_omeprazole'] = [
      DrugInteraction(
        drugId: 'tr_paracetamol',
        interactionType: 'moderate',
        description: 'Omeprazol parasetamolün emilimini azaltabilir',
        mechanism: 'Mide pH değişikliği',
        recommendation: '2 saat arayla alın',
        severity: 'medium',
      ),
    ];
  }

  // İlaç etkileşim analizi
  Future<DrugInteractionAnalysis> analyzeDrugInteractions(
    List<String> drugIds,
    String patientAge,
    String patientGender,
    List<String> existingConditions,
  ) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // AI işleme simülasyonu

      final interactions = <DrugInteraction>[];
      final warnings = <String>[];

      // İlaç çiftlerini kontrol et
      for (int i = 0; i < drugIds.length; i++) {
        for (int j = i + 1; j < drugIds.length; j++) {
          final drug1 = drugIds[i];
          final drug2 = drugIds[j];

          // Etkileşim ara
          final interaction1 = _interactionDatabase[drug1]?.firstWhere(
            (interaction) => interaction.drugId == drug2,
            orElse: () => DrugInteraction(
              drugId: drug2,
              interactionType: 'none',
              description: 'Bilinen etkileşim yok',
              mechanism: '',
              recommendation: 'Normal kullanım',
              severity: 'low',
            ),
          );

          final interaction2 = _interactionDatabase[drug2]?.firstWhere(
            (interaction) => interaction.drugId == drug1,
            orElse: () => DrugInteraction(
              drugId: drug1,
              interactionType: 'none',
              description: 'Bilinen etkileşim yok',
              mechanism: '',
              recommendation: 'Normal kullanım',
              severity: 'low',
            ),
          );

          if (interaction1 != null && interaction1.interactionType != 'none') {
            interactions.add(interaction1);
          }
          if (interaction2 != null && interaction2.interactionType != 'none') {
            interactions.add(interaction2);
          }
        }
      }

      // AI analizi simülasyonu
      final analysis = _performAIAnalysis(
        interactions,
        patientAge,
        patientGender,
        existingConditions,
      );

      return analysis;

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  DrugInteractionAnalysis _performAIAnalysis(
    List<DrugInteraction> interactions,
    String patientAge,
    String patientGender,
    List<String> existingConditions,
  ) {
    // Risk seviyesi hesaplama
    String overallRisk = 'low';
    if (interactions.any((i) => i.severity == 'high')) {
      overallRisk = 'high';
    } else if (interactions.any((i) => i.severity == 'medium')) {
      overallRisk = 'medium';
    }

    // Uyarılar oluştur
    final warnings = <String>[];
    if (overallRisk == 'high') {
      warnings.add('⚠️ Yüksek riskli ilaç etkileşimi tespit edildi');
    }
    if (patientAge == '65+') {
      warnings.add('👴 Yaşlı hasta - dozaj ayarlaması gerekebilir');
    }
    if (existingConditions.contains('Karaciğer Hastalığı')) {
      warnings.add('🫀 Karaciğer hastalığı - metabolizma etkilenebilir');
    }
    if (existingConditions.contains('Böbrek Hastalığı')) {
      warnings.add('🫘 Böbrek hastalığı - eliminasyon etkilenebilir');
    }

    // Öneriler
    String recommendation = 'Normal kullanım önerilir';
    if (overallRisk == 'high') {
      recommendation = 'İlaç kombinasyonu yeniden değerlendirilmeli';
    } else if (overallRisk == 'medium') {
      recommendation = 'Hasta yakın takip edilmeli';
    }

    // Güven skoru
    double confidenceScore = 0.8;
    if (interactions.isEmpty) {
      confidenceScore = 0.9;
    } else if (interactions.length > 3) {
      confidenceScore = 0.7;
    }

    return DrugInteractionAnalysis(
      interactions: interactions,
      overallRisk: overallRisk,
      recommendation: recommendation,
      warnings: warnings,
      confidenceScore: confidenceScore,
    );
  }

  // İlaç önerileri
  Future<List<DrugRecommendation>> getDrugRecommendations(
    String condition,
    List<String> currentDrugs,
    String patientAge,
    String patientGender,
    List<String> allergies,
  ) async {
    _isProcessing = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 3)); // AI işleme simülasyonu

      final recommendations = <DrugRecommendation>[];

      // Koşula göre öneriler
      switch (condition.toLowerCase()) {
        case 'depresyon':
          recommendations.addAll([
            DrugRecommendation(
              drugId: 'tr_fluoxetine',
              reason: 'Depresyon için birinci basamak tedavi',
              alternative: 'Sertralin',
              dosage: '20mg/gün',
              monitoring: 'İlk 2 hafta intihar düşünceleri takip edilmeli',
              confidence: 0.85,
            ),
            DrugRecommendation(
              drugId: 'tr_sertraline',
              reason: 'Daha az yan etki profili',
              alternative: 'Fluoksetin',
              dosage: '50mg/gün',
              monitoring: 'Karaciğer fonksiyonları',
              confidence: 0.80,
            ),
          ]);
          break;

        case 'anksiyete':
          recommendations.addAll([
            DrugRecommendation(
              drugId: 'tr_fluoxetine',
              reason: 'Anksiyete bozukluğu için etkili',
              alternative: 'Sertralin',
              dosage: '20mg/gün',
              monitoring: 'Anksiyete skorları',
              confidence: 0.82,
            ),
          ]);
          break;

        case 'ağrı':
          recommendations.addAll([
            DrugRecommendation(
              drugId: 'tr_paracetamol',
              reason: 'Güvenli analjezik',
              alternative: 'İbuprofen',
              dosage: '500mg 3x/gün',
              monitoring: 'Karaciğer fonksiyonları',
              confidence: 0.90,
            ),
          ]);
          break;
      }

      // Mevcut ilaçlarla etkileşim kontrolü
      for (var rec in recommendations) {
        final hasInteraction = currentDrugs.any((drug) =>
            _interactionDatabase[drug]?.any((interaction) =>
                interaction.drugId == rec.drugId &&
                interaction.severity == 'high') ?? false);

        if (hasInteraction) {
          rec = DrugRecommendation(
            drugId: rec.drugId,
            reason: '${rec.reason} (Etkileşim uyarısı ile)',
            alternative: rec.alternative,
            dosage: rec.dosage,
            monitoring: '${rec.monitoring}. Etkileşim takip edilmeli.',
            confidence: rec.confidence * 0.8,
          );
        }
      }

      return recommendations;

    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  // İlaç uyumluluk kontrolü
  Future<bool> checkDrugCompatibility(
    String drugId,
    List<String> currentDrugs,
    List<String> allergies,
    List<String> conditions,
  ) async {
    // Alerji kontrolü
    if (allergies.contains(drugId)) {
      return false;
    }

    // Etkileşim kontrolü
    for (var drug in currentDrugs) {
      final interactions = _interactionDatabase[drug];
      if (interactions != null) {
        final hasMajorInteraction = interactions.any((interaction) =>
            interaction.drugId == drugId && interaction.severity == 'high');
        if (hasMajorInteraction) {
          return false;
        }
      }
    }

    return true;
  }

  // Etkileşim veritabanına ekleme
  void addInteraction(String drugId, DrugInteraction interaction) {
    _interactionDatabase[drugId] ??= [];
    _interactionDatabase[drugId]!.add(interaction);
    notifyListeners();
  }

  // Etkileşim veritabanından silme
  void removeInteraction(String drugId, String targetDrugId) {
    _interactionDatabase[drugId]?.removeWhere(
      (interaction) => interaction.drugId == targetDrugId,
    );
    notifyListeners();
  }

  // AI ilaç önerileri alma
  Future<List<SmartPrescriptionRecommendation>> getAIDrugRecommendations(
    String patientId,
    List<String> diagnoses,
    List<String> symptoms,
    List<String> allergies,
  ) async {
    await Future.delayed(const Duration(seconds: 2)); // Simülasyon

    List<SmartPrescriptionRecommendation> recommendations = [];

    // Tanı bazlı öneriler
    for (String diagnosis in diagnoses) {
      if (diagnosis.toLowerCase().contains('diabetes') || diagnosis.toLowerCase().contains('diyabet')) {
        recommendations.add(SmartPrescriptionRecommendation(
          id: 'metformin_ai',
          drugName: 'Metformin',
          dosage: '500mg',
          frequency: 'Günde 2 kez',
          duration: 'Sürekli',
          reason: 'Tip 2 Diabetes Mellitus tedavisi',
          monitoring: 'Böbrek fonksiyonları kontrol edilmeli',
          contraindications: ['Böbrek yetmezliği'],
          confidence: 0.9,
          category: 'Antidiabetik',
          atcCode: 'A10BA02',
          manufacturer: 'Demo Üretici',
        ));
      }
      if (diagnosis.toLowerCase().contains('hypertension') || diagnosis.toLowerCase().contains('hipertansiyon')) {
        recommendations.add(SmartPrescriptionRecommendation(
          id: 'lisinopril_ai',
          drugName: 'Lisinopril',
          dosage: '10mg',
          frequency: 'Günde 1 kez',
          duration: 'Sürekli',
          reason: 'Esansiyel Hipertansiyon tedavisi',
          monitoring: 'Potasyum seviyeleri kontrol edilmeli',
          contraindications: ['Hamilelik'],
          confidence: 0.85,
          category: 'ACE İnhibitörü',
          atcCode: 'C09AA03',
          manufacturer: 'Demo Üretici',
        ));
      }
      if (diagnosis.toLowerCase().contains('hypothyroidism') || diagnosis.toLowerCase().contains('hipotiroidizm')) {
        recommendations.add(SmartPrescriptionRecommendation(
          id: 'levotiroksin_ai',
          drugName: 'Levotiroksin',
          dosage: '50mcg',
          frequency: 'Günde 1 kez',
          duration: 'Sürekli',
          reason: 'Hipotiroidizm tedavisi',
          monitoring: 'TSH seviyeleri düzenli kontrol edilmeli',
          contraindications: ['Hipertiroidizm'],
          confidence: 0.95,
          category: 'Tiroid Hormonu',
          atcCode: 'H03AA01',
          manufacturer: 'Demo Üretici',
        ));
      }
    }

    // Semptom bazlı öneriler
    for (String symptom in symptoms) {
      if (symptom.toLowerCase().contains('ağrı') || symptom.toLowerCase().contains('pain')) {
        recommendations.add(SmartPrescriptionRecommendation(
          id: 'parasetamol_ai',
          drugName: 'Parasetamol',
          dosage: '500mg',
          frequency: 'Günde 3 kez',
          duration: '3-5 gün',
          reason: 'Ağrı kesici',
          monitoring: 'Karaciğer fonksiyonları kontrol edilmeli',
          contraindications: ['Karaciğer yetmezliği'],
          confidence: 0.7,
          category: 'Analjezik',
          atcCode: 'N02BE01',
          manufacturer: 'Demo Üretici',
        ));
      }
      if (symptom.toLowerCase().contains('ateş') || symptom.toLowerCase().contains('fever')) {
        recommendations.add(SmartPrescriptionRecommendation(
          id: 'ibuprofen_ai',
          drugName: 'İbuprofen',
          dosage: '400mg',
          frequency: 'Günde 3 kez',
          duration: '3-5 gün',
          reason: 'Ateş ve inflamasyon',
          monitoring: 'Mide problemleri olabilir',
          contraindications: ['Mide ülseri'],
          confidence: 0.75,
          category: 'NSAID',
          atcCode: 'M01AE01',
          manufacturer: 'Demo Üretici',
        ));
      }
    }

    return recommendations;
  }
}
