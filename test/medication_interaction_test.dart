import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/medication_service.dart';

void main() {
  group('Medication Interaction Rules', () {
    test('SSRI + MAOI should be contraindicated (static or rule)', () async {
      final service = MedicationService();
      await service.initialize();

      final result = await service.checkDrugInteractions(
        medicationIds: ['sertraline', 'maoi'],
      );

      expect(result.any((i) => i.severity.name == 'contraindicated'), isTrue,
          reason: 'SSRI+MAOI kontrendike olmalı');
    });

    test('Lithium + Sertraline should be at least moderate (static or rule)', () async {
      final service = MedicationService();
      await service.initialize();

      final result = await service.checkDrugInteractions(
        medicationIds: ['lithium', 'sertraline'],
      );

      expect(result.any((i) => i.severity.name == 'moderate' || i.severity.name == 'major'), isTrue,
          reason: 'Lithium+SSRI en az orta şiddette etkileşim olmalı');
    });
  });
}
