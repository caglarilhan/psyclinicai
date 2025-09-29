import 'package:flutter/material.dart';
import '../services/workflow_automation_service.dart';
import '../utils/theme.dart';

// Workflow Management Widget
class WorkflowManagementWidget extends StatefulWidget {
  const WorkflowManagementWidget({super.key});

  @override
  State<WorkflowManagementWidget> createState() => _WorkflowManagementWidgetState();
}

class _WorkflowManagementWidgetState extends State<WorkflowManagementWidget> {
  final WorkflowAutomationService _workflowService = WorkflowAutomationService();
  List<Map<String, dynamic>> _workflows = [];
  String _selectedTab = 'workflows';

  @override
  void initState() {
    super.initState();
    _loadWorkflows();
    
    // Listen to workflow updates
    _workflowService.workflowStream.listen((workflow) {
      _loadWorkflows();
    });
  }

  void _loadWorkflows() {
    setState(() {
      _workflows = _workflowService.workflows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.schema,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text('İş Akışı Yönetimi'),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'İş Akışları'),
              Tab(text: 'Görevler'),
              Tab(text: 'Onaylar'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _showCreateWorkflowDialog,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildWorkflowsTab(),
            _buildTasksTab(),
            _buildApprovalsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowsTab() {
    return _workflows.isEmpty
        ? _buildEmptyState('İş Akışı', 'Henüz iş akışı oluşturulmamış')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _workflows.length,
            itemBuilder: (context, index) {
              final workflow = _workflows[index];
              return _buildWorkflowCard(workflow);
            },
          );
  }

  Widget _buildWorkflowCard(Map<String, dynamic> workflow) {
    final status = workflow['status'] ?? 'active';
    final type = workflow['type'] ?? 'unknown';
    final steps = List<Map<String, dynamic>>.from(workflow['steps'] ?? []);
    final workflowTasks = _workflowService.getTasksByWorkflow(workflow['id']);
    final completedTasks = workflowTasks.where((t) => t['status'] == 'completed').length;
    final progress = steps.isNotEmpty ? (completedTasks / steps.length) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workflow['name'] ?? '',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workflow['description'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İlerleme',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Steps
            Text(
              'Adımlar (${completedTasks}/${steps.length})',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...steps.map((step) => _buildStepItem(step, workflowTasks)),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _startWorkflow(workflow['id']),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Başlat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showWorkflowDetails(workflow),
                    icon: const Icon(Icons.info),
                    label: const Text('Detaylar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step, List<Map<String, dynamic>> workflowTasks) {
    final stepId = step['id'];
    final stepTask = workflowTasks.firstWhere(
      (task) => task['stepId'] == stepId,
      orElse: () => {},
    );
    final status = stepTask['status'] ?? 'pending';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              step['name'] ?? '',
              style: TextStyle(
                color: status == 'completed' ? Colors.grey[600] : Colors.black87,
                decoration: status == 'completed' ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            '${step['duration']} dk',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.play_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'completed':
        return 'Tamamlandı';
      case 'pending':
        return 'Bekliyor';
      case 'cancelled':
        return 'İptal';
      default:
        return 'Bilinmiyor';
    }
  }

  Widget _buildTasksTab() {
    final tasks = _workflowService.tasks;
    
    return tasks.isEmpty
        ? _buildEmptyState('Görev', 'Henüz görev oluşturulmamış')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task);
            },
          );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] ?? 'pending';
    final priority = task['priority'] ?? 'medium';
    final dueDate = task['dueDate'];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(priority),
          child: Icon(
            Icons.task,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          task['title'] ?? '',
          style: TextStyle(
            fontWeight: status == 'completed' ? FontWeight.normal : FontWeight.w600,
            decoration: status == 'completed' ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task['description'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(status),
                const SizedBox(width: 8),
                if (dueDate != null)
                  Text(
                    'Son: ${_formatDate(dueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'start':
                _updateTaskStatus(task['id'], 'in_progress');
                break;
              case 'complete':
                _updateTaskStatus(task['id'], 'completed');
                break;
              case 'cancel':
                _updateTaskStatus(task['id'], 'cancelled');
                break;
            }
          },
          itemBuilder: (context) => [
            if (status == 'pending')
              const PopupMenuItem(
                value: 'start',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text('Başlat'),
                  ],
                ),
              ),
            if (status == 'in_progress')
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('Tamamla'),
                  ],
                ),
              ),
            if (status != 'completed' && status != 'cancelled')
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel),
                    SizedBox(width: 8),
                    Text('İptal Et'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildApprovalsTab() {
    final approvals = _workflowService.approvals;
    
    return approvals.isEmpty
        ? _buildEmptyState('Onay', 'Henüz onay talebi oluşturulmamış')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: approvals.length,
            itemBuilder: (context, index) {
              final approval = approvals[index];
              return _buildApprovalCard(approval);
            },
          );
  }

  Widget _buildApprovalCard(Map<String, dynamic> approval) {
    final status = approval['status'] ?? 'pending';
    final type = approval['type'] ?? 'general';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            Icons.approval,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(approval['title'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(approval['description'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Talep Eden: ${approval['requester']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  'Onaylayan: ${approval['approver']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: status == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _updateApprovalStatus(approval['id'], 'approved'),
                    icon: const Icon(Icons.check, color: Colors.green),
                  ),
                  IconButton(
                    onPressed: () => _updateApprovalStatus(approval['id'], 'rejected'),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              )
            : _buildStatusChip(status),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schema,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni $title oluşturmak için + butonuna tıklayın',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateWorkflowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni İş Akışı Oluştur'),
        content: const WorkflowCreationWidget(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  void _startWorkflow(String workflowId) {
    _workflowService.startWorkflow(workflowId, {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İş akışı başlatıldı')),
    );
  }

  void _showWorkflowDetails(Map<String, dynamic> workflow) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(workflow['name'] ?? ''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Açıklama: ${workflow['description'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Tür: ${_workflowService.workflowTypes[workflow['type']] ?? workflow['type']}'),
            const SizedBox(height: 8),
            Text('Durum: ${_getStatusText(workflow['status'])}'),
            const SizedBox(height: 8),
            Text('Oluşturulma: ${_formatDate(workflow['createdAt'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(String taskId, String status) {
    _workflowService.updateTaskStatus(taskId, status);
  }

  void _updateApprovalStatus(String approvalId, String status) {
    _workflowService.updateApprovalStatus(approvalId, status, null);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}

// Workflow Creation Widget
class WorkflowCreationWidget extends StatefulWidget {
  const WorkflowCreationWidget({super.key});

  @override
  State<WorkflowCreationWidget> createState() => _WorkflowCreationWidgetState();
}

class _WorkflowCreationWidgetState extends State<WorkflowCreationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'client_onboarding';
  final List<Map<String, dynamic>> _steps = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'İş Akışı Adı',
              hintText: 'Örn: Müşteri Kayıt Süreci',
            ),
            validator: (value) {
              if (value?.isEmpty == true) {
                return 'İş akışı adı gerekli';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              hintText: 'İş akışının açıklaması',
            ),
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: const InputDecoration(
              labelText: 'İş Akışı Türü',
            ),
            items: WorkflowAutomationService().workflowTypes.entries.map((entry) => 
              DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              ),
            ).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Steps
          Text(
            'Adımlar',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          ..._steps.map((step) => _buildStepItem(step)),
          
          ElevatedButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: const Text('Adım Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(Map<String, dynamic> step) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Adım Adı',
                hintText: 'Örn: İlk Görüşme',
              ),
              onChanged: (value) {
                step['name'] = value;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                hintText: 'Adımın açıklaması',
              ),
              onChanged: (value) {
                step['description'] = value;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Sorumlu',
                      hintText: 'therapist',
                    ),
                    onChanged: (value) {
                      step['assignee'] = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Süre (dk)',
                      hintText: '30',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      step['duration'] = value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addStep() {
    setState(() {
      _steps.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': '',
        'description': '',
        'assignee': '',
        'duration': '',
        'status': 'pending',
      });
    });
  }
}

// Workflow Stats Widget
class WorkflowStatsWidget extends StatefulWidget {
  const WorkflowStatsWidget({super.key});

  @override
  State<WorkflowStatsWidget> createState() => _WorkflowStatsWidgetState();
}

class _WorkflowStatsWidgetState extends State<WorkflowStatsWidget> {
  final WorkflowAutomationService _workflowService = WorkflowAutomationService();
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _updateStats();
  }

  void _updateStats() {
    setState(() {
      _stats = _workflowService.getWorkflowStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schema,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'İş Akışı İstatistikleri',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatItem(
              'Toplam İş Akışı',
              '${_stats['totalWorkflows'] ?? 0}',
              Icons.schema,
              Colors.blue,
            ),
            
            _buildStatItem(
              'Aktif İş Akışı',
              '${_stats['activeWorkflows'] ?? 0}',
              Icons.play_circle,
              Colors.green,
            ),
            
            _buildStatItem(
              'Tamamlanan İş Akışı',
              '${_stats['completedWorkflows'] ?? 0}',
              Icons.check_circle,
              Colors.orange,
            ),
            
            _buildStatItem(
              'Bekleyen Görev',
              '${_stats['pendingTasks'] ?? 0}',
              Icons.task,
              Colors.red,
            ),
            
            _buildStatItem(
              'Bekleyen Onay',
              '${_stats['pendingApprovals'] ?? 0}',
              Icons.approval,
              Colors.purple,
            ),
            
            _buildStatItem(
              'Aktif Otomasyon',
              '${_stats['activeAutomations'] ?? 0}',
              Icons.auto_awesome,
              Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
