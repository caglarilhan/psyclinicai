import 'package:flutter/material.dart';

class FeatureSystemScreen extends StatefulWidget {
  const FeatureSystemScreen({super.key});

  @override
  State<FeatureSystemScreen> createState() => _FeatureSystemScreenState();
}

class _FeatureSystemScreenState extends State<FeatureSystemScreen> {
  String _selectedRole = 'Psychiatrist';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('PsyClinicAI — Feature System'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Role and Category Filters
          _buildFilters(theme),
          
          // Feature System Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Overview
                  _buildSystemOverview(theme),
                  const SizedBox(height: 24),
                  
                  // Main Categories
                  _buildMainCategories(theme),
                  const SizedBox(height: 24),
                  
                  // Detailed Features
                  _buildDetailedFeatures(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'Psychiatrist', child: Text('Psychiatrist')),
                DropdownMenuItem(value: 'Psychologist', child: Text('Psychologist')),
                DropdownMenuItem(value: 'Nurse', child: Text('Nurse')),
                DropdownMenuItem(value: 'Receptionist', child: Text('Receptionist')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'Patient', child: Text('Patient')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Patient management', child: Text('Patient management')),
                DropdownMenuItem(value: 'AI & analytics', child: Text('AI & analytics')),
                DropdownMenuItem(value: 'Communication', child: Text('Communication')),
                DropdownMenuItem(value: 'Operations', child: Text('Operations')),
                DropdownMenuItem(value: 'Security', child: Text('Security')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemOverview(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PsyClinicAI Feature System',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comprehensive mental-health clinic management platform',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(theme, '150+', 'Features', Icons.apps),
              const SizedBox(width: 16),
              _buildStatCard(theme, '6', 'Main categories', Icons.category),
              const SizedBox(width: 16),
              _buildStatCard(theme, '6', 'Roles supported', Icons.people),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategories(ThemeData theme) {
    final categories = _getMainCategories();
    
    return LayoutBuilder(
      builder: (context, c) {
        // Phones: 2-col grid so "Patient management" / "Communication"
        // fit without truncation; wider screens keep 3 col.
        final cols = c.maxWidth < 480 ? 2 : 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main categories',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6B46C1),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(theme, category);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(ThemeData theme, Map<String, dynamic> category) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                category['icon'] as IconData,
                color: category['color'] as Color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['name'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B46C1),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category['featureCount']} features',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedFeatures(ThemeData theme) {
    final features = _getDetailedFeatures(_selectedRole, _selectedCategory);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detaylı Özellik Listesi',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6B46C1),
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((category) => _buildFeatureCategory(theme, category)),
      ],
    );
  }

  Widget _buildFeatureCategory(ThemeData theme, Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: category['colors'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] as String,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category['description'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${category['features'].length} Özellik',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Features List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: (category['features'] as List<Map<String, dynamic>>)
                  .map((feature) => _buildFeatureItem(theme, feature))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(ThemeData theme, Map<String, dynamic> feature) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (feature['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature['icon'] as IconData,
              color: feature['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['name'] as String,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B46C1),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (feature['status'] != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(feature['status'] as String).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feature['status'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(feature['status'] as String),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    // English status keys (post-translation pass). Legacy Turkish 'Test'
    // is kept so any data missed by the sed still maps correctly.
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'In development':
        return Colors.orange;
      case 'Planned':
        return Colors.blue;
      case 'Testing':
      case 'Test':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getMainCategories() {
    return [
      {
        'name': 'Patient management',
        'icon': Icons.people,
        'color': const Color(0xFF6B46C1),
        'featureCount': 25,
      },
      {
        'name': 'AI & analytics',
        'icon': Icons.psychology,
        'color': const Color(0xFF7C3AED),
        'featureCount': 20,
      },
      {
        'name': 'Communication',
        'icon': Icons.video_call,
        'color': const Color(0xFF8B5CF6),
        'featureCount': 15,
      },
      {
        'name': 'Operations',
        'icon': Icons.analytics,
        'color': const Color(0xFF9333EA),
        'featureCount': 18,
      },
      {
        'name': 'Security',
        'icon': Icons.security,
        'color': const Color(0xFFA855F7),
        'featureCount': 12,
      },
      {
        'name': 'Integrations',
        'icon': Icons.integration_instructions,
        'color': const Color(0xFFC084FC),
        'featureCount': 10,
      },
    ];
  }

  List<Map<String, dynamic>> _getDetailedFeatures(String role, String category) {
    final allFeatures = {
      'Patient management': {
        'name': 'Patient management',
        'description': 'Patient records, appointments and follow-ups',
        'icon': Icons.people,
        'colors': [const Color(0xFF6B46C1), const Color(0xFF8B5CF6)],
        'features': [
          {
            'name': 'Patient list',
            'description': 'Tüm hastaları görüntüleme ve yönetim',
            'icon': Icons.people,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'Patient details',
            'description': 'Detaylı hasta bilgileri ve geçmiş',
            'icon': Icons.person,
            'color': const Color(0xFF7C3AED),
            'status': 'Active',
          },
          {
            'name': 'Appointments',
            'description': 'Randevu oluşturma ve takip',
            'icon': Icons.calendar_today,
            'color': const Color(0xFF8B5CF6),
            'status': 'Active',
          },
          {
            'name': 'Randevu Geçmişi',
            'description': 'Geçmiş randevular ve notlar',
            'icon': Icons.history,
            'color': const Color(0xFF9333EA),
            'status': 'Active',
          },
          {
            'name': 'Patient portal',
            'description': 'Hastalar için özel portal erişimi',
            'icon': Icons.person_pin,
            'color': const Color(0xFFA855F7),
            'status': 'In development',
          },
          {
            'name': 'Gelişmiş Arama',
            'description': 'Detaylı hasta arama ve filtreleme',
            'icon': Icons.search,
            'color': const Color(0xFFC084FC),
            'status': 'Active',
          },
          {
            'name': 'Patient groups',
            'description': 'Hasta kategorilendirme ve gruplama',
            'icon': Icons.group,
            'color': const Color(0xFF6B46C1),
            'status': 'Planned',
          },
          {
            'name': 'Patient statistics',
            'description': 'Hasta bazlı analiz ve istatistikler',
            'icon': Icons.bar_chart,
            'color': const Color(0xFF7C3AED),
            'status': 'In development',
          },
          {
            'name': 'Patient notifications',
            'description': 'Otomatik hasta bildirim sistemi',
            'icon': Icons.notifications,
            'color': const Color(0xFF8B5CF6),
            'status': 'Planned',
          },
          {
            'name': 'Patient privacy',
            'description': 'Hasta veri güvenliği ve gizlilik',
            'icon': Icons.security,
            'color': const Color(0xFF9333EA),
            'status': 'Active',
          },
        ],
      },
      'AI & analytics': {
        'name': 'AI & analytics',
        'description': 'Yapay zeka destekli tanı ve analiz araçları',
        'icon': Icons.psychology,
        'colors': [const Color(0xFF7C3AED), const Color(0xFF9333EA)],
        'features': [
          {
            'name': 'AI Tanı Asistanı',
            'description': 'Yapay zeka destekli tanı önerileri',
            'icon': Icons.psychology,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'AI Sohbet Botu',
            'description': 'Hasta ile AI destekli sohbet',
            'icon': Icons.chat,
            'color': const Color(0xFF7C3AED),
            'status': 'In development',
          },
          {
            'name': 'Risk Analizi',
            'description': 'Hasta risk değerlendirmesi',
            'icon': Icons.warning,
            'color': const Color(0xFF8B5CF6),
            'status': 'Active',
          },
          {
            'name': 'Tedavi Önerici',
            'description': 'AI destekli tedavi planı önerileri',
            'icon': Icons.medical_services,
            'color': const Color(0xFF9333EA),
            'status': 'In development',
          },
          {
            'name': 'Analitik Raporlar',
            'description': 'Detaylı analiz ve raporlar',
            'icon': Icons.analytics,
            'color': const Color(0xFFA855F7),
            'status': 'Active',
          },
          {
            'name': 'Mood Takibi',
            'description': 'Hasta ruh hali takip sistemi',
            'icon': Icons.timeline,
            'color': const Color(0xFFC084FC),
            'status': 'Active',
          },
          {
            'name': 'Rol Analizi',
            'description': 'Rol bazlı özellik analizi',
            'icon': Icons.people_alt,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'Tahmin Analizi',
            'description': 'Gelecek trend ve tahminler',
            'icon': Icons.trending_up,
            'color': const Color(0xFF7C3AED),
            'status': 'Planned',
          },
          {
            'name': 'Performans Metrikleri',
            'description': 'Klinik performans ölçümleri',
            'icon': Icons.speed,
            'color': const Color(0xFF8B5CF6),
            'status': 'In development',
          },
          {
            'name': 'Veri Görselleştirme',
            'description': 'İnteraktif grafik ve çizelgeler',
            'icon': Icons.show_chart,
            'color': const Color(0xFF9333EA),
            'status': 'Active',
          },
        ],
      },
      'Communication': {
        'name': 'Communication & telemedicine',
        'description': 'Uzaktan görüşme ve iletişim platformları',
        'icon': Icons.video_call,
        'colors': [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
        'features': [
          {
            'name': 'Telemedicine',
            'description': 'Uzaktan görüşme sistemi',
            'icon': Icons.video_call,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'Sesli Notlar',
            'description': 'Ses kayıt ve not alma',
            'icon': Icons.mic,
            'color': const Color(0xFF7C3AED),
            'status': 'Active',
          },
          {
            'name': 'Konsültasyon',
            'description': 'Uzman konsültasyon sistemi',
            'icon': Icons.medical_services,
            'color': const Color(0xFF8B5CF6),
            'status': 'Active',
          },
          {
            'name': 'Mobil Uygulama',
            'description': 'Mobil erişim ve özellikler',
            'icon': Icons.phone_android,
            'color': const Color(0xFF9333EA),
            'status': 'Active',
          },
          {
            'name': 'Mesajlaşma',
            'description': 'Güvenli mesajlaşma sistemi',
            'icon': Icons.message,
            'color': const Color(0xFFA855F7),
            'status': 'In development',
          },
          {
            'name': 'Video Kayıt',
            'description': 'Görüşme kayıt ve arşivleme',
            'icon': Icons.videocam,
            'color': const Color(0xFFC084FC),
            'status': 'Planned',
          },
          {
            'name': 'Ekran Paylaşımı',
            'description': 'Ekran paylaşım özelliği',
            'icon': Icons.screen_share,
            'color': const Color(0xFF6B46C1),
            'status': 'Planned',
          },
          {
            'name': 'Çoklu Dil',
            'description': 'Çoklu dil desteği',
            'icon': Icons.language,
            'color': const Color(0xFF7C3AED),
            'status': 'In development',
          },
        ],
      },
      'Operations': {
        'name': 'Yönetim & Raporlama',
        'description': 'Raporlar, finansal ve personel yönetimi',
        'icon': Icons.analytics,
        'colors': [const Color(0xFF9333EA), const Color(0xFFC084FC)],
        'features': [
          {
            'name': 'Raporlama',
            'description': 'Detaylı rapor oluşturma',
            'icon': Icons.analytics,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'Finansal Yönetim',
            'description': 'Gelir-gider takibi',
            'icon': Icons.account_balance_wallet,
            'color': const Color(0xFF7C3AED),
            'status': 'Active',
          },
          {
            'name': 'Personel Yönetimi',
            'description': 'Personel takip ve yönetim',
            'icon': Icons.people,
            'color': const Color(0xFF8B5CF6),
            'status': 'Active',
          },
          {
            'name': 'Faturalandırma',
            'description': 'Otomatik fatura oluşturma',
            'icon': Icons.receipt,
            'color': const Color(0xFF9333EA),
            'status': 'In development',
          },
          {
            'name': 'Sigorta Entegrasyonu',
            'description': 'Sigorta sistemleri entegrasyonu',
            'icon': Icons.local_hospital,
            'color': const Color(0xFFA855F7),
            'status': 'Planned',
          },
          {
            'name': 'E-Reçete',
            'description': 'Elektronik reçete sistemi',
            'icon': Icons.medication,
            'color': const Color(0xFFC084FC),
            'status': 'In development',
          },
          {
            'name': 'Stok Yönetimi',
            'description': 'İlaç ve malzeme stok takibi',
            'icon': Icons.inventory,
            'color': const Color(0xFF6B46C1),
            'status': 'Planned',
          },
          {
            'name': 'Kalite Kontrol',
            'description': 'Hizmet kalitesi değerlendirme',
            'icon': Icons.check_circle,
            'color': const Color(0xFF7C3AED),
            'status': 'Planned',
          },
        ],
      },
      'Security': {
        'name': 'Security & settings',
        'description': 'Security settings and system configuration',
        'icon': Icons.security,
        'colors': [const Color(0xFFA855F7), const Color(0xFFDDD6FE)],
        'features': [
          {
            'name': 'Security settings',
            'description': 'Sistem güvenlik yapılandırması',
            'icon': Icons.security,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'Dil settings',
            'description': 'Çoklu dil desteği',
            'icon': Icons.language,
            'color': const Color(0xFF7C3AED),
            'status': 'Active',
          },
          {
            'name': 'Offline Ayarlar',
            'description': 'Çevrimdışı çalışma modu',
            'icon': Icons.wifi_off,
            'color': const Color(0xFF8B5CF6),
            'status': 'Active',
          },
          {
            'name': 'Kullanıcı Yönetimi',
            'description': 'Kullanıcı hesapları ve yetkiler',
            'icon': Icons.person_add,
            'color': const Color(0xFF9333EA),
            'status': 'Active',
          },
          {
            'name': 'Veri Yedekleme',
            'description': 'Otomatik veri yedekleme',
            'icon': Icons.backup,
            'color': const Color(0xFFA855F7),
            'status': 'Active',
          },
          {
            'name': 'Audit Log',
            'description': 'Sistem aktivite kayıtları',
            'icon': Icons.history,
            'color': const Color(0xFFC084FC),
            'status': 'Active',
          },
          {
            'name': 'Şifreleme',
            'description': 'Veri şifreleme ve koruma',
            'icon': Icons.lock,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'İki Faktörlü Doğrulama',
            'description': '2FA güvenlik sistemi',
            'icon': Icons.verified_user,
            'color': const Color(0xFF7C3AED),
            'status': 'In development',
          },
        ],
      },
      'Entegrasyon': {
        'name': 'Entegrasyon & API',
        'description': 'Dış sistemler ve API entegrasyonları',
        'icon': Icons.integration_instructions,
        'colors': [const Color(0xFFC084FC), const Color(0xFFE9D5FF)],
        'features': [
          {
            'name': 'API Yönetimi',
            'description': 'REST API ve dokümantasyon',
            'icon': Icons.api,
            'color': const Color(0xFF6B46C1),
            'status': 'Active',
          },
          {
            'name': 'Webhook Desteği',
            'description': 'Webhook entegrasyonları',
            'icon': Icons.webhook,
            'color': const Color(0xFF7C3AED),
            'status': 'In development',
          },
          {
            'name': 'Üçüncü Parti Entegrasyon',
            'description': 'Dış sistem entegrasyonları',
            'icon': Icons.link,
            'color': const Color(0xFF8B5CF6),
            'status': 'Planned',
          },
          {
            'name': 'Veri Senkronizasyonu',
            'description': 'Çoklu sistem veri senkronizasyonu',
            'icon': Icons.sync,
            'color': const Color(0xFF9333EA),
            'status': 'In development',
          },
          {
            'name': 'Cloud Entegrasyonu',
            'description': 'Bulut servisleri entegrasyonu',
            'icon': Icons.cloud,
            'color': const Color(0xFFA855F7),
            'status': 'Active',
          },
          {
            'name': 'Mobile SDK',
            'description': 'Mobil uygulama geliştirme kiti',
            'icon': Icons.phone_android,
            'color': const Color(0xFFC084FC),
            'status': 'Planned',
          },
        ],
      },
    };

    if (category == 'All') {
      return allFeatures.values.toList();
    } else {
      return allFeatures.containsKey(category) ? [allFeatures[category]!] : [];
    }
  }
}
