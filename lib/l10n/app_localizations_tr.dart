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

  @override
  String get supervisionQueueTitle => 'Süpervizyon kuyruğu';

  @override
  String get supervisionQueueSubtitle =>
      'Stajyer notları onayınızı, değişiklik talebinizi veya birlikte imzanızı bekliyor.';

  @override
  String get supervisionOpenSection => 'Açık';

  @override
  String get supervisionClosedSection => 'Kapanmış';

  @override
  String get supervisionEmptyOpen => 'Şu an sizi bekleyen not yok.';

  @override
  String get supervisionEmptyClosed => 'Henüz kayda geçen karar yok.';

  @override
  String get supervisionActionApprove => 'Onayla';

  @override
  String get supervisionActionChanges => 'Değişiklik iste';

  @override
  String get supervisionActionCoSign => 'Birlikte imzala';

  @override
  String get supervisionCoSignDisclaimer =>
      'Buradaki birlikte-imza süpervizör kararını kayıt altına alır, ANCAK henüz hukuki olarak bağlayıcı elektronik imza değildir. Kriptografik imza (TOTP/WebAuthn, eIDAS / HIPAA §164.312(c)(2)) Sprint 10\'da gelir. O zamana kadar fatura edilecek Medicaid notları için ıslak imza arşivini koruyun.';

  @override
  String get portalTitle => 'Portalım';

  @override
  String get portalWelcome => 'Hoş geldiniz';

  @override
  String get portalIntro =>
      'Klinik ekibinize bağlı, size özel bir alan. Burada yaptığınız her işlem GDPR ve KVKK kapsamında korunarak kayıt altına alınır.';

  @override
  String get portalIntakeTitle => 'İlk görüşme formu';

  @override
  String get portalIntakeBody =>
      'İlk seansa girmeden önce geçmişinizi, kullandığınız ilaçları ve onay tercihlerinizi klinisyeniniz ile paylaşın.';

  @override
  String get portalPromTitle => 'İyileşme anketleri';

  @override
  String get portalPromBody =>
      'Klinisyeninizin istediği PHQ-9, GAD-7 ve diğer ölçüm anketleri.';

  @override
  String get portalSessionsTitle => 'Yaklaşan seanslar';

  @override
  String get portalSessionsBody =>
      'Klinisyeninizin planladığı randevuları görün. İptal veya yeniden planlama talepleri klinisyeninize otomatik iletilir.';

  @override
  String get portalDsarTitle => 'Verilerinizi isteyin';

  @override
  String get portalDsarBody =>
      'Sizinle ilgili tuttuğumuz tüm kayıtların kopyasını alın. Taşınabilir JSON arşiv olarak teslim edilir.';

  @override
  String get portalDeleteTitle => 'Hesabınızı kapatın';

  @override
  String get portalDeleteBody =>
      '30 günlük silme sürecini başlatın. Süre dolunca klinik kaydınız anonim bir yer tutucu ile değiştirilerek pseudonimize edilir.';

  @override
  String get portalSecurityFooter =>
      'Sizinle klinisyeniniz arasındaki seanslar ve notlar AB sunucularında tutulur. Yapay zekâ desteği yalnızca siz açıkça onay verdiğinizde çalışır.';
}
