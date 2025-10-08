import 'dart:convert';
import 'dart:io';

import 'models.dart';
import 'dart:math';

class ClinicalAdvisor {
  final Map<String, dynamic> _kb;

  ClinicalAdvisor._(this._kb);

  static Future<ClinicalAdvisor> fromAssetPath(String jsonPath) async {
    final file = File(jsonPath);
    final text = await file.readAsString();
    final data = json.decode(text) as Map<String, dynamic>;
    return ClinicalAdvisor._(data);
  }

  AdvicePlan advise(ClinicalInput input) {
    final lower = input.summary.toLowerCase();
    final disorders = (_kb['disorders'] as List).cast<Map<String, dynamic>>();

    final matched = <Map<String, dynamic>>[];
    for (final d in disorders) {
      final kw = (d['keywords'] as List).cast<String>();
      if (kw.any((k) => lower.contains(k.toLowerCase()))) {
        matched.add(d);
      }
    }

    final categories = matched.map((d) => d['name'] as String).toList();

    final redFlags = <String>{};
    for (final d in matched) {
      for (final rf in (d['red_flags'] as List).cast<String>()) {
        if (lower.contains(rf.toLowerCase())) redFlags.add(rf);
      }
    }

    final psycho = <AdviceItem>[];
    final psychoList = matched.expand((d) => (d['psychoeducation'] as List).cast<Map<String, dynamic>>());
    for (final m in psychoList) {
      psycho.add(AdviceItem(title: m['title'] as String, detail: m['detail'] as String));
    }

    final therapy = <AdviceItem>[];
    final therapyList = matched.expand((d) => (d['psychotherapy'] as List).cast<Map<String, dynamic>>());
    for (final m in therapyList) {
      therapy.add(AdviceItem(title: m['title'] as String, detail: m['detail'] as String));
    }

    final monitoring = <AdviceItem>[];
    final monList = matched.expand((d) => (d['monitoring'] as List).cast<Map<String, dynamic>>());
    for (final m in monList) {
      monitoring.add(AdviceItem(title: m['title'] as String, detail: m['detail'] as String));
    }

    final pharm = <AdviceItem>[];
    if (input.role.toLowerCase() == 'psychiatrist') {
      final region = input.region.toUpperCase();
      final pharmList = matched.expand((d) => (d['pharmacology'] as Map<String, dynamic>)[region] as List? ?? const []);
      for (final m in pharmList.cast<Map<String, dynamic>>()) {
        pharm.add(AdviceItem(title: m['title'] as String, detail: m['detail'] as String));
      }
    }

    return AdvicePlan(
      probableCategories: categories,
      redFlags: redFlags.toList(),
      psychoeducation: psycho,
      psychotherapy: therapy,
      monitoring: monitoring,
      pharmacology: pharm,
    );
  }

  List<DisorderSummary> listDisorders() {
    final disorders = (_kb['disorders'] as List).cast<Map<String, dynamic>>();
    return disorders
        .map((d) => DisorderSummary(id: d['id'] as String, name: d['name'] as String))
        .toList();
  }

  AdvicePlan adviseByDisorder({
    required String disorderId,
    required ClinicalInput context,
  }) {
    final disorders = (_kb['disorders'] as List).cast<Map<String, dynamic>>();
    final match = disorders.firstWhere((d) => d['id'] == disorderId, orElse: () => {});
    if (match.isEmpty) {
      return const AdvicePlan();
    }
    final cat = (match['name'] as String?) ?? disorderId;
    final input = ClinicalInput(
      role: context.role,
      region: context.region,
      summary: cat,
      tags: context.tags,
    );
    return advise(input);
  }

  AdvicePlan adviseRandom({required ClinicalInput context}) {
    final disorders = (_kb['disorders'] as List).cast<Map<String, dynamic>>();
    if (disorders.isEmpty) return const AdvicePlan();
    final idx = Random().nextInt(disorders.length);
    final id = disorders[idx]['id'] as String;
    return adviseByDisorder(disorderId: id, context: context);
  }
}

