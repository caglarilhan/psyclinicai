import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/role_service.dart';
import '../../services/homework_service.dart';
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

           // Bottom nav: max 6, sonuncu "Daha Fazla"
           final bool hasMore = allItems.length > 6;
           final int primaryCount = hasMore ? 5 : allItems.length;
           final List<BottomNavigationBarItem> visibleItems = [
             ...allItems.take(primaryCount),
             if (hasMore)
               const BottomNavigationBarItem(
                 icon: Icon(Icons.settings),
                 label: 'Ayarlar',
               ),
           ];

           final int currentNavIndex = hasMore
               ? (_selectedIndex < primaryCount ? _selectedIndex : primaryCount)
               : _selectedIndex;

           return Scaffold(
      appBar: AppBar(
        title: const Text('PsyClinic AI - Dashboard'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/landing');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
             body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
               currentIndex: currentNavIndex,
               onTap: (index) {
                 if (hasMore && index == primaryCount) {
                   // Açılır menü: kalan öğeler
                   showModalBottomSheet(
                     context: context,
                     builder: (ctx) {
                       final remaining = allItems.skip(primaryCount).toList();
                       return SafeArea(
                         child: Padding(
                           padding: const EdgeInsets.all(16),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 'Ayarlar ve Diğerleri',
                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                               ),
                               const SizedBox(height: 12),
                               Expanded(
                                 child: GridView.builder(
                                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                     crossAxisCount: 2,
                                     mainAxisSpacing: 12,
                                     crossAxisSpacing: 12,
                                     childAspectRatio: 3,
                                   ),
                                   itemCount: remaining.length,
                                   itemBuilder: (c, i) {
                                     final item = remaining[i];
                                     final targetIndex = primaryCount + i;
                                     return InkWell(
                                       onTap: () {
                                         Navigator.pop(c);
                                         setState(() => _selectedIndex = targetIndex);
                                       },
                                       child: Card(
                                         child: Padding(
                                           padding: const EdgeInsets.symmetric(horizontal: 12),
                                           child: Row(
                                             children: [
                                               item.icon,
                                               const SizedBox(width: 12),
                                               Expanded(child: Text(item.label ?? '')),
                                               const Icon(Icons.chevron_right),
                                             ],
                                           ),
                                         ),
                                       ),
                                     );
                                   },
                                 ),
                               ),
                             ],
                           ),
                         ),
                       );
                     },
                   );
                 } else {
                   setState(() => _selectedIndex = index);
                 }
               },
        selectedItemColor: colorScheme.primary,
               items: visibleItems,
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
      padding: const EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Welcome Card
          Card(
            color: Colors.purple[700],
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
                      Icon(Icons.psychology_alt, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
            Text(
                        'Hoş Geldiniz!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
                  const SizedBox(height: 12),
                  Text(
                    'AI destekli klinik yönetim sisteminize hoş geldiniz. Bugün 5 randevunuz ve 3 yeni hasta kaydınız var.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
          ),
        ),
      ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Stats
          Text(
            'Hızlı İstatistikler',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: roleStats
                .map((s) => _buildStatCard(
                      s['t'] as String,
                      s['v'].toString(),
                      s['i'] as IconData,
                      s['c'] as Color,
                      onTap: _routeForStat(context, s['t'] as String),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Hızlı İşlemler
          if (quickActions.isNotEmpty) ...[
            Text(
              'Hızlı İşlemler',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.purple[600],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: quickActions
                      .map((a) => ElevatedButton.icon(
                            onPressed: a['on'] as VoidCallback,
                            icon: Icon(a['i'] as IconData, size: 18),
                            label: Text(a['t'] as String),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple[800],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Son Aktiviteler
          Text(
            'Son Aktiviteler',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.purple[500],
            child: Column(
              children: [
                _buildActivityItem('Yeni hasta kaydı', 'Ahmet Yılmaz', '10:30'),
                const Divider(color: Colors.white30),
                _buildActivityItem('Randevu tamamlandı', 'Ayşe Demir', '09:15'),
                const Divider(color: Colors.white30),
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.person, color: Colors.purple[800]),
      ),
      title: Text(action, style: const TextStyle(color: Colors.white)),
      subtitle: Text(patient, style: const TextStyle(color: Colors.white70)),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.white70),
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