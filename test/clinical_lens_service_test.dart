import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/copilot/clinical_lens_service.dart';
import 'package:psyclinicai/services/copilot/soap_generator_service.dart'
    show Modality;

void main() {
  final svc = ClinicalLensService();

  test('every modality has a non-empty construct set', () {
    for (final m in Modality.values) {
      expect(
        ClinicalLensService.constructsFor(m),
        isNotEmpty,
        reason: '$m has no constructs',
      );
    }
  });

  test('schema constructs include modes', () {
    final c = ClinicalLensService.constructsFor(Modality.schema);
    expect(c, contains('Active modes'));
    expect(c, contains('Triggered schemas'));
  });

  test('parse keeps allowed sections, drops unknown + empty', () {
    const json =
        '{"sections":['
        '{"title":"Triggered schemas","items":["Defectiveness","Abandonment"]},'
        '{"title":"Active modes","items":["Punitive parent"]},'
        '{"title":"Made up section","items":["x"]},'
        '{"title":"Mode work / interventions","items":[]}'
        ']}';
    final lens = svc.parse(json, Modality.schema)!;
    expect(lens.modalityLabel, 'Schema');
    expect(lens.sections, hasLength(2)); // unknown + empty dropped
    expect(lens.sections.first.title, 'Triggered schemas');
    expect(lens.sections.first.items, hasLength(2));
  });

  test(
    'parse tolerates surrounding prose and returns null when nothing valid',
    () {
      expect(svc.parse('no json here', Modality.cbt), isNull);
      expect(
        svc.parse(
          '{"sections":[{"title":"Nope","items":["a"]}]}',
          Modality.cbt,
        ),
        isNull,
      );
    },
  );

  test('cbt parse maps its own constructs', () {
    const json =
        '{"sections":['
        '{"title":"Automatic thoughts","items":["I always fail"]},'
        '{"title":"Cognitive distortions","items":["Catastrophizing"]}'
        ']}';
    final lens = svc.parse(json, Modality.cbt)!;
    expect(lens.modalityLabel, 'CBT');
    expect(
      lens.sections.map((s) => s.title),
      containsAll(['Automatic thoughts', 'Cognitive distortions']),
    );
  });
}
