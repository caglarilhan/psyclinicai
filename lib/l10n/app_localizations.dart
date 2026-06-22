import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// Brand name surfaced on the splash and app bar.
  ///
  /// In en, this message translates to:
  /// **'PsyClinicAI'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navTrustCenter.
  ///
  /// In en, this message translates to:
  /// **'Trust Center'**
  String get navTrustCenter;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// No description provided for @actionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get actionCopy;

  /// No description provided for @consentDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'AI assistance is not consented'**
  String get consentDeniedTitle;

  /// No description provided for @consentDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Update the intake form before drafting with AI.'**
  String get consentDeniedBody;

  /// No description provided for @consentDeniedAction.
  ///
  /// In en, this message translates to:
  /// **'Open intake'**
  String get consentDeniedAction;

  /// No description provided for @imminentRiskHeadline.
  ///
  /// In en, this message translates to:
  /// **'Imminent risk — act now'**
  String get imminentRiskHeadline;

  /// No description provided for @imminentRiskBody.
  ///
  /// In en, this message translates to:
  /// **'Do not leave the patient alone. Conduct a full clinical risk assessment and arrange transfer to emergency services or an inpatient setting per protocol.'**
  String get imminentRiskBody;

  /// No description provided for @imminentRiskCta.
  ///
  /// In en, this message translates to:
  /// **'Start safety plan now'**
  String get imminentRiskCta;

  /// No description provided for @imminentRiskDismiss.
  ///
  /// In en, this message translates to:
  /// **'I\'ll handle this manually'**
  String get imminentRiskDismiss;

  /// No description provided for @dismissReasonHospitalized.
  ///
  /// In en, this message translates to:
  /// **'Patient is on the way to / already at an inpatient setting'**
  String get dismissReasonHospitalized;

  /// No description provided for @dismissReasonFamilyPresent.
  ///
  /// In en, this message translates to:
  /// **'Family or trusted adult is with the patient and informed'**
  String get dismissReasonFamilyPresent;

  /// No description provided for @dismissReasonSupervisorHandoff.
  ///
  /// In en, this message translates to:
  /// **'Handed off to a supervisor / on-call psychiatrist'**
  String get dismissReasonSupervisorHandoff;

  /// No description provided for @dismissReasonInSessionPlan.
  ///
  /// In en, this message translates to:
  /// **'Completing a safety plan inside this session instead'**
  String get dismissReasonInSessionPlan;

  /// No description provided for @dismissReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other (documented in the session note)'**
  String get dismissReasonOther;

  /// No description provided for @crisisResources.
  ///
  /// In en, this message translates to:
  /// **'Crisis resources'**
  String get crisisResources;

  /// No description provided for @crisisResourcesLastReviewed.
  ///
  /// In en, this message translates to:
  /// **'Last reviewed {date} — verify before relying on a number in an emergency.'**
  String crisisResourcesLastReviewed(String date);

  /// No description provided for @dsarPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Data export (DSAR)'**
  String get dsarPortalTitle;

  /// No description provided for @dsarPortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GDPR Article 15 (access) + Article 20 (portability).'**
  String get dsarPortalSubtitle;

  /// No description provided for @dsarPhiBanner.
  ///
  /// In en, this message translates to:
  /// **'Sharing this file outside the chart is patient authorised under GDPR Art. 15/20. Treat the JSON as PHI.'**
  String get dsarPhiBanner;

  /// No description provided for @dsarEmptyBundle.
  ///
  /// In en, this message translates to:
  /// **'No patient records on file yet. Complete an intake or open a safety plan and the bundle will populate.'**
  String get dsarEmptyBundle;

  /// No description provided for @phiBadge.
  ///
  /// In en, this message translates to:
  /// **'PHI'**
  String get phiBadge;

  /// No description provided for @phiBannerWeb.
  ///
  /// In en, this message translates to:
  /// **'Web build does not cache PHI on this device. Records read from and write to the server on every action.'**
  String get phiBannerWeb;

  /// No description provided for @supervisionQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Supervision queue'**
  String get supervisionQueueTitle;

  /// No description provided for @supervisionQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trainee notes awaiting your approval, change request, or co-sign.'**
  String get supervisionQueueSubtitle;

  /// No description provided for @supervisionOpenSection.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supervisionOpenSection;

  /// No description provided for @supervisionClosedSection.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supervisionClosedSection;

  /// No description provided for @supervisionEmptyOpen.
  ///
  /// In en, this message translates to:
  /// **'No notes are waiting on you.'**
  String get supervisionEmptyOpen;

  /// No description provided for @supervisionEmptyClosed.
  ///
  /// In en, this message translates to:
  /// **'No decisions on the record yet.'**
  String get supervisionEmptyClosed;

  /// No description provided for @supervisionActionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get supervisionActionApprove;

  /// No description provided for @supervisionActionChanges.
  ///
  /// In en, this message translates to:
  /// **'Request changes'**
  String get supervisionActionChanges;

  /// No description provided for @supervisionActionCoSign.
  ///
  /// In en, this message translates to:
  /// **'Co-sign'**
  String get supervisionActionCoSign;

  /// No description provided for @supervisionCoSignDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Co-sign here records the supervisor decision but is NOT yet a legally binding electronic signature. Cryptographic signing (TOTP/WebAuthn, eIDAS / HIPAA §164.312(c)(2)) lands in Sprint 10. Until then, keep a wet-signature archive for billable Medicaid notes.'**
  String get supervisionCoSignDisclaimer;

  /// No description provided for @portalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your portal'**
  String get portalTitle;

  /// No description provided for @portalWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get portalWelcome;

  /// No description provided for @portalIntro.
  ///
  /// In en, this message translates to:
  /// **'A private space connected to your clinic. Everything you do here is logged for your records and protected under GDPR and KVKK.'**
  String get portalIntro;

  /// No description provided for @portalIntakeTitle.
  ///
  /// In en, this message translates to:
  /// **'First-visit questionnaire'**
  String get portalIntakeTitle;

  /// No description provided for @portalIntakeBody.
  ///
  /// In en, this message translates to:
  /// **'Share history, current medications, and consent with your clinician before the first session.'**
  String get portalIntakeBody;

  /// No description provided for @portalPromTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress questionnaires'**
  String get portalPromTitle;

  /// No description provided for @portalPromBody.
  ///
  /// In en, this message translates to:
  /// **'PHQ-9, GAD-7, and other measures requested by your clinician.'**
  String get portalPromBody;

  /// No description provided for @portalSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming sessions'**
  String get portalSessionsTitle;

  /// No description provided for @portalSessionsBody.
  ///
  /// In en, this message translates to:
  /// **'See the appointments your clinician scheduled. Cancellations and reschedule requests notify your clinician automatically.'**
  String get portalSessionsBody;

  /// No description provided for @portalDsarTitle.
  ///
  /// In en, this message translates to:
  /// **'Request your data'**
  String get portalDsarTitle;

  /// No description provided for @portalDsarBody.
  ///
  /// In en, this message translates to:
  /// **'Get a copy of every record we hold for you. Delivered as a portable JSON archive.'**
  String get portalDsarBody;

  /// No description provided for @portalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Close your account'**
  String get portalDeleteTitle;

  /// No description provided for @portalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Start a 30-day deletion. Your clinical record is pseudonymised after the grace window (replaced with an anonymous placeholder).'**
  String get portalDeleteBody;

  /// No description provided for @portalSecurityFooter.
  ///
  /// In en, this message translates to:
  /// **'Sessions and notes between you and your clinician are held on EU servers. AI assistance only runs when you have explicitly opted in.'**
  String get portalSecurityFooter;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
