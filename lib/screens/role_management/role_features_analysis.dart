import 'package:flutter/material.dart';

class RoleFeaturesAnalysisScreen extends StatefulWidget {
  const RoleFeaturesAnalysisScreen({super.key});

  @override
  State<RoleFeaturesAnalysisScreen> createState() => _RoleFeaturesAnalysisScreenState();
}

class _RoleFeaturesAnalysisScreenState extends State<RoleFeaturesAnalysisScreen> {
  String _selectedRole = 'Psikiyatrist';
  
  final Map<String, RoleFeatures> _roleFeatures = {
    'Psikiyatrist': RoleFeatures(
      roleName: 'Psikiyatrist',
      description: 'Tam yetkili klinik yöneticisi',
      currentFeatures: [
        'Hasta yönetimi',
        'Randevu sistemi',
        'AI tanı asistanı',
        'Telemedicine',
        'Güvenlik ayarları',
        'Analitik raporlar',
        'İlaç reçetesi',
        'Tedavi planı',
        'Not yazma',
        'Rapor oluşturma',
      ],
      missingFeatures: [
        'Hasta portalı erişimi',
        'Sesli not alma',
        'Otomatik faturalandırma',
        'Sigorta entegrasyonu',
        'E-reçete sistemi',
        'Hasta eğitim modülleri',
        'Mobil uygulama',
        'Çoklu dil desteği',
        'Offline çalışma',
        'Gelişmiş arama',
        'AI ilaç etkileşim kontrolü',
        'Otomatik randevu hatırlatmaları',
        'Hasta güvenlik protokolleri',
        'Kriz müdahale sistemi',
        'Hasta takip dashboardu',
        'Otomatik rapor oluşturma',
        'İlaç yan etki takibi',
        'Hasta memnuniyet anketi',
        'Telemedicine kayıt sistemi',
        'Hasta veri analizi',
        'Otomatik backup sistemi',
        'Çoklu klinik yönetimi',
        'Hasta geçmiş analizi',
        'İlaç dozaj hesaplayıcısı',
        'Hasta risk skorlama',
        'Otomatik follow-up',
        'Hasta eğitim videoları',
        'İlaç uyumluluk kontrolü',
        'Hasta güvenlik bildirimleri',
        'Otomatik tedavi planı',
      ],
      competitorFeatures: [
        'SimplePractice: Otomatik randevu hatırlatmaları',
        'TherapyNotes: Entegre faturalandırma',
        'TheraNest: Hasta portalı',
        'Cerner: E-reçete sistemi',
        'Epic: Sigorta entegrasyonu',
      ],
    ),
    'Psikolog': RoleFeatures(
      roleName: 'Psikolog',
      description: 'Terapi ve danışmanlık hizmetleri',
      currentFeatures: [
        'Hasta yönetimi',
        'Randevu sistemi',
        'AI tanı asistanı',
        'Telemedicine',
        'Not yazma',
        'Tedavi planı',
        'Rapor oluşturma',
      ],
      missingFeatures: [
        'Terapi teknikleri kütüphanesi',
        'Hasta ödev sistemi',
        'Mood tracking',
        'Sesli not alma',
        'Video kayıt',
        'Grup terapi yönetimi',
        'Aile terapi araçları',
        'Çocuk terapi oyunları',
        'Mindfulness uygulamaları',
        'Hasta self-assessment',
        'Terapi seans kayıtları',
        'Hasta ilerleme takibi',
        'Terapi hedef belirleme',
        'Hasta motivasyon araçları',
        'Terapi ev ödevleri',
        'Hasta günlük takibi',
        'Terapi teknikleri rehberi',
        'Hasta değerlendirme testleri',
        'Terapi seans planlaması',
        'Hasta feedback sistemi',
        'Terapi notları şablonları',
        'Hasta kriz müdahale',
        'Terapi grup yönetimi',
        'Hasta aile eğitimi',
        'Terapi sonuç analizi',
        'Hasta memnuniyet ölçümü',
        'Terapi teknikleri eğitimi',
        'Hasta self-help araçları',
        'Terapi seans değerlendirmesi',
        'Hasta terapi uyumu',
      ],
      competitorFeatures: [
        'BetterHelp: 24/7 hasta desteği',
        'Talkspace: Mesajlaşma terapisi',
        'Calm: Mindfulness uygulamaları',
        'Headspace: Meditasyon rehberi',
        'Wysa: AI destekli terapi',
      ],
    ),
    'Hemşire': RoleFeatures(
      roleName: 'Hemşire',
      description: 'Hasta bakımı ve takibi',
      currentFeatures: [
        'Hasta yönetimi',
        'Randevu sistemi',
        'Not yazma',
        'Hasta takibi',
      ],
      missingFeatures: [
        'Vital signs tracking',
        'İlaç takip sistemi',
        'Hasta eğitimi',
        'Aile iletişim araçları',
        'Kriz müdahale protokolleri',
        'Hasta güvenliği kontrolü',
        'Enfeksiyon kontrolü',
        'Medication reconciliation',
        'Discharge planning',
        'Patient education materials',
        'Hasta vital bulguları takibi',
        'İlaç dozaj kontrolü',
        'Hasta bakım planı',
        'Aile eğitim modülleri',
        'Hasta güvenlik protokolleri',
        'Enfeksiyon önleme sistemi',
        'İlaç etkileşim kontrolü',
        'Hasta taburcu planlaması',
        'Hasta eğitim materyalleri',
        'Vital signs alarm sistemi',
        'İlaç uyumluluk takibi',
        'Hasta bakım notları',
        'Aile iletişim sistemi',
        'Hasta güvenlik bildirimleri',
        'Enfeksiyon kontrol protokolleri',
        'İlaç yan etki takibi',
        'Hasta taburcu eğitimi',
        'Hasta bakım kalitesi',
        'Vital signs trend analizi',
        'İlaç güvenlik kontrolü',
      ],
      competitorFeatures: [
        'Epic: Vital signs entegrasyonu',
        'Cerner: Medication management',
        'Allscripts: Patient education',
        'NextGen: Discharge planning',
        'Athenahealth: Care coordination',
      ],
    ),
    'Sekreter': RoleFeatures(
      roleName: 'Sekreter',
      description: 'Randevu ve idari işler',
      currentFeatures: [
        'Randevu sistemi',
        'Hasta yönetimi',
        'Temel raporlar',
      ],
      missingFeatures: [
        'Otomatik randevu hatırlatmaları',
        'Telefon sistemi entegrasyonu',
        'Faturalandırma sistemi',
        'Sigorta doğrulama',
        'Hasta kayıt formları',
        'Çoklu takvim görünümü',
        'Bekleme listesi yönetimi',
        'Randevu iptal yönetimi',
        'Hasta iletişim geçmişi',
        'Otomatik SMS gönderimi',
        'Randevu çakışma kontrolü',
        'Hasta ödeme takibi',
        'Sigorta onay sistemi',
        'Randevu yeniden planlama',
        'Hasta kayıt doğrulama',
        'Otomatik email gönderimi',
        'Randevu bekleme listesi',
        'Hasta iletişim merkezi',
        'Randevu iptal nedenleri',
        'Hasta memnuniyet anketi',
        'Randevu kapasite yönetimi',
        'Hasta ödeme planları',
        'Sigorta kapsam kontrolü',
        'Randevu öncelik sistemi',
        'Hasta kayıt güncelleme',
        'Otomatik takip çağrıları',
        'Randevu rapor sistemi',
        'Hasta iletişim tercihleri',
        'Randevu iptal politikaları',
        'Hasta veri güvenliği',
      ],
      competitorFeatures: [
        'SimplePractice: Otomatik hatırlatmalar',
        'TherapyNotes: Telefon entegrasyonu',
        'TheraNest: Faturalandırma',
        'Acuity Scheduling: Çoklu takvim',
        'Calendly: Otomatik randevu',
      ],
    ),
    'Hasta': RoleFeatures(
      roleName: 'Hasta',
      description: 'Hasta portalı ve self-service',
      currentFeatures: [
        'Randevu görüntüleme',
        'Temel bilgi erişimi',
      ],
      missingFeatures: [
        'Randevu alma/iptal etme',
        'Online ödeme',
        'Mesajlaşma',
        'Dosya paylaşımı',
        'Tedavi planı görüntüleme',
        'İlaç hatırlatıcıları',
        'Mood tracking',
        'Self-assessment araçları',
        'Eğitim materyalleri',
        'Acil durum iletişimi',
        'Hasta günlük takibi',
        'İlaç yan etki bildirimi',
        'Terapi ev ödevleri',
        'Hasta eğitim videoları',
        'Mood günlüğü',
        'Hasta self-help araçları',
        'Terapi ilerleme takibi',
        'Hasta feedback sistemi',
        'İlaç uyumluluk takibi',
        'Hasta güvenlik bildirimleri',
        'Randevu hatırlatıcıları',
        'Hasta eğitim modülleri',
        'Terapi teknikleri rehberi',
        'Hasta memnuniyet anketi',
        'İlaç dozaj hesaplayıcısı',
        'Hasta kriz müdahale',
        'Terapi grup katılımı',
        'Hasta aile eğitimi',
        'Terapi sonuç görüntüleme',
        'Hasta veri güvenliği',
      ],
      competitorFeatures: [
        'MyChart: Hasta portalı',
        'Patient Gateway: Online ödeme',
        'Epic MyChart: Mesajlaşma',
        'Cerner HealtheLife: Dosya paylaşımı',
        'Allscripts FollowMyHealth: Tedavi planı',
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final features = _roleFeatures[_selectedRole]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rol Bazlı Özellik Analizi'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalysis,
          ),
        ],
      ),
      body: Column(
        children: [
          // Rol seçimi
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerHigh,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Rol Seçin',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              value: _selectedRole,
              items: _roleFeatures.keys.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rol bilgileri
                  _buildRoleInfoCard(features),
                  const SizedBox(height: 24),
                  
                  // Mevcut özellikler
                  _buildFeaturesCard(
                    'Mevcut Özellikler',
                    features.currentFeatures,
                    Colors.green,
                    Icons.check_circle,
                  ),
                  const SizedBox(height: 24),
                  
                  // Eksik özellikler
                  _buildFeaturesCard(
                    'Eksik Özellikler',
                    features.missingFeatures,
                    Colors.orange,
                    Icons.warning,
                  ),
                  const SizedBox(height: 24),
                  
                  // Rakip özellikleri
                  _buildCompetitorFeaturesCard(features),
                  const SizedBox(height: 24),
                  
                  // Öncelik matrisi
                  _buildPriorityMatrix(features),
                  const SizedBox(height: 24),
                  
                  // Öneriler
                  _buildRecommendationsCard(features),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleInfoCard(RoleFeatures features) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        features.roleName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        features.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatChip('Mevcut', features.currentFeatures.length, Colors.green),
                const SizedBox(width: 8),
                _buildStatChip('Eksik', features.missingFeatures.length, Colors.orange),
                const SizedBox(width: 8),
                _buildStatChip('Rakip', features.competitorFeatures.length, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeaturesCard(String title, List<String> features, Color color, IconData icon) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${features.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitorFeaturesCard(RoleFeatures features) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Rakip Özellikleri',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${features.competitorFeatures.length}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.competitorFeatures.map((feature) {
              final parts = feature.split(': ');
              final competitor = parts[0];
              final featureName = parts[1];
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competitor,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        featureName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityMatrix(RoleFeatures features) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Öncelik Matrisi',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriorityItem('Yüksek Öncelik', [
              'Hasta portalı',
              'Otomatik faturalandırma',
              'Mobil uygulama',
              'Sesli not alma',
            ], Colors.red),
            const SizedBox(height: 12),
            _buildPriorityItem('Orta Öncelik', [
              'Sigorta entegrasyonu',
              'E-reçete sistemi',
              'Gelişmiş arama',
              'Çoklu dil desteği',
            ], Colors.orange),
            const SizedBox(height: 12),
            _buildPriorityItem('Düşük Öncelik', [
              'Offline çalışma',
              'Hasta eğitim modülleri',
              'Gelişmiş analitik',
              'AI chatbot',
            ], Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityItem(String title, List<String> items, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(RoleFeatures features) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Öneriler',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Hasta Portalı Geliştirme',
              'Hastaların randevu alabilmesi, ödeme yapabilmesi ve mesajlaşabilmesi için hasta portalı geliştirilmeli.',
              'Yüksek',
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Mobil Uygulama',
              'iOS ve Android için native mobil uygulama geliştirilerek her yerden erişim sağlanmalı.',
              'Yüksek',
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'AI Ses Asistanı',
              'Sesli komutlarla not alma ve hasta bilgilerine erişim için AI ses asistanı entegre edilmeli.',
              'Orta',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Entegre Faturalandırma',
              'Otomatik faturalandırma ve sigorta entegrasyonu ile idari yük azaltılmalı.',
              'Yüksek',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description, String priority, Color priorityColor) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _exportAnalysis() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analiz İhracı'),
        content: const Text('Rol bazlı özellik analizi PDF olarak ihraç edilecek.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analiz ihracı başlatıldı')),
              );
            },
            child: const Text('İhrac Et'),
          ),
        ],
      ),
    );
  }
}

class RoleFeatures {
  final String roleName;
  final String description;
  final List<String> currentFeatures;
  final List<String> missingFeatures;
  final List<String> competitorFeatures;

  RoleFeatures({
    required this.roleName,
    required this.description,
    required this.currentFeatures,
    required this.missingFeatures,
    required this.competitorFeatures,
  });
}
