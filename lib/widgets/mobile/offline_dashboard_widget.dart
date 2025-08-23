import 'package:flutter/material.dart';
import '../../services/offline_service.dart';

class OfflineDashboardWidget extends StatefulWidget {
  const OfflineDashboardWidget({super.key});

  @override
  State<OfflineDashboardWidget> createState() => _OfflineDashboardWidgetState();
}

class _OfflineDashboardWidgetState extends State<OfflineDashboardWidget> {
  final OfflineService _offlineService = OfflineService();
  final TextEditingController _dataKeyController = TextEditingController();
  final TextEditingController _dataTypeController = TextEditingController();
  final TextEditingController _dataContentController = TextEditingController();
  
  OfflineStatistics? _statistics;
  bool _isLoading = false;
  String _lastAction = '';

  @override
  void initState() {
    super.initState();
    _initializeOfflineService();
    _loadStatistics();
  }

  @override
  void dispose() {
    _dataKeyController.dispose();
    _dataTypeController.dispose();
    _dataContentController.dispose();
    super.dispose();
  }

  Future<void> _initializeOfflineService() async {
    await _offlineService.initialize();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _offlineService.getOfflineStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading statistics: $e');
    }
  }

  Future<void> _enableOfflineMode() async {
    setState(() => _isLoading = true);
    try {
      await _offlineService.enableOfflineMode();
      _showSnackBar('✅ Offline mode enabled!');
      await _loadStatistics();
    } catch (e) {
      _showSnackBar('❌ Error enabling offline mode: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disableOfflineMode() async {
    setState(() => _isLoading = true);
    try {
      await _offlineService.disableOfflineMode();
      _showSnackBar('✅ Offline mode disabled!');
      await _loadStatistics();
    } catch (e) {
      _showSnackBar('❌ Error disabling offline mode: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOfflineData() async {
    if (_dataKeyController.text.isEmpty ||
        _dataTypeController.text.isEmpty ||
        _dataContentController.text.isEmpty) {
      _showSnackBar('Please fill all fields', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        'content': _dataContentController.text,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': {
          'source': 'offline_dashboard',
          'version': '1.0',
        },
      };

      final success = await _offlineService.saveOfflineData(
        key: _dataKeyController.text,
        data: data,
        dataType: _dataTypeController.text,
        userId: 'demo_user_001',
      );

      if (success) {
        _showSnackBar('✅ Data saved offline successfully!');
        _dataKeyController.clear();
        _dataTypeController.clear();
        _dataContentController.clear();
        await _loadStatistics();
      } else {
        _showSnackBar('❌ Failed to save data offline', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _manualSync() async {
    if (_offlineService.isOffline) {
      _showSnackBar('Cannot sync while offline', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _offlineService.manualSync();
      _showSnackBar('✅ Manual sync completed!');
      await _loadStatistics();
    } catch (e) {
      _showSnackBar('❌ Sync failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 Mobile & Offline Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Overview
            _buildStatusOverview(),
            const SizedBox(height: 24),
            
            // Offline Mode Controls
            _buildOfflineControls(),
            const SizedBox(height: 24),
            
            // Data Management
            _buildDataManagement(),
            const SizedBox(height: 24),
            
            // Statistics
            _buildStatistics(),
            const SizedBox(height: 24),
            
            // Sync Controls
            _buildSyncControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _offlineService.isOffline ? Icons.cloud_off : Icons.cloud,
                  color: _offlineService.isOffline ? Colors.orange : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Connection Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Mode',
                    _offlineService.isOffline ? 'Offline' : 'Online',
                    _offlineService.isOffline ? Colors.orange : Colors.green,
                    Icons.wifi_off,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Sync Status',
                    _offlineService.isSyncing ? 'Syncing...' : 'Idle',
                    _offlineService.isSyncing ? Colors.blue : Colors.grey,
                    _offlineService.isSyncing ? Icons.sync : Icons.sync_disabled,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_offlineService.lastSyncTime != null)
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Last sync: ${_formatDate(_offlineService.lastSyncTime!)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String label, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Offline Mode Controls',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _enableOfflineMode,
                    icon: const Icon(Icons.cloud_off),
                    label: const Text('Enable Offline Mode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _disableOfflineMode,
                    icon: const Icon(Icons.cloud),
                    label: const Text('Disable Offline Mode'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Offline mode allows you to continue working without internet connection. '
              'Data will be stored locally and synced when connection is restored.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagement() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storage, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Offline Data Management',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _dataKeyController,
              decoration: const InputDecoration(
                labelText: 'Data Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
                hintText: 'e.g., patient_001_notes',
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _dataTypeController,
              decoration: const InputDecoration(
                labelText: 'Data Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
                hintText: 'e.g., patient_notes, appointment, medication',
              ),
            ),
            const SizedBox(height: 8),
            
            TextField(
              controller: _dataContentController,
              decoration: const InputDecoration(
                labelText: 'Data Content',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.content_paste),
                hintText: 'Enter your data content here...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveOfflineData,
                icon: const Icon(Icons.save),
                label: const Text('Save Data Offline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_statistics == null) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Offline Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Entries',
                    '${_statistics!.totalEntries}',
                    Colors.blue,
                    Icons.list,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Size',
                    '${(_statistics!.totalSize / 1024 / 1024).toStringAsFixed(2)} MB',
                    Colors.green,
                    Icons.storage,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending Sync',
                    '${_statistics!.pendingSync}',
                    Colors.orange,
                    Icons.sync,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Last Sync',
                    _statistics!.lastSyncTime != null 
                        ? _formatDate(_statistics!.lastSyncTime!)
                        : 'Never',
                    Colors.purple,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            
            if (_statistics!.dataTypeCounts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Data Type Distribution:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statistics!.dataTypeCounts.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: const TextStyle(fontSize: 12),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncControls() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Sync Controls',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading || _offlineService.isOffline ? null : _manualSync,
                    icon: const Icon(Icons.sync),
                    label: const Text('Manual Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadStatistics,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Stats'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_offlineService.isOffline)
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sync is disabled while offline. Enable online mode to sync data.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
