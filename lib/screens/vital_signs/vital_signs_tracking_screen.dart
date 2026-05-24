import 'package:flutter/material.dart';
import 'package:psyclinicai/services/vital_signs_service.dart';

class VitalSignsTrackingScreen extends StatefulWidget {
  const VitalSignsTrackingScreen({super.key});

  @override
  State<VitalSignsTrackingScreen> createState() => _VitalSignsTrackingScreenState();
}

class _VitalSignsTrackingScreenState extends State<VitalSignsTrackingScreen> {
  final VitalSignsService _vitalSignsService = VitalSignsService();
  String? _selectedPatientId;
  Map<String, TextEditingController> _controllers = {};
  List<Map<String, dynamic>> _vitalSignsHistory = [];
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadData();
  }

  void _initializeControllers() {
    _controllers = {
      'systolicBP': TextEditingController(),
      'diastolicBP': TextEditingController(),
      'heartRate': TextEditingController(),
      'temperature': TextEditingController(),
      'respiratoryRate': TextEditingController(),
      'oxygenSaturation': TextEditingController(),
      'weight': TextEditingController(),
      'height': TextEditingController(),
    };
  }

  Future<void> _loadData() async {
    await _vitalSignsService.initialize();
    setState(() {
      _vitalSignsHistory = _vitalSignsService.getVitalSignsHistory(_selectedPatientId ?? '')
          .map((vital) => vital.toJson())
          .toList();
      _alerts = _vitalSignsService.getActiveAlerts(_selectedPatientId ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Bulgular Takibi'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hasta Seçimi
            Card(
              color: Colors.purple[700],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasta Seçimi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedPatientId,
                      decoration: InputDecoration(
                        labelText: 'Hasta Seçin',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                      ),
                      dropdownColor: Colors.purple[600],
                      style: const TextStyle(color: Colors.white),
                      items: [
                        const DropdownMenuItem(
                          value: 'patient1',
                          child: Text('Ahmet Yılmaz'),
                        ),
                        const DropdownMenuItem(
                          value: 'patient2',
                          child: Text('Ayşe Demir'),
                        ),
                        const DropdownMenuItem(
                          value: 'patient3',
                          child: Text('Mehmet Kaya'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPatientId = value;
                        });
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Vital Bulgular Formu
            if (_selectedPatientId != null) ...[
              Card(
                color: Colors.purple[700],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vital Bulgular',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Kan Basıncı
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'systolicBP',
                              'Sistolik (mmHg)',
                              Icons.monitor_heart,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInputField(
                              'diastolicBP',
                              'Diyastolik (mmHg)',
                              Icons.monitor_heart,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Kalp Atım Hızı ve Vücut Sıcaklığı
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'heartRate',
                              'Kalp Atım Hızı (bpm)',
                              Icons.favorite,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInputField(
                              'temperature',
                              'Vücut Sıcaklığı (°C)',
                              Icons.thermostat,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Solunum Hızı ve Oksijen Saturasyonu
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'respiratoryRate',
                              'Solunum Hızı (dakika)',
                              Icons.air,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInputField(
                              'oxygenSaturation',
                              'Oksijen Saturasyonu (%)',
                              Icons.air,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Kilo ve Boy
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              'weight',
                              'Kilo (kg)',
                              Icons.monitor_weight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInputField(
                              'height',
                              'Boy (cm)',
                              Icons.height,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Kaydet Butonu
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveVitalSigns,
                          icon: const Icon(Icons.save),
                          label: const Text('Vital Bulguları Kaydet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Aktif Alarmlar
              if (_alerts.isNotEmpty) ...[
                Card(
                  color: Colors.red[700],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aktif Alarmlar',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._alerts.map((alert) => ListTile(
                          leading: const Icon(Icons.warning, color: Colors.white),
                          title: Text(
                            alert['message'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            alert['timestamp'] ?? '',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _resolveAlert(alert['id'] ?? ''),
                            child: const Text('Çöz'),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Vital Bulgular Geçmişi
              Card(
                color: Colors.purple[700],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vital Bulgular Geçmişi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_vitalSignsHistory.isEmpty)
                        const Text(
                          'Henüz vital bulgu kaydı yok',
                          style: TextStyle(color: Colors.white70),
                        )
                      else
                        ..._vitalSignsHistory.map((record) => Card(
                          color: Colors.white.withOpacity(0.1),
                          child: ListTile(
                            leading: const Icon(Icons.medical_services, color: Colors.white),
                            title: Text(
                              '${record['systolicBP']}/${record['diastolicBP']} mmHg',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Kalp: ${record['heartRate']} bpm, Sıcaklık: ${record['temperature']}°C',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              record['timestamp'] ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String key, String label, IconData icon) {
    return TextFormField(
      controller: _controllers[key],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Future<void> _saveVitalSigns() async {
    try {
      final vitalSigns = {
        'patientId': _selectedPatientId,
        'systolicBP': double.tryParse(_controllers['systolicBP']!.text) ?? 0,
        'diastolicBP': double.tryParse(_controllers['diastolicBP']!.text) ?? 0,
        'heartRate': double.tryParse(_controllers['heartRate']!.text) ?? 0,
        'temperature': double.tryParse(_controllers['temperature']!.text) ?? 0,
        'respiratoryRate': double.tryParse(_controllers['respiratoryRate']!.text) ?? 0,
        'oxygenSaturation': double.tryParse(_controllers['oxygenSaturation']!.text) ?? 0,
        'weight': double.tryParse(_controllers['weight']!.text) ?? 0,
        'height': double.tryParse(_controllers['height']!.text) ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _vitalSignsService.recordVitalSigns(vitalSigns);
      
      // Formu temizle
      for (var controller in _controllers.values) {
        controller.clear();
      }
      
      // Verileri yenile
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vital bulgular başarıyla kaydedildi'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resolveAlert(String alertId) async {
    final success = await _vitalSignsService.resolveAlert(alertId, 'current_user');
    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alarm çözüldü'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}