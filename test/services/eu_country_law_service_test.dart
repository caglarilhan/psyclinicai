import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/legal/eu_country_law_service.dart';

void main() {
  const svc = EuCountryLawService();

  group('EuCountryLawService EU Phase 2 (Sprint 32+33)', () {
    test('supportedCountries contains exactly DE + UK + AT', () {
      expect(EuCountryLawService.supportedCountries, {'DE', 'UK', 'AT'});
    });

    test('unknown country returns empty list', () {
      expect(svc.alertsForCountry('US'), isEmpty);
      expect(svc.alertsForCountry(''), isEmpty);
    });

    test('case-insensitive lookup', () {
      expect(
        svc.alertsForCountry('de').length,
        svc.alertsForCountry('DE').length,
      );
    });

    group('Germany', () {
      final alerts = svc.alertsForCountry('DE');

      test('5 alerts shipped', () {
        expect(alerts.length, 5);
      });

      test('§ 203 StGB / Notstand alert is critical', () {
        final a = alerts.firstWhere((e) => e.id == 'DE.dutyToWarn.bgh');
        expect(a.severity, AlertSeverity.critical);
        expect(a.citation, contains('§§ 203, 34 StGB'));
      });

      test('DSGVO Art. 9(2)(h) processing basis flagged', () {
        final a = alerts.firstWhere((e) => e.id == 'DE.consentToTreat.dsgvo');
        expect(a.citation, contains('Art. 9(2)(h) DSGVO'));
        expect(a.category, AlertCategory.consentToTreat);
      });

      test('record retention cites 10-year minimum', () {
        final a = alerts.firstWhere(
          (e) => e.id == 'DE.documentationRetention.psychthg',
        );
        expect(a.body, contains('10 years'));
      });
    });

    group('United Kingdom', () {
      final alerts = svc.alertsForCountry('UK');

      test('6 alerts shipped (FGM + safeguarding both present)', () {
        expect(alerts.length, 6);
      });

      test('FGM mandatory reporting is critical', () {
        final a = alerts.firstWhere((e) => e.id == 'UK.mandatoryReporting.fgm');
        expect(a.severity, AlertSeverity.critical);
        expect(a.citation, contains('FGM Act 2003 s.5B'));
      });

      test('public-interest disclosure is warning (no Tarasoff)', () {
        final a = alerts.firstWhere((e) => e.id == 'UK.dutyToWarn.tarasoff');
        expect(a.severity, AlertSeverity.warning);
        expect(a.citation, contains('W v Egdell'));
      });

      test('NHSX adult mental-health retention is 20 years', () {
        final a = alerts.firstWhere(
          (e) => e.id == 'UK.documentationRetention.nhsx',
        );
        expect(a.body, contains('20 years'));
      });
    });

    group('Austria', () {
      final alerts = svc.alertsForCountry('AT');

      test('5 alerts shipped', () {
        expect(alerts.length, 5);
      });

      test('§ 121 StGB Notstand alert is critical', () {
        final a = alerts.firstWhere((e) => e.id == 'AT.dutyToWarn.stgb121');
        expect(a.severity, AlertSeverity.critical);
        expect(a.citation, contains('§§ 121, 10 StGB'));
      });

      test('B-KJHG child notification is critical + cites § 49 ÄrzteG', () {
        final a = alerts.firstWhere(
          (e) => e.id == 'AT.mandatoryReporting.child',
        );
        expect(a.severity, AlertSeverity.critical);
        expect(a.citation, contains('§ 49 ÄrzteG'));
      });

      test('ELGA + telemedicine guidance flagged', () {
        final a = alerts.firstWhere(
          (e) => e.id == 'AT.telehealthLicensure.eheilg',
        );
        expect(a.body, contains('ELGA'));
      });
    });

    test('alertsForMultipleCountries concatenates without dedup', () {
      final bundle = svc.alertsForMultipleCountries(['DE', 'UK', 'AT']);
      expect(bundle.length, 5 + 6 + 5);
    });

    test('hasCriticalAlert true for all 3 supported countries', () {
      expect(svc.hasCriticalAlert(svc.alertsForCountry('DE')), true);
      expect(svc.hasCriticalAlert(svc.alertsForCountry('UK')), true);
      expect(svc.hasCriticalAlert(svc.alertsForCountry('AT')), true);
      expect(svc.hasCriticalAlert([]), false);
    });
  });
}
