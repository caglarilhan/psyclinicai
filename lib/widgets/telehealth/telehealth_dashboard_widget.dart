import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/telehealth_service.dart';
import '../../models/telehealth_models.dart';

class TelehealthDashboardWidget extends StatefulWidget {
  const TelehealthDashboardWidget({super.key});

  @override
  State<TelehealthDashboardWidget> createState() => _TelehealthDashboardWidgetState();
}

class _TelehealthDashboardWidgetState extends State<TelehealthDashboardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _metricController;
  String _selectedView = 'overview';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _metricController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _metricController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TelehealthService>(
      builder: (context, telehealthService, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🩺 Telehealth Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    _buildViewSelector(),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Genel Bakış'),
                    Tab(text: 'Video Seanslar'),
                    Tab(text: 'Uzaktan İzleme'),
                    Tab(text: 'Dijital Tedaviler'),
                  ],
                ),
                const SizedBox(height: 16),

                // Tab Content
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(telehealthService),
                      _buildVideoSessionsTab(telehealthService),
                      _buildRemoteMonitoringTab(telehealthService),
                      _buildDigitalTherapeuticsTab(telehealthService),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewSelector() {
    return DropdownButton<String>(
      value: _selectedView,
      items: const [
        DropdownMenuItem(value: 'overview', child: Text('Genel Bakış')),
        DropdownMenuItem(value: 'detailed', child: Text('Detaylı')),
        DropdownMenuItem(value: 'analytics', child: Text('Analitik')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedView = value!;
        });
      },
    );
  }

  Widget _buildOverviewTab(TelehealthService telehealthService) {
    final sessions = telehealthService.sessions;
    final devices = telehealthService.devices;
    final therapeutics = telehealthService.therapeutics;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(child: _buildMetricCard('Toplam Seans', sessions.length.toString(), Icons.video_call)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Aktif Cihazlar', devices.length.toString(), Icons.devices)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Dijital Tedaviler', therapeutics.length.toString(), Icons.healing)),
            ],
          ),
          const SizedBox(height: 24),

          // Session Status Chart
          _buildSessionStatusChart(sessions),
          const SizedBox(height: 24),

          // Compliance Status
          _buildComplianceStatus(sessions),
        ],
      ),
    );
  }

  Widget _buildVideoSessionsTab(TelehealthService telehealthService) {
    final sessions = telehealthService.sessions;

    return Column(
      children: [
        // Session Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _createNewSession(context),
              icon: const Icon(Icons.add),
              label: const Text('Yeni Seans'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _scheduleSession(context),
              icon: const Icon(Icons.schedule),
              label: const Text('Seans Planla'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Sessions List
        Expanded(
          child: ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(session);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRemoteMonitoringTab(TelehealthService telehealthService) {
    final devices = telehealthService.devices;

    return Column(
      children: [
        // Device Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _registerNewDevice(context),
              icon: const Icon(Icons.add),
              label: const Text('Cihaz Ekle'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _viewDeviceAlerts(context),
              icon: const Icon(Icons.warning),
              label: const Text('Uyarıları Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Devices Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _buildDeviceCard(device);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalTherapeuticsTab(TelehealthService telehealthService) {
    final therapeutics = telehealthService.therapeutics;

    return Column(
      children: [
        // Therapeutic Controls
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _createNewTherapeutic(context),
              icon: const Icon(Icons.add),
              label: const Text('Tedavi Ekle'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => _viewTherapeuticOutcomes(context),
              icon: const Icon(Icons.analytics),
              label: const Text('Sonuçları Gör'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Therapeutics List
        Expanded(
          child: ListView.builder(
            itemCount: therapeutics.length,
            itemBuilder: (context, index) {
              final therapeutic = therapeutics[index];
              return _buildTherapeuticCard(therapeutic);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionStatusChart(List<TelehealthSession> sessions) {
    final statusCounts = <TelehealthSessionStatus, int>{};
    for (final status in TelehealthSessionStatus.values) {
      statusCounts[status] = 0;
    }
    
    for (final session in sessions) {
      statusCounts[session.status] = (statusCounts[session.status] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seans Durumu Dağılımı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: statusCounts.entries.map((entry) {
                    final color = _getStatusColor(entry.key);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: color,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TelehealthSessionStatus status) {
    switch (status) {
      case TelehealthSessionStatus.scheduled:
        return Colors.blue;
      case TelehealthSessionStatus.inProgress:
        return Colors.green;
      case TelehealthSessionStatus.completed:
        return Colors.grey;
      case TelehealthSessionStatus.cancelled:
        return Colors.red;
      case TelehealthSessionStatus.noShow:
        return Colors.orange;
      case TelehealthSessionStatus.rescheduled:
        return Colors.purple;
    }
  }

  Widget _buildComplianceStatus(List<TelehealthSession> sessions) {
    int compliantSessions = 0;
    int totalSessions = sessions.length;

    for (final session in sessions) {
      if (session.compliance.hipaaCompliant && 
          session.compliance.gdprCompliant && 
          session.compliance.kvkkCompliant) {
        compliantSessions++;
      }
    }

    final complianceRate = totalSessions > 0 ? (compliantSessions / totalSessions) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uyumluluk Durumu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Uyumlu Seanslar: $compliantSessions'),
                      Text('Toplam Seans: $totalSessions'),
                      Text('Uyumluluk Oranı: ${(complianceRate * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: complianceRate,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    complianceRate > 0.8 ? Colors.green : 
                    complianceRate > 0.6 ? Colors.orange : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(TelehealthSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(session.status),
          child: Icon(
            _getSessionTypeIcon(session.type),
            color: Colors.white,
          ),
        ),
        title: Text('Seans ${session.id.substring(0, 8)}'),
        subtitle: Text(
          '${session.type.name} - ${session.status.name}\n'
          '${session.scheduledAt.toString().substring(0, 16)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleSessionAction(value, session),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'start', child: Text('Başlat')),
            const PopupMenuItem(value: 'end', child: Text('Bitir')),
            const PopupMenuItem(value: 'notes', child: Text('Notlar')),
            const PopupMenuItem(value: 'compliance', child: Text('Uyumluluk')),
          ],
        ),
      ),
    );
  }

  IconData _getSessionTypeIcon(TelehealthSessionType type) {
    switch (type) {
      case TelehealthSessionType.initialConsultation:
        return Icons.first_page;
      case TelehealthSessionType.followUp:
        return Icons.refresh;
      case TelehealthSessionType.crisisIntervention:
        return Icons.emergency;
      case TelehealthSessionType.groupTherapy:
        return Icons.group;
      case TelehealthSessionType.familyTherapy:
        return Icons.family_restroom;
      case TelehealthSessionType.medicationManagement:
        return Icons.medication;
    }
  }

  Widget _buildDeviceCard(RemoteMonitoringDevice device) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceTypeIcon(device.deviceType),
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    device.deviceType,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusIndicator(device.status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Son Senkronizasyon: ${_formatDateTime(device.lastSync)}'),
            Text('Okuma Sayısı: ${device.readings.length}'),
            Text('Uyarı Sayısı: ${device.alerts.length}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewDeviceDetails(device),
                    child: const Text('Detaylar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewDeviceReadings(device),
                    child: const Text('Okumalar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceTypeIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'heart_rate':
        return Icons.favorite;
      case 'blood_pressure':
        return Icons.favorite_border;
      case 'temperature':
        return Icons.thermostat;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.devices;
    }
  }

  Widget _buildStatusIndicator(DeviceStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case DeviceStatus.active:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case DeviceStatus.inactive:
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      case DeviceStatus.maintenance:
        color = Colors.orange;
        icon = Icons.build;
        break;
      case DeviceStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
    }

    return Icon(icon, color: color, size: 16);
  }

  Widget _buildTherapeuticCard(DigitalTherapeutic therapeutic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text(therapeutic.name),
        subtitle: Text(therapeutic.description),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            _getTherapeuticTypeIcon(therapeutic.type),
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tip: ${therapeutic.type.name}'),
                Text('Üretici: ${therapeutic.manufacturer}'),
                Text('Süre: ${therapeutic.protocol.durationWeeks} hafta'),
                Text('Seans: ${therapeutic.protocol.sessionsPerWeek}/hafta'),
                if (therapeutic.fdaApprovalNumber != null)
                  Text('FDA Onay: ${therapeutic.fdaApprovalNumber}'),
                if (therapeutic.ceMarkNumber != null)
                  Text('CE Mark: ${therapeutic.ceMarkNumber}'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewTherapeuticProtocol(therapeutic),
                        child: const Text('Protokol'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _viewTherapeuticOutcomes(context),
                        child: const Text('Sonuçlar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTherapeuticTypeIcon(TherapeuticType type) {
    switch (type) {
      case TherapeuticType.cognitiveBehavioral:
        return Icons.psychology;
      case TherapeuticType.mindfulness:
        return Icons.self_improvement;
      case TherapeuticType.biofeedback:
        return Icons.monitor_heart;
      case TherapeuticType.exposureTherapy:
        return Icons.exposure;
      case TherapeuticType.relaxation:
        return Icons.spa;
      case TherapeuticType.cognitiveTraining:
        return Icons.school;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  // Action Handlers
  void _createNewSession(BuildContext context) {
    // TODO: Implement new session creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni seans oluşturma özelliği yakında eklenecek')),
    );
  }

  void _scheduleSession(BuildContext context) {
    // TODO: Implement session scheduling
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Seans planlama özelliği yakında eklenecek')),
    );
  }

  void _handleSessionAction(String action, TelehealthSession session) {
    // TODO: Implement session actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seans işlemi: $action - yakında eklenecek')),
    );
  }

  void _registerNewDevice(BuildContext context) {
    // TODO: Implement device registration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cihaz kayıt özelliği yakında eklenecek')),
    );
  }

  void _viewDeviceAlerts(BuildContext context) {
    // TODO: Implement device alerts view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cihaz uyarıları yakında eklenecek')),
    );
  }

  void _viewDeviceDetails(RemoteMonitoringDevice device) {
    // TODO: Implement device details view
  }

  void _viewDeviceReadings(RemoteMonitoringDevice device) {
    // TODO: Implement device readings view
  }

  void _createNewTherapeutic(BuildContext context) {
    // TODO: Implement therapeutic creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tedavi oluşturma özelliği yakında eklenecek')),
    );
  }

  void _viewTherapeuticOutcomes(BuildContext context) {
    // TODO: Implement therapeutic outcomes view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tedavi sonuçları yakında eklenecek')),
    );
  }

  void _viewTherapeuticProtocol(DigitalTherapeutic therapeutic) {
    // TODO: Implement protocol view
  }


}
