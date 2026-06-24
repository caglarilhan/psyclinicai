import 'package:flutter/material.dart';

import '../../widgets/static/static_page_shell.dart';

/// `/legal/kvkk` — KVKK md. 10 aydınlatma metni (Turkish data-subject
/// information notice required by Law no. 6698, art. 10) covering data
/// controller, processing purposes, legal basis, transfers, retention
/// and the 11 enumerated rights under art. 11.
///
/// **Scope**: Türkiye-resident clinicians and patients. EU residents
/// rely on the GDPR-anchored `/privacy` summary instead. The two pages
/// are siblings, not substitutes — KVKK requires Turkish-language
/// wording even when the equivalent GDPR text already exists.
///
/// **Not a contract**: standard KVKK practice keeps the aydınlatma
/// metni standalone — it is a unilateral notice, not a consent form.
/// Açık rıza is captured separately in the intake and onboarding flows.
class KvkkAydinlatmaPage extends StatelessWidget {
  const KvkkAydinlatmaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StaticPageShell(
      eyebrow: 'KVKK · Türkiye',
      title: 'Aydınlatma Metni',
      lede:
          'PsyClinicAI olarak, 6698 sayılı Kişisel Verilerin Korunması '
          'Kanunu kapsamında veri sorumlusu sıfatıyla kişisel verilerinizi '
          'aşağıdaki esaslar çerçevesinde işliyoruz. Tam metin '
          '(legal@psyclinicai.com) talep üzerine PDF formatında '
          'iletilir.',
      lastUpdated: DateTime(2026, 6, 24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaticH2('1. Veri Sorumlusu'),
          StaticBullet(
            'PsyClinicAI — AB merkezli, klinik karar destek hizmeti '
            'sunan teknoloji sağlayıcı.',
          ),
          StaticBullet(
            'İletişim: legal@psyclinicai.com · KEP üzerinden başvuru '
            'için info@psyclinicai.kep.tr adresine yazılabilir.',
          ),
          StaticH2('2. İşlenen Kişisel Veriler'),
          StaticBullet(
            'Kimlik · ad, soyad, uzmanlık alanı, ruhsat numarası '
            '(klinisyen kullanıcılar için).',
          ),
          StaticBullet('İletişim · e-posta, opsiyonel telefon ve KEP adresi.'),
          StaticBullet(
            'Müşteri işlem · oturum kayıtları, randevu tarihleri, '
            'fatura kalemleri, abonelik durumu.',
          ),
          StaticBullet(
            'Sağlık · klinisyenin platforma kaydettiği seans notu '
            'taslakları, PHQ-9 / GAD-7 / C-SSRS ölçek skorları, '
            'tedavi planı hedefleri. Hasta kimliği yalnızca '
            'klinisyenin atadığı dahili kimlikle eşleştirilir; '
            'tanımlanabilir TC kimlik / sigorta numarası saklanmaz.',
          ),
          StaticBullet(
            'İşlem güvenliği · cihaz türü, IP, oturum açma zaman damgası, '
            'çok-faktörlü kimlik doğrulama olayları.',
          ),
          StaticBullet(
            'Asla işlenmeyenler · ham ses kaydı, üçüncü taraf çerez '
            'tabanlı izleme, açık rıza dışında pazarlama profili.',
          ),
          StaticH2('3. İşleme Amaçları'),
          StaticBullet(
            'Klinik karar destek hizmetinin sunulması ve geliştirilmesi.',
          ),
          StaticBullet('Faturalama, üyelik ve abonelik yönetimi.'),
          StaticBullet(
            'Yasal yükümlülüklerin yerine getirilmesi (vergi, denetim, '
            'sağlık mevzuatı).',
          ),
          StaticBullet(
            'Bilgi güvenliği ve denetim izlerinin korunması '
            '(HIPAA §164.312(b) ile uyumlu).',
          ),
          StaticH2('4. Hukuki Sebep'),
          StaticBullet('Sözleşmenin kurulması ve ifası — KVKK md. 5/2(c).'),
          StaticBullet(
            'Hukuki yükümlülüğün yerine getirilmesi — KVKK md. 5/2(ç).',
          ),
          StaticBullet(
            'Meşru menfaat — KVKK md. 5/2(f), yalnızca temel hak ve '
            'özgürlüklerinize zarar vermeyen ölçüde.',
          ),
          StaticBullet(
            'Özel nitelikli sağlık verileri için açık rıza — '
            'KVKK md. 6/2 ve md. 6/3. Açık rıza, hasta kaydı '
            'oluşturulurken ayrı bir form üzerinden alınır.',
          ),
          StaticH2('5. Aktarım'),
          StaticBullet(
            'Veriler AB veri merkezlerinde saklanır (Frankfurt + '
            'Amsterdam). KVKK md. 9 kapsamında yurt dışına aktarım, '
            'KVK Kurulu kararına uygun açık rıza veya yeterlilik '
            'kararı çerçevesinde gerçekleştirilir.',
          ),
          StaticBullet(
            'Alt işleyici listesi /security sayfasında ve talep üzerine '
            'güncel halde paylaşılır.',
          ),
          StaticH2('6. Saklama Süresi'),
          StaticBullet(
            'Aktif abonelik süresince + abonelik sonlandırmasının '
            'ardından 30 günlük dışa aktarım süresi.',
          ),
          StaticBullet(
            'Klinik kayıtların yerel mevzuatta belirlenen asgari '
            'saklama süreleri (örn. Türkiye için 20 yıl tıbbi kayıt '
            'mevzuatı) saklı kalmak üzere, kullanıcının silme '
            'talebi anında işleme alınır.',
          ),
          StaticH2('7. Veri Sahibi Hakları (KVKK md. 11)'),
          StaticBullet('Kişisel verilerinizin işlenip işlenmediğini öğrenme.'),
          StaticBullet('İşlenmişse buna ilişkin bilgi talep etme.'),
          StaticBullet(
            'İşleme amacını ve amacına uygun kullanılıp kullanılmadığını '
            'öğrenme.',
          ),
          StaticBullet(
            'Yurt içinde veya yurt dışında aktarıldığı üçüncü kişileri '
            'bilme.',
          ),
          StaticBullet(
            'Eksik veya yanlış işlenmiş verilerin düzeltilmesini isteme.',
          ),
          StaticBullet(
            'KVKK md. 7 çerçevesinde silinmesini veya yok edilmesini '
            'isteme.',
          ),
          StaticBullet(
            'Düzeltme, silme veya yok etme işlemlerinin aktarıldığı '
            'üçüncü kişilere bildirilmesini isteme.',
          ),
          StaticBullet(
            'Otomatik sistemler aracılığıyla analiz edilmesi suretiyle '
            'aleyhinize bir sonucun ortaya çıkmasına itiraz etme.',
          ),
          StaticBullet(
            'Kanuna aykırı işleme sebebiyle zarara uğramanız hâlinde '
            'zararın giderilmesini talep etme.',
          ),
          StaticH2('8. Başvuru Kanalı'),
          StaticBullet(
            'Veri Sorumlusuna Başvuru Usul ve Esasları Hakkında Tebliğ '
            'çerçevesinde, kimlik tespitine yarayacak bilgiler ve '
            'talebinizi açıkça içeren bir başvuru ile bize ulaşabilirsiniz.',
          ),
          StaticBullet(
            'E-posta · legal@psyclinicai.com (kayıtlı KEP veya güvenli '
            'kanal tercih edilir).',
          ),
          StaticBullet(
            'Talepleriniz, en geç 30 gün içinde ücretsiz olarak '
            'sonuçlandırılır; işlemin ayrıca bir maliyet gerektirmesi '
            'hâlinde Kurulca belirlenen tarifedeki ücret tahsil edilir.',
          ),
          StaticH2('9. Güncellemeler'),
          StaticBullet(
            'Bu metin, yasal çerçeve veya işleme amaçları değiştiğinde '
            'güncellenir. Önemli değişikliklerde uygulama içi '
            'bildirim gönderilir.',
          ),
        ],
      ),
    );
  }
}
