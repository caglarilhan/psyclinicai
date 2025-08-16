import 'package:flutter/material.dart';
import '../../models/prescription_model.dart';
import '../../utils/theme.dart';

class PrescriptionForm extends StatefulWidget {
  final Function(PrescriptionModel) onPrescriptionCreated;

  const PrescriptionForm({
    super.key,
    required this.onPrescriptionCreated,
  });

  @override
  State<PrescriptionForm> createState() => _PrescriptionFormState();
}

class _PrescriptionFormState extends State<PrescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  List<MedicationModel> _medications = [];
  List<String> _interactions = [];

  @override
  void dispose() {
    _patientNameController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              'Yeni Reçete Oluştur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Hasta bilgileri
            _buildSection(
              'Hasta Bilgileri',
              Icons.person,
              [
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Hasta Adı',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Hasta adı gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosisController,
                  decoration: const InputDecoration(
                    labelText: 'Tanı',
                    prefixIcon: Icon(Icons.medical_services),
                    hintText: 'Örn: Major Depressive Disorder (F32.1)',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tanı gerekli';
                    }
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // İlaç listesi
            _buildSection(
              'İlaçlar',
              Icons.medication,
              [
                if (_medications.isNotEmpty) ...[
                  ..._medications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final medication = entry.value;
                    return _buildMedicationCard(index, medication);
                  }),
                  const SizedBox(height: 16),
                ],
                ElevatedButton.icon(
                  onPressed: _showAddMedicationDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('İlaç Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Etkileşimler
            _buildSection(
              'Etkileşimler',
              Icons.warning,
              [
                if (_interactions.isNotEmpty) ...[
                  ..._interactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final interaction = entry.value;
                    return _buildInteractionCard(index, interaction);
                  }),
                  const SizedBox(height: 16),
                ],
                ElevatedButton.icon(
                  onPressed: _showAddInteractionDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Etkileşim Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notlar
            _buildSection(
              'Notlar',
              Icons.note,
              [
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ek Notlar',
                    hintText: 'Özel talimatlar, yan etkiler, takip planı...',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Kaydet butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _savePrescription,
                icon: const Icon(Icons.save),
                label: const Text('Reçeteyi Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildMedicationCard(int index, MedicationModel medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${medication.name} ${medication.dosage}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => _removeMedication(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'İlaçı Kaldır',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${medication.frequency} - ${medication.duration}'),
            if (medication.instructions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                medication.instructions,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionCard(int index, String interaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppTheme.warningColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(interaction)),
            IconButton(
              onPressed: () => _removeInteraction(index),
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Etkileşimi Kaldır',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final durationController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlaç Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'İlaç Adı',
                  hintText: 'Örn: Escitalopram',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Doz',
                  hintText: 'Örn: 10mg',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: frequencyController,
                decoration: const InputDecoration(
                  labelText: 'Frekans',
                  hintText: 'Örn: 1x daily',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Süre',
                  hintText: 'Örn: 30 days',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Talimatlar',
                  hintText: 'Örn: Sabah yemekle birlikte alın',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  dosageController.text.isNotEmpty) {
                setState(() {
                  _medications.add(MedicationModel(
                    name: nameController.text,
                    dosage: dosageController.text,
                    frequency: frequencyController.text,
                    duration: durationController.text,
                    instructions: instructionsController.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showAddInteractionDialog() {
    final interactionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkileşim Ekle'),
        content: TextField(
          controller: interactionController,
          decoration: const InputDecoration(
            labelText: 'Etkileşim Açıklaması',
            hintText: 'Örn: Alkol ile birlikte kullanmayın',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (interactionController.text.isNotEmpty) {
                setState(() {
                  _interactions.add(interactionController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _removeInteraction(int index) {
    setState(() {
      _interactions.removeAt(index);
    });
  }

  void _savePrescription() {
    if (!_formKey.currentState!.validate()) return;
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('En az bir ilaç eklemelisiniz'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final prescription = PrescriptionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientName: _patientNameController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      medications: _medications,
      interactions: _interactions,
      createdAt: DateTime.now(),
      status: 'Active',
      notes: _notesController.text.trim(),
    );

    widget.onPrescriptionCreated(prescription);

    // Form temizle
    _formKey.currentState!.reset();
    _patientNameController.clear();
    _diagnosisController.clear();
    _notesController.clear();
    setState(() {
      _medications.clear();
      _interactions.clear();
    });
  }
}
