# ABD Eyalet Bazlı Hukuk Motoru ve Uyarı Entegrasyonu

Bu belge, eyalet bazlı hukuk motorunun (policy engine), uyarı sistemi ve orkestratör kullanımını özetler.

## Bileşenler
- `lib/models/legal_policy_models.dart`: Policy modelleri (State, Rule, Condition, Action, Decision)
- `lib/services/legal_policy_service.dart`: Politika yükleme ve değerlendirme
- `lib/services/alerting_service.dart`: De-dup ve cool-down destekli bildirim altyapısı
- `lib/services/legal_compliance_orchestrator.dart`: Değerlendirme + bildirim entegrasyonu

## Hızlı Kullanım

### 1) Sadece değerlendirme
```dart
final policyService = LegalPolicyService();
await policyService.initialize();

final decision = await policyService.evaluate(
  LegalEvaluationContext(
    state: UsStateCode.ca,
    facts: {
      'patientId': 'p1',
      'risk_level': 'Kritik',
      'threat_to_others': false,
    },
  ),
);

// decision.requiredActions → yapılması gereken işlemler
// decision.notifications → şablonlardan üretilen mesajlar
```

### 2) Değerlendirme + Bildirim (Orchestrator)
```dart
final orchestrator = LegalComplianceOrchestrator();
final decision = await orchestrator.evaluateAndNotify(
  state: UsStateCode.ca,
  facts: {
    'patientId': 'p1',
    'risk_level': 'Kritik',
  },
  cooldown: const Duration(minutes: 5), // aynı hasta/state için tekrarı engelle
);
```

### 3) AlertingService tek başına
```dart
final alert = AlertingService();
alert.send(
  key: 'state:CA|patient:p1|legal|note:mandatory_report',
  message: 'CA Zorunlu Bildirim: Hasta: p1, Risk: Kritik',
  cooldown: const Duration(minutes: 5),
);
```

## Notlar
- Policy versiyonlama ve farklı eyalet varyantları `StateLegalPolicy` ile yönetilir.
- Şablonlar `notificationTemplates` haritasından gelir; basit `{{placeholder}}` değişimi kullanılır.
- Orchestrator, kararın `notifications` alanını `AlertingService` içine de-dup/cool-down ile iletir.

## Testler
- `test/legal_policy_service_test.dart`: CA/NY senaryoları
- `test/alerting_service_test.dart`: de-dup ve cool-down
- `test/legal_compliance_orchestrator_test.dart`: uçtan uca değerlendirme + bildirim

Tüm testler yeşildir. İş ihtiyaçlarına göre yeni eyalet politikaları veya kurum bazlı override’lar eklenebilir.
