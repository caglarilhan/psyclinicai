import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ai_case_management_models.dart';
import '../../services/ai_case_management_service.dart';
import '../../widgets/ai_case_management/ai_case_management_dashboard_widget.dart';
import '../../utils/theme.dart';

class AICaseManagementScreen extends StatefulWidget {
  const AICaseManagementScreen({super.key});

  @override
  State<AICaseManagementScreen> createState() => _AICaseManagementScreenState();
}

class _AICaseManagementScreenState extends State<AICaseManagementScreen>
    with TickerProviderStateMixin {
  final AICaseManagementService _aiService = AICaseManagementService();
  late TabController _tabController;
  late AnimationController _riskAnimationController;
  
  // Risk skorlaması için state
  double _currentRiskScore = 0.0;
  String _riskLevel = 'Düşük';
  Color _riskColor = Colors.green;
  bool _isRiskMonitoring = false;
  
  // Vaka önceliklendirme
  List<CasePriority> _casePriorities = [];
  bool _isAutoPrioritizing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _riskAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _initializeRiskMonitoring();
    _loadCasePriorities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _riskAnimationController.dispose();
    super.dispose();
  }

  void _initializeRiskMonitoring() {
    // Gerçek zamanlı risk izleme başlat
    _startRiskMonitoring();
  }

  void _startRiskMonitoring() {
    setState(() {
      _isRiskMonitoring = true;
    });
    
    // Her 30 saniyede bir risk skorunu güncelle
    Future.delayed(const Duration(seconds: 30), () {
      if (_isRiskMonitoring) {
        _updateRiskScore();
        _startRiskMonitoring(); // Recursive call for continuous monitoring
      }
    });
  }

  void _updateRiskScore() {
    // AI servisinden risk skorunu al
    _aiService.getRealTimeRiskScore().then((score) {
      setState(() {
        _currentRiskScore = score;
        _updateRiskLevel();
      });
      
      // Risk animasyonunu başlat
      _riskAnimationController.forward().then((_) {
        _riskAnimationController.reset();
      });
    });
  }

  void _updateRiskLevel() {
    if (_currentRiskScore < 0.3) {
      _riskLevel = 'Düşük';
      _riskColor = Colors.green;
    } else if (_currentRiskScore < 0.7) {
      _riskLevel = 'Orta';
      _riskColor = Colors.orange;
    } else {
      _riskLevel = 'Yüksek';
      _riskColor = Colors.red;
    }
  }

  void _loadCasePriorities() {
    _aiService.getCasePriorities().then((priorities) {
      setState(() {
        _casePriorities = priorities;
      });
    });
  }

  void _toggleAutoPrioritizing() {
    setState(() {
      _isAutoPrioritizing = !_isAutoPrioritizing;
    });
    
    if (_isAutoPrioritizing) {
      _startAutoPrioritizing();
    }
  }

  void _startAutoPrioritizing() {
    if (_isAutoPrioritizing) {
      _aiService.autoPrioritizeCases().then((priorities) {
        setState(() {
          _casePriorities = priorities;
        });
        
        // Her 5 dakikada bir otomatik önceliklendirme
        Future.delayed(const Duration(minutes: 5), () {
          if (_isAutoPrioritizing) {
            _startAutoPrioritizing();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Vaka Yöneticisi'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _updateRiskScore();
            },
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context);
            },
            tooltip: 'Ayarlar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Risk Analizi', icon: Icon(Icons.warning)),
            Tab(text: 'Vaka Öncelikleri', icon: Icon(Icons.priority_high)),
            Tab(text: 'AI Önerileri', icon: Icon(Icons.psychology)),
            Tab(text: 'Ayarlar', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRiskAnalysisTab(),
          _buildCasePrioritiesTab(),
          _buildAIRecommendationsTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActionsDialog(context);
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Hızlı İşlemler'),
      ),
    );
  }

  Widget _buildRiskAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk Skoru Kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gerçek Zamanlı Risk Skoru',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Switch(
                        value: _isRiskMonitoring,
                        onChanged: (value) {
                          setState(() {
                            _isRiskMonitoring = value;
                          });
                          if (value) {
                            _startRiskMonitoring();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Risk Skoru Görselleştirmesi
                  AnimatedBuilder(
                    animation: _riskAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _currentRiskScore,
                              strokeWidth: 20,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(_currentRiskScore * 100).toInt()}%',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: _riskColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _riskLevel,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _riskColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Risk Detayları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildRiskDetail('Toplam Vaka', '${_casePriorities.length}'),
                      _buildRiskDetail('Yüksek Risk', '${_casePriorities.where((c) => c.riskLevel == RiskLevel.high).length}'),
                      _buildRiskDetail('Orta Risk', '${_casePriorities.where((c) => c.riskLevel == RiskLevel.medium).length}'),
                      _buildRiskDetail('Düşük Risk', '${_casePriorities.where((c) => c.riskLevel == RiskLevel.low).length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Risk Trend Grafiği
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Risk Trend Analizi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  
                  // Basit trend grafiği (gerçek uygulamada Chart.js veya Flutter Charts kullanılabilir)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Risk trend grafiği burada gösterilecek\n(Chart.js entegrasyonu gerekli)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCasePrioritiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Otomatik Önceliklendirme Kontrolü
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Otomatik Önceliklendirme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'AI destekli otomatik vaka önceliklendirme',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAutoPrioritizing,
                    onChanged: (value) => _toggleAutoPrioritizing(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Vaka Öncelikleri Listesi
          Text(
            'Vaka Öncelikleri (${_casePriorities.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          ..._casePriorities.map((priority) => _buildCasePriorityCard(priority)),
        ],
      ),
    );
  }

  Widget _buildCasePriorityCard(CasePriority priority) {
    Color priorityColor;
    IconData priorityIcon;
    
    switch (priority.priority) {
      case Priority.high:
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case Priority.medium:
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      case Priority.low:
        priorityColor = Colors.green;
        priorityIcon = Icons.keyboard_arrow_down;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: priorityColor,
          child: Icon(priorityIcon, color: Colors.white),
        ),
        title: Text(priority.caseTitle),
        subtitle: Text('Risk: ${priority.riskLevel.name} | Öncelik: ${priority.priority.name}'),
        trailing: Chip(
          label: Text('${(priority.aiConfidence * 100).toInt()}%'),
          backgroundColor: priorityColor.withOpacity(0.2),
          labelStyle: TextStyle(color: priorityColor),
        ),
        onTap: () {
          _showCaseDetailsDialog(context, priority);
        },
      ),
    );
  }

  Widget _buildAIRecommendationsTab() {
    return const Center(
      child: Text('AI Önerileri burada gösterilecek'),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text('Ayarlar burada gösterilecek'),
    );
  }

  void _showCaseDetailsDialog(BuildContext context, CasePriority priority) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(priority.caseTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Seviyesi: ${priority.riskLevel.name}'),
            Text('Öncelik: ${priority.priority.name}'),
            Text('AI Güven: ${(priority.aiConfidence * 100).toInt()}%'),
            Text('Son Güncelleme: ${priority.lastUpdated.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Vaka Yönetimi Ayarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Analiz Hassasiyeti'),
            Slider(
              value: 0.85,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '85%',
              onChanged: null,
            ),
            SizedBox(height: 16),
            Text('Otomatik Risk Değerlendirmesi'),
            SwitchListTile(
              title: Text('Gerçek zamanlı izleme'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Otomatik uyarılar'),
              value: true,
              onChanged: null,
            ),
            SizedBox(height: 16),
            Text('Güvenlik'),
            SwitchListTile(
              title: Text('AES-256 şifreleme'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Audit log sistemi'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Biyometrik kimlik doğrulama'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showQuickActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hızlı İşlemler'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Risk Raporu Oluştur'),
              onTap: () {
                Navigator.of(context).pop();
                _generateRiskReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Öncelikleri Yeniden Hesapla'),
              onTap: () {
                Navigator.of(context).pop();
                _recalculatePriorities();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Uyarı Ayarları'),
              onTap: () {
                Navigator.of(context).pop();
                _showAlertSettings(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _generateRiskReport() {
    // Risk raporu oluştur
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Risk raporu oluşturuluyor...')),
    );
  }

  void _recalculatePriorities() {
    // Öncelikleri yeniden hesapla
    setState(() {
      _isAutoPrioritizing = true;
    });
    _startAutoPrioritizing();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Öncelikler yeniden hesaplanıyor...')),
    );
  }

  void _showAlertSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uyarı Ayarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('E-posta uyarıları'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('SMS uyarıları'),
              value: false,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Push bildirimleri'),
              value: true,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
