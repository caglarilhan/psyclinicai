import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/session/session_screen.dart';
import 'screens/diagnosis/diagnosis_screen.dart';
import 'screens/prescription/prescription_screen.dart';
import 'screens/flag/flag_screen.dart';
import 'screens/appointment/appointment_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/education/education_screen.dart';
import 'screens/therapy_simulation/therapy_simulation_screen.dart';
import 'screens/medication_guide/medication_guide_screen.dart';
import 'screens/ai_case_management/ai_case_management_screen.dart';
import 'screens/ai_appointment/ai_appointment_screen.dart';
import 'screens/ai_diagnosis/ai_diagnosis_screen.dart';
import 'screens/security/security_screen.dart';
import 'screens/finance/finance_dashboard_screen.dart';
import 'screens/supervisor/supervisor_dashboard_screen.dart';
import 'screens/client_management/client_management_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/offline_sync_service.dart';
import 'services/push_notification_service.dart';
import 'services/biometric_auth_service.dart';
import 'services/ai_orchestration_service.dart';
import 'services/ai_cache_service.dart';
import 'services/ai_prompt_service.dart';
import 'services/real_time_session_ai_service.dart'; // ADDED
import 'services/regional_config_service.dart';
import 'utils/theme.dart';
import 'services/consent_service.dart';
import 'widgets/ai_analytics/ai_analytics_dashboard_widget.dart';
import 'widgets/turkey_specific/turkey_psychiatry_dashboard_widget.dart';
import 'widgets/us/us_billing_dashboard_widget.dart';
import 'widgets/eu/eu_eprescription_dashboard_widget.dart';
import 'screens/consent/consent_compliance_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Servisleri başlat
  await _initializeServices();

  runApp(const PsyClinicAIApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize core services
    await ThemeService().initialize();
    await ThemeService().setPresetTheme('purple_blue');
    await OfflineSyncService().initialize();
    await PushNotificationService().initialize();
    await BiometricAuthService().initialize();
    
    // Initialize AI services
    await AIService().initialize();
    await AIDiagnosisService().initialize();
    await AICaseManagementService().initialize();
    await AIOrchestrationService().initialize();
    await RealTimeSessionAIService().initialize();
    
    // Initialize new services
    await ConsentService().initialize();
    
    print('All services initialized successfully');
  } catch (e) {
    print('Service initialization failed: $e');
  }
}

class PsyClinicAIApp extends StatelessWidget {
  const PsyClinicAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => OfflineSyncService()),
        ChangeNotifierProvider(create: (_) => RegionalConfigService.instance),
        ChangeNotifierProvider(create: (_) => ConsentService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'PsyClinic AI',
            debugShowCheckedModeBanner: false,
            theme: themeService.getLightTheme(),
            darkTheme: themeService.getDarkTheme(),
            themeMode: themeService.currentThemeMode,
            home: const DashboardScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/session': (context) => const SessionScreen(),
              '/diagnosis': (context) => const DiagnosisScreen(),
              '/prescription': (context) => const PrescriptionScreen(),
              '/flag': (context) => const FlagScreen(),
              '/appointment': (context) => const AppointmentScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/education': (context) => const EducationScreen(),
              '/therapy-simulation': (context) => const TherapySimulationScreen(),
              '/medication-guide': (context) => const MedicationGuideScreen(),
                                   '/ai-case-management': (context) => const AICaseManagementScreen(),
                     '/ai-appointment': (context) => const AIAppointmentScreen(),
                     '/ai-diagnosis': (context) => const AIDiagnosisScreen(
                       clientId: 'demo_client_001',
                       therapistId: 'demo_therapist_001',
                     ),
                     '/security': (context) => const SecurityScreen(),
              '/finance': (context) => const FinanceDashboardScreen(),
              '/supervisor': (context) => const SupervisorDashboardScreen(),
              '/client-management': (context) => const ClientManagementScreen(),
              '/consent-compliance': (context) => const ConsentComplianceScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.data == true) {
          return const DashboardScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'PsyClinic AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'AI Destekli Klinik Yönetim Sistemi',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
