import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../session/session_screen.dart';
import '../appointment/appointment_screen.dart';
import '../profile/profile_screen.dart';
import '../diagnosis/diagnosis_screen.dart';
import '../prescription/prescription_screen.dart';
import '../flag/flag_screen.dart';
import '../client_management/client_management_screen.dart';

import '../ai_appointment/ai_appointment_screen.dart';
import '../finance/finance_dashboard_screen.dart';
import '../supervisor/supervisor_dashboard_screen.dart';
import '../../widgets/ai_chatbot/ai_chatbot_widget.dart';
import '../../widgets/symptom_tracker/symptom_tracker_widget.dart';
import '../../widgets/medication_reminder/medication_reminder_widget.dart';
import '../../widgets/emergency_contact/emergency_contact_widget.dart';
import '../../widgets/progress_dashboard/progress_dashboard_widget.dart';
import '../../widgets/offline_mode/offline_mode_widget.dart';
import '../../widgets/telehealth/telehealth_dashboard_widget.dart';
import '../../widgets/advanced_ai/advanced_ai_dashboard_widget.dart';
// import '../../widgets/sprint3/sprint3_dashboard_widget.dart';
import '../../services/theme_service.dart';
import '../../services/offline_sync_service.dart';
import '../../widgets/therapist/therapist_tools_dashboard_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardHome(),
    SessionScreen(
      sessionId: 'demo_session_001',
      clientId: 'demo_client_001',
      clientName: 'Demo Client',
    ),
    const DiagnosisScreen(),
    const PrescriptionScreen(),
    const ClientManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology),
            label: 'Seanslar',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services),
            label: 'Tanılar',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication),
            label: 'Reçeteler',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Danışanlar',
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldiniz, ${AppConstants.userRoles.first}'),
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
            // Hoş geldin kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PsyClinic AI',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                    ),
                              ),
                              Text(
                                'AI Destekli Klinik Yönetim Sistemi',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Bugün ${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Offline Mode Widget
            const OfflineModeWidget(),
            const SizedBox(height: 24),

            // Telehealth Dashboard Widget
            const TelehealthDashboardWidget(),
            const SizedBox(height: 24),

            // Advanced AI Dashboard Widget
            const AdvancedAIDashboardWidget(),
            const SizedBox(height: 24),

            // Legal/Alert Sistemi Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel,
                          color: Colors.red.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '⚖️ Legal/Alert Sistemi',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Yasal uyumluluk ve acil durum bildirimleri',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/alert-console');
                            },
                            icon: const Icon(Icons.notifications_active),
                            label: const Text('Alert Konsolu'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/flag');
                            },
                            icon: const Icon(Icons.flag),
                            label: const Text('Flag Sistemi'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sprint 3 Dashboard
            // const Sprint3DashboardWidget(),
            const SizedBox(height: 24),
            
            // Sprint 3 Test Butonu
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Test & Geliştirme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/sprint3-test');
                            },
                            icon: const Icon(Icons.science),
                            label: const Text('Sprint 3 Test Ekranı'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // AI Analytics

            // Temel Modüller
            Text(
              'Temel Modüller',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Modül kartları
            _buildModuleCard(
              context,
              'Seans Notu + AI Özet',
              'Duygu, tema ve tanı önerisi üretimi + PDF',
              Icons.edit_note,
              AppTheme.primaryColor,
              () => Navigator.pushNamed(context, '/session'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Randevu Takvimi',
              'AI destekli hatırlatıcılar, no-show tahmini',
              Icons.calendar_today,
              AppTheme.secondaryColor,
              () => Navigator.pushNamed(context, '/appointment'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Tanı Arama Sistemi',
              'ICD/DSM kodları üzerinden hızlı arama',
              Icons.medical_services,
              AppTheme.warningColor,
              () => Navigator.pushNamed(context, '/diagnosis'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Reçete & İlaç Sistemi',
              'AI destekli ilaç önerisi ve etkileşim kontrolü',
              Icons.medication,
              AppTheme.secondaryColor,
              () => Navigator.pushNamed(context, '/prescription'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Flag Sistemi',
              'Kriz/suicid/ajitasyon tespiti ve müdahale',
              Icons.warning,
              AppTheme.errorColor,
              () => Navigator.pushNamed(context, '/flag'),
            ),
            const SizedBox(height: 16),

            // Sprint 3 Modülleri
            _buildModuleCard(
              context,
              'Eğitim Kitaplığı',
              'AI önerili eğitim içerikleri ve sertifika sistemi',
              Icons.school,
              Colors.purple,
              () => Navigator.pushNamed(context, '/education'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Terapi Simülasyonu',
              'AI destekli seans provası ve senaryo analizi',
              Icons.psychology,
              Colors.indigo,
              () => Navigator.pushNamed(context, '/therapy-simulation'),
            ),
            const SizedBox(height: 16),

            // Sprint 4 Modülleri
            _buildModuleCard(
              context,
              'İlaç Rehberi',
              'Kapsamlı ilaç veritabanı ve etkileşim kontrolü',
              Icons.medication,
              Colors.teal,
              () => Navigator.pushNamed(context, '/medication-guide'),
            ),
            const SizedBox(height: 16),

            // AI Chatbot
            _buildModuleCard(
              context,
              'AI Asistan',
              'İlaç bilgileri, yan etkiler ve etkileşimler hakkında anlık yardım',
              Icons.smart_toy,
              Colors.deepPurple,
              () => _showAIChatbot(context),
            ),
            const SizedBox(height: 16),

            // Symptom Tracker
            _buildModuleCard(
              context,
              'Semptom Takibi',
              'Günlük semptom seviyelerinizi takip edin ve trendleri görün',
              Icons.trending_up,
              Colors.green.shade600,
              () => _showSymptomTracker(context),
            ),
            const SizedBox(height: 16),

            // Medication Reminder
            _buildModuleCard(
              context,
              'İlaç Hatırlatıcıları',
              'İlaçlarınızı zamanında almayı unutmayın',
              Icons.alarm,
              Colors.orange.shade600,
              () => _showMedicationReminder(context),
            ),
            const SizedBox(height: 16),

            // Emergency Contact
            _buildModuleCard(
              context,
              'Acil Durum Kontakları',
              'Hızlı erişim için önemli kontaklar',
              Icons.emergency,
              Colors.red.shade600,
              () => _showEmergencyContact(context),
            ),
            const SizedBox(height: 16),

            // Progress Dashboard
            _buildModuleCard(
              context,
              'İlerleme Dashboard',
              'Hedeflerinizi takip edin ve başarılarınızı kutlayın',
              Icons.trending_up,
              Colors.indigo.shade600,
              () => _showProgressDashboard(context),
            ),
            const SizedBox(height: 16),

            // Offline Mode
            _buildModuleCard(
              context,
              'Çevrimdışı Mod',
              'İnternet olmadan çalışma ve veri senkronizasyonu',
              Icons.cloud_off,
              Colors.grey.shade600,
              () => _showOfflineMode(context),
            ),
            const SizedBox(height: 16),

            // Vaka Yönetimi
            _buildModuleCard(
              context,
              'Vaka Yönetimi',
              'Danışan profilleri, seans geçmişi ve AI destekli vaka analizi',
              Icons.people,
              Colors.teal.shade600,
              () => _showClientManagement(context),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 24),

            // AI Destekli Modüller
            Text(
              'AI Destekli Modüller',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'AI Vaka Yöneticisi',
              'AI destekli vaka analizi, risk değerlendirmesi ve öneriler',
              Icons.psychology,
              Colors.deepOrange.shade600,
              () => Navigator.pushNamed(context, '/ai-case-management'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'AI Tanı Sistemi',
              'AI destekli semptom analizi ve tanı önerileri',
              Icons.medical_services,
              Colors.teal.shade600,
              () => Navigator.pushNamed(context, '/ai-diagnosis'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Güvenlik & Uyumluluk',
              'Veri şifreleme, denetim kayıtları ve erişim kontrolü',
              Icons.security,
              Colors.red.shade600,
              () => Navigator.pushNamed(context, '/security'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'AI Randevu Sistemi',
              'AI destekli randevu optimizasyonu ve no-show tahmini',
              Icons.schedule,
              Colors.blue.shade600,
              () => Navigator.pushNamed(context, '/ai-appointment'),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 24),

            // Yönetim Modülleri
            Text(
              'Yönetim Modülleri',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Finans Dashboard',
              'Gelir takibi, maliyet analizi ve AI destekli finansal öngörüler',
              Icons.account_balance_wallet,
              Colors.green.shade700,
              () => Navigator.pushNamed(context, '/finance'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'Süpervizör Dashboard',
              'Terapist performans takibi, kalite metrikleri ve AI destekli süpervizyon',
              Icons.supervisor_account,
              Colors.purple.shade700,
              () => Navigator.pushNamed(context, '/supervisor'),
            ),
            const SizedBox(height: 16),

            _buildModuleCard(
              context,
              'PDF Çıktısı',
              'Seans notlarını PDF olarak alma',
              Icons.picture_as_pdf,
              AppTheme.accentColor,
              () {
                // TODO: PDF export
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export özelliği yakında!')),
                );
              },
            ),
            const SizedBox(height: 24),

            // Hızlı istatistikler
            Text(
              'Hızlı İstatistikler',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Bugünkü Seanslar',
                    '3',
                    Icons.psychology,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Bekleyen Randevular',
                    '7',
                    Icons.schedule,
                    AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'AI Özetleri',
                    '12',
                    Icons.auto_awesome,
                    AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'PDF Çıktıları',
                    '8',
                    Icons.picture_as_pdf,
                    AppTheme.warningColor,
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAIChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const AIChatbotWidget(),
      ),
    );
  }

  void _showSymptomTracker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const SymptomTrackerWidget(),
      ),
    );
  }

  void _showMedicationReminder(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const MedicationReminderWidget(),
      ),
    );
  }

  void _showEmergencyContact(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const EmergencyContactWidget(),
      ),
    );
  }

  void _showProgressDashboard(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const ProgressDashboardWidget(),
      ),
    );
  }

  void _showOfflineMode(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const OfflineModeWidget(),
      ),
    );
  }

  void _showClientManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClientManagementScreen(),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }
}
