import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '../../services/role_service.dart';
import '../../services/homework_service.dart';
import '../../utils/material3_animations.dart';
import '../../utils/material3_responsive.dart';
import 'package:intl/intl.dart';
import '../patients/patient_list_screen.dart';
import '../appointments/appointment_screen.dart';
import '../ai/ai_diagnosis_screen.dart';
import '../telemedicine/telemedicine_screen.dart';
import '../security/security_screen.dart';
import '../analytics/analytics_screen.dart';
import '../role_management/role_features_analysis.dart';
import '../patient_portal/patient_portal_screen.dart';
import '../voice_notes/voice_notes_screen.dart';
import '../billing/billing_screen.dart';
import '../insurance/insurance_screen.dart';
import '../e_prescription/e_prescription_screen.dart';
import '../search/advanced_search_screen.dart';
import '../mood_tracking/mood_tracking_screen.dart';
import '../ai_chatbot/ai_chatbot_screen.dart';
import '../settings/language_settings_screen.dart';
import '../settings/offline_settings_screen.dart';
import '../patient_education/patient_education_screen.dart';
import '../mobile/mobile_home_screen.dart';
import '../consultation/consultation_screen.dart';
import '../nurse_care/nurse_care_screen.dart';
import '../specialty_recommendations/specialty_recommendations_screen.dart';
import '../medication_tracking/medication_tracking_screen.dart';
import '../secretary_appointment/secretary_appointment_screen.dart';
import '../secretary_patient/secretary_patient_screen.dart';
import '../manager_reporting/manager_reporting_screen.dart';
import '../manager_financial/manager_financial_screen.dart';
import '../manager_staff/manager_staff_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

  class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

    List<Widget> _screensForRole(String role) {
      final full = [
        const HomeTab(),
        const PatientsTab(),
        const AppointmentsTab(),
        const AIDiagnosisTab(),
        const TelemedicineTab(),
        const SecurityTab(),
        const AnalyticsTab(),
        const RoleAnalysisTab(),
        const PatientPortalTab(),
        const VoiceNotesTab(),
        const BillingTab(),
        const InsuranceTab(),
        const EPrescriptionTab(),
        const AdvancedSearchTab(),
        const MoodTrackingTab(),
        // AIChatbot artık AI Tanı içinde erişilecek
        const LanguageSettingsTab(),
        const OfflineSettingsTab(),
        const PatientEducationTab(),
        const MobileAppTab(),
        const ConsultationTab(),
        const NurseCareTab(),
        const SpecialtyRecommendationsTab(),
        const MedicationTrackingTab(),
        const SecretaryAppointmentTab(),
        const SecretaryPatientTab(),
        const ManagerReportingTab(),
        const ManagerFinancialTab(),
        const ManagerStaffTab(),
      ];

      switch (role) {
        case 'Psikolog':
          return full.where((w) => w is! EPrescriptionTab && w is! InsuranceTab && w is! BillingTab).toList();
        case 'Sekreter':
          return [
            const HomeTab(),
            const PatientsTab(),
            const AppointmentsTab(),
            const BillingTab(),
            const InsuranceTab(),
            const AdvancedSearchTab(),
            const LanguageSettingsTab(),
            const MobileAppTab(),
          ];
        case 'Hasta':
          return [
            const HomeTab(),
            const PatientPortalTab(),
            const AppointmentsTab(),
            const MoodTrackingTab(),
            const AIChatbotTab(),
            const MobileAppTab(),
          ];
        default: // Psikiyatrist ve diğerleri tam
          return full;
      }
    }

    List<BottomNavigationBarItem> _navItemsForRole(String role) {
      List<Map<String, dynamic>> all = const [
        {'icon': Icons.home, 'label': 'Ana Sayfa'},
        {'icon': Icons.people, 'label': 'Hastalar'},
        {'icon': Icons.calendar_today, 'label': 'Randevular'},
        {'icon': Icons.psychology, 'label': 'AI Tanı'},
        {'icon': Icons.video_call, 'label': 'Telemedicine'},
        {'icon': Icons.security, 'label': 'Güvenlik'},
        {'icon': Icons.analytics, 'label': 'Analitik'},
        {'icon': Icons.people_alt, 'label': 'Roller'},
        {'icon': Icons.person, 'label': 'Hasta Portalı'},
        {'icon': Icons.mic, 'label': 'Sesli Notlar'},
        {'icon': Icons.receipt, 'label': 'Faturalandırma'},
        {'icon': Icons.local_hospital, 'label': 'Sigorta'},
        {'icon': Icons.medication, 'label': 'E-Reçete'},
        {'icon': Icons.search, 'label': 'Arama'},
        {'icon': Icons.timeline, 'label': 'Mood'},
        // AI Asistan kaldırıldı; AI Tanı içinde erişilecek
        {'icon': Icons.language, 'label': 'Dil'},
        {'icon': Icons.wifi_off, 'label': 'Offline'},
        {'icon': Icons.school, 'label': 'Eğitim'},
        {'icon': Icons.phone_android, 'label': 'Mobil'},
        {'icon': Icons.medical_services, 'label': 'Konsültasyon'},
        {'icon': Icons.healing, 'label': 'Hemşire Bakımı'},
        {'icon': Icons.lightbulb, 'label': 'Uzmanlık Önerileri'},
        {'icon': Icons.medication_liquid, 'label': 'İlaç Takibi'},
        {'icon': Icons.calendar_today, 'label': 'Sekreter Randevu'},
        {'icon': Icons.folder_open, 'label': 'Hasta Kayıtları'},
        {'icon': Icons.analytics, 'label': 'Yönetici Raporlama'},
        {'icon': Icons.account_balance_wallet, 'label': 'Finansal Yönetim'},
        {'icon': Icons.people, 'label': 'Personel Yönetimi'},
      ];

      List<Map<String, dynamic>> filtered;
      switch (role) {
        case 'Psikolog':
          filtered = all.where((i) => !['Faturalandırma','Sigorta','E-Reçete'].contains(i['label'])).toList();
          break;
        case 'Sekreter':
          filtered = all.where((i) => ['Ana Sayfa','Hastalar','Randevular','Faturalandırma','Sigorta','Arama','Dil','Mobil'].contains(i['label'])).toList();
          break;
        case 'Hasta':
          filtered = all.where((i) => ['Ana Sayfa','Hasta Portalı','Randevular','Mood','Mobil'].contains(i['label'])).toList();
          break;
        default:
          filtered = all;
      }
      return filtered.map((e) => BottomNavigationBarItem(icon: Icon(e['icon'] as IconData), label: e['label'] as String)).toList();
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final role = context.watch<RoleService>().currentRole;
    final screens = _screensForRole(role);
    final allItems = _navItemsForRole(role);
    if (_selectedIndex >= screens.length) _selectedIndex = 0;

    // Material 3 NavigationBar için destinations
    final bool hasMore = allItems.length > 5;
    final int primaryCount = hasMore ? 4 : allItems.length;
    
    final List<NavigationDestination> destinations = [
      ...allItems.take(primaryCount).map((item) => NavigationDestination(
        icon: item.icon,
        label: item.label ?? '',
      )),
      if (hasMore)
        const NavigationDestination(
          icon: Icon(Icons.more_horiz),
          label: 'Daha Fazla',
        ),
    ];

    final int currentNavIndex = hasMore
        ? (_selectedIndex < primaryCount ? _selectedIndex : primaryCount)
        : _selectedIndex;

    return ResponsiveLayoutBuilder(
      builder: (context, breakpoint) {
        final isMobile = breakpoint == Breakpoint.mobile;
        final isTablet = breakpoint == Breakpoint.tablet;
        final isDesktop = breakpoint == Breakpoint.desktop || breakpoint == Breakpoint.largeDesktop;
        
        if (isDesktop) {
          // Desktop layout with NavigationRail
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'PsyClinic AI Dashboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/landing');
                  },
                  icon: Icon(
                    Icons.logout,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Çıkış Yap',
                ),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentNavIndex,
                  onDestinationSelected: (index) {
                    if (hasMore && index == primaryCount) {
                      _showMoreMenu(context, allItems, primaryCount);
                    } else {
                      setState(() => _selectedIndex = index);
                    }
                  },
                  destinations: destinations.map((dest) => NavigationRailDestination(
                    icon: dest.icon,
                    label: Text(dest.label),
                  )).toList(),
                  extended: true,
                  minExtendedWidth: 200,
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: screens[_selectedIndex],
                ),
              ],
            ),
          );
        } else if (isTablet) {
          // Tablet layout with NavigationRail
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'PsyClinic AI Dashboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/landing');
                  },
                  icon: Icon(
                    Icons.logout,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Çıkış Yap',
                ),
              ],
            ),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentNavIndex,
                  onDestinationSelected: (index) {
                    if (hasMore && index == primaryCount) {
                      _showMoreMenu(context, allItems, primaryCount);
                    } else {
                      setState(() => _selectedIndex = index);
                    }
                  },
                  destinations: destinations.map((dest) => NavigationRailDestination(
                    icon: dest.icon,
                    label: Text(dest.label),
                  )).toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: screens[_selectedIndex],
                ),
              ],
            ),
          );
        } else {
          // Mobile layout with NavigationBar
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'PsyClinic AI Dashboard',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/landing');
                  },
                  icon: Icon(
                    Icons.logout,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: 'Çıkış Yap',
                ),
              ],
            ),
            body: screens[_selectedIndex],
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentNavIndex,
              onDestinationSelected: (index) {
                if (hasMore && index == primaryCount) {
                  _showMoreMenu(context, allItems, primaryCount);
                } else {
                  setState(() => _selectedIndex = index);
                }
              },
              destinations: destinations,
            ),
          );
        }
      },
    );
  }
  
  void _showMoreMenu(BuildContext context, List<BottomNavigationBarItem> allItems, int primaryCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Material3Animations.showMaterial3BottomSheet(
      context: context,
      child: SafeArea(
        child: Padding(
          padding: Material3Responsive.responsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ayarlar ve Diğerleri',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Gap(Material3Responsive.responsiveGap(context)),
              Flexible(
                child: ResponsiveGrid(
                  children: allItems.skip(primaryCount).map((item) {
                    final targetIndex = primaryCount + allItems.skip(primaryCount).toList().indexOf(item);
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _selectedIndex = targetIndex);
                      },
                      borderRadius: BorderRadius.circular(Material3Responsive.responsiveBorderRadius(context)),
                      child: ResponsiveCard(
                        child: Row(
                          children: [
                            Icon(
                              item.icon.icon,
                              color: colorScheme.primary,
                              size: Material3Responsive.responsiveIconSize(context) * 0.8,
                            ),
                            Gap(Material3Responsive.responsiveGap(context)),
                            Expanded(
                              child: ResponsiveText(
                                item.label ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: colorScheme.onSurfaceVariant,
                              size: Material3Responsive.responsiveIconSize(context) * 0.8,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Rol bazlı yapılandırma
    final currentRole = context.watch<RoleService>().currentRole;
    final List<Map<String, dynamic>> roleStats = () {
      switch (currentRole) {
        case 'Psikiyatrist':
          return <Map<String, dynamic>>[
            {'t': 'Aktif Hastalar', 'v': '156', 'i': Icons.people, 'c': Colors.blue},
            {'t': 'Bugünkü Seans', 'v': '8', 'i': Icons.schedule, 'c': Colors.green},
            {'t': 'Kritik Vaka', 'v': '2', 'i': Icons.warning_amber_rounded, 'c': Colors.orange},
            {'t': 'E-Reçete', 'v': '14', 'i': Icons.medication, 'c': Colors.purple},
          ];
        case 'Psikolog':
          return <Map<String, dynamic>>[
            {'t': 'Bugünkü Seans', 'v': '7', 'i': Icons.schedule, 'c': Colors.green},
            {'t': 'Tamamlanan Ölçek', 'v': '10', 'i': Icons.assignment_turned_in, 'c': Colors.indigo},
            {'t': 'Süpervizyon', 'v': '1', 'i': Icons.supervised_user_circle, 'c': Colors.teal},
            {'t': 'Not Şablonları', 'v': '6', 'i': Icons.description, 'c': Colors.deepOrange},
          ];
        case 'Sekreter':
          return <Map<String, dynamic>>[
            {'t': 'Bekleyen Randevu', 'v': '12', 'i': Icons.pending_actions, 'c': Colors.amber[800]!},
            {'t': 'Bugün Onaylanan', 'v': '18', 'i': Icons.event_available, 'c': Colors.green},
            {'t': 'Ödeme Bekleyen', 'v': '5', 'i': Icons.payments, 'c': Colors.pink},
            {'t': 'Yeni Başvuru', 'v': '4', 'i': Icons.person_add, 'c': Colors.blue},
          ];
        case 'Hasta':
          return <Map<String, dynamic>>[
            {'t': 'Yakın Randevu', 'v': 'Yarın 10:00', 'i': Icons.today, 'c': Colors.blue},
            {'t': 'Mood Günlüğü', 'v': '3/7', 'i': Icons.mood, 'c': Colors.purple},
            {'t': 'Egzersiz', 'v': '2 tamam', 'i': Icons.fitness_center, 'c': Colors.green},
            {'t': 'Mesajlar', 'v': '1 yeni', 'i': Icons.message, 'c': Colors.orange},
          ];
        default:
          return <Map<String, dynamic>>[
            {'t': 'Toplam Hasta', 'v': '156', 'i': Icons.people, 'c': Colors.blue},
            {'t': 'Bugünkü Randevular', 'v': '5', 'i': Icons.calendar_today, 'c': Colors.green},
            {'t': 'Aktif Tedaviler', 'v': '23', 'i': Icons.medical_services, 'c': Colors.orange},
            {'t': 'Gelir (Bu Ay)', 'v': '₺45.2K', 'i': Icons.attach_money, 'c': Colors.purple},
          ];
      }
    }();

    final List<Map<String, dynamic>> quickActions = () {
      switch (currentRole) {
        case 'Psikiyatrist':
          return <Map<String, dynamic>>[
            {'t': 'E‑Reçete Yaz', 'i': Icons.medication, 'on': () => Navigator.pushNamed(context, '/prescription')},
            {'t': '🤖 Akıllı Reçete', 'i': Icons.smart_toy, 'on': () => Navigator.pushNamed(context, '/smart-prescription')},
            {'t': 'Tanı/Ölçek', 'i': Icons.psychology, 'on': () => Navigator.pushNamed(context, '/diagnosis')},
            {'t': 'Kritik Vaka', 'i': Icons.warning, 'on': () => Navigator.pushNamed(context, '/flag')},
            {'t': 'İlaç Etkileşimi', 'i': Icons.science, 'on': () => Navigator.pushNamed(context, '/medication-guide')},
            {'t': 'Ödevlerim', 'i': Icons.task_alt, 'on': () => Navigator.pushNamed(context, '/homework')},
          ];
        case 'Psikolog':
          return <Map<String, dynamic>>[
            {'t': 'Seans Başlat', 'i': Icons.play_circle, 'on': () => Navigator.pushNamed(context, '/session')},
            {'t': 'PHQ‑9', 'i': Icons.assignment, 'on': () => Navigator.pushNamed(context, '/assessments')},
            {'t': 'GAD‑7', 'i': Icons.assignment_outlined, 'on': () => Navigator.pushNamed(context, '/assessments')},
            {'t': 'Not Oluştur', 'i': Icons.description, 'on': () => Navigator.pushNamed(context, '/therapy-notes')},
            {'t': 'Ödevlerim', 'i': Icons.task_alt, 'on': () => Navigator.pushNamed(context, '/homework')},
          ];
        case 'Sekreter':
          return <Map<String, dynamic>>[
            {'t': 'Randevu Oluştur', 'i': Icons.add_box, 'on': () => Navigator.pushNamed(context, '/appointment')},
            {'t': 'Hasta Ekle', 'i': Icons.person_add, 'on': () => Navigator.pushNamed(context, '/client-management')},
            {'t': 'Ödeme Al', 'i': Icons.attach_money, 'on': () => Navigator.pushNamed(context, '/finance')},
            {'t': 'Hatırlatma', 'i': Icons.notifications_active, 'on': () => Navigator.pushNamed(context, '/appointment')},
          ];
        case 'Hasta':
          return <Map<String, dynamic>>[
            {'t': 'Randevu Al', 'i': Icons.event, 'on': () => Navigator.pushNamed(context, '/appointment')},
            {'t': 'Mood Gir', 'i': Icons.mood, 'on': () => Navigator.pushNamed(context, '/mood')},
            {'t': 'Mesaj Yaz', 'i': Icons.message, 'on': () => Navigator.pushNamed(context, '/patient-portal')},
            {'t': 'Planı Gör', 'i': Icons.list_alt, 'on': () => Navigator.pushNamed(context, '/treatment-plan')},
            {'t': 'Ödevlerim', 'i': Icons.task_alt, 'on': () => Navigator.pushNamed(context, '/homework')},
          ];
        default:
          return <Map<String, dynamic>>[];
      }
    }();

    return SingleChildScrollView(
      padding: Material3Responsive.responsivePadding(context),
      child: Material3Animations.staggeredList(
        children: [
          // Welcome Card - Material 3
          ResponsiveCard(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Material3Responsive.responsiveBorderRadius(context)),
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: Material3Responsive.responsivePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Material3Animations.animatedIcon(
                          icon: Icons.psychology,
                          color: colorScheme.onPrimary,
                          size: Material3Responsive.responsiveIconSize(context),
                        ),
                        Gap(Material3Responsive.responsiveGap(context)),
                        Expanded(
                          child: ResponsiveText(
                            'Hoş Geldiniz, $currentRole',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(Material3Responsive.responsiveGap(context) * 0.5),
                    ResponsiveText(
                      'PsyClinic AI ile gününüze başlayın',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Gap(Material3Responsive.responsiveGap(context) * 1.5),
          
          // Stats Grid - Material 3
          ResponsiveText(
            'Özet İstatistikler',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Gap(Material3Responsive.responsiveGap(context)),
          ResponsiveGrid(
            children: roleStats.map((stat) {
              return Material3Animations.animatedCard(
                onTap: _routeForStat(context, stat['t'] as String),
                child: ResponsiveCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Material3Animations.animatedIcon(
                        icon: stat['i'] as IconData,
                        color: colorScheme.primary,
                        size: Material3Responsive.responsiveIconSize(context),
                      ),
                      Gap(Material3Responsive.responsiveGap(context) * 0.5),
                      Material3Animations.animatedCounter(
                        value: int.tryParse(stat['v'].toString()) ?? 0,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Gap(Material3Responsive.responsiveGap(context) * 0.25),
                      ResponsiveText(
                        stat['t'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          Gap(Material3Responsive.responsiveGap(context) * 1.5),
          
          // Quick Actions - Material 3
          if (quickActions.isNotEmpty) ...[
            ResponsiveText(
              'Hızlı İşlemler',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Gap(Material3Responsive.responsiveGap(context)),
            ResponsiveGrid(
              children: quickActions.map((action) {
                return Material3Animations.scaleIn(
                  child: FilledButton.icon(
                    onPressed: action['on'] as VoidCallback,
                    icon: Icon(
                      action['i'] as IconData,
                      size: Material3Responsive.responsiveIconSize(context) * 0.8,
                    ),
                    label: ResponsiveText(
                      action['t'] as String,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: Material3Responsive.responsiveGap(context),
                        vertical: Material3Responsive.responsiveGap(context) * 0.75,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Material3Responsive.responsiveBorderRadius(context) * 0.6),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            Gap(Material3Responsive.responsiveGap(context) * 1.5),
          ],
          
          // Recent Activities - Material 3
          ResponsiveText(
            'Son Aktiviteler',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Gap(Material3Responsive.responsiveGap(context)),
          ResponsiveCard(
            child: Column(
              children: [
                _buildActivityItem('Yeni hasta kaydı', 'Ahmet Yılmaz', '10:30'),
                Divider(color: colorScheme.outlineVariant),
                _buildActivityItem('Randevu tamamlandı', 'Ayşe Demir', '09:15'),
                Divider(color: colorScheme.outlineVariant),
                _buildActivityItem('Tedavi planı güncellendi', 'Mehmet Kaya', '08:45'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(onTap: onTap, child: card);
  }

  VoidCallback? _routeForStat(BuildContext context, String title) {
    switch (title) {
      case 'E-Reçete':
      case 'E‑Reçete':
        return () => Navigator.pushNamed(context, '/prescription');
      case 'Kritik Vaka':
        return () => Navigator.pushNamed(context, '/flag');
      case 'Bugünkü Seans':
      case 'Bugünkü Randevular':
        return () => Navigator.pushNamed(context, '/appointment');
      case 'Aktif Hastalar':
      case 'Toplam Hasta':
        return () => Navigator.pushNamed(context, '/client-management');
      default:
        return null;
    }
  }

  Widget _buildActivityItem(String action, String patient, String time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(
          Icons.person,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(
        action,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        patient,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        time,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class PatientsTab extends StatelessWidget {
  const PatientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientListScreen();
  }
}

class AppointmentsTab extends StatelessWidget {
  const AppointmentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppointmentScreen();
  }
}

class AIDiagnosisTab extends StatelessWidget {
  const AIDiagnosisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIDiagnosisScreen();
  }
}

class TelemedicineTab extends StatelessWidget {
  const TelemedicineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TelemedicineScreen();
  }
}

class SecurityTab extends StatelessWidget {
  const SecurityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecurityScreen();
  }
}

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnalyticsScreen();
  }
}

class RoleAnalysisTab extends StatelessWidget {
  const RoleAnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleFeaturesAnalysisScreen();
  }
}

class PatientPortalTab extends StatelessWidget {
  const PatientPortalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientPortalScreen();
  }
}

class VoiceNotesTab extends StatelessWidget {
  const VoiceNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const VoiceNotesScreen();
  }
}

class BillingTab extends StatelessWidget {
  const BillingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BillingScreen();
  }
}

class InsuranceTab extends StatelessWidget {
  const InsuranceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const InsuranceScreen();
  }
}

class EPrescriptionTab extends StatelessWidget {
  const EPrescriptionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const EPrescriptionScreen();
  }
}

class AdvancedSearchTab extends StatelessWidget {
  const AdvancedSearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdvancedSearchScreen();
  }
}

class MoodTrackingTab extends StatelessWidget {
  const MoodTrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoodTrackingScreen();
  }
}

class AIChatbotTab extends StatelessWidget {
  const AIChatbotTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const AIChatbotScreen();
  }
}

class LanguageSettingsTab extends StatelessWidget {
  const LanguageSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const LanguageSettingsScreen();
  }
}

class OfflineSettingsTab extends StatelessWidget {
  const OfflineSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const OfflineSettingsScreen();
  }
}

class PatientEducationTab extends StatelessWidget {
  const PatientEducationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const PatientEducationScreen();
  }
}

class MobileAppTab extends StatelessWidget {
  const MobileAppTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MobileHomeScreen();
  }
}

class ConsultationTab extends StatelessWidget {
  const ConsultationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ConsultationScreen();
  }
}

class NurseCareTab extends StatelessWidget {
  const NurseCareTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const NurseCareScreen();
  }
}

class SpecialtyRecommendationsTab extends StatelessWidget {
  const SpecialtyRecommendationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SpecialtyRecommendationsScreen();
  }
}

class MedicationTrackingTab extends StatelessWidget {
  const MedicationTrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MedicationTrackingScreen();
  }
}

class SecretaryAppointmentTab extends StatelessWidget {
  const SecretaryAppointmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecretaryAppointmentScreen();
  }
}

class SecretaryPatientTab extends StatelessWidget {
  const SecretaryPatientTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SecretaryPatientScreen();
  }
}

class ManagerReportingTab extends StatelessWidget {
  const ManagerReportingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManagerReportingScreen();
  }
}

class ManagerFinancialTab extends StatelessWidget {
  const ManagerFinancialTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManagerFinancialScreen();
  }
}

class ManagerStaffTab extends StatelessWidget {
  const ManagerStaffTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManagerStaffScreen();
  }
}