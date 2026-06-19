import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/models/superbill_prefill.dart';
import 'package:psyclinicai/screens/ai/ai_diagnosis_screen.dart';
import 'package:psyclinicai/screens/ai/rag_console_screen.dart';
import 'package:psyclinicai/screens/ai_chatbot/ai_chatbot_screen.dart';
import 'package:psyclinicai/screens/appointments/appointments_screen.dart';
import 'package:psyclinicai/screens/assessments/assessment_screen.dart';
import 'package:psyclinicai/screens/assessments/assessment_result_screen.dart';
import 'package:psyclinicai/screens/assessments/clinical_scale_screen.dart';
import 'package:psyclinicai/services/assessments/assessment_severity_engine.dart';
import 'package:psyclinicai/screens/auth/login_screen.dart';
import 'package:psyclinicai/screens/auth/mfa_setup_screen.dart';
import 'package:psyclinicai/screens/settings/account_deletion_screen.dart';
import 'package:psyclinicai/screens/settings/clinician_profile_screen.dart';
import 'package:psyclinicai/screens/settings/data_export_screen.dart';
import 'package:psyclinicai/screens/auth/password_reset_screen.dart';
import 'package:psyclinicai/screens/auth/telehealth_setup_screen.dart';
import 'package:psyclinicai/screens/billing/preauth_screen.dart';
import 'package:psyclinicai/screens/billing/insurance_claim_board_screen.dart';
import 'package:psyclinicai/screens/inbox/inbox_screen.dart';
import 'package:psyclinicai/screens/settings/ehr_sync_console_screen.dart';
import 'package:psyclinicai/screens/settings/payment_setup_screen.dart';
import 'package:psyclinicai/screens/settings/region_settings_screen.dart';
import 'package:psyclinicai/screens/patients/consent_center_screen.dart';
import 'package:psyclinicai/screens/patients/intake_form_screen.dart';
import 'package:psyclinicai/screens/patients/patient_chart_screen.dart';
import 'package:psyclinicai/screens/billing/superbill_screen.dart';
import 'package:psyclinicai/screens/caseload/caseload_screen.dart';
import 'package:psyclinicai/screens/dashboard/dashboard_screen.dart';
import 'package:psyclinicai/screens/e_prescription/e_prescription_screen.dart';
import 'package:psyclinicai/screens/feature_system/feature_system_screen.dart';
import 'package:psyclinicai/screens/group_session/group_session_screen.dart';
import 'package:psyclinicai/screens/landing/beta_waitlist_screen.dart';
import 'package:psyclinicai/screens/landing/landing_screen.dart';
import 'package:psyclinicai/screens/mood_tracking/mood_tracking_screen.dart';
import 'package:psyclinicai/screens/onboarding/onboarding_screen.dart';
import 'package:psyclinicai/screens/outcomes/outcomes_dashboard_screen.dart';
import 'package:psyclinicai/screens/patients/patient_detail_screen.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart';
import 'package:psyclinicai/screens/safety_plan/safety_plan_screen.dart';
import 'package:psyclinicai/screens/session/session_management_screen.dart';
import 'package:psyclinicai/screens/session/session_screen.dart';
import 'package:psyclinicai/screens/settings/api_keys_screen.dart';
import 'package:psyclinicai/screens/settings/audit_log_screen.dart';
import 'package:psyclinicai/screens/static/baa_page.dart';
import 'package:psyclinicai/screens/patient_portal/portal_landing_screen.dart';
import 'package:psyclinicai/screens/supervision/supervision_queue_screen.dart';
import 'package:psyclinicai/screens/static/dpa_page.dart';
import 'package:psyclinicai/screens/trust/incident_response_screen.dart';
import 'package:psyclinicai/screens/trust/security_controls_screen.dart';
import 'package:psyclinicai/screens/trust/subprocessors_screen.dart';
import 'package:psyclinicai/screens/trust/trust_center_screen.dart';
import 'package:psyclinicai/screens/settings/settings_screen.dart';
import 'package:psyclinicai/screens/static/about_page.dart';
import 'package:psyclinicai/screens/static/changelog_page.dart';
import 'package:psyclinicai/screens/static/roadmap_page.dart';
import 'package:psyclinicai/screens/static/compare_page.dart';
import 'package:psyclinicai/screens/static/faq_page.dart';
import 'package:psyclinicai/screens/static/pricing_page.dart';
import 'package:psyclinicai/screens/static/contact_page.dart';
import 'package:psyclinicai/screens/static/not_found_page.dart';
import 'package:psyclinicai/screens/static/press_page.dart';
import 'package:psyclinicai/screens/static/privacy_page.dart';
import 'package:psyclinicai/screens/static/security_page.dart';
import 'package:psyclinicai/screens/static/status_page.dart';
import 'package:psyclinicai/screens/splash/splash_screen.dart';
import 'package:psyclinicai/screens/static/tos_page.dart';
import 'package:psyclinicai/screens/treatment_plan/treatment_plan_screen.dart';
import 'package:psyclinicai/services/assessments/clinical_scales.dart';
import 'package:psyclinicai/services/data/appearance_preferences.dart';
import 'package:psyclinicai/services/data/auth_service.dart' as fb_auth;
import 'package:psyclinicai/services/data/firebase_bootstrap.dart';
import 'package:psyclinicai/services/ai/rag_service.dart';
import 'package:psyclinicai/services/billing/subscription_service.dart';
import 'package:psyclinicai/services/data/telemetry_service.dart';
import 'package:psyclinicai/services/patient_service.dart';
import 'package:psyclinicai/services/region_service.dart';
import 'package:psyclinicai/services/role_service.dart';
import 'package:psyclinicai/services/theme_service.dart';
import 'package:psyclinicai/l10n/app_localizations.dart';
import 'package:psyclinicai/theme/psy_theme.dart';
import 'package:psyclinicai/utils/document_title.dart';

void main() {
  // Route every uncaught error — framework and async — through the telemetry
  // façade (no-op in debug, Sentry once a DSN is set). See TelemetryService.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        TelemetryService.instance.captureError(
          details.exception,
          details.stack,
          hint: 'flutter',
        );
      };
      // Async errors escaping the framework (platform channels, Timer
      // callbacks, etc.) bypass FlutterError.onError. Wire the platform
      // dispatcher so HIPAA telemetry never misses an uncaught throw.
      WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
        TelemetryService.instance.captureError(error, stack, hint: 'platform');
        return true;
      };
      await _initializeServices();
      runApp(const PsyClinicAIApp());
    },
    (error, stack) {
      TelemetryService.instance.captureError(error, stack, hint: 'zone');
    },
  );
}

Future<void> _initializeServices() async {
  try {
    await ThemeService.initialize();
    await ThemeService.setPresetTheme('purple_blue');
    await PsyFirebase.bootstrap();
    await TelemetryService.instance.initialize();
    debugPrint('Services initialized (firebase: ${PsyFirebase.isReady})');
  } catch (e, stack) {
    debugPrint('Error initializing services: $e');
    await TelemetryService.instance.captureError(e, stack, hint: 'bootstrap');
  }
}

class PsyClinicAIApp extends StatelessWidget {
  const PsyClinicAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<fb_auth.FirebaseAuthService>.value(
          value: fb_auth.FirebaseAuthService.instance,
        ),
        ChangeNotifierProvider(create: (_) => RoleService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => PatientService()),
        ChangeNotifierProvider(create: (_) => RegionService()),
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        Provider<RagService>(
          create: (_) => RagService.fromConfig(),
          dispose: (_, svc) => svc.dispose(),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return AnimatedBuilder(
            animation: AppearancePreferences.instance,
            builder: (ctx, _) => MaterialApp(
              title: 'PsyClinicAI',
              theme: PsyTheme.light(),
              darkTheme: PsyTheme.dark(),
              themeMode: AppearancePreferences.instance.themeMode,
              debugShowCheckedModeBanner: false,
              navigatorObservers: [_PsyTitleObserver()],
              // B17 (Sprint 8): EN + TR ship today. Remaining EU locales
              // land once validated translations clear PHQ-9 / GAD-7 /
              // C-SSRS review.
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              initialRoute: '/',
              routes: {
                '/': (context) => const SplashScreen(),
                '/ai/rag': (context) => const RagConsoleScreen(),
                '/landing': (context) => const LandingScreen(),
                '/beta': (context) => const BetaWaitlistScreen(),
                '/login': (context) => const LoginScreen(),
                '/auth/password_reset': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments as String?;
                  return PasswordResetScreen(prefilledEmail: args);
                },
                '/settings/mfa': (context) => const MfaSetupScreen(),
                '/settings/profile': (context) =>
                    const ClinicianProfileScreen(),
                '/settings/data_export': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments as String?;
                  return DataExportScreen(patientId: args ?? 'demo-1');
                },
                '/settings/account_deletion': (context) =>
                    const AccountDeletionScreen(),
                '/settings/telehealth': (context) =>
                    const TelehealthSetupScreen(),
                '/settings/payments': (context) => const PaymentSetupScreen(),
                '/settings/region': (context) => const RegionSettingsScreen(),
                '/settings/ehr': (context) => const EhrSyncConsoleScreen(),
                '/billing/claims': (context) =>
                    const InsuranceClaimBoardScreen(),
                '/inbox': (context) => const InboxScreen(),
                '/billing/preauth': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments as String?;
                  return PreAuthScreen(patientId: args ?? 'demo-1');
                },
                '/patients/consents': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return ConsentCenterScreen(
                    patientId: args?.id ?? 'demo-1',
                    patientName: args?.name ?? 'John Demo',
                  );
                },
                '/patients/chart': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return PatientChartScreen(
                    args:
                        args ??
                        const PatientDetailArgs(
                          id: 'demo-1',
                          name: 'John Demo',
                        ),
                  );
                },
                '/patients/intake': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return IntakeFormScreen(
                    args:
                        args ??
                        const PatientDetailArgs(
                          id: 'demo-1',
                          name: 'John Demo',
                        ),
                  );
                },
                '/dashboard': (context) => const DashboardScreen(),
                '/feature_system': (context) => const FeatureSystemScreen(),
                '/session': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return SessionScreen(
                    sessionId:
                        'session-${DateTime.now().millisecondsSinceEpoch}',
                    clientId: args?.id ?? 'demo-1',
                    clientName: args?.name ?? 'John Demo',
                  );
                },
                '/session_management': (context) =>
                    const SessionManagementScreen(),
                '/e_prescription': (context) => const EPrescriptionScreen(),
                '/ai_chatbot': (context) => const AIChatbotScreen(),
                '/mood_tracking': (context) => const MoodTrackingScreen(),
                '/ai_diagnosis': (context) => const AIDiagnosisScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/settings/api_keys': (context) => const ApiKeysScreen(),
                '/settings/audit_log': (context) => const AuditLogScreen(),
                '/dpa': (context) => const DpaPage(),
                '/baa': (context) => const BaaPage(),
                '/trust': (context) => const TrustCenterScreen(),
                '/trust/subprocessors': (context) =>
                    const SubprocessorsScreen(),
                '/trust/security_controls': (context) =>
                    const SecurityControlsScreen(),
                '/trust/incident_response': (context) =>
                    const IncidentResponseScreen(),
                '/supervision/queue': (context) =>
                    const SupervisionQueueScreen(),
                '/group_session': (context) => const GroupSessionScreen(),
                '/portal': (context) => const PortalLandingScreen(),
                '/superbill': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments;
                  return SuperbillScreen(
                    prefill: args is SuperbillPrefill ? args : null,
                  );
                },
                '/assessments/phq9': (context) => const AssessmentScreen(
                  type: AssessmentType.phq9,
                  patientName: 'John Demo',
                ),
                '/assessments/result': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as AssessmentResultScreenArgs?;
                  return AssessmentResultScreen(
                    args:
                        args ??
                        const AssessmentResultScreenArgs(
                          instrument: AssessmentInstrument.phq9,
                          score: 14,
                          previousScore: 17,
                        ),
                  );
                },
                '/assessments/gad7': (context) => const AssessmentScreen(
                  type: AssessmentType.gad7,
                  patientName: 'John Demo',
                ),
                '/scales/cssrs': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return ClinicalScaleScreen(
                    scale: ClinicalScales.cssrs,
                    patientId: args?.id ?? 'demo-1',
                    patientName: args?.name ?? 'John Demo',
                  );
                },
                '/scales/pcl5': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return ClinicalScaleScreen(
                    scale: ClinicalScales.pcl5,
                    patientId: args?.id ?? 'demo-1',
                    patientName: args?.name ?? 'John Demo',
                  );
                },
                '/scales/audit': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return ClinicalScaleScreen(
                    scale: ClinicalScales.audit,
                    patientId: args?.id ?? 'demo-1',
                    patientName: args?.name ?? 'John Demo',
                  );
                },
                '/security': (context) => const SecurityPage(),
                '/about': (context) => const AboutPage(),
                '/pricing': (context) => const PricingPage(),
                '/compare': (context) => const ComparePage(),
                '/faq': (context) => const FaqPage(),
                '/changelog': (context) => const ChangelogPage(),
                '/roadmap': (context) => const RoadmapPage(),
                '/status': (context) => const StatusPage(),
                '/privacy': (context) => const PrivacyPage(),
                '/tos': (context) => const TosPage(),
                '/contact': (context) => const ContactPage(),
                '/press': (context) => const PressPage(),
                '/patients': (context) => const PatientListScreen(),
                '/patient/detail': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return PatientDetailScreen(
                    args:
                        args ??
                        const PatientDetailArgs(
                          id: 'demo-1',
                          name: 'John Demo',
                        ),
                  );
                },
                '/outcomes': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return OutcomesDashboardScreen(args: args);
                },
                '/onboarding': (context) => const OnboardingScreen(),
                '/appointments': (context) => const AppointmentsScreen(),
                '/caseload': (context) => const CaseloadScreen(),
                '/treatment_plan': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return TreatmentPlanScreen(
                    args:
                        args ??
                        const PatientDetailArgs(
                          id: 'demo-1',
                          name: 'John Demo',
                        ),
                  );
                },
                '/safety_plan': (context) {
                  final args =
                      ModalRoute.of(context)?.settings.arguments
                          as PatientDetailArgs?;
                  return SafetyPlanScreen(
                    args:
                        args ??
                        const PatientDetailArgs(
                          id: 'demo-1',
                          name: 'John Demo',
                        ),
                  );
                },
              },
              onUnknownRoute: (settings) => MaterialPageRoute(
                builder: (_) => NotFoundPage(path: settings.name),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Updates the browser tab title each time the top route changes (web).
/// On mobile/desktop the underlying setter is a no-op via conditional
/// import, so this observer is safe to register everywhere.
class _PsyTitleObserver extends NavigatorObserver {
  void _apply(Route<dynamic>? route) {
    if (route == null) return;
    setDocumentTitle(titleForRoute(route.settings.name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _apply(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _apply(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _apply(previousRoute);
}
