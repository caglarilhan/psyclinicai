import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/data_classification_catalog.dart';

void main() {
  group('DataClassificationCatalog — pinned invariants', () {
    test('catalog is non-empty', () {
      expect(DataClassificationCatalog.classes, isNotEmpty);
    });

    test('every class has a unique id', () {
      final ids = DataClassificationCatalog.classes.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'duplicate ids');
    });

    test('byId resolves every entry', () {
      for (final c in DataClassificationCatalog.classes) {
        expect(DataClassificationCatalog.byId(c.id), same(c));
      }
      expect(DataClassificationCatalog.byId('does-not-exist'), isNull);
    });

    test('every class has fields populated', () {
      for (final c in DataClassificationCatalog.classes) {
        expect(c.label, isNotEmpty, reason: c.id);
        expect(c.exampleCollections, isNotEmpty, reason: c.id);
        expect(c.regulatoryRefs, isNotEmpty, reason: c.id);
      }
    });

    test('minRetentionDays ≤ maxRetentionDays for every class', () {
      for (final c in DataClassificationCatalog.classes) {
        expect(
          c.minRetentionDays,
          lessThanOrEqualTo(c.maxRetentionDays),
          reason: '${c.id}: min > max retention is contradictory',
        );
      }
    });

    test('PHI classes require AES-256 at rest (HIPAA §164.312(a)(2)(iv))', () {
      for (final c in DataClassificationCatalog.classes) {
        if (c.sensitivity != DataSensitivity.phi) continue;
        expect(
          c.encryption,
          EncryptionRequirement.aes256AtRestTls13InTransit,
          reason: '${c.id}: PHI MUST use AES-256 at rest',
        );
        expect(
          requiresStrongEncryption(c),
          isTrue,
          reason: '${c.id}: helper agrees PHI needs strong encryption',
        );
      }
    });

    test('PHI clinical records retain ≥ 7 years (HIPAA §164.316(b)(2)(i))', () {
      final phi = DataClassificationCatalog.byId('phi-clinical')!;
      expect(phi.minRetentionDays, greaterThanOrEqualTo(2555));
    });

    test('PHI audit chain has a fixed 7y window (min == max)', () {
      final chain = DataClassificationCatalog.byId('phi-audit-chain')!;
      expect(chain.minRetentionDays, chain.maxRetentionDays);
      expect(chain.minRetentionDays, 2555);
    });

    test('consent ledger retention matches audit chain (Art. 7(1) burden)', () {
      final ledger = DataClassificationCatalog.byId('personal-consent-ledger')!;
      expect(ledger.minRetentionDays, greaterThanOrEqualTo(2555));
    });

    test('public data uses TLS-only encryption requirement', () {
      final pub = DataClassificationCatalog.byId('public-trust-marketing')!;
      expect(pub.encryption, EncryptionRequirement.tls13InTransitOnly);
      expect(requiresStrongEncryption(pub), isFalse);
    });

    test('PHI clinical + billing transfers require SCC + supplementary', () {
      for (final id in ['phi-clinical', 'business-billing']) {
        final c = DataClassificationCatalog.byId(id)!;
        expect(
          c.crossBorder,
          CrossBorderPolicy.sccPlusSupplementary,
          reason: '$id: cross-border transfer requires Schrems II posture',
        );
        expect(requiresSccForTransfer(c), isTrue, reason: id);
      }
    });

    test('audit chain stays EU-only (no cross-border replication)', () {
      final chain = DataClassificationCatalog.byId('phi-audit-chain')!;
      expect(chain.crossBorder, CrossBorderPolicy.euOnly);
    });

    test('every class cites at least one known regulatory standard', () {
      const knownStandards = [
        'HIPAA',
        'GDPR',
        'KVKK',
        'PCI DSS',
        'SOC 2',
        'EU Directive',
        'CAN-SPAM',
        'n/a',
      ];
      for (final c in DataClassificationCatalog.classes) {
        final blob = c.regulatoryRefs.join(' | ');
        expect(
          knownStandards.any(blob.contains),
          isTrue,
          reason: '${c.id}: regulatoryRefs cite no known standard',
        );
      }
    });

    test('every PHI class declares its example collections', () {
      for (final c in DataClassificationCatalog.classes) {
        if (c.sensitivity != DataSensitivity.phi) continue;
        expect(
          c.exampleCollections.length,
          greaterThanOrEqualTo(1),
          reason: '${c.id}: must name at least one collection',
        );
      }
    });
  });

  group('cross-helper invariants', () {
    test('requiresExplicitConsent fires for special-category PHI clinical', () {
      final phi = DataClassificationCatalog.byId('phi-clinical')!;
      expect(phi.requiresExplicitConsent, isTrue);
    });

    test('audit chain bypass: legal-obligation processing, not consented', () {
      final chain = DataClassificationCatalog.byId('phi-audit-chain')!;
      expect(chain.requiresExplicitConsent, isFalse);
    });

    test(
      'marketing waitlist requires explicit consent (CAN-SPAM / md. 5/1)',
      () {
        final m = DataClassificationCatalog.byId(
          'business-marketing-waitlist',
        )!;
        expect(m.requiresExplicitConsent, isTrue);
      },
    );
  });
}
