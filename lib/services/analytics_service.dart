import 'dart:math';
import 'package:flutter/material.dart';
import '../models/analytics_models.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _isInitialized = false;
  final Random _random = Random();

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  Future<AnalyticsData> getAnalyticsData(String timeRange) async {
    await initialize();
    
    // Demo veri oluştur
    return AnalyticsData(
      totalSessions: _generateRandomInt(800, 1200),
      activeClients: _generateRandomInt(150, 250),
      monthlyRevenue: _generateRandomDouble(45000, 75000),
      satisfactionScore: _generateRandomDouble(85, 98),
      sessionGrowth: _generateRandomDouble(5, 25),
      clientGrowth: _generateRandomDouble(8, 20),
      revenueGrowth: _generateRandomDouble(10, 30),
      satisfactionGrowth: _generateRandomDouble(2, 8),
      
      // Grafik verileri
      sessionTrends: _generateSessionTrends(timeRange),
      revenueData: _generateRevenueData(timeRange),
      clientDistribution: _generateClientDistribution(),
      performanceComparison: _generatePerformanceComparison(),
      
      // AI analiz verileri
      aiTrends: _generateAITrends(),
      aiInsights: _generateAIInsights(),
      aiRecommendations: _generateAIRecommendations(),
      
      // Performans metrikleri
      clinicalMetrics: _generateClinicalMetrics(),
      financialMetrics: _generateFinancialMetrics(),
      operationalMetrics: _generateOperationalMetrics(),
      qualityMetrics: _generateQualityMetrics(),
      
      // Detaylı analizler
      clientSegmentation: _generateClientSegmentation(),
      timeAnalysis: _generateTimeAnalysis(),
      riskAnalysis: _generateRiskAnalysis(),
      predictionModels: _generatePredictionModels(),
    );
  }

  List<ChartDataPoint> _generateSessionTrends(String timeRange) {
    final days = _getDaysForTimeRange(timeRange);
    final List<ChartDataPoint> trends = [];
    
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().subtract(Duration(days: days - i - 1));
      final baseValue = 20 + _random.nextDouble() * 15;
      final value = baseValue + _random.nextDouble() * 10 - 5;
      
      trends.add(ChartDataPoint(
        label: '${date.day}/${date.month}',
        value: value,
        date: date,
      ));
    }
    
    return trends;
  }

  List<ChartDataPoint> _generateRevenueData(String timeRange) {
    final months = _getMonthsForTimeRange(timeRange);
    final List<ChartDataPoint> data = [];
    
    for (int i = 0; i < months; i++) {
      final month = DateTime.now().month - months + i + 1;
      final baseValue = 40000 + _random.nextDouble() * 20000;
      final value = baseValue + _random.nextDouble() * 10000 - 5000;
      
      data.add(ChartDataPoint(
        label: _getMonthName(month),
        value: value,
        category: 'monthly',
      ));
    }
    
    return data;
  }

  List<PieChartData> _generateClientDistribution() {
    return [
      PieChartData(
        label: '18-25 Yaş',
        value: 25,
        color: const Color(0xFF3B82F6),
        percentage: 25,
      ),
      PieChartData(
        label: '26-35 Yaş',
        value: 35,
        color: const Color(0xFF8B5CF6),
        percentage: 35,
      ),
      PieChartData(
        label: '36-45 Yaş',
        value: 22,
        color: const Color(0xFF10B981),
        percentage: 22,
      ),
      PieChartData(
        label: '46+ Yaş',
        value: 18,
        color: const Color(0xFFF59E0B),
        percentage: 18,
      ),
    ];
  }

  List<RadarChartData> _generatePerformanceComparison() {
    return [
      RadarChartData(
        label: 'Dr. Ahmet Yılmaz',
        values: [85, 90, 88, 92, 87],
        color: const Color(0xFF3B82F6),
      ),
      RadarChartData(
        label: 'Dr. Ayşe Demir',
        values: [92, 88, 85, 90, 89],
        color: const Color(0xFF8B5CF6),
      ),
      RadarChartData(
        label: 'Dr. Mehmet Kaya',
        values: [78, 82, 80, 85, 83],
        color: const Color(0xFF10B981),
      ),
    ];
  }

  List<AITrend> _generateAITrends() {
    return [
      AITrend(
        title: 'Seans Sayısında Artış Trendi',
        description: 'Son 30 günde seans sayısında %15 artış gözlemleniyor',
        direction: TrendDirection.increasing,
        confidence: 87.5,
        factors: ['Yeni danışan kayıtları', 'Tekrar randevular', 'Sezon etkisi'],
        detectedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AITrend(
        title: 'Memnuniyet Skorunda İyileşme',
        description: 'Danışan memnuniyet skorunda %8 iyileşme tespit edildi',
        direction: TrendDirection.increasing,
        confidence: 92.3,
        factors: ['Terapist eğitimi', 'Hizmet kalitesi', 'İletişim iyileştirmeleri'],
        detectedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      AITrend(
        title: 'Gelir Dalgalanması',
        description: 'Aylık gelirde %5 dalgalanma gözlemleniyor',
        direction: TrendDirection.fluctuating,
        confidence: 78.9,
        factors: ['Sezon değişiklikleri', 'Ekonomik faktörler', 'Randevu iptalleri'],
        detectedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  List<AIInsight> _generateAIInsights() {
    return [
      AIInsight(
        title: 'Pazartesi Seans Yoğunluğu',
        description: 'Pazartesi günleri seans yoğunluğu %40 daha yüksek',
        type: InsightType.operational,
        impact: 8.5,
        recommendations: [
          'Pazartesi ek terapist desteği',
          'Randevu saatlerini optimize et',
          'Danışan bilgilendirmesi yap',
        ],
        generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      AIInsight(
        title: 'Genç Danışan Segmenti Büyüyor',
        description: '18-25 yaş grubunda %25 büyüme gözlemleniyor',
        type: InsightType.clinical,
        impact: 7.2,
        recommendations: [
          'Gençlere özel programlar geliştir',
          'Sosyal medya pazarlaması artır',
          'Akran desteği grupları oluştur',
        ],
        generatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      AIInsight(
        title: 'Finansal Performans Optimizasyonu',
        description: 'Randevu iptal oranı %12\'den %8\'e düştü',
        type: InsightType.financial,
        impact: 6.8,
        recommendations: [
          'İptal politikasını sıkılaştır',
          'Hatırlatma sistemini geliştir',
          'No-show ücreti uygula',
        ],
        generatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  List<AIRecommendation> _generateAIRecommendations() {
    return [
      AIRecommendation(
        title: 'Terapist Eğitim Programı',
        description: 'Yeni terapistler için kapsamlı eğitim programı başlat',
        priority: RecommendationPriority.high,
        expectedImpact: 8.5,
        actionSteps: [
          'Eğitim içeriklerini hazırla',
          'Terapistleri belirle',
          'Programı başlat ve takip et',
        ],
        validUntil: DateTime.now().add(const Duration(days: 30)),
      ),
      AIRecommendation(
        title: 'Danışan Portalı Geliştirme',
        description: 'Danışan deneyimini iyileştirmek için portal geliştir',
        priority: RecommendationPriority.medium,
        expectedImpact: 7.2,
        actionSteps: [
          'Portal gereksinimlerini analiz et',
          'UI/UX tasarımını yap',
          'Geliştirme ve test sürecini başlat',
        ],
        validUntil: DateTime.now().add(const Duration(days: 45)),
      ),
      AIRecommendation(
        title: 'Risk Yönetimi Sistemi',
        description: 'Klinik risklerini izlemek için sistem kur',
        priority: RecommendationPriority.critical,
        expectedImpact: 9.0,
        actionSteps: [
          'Risk faktörlerini belirle',
          'İzleme sistemi kur',
          'Alarm ve uyarı mekanizmaları ekle',
        ],
        validUntil: DateTime.now().add(const Duration(days: 15)),
      ),
    ];
  }

  PerformanceMetrics _generateClinicalMetrics() {
    return PerformanceMetrics(
      name: 'Klinik Performans',
      currentValue: 87.5,
      targetValue: 90.0,
      previousValue: 85.2,
      status: MetricStatus.good,
      details: [
        MetricDetail(
          label: 'Başarı Oranı',
          value: 87.5,
          unit: '%',
          color: const Color(0xFF3B82F6),
        ),
        MetricDetail(
          label: 'Ortalama Seans',
          value: 6.2,
          unit: 'seans',
          color: const Color(0xFF8B5CF6),
        ),
        MetricDetail(
          label: 'Takip Oranı',
          value: 92.1,
          unit: '%',
          color: const Color(0xFF10B981),
        ),
      ],
    );
  }

  PerformanceMetrics _generateFinancialMetrics() {
    return PerformanceMetrics(
      name: 'Finansal Performans',
      currentValue: 125000,
      targetValue: 150000,
      previousValue: 118000,
      status: MetricStatus.good,
      details: [
        MetricDetail(
          label: 'Aylık Gelir',
          value: 125000,
          unit: '₺',
          color: const Color(0xFF10B981),
        ),
        MetricDetail(
          label: 'Seans Başı Gelir',
          value: 450,
          unit: '₺',
          color: const Color(0xFF3B82F6),
        ),
        MetricDetail(
          label: 'Gelir Büyüme',
          value: 5.9,
          unit: '%',
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  PerformanceMetrics _generateOperationalMetrics() {
    return PerformanceMetrics(
      name: 'Operasyonel Performans',
      currentValue: 78.3,
      targetValue: 85.0,
      previousValue: 75.8,
      status: MetricStatus.neutral,
      details: [
        MetricDetail(
          label: 'Kapasite Kullanımı',
          value: 78.3,
          unit: '%',
          color: const Color(0xFFF59E0B),
        ),
        MetricDetail(
          label: 'Randevu Doluluk',
          value: 82.1,
          unit: '%',
          color: const Color(0xFF3B82F6),
        ),
        MetricDetail(
          label: 'İptal Oranı',
          value: 8.5,
          unit: '%',
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  PerformanceMetrics _generateQualityMetrics() {
    return PerformanceMetrics(
      name: 'Kalite Metrikleri',
      currentValue: 91.2,
      targetValue: 95.0,
      previousValue: 89.8,
      status: MetricStatus.excellent,
      details: [
        MetricDetail(
          label: 'Memnuniyet',
          value: 91.2,
          unit: '%',
          color: const Color(0xFF10B981),
        ),
        MetricDetail(
          label: 'Kalite Skoru',
          value: 88.7,
          unit: '%',
          color: const Color(0xFF3B82F6),
        ),
        MetricDetail(
          label: 'Güvenlik',
          value: 95.5,
          unit: '%',
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  List<SegmentationData> _generateClientSegmentation() {
    return [
      SegmentationData(
        segment: 'VIP Danışanlar',
        count: 25,
        percentage: 15,
        averageValue: 2500,
        characteristics: ['Yüksek gelir', 'Sık seans', 'Özel hizmet'],
      ),
      SegmentationData(
        segment: 'Kurumsal Müşteriler',
        count: 45,
        percentage: 28,
        averageValue: 1800,
        characteristics: ['Şirket anlaşması', 'Düzenli seans', 'Grup terapisi'],
      ),
      SegmentationData(
        segment: 'Sağlık Sigortası',
        count: 60,
        percentage: 37,
        averageValue: 1200,
        characteristics: ['Sigorta kapsamı', 'Orta gelir', 'Standart hizmet'],
      ),
      SegmentationData(
        segment: 'Bireysel Danışanlar',
        count: 35,
        percentage: 20,
        averageValue: 900,
        characteristics: ['Düşük gelir', 'Düzensiz seans', 'Temel hizmet'],
      ),
    ];
  }

  TimeAnalysisData _generateTimeAnalysis() {
    return TimeAnalysisData(
      hourlyDistribution: {
        '09:00': 15, '10:00': 25, '11:00': 30, '12:00': 20,
        '14:00': 35, '15:00': 40, '16:00': 45, '17:00': 35,
        '18:00': 25, '19:00': 20, '20:00': 15,
      },
      dailyDistribution: {
        'Pazartesi': 120, 'Salı': 110, 'Çarşamba': 105,
        'Perşembe': 115, 'Cuma': 100, 'Cumartesi': 80, 'Pazar': 30,
      },
      monthlyDistribution: {
        'Ocak': 2800, 'Şubat': 2900, 'Mart': 3100, 'Nisan': 3000,
        'Mayıs': 3200, 'Haziran': 3300, 'Temmuz': 3400, 'Ağustos': 3500,
        'Eylül': 3600, 'Ekim': 3700, 'Kasım': 3800, 'Aralık': 3900,
      },
      peakTimes: [
        PeakTime(
          timeSlot: '15:00-16:00',
          activityLevel: 45,
          reason: 'İş sonrası randevular',
        ),
        PeakTime(
          timeSlot: '10:00-11:00',
          activityLevel: 30,
          reason: 'Sabah seansları',
        ),
      ],
      lowActivityTimes: [
        LowActivityTime(
          timeSlot: '12:00-13:00',
          activityLevel: 20,
          reason: 'Öğle arası',
        ),
        LowActivityTime(
          timeSlot: '20:00-21:00',
          activityLevel: 15,
          reason: 'Geç saat',
        ),
      ],
    );
  }

  RiskAnalysisData _generateRiskAnalysis() {
    return RiskAnalysisData(
      overallRiskScore: 6.8,
      riskFactors: [
        RiskFactor(
          name: 'Terapist Yorgunluğu',
          probability: 0.7,
          impact: 8.0,
          level: RiskLevel.medium,
          description: 'Yoğun çalışma saatleri terapist performansını etkiliyor',
        ),
        RiskFactor(
          name: 'Veri Güvenliği',
          probability: 0.3,
          impact: 9.5,
          level: RiskLevel.high,
          description: 'Hasta verilerinin güvenliği kritik önem taşıyor',
        ),
        RiskFactor(
          name: 'Finansal Dalgalanma',
          probability: 0.5,
          impact: 6.0,
          level: RiskLevel.low,
          description: 'Ekonomik faktörler gelirleri etkileyebilir',
        ),
      ],
      mitigations: [
        RiskMitigation(
          strategy: 'Terapist Rotasyonu',
          effectiveness: 0.8,
          cost: 0.3,
          description: 'Terapistlerin çalışma saatlerini optimize et',
        ),
        RiskMitigation(
          strategy: 'Güvenlik Güncellemeleri',
          effectiveness: 0.95,
          cost: 0.7,
          description: 'Veri güvenliği sistemlerini güçlendir',
        ),
        RiskMitigation(
          strategy: 'Gelir Çeşitlendirme',
          effectiveness: 0.6,
          cost: 0.4,
          description: 'Farklı gelir kaynakları geliştir',
        ),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  PredictionModelData _generatePredictionModels() {
    return PredictionModelData(
      modelName: 'Seans Tahmin Modeli v2.1',
      accuracy: 87.3,
      predictions: [
        Prediction(
          target: 'Gelecek Ay Seans Sayısı',
          predictedValue: 1250,
          confidence: 87.3,
          predictionDate: DateTime.now().add(const Duration(days: 30)),
          factors: ['Mevcut trend', 'Sezon etkisi', 'Yeni kayıtlar'],
        ),
        Prediction(
          target: 'Gelir Tahmini',
          predictedValue: 135000,
          confidence: 84.7,
          predictionDate: DateTime.now().add(const Duration(days: 30)),
          factors: ['Seans sayısı', 'Ortalama ücret', 'İptal oranı'],
        ),
        Prediction(
          target: 'Danışan Memnuniyeti',
          predictedValue: 92.5,
          confidence: 89.1,
          predictionDate: DateTime.now().add(const Duration(days: 30)),
          factors: ['Hizmet kalitesi', 'Terapist performansı', 'İletişim'],
        ),
      ],
      features: [
        ModelFeature(
          name: 'Seans Geçmişi',
          importance: 0.85,
          description: 'Son 6 ay seans verileri',
        ),
        ModelFeature(
          name: 'Sezon Faktörü',
          importance: 0.72,
          description: 'Yılın hangi döneminde olduğumuz',
        ),
        ModelFeature(
          name: 'Terapist Kapasitesi',
          importance: 0.68,
          description: 'Mevcut terapist sayısı ve müsaitlik',
        ),
        ModelFeature(
          name: 'Ekonomik Göstergeler',
          importance: 0.54,
          description: 'Genel ekonomik durum',
        ),
      ],
      lastTrained: DateTime.now().subtract(const Duration(days: 7)),
    );
  }

  int _getDaysForTimeRange(String timeRange) {
    switch (timeRange) {
      case '7d': return 7;
      case '30d': return 30;
      case '90d': return 90;
      case '1y': return 365;
      default: return 30;
    }
  }

  int _getMonthsForTimeRange(String timeRange) {
    switch (timeRange) {
      case '7d': return 1;
      case '30d': return 3;
      case '90d': return 6;
      case '1y': return 12;
      default: return 3;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  int _generateRandomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }

  double _generateRandomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}
