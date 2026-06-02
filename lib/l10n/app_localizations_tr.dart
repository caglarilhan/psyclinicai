// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'PsyClinicAI';

  @override
  String get navHome => 'Anasayfa';

  @override
  String get navPatients => 'Hastalar';

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navTrustCenter => 'Güven Merkezi';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionCancel => 'Vazgeç';

  @override
  String get actionConfirm => 'Onayla';

  @override
  String get actionBack => 'Geri';

  @override
  String get actionNext => 'İleri';

  @override
  String get actionExport => 'Dışa aktar';

  @override
  String get actionCopy => 'Kopyala';

  @override
  String get consentDeniedTitle => 'Yapay zekâ rızası alınmamış';

  @override
  String get consentDeniedBody =>
      'Yapay zekâ ile taslak oluşturmadan önce intake formunu güncelleyin.';

  @override
  String get consentDeniedAction => 'Intake formunu aç';

  @override
  String get imminentRiskHeadline => 'Akut risk — hemen müdahale';

  @override
  String get imminentRiskBody =>
      'Hastayı yalnız bırakmayın. Tam klinik intihar risk değerlendirmesi yapın ve protokole göre acil ya da yatış birimine transferi başlatın.';

  @override
  String get imminentRiskCta => 'Güvenlik planını şimdi başlat';

  @override
  String get imminentRiskDismiss => 'Bu durumu kendim yöneteceğim';

  @override
  String get dismissReasonHospitalized =>
      'Hasta yatış birimine yönlendirildi / götürüldü';

  @override
  String get dismissReasonFamilyPresent =>
      'Hasta yanında bilgilendirilmiş bir aile bireyi/yetişkin var';

  @override
  String get dismissReasonSupervisorHandoff =>
      'Süpervizöre / nöbetçi psikiyatriste devredildi';

  @override
  String get dismissReasonInSessionPlan =>
      'Güvenlik planı bu seansın içinde tamamlanacak';

  @override
  String get dismissReasonOther => 'Diğer (seans notunda belgelendi)';

  @override
  String get crisisResources => 'Kriz kaynakları';

  @override
  String crisisResourcesLastReviewed(String date) {
    return 'Son güncelleme $date — acil durumlara güvenmeden önce numaraları doğrulayın.';
  }

  @override
  String get dsarPortalTitle => 'Veri ihracı (DSAR)';

  @override
  String get dsarPortalSubtitle =>
      'KVKK Md. 11 ve GDPR Madde 15 + 20 kapsamında erişim ve taşınabilirlik.';

  @override
  String get dsarPhiBanner =>
      'Bu dosyayı klinik dışına paylaşmak hastanın KVKK Md. 11 / GDPR Art. 15/20 hakkı altındadır. JSON\'u PHI olarak işleyin.';

  @override
  String get dsarEmptyBundle =>
      'Henüz hasta kaydı yok. Bir intake doldurun ya da güvenlik planı oluşturun.';

  @override
  String get phiBadge => 'PHI';

  @override
  String get phiBannerWeb =>
      'Web sürümü cihazda PHI önbellekleme yapmaz. Her işlemde sunucuya okur ve yazar.';
}
