import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/consent_entry.dart';
import 'package:psyclinicai/services/compliance/consent_kind_catalog.dart';

void main() {
  group('ConsentKindCatalog — enum parity', () {
    test('every ConsentKind has exactly one pinned record', () {
      final pinned = ConsentKindCatalog.entries.map((r) => r.kind).toList();
      expect(pinned.toSet().length, pinned.length, reason: 'duplicate kinds');
      expect(
        pinned.toSet(),
        equals(ConsentKind.values.toSet()),
        reason:
            'enum/catalog drift — if you add a ConsentKind, add its '
            'ConsentKindRecord to ConsentKindCatalog.entries',
      );
    });

    test('entries order matches ConsentKind.values', () {
      final pinned = ConsentKindCatalog.entries.map((r) => r.kind).toList();
      expect(pinned, equals(ConsentKind.values));
    });

    test('forKind resolves every enum value', () {
      for (final k in ConsentKind.values) {
        expect(ConsentKindCatalog.forKind(k).kind, k);
      }
    });
  });

  group('ConsentKindCatalog — content invariants', () {
    test('every record has non-empty title + summary + anchors', () {
      for (final r in ConsentKindCatalog.entries) {
        expect(r.modalTitle, isNotEmpty, reason: r.kind.id);
        expect(r.modalSummary, isNotEmpty, reason: r.kind.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.kind.id);
      }
    });

    test('special-category health data is explicit opt-in (legal floor)', () {
      final mustBeExplicit = [
        ConsentKind.gdprProcessing,
        ConsentKind.kvkkSpecialCategoryHealth,
        ConsentKind.aiProcessing,
        ConsentKind.audioRecording,
        ConsentKind.telehealth,
      ];
      for (final k in mustBeExplicit) {
        expect(
          ConsentKindCatalog.forKind(k).defaultPolicy,
          ConsentDefaultPolicy.explicitOptIn,
          reason:
              '${k.id} MUST be explicit opt-in — GDPR Art. 9 / KVKK md. 6 '
              'forbid opt-out for special-category health data.',
        );
      }
    });

    test('HIPAA NOPP is gated by the service agreement (45 CFR §164.520)', () {
      expect(
        ConsentKindCatalog.forKind(ConsentKind.hipaaNopp).defaultPolicy,
        ConsentDefaultPolicy.serviceAgreementGated,
      );
    });

    test('marketing is the only opt-out kind', () {
      final optOut = ConsentKindCatalog.entries
          .where((r) => r.defaultPolicy == ConsentDefaultPolicy.optOut)
          .map((r) => r.kind)
          .toList();
      expect(optOut, equals([ConsentKind.marketing]));
    });

    test('revocation SLA is bounded (1h .. 72h)', () {
      for (final r in ConsentKindCatalog.entries) {
        expect(
          r.revocationSlaHours,
          inInclusiveRange(1, 72),
          reason:
              '${r.kind.id}: revocation SLA must be between 1h and 72h — '
              'GDPR Art. 7(3) "as easy to withdraw as to give".',
        );
      }
    });

    test('AI + audio consents have the tightest revocation SLA (≤ 1h)', () {
      for (final k in [ConsentKind.aiProcessing, ConsentKind.audioRecording]) {
        expect(
          ConsentKindCatalog.forKind(k).revocationSlaHours,
          lessThanOrEqualTo(1),
          reason:
              '${k.id}: an active recording / AI session must stop within '
              'an hour of revoke.',
        );
      }
    });

    test('consents that close the chart require clinician countersign', () {
      for (final k in [
        ConsentKind.gdprProcessing,
        ConsentKind.kvkkSpecialCategoryHealth,
      ]) {
        expect(
          ConsentKindCatalog.forKind(k).requiresClinicianCountersign,
          isTrue,
          reason:
              '${k.id}: revoking this closes the chart → clinician must '
              'countersign the audit-trail entry.',
        );
      }
    });
  });
}
