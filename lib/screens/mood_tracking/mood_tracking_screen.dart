import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodTrackingScreen extends StatefulWidget {
  const MoodTrackingScreen({super.key});

  @override
  State<MoodTrackingScreen> createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _moodEntries = [
    {
      'id': '1',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'date': DateTime(2024, 2, 15),
      'mood': 3, // 1-5 scale (1=çok kötü, 5=çok iyi)
      'anxiety': 4,
      'energy': 2,
      'sleep': 3,
      'notes': 'Bugün kendimi daha iyi hissediyorum. İlaçlarımı düzenli alıyorum.',
      'tags': ['İlaç', 'Pozitif'],
    },
    {
      'id': '2',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'date': DateTime(2024, 2, 14),
      'mood': 2,
      'anxiety': 5,
      'energy': 1,
      'sleep': 2,
      'notes': 'Çok endişeli ve yorgun hissediyorum. Uyku sorunları devam ediyor.',
      'tags': ['Anksiyete', 'Uyku'],
    },
    {
      'id': '3',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'date': DateTime(2024, 2, 13),
      'mood': 4,
      'anxiety': 2,
      'energy': 4,
      'sleep': 4,
      'notes': 'Harika bir gün! Terapi seansı çok faydalı oldu.',
      'tags': ['Terapi', 'Pozitif'],
    },
    {
      'id': '4',
      'patientId': 'P002',
      'patientName': 'Ayşe Demir',
      'date': DateTime(2024, 2, 15),
      'mood': 4,
      'anxiety': 3,
      'energy': 3,
      'sleep': 3,
      'notes': 'Meditasyon yaptım, kendimi sakin hissediyorum.',
      'tags': ['Meditasyon', 'Sakinlik'],
    },
  ];

  final List<Map<String, dynamic>> _moodGoals = [
    {
      'id': '1',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'goal': 'Günlük mood skorunu 4\'ün üzerinde tutmak',
      'targetValue': 4.0,
      'currentValue': 3.0,
      'startDate': DateTime(2024, 2, 1),
      'endDate': DateTime(2024, 3, 1),
      'status': 'Devam Ediyor',
      'progress': 75.0,
    },
    {
      'id': '2',
      'patientId': 'P001',
      'patientName': 'Ahmet Yılmaz',
      'goal': 'Anksiyete seviyesini 3\'ün altına düşürmek',
      'targetValue': 3.0,
      'currentValue': 3.5,
      'startDate': DateTime(2024, 2, 1),
      'endDate': DateTime(2024, 3, 1),
      'status': 'Devam Ediyor',
      'progress': 60.0,
    },
    {
      'id': '3',
      'patientId': 'P002',
      'patientName': 'Ayşe Demir',
      'goal': 'Günlük enerji seviyesini artırmak',
      'targetValue': 4.0,
      'currentValue': 3.0,
      'startDate': DateTime(2024, 2, 10),
      'endDate': DateTime(2024, 3, 10),
      'status': 'Devam Ediyor',
      'progress': 50.0,
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracking'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMoodEntry,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showAnalytics,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.timeline), text: 'Takip'),
            Tab(icon: Icon(Icons.track_changes), text: 'Hedefler'),
            Tab(icon: Icon(Icons.insights), text: 'Analiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTrackingTab(),
          _buildGoalsTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildTrackingTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moodEntries.length,
      itemBuilder: (context, index) {
        return _buildMoodEntryCard(_moodEntries[index]);
      },
    );
  }

  Widget _buildMoodEntryCard(Map<String, dynamic> entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry['patientName'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd.MM.yyyy').format(entry['date']),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMoodIndicator('Mood', entry['mood'], _getMoodColor(entry['mood'])),
                ),
                Expanded(
                  child: _buildMoodIndicator('Anksiyete', entry['anxiety'], _getAnxietyColor(entry['anxiety'])),
                ),
                Expanded(
                  child: _buildMoodIndicator('Enerji', entry['energy'], _getEnergyColor(entry['energy'])),
                ),
                Expanded(
                  child: _buildMoodIndicator('Uyku', entry['sleep'], _getSleepColor(entry['sleep'])),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              entry['notes'],
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: entry['tags'].map<Widget>((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editMoodEntry(entry),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewMoodDetails(entry),
                    icon: const Icon(Icons.visibility, size: 16),
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

  Widget _buildMoodIndicator(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moodGoals.length,
      itemBuilder: (context, index) {
        return _buildGoalCard(_moodGoals[index]);
      },
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal['patientName'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal['status'],
                    style: const TextStyle(
                      color: Colors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              goal['goal'],
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hedef Değer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        goal['targetValue'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mevcut Değer',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        goal['currentValue'].toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'İlerleme: %${goal['progress'].toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal['progress'] / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                goal['progress'] > 75 ? Colors.green :
                goal['progress'] > 50 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${DateFormat('dd.MM.yyyy').format(goal['startDate'])} - ${DateFormat('dd.MM.yyyy').format(goal['endDate'])}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editGoal(goal),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Düzenle'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateGoalProgress(goal),
                    icon: const Icon(Icons.update, size: 16),
                    label: const Text('Güncelle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet kartları
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Ortalama Mood',
                  '3.2',
                  Icons.sentiment_satisfied,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Ortalama Anksiyete',
                  '3.5',
                  Icons.psychology,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  'Ortalama Enerji',
                  '2.8',
                  Icons.battery_charging_full,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  'Ortalama Uyku',
                  '3.0',
                  Icons.bedtime,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Mood trend grafiği
          Text(
            'Mood Trendi (Son 7 Gün)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Color(0xff68737d),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            );
                            Widget text;
                            switch (value.toInt()) {
                              case 0:
                                text = const Text('13', style: style);
                                break;
                              case 1:
                                text = const Text('14', style: style);
                                break;
                              case 2:
                                text = const Text('15', style: style);
                                break;
                              case 3:
                                text = const Text('16', style: style);
                                break;
                              case 4:
                                text = const Text('17', style: style);
                                break;
                              case 5:
                                text = const Text('18', style: style);
                                break;
                              case 6:
                                text = const Text('19', style: style);
                                break;
                              default:
                                text = const Text('', style: style);
                                break;
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: text,
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Color(0xff68737d),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 4),
                          FlSpot(1, 2),
                          FlSpot(2, 3),
                          FlSpot(3, 4),
                          FlSpot(4, 3),
                          FlSpot(5, 4),
                          FlSpot(6, 5),
                        ],
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Haftalık özet
          Text(
            'Haftalık Özet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildWeeklySummaryItem('En İyi Gün', '19 Şubat (Mood: 5)', Icons.trending_up, Colors.green),
                  const Divider(),
                  _buildWeeklySummaryItem('En Kötü Gün', '14 Şubat (Mood: 2)', Icons.trending_down, Colors.red),
                  const Divider(),
                  _buildWeeklySummaryItem('Ortalama Uyku', '6.5 saat', Icons.bedtime, Colors.purple),
                  const Divider(),
                  _buildWeeklySummaryItem('Aktif Hedefler', '3 hedef', Icons.track_changes, Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getAnxietyColor(int value) {
    switch (value) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getEnergyColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getSleepColor(int value) {
    switch (value) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _addMoodEntry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Mood Girişi'),
        content: const Text('Mood girişi formu burada olacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mood girişi ekleme özelliği yakında eklenecek')),
              );
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detaylı analitik raporu açılıyor...')),
    );
  }

  void _editMoodEntry(Map<String, dynamic> entry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${entry['patientName']} mood girişi düzenleniyor...')),
    );
  }

  void _viewMoodDetails(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${entry['patientName']} - Mood Detayları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tarih: ${DateFormat('dd.MM.yyyy').format(entry['date'])}'),
            Text('Mood: ${entry['mood']}/5'),
            Text('Anksiyete: ${entry['anxiety']}/5'),
            Text('Enerji: ${entry['energy']}/5'),
            Text('Uyku: ${entry['sleep']}/5'),
            const SizedBox(height: 8),
            Text('Notlar: ${entry['notes']}'),
            const SizedBox(height: 8),
            Text('Etiketler: ${entry['tags'].join(', ')}'),
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

  void _editGoal(Map<String, dynamic> goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${goal['patientName']} hedefi düzenleniyor...')),
    );
  }

  void _updateGoalProgress(Map<String, dynamic> goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${goal['patientName']} hedef ilerlemesi güncelleniyor...')),
    );
  }
}
