import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/tenant_region.dart';

void main() {
  group('TenantRegion', () {
    test('EU pin carries the eur3 Firestore region', () {
      const r = TenantRegion.euCentral;
      expect(r.id, 'eu-central');
      expect(r.firestoreRegion, 'eur3');
      expect(r.city, 'Frankfurt');
      expect(r.displayLabel, 'EU · Frankfurt (eur3)');
      expect(r.mandatoryFrameworks, containsAll(['GDPR', 'KVKK']));
    });

    test('US pin carries us-central1 + HIPAA framework', () {
      const r = TenantRegion.usCentral;
      expect(r.firestoreRegion, 'us-central1');
      expect(r.displayLabel, 'US · Iowa (us-central1)');
      expect(r.mandatoryFrameworks, contains('HIPAA'));
    });

    test('fromId throws on unknown id (no silent GDPR fallback)', () {
      expect(() => TenantRegion.fromId('unknown'), throwsArgumentError);
      expect(TenantRegion.fromId('us-central'), TenantRegion.usCentral);
    });

    test('tryFromId returns null for unknown ids (test seam)', () {
      expect(TenantRegion.tryFromId('unknown'), isNull);
      expect(TenantRegion.tryFromId('eu-central'), TenantRegion.euCentral);
    });
  });

  group('TenantRegionPin', () {
    final base = TenantRegionPin(
      tenantId: 't-1',
      region: TenantRegion.euCentral,
      pinnedAt: DateTime.utc(2026, 6),
    );

    test('requestChangeTo refuses identity change', () {
      expect(
        () => base.requestChangeTo(TenantRegion.euCentral),
        throwsArgumentError,
      );
    });

    test('requestChangeTo records pending migration', () {
      final next = base.requestChangeTo(
        TenantRegion.usCentral,
        at: DateTime.utc(2026, 6, 2),
      );
      expect(next.region, TenantRegion.euCentral);
      expect(next.hasPendingChange, isTrue);
      expect(next.changeRequestedTo, TenantRegion.usCentral);
      expect(next.changeRequestedAt, DateTime.utc(2026, 6, 2));
    });

    test('JSON round-trip preserves all fields', () {
      final next = base.requestChangeTo(
        TenantRegion.usCentral,
        at: DateTime.utc(2026, 6, 2),
      );
      final restored = TenantRegionPin.fromJson(next.toJson());
      expect(restored.tenantId, 't-1');
      expect(restored.region, TenantRegion.euCentral);
      expect(restored.changeRequestedTo, TenantRegion.usCentral);
      expect(restored.changeRequestedAt, DateTime.utc(2026, 6, 2));
    });

    test('JSON without change fields restores cleanly', () {
      final restored = TenantRegionPin.fromJson(base.toJson());
      expect(restored.hasPendingChange, isFalse);
      expect(restored.changeRequestedTo, isNull);
    });
  });
}
