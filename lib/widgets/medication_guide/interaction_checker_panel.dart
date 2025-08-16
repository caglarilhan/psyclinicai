import 'package:flutter/material.dart';
import '../../models/medication_guide_model.dart';
import '../../utils/theme.dart';

class InteractionCheckerPanel extends StatefulWidget {
  final List<MedicationModel> allMedications;

  const InteractionCheckerPanel({
    super.key,
    required this.allMedications,
  });

  @override
  State<InteractionCheckerPanel> createState() =>
      _InteractionCheckerPanelState();
}

class _InteractionCheckerPanelState extends State<InteractionCheckerPanel> {
  final List<MedicationModel> _selectedMedications = [];
  final List<DrugInteraction> _detectedInteractions = [];
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadDemoInteractions();
  }

  void _loadDemoInteractions() {
    // Demo etkileşim verileri
    _detectedInteractions.addAll([
      DrugInteraction(
        id: '1',
        medication1Id: '1', // Escitalopram
        medication2Id: '2', // Alprazolam
        severity: 'Moderate',
        description: 'Serotonin sendromu riski ve sedasyon artışı',
        mechanism:
            'Her iki ilaç da serotonin seviyesini artırır ve sedatif etki gösterir',
        recommendations: [
          'Dozları dikkatli ayarlayın',
          'Serotonin sendromu belirtilerini izleyin',
          'Hasta eğitimi yapın',
          'Düzenli takip planlayın'
        ],
        evidenceLevel: 'B',
        source: 'Drugs.com Interaction Checker',
      ),
      DrugInteraction(
        id: '2',
        medication1Id: '1', // Escitalopram
        medication2Id: '3', // Risperidone
        severity: 'Major',
        description: 'QT uzaması ve kardiyak aritmi riski',
        mechanism: 'Her iki ilaç da QT aralığını uzatabilir',
        recommendations: [
          'ECG ile QT aralığını izleyin',
          'Kardiyak risk faktörlerini değerlendirin',
          'Alternatif ilaç düşünün',
          'Hasta eğitimi yapın'
        ],
        evidenceLevel: 'A',
        source: 'FDA Drug Safety Communication',
      ),
      DrugInteraction(
        id: '3',
        medication1Id: '2', // Alprazolam
        medication2Id: '4', // Lithium
        severity: 'Minor',
        description: 'Hafif sedasyon artışı',
        mechanism: 'Alprazolam sedatif etkisi lithium ile artabilir',
        recommendations: [
          'Dozları dikkatli ayarlayın',
          'Sedasyon belirtilerini izleyin',
          'Araç kullanımında dikkatli olun'
        ],
        evidenceLevel: 'C',
        source: 'Micromedex Drug Interactions',
      ),
    ]);
  }

  void _addMedication(MedicationModel medication) {
    if (!_selectedMedications.contains(medication)) {
      setState(() {
        _selectedMedications.add(medication);
      });
      _checkInteractions();
    }
  }

  void _removeMedication(MedicationModel medication) {
    setState(() {
      _selectedMedications.remove(medication);
    });
    _checkInteractions();
  }

  void _checkInteractions() {
    setState(() {
      _isChecking = true;
    });

    // Simüle edilmiş etkileşim kontrolü
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isChecking = false;
      });
    });
  }

  void _clearAll() {
    setState(() {
      _selectedMedications.clear();
      _detectedInteractions.clear();
    });
  }

  List<DrugInteraction> _getRelevantInteractions() {
    if (_selectedMedications.length < 2) return [];

    final medicationIds = _selectedMedications.map((m) => m.id).toSet();

    return _detectedInteractions.where((interaction) {
      return medicationIds.contains(interaction.medication1Id) &&
          medicationIds.contains(interaction.medication2Id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final relevantInteractions = _getRelevantInteractions();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve açıklama
          Text(
            'İlaç Etkileşim Kontrolü',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Birden fazla ilaç seçerek potansiyel etkileşimleri kontrol edin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Seçilen ilaçlar
          Text(
            'Seçilen İlaçlar (${_selectedMedications.length})',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          if (_selectedMedications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ilaç seçilmedi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aşağıdaki listeden ilaç seçin veya arama yapın',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  ..._selectedMedications.map((medication) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: medication.categoryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: medication.categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medication.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  medication.categoryName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeMedication(medication),
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _clearAll,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Tümünü Temizle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _checkInteractions,
                          icon: _isChecking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.search),
                          label: Text(_isChecking
                              ? 'Kontrol Ediliyor...'
                              : 'Etkileşimleri Kontrol Et'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // İlaç seçim listesi
          Text(
            'İlaç Seçimi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.allMedications.length,
              itemBuilder: (context, index) {
                final medication = widget.allMedications[index];
                final isSelected = _selectedMedications.contains(medication);

                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: medication.categoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      medication.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      medication.categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        if (isSelected) {
                          _removeMedication(medication);
                        } else {
                          _addMedication(medication);
                        }
                      },
                      icon: Icon(
                        isSelected ? Icons.remove_circle : Icons.add_circle,
                        color: isSelected ? Colors.red : Colors.green,
                      ),
                    ),
                    onTap: () {
                      if (isSelected) {
                        _removeMedication(medication);
                      } else {
                        _addMedication(medication);
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Etkileşim sonuçları
          if (relevantInteractions.isNotEmpty) ...[
            Text(
              'Tespit Edilen Etkileşimler (${relevantInteractions.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 12),
            ...relevantInteractions.map((interaction) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: interaction.severityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: interaction.severityColor,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık ve şiddet
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: interaction.severityColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            interaction.severity.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: interaction.evidenceColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: interaction.evidenceColor,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Kanıt: ${interaction.evidenceLevel}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: interaction.evidenceColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Açıklama
                    Text(
                      interaction.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Mekanizma
                    Text(
                      'Mekanizma: ${interaction.mechanism}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Öneriler
                    Text(
                      'Öneriler:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...interaction.recommendations.map((recommendation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 12),

                    // Kaynak
                    Text(
                      'Kaynak: ${interaction.source}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ] else if (_selectedMedications.length >= 2) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Etkileşim Tespit Edilmedi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seçilen ilaçlar arasında bilinen bir etkileşim bulunmamaktadır',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
