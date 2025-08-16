import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/supervision_models.dart';
import '../../widgets/supervisor/performance_overview_widget.dart';
import '../../widgets/supervisor/supervision_sessions_widget.dart';
import '../../widgets/supervisor/therapist_performance_widget.dart';
import '../../widgets/supervisor/quality_metrics_widget.dart';

class SupervisorDashboardScreen extends StatefulWidget {
  const SupervisorDashboardScreen({super.key});

  @override
  State<SupervisorDashboardScreen> createState() => _SupervisorDashboardScreenState();
}

class _SupervisorDashboardScreenState extends State<SupervisorDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  List<SupervisionSession> _supervisionSessions = [];
  List<TherapistPerformance> _therapistPerformances = [];
  List<QualityMetric> _qualityMetrics = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    setState(() {
      _isLoading = true;
    });

    // Demo supervision sessions
    _supervisionSessions = [
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
    ];

    // Demo therapist performances
    _therapistPerformances = [
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
      ),
    ];

    // Demo quality metrics
    _qualityMetrics = [
      QualityMetric(
        id: '1',
        metricName: 'Seans Tamamlama Oranı',
        description: 'Planlanan seansların tamamlanma yüzdesi',
        category: 'Kalite',
        score: 0.925,
        trend: '↑ Artış',
        targetValue: 0.90,
        weight: 0.30,
        notes: 'Hedef değerin üzerinde performans gösteriliyor',
        lastUpdated: DateTime.now(),
      ),
      QualityMetric(
        id: '2',
        metricName: 'Müşteri Memnuniyeti',
        description: 'Ortalama müşteri memnuniyet skoru',
        category: 'Hasta Memnuniyeti',
        score: 0.90,
        trend: '↑ Artış',
        targetValue: 0.85,
        weight: 0.25,
        notes: 'Memnuniyet skoru hedef değerin üzerinde',
        lastUpdated: DateTime.now(),
      ),
      QualityMetric(
        id: '3',
        metricName: 'Vaka İlerleme Skoru',
        description: 'Ortalama vaka ilerleme skoru',
        category: 'Tedavi Başarısı',
        score: 0.78,
        trend: '→ Stabil',
        targetValue: 0.80,
        weight: 0.20,
        notes: 'Hedef değere yakın, iyileştirme alanı var',
        lastUpdated: DateTime.now(),
      ),
    ];

    _isLoading = false;
  }

  void _addNewSupervision() {
    HapticFeedback.lightImpact();
    // TODO: Implement new supervision form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yeni süpervizyon ekleme özelliği yakında!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Süpervizör Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _addNewSupervision,
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Süpervizyon Ekle',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Implement settings
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Ayarlar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel Bakış', icon: Icon(Icons.dashboard)),
            Tab(text: 'Süpervizyonlar', icon: Icon(Icons.supervisor_account)),
            Tab(text: 'Terapist Performansı', icon: Icon(Icons.assessment)),
            Tab(text: 'Kalite Metrikleri', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          PerformanceOverviewWidget(
            supervisionSessions: _supervisionSessions,
            therapistPerformances: _therapistPerformances,
            qualityMetrics: _qualityMetrics,
          ),
          
          // Supervision Sessions Tab
          SupervisionSessionsWidget(
            sessions: _supervisionSessions,
            onSessionTap: (session) {
              HapticFeedback.lightImpact();
              // TODO: Navigate to session detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${session.type.name} süpervizyon detayı'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          
          // Therapist Performance Tab
          TherapistPerformanceWidget(
            performances: _therapistPerformances,
            onTherapistTap: (performance) {
              HapticFeedback.lightImpact();
              // TODO: Navigate to therapist detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${performance.therapistName} performans detayı'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          
          // Quality Metrics Tab
          QualityMetricsWidget(
            metrics: _qualityMetrics,
            onMetricTap: (metric) {
              HapticFeedback.lightImpact();
              // TODO: Navigate to metric detail
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${metric.metricName} detay analizi'),
                  backgroundColor: Colors.purple,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewSupervision,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Süpervizyon'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
