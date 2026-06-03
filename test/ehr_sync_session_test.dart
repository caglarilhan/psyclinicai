import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/ehr_sync_session.dart';

void main() {
  group('FhirVendor', () {
    test('fromId fallback is SMART-on-FHIR', () {
      expect(FhirVendor.fromId('mystery'), FhirVendor.smartOnFhir);
      expect(FhirVendor.fromId('epic'), FhirVendor.epic);
    });
  });

  group('FhirConflict', () {
    test('JSON round-trip preserves all fields incl optional field_path',
        () {
      final c = FhirConflict(
        resourceType: 'Patient',
        resourceId: 'p-1',
        kind: FhirConflictKind.divergent,
        localUpdatedAt: DateTime.utc(2026, 6, 2, 10),
        remoteUpdatedAt: DateTime.utc(2026, 6, 2, 11),
        fieldPath: 'name[0].family',
      );
      final restored = FhirConflict.fromJson(c.toJson());
      expect(restored.resourceId, c.resourceId);
      expect(restored.kind, c.kind);
      expect(restored.fieldPath, c.fieldPath);
    });

    test('unknown conflict kind falls back to divergent', () {
      final c = FhirConflict.fromJson({
        'resource_type': 'Patient',
        'resource_id': 'p-1',
        'kind': 'unknown',
        'local_updated_at': '2026-06-02T10:00:00Z',
        'remote_updated_at': '2026-06-02T11:00:00Z',
      });
      expect(c.kind, FhirConflictKind.divergent);
    });
  });

  group('EhrSyncSession', () {
    test('needsAttention true for conflict + error states', () {
      final s = EhrSyncSession(
        sessionId: 's-1',
        vendor: FhirVendor.epic,
        resourceTypes: const ['Patient'],
        status: FhirSyncStatus.conflict,
        startedAt: DateTime.utc(2026, 6, 2),
      );
      expect(s.needsAttention, isTrue);
      expect(s.runtime, isNull);
    });

    test('runtime computed from completedAt', () {
      final s = EhrSyncSession(
        sessionId: 's-1',
        vendor: FhirVendor.epic,
        resourceTypes: const ['Patient'],
        status: FhirSyncStatus.complete,
        startedAt: DateTime.utc(2026, 6, 2, 10),
        completedAt: DateTime.utc(2026, 6, 2, 10, 5),
      );
      expect(s.runtime, const Duration(minutes: 5));
    });

    test('JSON round-trip preserves conflicts list', () {
      final s = EhrSyncSession(
        sessionId: 's-1',
        vendor: FhirVendor.epic,
        resourceTypes: const ['Patient', 'Encounter'],
        status: FhirSyncStatus.conflict,
        startedAt: DateTime.utc(2026, 6, 2),
        conflicts: [
          FhirConflict(
            resourceType: 'Encounter',
            resourceId: 'enc-9',
            kind: FhirConflictKind.remoteMissing,
            localUpdatedAt: DateTime.utc(2026, 6, 2, 10),
            remoteUpdatedAt: DateTime.utc(2026, 6, 1),
          ),
        ],
        recordsRead: 42,
      );
      final restored = EhrSyncSession.fromJson(s.toJson());
      expect(restored.conflicts.length, 1);
      expect(restored.conflicts.first.kind, FhirConflictKind.remoteMissing);
      expect(restored.recordsRead, 42);
    });
  });
}
