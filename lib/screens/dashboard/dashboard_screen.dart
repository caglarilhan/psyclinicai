import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/therapist/therapist_tools_dashboard_widget.dart';
import '../../widgets/region/region_selector_widget.dart';
import '../sprint3/sprint1_demo_screen.dart';
import '../crm/crm_dashboard_screen.dart';
import '../white_label/white_label_dashboard_screen.dart';
import '../analytics/advanced_analytics_dashboard_screen.dart';
import '../security/security_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldiniz, ${AppConstants.userRoles.first}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Bildirimler
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Ayarlar
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bölge Seçici
            const RegionSelectorWidget(
              showLabel: true,
            ),
            
            const SizedBox(height: 24),

            // Klinik Yönetimi
            Text(
              'Klinik Yönetimi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Seans Yönetimi',
                    'Seans notları ve AI özetleri',
                    Icons.medical_services,
                    AppTheme.primaryColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Sprint1DemoScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                                        Expanded(
                          child: _buildModuleCard(
                            context,
                            'Randevu Takvimi',
                            'AI destekli randevu yönetimi',
                            Icons.calendar_today,
                            AppTheme.secondaryColor,
                            () => Navigator.pushNamed(context, '/appointment-calendar'),
                          ),
                        ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Tanı Sistemi',
                    'ICD/DSM kodları ve AI önerileri',
                    Icons.search,
                    AppTheme.accentColor,
                    () {
                      // TODO: Tanı sistemi
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Reçete & İlaç',
                    'AI destekli ilaç önerileri',
                    Icons.medication,
                    AppTheme.successColor,
                    () {
                      // TODO: Reçete sistemi
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Flag Sistemi',
                    'Kriz ve risk tespiti',
                    Icons.warning,
                    AppTheme.warningColor,
                    () {
                      // TODO: Flag sistemi
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Vaka Yöneticisi',
                    'Danışan gelişim takibi',
                    Icons.folder,
                    AppTheme.infoColor,
                    () {
                      // TODO: Vaka yöneticisi
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Terapist Araçları
            Text(
              'Terapist Araçları',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            const TherapistToolsDashboardWidget(),
            
            const SizedBox(height: 24),

            // AI Destekli Modüller
            Text(
              'AI Destekli Modüller',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'AI Case Manager',
                    'AI destekli vaka yönetimi',
                    Icons.psychology,
                    AppTheme.primaryColor,
                    () {
                      // TODO: AI Case Manager
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'AI Diagnosis',
                    'AI destekli tanı önerileri',
                    Icons.auto_awesome,
                    AppTheme.accentColor,
                    () {
                      // TODO: AI Diagnosis
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Terapi Simülasyonu',
                    'AI ile seans provası',
                    Icons.smart_toy,
                    AppTheme.secondaryColor,
                    () => Navigator.pushNamed(context, '/therapy-simulation'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Eğitim Kitaplığı',
                    'AI önerili eğitim içerikleri',
                    Icons.library_books,
                    AppTheme.successColor,
                    () {
                      // TODO: Eğitim kitaplığı
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Yönetim Modülleri
            Text(
              'Yönetim Modülleri',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'CRM Dashboard',
                    'Müşteri yönetimi ve satış takibi',
                    Icons.people,
                    AppTheme.primaryColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CRMDashboardScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'White-Label',
                    'Marka ve tema özelleştirme',
                    Icons.palette,
                    AppTheme.accentColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WhiteLabelDashboardScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Süpervizör Dashboard',
                    'Terapist performans takibi',
                    Icons.supervisor_account,
                    AppTheme.secondaryColor,
                    () => Navigator.pushNamed(context, '/supervisor'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Finans Dashboard',
                    'Gelir-gider ve faturalama',
                    Icons.account_balance_wallet,
                    AppTheme.successColor,
                    () {
                      // TODO: Finans dashboard
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Gelişmiş Analitik',
                    'AI destekli veri analizi ve tahminler',
                    Icons.analytics,
                    AppTheme.infoColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedAnalyticsDashboardScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Güvenlik & Uyumluluk',
                    'HIPAA, GDPR, KVKK uyumluluğu',
                    Icons.security,
                    AppTheme.warningColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecurityDashboardScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Yardımcı Araçlar
            Text(
              'Yardımcı Araçlar',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'PDF Çıktısı',
                    'Seans raporları ve belgeler',
                    Icons.picture_as_pdf,
                    AppTheme.accentColor,
                    () {
                      // TODO: PDF çıktısı
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Kurum Mesajlaşma',
                    'AI özetli iletişim sistemi',
                    Icons.chat,
                    AppTheme.infoColor,
                    () {
                      // TODO: Kurum mesajlaşma
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
