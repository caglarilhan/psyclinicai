import 'dart:convert';
import 'dart:math';
import '../models/ai_models.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  Future<void> initialize() async {
    // No-op initialization for now; reserved for API keys/session setup
  }

  Future<String> generateResponse(String prompt) async {
    // Minimal mock LLM response for orchestration flows
    await Future.delayed(const Duration(milliseconds: 300));
    final preview = prompt.trim();
    final snippet = preview.length > 240 ? preview.substring(0, 240) + '...' : preview;
    return 'AI Response (mock) based on prompt:\n$snippet\n\nInsights:\n- Coherent\n- Safe\n- Role-aware';
  }

  // Dal bazlı AI prompt şablonları
  final Map<ProfessionalType, Map<AIServiceType, String>> _promptTemplates = {
    ProfessionalType.psychologist: {
      AIServiceType.sessionSummary: '''
Sen bir psikologsun. Aşağıdaki seans notlarını analiz et ve profesyonel bir özet hazırla:

Seans Notları: {inputText}

Lütfen şunları içeren bir özet hazırla:
1. Ana konular ve temalar
2. Danışanın duygusal durumu
3. Kullanılan terapi teknikleri
4. İlerleme ve değişimler
5. Sonraki seans için öneriler
6. Ev ödevi veya uygulama önerileri

Psikolog perspektifinden, terapötik süreç odaklı bir yaklaşım benimse.
''',
      AIServiceType.diagnostic: '''
Sen bir psikologsun. Aşağıdaki değerlendirme sonuçlarını analiz et:

Değerlendirme: {inputText}
Puan: {score}

Psikolog olarak şunları değerlendir:
1. Puanın klinik anlamı
2. Olası psikolojik tanılar (DSM-5)
3. Terapötik müdahale önerileri
4. Risk faktörleri
5. Koruyucu faktörler
6. Sonraki değerlendirme önerileri

İlaç önerisi YAPMA, sadece psikolojik müdahaleler öner.
''',
      AIServiceType.riskAssessment: '''
Sen bir psikologsun. Aşağıdaki seans notlarında risk faktörlerini değerlendir:

Seans Notları: {inputText}

Psikolog perspektifinden şunları değerlendir:
1. İntihar riski
2. Kendine zarar verme riski
3. Başkalarına zarar verme riski
4. İhmal/istismar riski
5. Madde kullanımı riski
6. Acil müdahale gerekliliği

Her risk için:
- Risk seviyesi (Düşük/Orta/Yüksek/Kritik)
- Risk faktörleri
- Koruyucu faktörler
- Acil eylemler
- Takip önerileri
''',
      AIServiceType.treatmentSuggestion: '''
Sen bir psikologsun. Aşağıdaki durum için tedavi önerileri hazırla:

Tanı: {diagnosis}
Seans Notları: {inputText}

Psikolog olarak şunları öner:
1. Uygun terapi yaklaşımları (CBT, EMDR, vb.)
2. Terapötik teknikler
3. Seans hedefleri
4. Ev ödevleri
5. İlerleme ölçümleri
6. Süre tahmini

İlaç önerisi YAPMA, sadece psikolojik müdahaleler öner.
''',
    },
    ProfessionalType.psychiatrist: {
      AIServiceType.sessionSummary: '''
Sen bir psikiyatristsin. Aşağıdaki seans notlarını analiz et ve tıbbi özet hazırla:

Seans Notları: {inputText}

Psikiyatrist perspektifinden şunları içeren özet hazırla:
1. Mevcut semptomlar ve şiddeti
2. İlaç yan etkileri ve tolerans
3. Tedavi yanıtı
4. Yaşam kalitesi değişimleri
5. İlaç ayarlama önerileri
6. Laboratuvar takibi gerekliliği
7. Sonraki randevu planı
''',
      AIServiceType.diagnostic: '''
Sen bir psikiyatristsin. Aşağıdaki değerlendirme sonuçlarını analiz et:

Değerlendirme: {inputText}
Puan: {score}

Psikiyatrist olarak şunları değerlendir:
1. Puanın tıbbi anlamı
2. Olası psikiyatrik tanılar (DSM-5/ICD-11)
3. İlaç tedavisi önerileri
4. Dozaj önerileri
5. Yan etki takibi
6. Laboratuvar testleri
7. Konsültasyon gerekliliği
''',
      AIServiceType.riskAssessment: '''
Sen bir psikiyatristsin. Aşağıdaki seans notlarında risk faktörlerini değerlendir:

Seans Notları: {inputText}

Psikiyatrist perspektifinden şunları değerlendir:
1. İntihar riski (tıbbi acil)
2. Agresyon riski
3. İlaç yan etkileri
4. Madde etkileşimleri
5. Tıbbi komplikasyonlar
6. Acil müdahale gerekliliği

Her risk için:
- Risk seviyesi (Düşük/Orta/Yüksek/Kritik)
- Tıbbi müdahale önerileri
- İlaç ayarlamaları
- Acil servis gerekliliği
- Konsültasyon önerileri
''',
      AIServiceType.treatmentSuggestion: '''
Sen bir psikiyatristsin. Aşağıdaki durum için tedavi önerileri hazırla:

Tanı: {diagnosis}
Seans Notları: {inputText}

Psikiyatrist olarak şunları öner:
1. İlaç tedavisi önerileri
2. Dozaj protokolleri
3. Yan etki takibi
4. Laboratuvar testleri
5. Terapi kombinasyonları
6. Takip sıklığı
7. Acil durum protokolleri
''',
    },
    ProfessionalType.therapist: {
      AIServiceType.sessionSummary: '''
Sen bir terapistsin. Aşağıdaki seans notlarını analiz et ve terapötik özet hazırla:

Seans Notları: {inputText}

Terapist perspektifinden şunları içeren özet hazırla:
1. Terapötik ilişki durumu
2. Danışanın motivasyonu
3. Kullanılan teknikler
4. Direnç noktaları
5. İlerleme göstergeleri
6. Sonraki seans planı
7. Ev ödevleri
''',
      AIServiceType.diagnostic: '''
Sen bir terapistsin. Aşağıdaki değerlendirme sonuçlarını analiz et:

Değerlendirme: {inputText}
Puan: {score}

Terapist olarak şunları değerlendir:
1. Terapötik hedefler
2. Müdahale stratejileri
3. Danışan hazırlığı
4. Terapötik teknikler
5. İlerleme ölçümleri
6. Süre tahmini
''',
    },
  };

  // Dal bazlı billing kodları
  final Map<ProfessionalType, Map<String, List<String>>> _billingCodes = {
    ProfessionalType.psychologist: {
      'TR': ['90834', '90837', '90847'], // Psikolog CPT kodları
      'US': ['90834', '90837', '90847'],
      'EU': ['F32.1', 'F33.1', 'F41.1'], // ICD-10 kodları
    },
    ProfessionalType.psychiatrist: {
      'TR': ['90834', '90837', '90847', '90862'], // Psikiyatrist + ilaç yönetimi
      'US': ['90834', '90837', '90847', '90862'],
      'EU': ['F32.1', 'F33.1', 'F41.1', 'Z51.1'], // ICD-10 + ilaç yönetimi
    },
    ProfessionalType.therapist: {
      'TR': ['90834', '90837', '90847'],
      'US': ['90834', '90837', '90847'],
      'EU': ['F32.1', 'F33.1', 'F41.1'],
    },
  };

  Future<SessionSummaryResponse> generateSessionSummary({
    required String sessionNotes,
    required ProfessionalType professionalType,
    required String clientId,
    required String sessionId,
    Map<String, dynamic> assessmentScores = const {},
  }) async {
    // Mock AI response - gerçek uygulamada OpenAI/Anthropic API kullanılır
    await Future.delayed(const Duration(seconds: 2));

    final prompt = _promptTemplates[professionalType]?[AIServiceType.sessionSummary] ?? '';
    
    // Dal bazlı özet üretimi
    final summary = _generateProfessionalSummary(sessionNotes, professionalType);
    final keyFindings = _extractKeyFindings(sessionNotes, professionalType);
    final actionItems = _generateActionItems(sessionNotes, professionalType);
    final followUpTasks = _generateFollowUpTasks(sessionNotes, professionalType);

    return SessionSummaryResponse(
      summary: summary,
      keyFindings: keyFindings,
      actionItems: actionItems,
      followUpTasks: followUpTasks,
      insights: {
        'professionalType': professionalType.name,
        'sessionId': sessionId,
        'clientId': clientId,
      },
      confidence: 0.85 + (Random().nextDouble() * 0.1),
    );
  }

  Future<DiagnosticSuggestion> generateDiagnosticSuggestion({
    required String assessmentType,
    required int score,
    required ProfessionalType professionalType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final severity = _calculateSeverity(assessmentType, score);
    final possibleDiagnoses = _getPossibleDiagnoses(assessmentType, score, professionalType);
    final recommendations = _getRecommendations(assessmentType, score, professionalType);
    final warningSigns = _getWarningSigns(assessmentType, score);

    return DiagnosticSuggestion(
      assessmentType: assessmentType,
      score: score,
      severity: severity,
      possibleDiagnoses: possibleDiagnoses,
      recommendations: recommendations,
      warningSigns: warningSigns,
      clinicalNotes: {
        'professionalType': professionalType.name,
        'assessmentDate': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<RiskAssessment> assessRisk({
    required String sessionNotes,
    required ProfessionalType professionalType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final riskFactors = _identifyRiskFactors(sessionNotes, professionalType);
    final protectiveFactors = _identifyProtectiveFactors(sessionNotes);
    final riskLevel = _calculateRiskLevel(riskFactors, protectiveFactors);
    final immediateActions = _getImmediateActions(riskLevel, professionalType);
    final followUpActions = _getFollowUpActions(riskLevel, professionalType);

    return RiskAssessment(
      riskType: 'Genel Risk Değerlendirmesi',
      riskLevel: riskLevel,
      riskScore: _calculateRiskScore(riskFactors, protectiveFactors),
      riskFactors: riskFactors,
      protectiveFactors: protectiveFactors,
      immediateActions: immediateActions,
      followUpActions: followUpActions,
      requiresImmediateAttention: riskLevel == 'Kritik' || riskLevel == 'Yüksek',
    );
  }

  Future<TreatmentSuggestion> generateTreatmentSuggestion({
    required String primaryDiagnosis,
    required String sessionNotes,
    required ProfessionalType professionalType,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final recommendedInterventions = _getRecommendedInterventions(primaryDiagnosis, professionalType);
    final therapeuticTechniques = _getTherapeuticTechniques(primaryDiagnosis, professionalType);
    final medicationConsiderations = _getMedicationConsiderations(primaryDiagnosis, professionalType);
    final sessionGoals = _getSessionGoals(primaryDiagnosis, professionalType);

    return TreatmentSuggestion(
      professionalType: professionalType,
      primaryDiagnosis: primaryDiagnosis,
      recommendedInterventions: recommendedInterventions,
      therapeuticTechniques: therapeuticTechniques,
      medicationConsiderations: medicationConsiderations,
      sessionGoals: sessionGoals,
      treatmentPlan: {
        'duration': _estimateTreatmentDuration(primaryDiagnosis),
        'frequency': _getSessionFrequency(primaryDiagnosis),
        'modalities': _getTreatmentModalities(primaryDiagnosis, professionalType),
      },
    );
  }

  Future<BillingCodeSuggestion> generateBillingCodeSuggestion({
    required String sessionType,
    required String primaryDiagnosis,
    required int sessionDuration,
    required ProfessionalType professionalType,
    required String region,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recommendedCPTCodes = _getCPTCodes(sessionType, sessionDuration, professionalType, region);
    final recommendedICDCodes = _getICDCodes(primaryDiagnosis, region);

    return BillingCodeSuggestion(
      professionalType: professionalType,
      sessionType: sessionType,
      primaryDiagnosis: primaryDiagnosis,
      sessionDuration: sessionDuration,
      recommendedCPTCodes: recommendedCPTCodes,
      recommendedICDCodes: recommendedICDCodes,
      region: region,
      billingNotes: {
        'sessionDuration': sessionDuration,
        'professionalType': professionalType.name,
        'region': region,
      },
    );
  }

  // Helper methods
  String _generateProfessionalSummary(String notes, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return '''
Psikolog Perspektifi:
Seans sırasında danışanın duygusal durumu ve davranışsal değişimler gözlemlendi. Terapötik süreçte ilerleme kaydedildi. Bilişsel davranışçı teknikler uygulandı ve danışanın farkındalığı artırıldı. Sonraki seans için ev ödevi verildi.
''';
      case ProfessionalType.psychiatrist:
        return '''
Psikiyatrist Perspektifi:
Hastanın mevcut semptomları değerlendirildi. İlaç tedavisinin etkinliği gözden geçirildi. Yan etkiler kontrol edildi. Gerekli laboratuvar testleri planlandı. İlaç dozajı ayarlandı.
''';
      case ProfessionalType.therapist:
        return '''
Terapist Perspektifi:
Terapötik ilişki güçlendirildi. Danışanın motivasyonu yüksek. Kullanılan teknikler etkili oldu. Direnç noktaları belirlendi. İlerleme kaydedildi.
''';
      case ProfessionalType.counselor:
        return '''
Danışman Perspektifi:
Danışanın hedefleri netleştirildi, pratik eylem planı çıkarıldı ve kaynaklara yönlendirme yapıldı.
''';
      default:
        return 'Seans özeti hazırlandı.';
    }
  }

  List<String> _extractKeyFindings(String notes, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return [
          'Danışanın duygusal farkındalığı artmış',
          'Bilişsel çarpıtmalar tespit edildi',
          'Terapötik ilişki güçlü',
          'Ev ödevlerine uyum iyi',
        ];
      case ProfessionalType.psychiatrist:
        return [
          'Semptom şiddeti azalmış',
          'İlaç toleransı iyi',
          'Yan etkiler minimal',
          'Yaşam kalitesi artmış',
        ];
      case ProfessionalType.therapist:
        return [
          'Terapötik hedeflere ulaşıldı',
          'Danışan motivasyonu yüksek',
          'Teknikler etkili',
          'İlerleme kaydedildi',
        ];
      case ProfessionalType.counselor:
        return [
          'Hedefler netleştirildi',
          'Kısa vadeli aksiyonlar belirlendi',
          'Kaynaklara erişim planlandı',
          'Destek ağı güçlendirildi',
        ];
      default:
        return ['Temel bulgular tespit edildi'];
    }
  }

  List<String> _generateActionItems(String notes, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return [
          'Bilişsel yeniden yapılandırma teknikleri uygula',
          'Ev ödevi: Düşünce kayıtları tut',
          'Sonraki seans: Duygu düzenleme teknikleri',
          'Aile terapisi değerlendir',
        ];
      case ProfessionalType.psychiatrist:
        return [
          'İlaç dozajını ayarla',
          'Laboratuvar testleri iste',
          'Yan etki takibi yap',
          'Konsültasyon gerekli mi değerlendir',
        ];
      case ProfessionalType.therapist:
        return [
          'Terapötik teknikleri çeşitlendir',
          'Danışanın hazırlığını değerlendir',
          'Hedefleri gözden geçir',
          'İlerleme ölçümleri yap',
        ];
      case ProfessionalType.counselor:
        return [
          'Kısa vadeli hedefler oluştur',
          'Eylem planını yazılı hale getir',
          'Uygun kaynaklara yönlendir',
          'Takip randevusunu planla',
        ];
      default:
        return ['Genel aksiyon öğeleri'];
    }
  }

  List<String> _generateFollowUpTasks(String notes, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return [
          '2 hafta sonra kontrol randevusu',
          'Aile görüşmesi planla',
          'Grup terapisi değerlendir',
          'Psikiyatrist konsültasyonu',
        ];
      case ProfessionalType.psychiatrist:
        return [
          '1 hafta sonra ilaç kontrolü',
          'Laboratuvar sonuçları takibi',
          'Yan etki değerlendirmesi',
          'Tedavi yanıtı değerlendirmesi',
        ];
      case ProfessionalType.therapist:
        return [
          'Sonraki seans planı',
          'Ev ödevleri takibi',
          'İlerleme değerlendirmesi',
          'Hedef gözden geçirmesi',
        ];
      case ProfessionalType.counselor:
        return [
          'Bir hafta sonra takip görüşmesi',
          'Kaynaklardan geri bildirim al',
          'Eylem planı revizyonu',
          'Gerekirse yönlendirme güncelle',
        ];
      default:
        return ['Genel takip görevleri'];
    }
  }

  String _calculateSeverity(String assessmentType, int score) {
    switch (assessmentType) {
      case 'PHQ-9':
        if (score >= 20) return 'Ağır';
        if (score >= 15) return 'Orta-Ağır';
        if (score >= 10) return 'Orta';
        if (score >= 5) return 'Hafif';
        return 'Minimal';
      case 'GAD-7':
        if (score >= 15) return 'Ağır';
        if (score >= 10) return 'Orta';
        if (score >= 5) return 'Hafif';
        return 'Minimal';
      default:
        return 'Değerlendirilecek';
    }
  }

  List<String> _getPossibleDiagnoses(String assessmentType, int score, ProfessionalType type) {
    final diagnoses = <String>[];
    
    switch (assessmentType) {
      case 'PHQ-9':
        if (score >= 10) {
          diagnoses.add('Major Depressive Disorder');
          if (type == ProfessionalType.psychiatrist) {
            diagnoses.add('Persistent Depressive Disorder');
            diagnoses.add('Adjustment Disorder with Depressed Mood');
          }
        }
        break;
      case 'GAD-7':
        if (score >= 10) {
          diagnoses.add('Generalized Anxiety Disorder');
          if (type == ProfessionalType.psychiatrist) {
            diagnoses.add('Panic Disorder');
            diagnoses.add('Social Anxiety Disorder');
          }
        }
        break;
    }
    
    return diagnoses;
  }

  List<String> _getRecommendations(String assessmentType, int score, ProfessionalType type) {
    final recommendations = <String>[];
    
    switch (type) {
      case ProfessionalType.psychologist:
        recommendations.addAll([
          'Bilişsel Davranışçı Terapi',
          'Duygu düzenleme teknikleri',
          'Stres yönetimi eğitimi',
          'Ev ödevleri ve uygulamalar',
        ]);
        break;
      case ProfessionalType.psychiatrist:
        recommendations.addAll([
          'İlaç tedavisi değerlendirmesi',
          'SSRI/SNRI başlangıcı',
          'Yan etki takibi',
          'Laboratuvar testleri',
        ]);
        if (score >= 15) {
          recommendations.add('Acil psikiyatrik değerlendirme');
        }
        break;
      case ProfessionalType.therapist:
        recommendations.addAll([
          'Terapötik müdahale',
          'Danışan eğitimi',
          'Destek grupları',
          'Yaşam tarzı değişiklikleri',
        ]);
        break;
    }
    
    return recommendations;
  }

  List<String> _getWarningSigns(String assessmentType, int score) {
    final warnings = <String>[];
    
    if (score >= 15) {
      warnings.add('Yüksek risk - Acil değerlendirme gerekli');
    }
    if (score >= 20) {
      warnings.add('Kritik seviye - Hemen müdahale gerekli');
    }
    
    return warnings;
  }

  List<String> _identifyRiskFactors(String notes, ProfessionalType type) {
    final riskFactors = <String>[];
    
    // Basit keyword tabanlı risk faktörü tespiti
    final lowerNotes = notes.toLowerCase();
    
    if (lowerNotes.contains('intihar') || lowerNotes.contains('ölüm')) {
      riskFactors.add('İntihar düşünceleri');
    }
    if (lowerNotes.contains('zarar') || lowerNotes.contains('kesme')) {
      riskFactors.add('Kendine zarar verme');
    }
    if (lowerNotes.contains('alkol') || lowerNotes.contains('madde')) {
      riskFactors.add('Madde kullanımı');
    }
    if (lowerNotes.contains('yalnız') || lowerNotes.contains('izole')) {
      riskFactors.add('Sosyal izolasyon');
    }
    
    return riskFactors;
  }

  List<String> _identifyProtectiveFactors(String notes) {
    final protectiveFactors = <String>[];
    
    final lowerNotes = notes.toLowerCase();
    
    if (lowerNotes.contains('aile') || lowerNotes.contains('destek')) {
      protectiveFactors.add('Aile desteği');
    }
    if (lowerNotes.contains('iş') || lowerNotes.contains('çalış')) {
      protectiveFactors.add('İş/okul bağlantısı');
    }
    if (lowerNotes.contains('hobi') || lowerNotes.contains('aktivite')) {
      protectiveFactors.add('Pozitif aktiviteler');
    }
    
    return protectiveFactors;
  }

  String _calculateRiskLevel(List<String> riskFactors, List<String> protectiveFactors) {
    if (riskFactors.contains('İntihar düşünceleri')) return 'Kritik';
    if (riskFactors.length >= 3) return 'Yüksek';
    if (riskFactors.length >= 2) return 'Orta';
    if (riskFactors.length >= 1) return 'Düşük';
    return 'Minimal';
  }

  double _calculateRiskScore(List<String> riskFactors, List<String> protectiveFactors) {
    double score = riskFactors.length * 0.3;
    score -= protectiveFactors.length * 0.1;
    return score.clamp(0.0, 1.0);
  }

  List<String> _getImmediateActions(String riskLevel, ProfessionalType type) {
    switch (riskLevel) {
      case 'Kritik':
        return [
          'Acil servise yönlendir',
          'Güvenlik planı oluştur',
          'Aile bilgilendir',
          '24 saat takip planla',
        ];
      case 'Yüksek':
        return [
          'Acil değerlendirme yap',
          'Güvenlik önlemleri al',
          'Sık takip planla',
          'Konsültasyon iste',
        ];
      default:
        return ['Rutin takip planla'];
    }
  }

  List<String> _getFollowUpActions(String riskLevel, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychiatrist:
        return [
          'İlaç ayarlaması yap',
          'Laboratuvar takibi',
          'Yan etki değerlendirmesi',
        ];
      case ProfessionalType.psychologist:
        return [
          'Terapi sıklığını artır',
          'Kriz müdahale planı',
          'Aile terapisi değerlendir',
        ];
      default:
        return ['Genel takip önerileri'];
    }
  }

  List<String> _getRecommendedInterventions(String diagnosis, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return [
          'Bilişsel Davranışçı Terapi',
          'Duygu düzenleme teknikleri',
          'Stres yönetimi',
          'Sosyal beceri eğitimi',
        ];
      case ProfessionalType.psychiatrist:
        return [
          'İlaç tedavisi',
          'Psikoeğitim',
          'Yaşam tarzı değişiklikleri',
          'Destek grupları',
        ];
      default:
        return ['Genel müdahale önerileri'];
    }
  }

  List<String> _getTherapeuticTechniques(String diagnosis, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return [
          'Bilişsel yeniden yapılandırma',
          'Davranış aktivasyonu',
          'Duygu düzenleme',
          'Mindfulness teknikleri',
        ];
      case ProfessionalType.psychiatrist:
        return [
          'İlaç yönetimi',
          'Psikoeğitim',
          'Motivasyonel görüşme',
          'Kriz müdahalesi',
        ];
      default:
        return ['Genel teknikler'];
    }
  }

  List<String> _getMedicationConsiderations(String diagnosis, ProfessionalType type) {
    if (type != ProfessionalType.psychiatrist) return [];
    
    switch (diagnosis) {
      case 'Major Depressive Disorder':
        return [
          'SSRI (Sertralin, Fluoksetin)',
          'SNRI (Venlafaksin, Duloksetin)',
          'Yan etki takibi gerekli',
          '4-6 hafta yanıt bekle',
        ];
      case 'Generalized Anxiety Disorder':
        return [
          'SSRI (Sertralin, Paroksetin)',
          'Benzodiazepin (kısa süreli)',
          'Yan etki takibi',
          'Bağımlılık riski değerlendir',
        ];
      default:
        return ['İlaç değerlendirmesi gerekli'];
    }
  }

  List<String> _getSessionGoals(String diagnosis, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return [
          'Semptom azaltma',
          'İşlevsellik artırma',
          'Yaşam kalitesi iyileştirme',
          'Relaps önleme',
        ];
      case ProfessionalType.psychiatrist:
        return [
          'İlaç optimizasyonu',
          'Yan etki minimizasyonu',
          'Tedavi uyumu artırma',
          'Kriz önleme',
        ];
      default:
        return ['Genel hedefler'];
    }
  }

  int _estimateTreatmentDuration(String diagnosis) {
    switch (diagnosis) {
      case 'Major Depressive Disorder':
        return 12; // hafta
      case 'Generalized Anxiety Disorder':
        return 16; // hafta
      default:
        return 8; // hafta
    }
  }

  String _getSessionFrequency(String diagnosis) {
    switch (diagnosis) {
      case 'Major Depressive Disorder':
        return 'Haftalık';
      case 'Generalized Anxiety Disorder':
        return 'Haftalık';
      default:
        return 'İki haftada bir';
    }
  }

  List<String> _getTreatmentModalities(String diagnosis, ProfessionalType type) {
    switch (type) {
      case ProfessionalType.psychologist:
        return ['Bireysel terapi', 'Grup terapisi', 'Aile terapisi'];
      case ProfessionalType.psychiatrist:
        return ['İlaç yönetimi', 'Psikoeğitim', 'Konsültasyon'];
      default:
        return ['Genel modaliteler'];
    }
  }

  List<String> _getCPTCodes(String sessionType, int duration, ProfessionalType type, String region) {
    return _billingCodes[type]?[region] ?? ['90834'];
  }

  List<String> _getICDCodes(String diagnosis, String region) {
    switch (diagnosis) {
      case 'Major Depressive Disorder':
        return ['F32.9', 'F33.9'];
      case 'Generalized Anxiety Disorder':
        return ['F41.1'];
      default:
        return ['Z00.00'];
    }
  }
}