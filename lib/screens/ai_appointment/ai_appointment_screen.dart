import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/ai_appointment_models.dart';
import '../../services/ai_appointment_service.dart';
import '../../widgets/ai_appointment/ai_appointment_dashboard_widget.dart';
import '../../utils/theme.dart';

class AIAppointmentScreen extends StatefulWidget {
  const AIAppointmentScreen({super.key});

  @override
  State<AIAppointmentScreen> createState() => _AIAppointmentScreenState();
}

class _AIAppointmentScreenState extends State<AIAppointmentScreen>
    with TickerProviderStateMixin {
  final AIAppointmentService _aiService = AIAppointmentService();
  late TabController _tabController;
  late AnimationController _predictionAnimationController;
  
  // No-show tahmini için state
  double _noShowPredictionAccuracy = 0.0;
  List<NoShowPrediction> _noShowPredictions = [];
  bool _isPredictionActive = false;
  
  // Randevu optimizasyonu
  List<AppointmentOptimization> _optimizations = [];
  bool _isAutoOptimizing = false;
  
  // Danışan tercih analizi
  List<ClientPreference> _clientPreferences = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _predictionAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _initializePredictions();
    _loadOptimizations();
    _loadClientPreferences();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _predictionAnimationController.dispose();
    super.dispose();
  }

  void _initializePredictions() {
    _startNoShowPrediction();
  }

  void _startNoShowPrediction() {
    setState(() {
      _isPredictionActive = true;
    });
    
    // Her 2 dakikada bir no-show tahmini güncelle
    Future.delayed(const Duration(minutes: 2), () {
      if (_isPredictionActive) {
        _updateNoShowPredictions();
        _startNoShowPrediction(); // Recursive call for continuous monitoring
      }
    });
  }

  void _updateNoShowPredictions() {
    _aiService.getNoShowPredictions().then((predictions) {
      setState(() {
        _noShowPredictions = predictions;
        _noShowPredictionAccuracy = _calculatePredictionAccuracy(predictions);
      });
      
      // Tahmin animasyonunu başlat
      _predictionAnimationController.forward().then((_) {
        _predictionAnimationController.reset();
      });
    });
  }

  double _calculatePredictionAccuracy(List<NoShowPrediction> predictions) {
    if (predictions.isEmpty) return 0.0;
    
    int correctPredictions = 0;
    for (var prediction in predictions) {
      if (prediction.predictedNoShow == prediction.actualNoShow) {
        correctPredictions++;
      }
    }
    
    return correctPredictions / predictions.length;
  }

  void _loadOptimizations() {
    _aiService.getAppointmentOptimizations().then((optimizations) {
      setState(() {
        _optimizations = optimizations;
      });
    });
  }

  void _loadClientPreferences() {
    _aiService.getClientPreferences().then((preferences) {
      setState(() {
        _clientPreferences = preferences;
      });
    });
  }

  void _toggleAutoOptimization() {
    setState(() {
      _isAutoOptimizing = !_isAutoOptimizing;
    });
    
    if (_isAutoOptimizing) {
      _startAutoOptimization();
    }
  }

  void _startAutoOptimization() {
    if (_isAutoOptimizing) {
      _aiService.autoOptimizeAppointments().then((optimizations) {
        setState(() {
          _optimizations = optimizations;
        });
        
        // Her 10 dakikada bir otomatik optimizasyon
        Future.delayed(const Duration(minutes: 10), () {
          if (_isAutoOptimizing) {
            _startAutoOptimization();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Randevu Sistemi'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              _updateNoShowPredictions();
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
            Tab(text: 'No-Show Tahmini', icon: Icon(Icons.prediction)),
            Tab(text: 'Randevu Optimizasyonu', icon: Icon(Icons.optimize)),
            Tab(text: 'Danışan Tercihleri', icon: Icon(Icons.people)),
            Tab(text: 'AI Analizi', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNoShowPredictionTab(),
          _buildOptimizationTab(),
          _buildClientPreferencesTab(),
          _buildAIAnalysisTab(),
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

  Widget _buildNoShowPredictionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tahmin Doğruluğu Kartı
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No-Show Tahmin Doğruluğu',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Switch(
                        value: _isPredictionActive,
                        onChanged: (value) {
                          setState(() {
                            _isPredictionActive = value;
                          });
                          if (value) {
                            _startNoShowPrediction();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Doğruluk Görselleştirmesi
                  AnimatedBuilder(
                    animation: _predictionAnimationController,
                    builder: (context, child) {
                      return Container(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _noShowPredictionAccuracy,
                              strokeWidth: 20,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getAccuracyColor(_noShowPredictionAccuracy),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(_noShowPredictionAccuracy * 100).toInt()}%',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: _getAccuracyColor(_noShowPredictionAccuracy),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Doğruluk',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _getAccuracyColor(_noShowPredictionAccuracy),
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
                  
                  // Tahmin İstatistikleri
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPredictionStat('Toplam Tahmin', '${_noShowPredictions.length}'),
                      _buildPredictionStat('Doğru Tahmin', '${_noShowPredictions.where((p) => p.predictedNoShow == p.actualNoShow).length}'),
                      _buildPredictionStat('Yanlış Tahmin', '${_noShowPredictions.where((p) => p.predictedNoShow != p.actualNoShow).length}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // No-Show Tahminleri Listesi
          Text(
            'Güncel No-Show Tahminleri',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          ..._noShowPredictions.take(5).map((prediction) => _buildPredictionCard(prediction)),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 0.8) return Colors.green;
    if (accuracy >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPredictionStat(String label, String value) {
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

  Widget _buildPredictionCard(NoShowPrediction prediction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: prediction.predictedNoShow ? Colors.red : Colors.green,
          child: Icon(
            prediction.predictedNoShow ? Icons.cancel : Icons.check,
            color: Colors.white,
          ),
        ),
        title: Text('${prediction.clientName} - ${prediction.appointmentTime.toString().substring(0, 16)}'),
        subtitle: Text(
          'Tahmin: ${prediction.predictedNoShow ? "No-Show" : "Katılım"} | '
          'Gerçek: ${prediction.actualNoShow ? "No-Show" : "Katılım"} | '
          'Güven: ${(prediction.confidence * 100).toInt()}%'
        ),
        trailing: Chip(
          label: Text(prediction.predictedNoShow == prediction.actualNoShow ? '✓' : '✗'),
          backgroundColor: prediction.predictedNoShow == prediction.actualNoShow 
              ? Colors.green.withOpacity(0.2) 
              : Colors.red.withOpacity(0.2),
          labelStyle: TextStyle(
            color: prediction.predictedNoShow == prediction.actualNoShow ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Otomatik Optimizasyon Kontrolü
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
                        'Otomatik Randevu Optimizasyonu',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'AI destekli otomatik randevu düzenleme',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Switch(
                    value: _isAutoOptimizing,
                    onChanged: (value) => _toggleAutoOptimization(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Optimizasyon Önerileri
          Text(
            'Optimizasyon Önerileri (${_optimizations.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          ..._optimizations.map((optimization) => _buildOptimizationCard(optimization)),
        ],
      ),
    );
  }

  Widget _buildOptimizationCard(AppointmentOptimization optimization) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getOptimizationColor(optimization.type),
          child: Icon(
            _getOptimizationIcon(optimization.type),
            color: Colors.white,
          ),
        ),
        title: Text(optimization.title),
        subtitle: Text(
          'Tip: ${optimization.type.name} | '
          'Tahmini Fayda: ${(optimization.estimatedBenefit * 100).toInt()}% | '
          'Uygulama Kolaylığı: ${optimization.implementationDifficulty.name}'
        ),
        trailing: Chip(
          label: Text('${(optimization.aiConfidence * 100).toInt()}%'),
          backgroundColor: _getOptimizationColor(optimization.type).withOpacity(0.2),
          labelStyle: TextStyle(color: _getOptimizationColor(optimization.type)),
        ),
        onTap: () {
          _showOptimizationDetailsDialog(context, optimization);
        },
      ),
    );
  }

  Color _getOptimizationColor(OptimizationType type) {
    switch (type) {
      case OptimizationType.timeSlot:
        return Colors.blue;
      case OptimizationType.duration:
        return Colors.green;
      case OptimizationType.therapist:
        return Colors.orange;
      case OptimizationType.location:
        return Colors.purple;
    }
  }

  IconData _getOptimizationIcon(OptimizationType type) {
    switch (type) {
      case OptimizationType.timeSlot:
        return Icons.schedule;
      case OptimizationType.duration:
        return Icons.timer;
      case OptimizationType.therapist:
        return Icons.person;
      case OptimizationType.location:
        return Icons.location_on;
    }
  }

  Widget _buildClientPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danışan Tercih Analizi',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          ..._clientPreferences.map((preference) => _buildPreferenceCard(preference)),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(ClientPreference preference) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            preference.clientName[0],
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(preference.clientName),
        subtitle: Text(
          'Tercih Edilen Zaman: ${preference.preferredTime} | '
          'Tercih Edilen Terapist: ${preference.preferredTherapist} | '
          'Tercih Gücü: ${(preference.preferenceStrength * 100).toInt()}%'
        ),
        trailing: Icon(
          Icons.trending_up,
          color: preference.preferenceStrength > 0.7 ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Widget _buildAIAnalysisTab() {
    return const Center(
      child: Text('AI Analizi burada gösterilecek'),
    );
  }

  void _showOptimizationDetailsDialog(BuildContext context, AppointmentOptimization optimization) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(optimization.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tip: ${optimization.type.name}'),
            Text('Tahmini Fayda: ${(optimization.estimatedBenefit * 100).toInt()}%'),
            Text('Uygulama Kolaylığı: ${optimization.implementationDifficulty.name}'),
            Text('AI Güven: ${(optimization.aiConfidence * 100).toInt()}%'),
            Text('Açıklama: ${optimization.description}'),
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
        title: const Text('AI Randevu Ayarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Tahmin Hassasiyeti'),
            Slider(
              value: 0.8,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: '80%',
              onChanged: null,
            ),
            SizedBox(height: 16),
            Text('Otomatik Hatırlatıcılar'),
            SwitchListTile(
              title: Text('SMS Hatırlatıcıları'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('E-posta Hatırlatıcıları'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Push Bildirimleri'),
              value: false,
              onChanged: null,
            ),
            SizedBox(height: 16),
            Text('AI Öğrenme'),
            SwitchListTile(
              title: Text('Otomatik Model Güncelleme'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('Kullanıcı Davranış Analizi'),
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
              title: const Text('No-Show Raporu Oluştur'),
              onTap: () {
                Navigator.of(context).pop();
                _generateNoShowReport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.optimize),
              title: const Text('Randevuları Optimize Et'),
              onTap: () {
                Navigator.of(context).pop();
                _optimizeAppointments();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Hatırlatıcı Ayarları'),
              onTap: () {
                Navigator.of(context).pop();
                _showReminderSettings(context);
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

  void _generateNoShowReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No-Show raporu oluşturuluyor...')),
    );
  }

  void _optimizeAppointments() {
    setState(() {
      _isAutoOptimizing = true;
    });
    _startAutoOptimization();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Randevular optimize ediliyor...')),
    );
  }

  void _showReminderSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatıcı Ayarları'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('E-posta hatırlatıcıları'),
              value: true,
              onChanged: null,
            ),
            SwitchListTile(
              title: Text('SMS hatırlatıcıları'),
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
