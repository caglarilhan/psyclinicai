import 'package:flutter/material.dart';
import '../services/pseudonym_service.dart';
import 'dart:convert';

// Export formatları
enum ExportFormat {
  json,
  csv,
  pdf,
  excel,
}

// Export türleri
enum ExportType {
  clients,
  sessions,
  diagnoses,
  medications,
  notes,
  appointments,
  all,
}

class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  // Export yap
  Future<String> exportData({
    required ExportType type,
    required ExportFormat format,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final data = await _getDataForExport(type, filters);
      final bool adminView = (filters?['admin'] as bool?) ?? false;
      if (!adminView) {
        _maskSensitive(data);
      }
      
      switch (format) {
        case ExportFormat.json:
          return _exportToJson(data);
        case ExportFormat.csv:
          return _exportToCsv(data);
        case ExportFormat.pdf:
          return _exportToPdf(data);
        case ExportFormat.excel:
          return _exportToExcel(data);
      }
    } catch (e) {
      throw Exception('Export hatası: $e');
    }
  }

  void _maskSensitive(Map<String, dynamic> data){
    String maskEmail(String v){
      final parts = v.split('@'); if (parts.length!=2) return v;
      final n = parts[0]; final d = parts[1];
      final m = n.length<=2? n[0] + '*' : n.substring(0,2) + '*' * (n.length-2);
      return m + '@' + d;
    }
    String maskPhone(String v){
      return v.length < 4 ? '***' : v.substring(0, v.length-4).replaceAll(RegExp(r'\d'), '*') + v.substring(v.length-4);
    }
    if (data['clients'] is List){
      for (final c in (data['clients'] as List)){
        if (c['email'] is String) c['email'] = maskEmail(c['email']);
        if (c['phone'] is String) c['phone'] = maskPhone(c['phone']);
      }
    }
  }

  // Export için veri al
  Future<Map<String, dynamic>> _getDataForExport(ExportType type, Map<String, dynamic>? filters) async {
    final data = <String, dynamic>{
      'reportId': DateTime.now().microsecondsSinceEpoch.toString(),
      'exportDate': DateTime.now().toIso8601String(),
      'exportType': type.name,
      'filters': filters ?? {},
      'app': 'PsyClinicAI Web',
      'version': '1.0.0',
    };

    switch (type) {
      case ExportType.clients:
        data['clients'] = _getDemoClients();
        break;
      case ExportType.sessions:
        data['sessions'] = _getDemoSessions();
        break;
      case ExportType.diagnoses:
        data['diagnoses'] = _getDemoDiagnoses();
        break;
      case ExportType.medications:
        data['medications'] = _getDemoMedications();
        break;
      case ExportType.notes:
        data['notes'] = _getDemoNotes();
        break;
      case ExportType.appointments:
        data['appointments'] = _getDemoAppointments();
        break;
      case ExportType.all:
        data['clients'] = _getDemoClients();
        data['sessions'] = _getDemoSessions();
        data['diagnoses'] = _getDemoDiagnoses();
        data['medications'] = _getDemoMedications();
        data['notes'] = _getDemoNotes();
        data['appointments'] = _getDemoAppointments();
        break;
    }

    return data;
  }

  // JSON export
  String _exportToJson(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  // CSV export
  String _exportToCsv(Map<String, dynamic> data) {
    final csv = StringBuffer();
    
    // Header
    csv.writeln('Export Date,${data['exportDate']}');
    csv.writeln('Export Type,${data['exportType']}');
    csv.writeln();

    // Data
    data.forEach((key, value) {
      if (key != 'exportDate' && key != 'exportType' && key != 'filters') {
        if (value is List) {
          csv.writeln('$key');
          if (value.isNotEmpty) {
            // CSV header
            final firstItem = value.first;
            if (firstItem is Map) {
              csv.writeln(firstItem.keys.join(','));
              
              // CSV data
              for (final item in value) {
                csv.writeln(item.values.join(','));
              }
            }
          }
          csv.writeln();
        }
      }
    });

    return csv.toString();
  }

  // PDF export (stub)
  String _exportToPdf(Map<String, dynamic> data) {
    // TODO: PDF generation implementation
    return 'PDF export - ${data['exportType']} - ${data['exportDate']}';
  }

  // Excel export (stub)
  String _exportToExcel(Map<String, dynamic> data) {
    // TODO: Excel generation implementation
    return 'Excel export - ${data['exportType']} - ${data['exportDate']}';
  }

  // Demo veriler
  List<Map<String, dynamic>> _getDemoClients() {
    return [
      {
        'id': '1',
        'firstName': 'Ahmet',
        'lastName': 'Yılmaz',
        'pseudonym': PseudonymService.generate('1'),
        'email': 'ahmet.yilmaz@email.com',
        'phone': '+90 555 123 4567',
        'primaryDiagnosis': 'Depresyon',
        'status': 'Aktif',
        'riskLevel': 'Orta',
        'firstSessionDate': '2024-01-15',
        'totalSessions': 8,
      },
      {
        'id': '2',
        'firstName': 'Ayşe',
        'lastName': 'Demir',
        'pseudonym': PseudonymService.generate('2'),
        'email': 'ayse.demir@email.com',
        'phone': '+90 555 987 6543',
        'primaryDiagnosis': 'Anksiyete Bozukluğu',
        'status': 'Aktif',
        'riskLevel': 'Düşük',
        'firstSessionDate': '2024-01-10',
        'totalSessions': 12,
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoSessions() {
    return [
      {
        'id': '1',
        'clientId': '1',
        'clientName': 'Ahmet Yılmaz',
        'clientPseudonym': PseudonymService.generate('1'),
        'date': '2024-01-15',
        'duration': 60,
        'type': 'Terapi',
        'notes': 'DAP notu eklendi',
        'status': 'Tamamlandı',
      },
      {
        'id': '2',
        'clientId': '2',
        'clientName': 'Ayşe Demir',
        'clientPseudonym': PseudonymService.generate('2'),
        'date': '2024-01-10',
        'duration': 45,
        'type': 'Konsültasyon',
        'notes': 'SOAP notu eklendi',
        'status': 'Tamamlandı',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoDiagnoses() {
    return [
      {
        'id': '1',
        'code': 'F32.1',
        'name': 'Depresyon',
        'description': 'Orta şiddetli depresif bozukluk',
        'category': 'Mood Disorders',
        'severity': 'Orta',
      },
      {
        'id': '2',
        'code': 'F41.1',
        'name': 'Anksiyete Bozukluğu',
        'description': 'Panik bozukluğu',
        'category': 'Anxiety Disorders',
        'severity': 'Hafif',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoMedications() {
    return [
      {
        'id': '1',
        'name': 'Prozac',
        'genericName': 'Fluoxetine',
        'dosage': '20mg',
        'frequency': 'Günde 1 kez',
        'indication': 'Depresyon',
        'sideEffects': 'Bulantı, uykusuzluk',
      },
      {
        'id': '2',
        'name': 'Xanax',
        'genericName': 'Alprazolam',
        'dosage': '0.5mg',
        'frequency': 'Günde 3 kez',
        'indication': 'Anksiyete',
        'sideEffects': 'Uyku hali, bağımlılık',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoNotes() {
    return [
      {
        'id': '1',
        'clientId': '1',
        'clientName': 'Ahmet Yılmaz',
        'clientPseudonym': PseudonymService.generate('1'),
        'type': 'DAP',
        'date': '2024-01-15',
        'content': 'Data: Danışan depresif belirtiler gösteriyor...',
        'therapist': 'Dr. Mehmet Kaya',
      },
      {
        'id': '2',
        'clientId': '2',
        'clientName': 'Ayşe Demir',
        'clientPseudonym': PseudonymService.generate('2'),
        'type': 'SOAP',
        'date': '2024-01-10',
        'content': 'Subjective: Danışan anksiyete belirtileri yaşıyor...',
        'therapist': 'Dr. Fatma Özkan',
      },
    ];
  }

  List<Map<String, dynamic>> _getDemoAppointments() {
    return [
      {
        'id': '1',
        'clientId': '1',
        'clientName': 'Ahmet Yılmaz',
        'clientPseudonym': PseudonymService.generate('1'),
        'date': '2024-01-20',
        'time': '14:00',
        'duration': 60,
        'type': 'Terapi',
        'status': 'Planlandı',
      },
      {
        'id': '2',
        'clientId': '2',
        'clientName': 'Ayşe Demir',
        'clientPseudonym': PseudonymService.generate('2'),
        'date': '2024-01-22',
        'time': '16:00',
        'duration': 45,
        'type': 'Konsültasyon',
        'status': 'Planlandı',
      },
    ];
  }

  // Backup oluştur
  Future<String> createBackup() async {
    try {
      final backupData = {
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'data': await _getDataForExport(ExportType.all, null),
      };

      return _exportToJson(backupData);
    } catch (e) {
      throw Exception('Backup oluşturma hatası: $e');
    }
  }

  // Backup geri yükle
  Future<void> restoreBackup(String backupData) async {
    try {
      final data = json.decode(backupData);
      // TODO: Backup geri yükleme implementasyonu
    } catch (e) {
      throw Exception('Backup geri yükleme hatası: $e');
    }
  }

  // Export istatistikleri
  Map<String, dynamic> getExportStatistics() {
    return {
      'totalExports': 0,
      'lastExportDate': null,
      'mostExportedType': 'clients',
      'exportFormats': ['json', 'csv', 'pdf', 'excel'],
    };
  }
}

// Export widget'ı
class DataExportWidget extends StatefulWidget {
  const DataExportWidget({super.key});

  @override
  State<DataExportWidget> createState() => _DataExportWidgetState();
}

class _DataExportWidgetState extends State<DataExportWidget> {
  final DataExportService _exportService = DataExportService();
  ExportType _selectedType = ExportType.all;
  ExportFormat _selectedFormat = ExportFormat.json;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Export',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Export türü seçimi
            DropdownButtonFormField<ExportType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Export Türü',
                border: OutlineInputBorder(),
              ),
              items: ExportType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getExportTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Export format seçimi
            DropdownButtonFormField<ExportFormat>(
              value: _selectedFormat,
              decoration: const InputDecoration(
                labelText: 'Export Formatı',
                border: OutlineInputBorder(),
              ),
              items: ExportFormat.values.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(_getExportFormatName(format)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Export butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportData,
                icon: _isExporting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isExporting ? 'Export Ediliyor...' : 'Export Et'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Backup butonları
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('Backup Oluştur'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _restoreBackup,
                    icon: const Icon(Icons.restore),
                    label: const Text('Backup Geri Yükle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getExportTypeName(ExportType type) {
    switch (type) {
      case ExportType.clients:
        return 'Danışanlar';
      case ExportType.sessions:
        return 'Seanslar';
      case ExportType.diagnoses:
        return 'Tanılar';
      case ExportType.medications:
        return 'İlaçlar';
      case ExportType.notes:
        return 'Notlar';
      case ExportType.appointments:
        return 'Randevular';
      case ExportType.all:
        return 'Tüm Veriler';
    }
  }

  String _getExportFormatName(ExportFormat format) {
    switch (format) {
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.excel:
        return 'Excel';
    }
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final result = await _exportService.exportData(
        type: _selectedType,
        format: _selectedFormat,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export başarılı: ${_getExportTypeName(_selectedType)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _createBackup() async {
    try {
      final backup = await _exportService.createBackup();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup oluşturuldu'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    // TODO: Backup dosyası seçimi ve geri yükleme
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup geri yükleme özelliği yakında gelecek'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
