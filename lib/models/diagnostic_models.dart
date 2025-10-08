// Tanı Modelleri - DSM-5/ICD-11 Odaklı

class DiagnosticEntry {
  final String id;
  final String clientId;
  final String therapistId;
  final String diagnosisCode;
  final String diagnosisName;
  final DiagnosticSystem system;
  final DiagnosticCategory category;
  final DiagnosticSeverity severity;
  final String description;
  final List<String> symptoms;
  final List<String> criteria;
  final DateTime diagnosisDate;
  final bool isPrimary;
  final bool isProvisional;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiagnosticEntry({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.diagnosisCode,
    required this.diagnosisName,
    required this.system,
    required this.category,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.criteria,
    required this.diagnosisDate,
    this.isPrimary = false,
    this.isProvisional = false,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'diagnosisCode': diagnosisCode,
      'diagnosisName': diagnosisName,
      'system': system.name,
      'category': category.name,
      'severity': severity.name,
      'description': description,
      'symptoms': symptoms,
      'criteria': criteria,
      'diagnosisDate': diagnosisDate.toIso8601String(),
      'isPrimary': isPrimary,
      'isProvisional': isProvisional,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DiagnosticEntry.fromJson(Map<String, dynamic> json) {
    return DiagnosticEntry(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      diagnosisCode: json['diagnosisCode'],
      diagnosisName: json['diagnosisName'],
      system: DiagnosticSystem.values.firstWhere((e) => e.name == json['system']),
      category: DiagnosticCategory.values.firstWhere((e) => e.name == json['category']),
      severity: DiagnosticSeverity.values.firstWhere((e) => e.name == json['severity']),
      description: json['description'],
      symptoms: List<String>.from(json['symptoms']),
      criteria: List<String>.from(json['criteria']),
      diagnosisDate: DateTime.parse(json['diagnosisDate']),
      isPrimary: json['isPrimary'] ?? false,
      isProvisional: json['isProvisional'] ?? false,
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum DiagnosticSystem {
  dsm5,           // DSM-5
  dsm5tr,         // DSM-5-TR
  icd10,          // ICD-10
  icd11,          // ICD-11
}

enum DiagnosticCategory {
  depressive,     // Depresif bozukluklar
  anxiety,        // Anksiyete bozuklukları
  trauma,         // Travma ve stres bozuklukları
  personality,    // Kişilik bozuklukları
  psychotic,      // Psikotik bozukluklar
  bipolar,        // Bipolar bozukluklar
  eating,         // Yeme bozuklukları
  substance,      // Madde kullanım bozuklukları
  neurodevelopmental, // Nörogelişimsel bozukluklar
  neurocognitive, // Nörobilişsel bozukluklar
  sleep,          // Uyku bozuklukları
  sexual,         // Cinsel bozukluklar
  adjustment,     // Uyum bozuklukları
  other,          // Diğer
}

enum DiagnosticSeverity {
  mild,           // Hafif
  moderate,       // Orta
  severe,         // Şiddetli
  inRemission,    // Remisyonda
  unspecified,    // Belirtilmemiş
}

class DiagnosticCriteria {
  final String id;
  final String code;
  final String name;
  final DiagnosticSystem system;
  final DiagnosticCategory category;
  final List<String> criteria;
  final List<String> symptoms;
  final String description;
  final DiagnosticSeverity severity;
  final List<String> differentialDiagnoses;
  final Map<String, dynamic> additionalInfo;

  DiagnosticCriteria({
    required this.id,
    required this.code,
    required this.name,
    required this.system,
    required this.category,
    required this.criteria,
    required this.symptoms,
    required this.description,
    required this.severity,
    this.differentialDiagnoses = const [],
    this.additionalInfo = const {},
  });
}

// DSM-5 Tanı Kriterleri
class DSM5Diagnoses {
  static List<DiagnosticCriteria> getDepressiveDisorders() {
    return [
      DiagnosticCriteria(
        id: 'dsm5_296.33',
        code: '296.33',
        name: 'Major Depressive Disorder, Recurrent, Severe',
        system: DiagnosticSystem.dsm5,
        category: DiagnosticCategory.depressive,
        criteria: [
          'A. Beş (veya daha fazla) belirti aynı 2 haftalık dönemde bulunur ve önceki işlevsellik düzeyinde bir değişiklik oluşturur; belirtilerden en az biri depresif duygudurum veya ilgi kaybı ya da zevk alamama olmalıdır.',
          'B. Belirtiler klinik olarak belirgin sıkıntıya ya da toplumsal, işle ilgili alanlarda ya da önemli diğer işlevsellik alanlarında işlevsellikte düşmeye neden olur.',
          'C. Belirtiler bir maddenin ya da başka bir sağlık durumunun fizyolojik etkilerine bağlanamaz.',
        ],
        symptoms: [
          'Depresif duygudurum',
          'İlgi kaybı veya zevk alamama',
          'Kilo kaybı veya artışı',
          'Uykusuzluk veya aşırı uyuma',
          'Psikomotor ajitasyon veya retardasyon',
          'Yorgunluk veya enerji kaybı',
          'Değersizlik veya suçluluk duyguları',
          'Konsantrasyon güçlüğü',
          'Ölüm düşünceleri',
        ],
        description: 'Major depresif bozukluk, tekrarlayan, şiddetli',
        severity: DiagnosticSeverity.severe,
        differentialDiagnoses: [
          'Bipolar I Disorder',
          'Persistent Depressive Disorder',
          'Adjustment Disorder',
          'Substance/Medication-Induced Depressive Disorder',
        ],
      ),
      DiagnosticCriteria(
        id: 'dsm5_300.4',
        code: '300.4',
        name: 'Persistent Depressive Disorder (Dysthymia)',
        system: DiagnosticSystem.dsm5,
        category: DiagnosticCategory.depressive,
        criteria: [
          'A. En az 2 yıl süreyle, günlerin çoğunda, günün büyük bölümünde depresif duygudurum.',
          'B. Depresif duygudurum sırasında aşağıdakilerden iki (veya daha fazlası) bulunur:',
          'C. Bu 2 yıllık süre boyunca, A ve B kriterleri 2 aydan uzun süreyle bulunmamıştır.',
        ],
        symptoms: [
          'İştahsızlık veya aşırı yeme',
          'Uykusuzluk veya aşırı uyuma',
          'Düşük enerji veya yorgunluk',
          'Düşük benlik saygısı',
          'Konsantrasyon güçlüğü veya karar verme güçlüğü',
          'Umutsuzluk duyguları',
        ],
        description: 'Sürekli depresif bozukluk (Distimi)',
        severity: DiagnosticSeverity.mild,
        differentialDiagnoses: [
          'Major Depressive Disorder',
          'Bipolar I Disorder',
          'Cyclothymic Disorder',
        ],
      ),
    ];
  }

  static List<DiagnosticCriteria> getAnxietyDisorders() {
    return [
      DiagnosticCriteria(
        id: 'dsm5_300.02',
        code: '300.02',
        name: 'Generalized Anxiety Disorder',
        system: DiagnosticSystem.dsm5,
        category: DiagnosticCategory.anxiety,
        criteria: [
          'A. Birçok olay ya da etkinlik hakkında aşırı kaygı ve endişe (endişeli beklenti), en az 6 ay süreyle, günlerin çoğunda oluşur.',
          'B. Kişi, endişesini kontrol etmekte güçlük çeker.',
          'C. Kaygı ve endişe, aşağıdaki 6 belirtiden 3\'ü (ya da daha fazlası) ile ilişkilidir:',
          'D. Kaygı, endişe ya da fiziksel belirtiler klinik olarak belirgin sıkıntıya ya da toplumsal, işle ilgili alanlarda ya da önemli diğer işlevsellik alanlarında işlevsellikte düşmeye neden olur.',
        ],
        symptoms: [
          'Huzursuzluk, gerginlik ya da sürekli diken üstünde olma',
          'Kolay yorulma',
          'Konsantrasyon güçlüğü ya da zihnin boşalması',
          'Sinirlilik',
          'Kas gerginliği',
          'Uyku bozukluğu',
        ],
        description: 'Yaygın anksiyete bozukluğu',
        severity: DiagnosticSeverity.moderate,
        differentialDiagnoses: [
          'Panic Disorder',
          'Social Anxiety Disorder',
          'Obsessive-Compulsive Disorder',
          'Post-Traumatic Stress Disorder',
        ],
      ),
      DiagnosticCriteria(
        id: 'dsm5_300.01',
        code: '300.01',
        name: 'Panic Disorder',
        system: DiagnosticSystem.dsm5,
        category: DiagnosticCategory.anxiety,
        criteria: [
          'A. Tekrarlayan, beklenmedik panik atakları.',
          'B. En az bir ataktan sonra, aşağıdakilerden biri (ya da daha fazlası) 1 ay (ya da daha uzun) süreyle devam eder:',
          'C. Bozukluk, bir maddenin ya da başka bir sağlık durumunun fizyolojik etkilerine bağlanamaz.',
        ],
        symptoms: [
          'Çarpıntı, kalp atımlarını duyumsama ya da kalp hızında artma',
          'Terleme',
          'Titreme ya da sarsılma',
          'Nefes darlığı ya da boğuluyor gibi olma duyumları',
          'Soluğun kesilmesi',
          'Göğüs ağrısı ya da göğüste sıkışma',
          'Bulantı ya da karın ağrısı',
          'Baş dönmesi, sersemlik, düşecek ya da bayılacak gibi olma',
          'Üşüme, ürperme ya da ateş basması',
          'Uyuşma ya da karıncalanma duyumları',
          'Gerçekdışılık (derealizasyon) ya da kendine yabancılaşma (depersonalizasyon)',
          'Kontrolü kaybetme ya da çıldırma korkusu',
          'Ölüm korkusu',
        ],
        description: 'Panik bozukluğu',
        severity: DiagnosticSeverity.severe,
        differentialDiagnoses: [
          'Generalized Anxiety Disorder',
          'Social Anxiety Disorder',
          'Specific Phobia',
          'Post-Traumatic Stress Disorder',
        ],
      ),
    ];
  }

  static List<DiagnosticCriteria> getTraumaDisorders() {
    return [
      DiagnosticCriteria(
        id: 'dsm5_309.81',
        code: '309.81',
        name: 'Post-Traumatic Stress Disorder',
        system: DiagnosticSystem.dsm5,
        category: DiagnosticCategory.trauma,
        criteria: [
          'A. Aşağıdakilerden birine (ya da daha fazlasına) maruz kalma:',
          'B. Aşağıdakilerden birini (ya da daha fazlasını) travmatik olay(lar)ın ardından yaşama:',
          'C. Aşağıdakilerden birini (ya da daha fazlasını) travmatik olay(lar)ın ardından yaşama:',
          'D. Aşağıdakilerden iki (ya da daha fazlasını) travmatik olay(lar)ın ardından yaşama:',
          'E. Aşağıdakilerden iki (ya da daha fazlasını) travmatik olay(lar)ın ardından yaşama:',
        ],
        symptoms: [
          'Travmatik olayın tekrarlayan, istemsiz ve rahatsız edici anıları',
          'Travmatik olayla ilgili tekrarlayan, rahatsız edici rüyalar',
          'Travmatik olayın yeniden oluyormuş gibi davranışları ya da hisleri',
          'Travmatik olayın bir ya da daha fazla yönünü simgeleyen ya da andıran iç ya da dış ipuçlarına maruz kaldığında yoğun ya da uzun süreli psikolojik sıkıntı',
          'Travmatik olayın bir ya da daha fazla yönünü simgeleyen ya da andıran iç ya da dış ipuçlarına maruz kaldığında belirgin fizyolojik tepkiler',
        ],
        description: 'Travma sonrası stres bozukluğu',
        severity: DiagnosticSeverity.severe,
        differentialDiagnoses: [
          'Acute Stress Disorder',
          'Adjustment Disorder',
          'Anxiety Disorders',
          'Dissociative Disorders',
        ],
      ),
    ];
  }
}

// ICD-11 Tanı Kriterleri
class ICD11Diagnoses {
  static List<DiagnosticCriteria> getDepressiveDisorders() {
    return [
      DiagnosticCriteria(
        id: 'icd11_6a70',
        code: '6A70',
        name: 'Single Episode Depressive Disorder',
        system: DiagnosticSystem.icd11,
        category: DiagnosticCategory.depressive,
        criteria: [
          'A. En az 2 hafta süreyle, günlerin çoğunda, günün büyük bölümünde depresif duygudurum.',
          'B. Aşağıdakilerden en az 4\'ü bulunur:',
          'C. Belirtiler klinik olarak belirgin sıkıntıya ya da işlevsellikte düşmeye neden olur.',
        ],
        symptoms: [
          'İlgi kaybı veya zevk alamama',
          'Kilo kaybı veya artışı',
          'Uykusuzluk veya aşırı uyuma',
          'Psikomotor ajitasyon veya retardasyon',
          'Yorgunluk veya enerji kaybı',
          'Değersizlik veya suçluluk duyguları',
          'Konsantrasyon güçlüğü',
          'Ölüm düşünceleri',
        ],
        description: 'Tek epizod depresif bozukluk',
        severity: DiagnosticSeverity.moderate,
        differentialDiagnoses: [
          'Recurrent Depressive Disorder',
          'Bipolar Type I Disorder',
          'Persistent Depressive Disorder',
        ],
      ),
    ];
  }

  static List<DiagnosticCriteria> getAnxietyDisorders() {
    return [
      DiagnosticCriteria(
        id: 'icd11_6b00',
        code: '6B00',
        name: 'Generalized Anxiety Disorder',
        system: DiagnosticSystem.icd11,
        category: DiagnosticCategory.anxiety,
        criteria: [
          'A. Birçok olay ya da etkinlik hakkında aşırı kaygı ve endişe, en az 6 ay süreyle, günlerin çoğunda oluşur.',
          'B. Kişi, endişesini kontrol etmekte güçlük çeker.',
          'C. Kaygı ve endişe, aşağıdaki belirtilerle ilişkilidir:',
          'D. Kaygı, endişe ya da fiziksel belirtiler klinik olarak belirgin sıkıntıya ya da işlevsellikte düşmeye neden olur.',
        ],
        symptoms: [
          'Huzursuzluk, gerginlik',
          'Kolay yorulma',
          'Konsantrasyon güçlüğü',
          'Sinirlilik',
          'Kas gerginliği',
          'Uyku bozukluğu',
        ],
        description: 'Yaygın anksiyete bozukluğu',
        severity: DiagnosticSeverity.moderate,
        differentialDiagnoses: [
          'Panic Disorder',
          'Social Anxiety Disorder',
          'Obsessive-Compulsive Disorder',
        ],
      ),
    ];
  }
}

class DiagnosticSearchResult {
  final List<DiagnosticCriteria> diagnoses;
  final int totalCount;
  final String searchQuery;
  final DiagnosticSystem system;
  final DiagnosticCategory? category;

  DiagnosticSearchResult({
    required this.diagnoses,
    required this.totalCount,
    required this.searchQuery,
    required this.system,
    this.category,
  });
}

class DiagnosticSuggestion {
  final String code;
  final String name;
  final DiagnosticSystem system;
  final DiagnosticCategory category;
  final double confidence;
  final String reason;

  DiagnosticSuggestion({
    required this.code,
    required this.name,
    required this.system,
    required this.category,
    required this.confidence,
    required this.reason,
  });
}
