import 'dart:math';
import '../models/case_models.dart';

class CaseService {
  static final CaseService _instance = CaseService._internal();
  factory CaseService() => _instance;
  CaseService._internal();

  List<Case> _cases = [];
  List<CaseProgress> _progressRecords = [];
  List<CaseGoal> _goals = [];
  List<CaseIntervention> _interventions = [];

  void initialize() {
    _createDemoData();
  }

  void _createDemoData() {
    final now = DateTime.now();
    final random = Random();

    // Demo vaka verileri
    _cases = [
      Case(
        id: 'case_001',
        clientId: 'client_001',
        therapistId: 'therapist_001',
        title: 'Anksiyete ve Depresyon Tedavisi',
        description: 'Genel anksiyete bozukluğu ve hafif depresyon semptomları ile gelen 28 yaşında kadın hasta.',
        status: CaseStatus.active,
        priority: CasePriority.high,
        type: CaseType.individual,
        startDate: now.subtract(const Duration(days: 45)),
        lastSessionDate: now.subtract(const Duration(days: 7)),
        totalSessions: 6,
        progressIndicator: ProgressIndicator.improving,
        diagnosis: 'F41.1 - Genel Anksiyete Bozukluğu, F32.1 - Hafif Depresif Epizod',
        goals: [
          'Anksiyete semptomlarını %50 azaltmak',
          'Günlük aktivitelere katılımı artırmak',
          'Uyku kalitesini iyileştirmek',
          'Stres yönetimi becerilerini geliştirmek'
        ],
        interventions: [
          'Bilişsel Davranışçı Terapi',
          'Mindfulness teknikleri',
          'Gevşeme egzersizleri',
          'Günlük aktivite planlaması'
        ],
        notes: [
          'İlk seans: Hasta motivasyonu yüksek, tedavi planı oluşturuldu',
          '3. seans: Anksiyete semptomlarında hafif azalma gözlemlendi',
          '6. seans: Uyku kalitesinde iyileşme, günlük aktivitelere katılım artıyor'
        ],
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Case(
        id: 'case_002',
        clientId: 'client_002',
        therapistId: 'therapist_001',
        title: 'Aile Terapisi - İletişim Problemleri',
        description: 'Ergen çocuk ile ebeveynler arasında iletişim problemleri yaşayan aile.',
        status: CaseStatus.active,
        priority: CasePriority.medium,
        type: CaseType.family,
        startDate: now.subtract(const Duration(days: 30)),
        lastSessionDate: now.subtract(const Duration(days: 3)),
        totalSessions: 4,
        progressIndicator: ProgressIndicator.stable,
        diagnosis: 'Z63.0 - Eş/partner ile ilgili problemler',
        goals: [
          'Aile içi iletişimi iyileştirmek',
          'Çatışma çözme becerilerini geliştirmek',
          'Sınırları netleştirmek',
          'Güven ortamı oluşturmak'
        ],
        interventions: [
          'Sistemik Aile Terapisi',
          'İletişim becerileri eğitimi',
          'Rol oyunları',
          'Ev ödevleri'
        ],
        notes: [
          'İlk seans: Aile dinamikleri değerlendirildi',
          '2. seans: İletişim kalıpları belirlendi',
          '4. seans: İyileşme belirtileri gözlemlendi'
        ],
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Case(
        id: 'case_003',
        clientId: 'client_003',
        therapistId: 'therapist_002',
        title: 'Travma Sonrası Stres Bozukluğu',
        description: 'Trafik kazası sonrası gelişen TSSB semptomları ile gelen 35 yaşında erkek hasta.',
        status: CaseStatus.active,
        priority: CasePriority.urgent,
        type: CaseType.individual,
        startDate: now.subtract(const Duration(days: 15)),
        lastSessionDate: now.subtract(const Duration(days: 1)),
        totalSessions: 3,
        progressIndicator: ProgressIndicator.fluctuating,
        diagnosis: 'F43.1 - Travma Sonrası Stres Bozukluğu',
        goals: [
          'Travma anılarını işlemek',
          'Kaçınma davranışlarını azaltmak',
          'Günlük işlevselliği geri kazanmak',
          'Güvenlik hissini yeniden oluşturmak'
        ],
        interventions: [
          'EMDR Terapisi',
          'Travma Odaklı BDT',
          'Güvenlik planlaması',
          'Gevşeme teknikleri'
        ],
        notes: [
          'İlk seans: Travma hikayesi alındı, güvenlik planı oluşturuldu',
          '2. seans: EMDR başlatıldı, hasta yoğun duygusal tepki verdi',
          '3. seans: Semptomlarda dalgalanma, ek destek gerekli'
        ],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Case(
        id: 'case_004',
        clientId: 'client_004',
        therapistId: 'therapist_002',
        title: 'Çift Terapisi - Evlilik Problemleri',
        description: '10 yıllık evlilikte iletişim ve güven problemleri yaşayan çift.',
        status: CaseStatus.onHold,
        priority: CasePriority.medium,
        type: CaseType.couple,
        startDate: now.subtract(const Duration(days: 60)),
        lastSessionDate: now.subtract(const Duration(days: 20)),
        totalSessions: 8,
        progressIndicator: ProgressIndicator.stable,
        diagnosis: 'Z63.0 - Eş/partner ile ilgili problemler',
        goals: [
          'İletişim kalitesini artırmak',
          'Güven ilişkisini yeniden kurmak',
          'Çatışma çözme becerilerini geliştirmek',
          'Ortak hedefler belirlemek'
        ],
        interventions: [
          'Çift Terapisi',
          'İletişim becerileri eğitimi',
          'Güven oluşturma egzersizleri',
          'Ev ödevleri'
        ],
        notes: [
          'İlk seans: Çift dinamikleri değerlendirildi',
          '4. seans: İletişimde iyileşme gözlemlendi',
          '8. seans: Çift mola vermek istedi, onHold durumuna alındı'
        ],
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      Case(
        id: 'case_005',
        clientId: 'client_005',
        therapistId: 'therapist_001',
        title: 'Panik Bozukluk Tedavisi',
        description: 'Panik atakları ile gelen 42 yaşında kadın hasta.',
        status: CaseStatus.completed,
        priority: CasePriority.high,
        type: CaseType.individual,
        startDate: now.subtract(const Duration(days: 120)),
        endDate: now.subtract(const Duration(days: 30)),
        lastSessionDate: now.subtract(const Duration(days: 30)),
        totalSessions: 12,
        progressIndicator: ProgressIndicator.improving,
        diagnosis: 'F41.0 - Panik Bozukluk',
        goals: [
          'Panik ataklarını tamamen durdurmak',
          'Agorafobi semptomlarını azaltmak',
          'Günlük aktivitelere güvenle katılmak',
          'Stres yönetimi becerilerini geliştirmek'
        ],
        interventions: [
          'Panik Odaklı BDT',
          'Solunum teknikleri',
          'Maruz bırakma terapisi',
          'Relaksasyon egzersizleri'
        ],
        notes: [
          'İlk seans: Panik hikayesi alındı, tedavi planı oluşturuldu',
          '6. seans: Panik atak sıklığında belirgin azalma',
          '12. seans: Hasta tamamen iyileşti, tedavi tamamlandı'
        ],
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    ];

    // Demo ilerleme kayıtları
    _progressRecords = [
      CaseProgress(
        id: 'progress_001',
        caseId: 'case_001',
        assessmentDate: now.subtract(const Duration(days: 7)),
        assessorId: 'therapist_001',
        progressIndicator: ProgressIndicator.improving,
        notes: 'Hasta anksiyete semptomlarında belirgin iyileşme gösteriyor. Uyku kalitesi artıyor ve günlük aktivitelere katılım yükseliyor.',
        achievements: [
          'Anksiyete semptomları %40 azaldı',
          'Uyku kalitesi iyileşti',
          'Günlük aktivitelere katılım %60 arttı'
        ],
        challenges: [
          'Stresli durumlarda hala zorlanıyor',
          'Sosyal ortamlarda kaygı yaşıyor'
        ],
        nextSteps: [
          'Stres yönetimi tekniklerini güçlendirmek',
          'Sosyal maruz bırakma egzersizleri eklemek',
          'Mindfulness pratiğini artırmak'
        ],
        metrics: {
          'anxiety_score': 4.2,
          'sleep_quality': 7.5,
          'daily_activity': 6.8,
        },
      ),
      CaseProgress(
        id: 'progress_002',
        caseId: 'case_002',
        assessmentDate: now.subtract(const Duration(days: 3)),
        assessorId: 'therapist_001',
        progressIndicator: ProgressIndicator.stable,
        notes: 'Aile iletişiminde iyileşme belirtileri var ancak henüz istikrarlı değil. Çatışma çözme becerileri gelişiyor.',
        achievements: [
          'Aile içi iletişim kalitesi arttı',
          'Çatışma çözme becerileri gelişti',
          'Ev ödevleri düzenli yapılıyor'
        ],
        challenges: [
          'Eski iletişim kalıpları bazen tekrarlanıyor',
          'Stresli durumlarda geriye dönüş olabiliyor'
        ],
        nextSteps: [
          'İletişim becerilerini pekiştirmek',
          'Stres yönetimi eklemek',
          'Rol oyunları ile pratik yapmak'
        ],
        metrics: {
          'communication_quality': 6.5,
          'conflict_resolution': 6.0,
          'homework_completion': 8.0,
        },
      ),
    ];

    // Demo hedefler
    _goals = [
      CaseGoal(
        id: 'goal_001',
        caseId: 'case_001',
        title: 'Anksiyete Semptomlarını Azaltmak',
        description: 'Genel anksiyete bozukluğu semptomlarını %50 oranında azaltmak',
        targetDate: now.add(const Duration(days: 30)),
        milestones: [
          'İlk 2 hafta: Semptomları %20 azaltmak',
          '4. hafta: Semptomları %35 azaltmak',
          '6. hafta: Semptomları %50 azaltmak'
        ],
        completedMilestones: [
          'İlk 2 hafta: Semptomları %20 azaltmak',
          '4. hafta: Semptomları %35 azaltmak'
        ],
      ),
      CaseGoal(
        id: 'goal_002',
        caseId: 'case_001',
        title: 'Uyku Kalitesini İyileştirmek',
        description: 'Uyku kalitesini 7/10 seviyesine çıkarmak',
        targetDate: now.add(const Duration(days: 21)),
        milestones: [
          '1. hafta: Uyku kalitesini 6/10 yapmak',
          '2. hafta: Uyku kalitesini 6.5/10 yapmak',
          '3. hafta: Uyku kalitesini 7/10 yapmak'
        ],
        completedMilestones: [
          '1. hafta: Uyku kalitesini 6/10 yapmak',
          '2. hafta: Uyku kalitesini 6.5/10 yapmak'
        ],
      ),
    ];

    // Demo müdahaleler
    _interventions = [
      CaseIntervention(
        id: 'intervention_001',
        caseId: 'case_001',
        title: 'Bilişsel Davranışçı Terapi',
        description: 'Anksiyete ile ilgili düşünce kalıplarını değiştirmek ve davranışsal tepkileri düzenlemek',
        interventionType: 'Psikoterapi',
        startDate: now.subtract(const Duration(days: 45)),
        isActive: true,
        techniques: [
          'Düşünce kayıtları',
          'Bilişsel yeniden yapılandırma',
          'Davranışsal deneyler',
          'Gevşeme teknikleri'
        ],
        notes: 'Hasta BDT tekniklerini iyi öğreniyor ve uyguluyor. Düşünce kayıtları düzenli tutuluyor.',
      ),
      CaseIntervention(
        id: 'intervention_002',
        caseId: 'case_001',
        title: 'Mindfulness Teknikleri',
        description: 'Farkındalık ve meditasyon teknikleri ile anksiyete yönetimi',
        interventionType: 'Tamamlayıcı Terapi',
        startDate: now.subtract(const Duration(days: 30)),
        isActive: true,
        techniques: [
          'Nefes farkındalığı',
          'Vücut tarama',
          'Düşünce gözlemi',
          'Günlük mindfulness pratiği'
        ],
        notes: 'Mindfulness teknikleri hasta tarafından benimseniyor. Günlük pratik yapılıyor.',
      ),
    ];
  }

  // Vaka CRUD işlemleri
  List<Case> getAllCases() => List.unmodifiable(_cases);
  
  Case? getCaseById(String id) {
    try {
      return _cases.firstWhere((case_) => case_.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Case> getCasesByTherapist(String therapistId) {
    return _cases.where((case_) => case_.therapistId == therapistId).toList();
  }

  List<Case> getCasesByClient(String clientId) {
    return _cases.where((case_) => case_.clientId == clientId).toList();
  }

  List<Case> getCasesByStatus(CaseStatus status) {
    return _cases.where((case_) => case_.status == status).toList();
  }

  List<Case> getCasesByPriority(CasePriority priority) {
    return _cases.where((case_) => case_.priority == priority).toList();
  }

  List<Case> getCasesByType(CaseType type) {
    return _cases.where((case_) => case_.type == type).toList();
  }

  List<Case> getActiveCases() {
    return _cases.where((case_) => case_.isActive).toList();
  }

  List<Case> getUrgentCases() {
    return _cases.where((case_) => case_.isUrgent).toList();
  }

  List<Case> getCasesNeedingAttention() {
    return _cases.where((case_) => case_.needsAttention).toList();
  }

  Case addCase(Case newCase) {
    final case_ = newCase.copyWith(
      id: 'case_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _cases.add(case_);
    return case_;
  }

  Case? updateCase(String id, Case updatedCase) {
    final index = _cases.indexWhere((case_) => case_.id == id);
    if (index != -1) {
      final case_ = updatedCase.copyWith(
        updatedAt: DateTime.now(),
      );
      _cases[index] = case_;
      return case_;
    }
    return null;
  }

  bool deleteCase(String id) {
    final index = _cases.indexWhere((case_) => case_.id == id);
    if (index != -1) {
      _cases.removeAt(index);
      return true;
    }
    return false;
  }

  // İlerleme kayıtları
  List<CaseProgress> getProgressByCase(String caseId) {
    return _progressRecords
        .where((progress) => progress.caseId == caseId)
        .toList()
      ..sort((a, b) => b.assessmentDate.compareTo(a.assessmentDate));
  }

  CaseProgress addProgress(CaseProgress progress) {
    final newProgress = CaseProgress(
      id: 'progress_${DateTime.now().millisecondsSinceEpoch}',
      caseId: progress.caseId,
      assessmentDate: progress.assessmentDate,
      assessorId: progress.assessorId,
      progressIndicator: progress.progressIndicator,
      notes: progress.notes,
      achievements: progress.achievements,
      challenges: progress.challenges,
      nextSteps: progress.nextSteps,
      metrics: progress.metrics,
      metadata: progress.metadata,
    );
    _progressRecords.add(newProgress);
    return newProgress;
  }

  // Hedefler
  List<CaseGoal> getGoalsByCase(String caseId) {
    return _goals.where((goal) => goal.caseId == caseId).toList();
  }

  CaseGoal addGoal(CaseGoal goal) {
    final newGoal = CaseGoal(
      id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
      caseId: goal.caseId,
      title: goal.title,
      description: goal.description,
      targetDate: goal.targetDate,
      isCompleted: goal.isCompleted,
      completedDate: goal.completedDate,
      completionNotes: goal.completionNotes,
      milestones: goal.milestones,
      completedMilestones: goal.completedMilestones,
      metadata: goal.metadata,
    );
    _goals.add(newGoal);
    return newGoal;
  }

  CaseGoal? updateGoal(String id, CaseGoal updatedGoal) {
    final index = _goals.indexWhere((goal) => goal.id == id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      return updatedGoal;
    }
    return null;
  }

  // Müdahaleler
  List<CaseIntervention> getInterventionsByCase(String caseId) {
    return _interventions.where((intervention) => intervention.caseId == caseId).toList();
  }

  CaseIntervention addIntervention(CaseIntervention intervention) {
    final newIntervention = CaseIntervention(
      id: 'intervention_${DateTime.now().millisecondsSinceEpoch}',
      caseId: intervention.caseId,
      title: intervention.title,
      description: intervention.description,
      interventionType: intervention.interventionType,
      startDate: intervention.startDate,
      endDate: intervention.endDate,
      isActive: intervention.isActive,
      outcome: intervention.outcome,
      notes: intervention.notes,
      techniques: intervention.techniques,
      metadata: intervention.metadata,
    );
    _interventions.add(newIntervention);
    return newIntervention;
  }

  // Arama ve filtreleme
  List<Case> searchCases(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _cases.where((case_) {
      return case_.title.toLowerCase().contains(lowercaseQuery) ||
          case_.description.toLowerCase().contains(lowercaseQuery) ||
          case_.diagnosis?.toLowerCase().contains(lowercaseQuery) == true ||
          case_.goals.any((goal) => goal.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  List<Case> filterCases({
    CaseStatus? status,
    CasePriority? priority,
    CaseType? type,
    ProgressIndicator? progress,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _cases.where((case_) {
      if (status != null && case_.status != status) return false;
      if (priority != null && case_.priority != priority) return false;
      if (type != null && case_.type != type) return false;
      if (progress != null && case_.progressIndicator != progress) return false;
      if (startDate != null && case_.startDate.isBefore(startDate)) return false;
      if (endDate != null && case_.startDate.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  // İstatistikler
  Map<String, dynamic> getCaseStatistics() {
    final totalCases = _cases.length;
    final activeCases = _cases.where((case_) => case_.isActive).length;
    final completedCases = _cases.where((case_) => case_.isCompleted).length;
    final urgentCases = _cases.where((case_) => case_.isUrgent).length;

    final statusDistribution = <String, int>{};
    final priorityDistribution = <String, int>{};
    final typeDistribution = <String, int>{};
    final progressDistribution = <String, int>{};

    for (final case_ in _cases) {
      statusDistribution[case_.statusText] = (statusDistribution[case_.statusText] ?? 0) + 1;
      priorityDistribution[case_.priorityText] = (priorityDistribution[case_.priorityText] ?? 0) + 1;
      typeDistribution[case_.typeText] = (typeDistribution[case_.typeText] ?? 0) + 1;
      progressDistribution[case_.progressText] = (progressDistribution[case_.progressText] ?? 0) + 1;
    }

    final averageSessions = totalCases > 0 
        ? _cases.map((case_) => case_.totalSessions).reduce((a, b) => a + b) / totalCases 
        : 0.0;

    final averageCaseDuration = totalCases > 0 
        ? _cases.map((case_) {
            final end = case_.endDate ?? DateTime.now();
            return end.difference(case_.startDate).inDays;
          }).reduce((a, b) => a + b) / totalCases 
        : 0.0;

    return {
      'totalCases': totalCases,
      'activeCases': activeCases,
      'completedCases': completedCases,
      'urgentCases': urgentCases,
      'statusDistribution': statusDistribution,
      'priorityDistribution': priorityDistribution,
      'typeDistribution': typeDistribution,
      'progressDistribution': progressDistribution,
      'averageSessions': averageSessions,
      'averageCaseDuration': averageCaseDuration,
    };
  }

  // Veri temizleme
  void clearAllData() {
    _cases.clear();
    _progressRecords.clear();
    _goals.clear();
    _interventions.clear();
  }
}
