import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/data_retention_class_catalog.dart';

void main() {
  group('DataRetentionClassCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(DataRetentionClassCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = DataRetentionClassCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in DataRetentionClassCatalog.records) {
        expect(DataRetentionClassCatalog.byId(r.id), same(r));
      }
      expect(DataRetentionClassCatalog.byId('does-not-exist'), isNull);
    });

    test('every DataCategory has exactly one pinned record', () {
      for (final c in DataCategory.values) {
        final matches = DataRetentionClassCatalog.records
            .where((r) => r.category == c)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${c.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in DataRetentionClassCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });

    test('min retention <= max retention (sanity)', () {
      for (final r in DataRetentionClassCatalog.records) {
        expect(
          r.minRetentionYears,
          lessThanOrEqualTo(r.maxRetentionYears),
          reason:
              '${r.id}: minRetention (${r.minRetentionYears}) cannot exceed maxRetention (${r.maxRetentionYears})',
        );
      }
    });
  });

  group('safety-critical invariants', () {
    test(
      'clinical-record MUST retain >= 10 years (NHS England RMC adult floor)',
      () {
        final r = DataRetentionClassCatalog.byCategory(
          DataCategory.clinicalRecord,
        )!;
        expect(
          r.minRetentionYears,
          greaterThanOrEqualTo(10),
          reason:
              'clinical record retention floor is 10y adult / 20y minors per NHS England RMC; HIPAA §164.530 6y is below floor',
        );
      },
    );

    test(
      'audit-log + consent-record MUST retain >= 7 years (HIPAA + SOC 2 dual-cover)',
      () {
        for (final c in [DataCategory.auditLog, DataCategory.consentRecord]) {
          final r = DataRetentionClassCatalog.byCategory(c)!;
          expect(
            r.minRetentionYears,
            greaterThanOrEqualTo(7),
            reason:
                '${c.name}: 6y HIPAA + 7y SOC 2 norm → pin 7y to dual-cover',
          );
        }
      },
    );

    test('billing-record MUST retain >= 7 years (US IRS + EU tax)', () {
      final r = DataRetentionClassCatalog.byCategory(
        DataCategory.billingRecord,
      )!;
      expect(
        r.minRetentionYears,
        greaterThanOrEqualTo(7),
        reason: 'billing record minimum 7y per US IRS / 10y per DE HGB §257',
      );
    });

    test(
      'clinical-record disposition MUST be anonymise (Recital 26, retain research value)',
      () {
        final r = DataRetentionClassCatalog.byCategory(
          DataCategory.clinicalRecord,
        )!;
        expect(
          r.dispositionAtEnd,
          DispositionAction.anonymise,
          reason:
              'clinical record disposition is anonymise — retains statistical research value while satisfying Art. 17 erasure for the patient',
        );
      },
    );

    test(
      'audit-log + consent-record + billing-record disposition MUST be coldArchive',
      () {
        for (final c in [
          DataCategory.auditLog,
          DataCategory.consentRecord,
          DataCategory.billingRecord,
        ]) {
          final r = DataRetentionClassCatalog.byCategory(c)!;
          expect(
            r.dispositionAtEnd,
            DispositionAction.coldArchive,
            reason:
                '${c.name}: needs cold archive for regulator inquiry after active retention',
          );
        }
      },
    );

    test(
      'product-analytics + auth-event + error-telemetry + backup-blob MUST hardDelete or anonymise',
      () {
        for (final c in [
          DataCategory.productAnalytics,
          DataCategory.authEvent,
          DataCategory.errorTelemetry,
          DataCategory.backupBlob,
        ]) {
          final r = DataRetentionClassCatalog.byCategory(c)!;
          expect(
            r.dispositionAtEnd == DispositionAction.hardDelete ||
                r.dispositionAtEnd == DispositionAction.anonymise,
            isTrue,
            reason:
                '${c.name}: short-lived telemetry/analytics has no regulator-access justification; cold archive is bloat + cost + breach surface',
          );
        }
      },
    );

    test('PHI-touching records MUST cite HIPAA', () {
      for (final c in [
        DataCategory.clinicalRecord,
        DataCategory.auditLog,
        DataCategory.consentRecord,
        DataCategory.authEvent,
        DataCategory.backupBlob,
      ]) {
        final r = DataRetentionClassCatalog.byCategory(c)!;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('HIPAA'),
          isTrue,
          reason:
              '${c.name}: PHI-touching retention class needs a HIPAA anchor',
        );
      }
    });

    test(
      'every record MUST cite GDPR Art. 5(1)(e), HIPAA, ISO 27001, SOC 2, or tax-law anchor',
      () {
        for (final r in DataRetentionClassCatalog.records) {
          final blob = r.regulatoryRefs.join(' | ');
          expect(
            blob.contains('GDPR Art. 5') ||
                blob.contains('HIPAA') ||
                blob.contains('ISO 27001') ||
                blob.contains('SOC 2') ||
                blob.contains('IRS') ||
                blob.contains('HGB'),
            isTrue,
            reason: '${r.id}: needs a retention-anchor regulatory citation',
          );
        }
      },
    );

    test(
      'max retention <= 30 years (GDPR Art. 5(1)(e) storage-limitation ceiling)',
      () {
        for (final r in DataRetentionClassCatalog.records) {
          expect(
            r.maxRetentionYears,
            lessThanOrEqualTo(30),
            reason:
                '${r.id}: GDPR Art. 5(1)(e) caps retention at the necessary duration; 30y is the absolute outer bound',
          );
        }
      },
    );
  });

  group('meetsMinRetention helper', () {
    test('false when years < min', () {
      expect(meetsMinRetention(DataCategory.clinicalRecord, 5), isFalse);
      expect(meetsMinRetention(DataCategory.auditLog, 6), isFalse);
    });

    test('true when years >= min', () {
      expect(meetsMinRetention(DataCategory.clinicalRecord, 10), isTrue);
      expect(meetsMinRetention(DataCategory.clinicalRecord, 25), isTrue);
      expect(meetsMinRetention(DataCategory.auditLog, 7), isTrue);
    });
  });
}
