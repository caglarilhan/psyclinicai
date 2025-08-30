import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class WorkflowAutomationService {
  static final WorkflowAutomationService _instance = WorkflowAutomationService._internal();
  factory WorkflowAutomationService() => _instance;
  WorkflowAutomationService._internal();

  // Workflow durumu
  bool _isInitialized = false;
  List<Map<String, dynamic>> _workflows = [];
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _approvals = [];
  List<Map<String, dynamic>> _automations = [];
  
  // Workflow türleri
  final Map<String, String> _workflowTypes = {
    'client_onboarding': 'Müşteri Kayıt Süreci',
    'session_scheduling': 'Seans Planlama',
    'treatment_plan': 'Tedavi Planı',
    'emergency_response': 'Acil Durum Yanıtı',
    'billing_process': 'Faturalama Süreci',
    'compliance_check': 'Uyumluluk Kontrolü',
  };
  
  // Task durumları
  final Map<String, String> _taskStatuses = {
    'pending': 'Bekliyor',
    'in_progress': 'Devam Ediyor',
    'completed': 'Tamamlandı',
    'cancelled': 'İptal Edildi',
    'overdue': 'Gecikmiş',
  };
  
  // Stream controllers
  final StreamController<Map<String, dynamic>> _workflowController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _taskController = StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _approvalController = StreamController<Map<String, dynamic>>.broadcast();

  // Streams
  Stream<Map<String, dynamic>> get workflowStream => _workflowController.stream;
  Stream<Map<String, dynamic>> get taskStream => _taskController.stream;
  Stream<Map<String, dynamic>> get approvalStream => _approvalController.stream;

  // Getter'lar
  bool get isInitialized => _isInitialized;
  List<Map<String, dynamic>> get workflows => List.unmodifiable(_workflows);
  List<Map<String, dynamic>> get tasks => List.unmodifiable(_tasks);
  List<Map<String, dynamic>> get approvals => List.unmodifiable(_approvals);
  List<Map<String, dynamic>> get automations => List.unmodifiable(_automations);
  Map<String, String> get workflowTypes => Map.unmodifiable(_workflowTypes);
  Map<String, String> get taskStatuses => Map.unmodifiable(_taskStatuses);

  // Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _loadWorkflows();
    await _loadTasks();
    await _loadApprovals();
    await _loadAutomations();
    
    _isInitialized = true;
    
    // Demo workflows oluştur
    await _createDemoWorkflows();
  }

  // Demo workflows oluştur
  Future<void> _createDemoWorkflows() async {
    if (_workflows.isEmpty) {
      await createWorkflow(
        name: 'Müşteri Kayıt Süreci',
        type: 'client_onboarding',
        description: 'Yeni müşteri kayıt ve değerlendirme süreci',
        steps: [
          {
            'id': '1',
            'name': 'İlk Görüşme',
            'description': 'Müşteri ile ilk görüşme yapılır',
            'assignee': 'therapist',
            'duration': '30',
            'status': 'pending',
          },
          {
            'id': '2',
            'name': 'Değerlendirme',
            'description': 'Psikolojik değerlendirme yapılır',
            'assignee': 'psychologist',
            'duration': '60',
            'status': 'pending',
          },
          {
            'id': '3',
            'name': 'Tedavi Planı',
            'description': 'Tedavi planı oluşturulur',
            'assignee': 'therapist',
            'duration': '45',
            'status': 'pending',
          },
        ],
      );
    }
  }

  // Workflow oluştur
  Future<void> createWorkflow({
    required String name,
    required String type,
    required String description,
    required List<Map<String, dynamic>> steps,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? actions,
  }) async {
    final workflow = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'type': type,
      'description': description,
      'steps': steps,
      'conditions': conditions ?? {},
      'actions': actions ?? {},
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _workflows.add(workflow);
    _saveWorkflows();
    
    _workflowController.add(workflow);
  }

  // Workflow başlat
  Future<void> startWorkflow(String workflowId, Map<String, dynamic> data) async {
    final workflow = _workflows.firstWhere((w) => w['id'] == workflowId);
    final steps = List<Map<String, dynamic>>.from(workflow['steps']);
    
    // İlk adımı başlat
    if (steps.isNotEmpty) {
      final firstStep = steps[0];
      await createTask(
        title: firstStep['name'],
        description: firstStep['description'],
        assignee: firstStep['assignee'],
        workflowId: workflowId,
        stepId: firstStep['id'],
        data: data,
      );
    }
  }

  // Task oluştur
  Future<void> createTask({
    required String title,
    required String description,
    required String assignee,
    String? workflowId,
    String? stepId,
    Map<String, dynamic>? data,
    DateTime? dueDate,
    String? priority,
  }) async {
    final task = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'description': description,
      'assignee': assignee,
      'workflowId': workflowId,
      'stepId': stepId,
      'data': data ?? {},
      'status': 'pending',
      'priority': priority ?? 'medium',
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _tasks.add(task);
    _saveTasks();
    
    _taskController.add(task);
  }

  // Task durumu güncelle
  Future<void> updateTaskStatus(String taskId, String status) async {
    final index = _tasks.indexWhere((t) => t['id'] == taskId);
    if (index != -1) {
      _tasks[index]['status'] = status;
      _tasks[index]['updatedAt'] = DateTime.now().toIso8601String();
      _saveTasks();
      
      _taskController.add(_tasks[index]);
      
      // Workflow'u kontrol et
      await _checkWorkflowProgress(_tasks[index]['workflowId']);
    }
  }

  // Workflow ilerlemesini kontrol et
  Future<void> _checkWorkflowProgress(String? workflowId) async {
    if (workflowId == null) return;
    
    final workflow = _workflows.firstWhere((w) => w['id'] == workflowId);
    final workflowTasks = _tasks.where((t) => t['workflowId'] == workflowId).toList();
    
    // Tüm görevler tamamlandı mı?
    final allCompleted = workflowTasks.every((task) => task['status'] == 'completed');
    
    if (allCompleted) {
      // Workflow tamamlandı
      await _completeWorkflow(workflowId);
    } else {
      // Sonraki adımı başlat
      await _startNextStep(workflowId, workflowTasks);
    }
  }

  // Sonraki adımı başlat
  Future<void> _startNextStep(String workflowId, List<Map<String, dynamic>> workflowTasks) async {
    final workflow = _workflows.firstWhere((w) => w['id'] == workflowId);
    final steps = List<Map<String, dynamic>>.from(workflow['steps']);
    
    // Tamamlanan adımları bul
    final completedSteps = workflowTasks
        .where((task) => task['status'] == 'completed')
        .map((task) => task['stepId'])
        .toList();
    
    // Sonraki adımı bul
    final nextStep = steps.firstWhere(
      (step) => !completedSteps.contains(step['id']),
      orElse: () => steps.last,
    );
    
    // Sonraki görevi oluştur
    await createTask(
      title: nextStep['name'],
      description: nextStep['description'],
      assignee: nextStep['assignee'],
      workflowId: workflowId,
      stepId: nextStep['id'],
    );
  }

  // Workflow tamamla
  Future<void> _completeWorkflow(String workflowId) async {
    final index = _workflows.indexWhere((w) => w['id'] == workflowId);
    if (index != -1) {
      _workflows[index]['status'] = 'completed';
      _workflows[index]['completedAt'] = DateTime.now().toIso8601String();
      _saveWorkflows();
      
      _workflowController.add(_workflows[index]);
    }
  }

  // Onay talebi oluştur
  Future<void> createApprovalRequest({
    required String title,
    required String description,
    required String requester,
    required String approver,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final approval = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'description': description,
      'requester': requester,
      'approver': approver,
      'type': type,
      'data': data ?? {},
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _approvals.add(approval);
    _saveApprovals();
    
    _approvalController.add(approval);
  }

  // Onay durumu güncelle
  Future<void> updateApprovalStatus(String approvalId, String status, String? comment) async {
    final index = _approvals.indexWhere((a) => a['id'] == approvalId);
    if (index != -1) {
      _approvals[index]['status'] = status;
      _approvals[index]['comment'] = comment;
      _approvals[index]['updatedAt'] = DateTime.now().toIso8601String();
      _saveApprovals();
      
      _approvalController.add(_approvals[index]);
    }
  }

  // Otomasyon oluştur
  Future<void> createAutomation({
    required String name,
    required String trigger,
    required List<Map<String, dynamic>> actions,
    Map<String, dynamic>? conditions,
    bool isActive = true,
  }) async {
    final automation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'trigger': trigger,
      'actions': actions,
      'conditions': conditions ?? {},
      'isActive': isActive,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    _automations.add(automation);
    _saveAutomations();
  }

  // Otomasyon tetikle
  Future<void> triggerAutomation(String trigger, Map<String, dynamic> data) async {
    final activeAutomations = _automations.where((a) => a['isActive'] == true).toList();
    
    for (final automation in activeAutomations) {
      if (automation['trigger'] == trigger) {
        await _executeAutomationActions(automation, data);
      }
    }
  }

  // Otomasyon aksiyonlarını çalıştır
  Future<void> _executeAutomationActions(Map<String, dynamic> automation, Map<String, dynamic> data) async {
    final actions = List<Map<String, dynamic>>.from(automation['actions']);
    
    for (final action in actions) {
      await _executeAction(action, data);
    }
  }

  // Aksiyon çalıştır
  Future<void> _executeAction(Map<String, dynamic> action, Map<String, dynamic> data) async {
    final actionType = action['type'];
    
    switch (actionType) {
      case 'create_task':
        await createTask(
          title: action['title'],
          description: action['description'],
          assignee: action['assignee'],
          data: data,
        );
        break;
      case 'send_notification':
        // TODO: Push notification gönder
        print('Sending notification: ${action['message']}');
        break;
      case 'create_approval':
        await createApprovalRequest(
          title: action['title'],
          description: action['description'],
          requester: action['requester'],
          approver: action['approver'],
          type: action['approvalType'],
          data: data,
        );
        break;
      case 'update_status':
        // TODO: Status güncelle
        print('Updating status: ${action['status']}');
        break;
    }
  }

  // Workflow'ları kaydet
  Future<void> _saveWorkflows() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('workflows', json.encode(_workflows));
  }

  // Workflow'ları yükle
  Future<void> _loadWorkflows() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('workflows');
    if (data != null) {
      _workflows = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Task'ları kaydet
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', json.encode(_tasks));
  }

  // Task'ları yükle
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      _tasks = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Onayları kaydet
  Future<void> _saveApprovals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('approvals', json.encode(_approvals));
  }

  // Onayları yükle
  Future<void> _loadApprovals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('approvals');
    if (data != null) {
      _approvals = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Otomasyonları kaydet
  Future<void> _saveAutomations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('automations', json.encode(_automations));
  }

  // Otomasyonları yükle
  Future<void> _loadAutomations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('automations');
    if (data != null) {
      _automations = List<Map<String, dynamic>>.from(json.decode(data));
    }
  }

  // Workflow istatistikleri
  Map<String, dynamic> getWorkflowStats() {
    final activeWorkflows = _workflows.where((w) => w['status'] == 'active').length;
    final completedWorkflows = _workflows.where((w) => w['status'] == 'completed').length;
    final pendingTasks = _tasks.where((t) => t['status'] == 'pending').length;
    final pendingApprovals = _approvals.where((a) => a['status'] == 'pending').length;

    return {
      'totalWorkflows': _workflows.length,
      'activeWorkflows': activeWorkflows,
      'completedWorkflows': completedWorkflows,
      'totalTasks': _tasks.length,
      'pendingTasks': pendingTasks,
      'totalApprovals': _approvals.length,
      'pendingApprovals': pendingApprovals,
      'totalAutomations': _automations.length,
      'activeAutomations': _automations.where((a) => a['isActive'] == true).length,
    };
  }

  // Task'ları filtrele
  List<Map<String, dynamic>> getTasksByAssignee(String assignee) {
    return _tasks.where((t) => t['assignee'] == assignee).toList();
  }

  List<Map<String, dynamic>> getTasksByStatus(String status) {
    return _tasks.where((t) => t['status'] == status).toList();
  }

  List<Map<String, dynamic>> getTasksByWorkflow(String workflowId) {
    return _tasks.where((t) => t['workflowId'] == workflowId).toList();
  }

  // Onayları filtrele
  List<Map<String, dynamic>> getApprovalsByApprover(String approver) {
    return _approvals.where((a) => a['approver'] == approver).toList();
  }

  List<Map<String, dynamic>> getApprovalsByStatus(String status) {
    return _approvals.where((a) => a['status'] == status).toList();
  }

  // Dispose
  void dispose() {
    _workflowController.close();
    _taskController.close();
    _approvalController.close();
  }
}
