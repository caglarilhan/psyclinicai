// Web-safe document.title setter — conditional import keeps the mobile
// build clean (no-op) while the web build sets the browser tab title.

import 'document_title_stub.dart'
    if (dart.library.html) 'document_title_web.dart' as impl;

/// Update the browser tab title. No-op on mobile/desktop platforms.
void setDocumentTitle(String title) => impl.setDocumentTitle(title);

/// Map a Flutter route name to a readable, SEO-friendly page title.
String titleForRoute(String? routeName) {
  const baseSuffix = ' · PsyClinicAI';
  return switch (routeName) {
    null || '' || '/' || '/landing' =>
      'PsyClinicAI — AI co-pilot for therapy sessions',
    '/login' => 'Sign in$baseSuffix',
    '/onboarding' => 'Welcome$baseSuffix',
    '/dashboard' => 'Dashboard$baseSuffix',
    '/session' => 'Live session$baseSuffix',
    '/session_management' => 'Sessions$baseSuffix',
    '/superbill' => 'Superbill$baseSuffix',
    '/assessments/phq9' => 'PHQ-9 screener$baseSuffix',
    '/assessments/gad7' => 'GAD-7 screener$baseSuffix',
    '/patients' => 'Patients$baseSuffix',
    '/patient/detail' => 'Patient chart$baseSuffix',
    '/outcomes' => 'Outcomes dashboard$baseSuffix',
    '/settings' => 'Settings$baseSuffix',
    '/settings/api_keys' => 'API keys$baseSuffix',
    '/security' => 'Security & compliance$baseSuffix',
    '/about' => 'About$baseSuffix',
    '/changelog' => 'Changelog$baseSuffix',
    '/status' => 'System status$baseSuffix',
    '/privacy' => 'Privacy policy$baseSuffix',
    '/tos' => 'Terms of service$baseSuffix',
    '/contact' => 'Contact$baseSuffix',
    '/press' => 'Press kit$baseSuffix',
    _ => 'Page not found$baseSuffix',
  };
}
