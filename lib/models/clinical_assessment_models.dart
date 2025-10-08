// Klinik Değerlendirme Modelleri - Psikolog/Psikiyatrist Odaklı

class ClinicalAssessment {
  final String id;
  final String clientId;
  final String therapistId;
  final AssessmentType type;
  final DateTime assessmentDate;
  final Map<String, dynamic> responses;
  final Map<String, dynamic> scores;
  final String interpretation;
  final AssessmentSeverity severity;
  final List<String> recommendations;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicalAssessment({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.type,
    required this.assessmentDate,
    required this.responses,
    required this.scores,
    required this.interpretation,
    required this.severity,
    required this.recommendations,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'therapistId': therapistId,
      'type': type.name,
      'assessmentDate': assessmentDate.toIso8601String(),
      'responses': responses,
      'scores': scores,
      'interpretation': interpretation,
      'severity': severity.name,
      'recommendations': recommendations,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ClinicalAssessment.fromJson(Map<String, dynamic> json) {
    return ClinicalAssessment(
      id: json['id'],
      clientId: json['clientId'],
      therapistId: json['therapistId'],
      type: AssessmentType.values.firstWhere((e) => e.name == json['type']),
      assessmentDate: DateTime.parse(json['assessmentDate']),
      responses: Map<String, dynamic>.from(json['responses']),
      scores: Map<String, dynamic>.from(json['scores']),
      interpretation: json['interpretation'],
      severity: AssessmentSeverity.values.firstWhere((e) => e.name == json['severity']),
      recommendations: List<String>.from(json['recommendations']),
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum AssessmentType {
  phq9,           // Patient Health Questionnaire-9 (Depresyon)
  gad7,           // Generalized Anxiety Disorder-7 (Anksiyete)
  bdi,            // Beck Depression Inventory
  bai,            // Beck Anxiety Inventory
  pcl5,           // PTSD Checklist-5 (Travma)
  ybocs,          // Yale-Brown Obsessive Compulsive Scale
  mmpi2,          // Minnesota Multiphasic Personality Inventory-2
  wisc,           // Wechsler Intelligence Scale for Children
  wais,           // Wechsler Adult Intelligence Scale
  rorschach,      // Rorschach Test
  thematic,       // Thematic Apperception Test
  mmpi,           // Minnesota Multiphasic Personality Inventory
  hamilton,       // Hamilton Depression Rating Scale
  hamiltonAnxiety, // Hamilton Anxiety Rating Scale
  mini,           // Mini International Neuropsychiatric Interview
  scid,           // Structured Clinical Interview for DSM
  custom,         // Özel değerlendirme
}

enum AssessmentSeverity {
  minimal,        // Minimal
  mild,           // Hafif
  moderate,       // Orta
  severe,         // Şiddetli
  extreme,        // Aşırı şiddetli
}

class AssessmentQuestion {
  final String id;
  final String question;
  final String description;
  final List<AssessmentOption> options;
  final QuestionType type;
  final bool isRequired;
  final String category;

  AssessmentQuestion({
    required this.id,
    required this.question,
    required this.description,
    required this.options,
    required this.type,
    this.isRequired = true,
    required this.category,
  });
}

class AssessmentOption {
  final String id;
  final String text;
  final int value;
  final String description;

  AssessmentOption({
    required this.id,
    required this.text,
    required this.value,
    required this.description,
  });
}

enum QuestionType {
  singleChoice,   // Tek seçim
  multipleChoice, // Çoklu seçim
  scale,          // Ölçek (1-10)
  text,           // Metin
  number,         // Sayı
  date,           // Tarih
  boolean,        // Evet/Hayır
}

// PHQ-9 Değerlendirme Şablonu
class PHQ9Template {
  static List<AssessmentQuestion> getQuestions() {
    return [
      AssessmentQuestion(
        id: 'phq9_1',
        question: 'Son 2 hafta boyunca, aşağıdaki sorunlardan hiçbirini yaşamadınız mı?',
        description: 'Hiç ilgi duymama veya zevk alamama',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_2',
        question: 'Son 2 hafta boyunca, kendinizi üzgün, depresif veya umutsuz hissettiniz mi?',
        description: 'Üzgün, depresif veya umutsuz hissetme',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_3',
        question: 'Son 2 hafta boyunca, uykuya dalmakta veya uykuyu sürdürmekte zorluk yaşadınız mı?',
        description: 'Uyku problemleri',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_4',
        question: 'Son 2 hafta boyunca, kendinizi yorgun veya enerjisiz hissettiniz mi?',
        description: 'Yorgunluk veya enerji kaybı',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_5',
        question: 'Son 2 hafta boyunca, iştahınızda değişiklik oldu mu?',
        description: 'İştah değişiklikleri',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_6',
        question: 'Son 2 hafta boyunca, kendinizi başarısız hissettiniz mi?',
        description: 'Kendini başarısız hissetme',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_7',
        question: 'Son 2 hafta boyunca, konsantre olmakta zorluk yaşadınız mı?',
        description: 'Konsantrasyon güçlüğü',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_8',
        question: 'Son 2 hafta boyunca, konuşmanızda veya hareketlerinizde yavaşlama oldu mu?',
        description: 'Psikomotor yavaşlama',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
      AssessmentQuestion(
        id: 'phq9_9',
        question: 'Son 2 hafta boyunca, kendinize zarar vermeyi düşündünüz mü?',
        description: 'İntihar düşünceleri',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Depresyon',
      ),
    ];
  }

  static Map<String, dynamic> calculateScore(Map<String, dynamic> responses) {
    int totalScore = 0;
    for (int i = 1; i <= 9; i++) {
      final response = responses['phq9_$i'];
      if (response != null) {
        totalScore += response as int;
      }
    }

    AssessmentSeverity severity;
    String interpretation;
    List<String> recommendations = [];

    if (totalScore <= 4) {
      severity = AssessmentSeverity.minimal;
      interpretation = 'Minimal depresyon belirtileri. Rutin takip önerilir.';
      recommendations = ['Düzenli egzersiz', 'Sağlıklı beslenme', 'Stres yönetimi'];
    } else if (totalScore <= 9) {
      severity = AssessmentSeverity.mild;
      interpretation = 'Hafif depresyon belirtileri. Psikoeğitim ve destekleyici terapi önerilir.';
      recommendations = ['Psikoeğitim', 'Destekleyici terapi', 'Yaşam tarzı değişiklikleri'];
    } else if (totalScore <= 14) {
      severity = AssessmentSeverity.moderate;
      interpretation = 'Orta düzeyde depresyon belirtileri. Psikoterapi ve ilaç değerlendirmesi önerilir.';
      recommendations = ['Bilişsel davranışçı terapi', 'İlaç değerlendirmesi', 'Düzenli takip'];
    } else if (totalScore <= 19) {
      severity = AssessmentSeverity.severe;
      interpretation = 'Şiddetli depresyon belirtileri. Acil psikoterapi ve ilaç tedavisi önerilir.';
      recommendations = ['Acil psikoterapi', 'Antidepresan tedavi', 'Sık takip', 'Aile desteği'];
    } else {
      severity = AssessmentSeverity.extreme;
      interpretation = 'Aşırı şiddetli depresyon belirtileri. Acil müdahale ve hastane değerlendirmesi gerekebilir.';
      recommendations = ['Acil psikiyatrik değerlendirme', 'Hastane yatışı değerlendirmesi', 'İntihar riski değerlendirmesi'];
    }

    return {
      'totalScore': totalScore,
      'severity': severity.name,
      'interpretation': interpretation,
      'recommendations': recommendations,
    };
  }
}

// GAD-7 Değerlendirme Şablonu
class GAD7Template {
  static List<AssessmentQuestion> getQuestions() {
    return [
      AssessmentQuestion(
        id: 'gad7_1',
        question: 'Son 2 hafta boyunca, sinirlilik, endişe veya gerginlik hissettiniz mi?',
        description: 'Sinirlilik, endişe veya gerginlik',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
      AssessmentQuestion(
        id: 'gad7_2',
        question: 'Son 2 hafta boyunca, endişelerinizi durdurmakta veya kontrol etmekte zorluk yaşadınız mı?',
        description: 'Endişe kontrolü güçlüğü',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
      AssessmentQuestion(
        id: 'gad7_3',
        question: 'Son 2 hafta boyunca, farklı şeyler hakkında çok fazla endişelendiniz mi?',
        description: 'Aşırı endişelenme',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
      AssessmentQuestion(
        id: 'gad7_4',
        question: 'Son 2 hafta boyunca, rahatlamakta zorluk yaşadınız mı?',
        description: 'Rahatlama güçlüğü',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
      AssessmentQuestion(
        id: 'gad7_5',
        question: 'Son 2 hafta boyunca, o kadar huzursuzdunuz ki oturmakta zorluk yaşadınız mı?',
        description: 'Huzursuzluk',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
      AssessmentQuestion(
        id: 'gad7_6',
        question: 'Son 2 hafta boyunca, kolayca sinirlenir veya rahatsız olur musunuz?',
        description: 'Kolay sinirlenme',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
      AssessmentQuestion(
        id: 'gad7_7',
        question: 'Son 2 hafta boyunca, korkacak bir şey olacağından korktunuz mu?',
        description: 'Korku hissi',
        options: [
          AssessmentOption(id: '0', text: 'Hiç', value: 0, description: 'Hiç'),
          AssessmentOption(id: '1', text: 'Birkaç gün', value: 1, description: 'Birkaç gün'),
          AssessmentOption(id: '2', text: 'Yarıdan fazla gün', value: 2, description: 'Yarıdan fazla gün'),
          AssessmentOption(id: '3', text: 'Neredeyse her gün', value: 3, description: 'Neredeyse her gün'),
        ],
        type: QuestionType.singleChoice,
        category: 'Anksiyete',
      ),
    ];
  }

  static Map<String, dynamic> calculateScore(Map<String, dynamic> responses) {
    int totalScore = 0;
    for (int i = 1; i <= 7; i++) {
      final response = responses['gad7_$i'];
      if (response != null) {
        totalScore += response as int;
      }
    }

    AssessmentSeverity severity;
    String interpretation;
    List<String> recommendations = [];

    if (totalScore <= 4) {
      severity = AssessmentSeverity.minimal;
      interpretation = 'Minimal anksiyete belirtileri. Rutin takip önerilir.';
      recommendations = ['Stres yönetimi', 'Nefes egzersizleri', 'Düzenli uyku'];
    } else if (totalScore <= 9) {
      severity = AssessmentSeverity.mild;
      interpretation = 'Hafif anksiyete belirtileri. Psikoeğitim ve gevşeme teknikleri önerilir.';
      recommendations = ['Psikoeğitim', 'Gevşeme teknikleri', 'Yaşam tarzı değişiklikleri'];
    } else if (totalScore <= 14) {
      severity = AssessmentSeverity.moderate;
      interpretation = 'Orta düzeyde anksiyete belirtileri. Psikoterapi ve ilaç değerlendirmesi önerilir.';
      recommendations = ['Bilişsel davranışçı terapi', 'İlaç değerlendirmesi', 'Düzenli takip'];
    } else {
      severity = AssessmentSeverity.severe;
      interpretation = 'Şiddetli anksiyete belirtileri. Acil psikoterapi ve ilaç tedavisi önerilir.';
      recommendations = ['Acil psikoterapi', 'Anksiyolitik tedavi', 'Sık takip', 'Aile desteği'];
    }

    return {
      'totalScore': totalScore,
      'severity': severity.name,
      'interpretation': interpretation,
      'recommendations': recommendations,
    };
  }
}
