/// The "Clinical Lens" — the selected therapeutic modality's own constructs
/// extracted from a session (Schema → triggered schemas + active modes; CBT →
/// automatic thoughts + distortions; Psychodynamic → defenses + transference,
/// …). This is the clinical-depth engine that separates us from generic SOAP
/// scribes. Decision-support — surfaces what the transcript supports, never
/// invents clinical material.
class LensSection {
  const LensSection({required this.title, required this.items});
  final String title;
  final List<String> items;
}

class ClinicalLens {
  const ClinicalLens({required this.modalityLabel, required this.sections});

  final String modalityLabel;
  final List<LensSection> sections;

  bool get isEmpty => sections.every((s) => s.items.isEmpty);
}
