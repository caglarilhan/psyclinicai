import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/models/cssrs_administration_mode.dart';

void main() {
  group('CssrsAdministrationMode', () {
    test('clinician escalation threshold is Q4 (Posner)', () {
      expect(
        CssrsAdministrationMode.clinicianAdministered.escalationItem,
        4,
      );
    });

    test('self-rated escalation threshold is Q3 (Mundt 2013)', () {
      expect(CssrsAdministrationMode.selfRated.escalationItem, 3);
    });

    test('fromId is round-trip safe + clinician default', () {
      expect(CssrsAdministrationMode.fromId('self'),
          CssrsAdministrationMode.selfRated);
      expect(CssrsAdministrationMode.fromId('unknown'),
          CssrsAdministrationMode.clinicianAdministered);
    });

    test('instructions differ between modes (avoids unsafe single UI)', () {
      expect(
        CssrsAdministrationMode.clinicianAdministered.instructions,
        isNot(equals(CssrsAdministrationMode.selfRated.instructions)),
      );
      expect(
        CssrsAdministrationMode.selfRated.instructions,
        contains('your clinician will review'),
      );
    });
  });
}
