import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/offline_service.dart';
import 'screens/landing/landing_screen.dart';
       import 'screens/auth/login_screen.dart';
       import 'screens/auth/specialty_select_screen.dart';
       import 'services/role_service.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/settings/language_settings_screen.dart';
import 'screens/guide/diagnosis_guide_screen.dart';
import 'widgets/common/offline_indicator.dart';
import 'screens/settings/region_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
         final languageService = LanguageService();
         final offlineService = OfflineService();
         final roleService = RoleService();
  
         await languageService.initialize();
         await offlineService.initialize();
         await roleService.initialize();
  
  runApp(PsyClinicAIWebApp(
           languageService: languageService,
           offlineService: offlineService,
           roleService: roleService,
  ));
}

       class PsyClinicAIWebApp extends StatelessWidget {
  final LanguageService languageService;
  final OfflineService offlineService;
         final RoleService roleService;
  
         const PsyClinicAIWebApp({
    super.key,
    required this.languageService,
    required this.offlineService,
           required this.roleService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageService>.value(value: languageService),
               ChangeNotifierProvider<OfflineService>.value(value: offlineService),
               ChangeNotifierProvider<RoleService>.value(value: roleService),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: languageService.translate('app_title'),
            debugShowCheckedModeBanner: false,
                   theme: ThemeData(
                     useMaterial3: true,
                     colorScheme: ColorScheme.fromSeed(
                       seedColor: const Color(0xFF6D4AFF), // modern mor ton
                       brightness: Brightness.light,
                     ),
                     visualDensity: VisualDensity.adaptivePlatformDensity,
                   ),
            locale: languageService.currentLocale,
            supportedLocales: languageService.supportedLocales,
                   home: const LoginScreen(),
            routes: {
              '/landing': (context) => const LoginScreen(),
              '/login': (context) => const LoginScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/specialty-select': (context) => const SpecialtySelectScreen(),
              '/language-settings': (context) => const LanguageSettingsScreen(),
              '/diagnosis-guide': (context) => const DiagnosisGuideScreen(),
              '/region-settings': (context) => const RegionSettingsScreen(),
            },
            builder: (context, child) {
              return Column(
                children: [
                  const OfflineIndicator(),
                  Expanded(child: child!),
                ],
              );
            },
          );
        },
      ),
    );
  }
}