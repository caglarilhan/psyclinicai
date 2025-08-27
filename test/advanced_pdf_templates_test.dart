import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/advanced_pdf_templates_service.dart';
import 'package:psyclinicai/models/session_models.dart';
import 'package:psyclinicai/models/patient_models.dart';
import 'package:psyclinicai/models/medication_models.dart';

void main() {
  group('AdvancedPDFTemplatesService Tests', () {
    late AdvancedPDFTemplatesService service;
    late SessionData mockSession;
    late PatientData mockPatient;
    late List<DrugInteraction> mockInteractions;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = AdvancedPDFTemplatesService();
      
      // Mock session data
      mockSession = SessionData(
        id: 'session_001',
        patientId: 'patient_001',
        therapistId: 'therapist_001',
        date: DateTime.now(),
        duration: 60,
        type: 'Individual Therapy',
        status: 'Completed',
        location: 'Office',
        notes: 'Patient showed significant improvement in mood and anxiety levels.',
        goals: [
          'Reduce anxiety symptoms',
          'Improve coping mechanisms',
          'Develop healthy sleep habits'
        ],
        interventions: [
          'Cognitive Behavioral Therapy',
          'Mindfulness exercises',
          'Progressive muscle relaxation'
        ],
        assessments: [
          'PHQ-9: Score 8 (Mild depression)',
          'GAD-7: Score 6 (Mild anxiety)',
          'PTSD Checklist: Score 12 (Minimal symptoms)'
        ],
        progressNotes: [
          'Patient reports 30% reduction in anxiety',
          'Sleep quality improved from 3/10 to 7/10',
          'Successfully used CBT techniques during stressful situations'
        ],
        symptoms: [
          'Anxiety: Moderate (down from Severe)',
          'Depression: Mild (down from Moderate)',
          'Sleep: Improved (up from Poor)'
        ],
        patientResponse: 'Patient was engaged and responsive throughout the session. Showed good understanding of therapeutic techniques.',
        treatmentPlan: 'Continue weekly sessions with focus on anxiety management and sleep hygiene. Introduce exposure therapy gradually.',
        nextSteps: [
          'Practice mindfulness exercises daily',
          'Complete sleep diary',
          'Schedule follow-up in 1 week'
        ],
        homework: [
          'Mindfulness meditation 10 minutes daily',
          'Sleep hygiene checklist',
          'Anxiety tracking worksheet'
        ],
        recommendations: 'Consider reducing session frequency to bi-weekly if progress continues. Monitor for any regression in symptoms.',
        followUpPlan: 'Weekly sessions for next 4 weeks, then reassess for frequency adjustment.',
        referrals: [
          'Psychiatrist for medication evaluation',
          'Sleep specialist for persistent insomnia'
        ],
        summary: 'Significant progress made in anxiety and depression symptoms. Patient demonstrates good engagement and application of therapeutic techniques.',
        attachments: [],
        tags: ['anxiety', 'depression', 'sleep', 'CBT'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock patient data
      mockPatient = PatientData(
        id: 'patient_001',
        name: 'John Doe',
        age: 35,
        gender: 'Male',
        dateOfBirth: '1988-05-15',
        phoneNumber: '+1-555-0123',
        email: 'john.doe@email.com',
        address: '123 Main St, Anytown, USA',
        emergencyContact: 'Jane Doe',
        emergencyPhone: '+1-555-0124',
        insuranceProvider: 'Blue Cross Blue Shield',
        insuranceNumber: 'BCBS123456789',
        primaryDiagnosis: 'Generalized Anxiety Disorder',
        secondaryDiagnosis: 'Major Depressive Disorder',
        allergies: ['None known'],
        medications: ['Sertraline 50mg daily'],
        medicalHistory: 'No significant medical history',
        psychiatricHistory: 'First episode of depression and anxiety 6 months ago',
        familyHistory: 'Mother has depression, father has anxiety',
        occupation: 'Software Engineer',
        maritalStatus: 'Married',
        children: 2,
        referralSource: 'Primary Care Physician',
        treatmentGoals: [
          'Reduce anxiety symptoms by 50%',
          'Improve sleep quality',
          'Return to normal daily functioning'
        ],
        riskFactors: ['Family history of mental illness', 'High stress job'],
        protectiveFactors: ['Strong family support', 'Good physical health'],
        notes: 'Patient is highly motivated and has good insight into his condition.',
        status: 'Active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Mock drug interactions
      mockInteractions = [
        DrugInteraction(
          id: 'interaction_001',
          medication1Id: 'med_001',
          medication1Name: 'Sertraline',
          medication2Id: 'med_002',
          medication2Name: 'St. John\'s Wort',
          severity: "major",
          type: InteractionType.pharmacokinetic,
          mechanism: 'Induction of CYP3A4 enzymes',
          description: 'St. John\'s Wort may decrease sertraline levels, reducing effectiveness.',
          clinicalSignificance: 'Major interaction',
          symptoms: [
            'Reduced antidepressant efficacy',
            'Potential return of depressive symptoms'
          ],
          recommendations: [
            'Avoid combination',
            'Monitor for decreased efficacy',
            'Consider alternative antidepressant if needed'
          ],
          alternatives: ['Alternative herbal supplements', 'Different antidepressant class'],
          monitoring: ['Weekly mood assessment'],
          evidence: 'Strong clinical evidence',
          source: 'Drug Interaction Facts 2024',
        ),
        DrugInteraction(
          id: 'interaction_002',
          medication1Id: 'med_001',
          medication1Name: 'Sertraline',
          medication2Id: 'med_003',
          medication2Name: 'Aspirin',
          severity: "minor",
          type: InteractionType.pharmacodynamic,
          mechanism: 'Serotonin-mediated platelet dysfunction',
          description: 'Increased risk of bleeding when combining SSRI with antiplatelet agents.',
          clinicalSignificance: 'Minor interaction',
          symptoms: [
            'Increased bleeding risk',
            'Bruising',
            'Prolonged bleeding time'
          ],
          recommendations: [
            'Monitor for signs of bleeding',
            'Consider alternative pain reliever',
            'Regular CBC monitoring'
          ],
          alternatives: ['Acetaminophen', 'Ibuprofen (with caution)'],
          monitoring: ['Monthly CBC'],
          evidence: 'Moderate clinical evidence',
          source: 'Clinical Pharmacology 2024',
        ),
      ];
    });

    group('Template Configuration Tests', () {
      test('should return available templates', () {
        final templates = service.getAvailableTemplates();
        
        expect(templates, isNotEmpty);
        expect(templates.containsKey('professional'), isTrue);
        expect(templates.containsKey('medical'), isTrue);
        expect(templates.containsKey('minimalist'), isTrue);
        expect(templates.containsKey('corporate'), isTrue);
        expect(templates.containsKey('creative'), isTrue);
      });

      test('should return template config by name', () {
        final professionalConfig = service.getTemplateConfig('professional');
        final medicalConfig = service.getTemplateConfig('medical');
        
        expect(professionalConfig, isNotNull);
        expect(professionalConfig!['name'], equals('Professional'));
        expect(professionalConfig['primaryColor'], isNotNull);
        expect(professionalConfig['watermark'], isFalse);
        
        expect(medicalConfig, isNotNull);
        expect(medicalConfig!['name'], equals('Medical'));
        expect(medicalConfig['watermark'], isTrue);
      });

      test('should return null for invalid template name', () {
        final invalidConfig = service.getTemplateConfig('invalid_template');
        expect(invalidConfig, isNull);
      });

      test('should have correct template properties', () {
        final professionalConfig = service.getTemplateConfig('professional')!;
        
        expect(professionalConfig['name'], equals('Professional'));
        expect(professionalConfig['description'], isNotEmpty);
        expect(professionalConfig['primaryColor'], isNotNull);
        expect(professionalConfig['secondaryColor'], isNotNull);
        expect(professionalConfig['fontFamily'], equals('Helvetica'));
        expect(professionalConfig['logoPosition'], isNotEmpty);
        expect(professionalConfig['watermark'], isA<bool>());
      });
    });

    group('Service Initialization Tests', () {
      test('should create service instance', () {
        expect(service, isNotNull);
        expect(service, isA<AdvancedPDFTemplatesService>());
      });

      test('should have template configurations', () {
        final templates = service.getAvailableTemplates();
        expect(templates, isNotEmpty);
        expect(templates.length, equals(5));
      });
    });

    group('Template Variants Tests', () {
      test('should have professional template', () {
        final config = service.getTemplateConfig('professional');
        expect(config, isNotNull);
        expect(config!['name'], equals('Professional'));
        expect(config['primaryColor'], isNotNull);
        expect(config['watermark'], isFalse);
      });

      test('should have medical template', () {
        final config = service.getTemplateConfig('medical');
        expect(config, isNotNull);
        expect(config!['name'], equals('Medical'));
        expect(config['primaryColor'], isNotNull);
        expect(config['watermark'], isTrue);
      });

      test('should have minimalist template', () {
        final config = service.getTemplateConfig('minimalist');
        expect(config, isNotNull);
        expect(config!['name'], equals('Minimalist'));
        expect(config['primaryColor'], isNotNull);
        expect(config['watermark'], isFalse);
      });

      test('should have corporate template', () {
        final config = service.getTemplateConfig('corporate');
        expect(config, isNotNull);
        expect(config!['name'], equals('Corporate'));
        expect(config['primaryColor'], isNotNull);
        expect(config['watermark'], isTrue);
      });

      test('should have creative template', () {
        final config = service.getTemplateConfig('creative');
        expect(config, isNotNull);
        expect(config!['name'], equals('Creative'));
        expect(config['primaryColor'], isNotNull);
        expect(config['watermark'], isFalse);
      });
    });

    group('Data Model Tests', () {
      test('should have valid session data', () {
        expect(mockSession.id, equals('session_001'));
        expect(mockSession.patientId, equals('patient_001'));
        expect(mockSession.type, equals('Individual Therapy'));
        expect(mockSession.goals, isNotEmpty);
        expect(mockSession.interventions, isNotEmpty);
        expect(mockSession.assessments, isNotEmpty);
      });

      test('should have valid patient data', () {
        expect(mockPatient.id, equals('patient_001'));
        expect(mockPatient.name, equals('John Doe'));
        expect(mockPatient.age, equals(35));
        expect(mockPatient.primaryDiagnosis, equals('Generalized Anxiety Disorder'));
        expect(mockPatient.medications, isNotEmpty);
      });

      test('should have valid drug interactions', () {
        expect(mockInteractions, isNotEmpty);
        expect(mockInteractions.length, equals(2));
        
        final firstInteraction = mockInteractions.first;
        expect(firstInteraction.medication1Name, equals('Sertraline'));
        expect(firstInteraction.medication2Name, equals('St. John\'s Wort'));
        expect(firstInteraction.severity, equals("major"));
        expect(firstInteraction.type, equals(InteractionType.pharmacokinetic));
      });
    });
  });
}
