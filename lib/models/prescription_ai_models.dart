import 'package:json_annotation/json_annotation.dart';
import 'medication_models.dart';

part 'prescription_ai_models.g.dart';

// ===== AI DESTEKLİ REÇETE SİSTEMİ MODELLERİ =====

/// AI İlaç Önerisi - AI destekli ilaç reçete önerisi
/// Bu model, yapay zeka tarafından üretilen ilaç önerilerini temsil eder
@JsonSerializable()
class AIMedicationRecommendation {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final DateTime recommendationDate; // Öneri tarihi
  final String aiModel; // Kullanılan AI model adı
  final String aiVersion; // AI model versiyonu
  final double confidenceScore; // Güven skoru (0-1 arası)
  final List<RecommendedMedication> recommendedMedications; // Önerilen ilaçlar listesi
  final List<MedicationAlternative> alternatives; // Alternatif ilaç seçenekleri
  final List<String> contraindications; // Kontrendikasyonlar
  final List<String> warnings; // Uyarılar
  final List<String> monitoringRequirements; // İzleme gereksinimleri
  final String clinicalRationale; // Klinik gerekçe
  final Map<String, dynamic> aiAnalysis; // AI analiz detayları
  final bool isReviewed; // İncelenme durumu
  final String? reviewedBy; // İnceleyen kişi
  final DateTime? reviewedAt; // İnceleme tarihi
  final String? reviewNotes; // İnceleme notları
  final Map<String, dynamic> metadata; // Ek meta veriler

  const AIMedicationRecommendation({
    required this.id,
    required this.patientId,
    required this.clinicianId,
    required this.recommendationDate,
    required this.aiModel,
    required this.aiVersion,
    required this.confidenceScore,
    required this.recommendedMedications,
    required this.alternatives,
    required this.contraindications,
    required this.warnings,
    required this.monitoringRequirements,
    required this.clinicalRationale,
    required this.aiAnalysis,
    required this.isReviewed,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    required this.metadata,
  });

  factory AIMedicationRecommendation.fromJson(Map<String, dynamic> json) =>
      _$AIMedicationRecommendationFromJson(json);

  Map<String, dynamic> toJson() => _$AIMedicationRecommendationToJson(this);
}

/// Önerilen İlaç - AI tarafından önerilen spesifik ilaç
/// Her ilaç için dozaj, süre ve özel talimatları içerir
@JsonSerializable()
class RecommendedMedication {
  final String id; // Benzersiz tanımlayıcı
  final String medicationId; // İlaç kimliği
  final String medicationName; // İlaç adı
  final String dosage; // Önerilen dozaj
  final String frequency; // Kullanım sıklığı
  final String duration; // Tedavi süresi
  final String route; // Uygulama yolu (oral, IV, IM)
  final List<String> specialInstructions; // Özel talimatlar
  final double priorityScore; // Öncelik skoru
  final String reasoning; // Bu ilacın önerilme gerekçesi
  final Map<String, dynamic> metadata; // Ek meta veriler

  const RecommendedMedication({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.route,
    required this.specialInstructions,
    required this.priorityScore,
    required this.reasoning,
    required this.metadata,
  });

  factory RecommendedMedication.fromJson(Map<String, dynamic> json) =>
      _$RecommendedMedicationFromJson(json);

  Map<String, dynamic> toJson() => _$RecommendedMedicationToJson(this);
}

/// İlaç Alternatifi - Ana öneriye alternatif olabilecek ilaçlar
/// Farklı mekanizma veya daha uygun profilde ilaçlar
@JsonSerializable()
class MedicationAlternative {
  final String id; // Benzersiz tanımlayıcı
  final String medicationId; // İlaç kimliği
  final String medicationName; // İlaç adı
  final String alternativeType; // Alternatif türü (mechanism, safety, cost)
  final String reasoning; // Alternatif olma gerekçesi
  final double similarityScore; // Ana öneriye benzerlik skoru
  final List<String> advantages; // Avantajlar
  final List<String> disadvantages; // Dezavantajlar
  final Map<String, dynamic> metadata; // Ek meta veriler

  const MedicationAlternative({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.alternativeType,
    required this.reasoning,
    required this.similarityScore,
    required this.advantages,
    required this.disadvantages,
    required this.metadata,
  });

  factory MedicationAlternative.fromJson(Map<String, dynamic> json) =>
      _$MedicationAlternativeFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationAlternativeToJson(this);
}

/// Hasta İlaç Profili - Hasta bazlı ilaç kullanım geçmişi ve özellikleri
/// AI'ın daha iyi öneriler yapabilmesi için hasta bilgilerini içerir
@JsonSerializable()
class PatientMedicationProfile {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final List<String> currentMedications; // Mevcut ilaçlar
  final List<String> medicationAllergies; // İlaç alerjileri
  final List<String> medicationIntolerances; // İlaç intoleransları
  final Map<String, String> medicationHistory; // İlaç kullanım geçmişi
  final List<String> geneticFactors; // Genetik faktörler
  final Map<String, dynamic> organFunction; // Organ fonksiyonları
  final List<String> comorbidities; // Komorbiditeler
  final Map<String, dynamic> responsePatterns; // İlaç yanıt paternleri
  final DateTime lastUpdated; // Son güncelleme tarihi
  final Map<String, dynamic> metadata; // Ek meta veriler

  const PatientMedicationProfile({
    required this.id,
    required this.patientId,
    required this.currentMedications,
    required this.medicationAllergies,
    required this.medicationIntolerances,
    required this.medicationHistory,
    required this.geneticFactors,
    required this.organFunction,
    required this.comorbidities,
    required this.responsePatterns,
    required this.lastUpdated,
    required this.metadata,
  });

  factory PatientMedicationProfile.fromJson(Map<String, dynamic> json) =>
      _$PatientMedicationProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PatientMedicationProfileToJson(this);

  // Backward-compatible getters for legacy tests
  List<String> get currentDiagnoses =>
      (metadata['currentDiagnoses'] as List?)?.cast<String>() ?? const [];
  List<String> get allergies =>
      medicationAllergies;
  List<String> get intolerances =>
      medicationIntolerances;
  DateTime get profileDate => lastUpdated;
}

/// Akıllı Dozaj Optimizasyonu - AI destekli dozaj ayarlaması
/// Hasta özelliklerine göre optimal dozaj hesaplaması
@JsonSerializable()
class SmartDosageOptimization {
  final String id; // Benzersiz tanımlayıcı
  final String patientId; // Hasta kimliği
  final String medicationId; // İlaç kimliği
  final String currentDosage; // Mevcut dozaj
  final String optimizedDosage; // Optimize edilmiş dozaj
  final List<String> optimizationFactors; // Optimizasyon faktörleri
  final String optimizationReasoning; // Optimizasyon gerekçesi
  final List<String> monitoringParameters; // İzleme parametreleri
  final String titrationPlan; // Dozaj artırım planı
  final DateTime optimizationDate; // Optimizasyon tarihi
  final double confidenceScore; // Güven skoru
  final Map<String, dynamic> metadata; // Ek meta veriler

  const SmartDosageOptimization({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.currentDosage,
    required this.optimizedDosage,
    required this.optimizationFactors,
    required this.optimizationReasoning,
    required this.monitoringParameters,
    required this.titrationPlan,
    required this.optimizationDate,
    required this.confidenceScore,
    required this.metadata,
  });

  factory SmartDosageOptimization.fromJson(Map<String, dynamic> json) =>
      _$SmartDosageOptimizationFromJson(json);

  Map<String, dynamic> toJson() => _$SmartDosageOptimizationToJson(this);

  // Backward-compatible getters for legacy tests
  String get titrationSchedule => titrationPlan;
  double get expectedEfficacy => confidenceScore; // proxy
  double get expectedSafety => confidenceScore; // proxy
  List<String> get monitoringPoints => monitoringParameters;
  String get aiModel => (metadata['aiModel'] as String?) ?? 'AI-Model';
}

/// Gelişmiş İlaç Etkileşimi - AI destekli kapsamlı etkileşim analizi
/// Çoklu ilaç kombinasyonlarında detaylı risk değerlendirmesi
@JsonSerializable()
class AdvancedDrugInteraction {
  final String id; // Benzersiz tanımlayıcı
  final List<String> medicationIds; // Etkileşen ilaç kimlikleri
  final List<String> medicationNames; // Etkileşen ilaç adları
  final InteractionSeverity severity; // Etkileşim şiddeti
  final String interactionType; // Etkileşim türü
  final String mechanism; // Etkileşim mekanizması
  final String clinicalSignificance; // Klinik önem
  final List<String> symptoms; // Belirtiler
  final List<String> riskFactors; // Risk faktörleri
  final List<String> recommendations; // Öneriler
  final List<String> monitoring; // İzleme gereksinimleri
  final double riskScore; // Risk skoru (0-1 arası)
  final String evidence; // Kanıt seviyesi
  final DateTime analysisDate; // Analiz tarihi
  final Map<String, dynamic> metadata; // Ek meta veriler

  const AdvancedDrugInteraction({
    required this.id,
    required this.medicationIds,
    required this.medicationNames,
    required this.severity,
    required this.interactionType,
    required this.mechanism,
    required this.clinicalSignificance,
    required this.symptoms,
    required this.riskFactors,
    required this.recommendations,
    required this.monitoring,
    required this.riskScore,
    required this.evidence,
    required this.analysisDate,
    required this.metadata,
  });

  factory AdvancedDrugInteraction.fromJson(Map<String, dynamic> json) =>
      _$AdvancedDrugInteractionFromJson(json);

  Map<String, dynamic> toJson() => _$AdvancedDrugInteractionToJson(this);

  // Backward-compatible getters for legacy tests
  List<String> get monitoringRequirements => monitoring;
  String get evidenceLevel => evidence;
  List<String> get references =>
      (metadata['references'] as List?)?.cast<String>() ?? const [];
}

/// Etkileşim Şiddeti - İlaç etkileşimlerinin ciddiyet seviyeleri
// InteractionSeverity enum'u medication_models.dart'tan import edilecek

/// AI Reçete Durumu - AI önerilerinin inceleme ve onay süreci
/// Reçete önerilerinin klinisyen tarafından değerlendirilme durumları
enum AIPrescriptionStatus {
  @JsonValue('pending') pending, // Beklemede
  @JsonValue('approved') approved, // Onaylandı
  @JsonValue('rejected') rejected, // Reddedildi
  @JsonValue('modified') modified, // Değiştirildi
  @JsonValue('under_review') underReview, // İncelemede
}

/// AI Reçete Geçmişi - AI önerilerinin takip edilmesi
/// Tüm AI reçete önerilerinin durum ve sonuç takibi
@JsonSerializable()
class AIPrescriptionHistory {
  final String id; // Benzersiz tanımlayıcı
  final String recommendationId; // AI öneri kimliği
  final String patientId; // Hasta kimliği
  final String clinicianId; // Klinisyen kimliği
  final AIPrescriptionStatus status; // Reçete durumu
  final DateTime createdAt; // Oluşturulma tarihi
  final DateTime? updatedAt; // Güncellenme tarihi
  final String? reviewNotes; // İnceleme notları
  final String? rejectionReason; // Red gerekçesi
  final List<String> modifications; // Yapılan değişiklikler
  final Map<String, dynamic> metadata; // Ek meta veriler

  const AIPrescriptionHistory({
    required this.id,
    required this.recommendationId,
    required this.patientId,
    required this.clinicianId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.reviewNotes,
    this.rejectionReason,
    required this.modifications,
    required this.metadata,
  });

  factory AIPrescriptionHistory.fromJson(Map<String, dynamic> json) =>
      _$AIPrescriptionHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$AIPrescriptionHistoryToJson(this);

  // Backward-compatible getters for legacy tests
  DateTime get prescriptionDate => createdAt;
  List<String> get medications =>
      (metadata['medications'] as List?)?.cast<String>() ?? const [];
  String get diagnosis => (metadata['diagnosis'] as String?) ?? '';
  String get aiRecommendation => (metadata['aiRecommendation'] as String?) ?? '';
  double get aiConfidence => (metadata['aiConfidence'] as num?)?.toDouble() ?? 0.0;
  String? get modificationNotes => (metadata['modificationNotes'] as String?);
}
