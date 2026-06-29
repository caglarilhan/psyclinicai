import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/compliance/lawful_basis_catalog.dart';

void main() {
  group('LawfulBasisCatalog — pinned invariants', () {
    test('records is non-empty', () {
      expect(LawfulBasisCatalog.records, isNotEmpty);
    });

    test('every record id is unique', () {
      final ids = LawfulBasisCatalog.records.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('byId resolves every record', () {
      for (final r in LawfulBasisCatalog.records) {
        expect(LawfulBasisCatalog.byId(r.id), same(r));
      }
      expect(LawfulBasisCatalog.byId('does-not-exist'), isNull);
    });

    test('every ProcessingActivity has exactly one pinned record', () {
      for (final a in ProcessingActivity.values) {
        final matches = LawfulBasisCatalog.records
            .where((r) => r.activity == a)
            .toList();
        expect(
          matches.length,
          1,
          reason:
              '${a.name}: expected exactly one record, found ${matches.length}',
        );
      }
    });

    test('every record has populated fields + anchors', () {
      for (final r in LawfulBasisCatalog.records) {
        expect(r.description, isNotEmpty, reason: r.id);
        expect(r.regulatoryRefs, isNotEmpty, reason: r.id);
      }
    });
  });

  group('safety-critical invariants', () {
    test('withdrawable IFF basis is consent (Art. 7(3))', () {
      for (final r in LawfulBasisCatalog.records) {
        final isConsent = r.article6Basis == LawfulBasisArticle6.consent;
        expect(
          r.withdrawable,
          isConsent,
          reason:
              '${r.id}: Art. 7(3) — withdrawable IFF basis is consent. consent=$isConsent withdrawable=${r.withdrawable}',
        );
      }
    });

    test(
      'clinical-record-storage + ai-copilot MUST use Art. 6(1)(b) contract + Art. 9(2)(h) healthcare',
      () {
        for (final a in [
          ProcessingActivity.clinicalRecordStorage,
          ProcessingActivity.aiCopilotInference,
        ]) {
          final r = LawfulBasisCatalog.byActivity(a)!;
          expect(
            r.article6Basis,
            LawfulBasisArticle6.contract,
            reason:
                '${a.name}: care delivery is Art. 6(1)(b) contract — picking consent would let patient withdraw mid-care, violating clinical safety',
          );
          expect(
            r.article9Condition,
            SpecialCategoryArt9.healthcareProvision,
            reason:
                '${a.name}: health data needs Art. 9(2)(h) healthcare-provision condition',
          );
        }
      },
    );

    test('billing MUST use Art. 6(1)(c) legal obligation (tax law)', () {
      final r = LawfulBasisCatalog.byActivity(ProcessingActivity.billing)!;
      expect(
        r.article6Basis,
        LawfulBasisArticle6.legalObligation,
        reason:
            'billing retention is driven by tax law — Art. 6(1)(c). Consent or contract would let the org delete their tax records.',
      );
    });

    test('marketing-email MUST use Art. 6(1)(a) consent + be withdrawable', () {
      final r = LawfulBasisCatalog.byActivity(
        ProcessingActivity.marketingEmail,
      )!;
      expect(
        r.article6Basis,
        LawfulBasisArticle6.consent,
        reason:
            'marketing comms is opt-in per ePrivacy Art. 13(1); any other basis is a dark-pattern',
      );
      expect(r.withdrawable, isTrue);
    });

    test(
      'vital-emergency-disclosure MUST use Art. 6(1)(d) vital interest + Art. 9(2)(c)',
      () {
        final r = LawfulBasisCatalog.byActivity(
          ProcessingActivity.vitalEmergencyDisclosure,
        )!;
        expect(
          r.article6Basis,
          LawfulBasisArticle6.vitalInterest,
          reason:
              'imminent risk-to-life disclosure is the textbook Art. 6(1)(d) vital-interest case',
        );
        expect(r.article9Condition, SpecialCategoryArt9.vitalIncapacity);
      },
    );

    test('error-telemetry MUST use Art. 6(1)(f) legitimate interest', () {
      final r = LawfulBasisCatalog.byActivity(
        ProcessingActivity.errorTelemetry,
      )!;
      expect(
        r.article6Basis,
        LawfulBasisArticle6.legitimateInterest,
        reason:
            'pseudonymised crash telemetry is GDPR Recital 49 legitimate interest (service reliability)',
      );
    });

    test('activities with health-data MUST cite Art. 9(2) condition', () {
      for (final a in [
        ProcessingActivity.clinicalRecordStorage,
        ProcessingActivity.aiCopilotInference,
        ProcessingActivity.vitalEmergencyDisclosure,
      ]) {
        final r = LawfulBasisCatalog.byActivity(a)!;
        expect(
          r.article9Condition,
          isNotNull,
          reason:
              '${a.name}: processes health data; Art. 9(2) condition mandatory',
        );
      }
    });

    test('activities NOT involving health data MUST NOT cite Art. 9(2)', () {
      for (final a in [
        ProcessingActivity.appointmentReminder,
        ProcessingActivity.billing,
        ProcessingActivity.marketingEmail,
        ProcessingActivity.errorTelemetry,
      ]) {
        final r = LawfulBasisCatalog.byActivity(a)!;
        expect(
          r.article9Condition,
          isNull,
          reason:
              '${a.name}: does not process Art. 9 special category — citing a condition would over-promise',
        );
      }
    });

    test('every record MUST cite a GDPR Art. 6 reference', () {
      for (final r in LawfulBasisCatalog.records) {
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('GDPR Art. 6(1)'),
          isTrue,
          reason: '${r.id}: GDPR Art. 6(1) anchor is mandatory',
        );
      }
    });

    test('records with article9Condition MUST cite GDPR Art. 9(2) ref', () {
      for (final r in LawfulBasisCatalog.records) {
        if (r.article9Condition == null) continue;
        final blob = r.regulatoryRefs.join(' | ');
        expect(
          blob.contains('GDPR Art. 9(2)'),
          isTrue,
          reason: '${r.id}: needs GDPR Art. 9(2) anchor to back the condition',
        );
      }
    });
  });

  group('isWithdrawable helper', () {
    test('true ONLY for marketing-email', () {
      for (final a in ProcessingActivity.values) {
        final expected = a == ProcessingActivity.marketingEmail;
        expect(isWithdrawable(a), expected, reason: a.name);
      }
    });
  });
}
