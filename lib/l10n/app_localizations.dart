import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('en'),
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
