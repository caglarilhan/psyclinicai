import 'package:json_annotation/json_annotation.dart';

part 'crisis_communication_models.g.dart';

// ===== KRİZ İLETİŞİM SİSTEMİ MODELLERİ =====
// Kriz durumunda otomatik iletişim için gerekli veri yapıları

/// İletişim Türü - Farklı iletişim kanalları
enum CommunicationType {
  @JsonValue('phone_call') phoneCall, // Telefon araması
  @JsonValue('sms') sms, // SMS
  @JsonValue('email') email, // Email
  @JsonValue('emergency_service') emergencyService, // Acil servis (112)
  @JsonValue('emergency_contact') emergencyContact, // Acil durum kişisi
  @JsonValue('push_notification') pushNotification, // Push bildirim
  @JsonValue('in_app_message') inAppMessage, // Uygulama içi mesaj
}

/// İletişim Durumu - İletişim girişiminin sonucu
enum CommunicationStatus {
  @JsonValue('pending') pending, // Bekliyor
  @JsonValue('attempting') attempting, // Deneniyor
  @JsonValue('successful') successful, // Başarılı
  @JsonValue('failed') failed, // Başarısız
  @JsonValue('cancelled') cancelled, // İptal edildi
  @JsonValue('retrying') retrying, // Tekrar deneniyor
}

/// İletişim Girişimi - Tek bir iletişim denemesi
@JsonSerializable()
class CommunicationAttempt {
  final String id; // Benzersiz tanımlayıcı
  final String communicationId; // İletişim oturumu kimliği
  final CommunicationType type; // İletişim türü
  final String target; // Hedef (telefon, email, vb.)
  final CommunicationStatus status; // İletişim durumu
  final DateTime timestamp; // Başlangıç zamanı
  final DateTime? completedAt; // Tamamlanma zamanı
  final Map<String, dynamic> metadata; // Ek meta veriler

  const CommunicationAttempt({
    required this.id,
    required this.communicationId,
    required this.type,
    required this.target,
    required this.status,
    required this.timestamp,
    this.completedAt,
    this.metadata = const {},
  });

  factory CommunicationAttempt.fromJson(Map<String, dynamic> json) => 
      _$CommunicationAttemptFromJson(json);
  Map<String, dynamic> toJson() => _$CommunicationAttemptToJson(this);
}

/// İletişim Oturumu - Bir kriz için yapılan tüm iletişim girişimleri
@JsonSerializable()
class CommunicationSession {
  final String id; // Benzersiz tanımlayıcı
  final String crisisFlagId; // Kriz flag kimliği
  final String patientId; // Hasta kimliği
  final DateTime initiatedAt; // Başlatılma zamanı
  final DateTime? completedAt; // Tamamlanma zamanı
  final List<CommunicationAttempt> attempts; // İletişim girişimleri
  final CommunicationSessionStatus status; // Oturum durumu
  final Map<String, dynamic> metadata; // Ek meta veriler

  const CommunicationSession({
    required this.id,
    required this.crisisFlagId,
    required this.patientId,
    required this.initiatedAt,
    this.completedAt,
    required this.attempts,
    required this.status,
    this.metadata = const {},
  });

  factory CommunicationSession.fromJson(Map<String, dynamic> json) => 
      _$CommunicationSessionFromJson(json);
  Map<String, dynamic> toJson() => _$CommunicationSessionToJson(this);
}

/// İletişim Oturumu Durumu
enum CommunicationSessionStatus {
  @JsonValue('active') active, // Aktif
  @JsonValue('completed') completed, // Tamamlandı
  @JsonValue('failed') failed, // Başarısız
  @JsonValue('cancelled') cancelled, // İptal edildi
}

/// Hasta İletişim Bilgileri
@JsonSerializable()
class PatientContactInfo {
  final String patientId; // Hasta kimliği
  final String? phone; // Telefon numarası
  final String? email; // Email adresi
  final String? address; // Adres
  final List<EmergencyContact> emergencyContacts; // Acil durum kişileri
  final Map<String, dynamic> metadata; // Ek meta veriler

  const PatientContactInfo({
    required this.patientId,
    this.phone,
    this.email,
    this.address,
    required this.emergencyContacts,
    this.metadata = const {},
  });

  factory PatientContactInfo.fromJson(Map<String, dynamic> json) => 
      _$PatientContactInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PatientContactInfoToJson(this);
}

/// Acil Durum Kişisi
@JsonSerializable()
class EmergencyContact {
  final String id; // Benzersiz tanımlayıcı
  final String name; // İsim
  final String? phone; // Telefon numarası
  final String? email; // Email adresi
  final String? relationship; // Hasta ile ilişkisi
  final int priority; // Öncelik (1: en yüksek)
  final bool isPrimary; // Birincil acil durum kişisi mi?
  final Map<String, dynamic> metadata; // Ek meta veriler

  const EmergencyContact({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.relationship,
    this.priority = 1,
    this.isPrimary = false,
    this.metadata = const {},
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => 
      _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}

/// İletişim Şablonu - Farklı kriz türleri için iletişim şablonları
@JsonSerializable()
class CommunicationTemplate {
  final String id; // Benzersiz tanımlayıcı
  final CrisisType crisisType; // Kriz türü
  final CrisisSeverity severity; // Şiddet seviyesi
  final CommunicationType type; // İletişim türü
  final String subject; // Konu (email için)
  final String content; // İçerik
  final Map<String, String> variables; // Değişkenler
  final bool isActive; // Aktif mi?
  final Map<String, dynamic> metadata; // Ek meta veriler

  const CommunicationTemplate({
    required this.id,
    required this.crisisType,
    required this.severity,
    required this.type,
    required this.subject,
    required this.content,
    required this.variables,
    this.isActive = true,
    this.metadata = const {},
  });

  factory CommunicationTemplate.fromJson(Map<String, dynamic> json) => 
      _$CommunicationTemplateFromJson(json);
  Map<String, dynamic> toJson() => _$CommunicationTemplateToJson(this);
}

/// İletişim Raporu - İletişim oturumunun özeti
@JsonSerializable()
class CommunicationReport {
  final String id; // Benzersiz tanımlayıcı
  final String communicationSessionId; // İletişim oturumu kimliği
  final DateTime generatedAt; // Oluşturulma zamanı
  final int totalAttempts; // Toplam girişim sayısı
  final int successfulAttempts; // Başarılı girişim sayısı
  final int failedAttempts; // Başarısız girişim sayısı
  final Duration totalDuration; // Toplam süre
  final List<String> contactedChannels; // İletişim kurulan kanallar
  final String summary; // Özet
  final Map<String, dynamic> metadata; // Ek meta veriler

  const CommunicationReport({
    required this.id,
    required this.communicationSessionId,
    required this.generatedAt,
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.failedAttempts,
    required this.totalDuration,
    required this.contactedChannels,
    required this.summary,
    this.metadata = const {},
  });

  factory CommunicationReport.fromJson(Map<String, dynamic> json) => 
      _$CommunicationReportFromJson(json);
  Map<String, dynamic> toJson() => _$CommunicationReportToJson(this);
}

