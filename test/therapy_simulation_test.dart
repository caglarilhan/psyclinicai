import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/therapy_simulation_service.dart';
import 'package:psyclinicai/models/therapy_simulation_models.dart';

void main() {
  group('TherapySimulationService Tests', () {
    late TherapySimulationService service;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      service = TherapySimulationService();
    });

    tearDown(() {
      // Service'i dispose etme, sadece test verilerini temizle
    });

    group('Initialization Tests', () {
      test('should initialize successfully', () async {
        await service.initialize();
        
        // Senaryolar yüklenmiş olmalı
        final scenarios = service.getScenarios();
        expect(scenarios, isNotEmpty);
        expect(scenarios.length, greaterThanOrEqualTo(2));
      });

      test('should load mock scenarios', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        expect(scenarios.any((s) => s.title.contains('Depresyon')), isTrue);
        expect(scenarios.any((s) => s.title.contains('Anksiyete')), isTrue);
      });
    });

    group('Scenario Management Tests', () {
      test('should get scenarios', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        expect(scenarios, isNotEmpty);
        expect(scenarios.first.title, isNotEmpty);
        expect(scenarios.first.description, isNotEmpty);
      });

      test('should get scenario by id', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final firstScenario = scenarios.first;
        
        final scenario = service.getScenario(firstScenario.id);
        expect(scenario, isNotNull);
        expect(scenario!.id, firstScenario.id);
        expect(scenario.title, firstScenario.title);
      });
    });

    group('Session Management Tests', () {
      test('should create new session', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        expect(session, isNotNull);
        expect(session.scenario.id, scenario.id);
        expect(session.messages, isEmpty);
        expect(session.score, isNull);
      });

      test('should get session by id', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        final retrievedSession = service.getSession(session.id);
        
        expect(retrievedSession, isNotNull);
        expect(retrievedSession!.id, session.id);
      });

      test('should add message to session', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        final message = SessionMessage(
          id: 'msg1',
          sessionId: session.id,
          sender: MessageSender.therapist,
          content: 'Merhaba, nasılsınız?',
          timestamp: DateTime.now(),
          metadata: {},
        );
        
        await service.addMessage(session.id, message);
        
        final updatedSession = service.getSession(session.id);
        expect(updatedSession!.messages.length, 1);
        expect(updatedSession.messages.first.content, 'Merhaba, nasılsınız?');
      });

      test('should calculate score for session', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        // Birkaç mesaj ekle
        final message1 = SessionMessage(
          id: 'msg1',
          sessionId: session.id,
          sender: MessageSender.therapist,
          content: 'Merhaba, nasılsınız?',
          timestamp: DateTime.now(),
          metadata: {},
        );
        
        final message2 = SessionMessage(
          id: 'msg2',
          sessionId: session.id,
          sender: MessageSender.client,
          content: 'İyi değilim, çok stresliyim',
          timestamp: DateTime.now(),
          metadata: {},
        );
        
        await service.addMessage(session.id, message1);
        await service.addMessage(session.id, message2);
        
        final score = service.calculateScore(session.id, 'therapist1');
        expect(score, isNotNull);
        expect(score!.sessionId, session.id);
        expect(score.overallScore, greaterThanOrEqualTo(0.0));
        expect(score.overallScore, lessThanOrEqualTo(100.0));
      });
    });

    group('AI Response Tests', () {
      test('should get AI response', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        final message = SessionMessage(
          id: 'msg1',
          sessionId: session.id,
          sender: MessageSender.client,
          content: 'Çok endişeliyim',
          timestamp: DateTime.now(),
          metadata: {},
        );
        
        await service.addMessage(session.id, message);
        
        final aiResponse = await service.getAIResponse(session.id, message.id);
        expect(aiResponse, isNotNull);
        expect(aiResponse!.sender, MessageSender.therapist);
        expect(aiResponse.content, isNotEmpty);
      });
    });

    group('Score Feedback Tests', () {
      test('should provide score feedback', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        final score = SimulationScore(
          id: 'score1',
          sessionId: session.id,
          empathyScore: 85.0,
          questioningScore: 75.0,
          activeListeningScore: 80.0,
          professionalLanguageScore: 90.0,
          overallScore: 82.5,
          strengths: ['Empati', 'Aktif dinleme'],
          areasForImprovement: ['Soru sorma'],
          detailedScores: {},
          calculatedAt: DateTime.now(),
        );
        
        final feedback = service.getScoreFeedback(score);
        expect(feedback, isNotEmpty);
        expect(feedback.contains('Mükemmel'), isTrue);
      });

      test('should provide improvement suggestions', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        final score = SimulationScore(
          id: 'score1',
          sessionId: session.id,
          empathyScore: 15.0,
          questioningScore: 20.0,
          activeListeningScore: 10.0,
          professionalLanguageScore: 25.0,
          overallScore: 17.5,
          strengths: [],
          areasForImprovement: ['Empati', 'Aktif dinleme'],
          detailedScores: {},
          calculatedAt: DateTime.now(),
        );
        
        final suggestions = service.getImprovementSuggestions(score);
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, greaterThan(1));
      });
    });

    group('Error Handling Tests', () {
      test('should handle non-existent session', () async {
        await service.initialize();
        
        final session = service.getSession('non_existent_id');
        expect(session, isNull);
      });

      test('should handle non-existent scenario', () async {
        await service.initialize();
        
        final scenario = service.getScenario('non_existent_id');
        expect(scenario, isNull);
      });
    });

    group('Data Validation Tests', () {
      test('should validate session data integrity', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        expect(session.id, isNotEmpty);
        expect(session.scenario.id, scenario.id);
        expect(session.messages, isEmpty);
        expect(session.sessionNotes, isEmpty);
        expect(session.score, isNull);
      });

      test('should validate message data integrity', () async {
        await service.initialize();
        
        final scenarios = service.getScenarios();
        final scenario = scenarios.first;
        
        final session = await service.createSession(scenario);
        
        final message = SessionMessage(
          id: 'msg1',
          sessionId: session.id,
          sender: MessageSender.therapist,
          content: 'Test mesajı',
          timestamp: DateTime.now(),
          metadata: {'key': 'value'},
        );
        
        await service.addMessage(session.id, message);
        
        final updatedSession = service.getSession(session.id);
        final addedMessage = updatedSession!.messages.first;
        
        expect(addedMessage.id, 'msg1');
        expect(addedMessage.sessionId, session.id);
        expect(addedMessage.sender, MessageSender.therapist);
        expect(addedMessage.content, 'Test mesajı');
        expect(addedMessage.metadata['key'], 'value');
      });
    });
  });
}
