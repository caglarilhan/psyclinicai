import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/supervision_models.dart';

class SupervisionSessionsWidget extends StatefulWidget {
  final List<SupervisionSession> sessions;
  final Function(SupervisionSession) onSessionTap;

  const SupervisionSessionsWidget({
    super.key,
    required this.sessions,
    required this.onSessionTap,
  });

  @override
  State<SupervisionSessionsWidget> createState() => _SupervisionSessionsWidgetState();
}

class _SupervisionSessionsWidgetState extends State<SupervisionSessionsWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'Tümü';
  String _selectedType = 'Tümü';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SupervisionSession> get _filteredSessions {
    return widget.sessions.where((session) {
      final matchesSearch = session.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          session.therapistName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          session.notes.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _selectedStatus == 'Tümü' || session.status.name == _selectedStatus;
      final matchesType = _selectedType == 'Tümü' || session.type.name == _selectedType;
      
      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Süpervizyon ara...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Durum',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Tümü', 'Planlandı', 'Tamamlandı', 'İptal Edildi']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedStatus = value!),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tür',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Tümü', 'Bireysel', 'Grup', 'Vaka', 'Süpervizyon']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            tabs: const [
              Tab(text: 'Tümü'),
              Tab(text: 'Planlandı'),
              Tab(text: 'Tamamlandı'),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Sessions List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSessionsList(_filteredSessions),
              _buildSessionsList(_filteredSessions.where((s) => s.status == SupervisionStatus.scheduled).toList()),
              _buildSessionsList(_filteredSessions.where((s) => s.status == SupervisionStatus.completed).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsList(List<SupervisionSession> sessions) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.supervisor_account_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Süpervizyon bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni bir süpervizyon ekleyin veya filtreleri değiştirin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(session.status).withOpacity(0.2),
              child: Icon(
                _getStatusIcon(session.status),
                color: _getStatusColor(session.status),
              ),
            ),
            title: Text(
              session.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.therapistName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(session.scheduledDate),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (session.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.notes,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(session.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                session.status.name,
                style: TextStyle(
                  color: _getStatusColor(session.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onSessionTap(session);
            },
          ),
        );
      },
    );
  }

  Color _getStatusColor(SupervisionStatus status) {
    switch (status) {
      case SupervisionStatus.pending:
        return Colors.grey;
      case SupervisionStatus.scheduled:
        return Colors.blue;
      case SupervisionStatus.completed:
        return Colors.green;
      case SupervisionStatus.cancelled:
        return Colors.red;
      case SupervisionStatus.inProgress:
        return Colors.orange;
      case SupervisionStatus.requiresFollowUp:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(SupervisionStatus status) {
    switch (status) {
      case SupervisionStatus.pending:
        return Icons.pending;
      case SupervisionStatus.scheduled:
        return Icons.schedule;
      case SupervisionStatus.completed:
        return Icons.check_circle;
      case SupervisionStatus.cancelled:
        return Icons.cancel;
      case SupervisionStatus.inProgress:
        return Icons.play_circle;
      case SupervisionStatus.requiresFollowUp:
        return Icons.follow_the_signs;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (sessionDate == today) {
      return 'Bugün ${_formatTime(dateTime)}';
    } else if (sessionDate == tomorrow) {
      return 'Yarın ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
