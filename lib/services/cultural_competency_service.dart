import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cultural_competency_models.dart';

class CulturalCompetencyService {
  static const String _profilesKey = 'cultural_profiles';
  static const String _assessmentsKey = 'cultural_assessments';
  static const String _guidelinesKey = 'cultural_guidelines';
  
  // Singleton pattern
  static final CulturalCompetencyService _instance = CulturalCompetencyService._internal();
  factory CulturalCompetencyService() => _instance;
  CulturalCompetencyService._internal();

  // Mock cultural data for development
  final Map<String, CulturalProfile> _mockCulturalProfiles = {
    'TR': CulturalProfile(
      id: 'profile_tr',
      patientId: 'patient_tr_001',
      primaryCulture: 'Turkish',
      culturalBackgrounds: ['Turkish', 'Ottoman', 'Anatolian'],
      language: 'Turkish',
      religion: 'Islam',
      ethnicity: 'Turkish',
      nationality: 'Turkish',
      culturalValues: {
        'family_importance': 'high',
        'respect_for_elders': 'very_high',
        'collectivism': 'high',
        'hospitality': 'very_high',
      },
      communicationPreferences: {
        'formality': 'moderate',
        'directness': 'moderate',
        'nonverbal_importance': 'high',
        'personal_space': 'close',
      },
      healthBeliefs: {
        'traditional_medicine': 'accepted',
        'family_consultation': 'required',
        'spiritual_healing': 'considered',
        'western_medicine': 'trusted',
      },
      familyStructure: {
        'extended_family': 'important',
        'patriarchal_tendencies': 'moderate',
        'intergenerational_living': 'common',
        'family_decisions': 'collective',
      },
      socialContext: {
        'community_support': 'strong',
        'social_networks': 'dense',
        'hierarchy_respect': 'high',
        'group_harmony': 'valued',
      },
    ),
    'US': CulturalProfile(
      id: 'profile_us',
      patientId: 'patient_us_001',
      primaryCulture: 'American',
      culturalBackgrounds: ['American', 'European', 'African American'],
      language: 'English',
      religion: 'Christianity',
      ethnicity: 'Caucasian',
      nationality: 'American',
      culturalValues: {
        'individualism': 'high',
        'independence': 'very_high',
        'equality': 'valued',
        'achievement': 'important',
      },
      communicationPreferences: {
        'formality': 'low',
        'directness': 'very_high',
        'nonverbal_importance': 'moderate',
        'personal_space': 'distant',
      },
      healthBeliefs: {
        'evidence_based': 'preferred',
        'patient_autonomy': 'high',
        'informed_consent': 'required',
        'alternative_medicine': 'accepted',
      },
      familyStructure: {
        'nuclear_family': 'common',
        'individual_choice': 'valued',
        'generational_independence': 'high',
        'family_decisions': 'individual',
      },
      socialContext: {
        'diversity': 'valued',
        'equal_opportunity': 'important',
        'personal_freedom': 'high',
        'community_engagement': 'moderate',
      },
    ),
    'EU': CulturalProfile(
      id: 'profile_eu',
      patientId: 'patient_eu_001',
      primaryCulture: 'European',
      culturalBackgrounds: ['German', 'French', 'Italian'],
      language: 'German',
      religion: 'Christianity',
      ethnicity: 'European',
      nationality: 'German',
      culturalValues: {
        'efficiency': 'high',
        'quality': 'very_high',
        'sustainability': 'valued',
        'social_welfare': 'important',
      },
      communicationPreferences: {
        'formality': 'high',
        'directness': 'high',
        'nonverbal_importance': 'moderate',
        'personal_space': 'moderate',
      },
      healthBeliefs: {
        'universal_healthcare': 'expected',
        'preventive_care': 'emphasized',
        'patient_rights': 'protected',
        'holistic_approach': 'valued',
      },
      familyStructure: {
        'nuclear_family': 'common',
        'gender_equality': 'high',
        'work_life_balance': 'valued',
        'family_decisions': 'shared',
      },
      socialContext: {
        'social_democracy': 'valued',
        'environmental_consciousness': 'high',
        'cultural_diversity': 'respected',
        'social_responsibility': 'expected',
      },
    ),
  };

  // Mock cultural treatment guidelines
  final List<CulturalTreatmentGuideline> _mockGuidelines = [
    CulturalTreatmentGuideline(
      id: 'guideline_tr_depression',
      culture: 'Turkish',
      condition: 'Depression',
      preferredApproaches: [
        'Family-involved therapy',
        'Group therapy with community support',
        'Spiritual counseling integration',
        'Traditional healing practices',
      ],
      avoidedApproaches: [
        'Isolation-focused treatment',
        'Individual-only therapy',
        'Disregard for family opinions',
        'Ignoring spiritual aspects',
      ],
      culturalConsiderations: [
        'Family involvement is crucial',
        'Respect for religious beliefs',
        'Community support networks',
        'Traditional medicine integration',
      ],
      familyInvolvement: [
        'Include family in treatment planning',
        'Respect family hierarchy',
        'Address family concerns',
        'Provide family education',
      ],
      communicationTips: [
        'Use formal address initially',
        'Respect personal space preferences',
        'Include family in discussions',
        'Be patient with language barriers',
      ],
    ),
    CulturalTreatmentGuideline(
      id: 'guideline_us_anxiety',
      culture: 'American',
      condition: 'Anxiety',
      preferredApproaches: [
        'Cognitive Behavioral Therapy (CBT)',
        'Individual therapy sessions',
        'Evidence-based interventions',
        'Self-help strategies',
      ],
      avoidedApproaches: [
        'Forced family involvement',
        'Spiritual imposition',
        'Traditional medicine only',
        'Group therapy without choice',
      ],
      culturalConsiderations: [
        'Respect individual autonomy',
        'Provide evidence-based options',
        'Allow patient choice',
        'Maintain confidentiality',
      ],
      familyInvolvement: [
        'Offer family involvement option',
        'Respect patient preferences',
        'Provide family education if requested',
        'Maintain patient privacy',
      ],
      communicationTips: [
        'Use direct communication',
        'Respect personal space',
        'Provide clear information',
        'Encourage questions',
      ],
    ),
  ];

  // Get cultural profile by region
  CulturalProfile? getCulturalProfile(String region) {
    return _mockCulturalProfiles[region];
  }

  // Get all available cultural profiles
  List<CulturalProfile> getAllCulturalProfiles() {
    return _mockCulturalProfiles.values.toList();
  }

  // Assess cultural competency
  Future<CulturalCompetencyAssessment> assessCulturalCompetency({
    required String patientId,
    required String clinicianId,
    required String patientCulture,
    required Map<String, dynamic> sessionData,
  }) async {
    // Simulate AI assessment delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final random = Random();
    final timestamp = DateTime.now();
    
    // Generate competency scores
    final culturalSensitivityScore = 0.7 + random.nextDouble() * 0.3;
    final communicationEffectivenessScore = 0.6 + random.nextDouble() * 0.4;
    final treatmentCulturalFitScore = 0.8 + random.nextDouble() * 0.2;
    
    // Generate competency dimensions
    final dimensions = _generateCompetencyDimensions(random);
    
    // Generate recommendations
    final recommendations = _generateRecommendations(
      culturalSensitivityScore,
      communicationEffectivenessScore,
      treatmentCulturalFitScore,
      patientCulture,
    );
    
    return CulturalCompetencyAssessment(
      id: 'assessment_${timestamp.millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      assessmentDate: timestamp,
      culturalSensitivityScore: culturalSensitivityScore.clamp(0.0, 1.0),
      communicationEffectivenessScore: communicationEffectivenessScore.clamp(0.0, 1.0),
      treatmentCulturalFitScore: treatmentCulturalFitScore.clamp(0.0, 1.0),
      dimensions: dimensions,
      recommendations: recommendations,
    );
  }

  // Generate cultural competency dimensions
  List<CulturalCompetencyDimension> _generateCompetencyDimensions(Random random) {
    final dimensions = [
      'Cultural Awareness',
      'Communication Skills',
      'Treatment Adaptation',
      'Family Involvement',
      'Religious Sensitivity',
      'Language Proficiency',
    ];
    
    return dimensions.map((dimension) {
      final score = 0.5 + random.nextDouble() * 0.5;
      final strengths = _generateStrengths(dimension, score);
      final areasForImprovement = _generateAreasForImprovement(dimension, score);
      
      return CulturalCompetencyDimension(
        dimension: dimension,
        score: score,
        description: _getDimensionDescription(dimension),
        strengths: strengths,
        areasForImprovement: areasForImprovement,
      );
    }).toList();
  }

  // Generate strengths based on dimension and score
  List<String> _generateStrengths(String dimension, double score) {
    if (score < 0.6) return ['Basic understanding present'];
    
    final strengths = <String>[];
    
    switch (dimension) {
      case 'Cultural Awareness':
        strengths.addAll([
          'Recognizes cultural differences',
          'Shows respect for diverse backgrounds',
          'Adapts approach appropriately',
        ]);
        break;
      case 'Communication Skills':
        strengths.addAll([
          'Uses appropriate language',
          'Respects communication preferences',
          'Shows cultural sensitivity',
        ]);
        break;
      case 'Treatment Adaptation':
        strengths.addAll([
          'Modifies treatment plans',
          'Considers cultural factors',
          'Integrates traditional practices',
        ]);
        break;
      case 'Family Involvement':
        strengths.addAll([
          'Includes family appropriately',
          'Respects family dynamics',
          'Provides family education',
        ]);
        break;
      case 'Religious Sensitivity':
        strengths.addAll([
          'Respects religious beliefs',
          'Integrates spiritual aspects',
          'Avoids religious imposition',
        ]);
        break;
      case 'Language Proficiency':
        strengths.addAll([
          'Communicates effectively',
          'Uses appropriate terminology',
          'Provides clear explanations',
        ]);
        break;
    }
    
    return strengths.take((score * 3).round()).toList();
  }

  // Generate areas for improvement
  List<String> _generateAreasForImprovement(String dimension, double score) {
    if (score > 0.8) return ['Continue current excellent practices'];
    
    final areas = <String>[];
    
    switch (dimension) {
      case 'Cultural Awareness':
        areas.addAll([
          'Learn more about specific cultures',
          'Attend cultural competency training',
          'Seek cultural consultation',
        ]);
        break;
      case 'Communication Skills':
        areas.addAll([
          'Improve nonverbal communication',
          'Learn cultural communication styles',
          'Practice active listening',
        ]);
        break;
      case 'Treatment Adaptation':
        areas.addAll([
          'Research cultural treatment preferences',
          'Consult cultural experts',
          'Adapt evidence-based practices',
        ]);
        break;
      case 'Family Involvement':
        areas.addAll([
          'Understand family dynamics better',
          'Learn family involvement strategies',
          'Respect family decision-making',
        ]);
        break;
      case 'Religious Sensitivity':
        areas.addAll([
          'Learn about different religions',
          'Understand spiritual practices',
          'Respect religious preferences',
        ]);
        break;
      case 'Language Proficiency':
        areas.addAll([
          'Improve language skills',
          'Use professional interpreters',
          'Learn cultural terminology',
        ]);
        break;
    }
    
    return areas.take(((1.0 - score) * 3).round()).toList();
  }

  // Get dimension description
  String _getDimensionDescription(String dimension) {
    switch (dimension) {
      case 'Cultural Awareness':
        return 'Understanding and recognition of cultural differences and their impact on mental health';
      case 'Communication Skills':
        return 'Ability to communicate effectively across cultural boundaries';
      case 'Treatment Adaptation':
        return 'Skill in adapting treatment approaches to cultural contexts';
      case 'Family Involvement':
        return 'Understanding of family dynamics and appropriate involvement strategies';
      case 'Religious Sensitivity':
        return 'Respect and integration of religious and spiritual beliefs in treatment';
      case 'Language Proficiency':
        return 'Ability to communicate in patient\'s preferred language';
      default:
        return 'Cultural competency dimension';
    }
  }

  // Generate recommendations
  List<CulturalCompetencyRecommendation> _generateRecommendations(
    double culturalSensitivityScore,
    double communicationEffectivenessScore,
    double treatmentCulturalFitScore,
    String patientCulture,
  ) {
    final recommendations = <CulturalCompetencyRecommendation>[];
    final timestamp = DateTime.now();
    
    // Cultural sensitivity recommendations
    if (culturalSensitivityScore < 0.7) {
      recommendations.add(CulturalCompetencyRecommendation(
        id: 'rec_${timestamp.millisecondsSinceEpoch}_1',
        category: 'Cultural Awareness',
        title: 'Improve Cultural Sensitivity',
        description: 'Enhance understanding of $patientCulture culture and its impact on mental health',
        priority: culturalSensitivityScore < 0.5 ? RecommendationPriority.high : RecommendationPriority.medium,
        actions: [
          'Complete cultural competency training',
          'Read cultural literature',
          'Consult with cultural experts',
          'Practice cultural humility',
        ],
        resources: [
          'Cultural competency courses',
          'Cultural consultation services',
          'Cultural literature and resources',
          'Peer consultation groups',
        ],
      ));
    }
    
    // Communication recommendations
    if (communicationEffectivenessScore < 0.7) {
      recommendations.add(CulturalCompetencyRecommendation(
        id: 'rec_${timestamp.millisecondsSinceEpoch}_2',
        category: 'Communication',
        title: 'Enhance Cross-Cultural Communication',
        description: 'Improve communication skills for effective interaction with $patientCulture patients',
        priority: communicationEffectivenessScore < 0.5 ? RecommendationPriority.high : RecommendationPriority.medium,
        actions: [
          'Learn cultural communication styles',
          'Practice active listening',
          'Use appropriate nonverbal cues',
          'Seek language assistance if needed',
        ],
        resources: [
          'Communication skills training',
          'Language learning resources',
          'Cultural communication guides',
          'Professional interpreters',
        ],
      ));
    }
    
    // Treatment adaptation recommendations
    if (treatmentCulturalFitScore < 0.8) {
      recommendations.add(CulturalCompetencyRecommendation(
        id: 'rec_${timestamp.millisecondsSinceEpoch}_3',
        category: 'Treatment',
        title: 'Adapt Treatment Approaches',
        description: 'Modify treatment strategies to better fit $patientCulture cultural context',
        priority: treatmentCulturalFitScore < 0.6 ? RecommendationPriority.high : RecommendationPriority.medium,
        actions: [
          'Research cultural treatment preferences',
          'Integrate traditional practices',
          'Adapt evidence-based approaches',
          'Consult cultural treatment guidelines',
        ],
        resources: [
          'Cultural treatment guidelines',
          'Traditional medicine resources',
          'Cultural consultation services',
          'Evidence-based adaptation guides',
        ],
      ));
    }
    
    // General improvement recommendations
    if (recommendations.isEmpty) {
      recommendations.add(CulturalCompetencyRecommendation(
        id: 'rec_${timestamp.millisecondsSinceEpoch}_4',
        category: 'Maintenance',
        title: 'Maintain Cultural Competency',
        description: 'Continue excellent cultural competency practices',
        priority: RecommendationPriority.low,
        actions: [
          'Continue current practices',
          'Stay updated on cultural trends',
          'Share knowledge with colleagues',
          'Mentor other clinicians',
        ],
        resources: [
          'Ongoing education',
          'Professional development',
          'Peer consultation',
          'Cultural competency resources',
        ],
      ));
    }
    
    return recommendations;
  }

  // Get cultural treatment guidelines
  List<CulturalTreatmentGuideline> getCulturalTreatmentGuidelines(String culture, String condition) {
    return _mockGuidelines.where((guideline) => 
      guideline.culture.toLowerCase() == culture.toLowerCase() &&
      guideline.condition.toLowerCase() == condition.toLowerCase()
    ).toList();
  }

  // Get all treatment guidelines
  List<CulturalTreatmentGuideline> getAllTreatmentGuidelines() {
    return _mockGuidelines;
  }

  // Generate cultural competency report
  Future<CulturalCompetencyReport> generateCulturalCompetencyReport({
    required String patientId,
    required String clinicianId,
    required String patientCulture,
  }) async {
    // Get patient cultural profile
    final culturalProfile = getCulturalProfile(patientCulture) ?? 
        getCulturalProfile('US')!; // Default to US if culture not found
    
    // Assess cultural competency
    final assessment = await assessCulturalCompetency(
      patientId: patientId,
      clinicianId: clinicianId,
      patientCulture: patientCulture,
      sessionData: {},
    );
    
    // Get treatment guidelines
    final treatmentGuidelines = getCulturalTreatmentGuidelines(patientCulture, 'General');
    
    // Get communication guides
    final communicationGuides = _generateCommunicationGuides(patientCulture);
    
    // Generate insights
    final insights = _generateCulturalInsights(culturalProfile, assessment);
    
    return CulturalCompetencyReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      clinicianId: clinicianId,
      reportDate: DateTime.now(),
      patientCulturalProfile: culturalProfile,
      assessment: assessment,
      treatmentGuidelines: treatmentGuidelines,
      communicationGuides: communicationGuides,
      recommendations: assessment.recommendations,
      insights: insights,
    );
  }

  // Generate communication guides
  List<CulturalCommunicationGuide> _generateCommunicationGuides(String culture) {
    final guides = <CulturalCommunicationGuide>[];
    
    switch (culture.toLowerCase()) {
      case 'turkish':
        guides.add(CulturalCommunicationGuide(
          id: 'guide_tr_001',
          culture: 'Turkish',
          language: 'Turkish',
          greetingCustoms: [
            'Use formal address (siz) initially',
            'Respect age hierarchy',
            'Include family in greetings',
          ],
          communicationStyles: [
            'Indirect communication preferred',
            'Respect for authority figures',
            'Emotional expression accepted',
          ],
          tabooTopics: [
            'Avoid criticizing family',
            'Respect religious beliefs',
            'Avoid political discussions',
          ],
          respectfulTerms: [
            'Sayın (Respected)',
            'Hocam (My teacher)',
            'Abi/Abla (Elder brother/sister)',
          ],
          nonverbalCues: [
            'Maintain eye contact',
            'Use appropriate gestures',
            'Respect personal space',
          ],
        ));
        break;
      case 'american':
        guides.add(CulturalCommunicationGuide(
          id: 'guide_us_001',
          culture: 'American',
          language: 'English',
          greetingCustoms: [
            'Use first names unless specified',
            'Firm handshake',
            'Maintain eye contact',
          ],
          communicationStyles: [
            'Direct communication preferred',
            'Individual expression valued',
            'Informal tone acceptable',
          ],
          tabooTopics: [
            'Avoid personal questions',
            'Respect privacy',
            'Avoid controversial topics',
          ],
          respectfulTerms: [
            'Professional titles',
            'Mr./Ms./Dr.',
            'Respectful language',
          ],
          nonverbalCues: [
            'Maintain personal space',
            'Use open body language',
            'Respect boundaries',
          ],
        ));
        break;
      case 'german':
        guides.add(CulturalCommunicationGuide(
          id: 'guide_de_001',
          culture: 'German',
          language: 'German',
          greetingCustoms: [
            'Use formal address (Sie)',
            'Firm handshake',
            'Maintain eye contact',
          ],
          communicationStyles: [
            'Direct and precise communication',
            'Value efficiency',
            'Respect structure',
          ],
          tabooTopics: [
            'Avoid personal questions',
            'Respect privacy',
            'Avoid controversial topics',
          ],
          respectfulTerms: [
            'Herr/Frau (Mr./Ms.)',
            'Doktor (Doctor)',
            'Professor (Professor)',
          ],
          nonverbalCues: [
            'Maintain personal space',
            'Use formal gestures',
            'Respect boundaries',
          ],
        ));
        break;
    }
    
    return guides;
  }

  // Generate cultural insights
  Map<String, dynamic> _generateCulturalInsights(
    CulturalProfile profile,
    CulturalCompetencyAssessment assessment,
  ) {
    final insights = <String, dynamic>{};
    
    // Cultural profile insights
    insights['cultural_profile'] = {
      'primary_culture': profile.primaryCulture,
      'language': profile.language,
      'religion': profile.religion,
      'key_values': profile.culturalValues.keys.toList(),
    };
    
    // Assessment insights
    insights['competency_assessment'] = {
      'overall_score': (assessment.culturalSensitivityScore + 
                       assessment.communicationEffectivenessScore + 
                       assessment.treatmentCulturalFitScore) / 3,
      'strengths': assessment.dimensions
          .where((d) => d.score > 0.7)
          .map((d) => d.dimension)
          .toList(),
      'areas_for_improvement': assessment.dimensions
          .where((d) => d.score < 0.6)
          .map((d) => d.dimension)
          .toList(),
    };
    
    // Treatment insights
    insights['treatment_considerations'] = {
      'family_involvement': profile.familyStructure['extended_family'] == 'important',
      'spiritual_integration': profile.healthBeliefs['spiritual_healing'] == 'considered',
      'traditional_medicine': profile.healthBeliefs['traditional_medicine'] == 'accepted',
      'communication_style': profile.communicationPreferences['formality'],
    };
    
    // Recommendations insights
    insights['priority_recommendations'] = assessment.recommendations
        .where((r) => r.priority == RecommendationPriority.high || 
                     r.priority == RecommendationPriority.critical)
        .map((r) => r.title)
        .toList();
    
    return insights;
  }

  // Save cultural profile
  Future<void> saveCulturalProfile(CulturalProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesKey = '${_profilesKey}_${profile.patientId}';
      
      await prefs.setString(profilesKey, json.encode(profile.toJson()));
    } catch (e) {
      print('Error saving cultural profile: $e');
    }
  }

  // Get cultural profile for a patient
  Future<CulturalProfile?> getCulturalProfileForPatient(String patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesKey = '${_profilesKey}_$patientId';
      
      final profileJson = prefs.getString(profilesKey);
      if (profileJson != null) {
        return CulturalProfile.fromJson(json.decode(profileJson));
      }
      
      return null;
    } catch (e) {
      print('Error getting cultural profile: $e');
      return null;
    }
  }

  // Save cultural competency assessment
  Future<void> saveCulturalCompetencyAssessment(CulturalCompetencyAssessment assessment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsKey = '${_assessmentsKey}_${assessment.clinicianId}';
      
      final existingAssessmentsJson = prefs.getString(assessmentsKey);
      List<Map<String, dynamic>> assessments = [];
      
      if (existingAssessmentsJson != null) {
        assessments = List<Map<String, dynamic>>.from(json.decode(existingAssessmentsJson));
      }
      
      assessments.add(assessment.toJson());
      
      // Keep only last 20 assessments
      if (assessments.length > 20) {
        assessments = assessments.sublist(assessments.length - 20);
      }
      
      await prefs.setString(assessmentsKey, json.encode(assessments));
    } catch (e) {
      print('Error saving cultural competency assessment: $e');
    }
  }

  // Get cultural competency assessments for a clinician
  Future<List<CulturalCompetencyAssessment>> getCulturalCompetencyAssessments(String clinicianId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assessmentsKey = '${_assessmentsKey}_$clinicianId';
      
      final assessmentsJson = prefs.getString(assessmentsKey);
      if (assessmentsJson == null) return [];
      
      final assessments = List<Map<String, dynamic>>.from(json.decode(assessmentsJson));
      return assessments.map((json) => CulturalCompetencyAssessment.fromJson(json)).toList();
    } catch (e) {
      print('Error getting cultural competency assessments: $e');
      return [];
    }
  }
}
