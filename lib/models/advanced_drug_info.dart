import 'package:flutter/foundation.dart';

class DrugContent {
  final String ingredient;
  final double amount;
  final String unit; // mg, mcg, g, ml
  final String type; // active, inactive, preservative

  DrugContent({
    required this.ingredient,
    required this.amount,
    required this.unit,
    required this.type,
  });

  factory DrugContent.fromJson(Map<String, dynamic> json) => DrugContent(
    ingredient: json['ingredient'],
    amount: json['amount'].toDouble(),
    unit: json['unit'],
    type: json['type'],
  );

  Map<String, dynamic> toJson() => {
    'ingredient': ingredient,
    'amount': amount,
    'unit': unit,
    'type': type,
  };
}

class DrugDosage {
  final String form; // tablet, kapsül, şurup, enjeksiyon
  final List<String> strengths; // ["500mg", "1000mg"]
  final String frequency; // "günde 3 kez", "günde 1 kez"
  final String duration; // "7 gün", "sürekli"
  final String administration; // "yemeklerle", "aç karnına"
  final String maxDailyDose;

  DrugDosage({
    required this.form,
    required this.strengths,
    required this.frequency,
    required this.duration,
    required this.administration,
    required this.maxDailyDose,
  });

  factory DrugDosage.fromJson(Map<String, dynamic> json) => DrugDosage(
    form: json['form'],
    strengths: List<String>.from(json['strengths']),
    frequency: json['frequency'],
    duration: json['duration'],
    administration: json['administration'],
    maxDailyDose: json['maxDailyDose'],
  );

  Map<String, dynamic> toJson() => {
    'form': form,
    'strengths': strengths,
    'frequency': frequency,
    'duration': duration,
    'administration': administration,
    'maxDailyDose': maxDailyDose,
  };
}

class DrugInteraction {
  final String drugId;
  final String interactionType; // "major", "moderate", "minor"
  final String description;
  final String mechanism;
  final String recommendation;
  final String severity; // "high", "medium", "low"

  DrugInteraction({
    required this.drugId,
    required this.interactionType,
    required this.description,
    required this.mechanism,
    required this.recommendation,
    required this.severity,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) => DrugInteraction(
    drugId: json['drugId'],
    interactionType: json['interactionType'],
    description: json['description'],
    mechanism: json['mechanism'],
    recommendation: json['recommendation'],
    severity: json['severity'],
  );

  Map<String, dynamic> toJson() => {
    'drugId': drugId,
    'interactionType': interactionType,
    'description': description,
    'mechanism': mechanism,
    'recommendation': recommendation,
    'severity': severity,
  };
}

class AdvancedDrugInfo {
  final String id;
  final String genericName;
  final String brandName;
  final List<DrugContent> contents;
  final List<DrugDosage> dosages;
  final String category;
  final String indication;
  final List<String> contraindications;
  final List<String> sideEffects;
  final String pregnancyCategory;
  final String lactationCategory;
  final List<DrugInteraction> interactions;
  final Map<String, dynamic> pharmacokinetics;
  final Map<String, dynamic> pharmacodynamics;
  final List<String> warnings;
  final Map<String, dynamic> countrySpecific;
  final String atcCode;
  final String reimbursementCode;
  final Map<String, String> warningsByCountry;

  AdvancedDrugInfo({
    required this.id,
    required this.genericName,
    required this.brandName,
    required this.contents,
    required this.dosages,
    required this.category,
    required this.indication,
    required this.contraindications,
    required this.sideEffects,
    required this.pregnancyCategory,
    required this.lactationCategory,
    required this.interactions,
    required this.pharmacokinetics,
    required this.pharmacodynamics,
    required this.warnings,
    required this.countrySpecific,
    required this.atcCode,
    required this.reimbursementCode,
    required this.warningsByCountry,
  });

  factory AdvancedDrugInfo.fromJson(Map<String, dynamic> json) => AdvancedDrugInfo(
    id: json['id'],
    genericName: json['genericName'],
    brandName: json['brandName'],
    contents: (json['contents'] as List)
        .map((c) => DrugContent.fromJson(c))
        .toList(),
    dosages: (json['dosages'] as List)
        .map((d) => DrugDosage.fromJson(d))
        .toList(),
    category: json['category'],
    indication: json['indication'],
    contraindications: List<String>.from(json['contraindications']),
    sideEffects: List<String>.from(json['sideEffects']),
    pregnancyCategory: json['pregnancyCategory'],
    lactationCategory: json['lactationCategory'],
    interactions: (json['interactions'] as List)
        .map((i) => DrugInteraction.fromJson(i))
        .toList(),
    pharmacokinetics: Map<String, dynamic>.from(json['pharmacokinetics'] ?? {}),
    pharmacodynamics: Map<String, dynamic>.from(json['pharmacodynamics'] ?? {}),
    warnings: List<String>.from(json['warnings'] ?? []),
    countrySpecific: Map<String, dynamic>.from(json['countrySpecific'] ?? {}),
    atcCode: json['atcCode'],
    reimbursementCode: json['reimbursementCode'],
    warningsByCountry: Map<String, String>.from(json['warningsByCountry'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'genericName': genericName,
    'brandName': brandName,
    'contents': contents.map((c) => c.toJson()).toList(),
    'dosages': dosages.map((d) => d.toJson()).toList(),
    'category': category,
    'indication': indication,
    'contraindications': contraindications,
    'sideEffects': sideEffects,
    'pregnancyCategory': pregnancyCategory,
    'lactationCategory': lactationCategory,
    'interactions': interactions.map((i) => i.toJson()).toList(),
    'pharmacokinetics': pharmacokinetics,
    'pharmacodynamics': pharmacodynamics,
    'warnings': warnings,
    'countrySpecific': countrySpecific,
    'atcCode': atcCode,
    'reimbursementCode': reimbursementCode,
    'warningsByCountry': warningsByCountry,
  };
}
