// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PsyClinicAI';

  @override
  String get navHome => 'Home';

  @override
  String get navPatients => 'Patients';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navSettings => 'Settings';

  @override
  String get navTrustCenter => 'Trust Center';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionBack => 'Back';

  @override
  String get actionNext => 'Next';

  @override
  String get actionExport => 'Export';

  @override
  String get actionCopy => 'Copy';

  @override
  String get consentDeniedTitle => 'AI assistance is not consented';

  @override
  String get consentDeniedBody =>
      'Update the intake form before drafting with AI.';

  @override
  String get consentDeniedAction => 'Open intake';

  @override
  String get imminentRiskHeadline => 'Imminent risk — act now';

  @override
  String get imminentRiskBody =>
      'Do not leave the patient alone. Conduct a full clinical risk assessment and arrange transfer to emergency services or an inpatient setting per protocol.';

  @override
  String get imminentRiskCta => 'Start safety plan now';

  @override
  String get imminentRiskDismiss => 'I\'ll handle this manually';

  @override
  String get dismissReasonHospitalized =>
      'Patient is on the way to / already at an inpatient setting';

  @override
  String get dismissReasonFamilyPresent =>
      'Family or trusted adult is with the patient and informed';

  @override
  String get dismissReasonSupervisorHandoff =>
      'Handed off to a supervisor / on-call psychiatrist';

  @override
  String get dismissReasonInSessionPlan =>
      'Completing a safety plan inside this session instead';

  @override
  String get dismissReasonOther => 'Other (documented in the session note)';

  @override
  String get crisisResources => 'Crisis resources';

  @override
  String crisisResourcesLastReviewed(String date) {
    return 'Last reviewed $date — verify before relying on a number in an emergency.';
  }

  @override
  String get dsarPortalTitle => 'Data export (DSAR)';

  @override
  String get dsarPortalSubtitle =>
      'GDPR Article 15 (access) + Article 20 (portability).';

  @override
  String get dsarPhiBanner =>
      'Sharing this file outside the chart is patient authorised under GDPR Art. 15/20. Treat the JSON as PHI.';

  @override
  String get dsarEmptyBundle =>
      'No patient records on file yet. Complete an intake or open a safety plan and the bundle will populate.';

  @override
  String get phiBadge => 'PHI';

  @override
  String get phiBannerWeb =>
      'Web build does not cache PHI on this device. Records read from and write to the server on every action.';
}
