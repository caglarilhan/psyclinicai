import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/two_factor_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/session/session_screen.dart';
import 'screens/diagnosis/diagnosis_screen.dart';
import 'screens/prescription/prescription_screen.dart';
import 'screens/prescription/smart_prescription_screen.dart';
import 'screens/flag/flag_screen.dart';
import 'screens/appointment/appointment_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/education/education_screen.dart';
import 'screens/therapy_simulation/therapy_simulation_screen.dart';
import 'screens/medication_guide/medication_guide_screen.dart';

import 'screens/ai_appointment/ai_appointment_screen.dart';
// import 'screens/ai_diagnosis/ai_diagnosis_screen.dart';
import 'screens/security/security_screen.dart';
import 'screens/finance/finance_dashboard_screen.dart';
import 'screens/supervisor/supervisor_dashboard_screen.dart';
import 'screens/client_management/client_management_screen.dart';
import 'screens/crm/crm_dashboard_screen.dart';
import 'screens/white_label/white_label_dashboard_screen.dart';
import 'screens/appointment/appointment_calendar_screen.dart';
import 'screens/appointment/pending_appointments_screen.dart';
import 'services/notification_service.dart';
import 'widgets/teletherapy/webrtc_session_widget.dart';
import 'screens/session/session_management_screen.dart';
import 'screens/case/case_management_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/offline_sync_service.dart';
import 'config/white_label_config.dart';
import 'services/push_notification_service.dart';
import 'services/biometric_auth_service.dart';
import 'services/ai_service.dart';
import 'services/ai_orchestration_service.dart';
import 'services/real_time_session_ai_service.dart';
import 'services/regional_config_service.dart';
// import 'services/diagnosis_service.dart';
import 'services/medication_service.dart';
import 'services/prescription_ai_service.dart';
import 'services/telehealth_service.dart';
import 'services/advanced_ai_service.dart';
import 'services/consent_service.dart';
// import 'services/clinical_decision_support_service.dart';
import 'services/performance_optimization_service.dart';
import 'services/documentation_service.dart';
// import 'services/ai_diagnosis_service.dart';
import 'services/ai_case_management_service.dart';
import 'screens/consent/consent_compliance_screen.dart';
// import 'screens/sprint3/sprint3_test_screen.dart';
import 'services/therapy_note_service.dart';
import 'services/treatment_plan_service.dart';
import 'services/homework_service.dart';
import 'services/homework_template_service.dart';
import 'services/ai_homework_generator.dart';
import 'services/drug_database_service.dart';
import 'services/drug_image_recognition_service.dart';
import 'services/ai_drug_interaction_service.dart';
import 'services/pdf_analysis_service.dart';
import 'services/real_pdf_reader_service.dart';
import 'services/llm_analysis_service.dart';
import 'services/titck_service.dart';
import 'services/ema_service.dart';
import 'services/fda_service.dart';
import 'services/assessment_scoring_service.dart';
import 'screens/therapist/therapy_note_editor_screen.dart';
import 'screens/therapist/treatment_plan_screen.dart';
import 'screens/therapist/homework_screen.dart';
import 'screens/therapist/assessments_screen.dart';
// Legal/Alert sistemleri için import'lar
import 'services/flag_system_service.dart';
import 'services/legal_policy_service.dart';
import 'services/alerting_service.dart';
import 'services/legal_compliance_orchestrator.dart';
import 'services/crisis_communication_service.dart';
// Alert Konsolu ekranı
import 'screens/alert/alert_console_screen.dart';
// Masaüstü optimizasyonu için import'lar
import 'services/keyboard_shortcuts_service.dart';
import 'utils/desktop_theme.dart';
import 'widgets/desktop/desktop_layout.dart';
// Yeni iyileştirmeler için import'lar
import 'utils/theme.dart';
import 'services/animation_service.dart';
import 'services/notification_service.dart';
import 'services/global_search_service.dart';
import 'services/data_export_service.dart';
import 'services/performance_service.dart';
import 'widgets/theme_switcher.dart';
// 2FA için import
import 'services/two_factor_auth_service.dart';
import 'widgets/two_factor_auth_widgets.dart';
// Voice-to-text için import
import 'services/voice_to_text_service.dart';
import 'widgets/voice_to_text_widgets.dart';
// Real-time dashboard için import
import 'services/realtime_dashboard_service.dart';
import 'widgets/realtime_dashboard_widgets.dart';
// API & Integration için import
import 'services/api_service.dart';
// Team collaboration için import
import 'services/team_collaboration_service.dart';
import 'services/ai_chatbot_service.dart';
import 'widgets/ai_chatbot_widgets.dart';
import 'services/push_notification_service.dart';
import 'widgets/push_notification_widgets.dart';
import 'services/workflow_automation_service.dart';
import 'widgets/workflow_automation_widgets.dart';
import 'services/multi_language_service.dart';
import 'widgets/multi_language_widgets.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/auth/specialty_select_screen.dart';
import 'services/role_service.dart';
import 'services/patient_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await _initializeServices();
  runApp(const PsyClinicAIApp());
}

Future<void> _initializeServices() async {
  try {
    // Locale/Intl
    await initializeDateFormatting('tr_TR', null);
    await initializeDateFormatting('tr', null);
    // Initialize core services
    await ThemeService().initialize();
    await ThemeService().setPresetTheme('purple_blue');
    await OfflineSyncService().initialize();
    await PrescriptionAIService().initialize();
    await PushNotificationService().initialize();
    
    // Yeni servisleri başlat
    await AppTheme.loadThemeMode();
    await NotificationService().initialize();
    GlobalSearchService();
    DataExportService();
    PerformanceService();
    
    // 2FA servisini başlat
    await TwoFactorAuthService().load2FASettings();
    
    // Voice-to-text servisini başlat
    await VoiceToTextService().loadRecordingSessions();
    
    // Real-time dashboard servisini başlat
    await RealtimeDashboardService().initialize();
    
    // API servisini başlat
    await ApiService().initialize();
    
                    // Team collaboration servisini başlat
                await TeamCollaborationService().initialize();
                // AI Chatbot servisini başlat
                await AIChatbotService().initialize();
                // Push Notification servisini başlat
                await PushNotificationService().initialize();
                // Workflow Automation servisini başlat
                await WorkflowAutomationService().initialize();
                // Multi-language servisini başlat
                await MultiLanguageService().initialize();
    await BiometricAuthService().initialize();
    await PatientService().seedDemoDocs();
    
    // Initialize homework services
    HomeworkTemplateService().initialize();
    AIHomeworkGenerator().initialize();
    
    // Initialize drug services
    DrugDatabaseService().initialize();
    DrugImageRecognitionService().initialize();
    AIDrugInteractionService().initialize();
    PDFAnalysisService().initialize();
    RealPDFReaderService().initialize();
    LLMAnalysisService().initialize();
    TITCKService().initialize();
    EMAService().initialize();
    FDAService().initialize();
    
    // Initialize AI services
    await AIService().initialize();
    
    // Initialize desktop services
    KeyboardShortcutsService().initialize();
          // await AIDiagnosisService().initialize();
    await AICaseManagementService().initialize();
    await AIOrchestrationService().initialize();
    await RealTimeSessionAIService().initialize();
    
    // Initialize psychiatric services
          // await DiagnosisService().initialize();
    await MedicationService().initialize();
    
    // Initialize telehealth & advanced AI services
    await TelehealthService().initialize();
    await AdvancedAIService().initialize();
    
    // Initialize new services
    // await ConsentService().initialize(); // Geçici olarak devre dışı
    
    // Initialize Sprint 3 services
          // await ClinicalDecisionSupportService().initialize();
    await PerformanceOptimizationService().initialize();
    await DocumentationService().initialize();
    
    // Initialize therapist services
    await TherapyNoteService().initialize();
    await TreatmentPlanService().initialize();
    await HomeworkService().initialize();
    // AssessmentScoringService has only pure methods; no init needed

    // Legal/Alert sistemleri için initialization
    await FlagSystemService().initialize();
    await LegalPolicyService().initialize();
    await CrisisCommunicationService().initialize();
    await AlertingService().initialize();
    await LegalComplianceOrchestrator().initialize();

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
        ChangeNotifierProvider.value(value: ThemeService()),
        ChangeNotifierProvider(create: (_) => RoleService()),
        ChangeNotifierProvider(create: (_) => PatientService()),
        // ChangeNotifierProvider(create: (_) => OfflineSyncService()),
        ChangeNotifierProvider(create: (_) => PrescriptionAIService()),
        ChangeNotifierProvider(create: (_) => RegionalConfigService.instance),
        // ChangeNotifierProvider(create: (_) => ConsentService()), // Geçici olarak devre dışı
        // ChangeNotifierProvider(create: (_) => DiagnosisService()),
        ChangeNotifierProvider(create: (_) => MedicationService()),
        ChangeNotifierProvider(create: (_) => TelehealthService()),
        ChangeNotifierProvider(create: (_) => AdvancedAIService()),
        // ChangeNotifierProvider(create: (_) => ClinicalDecisionSupportService()),
        ChangeNotifierProvider(create: (_) => PerformanceOptimizationService()),
        ChangeNotifierProvider(create: (_) => DocumentationService()),
        ChangeNotifierProvider(create: (_) => TherapyNoteService()),
        // ChangeNotifierProvider(create: (_) => TreatmentPlanService()),
        ChangeNotifierProvider(create: (_) => HomeworkService()),
        ChangeNotifierProvider(create: (_) => HomeworkTemplateService()),
        ChangeNotifierProvider(create: (_) => AIHomeworkGenerator()),
        ChangeNotifierProvider(create: (_) => DrugDatabaseService()),
        ChangeNotifierProvider(create: (_) => DrugImageRecognitionService()),
        ChangeNotifierProvider(create: (_) => AIDrugInteractionService()),
        ChangeNotifierProvider(create: (_) => PDFAnalysisService()),
        ChangeNotifierProvider(create: (_) => RealPDFReaderService()),
        ChangeNotifierProvider(create: (_) => LLMAnalysisService()),
        ChangeNotifierProvider(create: (_) => TITCKService()),
        ChangeNotifierProvider(create: (_) => EMAService()),
        ChangeNotifierProvider(create: (_) => FDAService()),
        ChangeNotifierProvider(create: (_) => AssessmentScoringService()),
        // Legal/Alert sistemleri için provider'lar
        ChangeNotifierProvider(create: (_) => FlagSystemService()),
        ChangeNotifierProvider(create: (_) => CrisisCommunicationService()),
        ChangeNotifierProvider(create: (_) => LegalPolicyService()),
        ChangeNotifierProvider(create: (_) => AlertingService()),
        ChangeNotifierProvider(create: (_) => LegalComplianceOrchestrator()),
        // Masaüstü servisleri için provider'lar
        ChangeNotifierProvider(create: (_) => KeyboardShortcutsService()),
        ChangeNotifierProvider(create: (_) => WhiteLabelThemeProvider()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Consumer<WhiteLabelThemeProvider>(
            builder: (context, whiteLabelProvider, child) {
              return MaterialApp(
                title: 'PsyClinic AI',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: AppTheme.themeMode,
                home: const AuthWrapper(),
                routes: {
                  '/landing': (context) => const LoginScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/specialty-select': (context) => const SpecialtySelectScreen(),
                  '/2fa': (context) => const TwoFactorScreen(),
                  '/dashboard': (context) => const DashboardScreen(),
                  '/session': (context) => const SessionScreen(
                    sessionId: 'demo_session_001',
                    clientId: 'demo_client_001',
                    clientName: 'Demo Client',
                  ),
                  '/diagnosis': (context) => const DiagnosisScreen(),
                  '/prescription': (context) => const PrescriptionScreen(),
                  '/smart-prescription': (context) => const SmartPrescriptionScreen(),
                  '/flag': (context) => const FlagScreen(),
                  '/appointment': (context) => const AppointmentScreen(),
                  '/profile': (context) => const ProfileScreen(),
                  '/education': (context) => const EducationScreen(),
                  '/therapy-simulation': (context) => const TherapySimulationScreen(),
                  '/medication-guide': (context) => const MedicationGuideScreen(),
 
                  '/ai-appointment': (context) => const AIAppointmentScreen(),
                  // '/ai-diagnosis': (context) => const AIDiagnosisScreen(
                  //   clientId: 'demo_client_001',
                  //   therapistId: 'demo_therapist_001',
                  // ),
                  '/security': (context) => const SecurityScreen(),
                  '/finance': (context) => const FinanceDashboardScreen(),
                  '/supervisor': (context) => const SupervisorDashboardScreen(),
                  '/client-management': (context) => const ClientManagementScreen(),
                  '/consent-compliance': (context) => const ConsentComplianceScreen(),
                  // '/sprint3-test': (context) => const Sprint3TestScreen(),
                  '/therapy-notes': (context) => const TherapyNoteEditorScreen(),
                  '/treatment-plan': (context) => const TreatmentPlanScreen(),
                  '/homework': (context) => const HomeworkScreen(),
                  '/assessments': (context) => const AssessmentsScreen(),
                  '/alert-console': (context) => const AlertConsoleScreen(),
                  '/crm': (context) => const CRMDashboardScreen(),
                  '/white-label': (context) => const WhiteLabelDashboardScreen(),
                  '/appointment-calendar': (context) => const AppointmentCalendarScreen(),
                  '/session-management': (context) => const SessionManagementScreen(),
                  '/case-management': (context) => const CaseManagementScreen(),
                  '/pending-appointments': (context) => const PendingAppointmentsScreen(),
                  '/webrtc-demo': (context) => const WebRTCSimpleSession(),
                },
                builder: (context, child) {
                  // Bildirim servisini erken başlat
                  NotificationService().initialize();
                  return child!;
                },
              );
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadInitialState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final isAuthed = snapshot.data?['authed'] as bool? ?? false;
        final seenLanding = snapshot.data?['seenLanding'] as bool? ?? false;

        if (isAuthed) {
          return const DashboardScreen();
        }

        if (!seenLanding) {
          return const LandingScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

Future<Map<String, dynamic>> _loadInitialState() async {
  final authed = await AuthService().isAuthenticated();
  final prefs = await SharedPreferences.getInstance();
  final seenLanding = prefs.getBool('seen_landing') ?? false;
  return {'authed': authed, 'seenLanding': seenLanding};
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
