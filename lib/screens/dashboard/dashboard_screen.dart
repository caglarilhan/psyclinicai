import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/theme.dart';
// import '../../utils/app_constants.dart';
import '../../widgets/therapist/therapist_tools_dashboard_widget.dart';
import '../../widgets/region/region_selector_widget.dart';
import '../../widgets/advanced_analytics_widgets.dart';
import '../../widgets/ai_chatbot_widgets.dart';
import '../../widgets/push_notification_widgets.dart';
import '../../widgets/workflow_automation_widgets.dart';
import '../../widgets/multi_language_widgets.dart';
import '../../widgets/enhanced_security_widgets.dart';
import '../sprint3/sprint1_demo_screen.dart';
import '../crm/crm_dashboard_screen.dart';
import '../white_label/white_label_dashboard_screen.dart';
import '../analytics/advanced_analytics_dashboard_screen.dart';
import '../security/security_dashboard_screen.dart';
import '../case/case_management_screen.dart';
// Masaüstü optimizasyonu için import'lar
import '../../utils/desktop_theme.dart';
import '../../widgets/desktop/desktop_layout.dart';
import '../../widgets/desktop/desktop_grid.dart';
import '../../services/keyboard_shortcuts_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final KeyboardShortcutsService _shortcutsService = KeyboardShortcutsService();

  @override
  void initState() {
    super.initState();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    // Dashboard için özel kısayollar
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/session-management'),
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/appointment-calendar'),
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/finance'),
    );
    _shortcutsService.addShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
      () => Navigator.pushNamed(context, '/security'),
    );
  }

  @override
  void dispose() {
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyN, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyC, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control),
    );
    _shortcutsService.removeShortcut(
      const LogicalKeySet(LogicalKeyboardKey.keyS, LogicalKeyboardKey.control),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (DesktopTheme.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  Widget _buildDesktopLayout() {
    return DesktopLayout(
      title: 'PsyClinic AI Dashboard',
      actions: [
        DesktopTheme.desktopButton(
          text: 'Kısayollar',
          onPressed: () => _showShortcutsDialog(context),
          icon: Icons.keyboard,
        ),
        const SizedBox(width: 8),
        DesktopTheme.desktopButton(
          text: 'Ayarlar',
          onPressed: () {
            // TODO: Ayarlar
          },
          icon: Icons.settings,
        ),
      ],
      sidebarItems: [
        DesktopSidebarItem(
          title: 'Klinik Yönetimi',
          icon: Icons.medical_services,
          children: [
            DesktopSidebarItem(
              title: 'Seans Yönetimi',
              icon: Icons.medical_services,
              onTap: () => Navigator.pushNamed(context, '/session-management'),
            ),
            DesktopSidebarItem(
              title: 'Randevu Takvimi',
              icon: Icons.calendar_today,
              onTap: () => Navigator.pushNamed(context, '/appointment-calendar'),
            ),
            DesktopSidebarItem(
              title: 'Vaka Yönetimi',
              icon: Icons.folder,
              onTap: () => Navigator.pushNamed(context, '/case-management'),
            ),
          ],
        ),
        DesktopSidebarItem(
          title: 'AI Modülleri',
          icon: Icons.psychology,
          children: [
            DesktopSidebarItem(
              title: 'Terapi Simülasyonu',
              icon: Icons.smart_toy,
              onTap: () => Navigator.pushNamed(context, '/therapy-simulation'),
            ),
            DesktopSidebarItem(
              title: 'Gelişmiş Analitik',
              icon: Icons.analytics,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedAnalyticsDashboardScreen(),
                ),
              ),
            ),
          ],
        ),
        DesktopSidebarItem(
          title: 'Yönetim',
          icon: Icons.admin_panel_settings,
          children: [
            DesktopSidebarItem(
              title: 'CRM Dashboard',
              icon: Icons.people,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CRMDashboardScreen(),
                ),
              ),
            ),
            DesktopSidebarItem(
              title: 'Finans Dashboard',
              icon: Icons.account_balance_wallet,
              onTap: () => Navigator.pushNamed(context, '/finance'),
            ),
            DesktopSidebarItem(
              title: 'Güvenlik',
              icon: Icons.security,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SecurityDashboardScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
      child: _buildDesktopContent(),
    );
  }

  Widget _buildDesktopContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst bilgi paneli
          DesktopTheme.desktopCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoş Geldiniz, ${AppConstants.userRoles.first}',
                        style: DesktopTheme.desktopTitleStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PsyClinic AI - AI Destekli Klinik Yönetim Sistemi',
                        style: DesktopTheme.desktopSubtitleStyle,
                      ),
                    ],
                  ),
                ),
                const RegionSelectorWidget(showLabel: true),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Klinik Yönetimi Grid
          _buildSectionTitle('Klinik Yönetimi'),
          const SizedBox(height: 16),
          
          DesktopGrid(
            children: [
              _buildDesktopModuleCard(
                'Seans Yönetimi',
                'Seans notları ve AI özetleri',
                Icons.medical_services,
                AppTheme.primaryColor,
                () => Navigator.pushNamed(context, '/session-management'),
              ),
              _buildDesktopModuleCard(
                'Randevu Takvimi',
                'AI destekli randevu yönetimi',
                Icons.calendar_today,
                AppTheme.secondaryColor,
                () => Navigator.pushNamed(context, '/appointment-calendar'),
              ),
              _buildDesktopModuleCard(
                'Tanı Sistemi',
                'ICD/DSM kodları ve AI önerileri',
                Icons.search,
                AppTheme.accentColor,
                () {
                  // TODO: Tanı sistemi
                },
              ),
              _buildDesktopModuleCard(
                'Reçete & İlaç',
                'AI destekli ilaç önerileri',
                Icons.medication,
                AppTheme.successColor,
                () {
                  // TODO: Reçete sistemi
                },
              ),
              _buildDesktopModuleCard(
                'Flag Sistemi',
                'Kriz ve risk tespiti',
                Icons.warning,
                AppTheme.warningColor,
                () {
                  // TODO: Flag sistemi
                },
              ),
              _buildDesktopModuleCard(
                'Vaka Yönetimi',
                'Danışan gelişim takibi ve ilerleme',
                Icons.folder,
                AppTheme.infoColor,
                () => Navigator.pushNamed(context, '/case-management'),
              ),
            ],
            context: context,
          ),
          
          const SizedBox(height: 32),

          // Terapist Araçları
          _buildSectionTitle('Terapist Araçları'),
          const SizedBox(height: 16),
          
          DesktopTheme.desktopCard(
            child: const TherapistToolsDashboardWidget(),
          ),
          
          const SizedBox(height: 32),

          // AI Destekli Modüller
          _buildSectionTitle('AI Destekli Modüller'),
          const SizedBox(height: 16),
          
          DesktopGrid(
            children: [
              _buildDesktopModuleCard(
                'AI Case Manager',
                'AI destekli vaka yönetimi',
                Icons.psychology,
                AppTheme.primaryColor,
                () {
                  // TODO: AI Case Manager
                },
              ),
              _buildDesktopModuleCard(
                'AI Diagnosis',
                'AI destekli tanı önerileri',
                Icons.auto_awesome,
                AppTheme.accentColor,
                () {
                  // TODO: AI Diagnosis
                },
              ),
              _buildDesktopModuleCard(
                'Terapi Simülasyonu',
                'AI ile seans provası',
                Icons.smart_toy,
                AppTheme.secondaryColor,
                () => Navigator.pushNamed(context, '/therapy-simulation'),
              ),
              _buildDesktopModuleCard(
                'Eğitim Kitaplığı',
                'AI önerili eğitim içerikleri',
                Icons.library_books,
                AppTheme.successColor,
                () {
                  // TODO: Eğitim kitaplığı
                },
              ),
            ],
            context: context,
          ),
          
          const SizedBox(height: 32),

          // Yönetim Modülleri
          _buildSectionTitle('Yönetim Modülleri'),
          const SizedBox(height: 16),
          
          DesktopGrid(
            children: [
              _buildDesktopModuleCard(
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
              _buildDesktopModuleCard(
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
              _buildDesktopModuleCard(
                'Süpervizör Dashboard',
                'Terapist performans takibi',
                Icons.supervisor_account,
                AppTheme.secondaryColor,
                () => Navigator.pushNamed(context, '/supervisor'),
              ),
              _buildDesktopModuleCard(
                'Finans Dashboard',
                'Gelir-gider ve faturalama',
                Icons.account_balance_wallet,
                AppTheme.successColor,
                () => Navigator.pushNamed(context, '/finance'),
              ),
              _buildDesktopModuleCard(
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
              _buildDesktopModuleCard(
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
            ],
            context: context,
          ),
          
          const SizedBox(height: 32),

          // Yardımcı Araçlar
          _buildSectionTitle('Yardımcı Araçlar'),
          const SizedBox(height: 16),
          
          DesktopGrid(
            children: [
              _buildDesktopModuleCard(
                'PDF Çıktısı',
                'Seans raporları ve belgeler',
                Icons.picture_as_pdf,
                AppTheme.accentColor,
                () {
                  // TODO: PDF çıktısı
                },
              ),
              _buildDesktopModuleCard(
                'Kurum Mesajlaşma',
                'AI özetli iletişim sistemi',
                Icons.chat,
                AppTheme.infoColor,
                () {
                  // TODO: Kurum mesajlaşma
                },
              ),
            ],
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
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
                    () => Navigator.pushNamed(context, '/session-management'),
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
                    'Vaka Yönetimi',
                    'Danışan gelişim takibi ve ilerleme',
                    Icons.folder,
                    AppTheme.infoColor,
                    () => Navigator.pushNamed(context, '/case-management'),
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
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Gelişmiş Analitik',
                    'AI destekli trend analizi ve tahminler',
                    Icons.analytics,
                    AppTheme.infoColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdvancedAnalyticsDashboardWidget(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'AI Chatbot',
                    '24/7 müşteri desteği',
                    Icons.chat_bubble,
                    AppTheme.warningColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AIChatbotWidget(),
                      ),
                    ),
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
                    () => Navigator.pushNamed(context, '/finance'),
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
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Bildirimler',
                    'Push notifications ve mesajlar',
                    Icons.notifications,
                    AppTheme.warningColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PushNotificationCenterWidget(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'İş Akışı Otomasyonu',
                    'Otomatik görevler ve onaylar',
                    Icons.schema,
                    AppTheme.successColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkflowManagementWidget(),
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
                    'Çoklu Dil Desteği',
                    'Türkçe, İngilizce, Almanca',
                    Icons.language,
                    AppTheme.infoColor,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LanguageSettingsWidget(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModuleCard(
                    context,
                    'Gelişmiş Güvenlik',
                    'Uyumluluk, şifreleme, erişim kontrolü',
                    Icons.security,
                    Colors.red[700]!,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnhancedSecurityDashboardWidget(),
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
                    'Tema Ayarları',
                    'Açık/koyu tema ve renkler',
                    Icons.palette,
                    AppTheme.accentColor,
                    () {
                      // TODO: Tema ayarları
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: DesktopTheme.isDesktop(context)
          ? DesktopTheme.desktopSectionTitleStyle
          : Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
    );
  }

  Widget _buildDesktopModuleCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return DesktopGridCard(
      title: title,
      subtitle: description,
      icon: icon,
      color: color,
      onTap: onTap,
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

  void _showShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Klavye Kısayolları'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutRow('Ctrl + N', 'Yeni Seans'),
              _buildShortcutRow('Ctrl + C', 'Randevu Takvimi'),
              _buildShortcutRow('Ctrl + F', 'Finans Dashboard'),
              _buildShortcutRow('Ctrl + S', 'Güvenlik Dashboard'),
              _buildShortcutRow('F11', 'Tam Ekran'),
              _buildShortcutRow('Ctrl + B', 'Sidebar Toggle'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
