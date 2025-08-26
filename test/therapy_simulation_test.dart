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
      service.dispose();
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

    group('Session Management Tests', () {
      test('should create new session', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        expect(session, isNotNull);
        expect(session.title, 'Test Seansı');
        expect(session.status, SimulationStatus.notStarted);
        expect(session.approach, TherapyApproach.cbt);
      });

      test('should start session', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        await service.startSession(session.id);
        
        final updatedSession = service.getSession(session.id);
        expect(updatedSession?.status, SimulationStatus.inProgress);
        expect(updatedSession?.startedAt, isNotNull);
      });

      test('should complete session', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        await service.startSession(session.id);
        await service.completeSession(session.id);
        
        final completedSession = service.getSession(session.id);
        expect(completedSession?.status, SimulationStatus.completed);
        expect(completedSession?.completedAt, isNotNull);
      });

      test('should get all sessions', () async {
        await service.initialize();
        
        await service.createSession(
          title: 'Seans 1',
          description: 'Açıklama 1',
          approach: TherapyApproach.cbt,
          createdBy: 'user1',
        );
        
        await service.createSession(
          title: 'Seans 2',
          description: 'Açıklama 2',
          approach: TherapyApproach.dbt,
          createdBy: 'user2',
        );
        
        final sessions = service.getSessions();
        expect(sessions.length, greaterThanOrEqualTo(1));
      });
    });

    group('Turn Management Tests', () {
      test('should add turn to session', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turn = await service.addTurn(
          sessionId: session.id,
          content: 'Merhaba, nasılsınız?',
          role: RoleType.therapist,
        );
        
        expect(turn, isNotNull);
        expect(turn.content, 'Merhaba, nasılsınız?');
        expect(turn.role, RoleType.therapist);
        expect(turn.turnNumber, 1);
      });

      test('should get turns for session', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        await service.addTurn(
          sessionId: session.id,
          content: 'Terapist sorusu',
          role: RoleType.therapist,
        );
        
        await service.addTurn(
          sessionId: session.id,
          content: 'Hasta yanıtı',
          role: RoleType.patient,
        );
        
        final turns = service.getTurns(session.id);
        expect(turns.length, 2);
        expect(turns[0].role, RoleType.therapist);
        expect(turns[1].role, RoleType.patient);
      });

      test('should handle multiple turns correctly', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        for (int i = 0; i < 5; i++) {
          await service.addTurn(
            sessionId: session.id,
            content: 'Turn $i',
            role: i % 2 == 0 ? RoleType.therapist : RoleType.patient,
          );
        }
        
        final turns = service.getTurns(session.id);
        expect(turns.length, 5);
        expect(turns[4].turnNumber, 5);
      });
    });

    group('AI Response Tests', () {
      test('should get AI response for therapist role', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turn = await service.addTurn(
          sessionId: session.id,
          content: 'Hasta sorusu',
          role: RoleType.patient,
        );
        
        final aiResponse = await service.getAIResponse(
          turnId: turn.id,
          sessionId: session.id,
          role: RoleType.therapist,
        );
        
        expect(aiResponse, isNotNull);
        expect(aiResponse.role, RoleType.therapist);
        expect(aiResponse.content, isNotEmpty);
        expect(aiResponse.techniques, isNotNull);
      });

      test('should get AI response for patient role', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turn = await service.addTurn(
          sessionId: session.id,
          content: 'Terapist sorusu',
          role: RoleType.therapist,
        );
        
        final aiResponse = await service.getAIResponse(
          turnId: turn.id,
          sessionId: session.id,
          role: RoleType.patient,
        );
        
        expect(aiResponse, isNotNull);
        expect(aiResponse.role, RoleType.patient);
        expect(aiResponse.content, isNotEmpty);
      });

      test('should update turn with AI response', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turn = await service.addTurn(
          sessionId: session.id,
          content: 'Hasta sorusu',
          role: RoleType.patient,
        );
        
        await service.getAIResponse(
          turnId: turn.id,
          sessionId: session.id,
          role: RoleType.therapist,
        );
        
        final updatedTurns = service.getTurns(session.id);
        final updatedTurn = updatedTurns.firstWhere((t) => t.id == turn.id);
        expect(updatedTurn.aiResponse, isNotEmpty);
      });
    });

    group('Metrics Calculation Tests', () {
      test('should calculate metrics after session completion', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        await service.startSession(session.id);
        
        // Birkaç turn ekle
        await service.addTurn(
          sessionId: session.id,
          content: 'Terapist sorusu 1',
          role: RoleType.therapist,
        );
        
        await service.addTurn(
          sessionId: session.id,
          content: 'Hasta yanıtı 1',
          role: RoleType.patient,
        );
        
        await service.addTurn(
          sessionId: session.id,
          content: 'Terapist sorusu 2',
          role: RoleType.therapist,
        );
        
        await service.completeSession(session.id);
        
        final metrics = service.getMetrics(session.id);
        expect(metrics, isNotNull);
        expect(metrics!.totalTurns, 3);
        expect(metrics.userTurns, 2); // therapist turns
        expect(metrics.aiTurns, 1); // patient turns
        expect(metrics.strengths, isNotEmpty);
        expect(metrics.areasForImprovement, isNotEmpty);
      });

      test('should generate mock metrics for empty session', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        await service.startSession(session.id);
        await service.completeSession(session.id);
        
        final metrics = service.getMetrics(session.id);
        expect(metrics, isNotNull);
        expect(metrics!.totalTurns, greaterThanOrEqualTo(0)); // Mock data
        expect(metrics.engagementScore, greaterThanOrEqualTo(0.0));
        expect(metrics.techniqueUsageScore, greaterThanOrEqualTo(0.0));
        expect(metrics.empathyScore, greaterThanOrEqualTo(0.0));
      });
    });

    group('Stream Tests', () {
      test('should emit session updates', () async {
        await service.initialize();
        
        final sessionUpdates = <TherapySimulationSession>[];
        service.sessionStream.listen(sessionUpdates.add);
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        await service.startSession(session.id);
        
        expect(sessionUpdates.length, 2); // create + start
        expect(sessionUpdates[0].status, SimulationStatus.notStarted);
        expect(sessionUpdates[1].status, SimulationStatus.inProgress);
      });

      test('should emit turn updates', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turnUpdates = <SimulationTurn>[];
        service.turnStream.listen(turnUpdates.add);
        
        await service.addTurn(
          sessionId: session.id,
          content: 'Test turn',
          role: RoleType.therapist,
        );
        
        expect(turnUpdates.length, 1);
        expect(turnUpdates[0].content, 'Test turn');
      });

      test('should emit metrics updates', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final metricsUpdates = <SimulationMetrics>[];
        service.metricsStream.listen(metricsUpdates.add);
        
        await service.startSession(session.id);
        await service.completeSession(session.id);
        
        expect(metricsUpdates.length, 1);
        expect(metricsUpdates[0].sessionId, session.id);
      });
    });

    group('Error Handling Tests', () {
      test('should handle session not found error', () async {
        await service.initialize();
        
        expect(
          () => service.startSession('non_existent_id'),
          returnsNormally, // Service handles errors gracefully
        );
      });

      test('should handle turn creation for non-existent session', () async {
        await service.initialize();
        
        expect(
          () => service.addTurn(
            sessionId: 'non_existent_id',
            content: 'Test',
            role: RoleType.therapist,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle AI response for non-existent session', () async {
        await service.initialize();
        
        expect(
          () => service.getAIResponse(
            turnId: 'turn_id',
            sessionId: 'non_existent_id',
            role: RoleType.therapist,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Data Validation Tests', () {
      test('should validate session data integrity', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
          learningObjectives: ['Hedef 1', 'Hedef 2'],
        );
        
        expect(session.id, isNotEmpty);
        expect(session.createdAt, isNotNull);
        expect(session.learningObjectives.length, 2);
        expect(session.metadata, isNotNull);
      });

      test('should validate turn data integrity', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turn = await service.addTurn(
          sessionId: session.id,
          content: 'Test turn',
          role: RoleType.therapist,
          context: {'key': 'value'},
        );
        
        expect(turn.id, isNotEmpty);
        expect(turn.sessionId, session.id);
        expect(turn.turnNumber, 1);
        expect(turn.timestamp, isNotNull);
        expect(turn.context['key'], 'value');
      });

      test('should validate AI response data integrity', () async {
        await service.initialize();
        
        final session = await service.createSession(
          title: 'Test Seansı',
          description: 'Test açıklaması',
          approach: TherapyApproach.cbt,
          createdBy: 'test_user',
        );
        
        final turn = await service.addTurn(
          sessionId: session.id,
          content: 'Test turn',
          role: RoleType.patient,
        );
        
        final aiResponse = await service.getAIResponse(
          turnId: turn.id,
          sessionId: session.id,
          role: RoleType.therapist,
        );
        
        expect(aiResponse.id, isNotEmpty);
        expect(aiResponse.turnId, turn.id);
        expect(aiResponse.role, RoleType.therapist);
        expect(aiResponse.content, isNotEmpty);
        expect(aiResponse.techniques, isNotNull);
        expect(aiResponse.emotions, isNotNull);
        expect(aiResponse.timestamp, isNotNull);
      });
    });
  });
}
