// Terapi Teknikleri Modelleri - Psikolog/Psikiyatrist Odaklı

class TherapyTechnique {
  final String id;
  final String name;
  final String description;
  final TherapyType type;
  final TherapyApproach approach;
  final List<String> indications;
  final List<String> contraindications;
  final List<String> steps;
  final List<String> materials;
  final int estimatedDuration;
  final DifficultyLevel difficulty;
  final List<String> keywords;
  final String theoreticalBackground;
  final List<String> researchEvidence;
  final DateTime createdAt;
  final DateTime updatedAt;

  TherapyTechnique({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.approach,
    required this.indications,
    required this.contraindications,
    required this.steps,
    required this.materials,
    required this.estimatedDuration,
    required this.difficulty,
    required this.keywords,
    required this.theoreticalBackground,
    required this.researchEvidence,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'approach': approach.name,
      'indications': indications,
      'contraindications': contraindications,
      'steps': steps,
      'materials': materials,
      'estimatedDuration': estimatedDuration,
      'difficulty': difficulty.name,
      'keywords': keywords,
      'theoreticalBackground': theoreticalBackground,
      'researchEvidence': researchEvidence,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TherapyTechnique.fromJson(Map<String, dynamic> json) {
    return TherapyTechnique(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: TherapyType.values.firstWhere((e) => e.name == json['type']),
      approach: TherapyApproach.values.firstWhere((e) => e.name == json['approach']),
      indications: List<String>.from(json['indications']),
      contraindications: List<String>.from(json['contraindications']),
      steps: List<String>.from(json['steps']),
      materials: List<String>.from(json['materials']),
      estimatedDuration: json['estimatedDuration'],
      difficulty: DifficultyLevel.values.firstWhere((e) => e.name == json['difficulty']),
      keywords: List<String>.from(json['keywords']),
      theoreticalBackground: json['theoreticalBackground'],
      researchEvidence: List<String>.from(json['researchEvidence']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum TherapyType {
  cognitive,      // Bilişsel
  behavioral,     // Davranışçı
  psychodynamic,  // Psikodinamik
  humanistic,     // Hümanistik
  systemic,       // Sistemik
  integrative,    // Entegratif
  exposure,       // Maruz bırakma
  relaxation,     // Gevşeme
  mindfulness,    // Farkındalık
  art,            // Sanat terapisi
  music,          // Müzik terapisi
  play,           // Oyun terapisi
  group,          // Grup terapisi
  family,         // Aile terapisi
  couple,         // Çift terapisi
}

enum TherapyApproach {
  cbt,            // Bilişsel Davranışçı Terapi
  dbt,            // Diyalektik Davranış Terapisi
  act,            // Kabul ve Kararlılık Terapisi
  emdr,           // EMDR
  gestalt,        // Gestalt Terapi
  personCentered, // Kişi Merkezli Terapi
  psychodynamic,  // Psikodinamik Terapi
  systemic,       // Sistemik Terapi
  narrative,      // Anlatı Terapisi
  solutionFocused, // Çözüm Odaklı Terapi
  motivational,   // Motivasyonel Görüşme
  traumaFocused,  // Travma Odaklı Terapi
}

enum DifficultyLevel {
  beginner,       // Başlangıç
  intermediate,   // Orta
  advanced,       // İleri
  expert,         // Uzman
}

class TherapySession {
  final String id;
  final String clientId;
  final String therapistId;
  final String techniqueId;
  final DateTime sessionDate;
  final int duration;
  final SessionStatus status;
  final List<String> objectives;
  final List<String> outcomes;
  final String notes;
  final Map<String, dynamic> clientFeedback;
  final Map<String, dynamic> therapistEvaluation;
  final List<String> homework;
  final DateTime createdAt;
  final DateTime updatedAt;

  TherapySession({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.techniqueId,
    required this.sessionDate,
    required this.duration,
    required this.status,
    required this.objectives,
    required this.outcomes,
    this.notes = '',
    this.clientFeedback = const {},
    this.therapistEvaluation = const {},
    this.homework = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'techniqueId': techniqueId,
      'sessionDate': sessionDate.toIso8601String(),
      'duration': duration,
      'status': status.name,
      'objectives': objectives,
      'outcomes': outcomes,
      'notes': notes,
      'clientFeedback': clientFeedback,
      'therapistEvaluation': therapistEvaluation,
      'homework': homework,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      techniqueId: json['techniqueId'],
      sessionDate: DateTime.parse(json['sessionDate']),
      duration: json['duration'],
      status: SessionStatus.values.firstWhere((e) => e.name == json['status']),
      objectives: List<String>.from(json['objectives']),
      outcomes: List<String>.from(json['outcomes']),
      notes: json['notes'] ?? '',
      clientFeedback: Map<String, dynamic>.from(json['clientFeedback'] ?? {}),
      therapistEvaluation: Map<String, dynamic>.from(json['therapistEvaluation'] ?? {}),
      homework: List<String>.from(json['homework'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum SessionStatus {
  planned,        // Planlandı
  inProgress,     // Devam ediyor
  completed,      // Tamamlandı
  cancelled,      // İptal edildi
  rescheduled,    // Ertelendi
}

// Terapi Teknikleri Şablonları
class TherapyTechniqueTemplates {
  static List<TherapyTechnique> getCognitiveTechniques() {
    return [
      TherapyTechnique(
        id: 'cbt_1',
        name: 'Bilişsel Yeniden Yapılandırma',
        description: 'Olumsuz düşünce kalıplarını tanıma ve değiştirme tekniği',
        type: TherapyType.cognitive,
        approach: TherapyApproach.cbt,
        indications: [
          'Depresyon',
          'Anksiyete bozuklukları',
          'Panik bozukluğu',
          'Sosyal anksiyete',
          'Obsesif kompulsif bozukluk',
        ],
        contraindications: [
          'Aktif psikoz',
          'Ciddi bilişsel bozukluk',
          'Akut kriz durumu',
        ],
        steps: [
          'Olumsuz düşünceyi tanıma',
          'Duygusal tepkiyi değerlendirme',
          'Kanıtları toplama',
          'Alternatif düşünce geliştirme',
          'Yeni düşünceyi test etme',
          'Sonuçları değerlendirme',
        ],
        materials: [
          'Düşünce kayıt formu',
          'Kalem ve kağıt',
          'Duygu ölçeği',
        ],
        estimatedDuration: 45,
        difficulty: DifficultyLevel.intermediate,
        keywords: ['bilişsel', 'düşünce', 'yeniden yapılandırma', 'CBT'],
        theoreticalBackground: 'Aaron Beck\'in bilişsel modeline dayanır. Düşünceler, duygular ve davranışlar arasındaki ilişkiyi vurgular.',
        researchEvidence: [
          'Beck, A. T. (1976). Cognitive Therapy and the Emotional Disorders.',
          'Hofmann, S. G. (2013). The efficacy of cognitive behavioral therapy.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TherapyTechnique(
        id: 'cbt_2',
        name: 'Davranış Aktivasyonu',
        description: 'Depresyon tedavisinde aktivite seviyesini artırma tekniği',
        type: TherapyType.behavioral,
        approach: TherapyApproach.cbt,
        indications: [
          'Major depresif bozukluk',
          'Dysthymia',
          'Bipolar depresyon',
          'Mevsimsel depresyon',
        ],
        contraindications: [
          'Ağır fiziksel engel',
          'Aktif manik epizod',
          'Ciddi madde kullanımı',
        ],
        steps: [
          'Mevcut aktiviteleri değerlendirme',
          'Zevk verici aktiviteleri belirleme',
          'Aktivite planı oluşturma',
          'Küçük adımlarla başlama',
          'İlerlemeyi takip etme',
          'Zorlukları çözme',
        ],
        materials: [
          'Aktivite kayıt formu',
          'Zevk ölçeği',
          'Haftalık planlama çizelgesi',
        ],
        estimatedDuration: 60,
        difficulty: DifficultyLevel.beginner,
        keywords: ['davranış', 'aktivasyon', 'depresyon', 'planlama'],
        theoreticalBackground: 'Davranışçı aktivasyon teorisine dayanır. Depresyonun davranışsal bileşenlerine odaklanır.',
        researchEvidence: [
          'Jacobson, N. S. (1996). A component analysis of cognitive-behavioral treatment for depression.',
          'Dimidjian, S. (2006). Randomized trial of behavioral activation.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<TherapyTechnique> getAnxietyTechniques() {
    return [
      TherapyTechnique(
        id: 'anxiety_1',
        name: 'Progresif Kas Gevşemesi',
        description: 'Sistematik kas gevşetme tekniği',
        type: TherapyType.relaxation,
        approach: TherapyApproach.cbt,
        indications: [
          'Yaygın anksiyete bozukluğu',
          'Panik bozukluğu',
          'Sosyal anksiyete',
          'Uyku bozuklukları',
          'Stres yönetimi',
        ],
        contraindications: [
          'Ciddi kardiyovasküler hastalık',
          'Ağır kas-iskelet sistemi bozukluğu',
          'Aktif psikoz',
        ],
        steps: [
          'Rahat bir pozisyon alma',
          'Derin nefes alma',
          'Ayak kaslarını germe ve gevşetme',
          'Bacak kaslarını germe ve gevşetme',
          'Karın kaslarını germe ve gevşetme',
          'Göğüs kaslarını germe ve gevşetme',
          'Kol kaslarını germe ve gevşetme',
          'Boyun kaslarını germe ve gevşetme',
          'Yüz kaslarını germe ve gevşetme',
          'Tüm vücudu gevşetme',
        ],
        materials: [
          'Rahat sandalye veya yatak',
          'Sessiz ortam',
          'Gevşeme rehberi',
        ],
        estimatedDuration: 30,
        difficulty: DifficultyLevel.beginner,
        keywords: ['gevşeme', 'kas', 'anksiyete', 'stres'],
        theoreticalBackground: 'Edmund Jacobson tarafından geliştirilmiştir. Kas gerginliği ve gevşeme arasındaki farkı öğretir.',
        researchEvidence: [
          'Jacobson, E. (1938). Progressive Relaxation.',
          'Pawlow, L. A. (2005). Progressive muscle relaxation.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TherapyTechnique(
        id: 'anxiety_2',
        name: 'Sistematik Duyarsızlaştırma',
        description: 'Anksiyete uyandıran durumlara kademeli maruz bırakma',
        type: TherapyType.exposure,
        approach: TherapyApproach.cbt,
        indications: [
          'Fobiler',
          'Panik bozukluğu',
          'Sosyal anksiyete',
          'Obsesif kompulsif bozukluk',
          'Travma sonrası stres bozukluğu',
        ],
        contraindications: [
          'Aktif kriz durumu',
          'Ciddi kardiyovasküler hastalık',
          'Ağır psikoz',
          'Madde kullanımı',
        ],
        steps: [
          'Anksiyete hiyerarşisi oluşturma',
          'Gevşeme tekniği öğretme',
          'En düşük seviyeden başlama',
          'Anksiyete seviyesini ölçme',
          'Gevşeme ile eşleştirme',
          'Bir sonraki seviyeye geçme',
          'Genelleme yapma',
        ],
        materials: [
          'Anksiyete hiyerarşi formu',
          'Anksiyete ölçeği',
          'Gevşeme rehberi',
        ],
        estimatedDuration: 60,
        difficulty: DifficultyLevel.advanced,
        keywords: ['maruz bırakma', 'duyarsızlaştırma', 'fobi', 'anksiyete'],
        theoreticalBackground: 'Joseph Wolpe tarafından geliştirilmiştir. Klasik koşullanma prensiplerine dayanır.',
        researchEvidence: [
          'Wolpe, J. (1958). Psychotherapy by Reciprocal Inhibition.',
          'Öst, L. G. (1989). One-session treatment for specific phobias.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<TherapyTechnique> getTraumaTechniques() {
    return [
      TherapyTechnique(
        id: 'trauma_1',
        name: 'EMDR (Göz Hareketleri ile Duyarsızlaştırma)',
        description: 'Travmatik anıları işleme ve duyarsızlaştırma tekniği',
        type: TherapyType.integrative,
        approach: TherapyApproach.emdr,
        indications: [
          'Travma sonrası stres bozukluğu',
          'Akut stres bozukluğu',
          'Travma sonrası depresyon',
          'Anksiyete bozuklukları',
          'Yas ve kayıp',
        ],
        contraindications: [
          'Aktif psikoz',
          'Ciddi dissosiyatif bozukluk',
          'Aktif madde kullanımı',
          'Ciddi kardiyovasküler hastalık',
        ],
        steps: [
          'Hasta geçmişi alma',
          'Hazırlık ve güvenlik planı',
          'Hedef anıyı belirleme',
          'Göz hareketleri ile işleme',
          'Pozitif inancı güçlendirme',
          'Vücut taraması',
          'Kapanış ve değerlendirme',
          'Gelecek şablonu',
        ],
        materials: [
          'EMDR protokolü',
          'Göz hareketleri rehberi',
          'Güvenlik planı formu',
        ],
        estimatedDuration: 90,
        difficulty: DifficultyLevel.expert,
        keywords: ['EMDR', 'travma', 'göz hareketleri', 'duyarsızlaştırma'],
        theoreticalBackground: 'Francine Shapiro tarafından geliştirilmiştir. Adaptif Bilgi İşleme Modeli\'ne dayanır.',
        researchEvidence: [
          'Shapiro, F. (1989). Eye movement desensitization.',
          'Bisson, J. I. (2013). Psychological therapies for chronic PTSD.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TherapyTechnique(
        id: 'trauma_2',
        name: 'Travma Odaklı Bilişsel Davranışçı Terapi',
        description: 'Travma sonrası stres bozukluğu için özel CBT protokolü',
        type: TherapyType.cognitive,
        approach: TherapyApproach.traumaFocused,
        indications: [
          'Travma sonrası stres bozukluğu',
          'Akut stres bozukluğu',
          'Travma sonrası depresyon',
          'Karmaşık travma',
        ],
        contraindications: [
          'Aktif kriz durumu',
          'Ciddi dissosiyatif bozukluk',
          'Aktif madde kullanımı',
          'Ciddi bilişsel bozukluk',
        ],
        steps: [
          'Psikoeğitim',
          'Güvenlik planı oluşturma',
          'Gevşeme teknikleri',
          'Bilişsel yeniden yapılandırma',
          'Travma anısı işleme',
          'Maruz bırakma',
          'Önleme stratejileri',
          'Relaps önleme',
        ],
        materials: [
          'TF-CBT protokolü',
          'Travma anısı formu',
          'Güvenlik planı',
          'Gevşeme rehberi',
        ],
        estimatedDuration: 75,
        difficulty: DifficultyLevel.advanced,
        keywords: ['travma', 'CBT', 'PTSD', 'maruz bırakma'],
        theoreticalBackground: 'Judith Cohen ve Anthony Mannarino tarafından geliştirilmiştir. Travma sonrası iyileşme modeline dayanır.',
        researchEvidence: [
          'Cohen, J. A. (2006). Treating trauma and traumatic grief in children.',
          'Foa, E. B. (2008). Prolonged exposure therapy for PTSD.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<TherapyTechnique> getMindfulnessTechniques() {
    return [
      TherapyTechnique(
        id: 'mindfulness_1',
        name: 'Mindfulness Temelli Stres Azaltma (MBSR)',
        description: 'Farkındalık temelli stres yönetimi tekniği',
        type: TherapyType.mindfulness,
        approach: TherapyApproach.act,
        indications: [
          'Stres yönetimi',
          'Anksiyete bozuklukları',
          'Depresyon',
          'Kronik ağrı',
          'Uyku bozuklukları',
        ],
        contraindications: [
          'Aktif psikoz',
          'Ciddi dissosiyatif bozukluk',
          'Aktif kriz durumu',
        ],
        steps: [
          'Farkındalık nedir?',
          'Nefes farkındalığı',
          'Vücut taraması',
          'Yürüme meditasyonu',
          'Duygu farkındalığı',
          'Düşünce farkındalığı',
          'Günlük yaşamda farkındalık',
          'Stres tepkisi yönetimi',
        ],
        materials: [
          'Meditasyon rehberi',
          'Farkındalık egzersizleri',
          'Günlük pratik çizelgesi',
        ],
        estimatedDuration: 45,
        difficulty: DifficultyLevel.intermediate,
        keywords: ['mindfulness', 'farkındalık', 'stres', 'meditasyon'],
        theoreticalBackground: 'Jon Kabat-Zinn tarafından geliştirilmiştir. Budist meditasyon pratiklerine dayanır.',
        researchEvidence: [
          'Kabat-Zinn, J. (1990). Full Catastrophe Living.',
          'Goyal, M. (2014). Meditation programs for psychological stress.',
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  static List<TherapyTechnique> getAllTechniques() {
    return [
      ...getCognitiveTechniques(),
      ...getAnxietyTechniques(),
      ...getTraumaTechniques(),
      ...getMindfulnessTechniques(),
    ];
  }
}

class TherapyIntervention {
  final String id;
  final String techniqueId;
  final String clientId;
  final String therapistId;
  final DateTime scheduledDate;
  final int duration;
  final InterventionStatus status;
  final List<String> objectives;
  final List<String> outcomes;
  final String notes;
  final Map<String, dynamic> clientFeedback;
  final Map<String, dynamic> therapistEvaluation;
  final List<String> homework;
  final DateTime createdAt;
  final DateTime updatedAt;

  TherapyIntervention({
    required this.id,
    required this.techniqueId,
    required this.clientId,
    required this.therapistId,
    required this.scheduledDate,
    required this.duration,
    required this.status,
    required this.objectives,
    required this.outcomes,
    this.notes = '',
    this.clientFeedback = const {},
    this.therapistEvaluation = const {},
    this.homework = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'techniqueId': techniqueId,
      'clientId': clientId,
      'therapistId': therapistId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'duration': duration,
      'status': status.name,
      'objectives': objectives,
      'outcomes': outcomes,
      'notes': notes,
      'clientFeedback': clientFeedback,
      'therapistEvaluation': therapistEvaluation,
      'homework': homework,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TherapyIntervention.fromJson(Map<String, dynamic> json) {
    return TherapyIntervention(
      id: json['id'],
      techniqueId: json['techniqueId'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      duration: json['duration'],
      status: InterventionStatus.values.firstWhere((e) => e.name == json['status']),
      objectives: List<String>.from(json['objectives']),
      outcomes: List<String>.from(json['outcomes']),
      notes: json['notes'] ?? '',
      clientFeedback: Map<String, dynamic>.from(json['clientFeedback'] ?? {}),
      therapistEvaluation: Map<String, dynamic>.from(json['therapistEvaluation'] ?? {}),
      homework: List<String>.from(json['homework'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum InterventionStatus {
  planned,        // Planlandı
  inProgress,     // Devam ediyor
  completed,      // Tamamlandı
  cancelled,      // İptal edildi
  rescheduled,    // Ertelendi
}
