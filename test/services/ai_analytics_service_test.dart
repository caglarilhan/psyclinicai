import 'package:flutter_test/flutter_test.dart';
import 'package:psyclinicai/services/ai_analytics_service.dart';
import '../test_config.dart';

void main() {
  group('AIAnalyticsService Tests', () {
    late AIAnalyticsService aiService;

    setUpAll(() async {
      await TestConfig.initialize();
    });

    setUp(() {
      aiService = AIAnalyticsService();
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group('Service Initialization', () {
      test('should initialize successfully', () async {
        await aiService.initialize();
        TestConfig.assertServiceInitialized(aiService, 'AIAnalyticsService');
      });

      test('should have default configuration', () {
        final config = aiService.defaultConfig;
        expect(config, isNotNull);
        expect(config.maxConcurrentTasks, isA<int>);
        expect(config.taskTimeout, isA<int>);
        expect(config.retryAttempts, isA<int>);
      });
    });

    group('Task Management', () {
      test('should create AI task successfully', () async {
        final taskData = TestConfig.generateTestAIAnalysisData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
          metadata: taskData['results'],
        );

        expect(task, isNotNull);
        expect(task.id, isNotEmpty);
        expect(task.type, equals(taskData['analysisType']));
        expect(task.status, equals('pending'));
        expect(task.inputData, equals(taskData['inputData']));
      });

      test('should get task by ID', () async {
        final taskData = TestConfig.generateTestAIAnalysisData();
        
        final createdTask = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        final retrievedTask = await aiService.getTaskById(createdTask.id);
        
        expect(retrievedTask, isNotNull);
        expect(retrievedTask!.id, equals(createdTask.id));
        expect(retrievedTask.type, equals(createdTask.type));
      });

      test('should get all tasks', () async {
        final tasks = await aiService.getAllTasks();
        TestConfig.assertListNotEmpty(tasks, 'Tasks list');
        
        for (final task in tasks) {
          TestConfig.assertDataValid(task, ['id', 'type', 'status', 'inputData']);
        }
      });

      test('should get tasks by type', () async {
        final sentimentTasks = await aiService.getTasksByType('sentiment_analysis');
        expect(sentimentTasks, isA<List<Map<String, dynamic>>>());
        
        for (final task in sentimentTasks) {
          expect(task['type'], equals('sentiment_analysis'));
        }
      });

      test('should get tasks by status', () async {
        final pendingTasks = await aiService.getTasksByStatus('pending');
        expect(pendingTasks, isA<List<Map<String, dynamic>>>());
        
        for (final task in pendingTasks) {
          expect(task['status'], equals('pending'));
        }
      });
    });

    group('Task Execution', () {
      test('should execute task successfully', () async {
        final taskData = TestConfig.generateTestAIAnalysisData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        final result = await aiService.executeTask(task.id);
        
        expect(result, isNotNull);
        expect(result['success'], isTrue);
        expect(result['taskId'], equals(task.id));
        expect(result['results'], isNotNull);
      });

      test('should handle task execution errors', () async {
        final result = await aiService.executeTask('non_existent_task_id');
        
        expect(result, isNotNull);
        expect(result['success'], isFalse);
        expect(result['error'], isNotEmpty);
      });

      test('should retry failed tasks', () async {
        final taskData = TestConfig.generateTestAIAnalyticsData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'high',
        );

        // Simulate task failure
        await aiService.updateTaskStatus(task.id, 'failed');
        
        final retryResult = await aiService.retryTask(task.id);
        
        expect(retryResult, isNotNull);
        expect(retryResult['success'], isTrue);
        expect(retryResult['taskId'], equals(task.id));
      });
    });

    group('Task Status Management', () {
      test('should update task status', () async {
        final taskData = TestConfig.generateTestAIAnalyticsData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        await aiService.updateTaskStatus(task.id, 'processing');
        
        final updatedTask = await aiService.getTaskById(task.id);
        expect(updatedTask!['status'], equals('processing'));
      });

      test('should update task progress', () async {
        final taskData = TestConfig.generateTestAIAnalyticsData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        await aiService.updateTaskProgress(task.id, 50);
        
        final updatedTask = await aiService.getTaskById(task.id);
        expect(updatedTask!['progress'], equals(50));
      });

      test('should update task results', () async {
        final taskData = TestConfig.generateTestAIAnalyticsData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        final results = {
          'sentiment': 'positive',
          'confidence': 0.85,
          'recommendations': ['Test recommendation'],
        };

        await aiService.updateTaskResults(task.id, results);
        
        final updatedTask = await aiService.getTaskById(task.id);
        expect(updatedTask!['results'], equals(results));
      });
    });

    group('Task History and Analytics', () {
      test('should get task history', () async {
        final history = await aiService.getTaskHistory();
        expect(history, isA<List<Map<String, dynamic>>>());
        
        for (final record in history) {
          TestConfig.assertDataValid(record, ['taskId', 'action', 'timestamp']);
        }
      });

      test('should get task statistics', () async {
        final stats = await aiService.getTaskStatistics();
        
        expect(stats, isNotNull);
        expect(stats['totalTasks'], isA<int>);
        expect(stats['completedTasks'], isA<int>());
        expect(stats['failedTasks'], isA<int>());
        expect(stats['successRate'], isA<double>());
      });

      test('should get performance metrics', () async {
        final metrics = await aiService.getPerformanceMetrics();
        
        expect(metrics, isNotNull);
        expect(metrics['averageExecutionTime'], isA<double>());
        expect(metrics['totalExecutionTime'], isA<int>());
        expect(metrics['taskCount'], isA<int>());
      });
    });

    group('Stream Management', () {
      test('should emit task updates', () async {
        final taskData = TestConfig.generateTestAIAnalyticsData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        // Listen to task updates
        final updates = <Map<String, dynamic>>[];
        final subscription = aiService.taskUpdateStream.listen(updates.add);

        // Wait for async operations
        await TestConfig.waitForAsync();

        expect(updates, isNotEmpty);
        
        subscription.cancel();
      });

      test('should emit progress updates', () async {
        final taskData = TestConfig.generateTestAIAnalyticsData();
        
        final task = await aiService.createAITask(
          type: taskData['analysisType'],
          inputData: taskData['inputData'],
          priority: 'normal',
        );

        // Listen to progress updates
        final progressUpdates = <Map<String, dynamic>>[];
        final subscription = aiService.progressStream.listen(progressUpdates.add);

        // Update progress
        await aiService.updateTaskProgress(task.id, 75);

        // Wait for async operations
        await TestConfig.waitForAsync();

        expect(progressUpdates, isNotEmpty);
        
        subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('should handle invalid task ID', () async {
        final result = await aiService.getTaskById('invalid_id');
        expect(result, isNull);
      });

      test('should handle invalid status updates', () async {
        final result = await aiService.updateTaskStatus('invalid_id', 'invalid_status');
        expect(result, isFalse);
      });

      test('should handle invalid progress updates', () async {
        final result = await aiService.updateTaskProgress('invalid_id', 150);
        expect(result, isFalse);
      });

      test('should handle invalid results updates', () async {
        final result = await aiService.updateTaskResults('invalid_id', {});
        expect(result, isFalse);
      });
    });

    group('Performance Tests', () {
      test('should handle multiple concurrent tasks', () async {
        final tasks = <String>[];
        
        // Create multiple tasks
        for (int i = 0; i < 5; i++) {
          final task = await aiService.createAITask(
            type: 'test_analysis_$i',
            inputData: 'Test data $i',
            priority: 'normal',
          );
          tasks.add(task.id);
        }

        expect(tasks.length, equals(5));
        
        // Execute all tasks
        final results = await Future.wait(
          tasks.map((taskId) => aiService.executeTask(taskId))
        );

        expect(results.length, equals(5));
        
        for (final result in results) {
          expect(result['success'], isTrue);
        }
      });

      test('should handle large input data', () async {
        final largeInputData = 'A' * 10000; // 10KB of data
        
        final task = await aiService.createAITask(
          type: 'large_data_analysis',
          inputData: largeInputData,
          priority: 'high',
        );

        expect(task, isNotNull);
        expect(task.inputData, equals(largeInputData));
        
        final result = await aiService.executeTask(task.id);
        expect(result['success'], isTrue);
      });
    });

    group('Data Validation', () {
      test('should validate task creation data', () {
        expect(() => aiService.createAITask(
          type: '',
          inputData: 'test',
          priority: 'normal',
        ), throwsA(isA<ArgumentError>()));

        expect(() => aiService.createAITask(
          type: 'test',
          inputData: '',
          priority: 'normal',
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate priority levels', () {
        expect(() => aiService.createAITask(
          type: 'test',
          inputData: 'test',
          priority: 'invalid_priority',
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate task types', () {
        expect(() => aiService.createAITask(
          type: 'invalid_type',
          inputData: 'test',
          priority: 'normal',
        ), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
