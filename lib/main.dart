import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyclinicai/services/theme_service.dart';
import 'package:psyclinicai/services/auth_service.dart';
import 'package:psyclinicai/services/role_service.dart';
import 'package:psyclinicai/services/patient_service.dart';
import 'package:psyclinicai/services/region_service.dart';
import 'package:psyclinicai/services/data/auth_service.dart' as fb_auth;
import 'package:psyclinicai/services/data/firebase_bootstrap.dart';
import 'package:psyclinicai/services/data/telemetry_service.dart';
import 'package:psyclinicai/theme/psy_theme.dart';
import 'package:psyclinicai/utils/document_title.dart';
import 'package:psyclinicai/screens/landing/landing_screen.dart';
import 'package:psyclinicai/screens/auth/login_screen.dart';
import 'package:psyclinicai/screens/dashboard/dashboard_screen.dart';
import 'package:psyclinicai/screens/feature_system/feature_system_screen.dart';
import 'package:psyclinicai/screens/session/session_screen.dart';
import 'package:psyclinicai/screens/session/session_management_screen.dart';
import 'package:psyclinicai/screens/e_prescription/e_prescription_screen.dart';
import 'package:psyclinicai/screens/ai_chatbot/ai_chatbot_screen.dart';
import 'package:psyclinicai/screens/mood_tracking/mood_tracking_screen.dart';
import 'package:psyclinicai/screens/ai/ai_diagnosis_screen.dart';
import 'package:psyclinicai/screens/settings/api_keys_screen.dart';
import 'package:psyclinicai/screens/settings/settings_screen.dart';
import 'package:psyclinicai/screens/billing/superbill_screen.dart';
import 'package:psyclinicai/screens/assessments/assessment_screen.dart';
import 'package:psyclinicai/screens/static/security_page.dart';
import 'package:psyclinicai/screens/static/about_page.dart';
import 'package:psyclinicai/screens/static/changelog_page.dart';
import 'package:psyclinicai/screens/static/status_page.dart';
import 'package:psyclinicai/screens/static/privacy_page.dart';
import 'package:psyclinicai/screens/static/tos_page.dart';
import 'package:psyclinicai/screens/static/contact_page.dart';
import 'package:psyclinicai/screens/static/press_page.dart';
import 'package:psyclinicai/screens/static/not_found_page.dart';
import 'package:psyclinicai/screens/patients/patient_list_screen.dart';
import 'package:psyclinicai/screens/patients/patient_detail_screen.dart';
import 'package:psyclinicai/screens/outcomes/outcomes_dashboard_screen.dart';
import 'package:psyclinicai/screens/onboarding/onboarding_screen.dart';
import 'package:psyclinicai/screens/appointments/appointments_screen.dart';

void main() {
  // Route every uncaught error — framework and async — through the telemetry
  // façade (no-op in debug, Sentry once a DSN is set). See TelemetryService.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      TelemetryService.instance
          .captureError(details.exception, details.stack, hint: 'flutter');
    };
    await _initializeServices();
    runApp(const PsyClinicAIApp());
  }, (error, stack) {
    TelemetryService.instance.captureError(error, stack, hint: 'zone');
  });
}

Future<void> _initializeServices() async {
  try {
    await ThemeService.initialize();
    await ThemeService.setPresetTheme('purple_blue');
    await PsyFirebase.bootstrap();
    await TelemetryService.instance.initialize();
    debugPrint(
        'Services initialized (firebase: ${PsyFirebase.isReady})');
  } catch (e, stack) {
    debugPrint('Error initializing services: $e');
    await TelemetryService.instance
        .captureError(e, stack, hint: 'bootstrap');
  }
}

class PsyClinicAIApp extends StatelessWidget {
  const PsyClinicAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider<fb_auth.FirebaseAuthService>.value(
          value: fb_auth.FirebaseAuthService.instance,
        ),
        ChangeNotifierProvider(create: (_) => RoleService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => PatientService()),
        ChangeNotifierProvider(create: (_) => RegionService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'PsyClinicAI',
            theme: PsyTheme.light(),
            darkTheme: PsyTheme.dark(),
            themeMode: ThemeMode.light,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [_PsyTitleObserver()],
            initialRoute: '/landing',
            routes: {
              '/landing': (context) => const LandingScreen(),
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/feature_system': (context) => const FeatureSystemScreen(),
              '/session': (context) => const SessionScreen(
                    sessionId: 'demo-session-001',
                    clientId: 'demo-client-001',
                    clientName: 'John Demo',
                  ),
              '/session_management': (context) => const SessionManagementScreen(),
              '/e_prescription': (context) => const EPrescriptionScreen(),
              '/ai_chatbot': (context) => const AIChatbotScreen(),
              '/mood_tracking': (context) => const MoodTrackingScreen(),
              '/ai_diagnosis': (context) => const AIDiagnosisScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/settings/api_keys': (context) => const ApiKeysScreen(),
              '/superbill': (context) => const SuperbillScreen(),
              '/assessments/phq9': (context) => const AssessmentScreen(
                    type: AssessmentType.phq9,
                    patientName: 'John Demo',
                  ),
              '/assessments/gad7': (context) => const AssessmentScreen(
                    type: AssessmentType.gad7,
                    patientName: 'John Demo',
                  ),
              '/security': (context) => const SecurityPage(),
              '/about': (context) => const AboutPage(),
              '/changelog': (context) => const ChangelogPage(),
              '/status': (context) => const StatusPage(),
              '/privacy': (context) => const PrivacyPage(),
              '/tos': (context) => const TosPage(),
              '/contact': (context) => const ContactPage(),
              '/press': (context) => const PressPage(),
              '/patients': (context) => const PatientListScreen(),
              '/patient/detail': (context) {
                final args = ModalRoute.of(context)?.settings.arguments
                    as PatientDetailArgs?;
                return PatientDetailScreen(
                  args: args ??
                      const PatientDetailArgs(
                          id: 'demo-1', name: 'John Demo'),
                );
              },
              '/outcomes': (context) {
                final args = ModalRoute.of(context)?.settings.arguments
                    as PatientDetailArgs?;
                return OutcomesDashboardScreen(args: args);
              },
              '/onboarding': (context) => const OnboardingScreen(),
              '/appointments': (context) => const AppointmentsScreen(),
            },
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => NotFoundPage(path: settings.name),
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