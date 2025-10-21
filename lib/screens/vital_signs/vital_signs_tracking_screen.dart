import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vital_signs_models.dart';
import '../../services/vital_signs_service.dart';
import '../../services/patient_service.dart';

class VitalSignsTrackingScreen extends StatefulWidget {
  const VitalSignsTrackingScreen({super.key});

  @override
  State<VitalSignsTrackingScreen> createState() => _VitalSignsTrackingScreenState();
}

class _VitalSignsTrackingScreenState extends State<VitalSignsTrackingScreen> {
  final VitalSignsService _vitalSignsService = VitalSignsService();
  String? _selectedPatientId;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _vitalSignsService.initialize();
  }

  void _initializeControllers() {
    _controllers['systolicBP'] = TextEditingController();
    _controllers['diastolicBP'] = TextEditingController();
    _controllers['heartRate'] = TextEditingController();
    _controllers['temperature'] = TextEditingController();
    _controllers['respiratoryRate'] = TextEditingController();
    _controllers['oxygenSaturation'] = TextEditingController();
    _controllers['weight'] = TextEditingController();
    _controllers['height'] = TextEditingController();
    _controllers['painLevel'] = TextEditingController();
    _controllers['notes'] = TextEditingController();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Bulgular Takibi'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hasta Seçimi
            Card(
              color: Colors.purple[800],
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
                    const SizedBox(height: 12),
                    Consumer<PatientService>(
                      builder: (context, patientService, child) {
                        return DropdownButtonFormField<String>(
                          value: _selectedPatientId,
                          decoration: InputDecoration(
                            labelText: 'Hasta',
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          dropdownColor: Colors.purple[700],
                          items: patientService.patients.map((patient) {
                            return DropdownMenuItem(
                              value: patient.id,
                              child: Text(
                                patient.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPatientId = value;
                            });
                          },
                        );
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
                        
                        // Nabız ve Ateş
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                'heartRate',
                                'Nabız (bpm)',
                                Icons.favorite,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildInputField(
                                'temperature',
                                'Ateş (°C)',
                                Icons.thermostat,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Solunum ve Oksijen
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                'respiratoryRate',
                                'Solunum (dk)',
                                Icons.air,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildInputField(
                                'oxygenSaturation',
                                'O2 Sat (%)',
                                Icons.bloodtype,
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
                        
                        const SizedBox(height: 16),
                        
                        // Ağrı Seviyesi
                        _buildInputField(
                          'painLevel',
                          'Ağrı Seviyesi (0-10)',
                          Icons.sick,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Notlar
                        TextField(
                          controller: _controllers['notes'],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Notlar',
                            labelStyle: const TextStyle(color: Colors.white70),
                            hintText: 'Ek notlar...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            prefixIcon: const Icon(Icons.note, color: Colors.white70),
                          ),
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Kaydet Butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveVitalSigns,
                            icon: const Icon(Icons.save),
                            label: const Text('Kaydet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple[800],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Son Vital Bulgular
              Card(
                color: Colors.purple[600],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son Vital Bulgular',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLatestVitalSigns(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Aktif Alarmlar
              Card(
                color: Colors.purple[500],
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
                      _buildActiveAlerts(),
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
    return TextField(
      controller: _controllers[key],
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
    );
  }

  Widget _buildLatestVitalSigns() {
    final latestVitalSigns = _vitalSignsService.getLatestVitalSignsForPatient(_selectedPatientId!);
    
    if (latestVitalSigns == null) {
      return const Text(
        'Henüz vital bulgu kaydı yok',
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children: [
        _buildVitalSignItem('Kan Basıncı', '${latestVitalSigns.data.systolicBP}/${latestVitalSigns.data.diastolicBP} mmHg'),
        _buildVitalSignItem('Nabız', '${latestVitalSigns.data.heartRate} bpm'),
        _buildVitalSignItem('Ateş', '${latestVitalSigns.data.temperature}°C'),
        _buildVitalSignItem('Solunum', '${latestVitalSigns.data.respiratoryRate}/dk'),
        _buildVitalSignItem('O2 Sat', '${latestVitalSigns.data.oxygenSaturation}%'),
        _buildVitalSignItem('Ağrı', '${latestVitalSigns.data.painLevel}/10'),
        if (latestVitalSigns.data.bmi != null)
          _buildVitalSignItem('BMI', '${latestVitalSigns.data.bmi!.toStringAsFixed(1)}'),
      ],
    );
  }

  Widget _buildVitalSignItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAlerts() {
    final alerts = _vitalSignsService.getAlertsForPatient(_selectedPatientId!);
    
    if (alerts.isEmpty) {
      return const Text(
        'Aktif alarm yok',
        style: TextStyle(color: Colors.white70),
      );
    }

    return Column(
      children: alerts.map((alert) => Card(
        color: _getAlertColor(alert.severity),
        child: ListTile(
          leading: Icon(
            _getAlertIcon(alert.type),
            color: Colors.white,
          ),
          title: Text(
            alert.message,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${alert.createdAt.day}/${alert.createdAt.month} ${alert.createdAt.hour}:${alert.createdAt.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () => _resolveAlert(alert.id),
          ),
        ),
      )).toList(),
    );
  }

  Color _getAlertColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      case AlertSeverity.critical:
        return Colors.red[900]!;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.bloodPressureHigh:
        return Icons.monitor_heart;
      case AlertType.heartRateAbnormal:
        return Icons.favorite;
      case AlertType.temperatureHigh:
        return Icons.thermostat;
      case AlertType.oxygenSaturationLow:
        return Icons.bloodtype;
      case AlertType.painLevelHigh:
        return Icons.sick;
      default:
        return Icons.warning;
    }
  }

  Future<void> _saveVitalSigns() async {
    try {
      final data = VitalSignsData(
        systolicBP: double.tryParse(_controllers['systolicBP']!.text),
        diastolicBP: double.tryParse(_controllers['diastolicBP']!.text),
        heartRate: int.tryParse(_controllers['heartRate']!.text),
        temperature: double.tryParse(_controllers['temperature']!.text),
        respiratoryRate: int.tryParse(_controllers['respiratoryRate']!.text),
        oxygenSaturation: int.tryParse(_controllers['oxygenSaturation']!.text),
        weight: double.tryParse(_controllers['weight']!.text),
        height: double.tryParse(_controllers['height']!.text),
        painLevel: double.tryParse(_controllers['painLevel']!.text),
      );

      await _vitalSignsService.addVitalSignsRecord(
        patientId: _selectedPatientId!,
        recordedBy: 'current_user', // TODO: Get from auth service
        data: data,
        notes: _controllers['notes']!.text.isNotEmpty ? _controllers['notes']!.text : null,
      );

      // Clear form
      for (final controller in _controllers.values) {
        controller.clear();
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vital bulgular kaydedildi'),
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
}
