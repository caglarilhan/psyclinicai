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
    // Offline sync service
    await OfflineSyncService().initialize();
    
    // Push notification service
    await PushNotificationService().initialize();
    
    // Biometric auth service
    await BiometricAuthService().initialize();
    
    // Theme service
    await ThemeService().initialize();
    // Mor-Mavi ana tema + kırmızı vurgu preset'i uygula
    await ThemeService().setPresetTheme('purple_blue');
    
    // AI services
    await AIOrchestrationService().initialize();
    await AICacheService().initialize();
    
    // Session AI service
    await RealTimeSessionAIService().initialize();
    
    print('All services initialized successfully');
  } catch (e) {
    print('Error initializing services: $e');
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
        ChangeNotifierProvider<RegionalConfigService>(create: (_) => RegionalConfigService.instance),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'PsyClinic AI',
            debugShowCheckedModeBanner: false,
            theme: themeService.getLightTheme(),
            darkTheme: themeService.getDarkTheme(),
            themeMode: themeService.currentThemeMode,
            home: const AuthWrapper(),
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
