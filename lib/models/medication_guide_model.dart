import 'package:flutter/material.dart';

enum MedicationCategory {
  antidepressant,
  anxiolytic,
  antipsychotic,
  moodStabilizer,
  stimulant,
  hypnotic,
  anticonvulsant,
  antianxiety,
  antimanic,
  anticholinergic,
  antihistamine,
  betaBlocker,
  calciumChannelBlocker,
  aceInhibitor,
  angiotensinReceptorBlocker,
  diuretic,
  statin,
  antiplatelet,
  anticoagulant,
  nsaid,
  opioid,
  muscleRelaxant,
  antiepileptic,
  antiparkinsonian,
  antialzheimer,
  antimigraine,
  antinausea,
  antidiabetic,
  thyroid,
  corticosteroid,
  immunosuppressant,
  antiviral,
  antibacterial,
  antifungal,
  other,
}

class MedicationModel {
  final String id;
  final String name;
  final String genericName;
  final List<String> brandNames;
  final List<String> internationalNames;
  final MedicationCategory category;
  final String subcategory;
  final List<String> indications;
  final List<String> offLabelIndications;
  final String dosage;
  final String administration;
  final String mechanism;
  final List<String> sideEffects;
  final List<String> seriousSideEffects;
  final List<String> contraindications;
  final List<String> interactions;
  final List<String> warnings;
  final List<String> precautions;
  final String pregnancyCategory;
  final String lactationCategory;
  final String pediatricUse;
  final String geriatricUse;
  final String hepaticImpairment;
  final String renalImpairment;
  final String halfLife;
  final String metabolism;
  final String excretion;
  final Map<String, String> approvalStatus;
  final Map<String, DateTime> approvalDates;
  final Map<String, String> regulatoryStatus;
  final String cost;
  final String availability;
  final List<String> alternatives;
  final List<String> combinationProducts;
  final Map<String, dynamic> clinicalData;
  final List<ClinicalTrial> clinicalTrials;
  final List<Publication> publications;
  final Map<String, String> guidelines;
  final String notes;
  final DateTime? lastUpdated;
  final String dataSource;
  final String evidenceQuality;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.genericName,
    required this.brandNames,
    required this.internationalNames,
    required this.category,
    required this.subcategory,
    required this.indications,
    required this.offLabelIndications,
    required this.dosage,
    required this.administration,
    required this.mechanism,
    required this.sideEffects,
    required this.seriousSideEffects,
    required this.contraindications,
    required this.interactions,
    required this.warnings,
    required this.precautions,
    required this.pregnancyCategory,
    required this.lactationCategory,
    required this.pediatricUse,
    required this.geriatricUse,
    required this.hepaticImpairment,
    required this.renalImpairment,
    required this.halfLife,
    required this.metabolism,
    required this.excretion,
    required this.approvalStatus,
    required this.approvalDates,
    required this.regulatoryStatus,
    required this.cost,
    required this.availability,
    required this.alternatives,
    required this.combinationProducts,
    required this.clinicalData,
    required this.clinicalTrials,
    required this.publications,
    required this.guidelines,
    required this.notes,
    this.lastUpdated,
    required this.dataSource,
    required this.evidenceQuality,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genericName: json['genericName'] ?? '',
      brandNames: List<String>.from(json['brandNames'] ?? []),
      internationalNames: List<String>.from(json['internationalNames'] ?? []),
      category: MedicationCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => MedicationCategory.other,
      ),
      subcategory: json['subcategory'] ?? '',
      indications: List<String>.from(json['indications'] ?? []),
      offLabelIndications: List<String>.from(json['offLabelIndications'] ?? []),
      dosage: json['dosage'] ?? '',
      administration: json['administration'] ?? '',
      mechanism: json['mechanism'] ?? '',
      sideEffects: List<String>.from(json['sideEffects'] ?? []),
      seriousSideEffects: List<String>.from(json['seriousSideEffects'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      interactions: List<String>.from(json['interactions'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      precautions: List<String>.from(json['precautions'] ?? []),
      pregnancyCategory: json['pregnancyCategory'] ?? '',
      lactationCategory: json['lactationCategory'] ?? '',
      pediatricUse: json['pediatricUse'] ?? '',
      geriatricUse: json['geriatricUse'] ?? '',
      hepaticImpairment: json['hepaticImpairment'] ?? '',
      renalImpairment: json['renalImpairment'] ?? '',
      halfLife: json['halfLife'] ?? '',
      metabolism: json['metabolism'] ?? '',
      excretion: json['excretion'] ?? '',
      approvalStatus: Map<String, String>.from(json['approvalStatus'] ?? {}),
      approvalDates: (json['approvalDates'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DateTime.parse(value)),
          ) ??
          {},
      regulatoryStatus:
          Map<String, String>.from(json['regulatoryStatus'] ?? {}),
      cost: json['cost'] ?? '',
      availability: json['availability'] ?? '',
      alternatives: List<String>.from(json['alternatives'] ?? []),
      combinationProducts: List<String>.from(json['combinationProducts'] ?? []),
      clinicalData: Map<String, dynamic>.from(json['clinicalData'] ?? {}),
      clinicalTrials: (json['clinicalTrials'] as List<dynamic>?)
              ?.map((trial) => ClinicalTrial.fromJson(trial))
              .toList() ??
          [],
      publications: (json['publications'] as List<dynamic>?)
              ?.map((pub) => Publication.fromJson(pub))
              .toList() ??
          [],
      guidelines: Map<String, String>.from(json['guidelines'] ?? {}),
      notes: json['notes'] ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      dataSource: json['dataSource'] ?? '',
      evidenceQuality: json['evidenceQuality'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'brandNames': brandNames,
      'internationalNames': internationalNames,
      'category': category.name,
      'subcategory': subcategory,
      'indications': indications,
      'offLabelIndications': offLabelIndications,
      'dosage': dosage,
      'administration': administration,
      'mechanism': mechanism,
      'sideEffects': sideEffects,
      'seriousSideEffects': seriousSideEffects,
      'contraindications': contraindications,
      'interactions': interactions,
      'warnings': warnings,
      'precautions': precautions,
      'pregnancyCategory': pregnancyCategory,
      'lactationCategory': lactationCategory,
      'pediatricUse': pediatricUse,
      'geriatricUse': geriatricUse,
      'hepaticImpairment': hepaticImpairment,
      'renalImpairment': renalImpairment,
      'halfLife': halfLife,
      'metabolism': metabolism,
      'excretion': excretion,
      'approvalStatus': approvalStatus,
      'approvalDates': approvalDates
          .map((key, value) => MapEntry(key, value.toIso8601String())),
      'regulatoryStatus': regulatoryStatus,
      'cost': cost,
      'availability': availability,
      'alternatives': alternatives,
      'combinationProducts': combinationProducts,
      'clinicalData': clinicalData,
      'clinicalTrials': clinicalTrials.map((trial) => trial.toJson()).toList(),
      'publications': publications.map((pub) => pub.toJson()).toList(),
      'guidelines': guidelines,
      'notes': notes,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'dataSource': dataSource,
      'evidenceQuality': evidenceQuality,
    };
  }

  // Kategori rengi
  Color get categoryColor {
    switch (category) {
      case MedicationCategory.antidepressant:
        return Colors.blue;
      case MedicationCategory.anxiolytic:
        return Colors.green;
      case MedicationCategory.antipsychotic:
        return Colors.red;
      case MedicationCategory.moodStabilizer:
        return Colors.orange;
      case MedicationCategory.stimulant:
        return Colors.purple;
      case MedicationCategory.hypnotic:
        return Colors.indigo;
      case MedicationCategory.anticonvulsant:
        return Colors.teal;
      case MedicationCategory.antianxiety:
        return Colors.lightGreen;
      case MedicationCategory.antimanic:
        return Colors.deepOrange;
      case MedicationCategory.anticholinergic:
        return Colors.brown;
      case MedicationCategory.antihistamine:
        return Colors.cyan;
      case MedicationCategory.betaBlocker:
        return Colors.amber;
      case MedicationCategory.calciumChannelBlocker:
        return Colors.lime;
      case MedicationCategory.aceInhibitor:
        return Colors.pink;
      case MedicationCategory.angiotensinReceptorBlocker:
        return Colors.deepPurple;
      case MedicationCategory.diuretic:
        return Colors.lightBlue;
      case MedicationCategory.statin:
        return Colors.redAccent;
      case MedicationCategory.antiplatelet:
        return Colors.orangeAccent;
      case MedicationCategory.anticoagulant:
        return Colors.red.shade300;
      case MedicationCategory.nsaid:
        return Colors.blueGrey;
      case MedicationCategory.opioid:
        return Colors.deepPurpleAccent;
      case MedicationCategory.muscleRelaxant:
        return Colors.lightGreenAccent;
      case MedicationCategory.antiepileptic:
        return Colors.tealAccent;
      case MedicationCategory.antiparkinsonian:
        return Colors.yellow;
      case MedicationCategory.antialzheimer:
        return Colors.blueAccent;
      case MedicationCategory.antimigraine:
        return Colors.purpleAccent;
      case MedicationCategory.antinausea:
        return Colors.greenAccent;
      case MedicationCategory.antidiabetic:
        return Colors.orange.shade300;
      case MedicationCategory.thyroid:
        return Colors.yellowAccent;
      case MedicationCategory.corticosteroid:
        return Colors.red.shade200;
      case MedicationCategory.immunosuppressant:
        return Colors.indigo;
      case MedicationCategory.antiviral:
        return Colors.purple.shade300;
      case MedicationCategory.antibacterial:
        return Colors.blue.shade300;
      case MedicationCategory.antifungal:
        return Colors.green.shade300;
      case MedicationCategory.other:
        return Colors.grey;
    }
  }

  // Kategori adı
  String get categoryName {
    switch (category) {
      case MedicationCategory.antidepressant:
        return 'Antidepresan';
      case MedicationCategory.anxiolytic:
        return 'Anksiyolitik';
      case MedicationCategory.antipsychotic:
        return 'Antipsikotik';
      case MedicationCategory.moodStabilizer:
        return 'Duygu Durum Dengeleyici';
      case MedicationCategory.stimulant:
        return 'Uyarıcı';
      case MedicationCategory.hypnotic:
        return 'Hipnotik';
      case MedicationCategory.anticonvulsant:
        return 'Antikonvülsan';
      case MedicationCategory.antianxiety:
        return 'Antianksiyete';
      case MedicationCategory.antimanic:
        return 'Antimanik';
      case MedicationCategory.anticholinergic:
        return 'Antikolinerjik';
      case MedicationCategory.antihistamine:
        return 'Antihistaminik';
      case MedicationCategory.betaBlocker:
        return 'Beta Bloker';
      case MedicationCategory.calciumChannelBlocker:
        return 'Kalsiyum Kanal Blokeri';
      case MedicationCategory.aceInhibitor:
        return 'ACE İnhibitörü';
      case MedicationCategory.angiotensinReceptorBlocker:
        return 'Anjiyotensin Reseptör Blokeri';
      case MedicationCategory.diuretic:
        return 'Diüretik';
      case MedicationCategory.statin:
        return 'Statin';
      case MedicationCategory.antiplatelet:
        return 'Antitrombosit';
      case MedicationCategory.anticoagulant:
        return 'Antikoagülan';
      case MedicationCategory.nsaid:
        return 'NSAID';
      case MedicationCategory.opioid:
        return 'Opioid';
      case MedicationCategory.muscleRelaxant:
        return 'Kas Gevşetici';
      case MedicationCategory.antiepileptic:
        return 'Antiepileptik';
      case MedicationCategory.antiparkinsonian:
        return 'Antiparkinsonian';
      case MedicationCategory.antialzheimer:
        return 'Antialzheimer';
      case MedicationCategory.antimigraine:
        return 'Antimigren';
      case MedicationCategory.antinausea:
        return 'Antinausea';
      case MedicationCategory.antidiabetic:
        return 'Antidiabetik';
      case MedicationCategory.thyroid:
        return 'Tiroid';
      case MedicationCategory.corticosteroid:
        return 'Kortikosteroid';
      case MedicationCategory.immunosuppressant:
        return 'İmmünosupressan';
      case MedicationCategory.antiviral:
        return 'Antiviral';
      case MedicationCategory.antibacterial:
        return 'Antibakteriyel';
      case MedicationCategory.antifungal:
        return 'Antifungal';
      case MedicationCategory.other:
        return 'Diğer';
    }
  }

  // Gebelik kategorisi rengi
  Color get pregnancyColor {
    switch (pregnancyCategory) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      case 'X':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  // Emzirme kategorisi rengi
  Color get lactationColor {
    switch (lactationCategory) {
      case 'L1':
        return Colors.green;
      case 'L2':
        return Colors.lightGreen;
      case 'L3':
        return Colors.orange;
      case 'L4':
        return Colors.red;
      case 'L5':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  // Onay durumu rengi
  Color getApprovalStatusColor(String authority) {
    final status = approvalStatus[authority];
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'withdrawn':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  // Kanıt kalitesi rengi
  Color get evidenceQualityColor {
    switch (evidenceQuality.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.orange;
      case 'd':
        return Colors.red;
      case 'e':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  // Copy with metodu
  MedicationModel copyWith({
    String? id,
    String? name,
    String? genericName,
    List<String>? brandNames,
    List<String>? internationalNames,
    MedicationCategory? category,
    String? subcategory,
    List<String>? indications,
    List<String>? offLabelIndications,
    String? dosage,
    String? administration,
    String? mechanism,
    List<String>? sideEffects,
    List<String>? seriousSideEffects,
    List<String>? contraindications,
    List<String>? interactions,
    List<String>? warnings,
    List<String>? precautions,
    String? pregnancyCategory,
    String? lactationCategory,
    String? pediatricUse,
    String? geriatricUse,
    String? hepaticImpairment,
    String? renalImpairment,
    String? halfLife,
    String? metabolism,
    String? excretion,
    Map<String, String>? approvalStatus,
    Map<String, DateTime>? approvalDates,
    Map<String, String>? regulatoryStatus,
    String? cost,
    String? availability,
    List<String>? alternatives,
    List<String>? combinationProducts,
    Map<String, dynamic>? clinicalData,
    List<ClinicalTrial>? clinicalTrials,
    List<Publication>? publications,
    Map<String, String>? guidelines,
    String? notes,
    DateTime? lastUpdated,
    String? dataSource,
    String? evidenceQuality,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      brandNames: brandNames ?? this.brandNames,
      internationalNames: internationalNames ?? this.internationalNames,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      indications: indications ?? this.indications,
      offLabelIndications: offLabelIndications ?? this.offLabelIndications,
      dosage: dosage ?? this.dosage,
      administration: administration ?? this.administration,
      mechanism: mechanism ?? this.mechanism,
      sideEffects: sideEffects ?? this.sideEffects,
      seriousSideEffects: seriousSideEffects ?? this.seriousSideEffects,
      contraindications: contraindications ?? this.contraindications,
      interactions: interactions ?? this.interactions,
      warnings: warnings ?? this.warnings,
      precautions: precautions ?? this.precautions,
      pregnancyCategory: pregnancyCategory ?? this.pregnancyCategory,
      lactationCategory: lactationCategory ?? this.lactationCategory,
      pediatricUse: pediatricUse ?? this.pediatricUse,
      geriatricUse: geriatricUse ?? this.geriatricUse,
      hepaticImpairment: hepaticImpairment ?? this.hepaticImpairment,
      renalImpairment: renalImpairment ?? this.renalImpairment,
      halfLife: halfLife ?? this.halfLife,
      metabolism: metabolism ?? this.metabolism,
      excretion: excretion ?? this.excretion,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approvalDates: approvalDates ?? this.approvalDates,
      regulatoryStatus: regulatoryStatus ?? this.regulatoryStatus,
      cost: cost ?? this.cost,
      availability: availability ?? this.availability,
      alternatives: alternatives ?? this.alternatives,
      combinationProducts: combinationProducts ?? this.combinationProducts,
      clinicalData: clinicalData ?? this.clinicalData,
      clinicalTrials: clinicalTrials ?? this.clinicalTrials,
      publications: publications ?? this.publications,
      guidelines: guidelines ?? this.guidelines,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      dataSource: dataSource ?? this.dataSource,
      evidenceQuality: evidenceQuality ?? this.evidenceQuality,
    );
  }

  @override
  String toString() {
    return 'MedicationModel(id: $id, name: $name, category: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DrugInteraction {
  final String id;
  final String medication1Id;
  final String medication2Id;
  final String severity; // Minor, Moderate, Major, Contraindicated
  final String description;
  final String mechanism;
  final List<String> recommendations;
  final String evidenceLevel; // A, B, C, D, E
  final String source;
  final DateTime? lastUpdated;
  final String? clinicalSignificance;
  final List<String>? monitoringParameters;
  final String? onset;
  final String? duration;

  const DrugInteraction({
    required this.id,
    required this.medication1Id,
    required this.medication2Id,
    required this.severity,
    required this.description,
    required this.mechanism,
    required this.recommendations,
    required this.evidenceLevel,
    required this.source,
    this.lastUpdated,
    this.clinicalSignificance,
    this.monitoringParameters,
    this.onset,
    this.duration,
  });

  factory DrugInteraction.fromJson(Map<String, dynamic> json) {
    return DrugInteraction(
      id: json['id'] ?? '',
      medication1Id: json['medication1Id'] ?? '',
      medication2Id: json['medication2Id'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
      mechanism: json['mechanism'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
      evidenceLevel: json['evidenceLevel'] ?? '',
      source: json['source'] ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      clinicalSignificance: json['clinicalSignificance'],
      monitoringParameters: json['monitoringParameters'] != null
          ? List<String>.from(json['monitoringParameters'])
          : null,
      onset: json['onset'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medication1Id': medication1Id,
      'medication2Id': medication2Id,
      'severity': severity,
      'description': description,
      'mechanism': mechanism,
      'recommendations': recommendations,
      'evidenceLevel': evidenceLevel,
      'source': source,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'clinicalSignificance': clinicalSignificance,
      'monitoringParameters': monitoringParameters,
      'onset': onset,
      'duration': duration,
    };
  }

  // Severity rengi
  Color get severityColor {
    switch (severity.toLowerCase()) {
      case 'minor':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'major':
        return Colors.red;
      case 'contraindicated':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  // Evidence level rengi
  Color get evidenceColor {
    switch (evidenceLevel.toLowerCase()) {
      case 'a':
        return Colors.green;
      case 'b':
        return Colors.lightGreen;
      case 'c':
        return Colors.orange;
      case 'd':
        return Colors.red;
      case 'e':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }
}

class ClinicalTrial {
  final String id;
  final String title;
  final String phase;
  final String status;
  final DateTime? startDate;
  final DateTime? completionDate;
  final String sponsor;
  final String description;
  final List<String> outcomes;
  final String? results;

  const ClinicalTrial({
    required this.id,
    required this.title,
    required this.phase,
    required this.status,
    this.startDate,
    this.completionDate,
    required this.sponsor,
    required this.description,
    required this.outcomes,
    this.results,
  });

  factory ClinicalTrial.fromJson(Map<String, dynamic> json) {
    return ClinicalTrial(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      phase: json['phase'] ?? '',
      status: json['status'] ?? '',
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      completionDate: json['completionDate'] != null
          ? DateTime.parse(json['completionDate'])
          : null,
      sponsor: json['sponsor'] ?? '',
      description: json['description'] ?? '',
      outcomes: List<String>.from(json['outcomes'] ?? []),
      results: json['results'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'phase': phase,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'completionDate': completionDate?.toIso8601String(),
      'sponsor': sponsor,
      'description': description,
      'outcomes': outcomes,
      'results': results,
    };
  }
}

class Publication {
  final String id;
  final String title;
  final String authors;
  final String journal;
  final DateTime? publicationDate;
  final String? doi;
  final String? abstract;
  final List<String> keywords;

  const Publication({
    required this.id,
    required this.title,
    required this.authors,
    required this.journal,
    this.publicationDate,
    this.doi,
    this.abstract,
    required this.keywords,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      authors: json['authors'] ?? '',
      journal: json['journal'] ?? '',
      publicationDate: json['publicationDate'] != null
          ? DateTime.parse(json['publicationDate'])
          : null,
      doi: json['doi'],
      abstract: json['abstract'],
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'journal': journal,
      'publicationDate': publicationDate?.toIso8601String(),
      'doi': doi,
      'abstract': abstract,
      'keywords': keywords,
    };
  }
}

class PatientGuide {
  final String id;
  final String medicationId;
  final String title;
  final String content;
  final List<String> sections;
  final List<String> keyPoints;
  final List<String> patientWarnings;
  final String language;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String author;
  final String version;

  const PatientGuide({
    required this.id,
    required this.medicationId,
    required this.title,
    required this.content,
    required this.sections,
    required this.keyPoints,
    required this.patientWarnings,
    required this.language,
    required this.createdAt,
    this.lastUpdated,
    required this.author,
    required this.version,
  });

  factory PatientGuide.fromJson(Map<String, dynamic> json) {
    return PatientGuide(
      id: json['id'] ?? '',
      medicationId: json['medicationId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      sections: List<String>.from(json['sections'] ?? []),
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      patientWarnings: List<String>.from(json['warnings'] ?? []),
      language: json['language'] ?? 'tr',
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      author: json['author'] ?? '',
      version: json['version'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'title': title,
      'content': content,
      'sections': sections,
      'keyPoints': keyPoints,
      'warnings': patientWarnings,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'author': author,
      'version': version,
    };
  }
}

class TreatmentProtocol {
  final String id;
  final String medicationId;
  final String title;
  final String name;
  final String description;
  final String diagnosis;
  final String category;
  final List<String> protocolIndications;
  final List<String> protocolContraindications;
  final List<String> dosageInstructions;
  final List<String> monitoringParameters;
  final List<String> adverseEffects;
  final List<String> protocolDrugInteractions;
  final List<String> specialPopulations;
  final List<String> protocolReferences;
  final List<String> protocolMedications;
  final List<String> nonPharmacological;
  final String duration;
  final String frequency;
  final List<String> monitoring;
  final String source;
  final DateTime createdAt;
  final DateTime? lastUpdated;
  final String author;
  final String evidenceLevel;

  const TreatmentProtocol({
    required this.id,
    required this.medicationId,
    required this.title,
    required this.name,
    required this.description,
    required this.diagnosis,
    required this.category,
    required this.protocolIndications,
    required this.protocolContraindications,
    required this.dosageInstructions,
    required this.monitoringParameters,
    required this.adverseEffects,
    required this.protocolDrugInteractions,
    required this.specialPopulations,
    required this.protocolReferences,
    required this.protocolMedications,
    required this.nonPharmacological,
    required this.duration,
    required this.frequency,
    required this.monitoring,
    required this.source,
    required this.createdAt,
    this.lastUpdated,
    required this.author,
    required this.evidenceLevel,
  });

  factory TreatmentProtocol.fromJson(Map<String, dynamic> json) {
    return TreatmentProtocol(
      id: json['id'] ?? '',
      medicationId: json['medicationId'] ?? '',
      title: json['title'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      category: json['category'] ?? '',
      protocolIndications: List<String>.from(json['indications'] ?? []),
      protocolContraindications:
          List<String>.from(json['contraindications'] ?? []),
      dosageInstructions: List<String>.from(json['dosageInstructions'] ?? []),
      monitoringParameters:
          List<String>.from(json['monitoringParameters'] ?? []),
      adverseEffects: List<String>.from(json['adverseEffects'] ?? []),
      protocolDrugInteractions:
          List<String>.from(json['drugInteractions'] ?? []),
      specialPopulations: List<String>.from(json['specialPopulations'] ?? []),
      protocolReferences: List<String>.from(json['references'] ?? []),
      protocolMedications: List<String>.from(json['medications'] ?? []),
      nonPharmacological: List<String>.from(json['nonPharmacological'] ?? []),
      duration: json['duration'] ?? '',
      frequency: json['frequency'] ?? '',
      monitoring: List<String>.from(json['monitoring'] ?? []),
      source: json['source'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      author: json['author'] ?? '',
      evidenceLevel: json['evidenceLevel'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'title': title,
      'name': name,
      'description': description,
      'diagnosis': diagnosis,
      'category': category,
      'indications': protocolIndications,
      'contraindications': protocolContraindications,
      'dosageInstructions': dosageInstructions,
      'monitoringParameters': monitoringParameters,
      'adverseEffects': adverseEffects,
      'drugInteractions': protocolDrugInteractions,
      'specialPopulations': specialPopulations,
      'references': protocolReferences,
      'medications': protocolMedications,
      'nonPharmacological': nonPharmacological,
      'duration': duration,
      'frequency': frequency,
      'monitoring': monitoring,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'author': author,
      'evidenceLevel': evidenceLevel,
    };
  }
}
