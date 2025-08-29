import '../models/session_models.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  // Demo veriler
  final List<Session> _sessions = [];
  final List<Client> _clients = [];
  final List<SessionNote> _sessionNotes = [];
  final List<AISummary> _aiSummaries = [];
  final List<SessionGoal> _goals = [];
  final List<SessionHomework> _homework = [];

  // Initialize demo data
  Future<void> initialize() async {
    // Demo danışanlar
    _clients.addAll([
      Client(
        id: 'client_001',
        name: 'Ayşe Yılmaz',
        email: 'ayse.yilmaz@email.com',
        phone: '+90 555 123 4567',
        dateOfBirth: DateTime(1990, 5, 15),
        gender: 'Kadın',
        address: 'İstanbul, Türkiye',
        emergencyContact: '+90 555 987 6543',
        insuranceProvider: 'SGK',
        insuranceNumber: '12345678901',
        diagnoses: ['Anksiyete Bozukluğu', 'Depresyon'],
        medications: ['Sertralin 50mg', 'Alprazolam 0.5mg'],
        allergies: ['Penisilin'],
        notes: 'İlk kez terapiye geliyor. Aile desteği mevcut.',
        firstSessionDate: DateTime.now().subtract(const Duration(days: 30)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 7)),
        totalSessions: 4,
        status: ClientStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Client(
        id: 'client_002',
        name: 'Mehmet Demir',
        email: 'mehmet.demir@email.com',
        phone: '+90 555 234 5678',
        dateOfBirth: DateTime(1985, 8, 22),
        gender: 'Erkek',
        address: 'Ankara, Türkiye',
        emergencyContact: '+90 555 876 5432',
        insuranceProvider: 'Özel Sigorta',
        insuranceNumber: '98765432109',
        diagnoses: ['Travma Sonrası Stres Bozukluğu'],
        medications: ['Paroksetin 20mg'],
        allergies: [],
        notes: 'Askerlik sonrası travma yaşadı. İyileşme sürecinde.',
        firstSessionDate: DateTime.now().subtract(const Duration(days: 60)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 14)),
        totalSessions: 8,
        status: ClientStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      Client(
        id: 'client_003',
        name: 'Fatma Kaya',
        email: 'fatma.kaya@email.com',
        phone: '+90 555 345 6789',
        dateOfBirth: DateTime(1995, 3, 10),
        gender: 'Kadın',
        address: 'İzmir, Türkiye',
        emergencyContact: '+90 555 765 4321',
        insuranceProvider: 'SGK',
        insuranceNumber: '11223344556',
        diagnoses: ['Yeme Bozukluğu', 'Düşük Benlik Saygısı'],
        medications: ['Fluoksetin 40mg'],
        allergies: ['Lateks'],
        notes: 'Üniversite öğrencisi. Aile terapisi gerekebilir.',
        firstSessionDate: DateTime.now().subtract(const Duration(days: 45)),
        lastSessionDate: DateTime.now().subtract(const Duration(days: 3)),
        totalSessions: 6,
        status: ClientStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ]);

    // Demo seanslar
    _sessions.addAll([
      Session(
        id: 'session_001',
        clientId: 'client_001',
        title: 'İlk Seans - Tanışma ve Değerlendirme',
        notes: 'Ayşe ile ilk kez tanıştık. Anksiyete belirtileri hakkında detaylı bilgi aldık. Aile geçmişi ve mevcut durumu değerlendirildi. İlk hedefler belirlendi.',
        goals: [
          'Anksiyete belirtilerini azaltmak',
          'Günlük aktivitelere katılımı artırmak',
          'Nefes egzersizleri öğrenmek'
        ],
        homework: 'Günde 3 kez 5 dakika nefes egzersizi yapmak. Anksiyete günlüğü tutmak.',
        nextSessionPlan: 'Nefes egzersizleri ve gevşeme teknikleri üzerinde çalışmak. Anksiyete günlüğünü değerlendirmek.',
        sessionDate: DateTime.now().subtract(const Duration(days: 30)),
        duration: const Duration(minutes: 60),
        status: SessionStatus.completed,
        type: SessionType.initial,
        modality: SessionModality.inPerson,
        therapistId: 'therapist_001',
        location: 'Ofis 1',
        cost: 300.0,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Session(
        id: 'session_002',
        clientId: 'client_001',
        title: 'Nefes Egzersizleri ve Gevşeme Teknikleri',
        notes: 'Ayşe ev ödevlerini başarıyla tamamlamış. Nefes egzersizlerinde ilerleme kaydedildi. Anksiyete günlüğünde bazı tetikleyiciler tespit edildi. Yeni gevşeme teknikleri öğretildi.',
        goals: [
          'Gevşeme tekniklerini günlük rutine entegre etmek',
          'Anksiyete tetikleyicilerini tanımak',
          'Stres yönetimi becerilerini geliştirmek'
        ],
        homework: 'Günde 2 kez 10 dakika gevşeme egzersizi. Tetikleyici durumları kaydetmek.',
        nextSessionPlan: 'Bilişsel davranışçı terapi tekniklerini tanıtmak. Tetikleyici durumlarla başa çıkma stratejileri geliştirmek.',
        sessionDate: DateTime.now().subtract(const Duration(days: 23)),
        duration: const Duration(minutes: 60),
        status: SessionStatus.completed,
        type: SessionType.individual,
        modality: SessionModality.inPerson,
        therapistId: 'therapist_001',
        location: 'Ofis 1',
        cost: 300.0,
        createdAt: DateTime.now().subtract(const Duration(days: 23)),
        updatedAt: DateTime.now().subtract(const Duration(days: 23)),
      ),
      Session(
        id: 'session_003',
        clientId: 'client_002',
        title: 'Travma Anıları ile Çalışma',
        notes: 'Mehmet travma anılarını paylaştı. EMDR tekniği kullanıldı. İlk kez travma anılarını detaylı olarak anlattı. Duygusal tepkiler yoğundu ama kontrollüydü.',
        goals: [
          'Travma anılarının yoğunluğunu azaltmak',
          'Güvenlik hissini artırmak',
          'Gelecek planları yapabilmek'
        ],
        homework: 'Güvenlik yeri egzersizi yapmak. Travma günlüğü tutmak.',
        nextSessionPlan: 'EMDR sürecine devam etmek. Güvenlik hissini pekiştirmek.',
        sessionDate: DateTime.now().subtract(const Duration(days: 14)),
        duration: const Duration(minutes: 90),
        status: SessionStatus.completed,
        type: SessionType.individual,
        modality: SessionModality.inPerson,
        therapistId: 'therapist_001',
        location: 'Ofis 2',
        cost: 450.0,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ]);

    // Demo seans notları
    _sessionNotes.addAll([
      SessionNote(
        id: 'note_001',
        sessionId: 'session_001',
        content: 'İlk görüşme çok verimli geçti. Ayşe terapötik sürece açık ve motive.',
        type: NoteType.observation,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        authorId: 'therapist_001',
        authorName: 'Dr. Ahmet Yıldız',
        tags: ['ilk-seans', 'motivasyon', 'açıklık'],
      ),
      SessionNote(
        id: 'note_002',
        sessionId: 'session_001',
        content: 'Aile desteği mevcut. Eşi de sürece dahil olmak istiyor.',
        type: NoteType.family,
        timestamp: DateTime.now().subtract(const Duration(days: 30)),
        authorId: 'therapist_001',
        authorName: 'Dr. Ahmet Yıldız',
        tags: ['aile-desteği', 'eş-katılımı'],
      ),
      SessionNote(
        id: 'note_003',
        sessionId: 'session_002',
        content: 'Ev ödevleri başarıyla tamamlanmış. Nefes egzersizlerinde belirgin ilerleme.',
        type: NoteType.progress,
        timestamp: DateTime.now().subtract(const Duration(days: 23)),
        authorId: 'therapist_001',
        authorName: 'Dr. Ahmet Yıldız',
        tags: ['ev-ödevi', 'ilerleme', 'nefes-egzersizi'],
      ),
    ]);

    // Demo AI özetleri
    _aiSummaries.addAll([
      AISummary(
        id: 'summary_001',
        sessionId: 'session_001',
        summary: 'İlk seans başarıyla tamamlandı. Danışan anksiyete belirtileri ile ilgili detaylı bilgi verdi. Aile desteği mevcut ve terapötik sürece açık.',
        keyPoints: 'Anksiyete belirtileri, aile desteği, motivasyon, ilk hedefler belirlendi',
        emotionalState: 'Endişeli ama umutlu, terapötik sürece açık',
        progressAssessment: 'İlk seans olduğu için henüz ilerleme değerlendirilemedi',
        recommendations: 'Nefes egzersizleri ile başlanması, anksiyete günlüğü tutulması önerildi',
        riskFactors: ['Orta düzey anksiyete', 'Günlük aktivitelerde kısıtlılık'],
        strengths: ['Aile desteği', 'Motivasyon', 'Açıklık', 'İçgörü'],
        confidence: 0.85,
        generatedAt: DateTime.now().subtract(const Duration(days: 30)),
        modelVersion: 'GPT-4 v1.0',
      ),
      AISummary(
        id: 'summary_002',
        sessionId: 'session_002',
        summary: 'İkinci seans başarılı geçti. Ev ödevleri tamamlanmış, nefes egzersizlerinde ilerleme kaydedildi. Yeni gevşeme teknikleri öğretildi.',
        keyPoints: 'Ev ödevleri tamamlandı, nefes egzersizlerinde ilerleme, gevşeme teknikleri öğretildi',
        emotionalState: 'Daha sakin, özgüven artışı, motivasyon yüksek',
        progressAssessment: 'Belirgin ilerleme: nefes egzersizleri %70 başarı, anksiyete günlüğü düzenli tutuluyor',
        recommendations: 'Gevşeme tekniklerinin günlük rutine entegrasyonu, tetikleyici durumların takibi',
        riskFactors: ['Bazı tetikleyici durumlar tespit edildi'],
        strengths: ['Öz disiplin', 'Ev ödevlerine uyum', 'Öğrenme isteği'],
        confidence: 0.92,
        generatedAt: DateTime.now().subtract(const Duration(days: 23)),
        modelVersion: 'GPT-4 v1.0',
      ),
    ]);

    // Demo hedefler
    _goals.addAll([
      SessionGoal(
        id: 'goal_001',
        sessionId: 'session_001',
        description: 'Anksiyete belirtilerini %50 azaltmak',
        type: GoalType.behavioral,
        priority: GoalPriority.high,
        status: GoalStatus.inProgress,
        progress: 0.3,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        notes: 'Nefes egzersizleri ile başlandı, ilerleme kaydedildi',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      SessionGoal(
        id: 'goal_002',
        sessionId: 'session_001',
        description: 'Günlük aktivitelere katılımı artırmak',
        type: GoalType.behavioral,
        priority: GoalPriority.medium,
        status: GoalStatus.inProgress,
        progress: 0.4,
        targetDate: DateTime.now().add(const Duration(days: 45)),
        notes: 'Sosyal aktivitelere katılım artıyor',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);

    // Demo ödevler
    _homework.addAll([
      SessionHomework(
        id: 'homework_001',
        sessionId: 'session_001',
        description: 'Günde 3 kez 5 dakika nefes egzersizi yapmak',
        type: HomeworkType.exercise,
        assignedDate: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().subtract(const Duration(days: 23)),
        completedDate: DateTime.now().subtract(const Duration(days: 23)),
        status: HomeworkStatus.completed,
        clientNotes: 'Egzersizleri düzenli olarak yapıyorum, faydasını görüyorum',
        therapistNotes: 'Başarıyla tamamlandı, tekniği öğrendi',
        difficulty: 2.0,
        satisfaction: 4.0,
      ),
      SessionHomework(
        id: 'homework_002',
        sessionId: 'session_001',
        description: 'Anksiyete günlüğü tutmak',
        type: HomeworkType.journaling,
        assignedDate: DateTime.now().subtract(const Duration(days: 30)),
        dueDate: DateTime.now().subtract(const Duration(days: 23)),
        completedDate: DateTime.now().subtract(const Duration(days: 23)),
        status: HomeworkStatus.completed,
        clientNotes: 'Günlük olarak kayıt tutuyorum, tetikleyicileri fark ettim',
        therapistNotes: 'Çok detaylı ve faydalı kayıtlar',
        difficulty: 1.0,
        satisfaction: 5.0,
      ),
    ]);
  }

  // Session methods
  Future<List<Session>> getAllSessions() async {
    await initialize();
    return List.unmodifiable(_sessions);
  }

  Future<Session?> getSession(String sessionId) async {
    await initialize();
    try {
      return _sessions.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Session>> getClientSessions(String clientId) async {
    await initialize();
    return _sessions
        .where((session) => session.clientId == clientId)
        .toList()
      ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
  }

  Future<Session> createSession(Session session) async {
    await initialize();
    _sessions.add(session);
    return session;
  }

  Future<Session> updateSession(Session session) async {
    await initialize();
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    }
    return session;
  }

  Future<void> deleteSession(String sessionId) async {
    await initialize();
    _sessions.removeWhere((session) => session.id == sessionId);
  }

  // Client methods
  Future<List<Client>> getAllClients() async {
    await initialize();
    return List.unmodifiable(_clients);
  }

  Future<Client?> getClient(String clientId) async {
    await initialize();
    try {
      return _clients.firstWhere((client) => client.id == clientId);
    } catch (e) {
      return null;
    }
  }

  Future<Client> createClient(Client client) async {
    await initialize();
    _clients.add(client);
    return client;
  }

  Future<Client> updateClient(Client client) async {
    await initialize();
    final index = _clients.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      _clients[index] = client;
    }
    return client;
  }

  Future<void> deleteClient(String clientId) async {
    await initialize();
    _clients.removeWhere((client) => client.id == clientId);
  }

  // Session notes methods
  Future<List<SessionNote>> getSessionNotes(String sessionId) async {
    await initialize();
    return _sessionNotes
        .where((note) => note.sessionId == sessionId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<SessionNote> createSessionNote(SessionNote note) async {
    await initialize();
    _sessionNotes.add(note);
    return note;
  }

  Future<SessionNote> updateSessionNote(SessionNote note) async {
    await initialize();
    final index = _sessionNotes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _sessionNotes[index] = note;
    }
    return note;
  }

  Future<void> deleteSessionNote(String noteId) async {
    await initialize();
    _sessionNotes.removeWhere((note) => note.id == noteId);
  }

  // AI Summary methods
  Future<AISummary?> getAISummary(String sessionId) async {
    await initialize();
    try {
      return _aiSummaries.firstWhere((summary) => summary.sessionId == sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<AISummary> saveAISummary(String sessionId, AISummary summary) async {
    await initialize();
    // Remove existing summary if exists
    _aiSummaries.removeWhere((s) => s.sessionId == sessionId);
    _aiSummaries.add(summary);
    return summary;
  }

  Future<void> deleteAISummary(String sessionId) async {
    await initialize();
    _aiSummaries.removeWhere((summary) => summary.sessionId == sessionId);
  }

  // Goals methods
  Future<List<SessionGoal>> getSessionGoals(String sessionId) async {
    await initialize();
    return _goals
        .where((goal) => goal.sessionId == sessionId)
        .toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
  }

  Future<SessionGoal> createGoal(SessionGoal goal) async {
    await initialize();
    _goals.add(goal);
    return goal;
  }

  Future<SessionGoal> updateGoal(SessionGoal goal) async {
    await initialize();
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
    return goal;
  }

  Future<void> deleteGoal(String goalId) async {
    await initialize();
    _goals.removeWhere((goal) => goal.id == goalId);
  }

  // Homework methods
  Future<List<SessionHomework>> getSessionHomework(String sessionId) async {
    await initialize();
    return _homework
        .where((hw) => hw.sessionId == sessionId)
        .toList()
      ..sort((a, b) => b.assignedDate.compareTo(a.assignedDate));
  }

  Future<SessionHomework> createHomework(SessionHomework homework) async {
    await initialize();
    _homework.add(homework);
    return homework;
  }

  Future<SessionHomework> updateHomework(SessionHomework homework) async {
    await initialize();
    final index = _homework.indexWhere((hw) => hw.id == homework.id);
    if (index != -1) {
      _homework[index] = homework;
    }
    return homework;
  }

  Future<void> deleteHomework(String homeworkId) async {
    await initialize();
    _homework.removeWhere((hw) => hw.id == homeworkId);
  }

  // Search methods
  Future<List<Session>> searchSessions(String query) async {
    await initialize();
    final lowercaseQuery = query.toLowerCase();
    return _sessions.where((session) {
      return session.title.toLowerCase().contains(lowercaseQuery) ||
          session.notes.toLowerCase().contains(lowercaseQuery) ||
          session.goals.any((goal) => goal.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  Future<List<Client>> searchClients(String query) async {
    await initialize();
    final lowercaseQuery = query.toLowerCase();
    return _clients.where((client) {
      return client.name.toLowerCase().contains(lowercaseQuery) ||
          client.email.toLowerCase().contains(lowercaseQuery) ||
          client.diagnoses.any((diagnosis) => diagnosis.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Statistics methods
  Future<Map<String, dynamic>> getSessionStatistics() async {
    await initialize();
    final totalSessions = _sessions.length;
    final completedSessions = _sessions.where((s) => s.status == SessionStatus.completed).length;
    final cancelledSessions = _sessions.where((s) => s.status == SessionStatus.cancelled).length;
    final noShowSessions = _sessions.where((s) => s.status == SessionStatus.noShow).length;

    final totalClients = _clients.length;
    final activeClients = _clients.where((c) => c.status == ClientStatus.active).length;

    final averageSessionDuration = _sessions.isNotEmpty
        ? _sessions.map((s) => s.duration.inMinutes).reduce((a, b) => a + b) / _sessions.length
        : 0.0;

    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'cancelledSessions': cancelledSessions,
      'noShowSessions': noShowSessions,
      'completionRate': totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0.0,
      'totalClients': totalClients,
      'activeClients': activeClients,
      'averageSessionDuration': averageSessionDuration,
      'totalRevenue': _sessions.fold(0.0, (sum, session) => sum + (session.cost ?? 0)),
    };
  }

  // Utility methods
  Future<void> clearAllData() async {
    _sessions.clear();
    _clients.clear();
    _sessionNotes.clear();
    _aiSummaries.clear();
    _goals.clear();
    _homework.clear();
  }

  Future<void> exportData() async {
    // TODO: Implement data export functionality
  }

  Future<void> importData() async {
    // TODO: Implement data import functionality
  }
}
