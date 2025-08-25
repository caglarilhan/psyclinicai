import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/medication_service.dart';
import 'package:psyclinicai/models/medication_models.dart';

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

    test('Risperidone + Venlafaxine should raise QT risk (>= moderate)', () async {
      final service = MedicationService();
      await service.initialize();

      final result = await service.checkDrugInteractions(
        medicationIds: ['risperidone', 'venlafaxine'],
      );

      expect(result.any((i) => i.severity.name == 'moderate' || i.severity.name == 'major'), isTrue,
          reason: 'Risperidone+Venlafaxine QT riski nedeniyle en az orta şiddet olmalı');
    });

    test('Fluoxetine + Codeine should reduce analgesia via CYP2D6 (>= moderate)', () async {
      final service = MedicationService();
      await service.initialize();
      final result = await service.checkDrugInteractions(
        medicationIds: ['fluoxetine', 'codeine'],
      );
      expect(result.any((i) => i.severity == InteractionSeverity.moderate || i.severity == InteractionSeverity.major), isTrue,
          reason: 'Fluoxetine CYP2D6 inhibisyonu ile codeine etkisini düşürür');
    });

    test('Carbamazepine + Quetiapine should lower levels via CYP3A4 (>= moderate)', () async {
      final service = MedicationService();
      await service.initialize();
      final result = await service.checkDrugInteractions(
        medicationIds: ['carbamazepine', 'quetiapine'],
      );
      expect(result.any((i) => i.severity == InteractionSeverity.moderate || i.severity == InteractionSeverity.major), isTrue,
          reason: 'Carbamazepine CYP3A4 indükleyicidir, quetiapine düzeyini düşürür');
    });

    test('Grapefruit + Simvastatin should raise levels via CYP3A4 (major)', () async {
      final service = MedicationService();
      await service.initialize();
      final result = await service.checkDrugInteractions(
        medicationIds: ['grapefruit', 'simvastatin'],
      );
      expect(result.any((i) => i.severity == InteractionSeverity.major || i.severity == InteractionSeverity.contraindicated), isTrue,
          reason: 'Greyfurt 3A4 inhibisyonu ile simvastatin düzeyini yükseltir, miyopati riski');
    });
  });
}
