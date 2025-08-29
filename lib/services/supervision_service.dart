import 'dart:math';
import '../models/supervision_models.dart';

class SupervisionService {
  static final SupervisionService _instance = SupervisionService._internal();
  factory SupervisionService() => _instance;
  SupervisionService._internal();

  bool _isInitialized = false;
  final List<SupervisionSession> _sessions = [];
  final List<TherapistPerformance> _performances = [];
  final List<SupervisionActivity> _activities = [];
  final Random _random = Random();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Demo verileri yükle
    await _loadDemoData();
    _isInitialized = true;
    print('SupervisionService initialized with ${_sessions.length} sessions and ${_performances.length} performances');
  }

  Future<void> _loadDemoData() async {
    // Demo süpervizyon seansları
    _sessions.addAll([
      SupervisionSession(
        id: '1',
        title: 'Depresyon Vakası Süpervizyonu',
        supervisorId: 'supervisor1',
        therapistId: 'therapist1',
        therapistName: 'Dr. Ayşe Demir',
        clientId: 'client1',
        type: SupervisionType.individual,
        status: SupervisionStatus.completed,
        scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
        actualDate: DateTime.now().subtract(const Duration(days: 2)),
        duration: const Duration(minutes: 60),
        notes: 'Depresyon vakası üzerinde çalışma teknikleri gözden geçirildi. CBT yaklaşımı başarılı.',
        topics: ['CBT Teknikleri', 'Depresyon Vakası', 'Vaka Formülasyonu'],
        actionItems: ['Haftalık ödev takibi yapılacak', 'Bir sonraki seans planlanacak'],
        aiSummary: {
          'keyInsights': ['Terapist CBT tekniklerini etkili kullanıyor', 'Vaka formülasyonu güçlü'],
          'recommendations': ['Haftalık ödev takibi artırılsın', 'Vaka notları daha detaylı tutulsun'],
          'riskFactors': ['Düşük risk', 'İyi ilerleme'],
        },
        performanceRating: PerformanceRating.excellent,
        feedback: 'Mükemmel vaka yönetimi. CBT tekniklerini çok iyi uyguluyor.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SupervisionSession(
        id: '2',
        title: 'PTSD Vakası Kriz Yönetimi',
        supervisorId: 'supervisor1',
        therapistId: 'therapist2',
        therapistName: 'Dr. Mehmet Kaya',
        clientId: 'client3',
        type: SupervisionType.caseReview,
        status: SupervisionStatus.inProgress,
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
        duration: const Duration(minutes: 90),
        notes: 'Karmaşık PTSD vakası. Terapist desteğe ihtiyaç duyuyor.',
        topics: ['PTSD Vakası', 'Kriz Yönetimi', 'Güvenlik Planı'],
        actionItems: ['Güvenlik planı geliştirilecek', 'Kriz müdahale protokolü gözden geçirilecek'],
        aiSummary: {
          'keyInsights': ['Vaka karmaşık', 'Terapist desteğe ihtiyaç duyuyor'],
          'recommendations': ['Güvenlik planı geliştirilsin', 'Kriz müdahale protokolü uygulansın'],
          'riskFactors': ['Yüksek risk', 'Acil müdahale gerekebilir'],
        },
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      SupervisionSession(
        id: '3',
        title: 'Yeni Terapist Beceri Değerlendirmesi',
        supervisorId: 'supervisor1',
        therapistId: 'therapist3',
        therapistName: 'Dr. Fatma Özkan',
        clientId: 'client5',
        type: SupervisionType.skillAssessment,
        status: SupervisionStatus.pending,
        scheduledDate: DateTime.now().add(const Duration(days: 3)),
        duration: const Duration(minutes: 45),
        notes: 'Yeni terapist beceri değerlendirmesi. Temel teknikler gözden geçirilecek.',
        topics: ['Temel Terapi Teknikleri', 'Vaka Notları', 'Etik Kurallar'],
        actionItems: ['Temel teknikler pratik edilecek', 'Vaka notları şablonu hazırlanacak'],
        aiSummary: {
          'keyInsights': ['Yeni terapist', 'Temel eğitim gerekli'],
          'recommendations': ['Temel teknikler pratik edilsin', 'Mentorluk programı başlatılsın'],
          'riskFactors': ['Düşük risk', 'Eğitim odaklı'],
        },
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SupervisionSession(
        id: '4',
        title: 'Grup Süpervizyonu - Aile Terapisi',
        supervisorId: 'supervisor1',
        therapistId: 'therapist4',
        therapistName: 'Dr. Ali Yılmaz',
        clientId: null,
        type: SupervisionType.group,
        status: SupervisionStatus.completed,
        scheduledDate: DateTime.now().subtract(const Duration(days: 5)),
        actualDate: DateTime.now().subtract(const Duration(days: 5)),
        duration: const Duration(minutes: 120),
        notes: 'Aile terapisi teknikleri üzerine grup süpervizyonu. Sistemik yaklaşım tartışıldı.',
        topics: ['Aile Terapisi', 'Sistemik Yaklaşım', 'Grup Dinamikleri'],
        actionItems: ['Sistemik yaklaşım teknikleri pratik edilecek', 'Vaka örnekleri paylaşılacak'],
        aiSummary: {
          'keyInsights': ['Grup dinamikleri güçlü', 'Sistemik yaklaşım anlaşıldı'],
          'recommendations': ['Daha fazla pratik yapılsın', 'Vaka örnekleri artırılsın'],
          'riskFactors': ['Düşük risk', 'İyi ilerleme'],
        },
        performanceRating: PerformanceRating.veryGood,
        feedback: 'Grup süpervizyonu çok verimli geçti. Sistemik yaklaşım iyi anlaşıldı.',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      SupervisionSession(
        id: '5',
        title: 'Kriz Müdahalesi Süpervizyonu',
        supervisorId: 'supervisor1',
        therapistId: 'therapist5',
        therapistName: 'Dr. Zeynep Kaya',
        clientId: 'client7',
        type: SupervisionType.crisis,
        status: SupervisionStatus.completed,
        scheduledDate: DateTime.now().subtract(const Duration(days: 7)),
        actualDate: DateTime.now().subtract(const Duration(days: 7)),
        duration: const Duration(minutes: 60),
        notes: 'Acil kriz müdahalesi sonrası süpervizyon. Güvenlik protokolleri gözden geçirildi.',
        topics: ['Kriz Müdahalesi', 'Güvenlik Protokolleri', 'Acil Durum Planı'],
        actionItems: ['Güvenlik protokolleri güncellenecek', 'Kriz müdahale ekibi eğitilecek'],
        aiSummary: {
          'keyInsights': ['Kriz müdahalesi başarılı', 'Güvenlik protokolleri iyileştirilmeli'],
          'recommendations': ['Protokoller güncellensin', 'Ekip eğitimi yapılsın'],
          'riskFactors': ['Orta risk', 'Protokol iyileştirmesi gerekli'],
        },
        performanceRating: PerformanceRating.good,
        feedback: 'Kriz müdahalesi başarılı ancak protokoller iyileştirilmeli.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);

    // Demo terapist performansları
    _performances.addAll([
      TherapistPerformance(
        id: '1',
        therapistId: 'therapist1',
        therapistName: 'Dr. Ayşe Demir',
        specialization: 'CBT ve Depresyon',
        successRate: 0.93,
        caseCount: 45,
        averageRating: 4.8,
        improvementRate: 0.15,
        notes: 'CBT tekniklerinde mükemmel, vaka notlarında gelişim alanı',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        strengths: ['CBT Teknikleri', 'Vaka Formülasyonu', 'Terapötik İlişki'],
        improvementAreas: ['Vaka Notları', 'Dokümantasyon'],
        skillScores: {
          'CBT': 9.5,
          'Vaka Formülasyonu': 9.0,
          'Terapötik İlişki': 9.2,
          'Dokümantasyon': 7.8,
        },
      ),
      TherapistPerformance(
        id: '2',
        therapistId: 'therapist2',
        therapistName: 'Dr. Mehmet Kaya',
        specialization: 'Kriz Müdahalesi ve Aile Terapisi',
        successRate: 0.92,
        caseCount: 38,
        averageRating: 4.5,
        improvementRate: 0.12,
        notes: 'Kriz müdahalesinde güçlü, dokümantasyonda gelişim alanı',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 4)),
        isActive: true,
        strengths: ['Kriz Müdahalesi', 'Aile Terapisi', 'Güvenlik'],
        improvementAreas: ['Dokümantasyon', 'Vaka Takibi'],
        skillScores: {
          'Kriz Müdahalesi': 9.8,
          'Aile Terapisi': 8.9,
          'Güvenlik': 9.5,
          'Dokümantasyon': 7.5,
        },
      ),
      TherapistPerformance(
        id: '3',
        therapistId: 'therapist3',
        therapistName: 'Dr. Fatma Özkan',
        specialization: 'Genel Terapi',
        successRate: 0.83,
        caseCount: 12,
        averageRating: 4.2,
        improvementRate: 0.08,
        notes: 'Yeni terapist, temel becerilerde gelişim gösteriyor',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
        strengths: ['Temel Teknikler', 'Öğrenme İsteği', 'Etik Kurallar'],
        improvementAreas: ['Vaka Yönetimi', 'Teknik Uygulama'],
        skillScores: {
          'Temel Teknikler': 7.5,
          'Vaka Yönetimi': 6.8,
          'Teknik Uygulama': 7.0,
          'Etik Kurallar': 8.5,
        },
      ),
      TherapistPerformance(
        id: '4',
        therapistId: 'therapist4',
        therapistName: 'Dr. Ali Yılmaz',
        specialization: 'Aile ve Çift Terapisi',
        successRate: 0.89,
        caseCount: 32,
        averageRating: 4.6,
        improvementRate: 0.18,
        notes: 'Aile terapisi uzmanı, grup süpervizyonlarında başarılı',
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
        strengths: ['Aile Terapisi', 'Grup Dinamikleri', 'Sistemik Yaklaşım'],
        improvementAreas: ['Bireysel Vaka Yönetimi', 'Raporlama'],
        skillScores: {
          'Aile Terapisi': 9.2,
          'Grup Dinamikleri': 8.8,
          'Sistemik Yaklaşım': 9.0,
          'Bireysel Vaka': 7.5,
        },
      ),
      TherapistPerformance(
        id: '5',
        therapistId: 'therapist5',
        therapistName: 'Dr. Zeynep Kaya',
        specialization: 'Kriz ve Travma',
        successRate: 0.87,
        caseCount: 28,
        averageRating: 4.4,
        improvementRate: 0.10,
        notes: 'Kriz müdahalesinde deneyimli, travma terapisi geliştirilmeli',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
        isActive: true,
        strengths: ['Kriz Müdahalesi', 'Güvenlik', 'Hızlı Müdahale'],
        improvementAreas: ['Travma Terapisi', 'Uzun Vadeli Takip'],
        skillScores: {
          'Kriz Müdahalesi': 9.3,
          'Güvenlik': 9.7,
          'Travma Terapisi': 7.8,
          'Uzun Vadeli Takip': 7.2,
        },
      ),
    ]);

    // Demo aktiviteler
    _activities.addAll([
      SupervisionActivity(
        id: '1',
        type: SupervisionActivityType.sessionCreated,
        description: 'Yeni süpervizyon seansı oluşturuldu: Depresyon Vakası',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        userId: 'supervisor1',
        userName: 'Dr. Ahmet Süpervizör',
        sessionId: '1',
        therapistId: 'therapist1',
      ),
      SupervisionActivity(
        id: '2',
        type: SupervisionActivityType.sessionCompleted,
        description: 'Süpervizyon seansı tamamlandı: Depresyon Vakası',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'supervisor1',
        userName: 'Dr. Ahmet Süpervizör',
        sessionId: '1',
        therapistId: 'therapist1',
      ),
      SupervisionActivity(
        id: '3',
        type: SupervisionActivityType.feedbackGiven,
        description: 'Performans geri bildirimi verildi: Dr. Ayşe Demir',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'supervisor1',
        userName: 'Dr. Ahmet Süpervizör',
        sessionId: '1',
        therapistId: 'therapist1',
      ),
      SupervisionActivity(
        id: '4',
        type: SupervisionActivityType.performanceUpdated,
        description: 'Terapist performansı güncellendi: Dr. Mehmet Kaya',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        userId: 'supervisor1',
        userName: 'Dr. Ahmet Süpervizör',
        therapistId: 'therapist2',
      ),
      SupervisionActivity(
        id: '5',
        type: SupervisionActivityType.sessionCreated,
        description: 'Yeni süpervizyon seansı oluşturuldu: PTSD Vakası',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'supervisor1',
        userName: 'Dr. Ahmet Süpervizör',
        sessionId: '2',
        therapistId: 'therapist2',
      ),
    ]);
  }

  // Süpervizyon seansları işlemleri
  Future<List<SupervisionSession>> getSupervisionSessions() async {
    await initialize();
    return List.unmodifiable(_sessions);
  }

  Future<SupervisionSession?> getSessionById(String id) async {
    await initialize();
    try {
      return _sessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addSession(SupervisionSession session) async {
    await initialize();
    _sessions.add(session);
    
    // Aktivite ekle
    _activities.add(SupervisionActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: SupervisionActivityType.sessionCreated,
      description: 'Yeni süpervizyon seansı oluşturuldu: ${session.title}',
      timestamp: DateTime.now(),
      userId: 'current_user',
      userName: 'Mevcut Kullanıcı',
      sessionId: session.id,
      therapistId: session.therapistId,
    ));
  }

  Future<void> updateSession(SupervisionSession session) async {
    await initialize();
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session.copyWith(
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> deleteSession(String id) async {
    await initialize();
    _sessions.removeWhere((session) => session.id == id);
  }

  // Terapist performansları işlemleri
  Future<List<TherapistPerformance>> getTherapistPerformances() async {
    await initialize();
    return List.unmodifiable(_performances);
  }

  Future<TherapistPerformance?> getPerformanceById(String id) async {
    await initialize();
    try {
      return _performances.firstWhere((performance) => performance.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addPerformance(TherapistPerformance performance) async {
    await initialize();
    _performances.add(performance);
  }

  Future<void> updatePerformance(TherapistPerformance performance) async {
    await initialize();
    final index = _performances.indexWhere((p) => p.id == performance.id);
    if (index != -1) {
      _performances[index] = performance.copyWith(
        lastUpdated: DateTime.now(),
      );
    }
  }

  Future<void> deletePerformance(String id) async {
    await initialize();
    _performances.removeWhere((performance) => performance.id == id);
  }

  // Kalite metrikleri işlemleri
  Future<QualityMetrics> getQualityMetrics() async {
    await initialize();
    
    if (_sessions.isEmpty) {
      return QualityMetrics.empty();
    }

    final completedSessions = _sessions.where((s) => s.status == SupervisionStatus.completed);
    final totalSessions = _sessions.length;
    final successfulSessions = completedSessions.where((s) => 
      s.performanceRating == PerformanceRating.good || 
      s.performanceRating == PerformanceRating.veryGood || 
      s.performanceRating == PerformanceRating.excellent
    ).length;

    // Ortalama skor hesapla
    double totalScore = 0;
    int ratedSessions = 0;
    
    for (final session in completedSessions) {
      if (session.performanceRating != null) {
        totalScore += _getRatingScore(session.performanceRating!);
        ratedSessions++;
      }
    }

    final averageScore = ratedSessions > 0 ? totalScore / ratedSessions : 0.0;
    final qualityRate = totalSessions > 0 ? successfulSessions / totalSessions : 0.0;

    // İyileştirme alanları
    final improvementAreas = <String>[];
    if (qualityRate < 0.8) improvementAreas.add('Genel kalite');
    if (averageScore < 8.0) improvementAreas.add('Performans skorları');
    
    final pendingSessions = _sessions.where((s) => s.status == SupervisionStatus.pending).length;
    if (pendingSessions > 3) improvementAreas.add('Seans planlaması');

    // Metrik skorları
    final metricScores = <String, double>{
      'Genel Kalite': qualityRate * 10,
      'Performans': averageScore,
      'Planlama': (totalSessions - pendingSessions) / totalSessions * 10,
      'Geri Bildirim': ratedSessions / totalSessions * 10,
    };

    return QualityMetrics(
      averageScore: averageScore,
      qualityRate: qualityRate,
      totalSessions: totalSessions,
      successfulSessions: successfulSessions,
      improvementAreas: improvementAreas,
      metricScores: metricScores,
      lastUpdated: DateTime.now(),
    );
  }

  double _getRatingScore(PerformanceRating rating) {
    switch (rating) {
      case PerformanceRating.poor:
        return 3.0;
      case PerformanceRating.fair:
        return 5.0;
      case PerformanceRating.good:
        return 7.0;
      case PerformanceRating.veryGood:
        return 8.5;
      case PerformanceRating.excellent:
        return 10.0;
    }
  }

  // Aktivite işlemleri
  List<SupervisionActivity> getRecentActivities() {
    final sortedActivities = List<SupervisionActivity>.from(_activities);
    sortedActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedActivities;
  }

  Future<void> addActivity(SupervisionActivity activity) async {
    await initialize();
    _activities.add(activity);
  }

  // Arama ve filtreleme
  Future<List<SupervisionSession>> searchSessions(String query) async {
    await initialize();
    if (query.isEmpty) return getSupervisionSessions();
    
    final lowercaseQuery = query.toLowerCase();
    return _sessions.where((session) =>
      session.title.toLowerCase().contains(lowercaseQuery) ||
      session.therapistName.toLowerCase().contains(lowercaseQuery) ||
      session.notes.toLowerCase().contains(lowercaseQuery) ||
      session.topics.any((topic) => topic.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  Future<List<SupervisionSession>> getSessionsByStatus(SupervisionStatus status) async {
    await initialize();
    return _sessions.where((session) => session.status == status).toList();
  }

  Future<List<SupervisionSession>> getSessionsByType(SupervisionType type) async {
    await initialize();
    return _sessions.where((session) => session.type == type).toList();
  }

  Future<List<SupervisionSession>> getSessionsByTherapist(String therapistId) async {
    await initialize();
    return _sessions.where((session) => session.therapistId == therapistId).toList();
  }

  Future<List<SupervisionSession>> getOverdueSessions() async {
    await initialize();
    return _sessions.where((session) => session.isOverdue).toList();
  }

  Future<List<SupervisionSession>> getTodaySessions() async {
    await initialize();
    return _sessions.where((session) => session.isToday).toList();
  }

  // İstatistikler
  Map<String, int> getSessionsByTypeStats() {
    final stats = <String, int>{};
    for (final session in _sessions) {
      final typeKey = session.typeText;
      stats[typeKey] = (stats[typeKey] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, int> getSessionsByStatusStats() {
    final stats = <String, int>{};
    for (final session in _sessions) {
      final statusKey = session.statusText;
      stats[statusKey] = (stats[statusKey] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, double> getTherapistPerformanceStats() {
    final stats = <String, double>{};
    for (final performance in _performances) {
      stats[performance.therapistName] = performance.successRate;
    }
    return stats;
  }
}
