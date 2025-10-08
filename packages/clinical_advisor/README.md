# clinical_advisor (MVP)

Role/region-aware clinical advisor with a JSON knowledge base.

## Install (path dependency)

In your root pubspec.yaml:

```yaml
  clinical_advisor:
    path: packages/clinical_advisor
```

## Usage

```dart
import 'package:clinical_advisor/clinical_advisor.dart';

final advisor = await ClinicalAdvisor.fromAssetPath('packages/clinical_advisor/lib/src/kb/disorders_min.json');
final plan = advisor.advise(
  ClinicalInput(
    role: 'psychologist',
    region: 'TR',
    summary: 'hasta manik dönem belirtileri, uykusuzluk ve taşkınlık yaşıyor',
  ),
);
print(plan.probableCategories);
```

### List disorders
```dart
final all = advisor.listDisorders(); // List<DisorderSummary>
```

### Advise for a specific disorder
```dart
final specific = advisor.adviseByDisorder(
  disorderId: 'bipolar',
  context: ClinicalInput(role: 'psychiatrist', region: 'US', summary: ''),
);
```

### Advise randomly
```dart
final randomPlan = advisor.adviseRandom(
  context: ClinicalInput(role: 'psychologist', region: 'TR', summary: ''),
);
```

## Notes
- Pharmacology list is informational and only returned for role=psychiatrist.
- Red flags are heuristic keyword matches; human-in-the-loop is required.

