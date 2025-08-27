import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/medication_models.dart';
import '../../models/prescription_ai_models.dart';
import '../../services/medication_service.dart';

class InteractionChecker extends StatefulWidget {
  final List<String> medications;
  final Function(List<String>) onInteractionsFound;

  const InteractionChecker({
    super.key,
    required this.medications,
    required this.onInteractionsFound,
  });

  @override
  State<InteractionChecker> createState() => _InteractionCheckerState();
}

class _InteractionCheckerState extends State<InteractionChecker> {
  final TextEditingController _medication1Controller = TextEditingController();
  final TextEditingController _medication2Controller = TextEditingController();
  List<DrugInteraction> _interactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // _checkInteractions(); // This line is removed as per the new_code, as the interaction check is now triggered by a button.
  }

  @override
  void didUpdateWidget(InteractionChecker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medications != widget.medications) {
      // _checkInteractions(); // This line is removed as per the new_code, as the interaction check is now triggered by a button.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'İlaç Etkileşim Kontrolü',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _medication1Controller,
                    decoration: const InputDecoration(
                      labelText: 'İlaç 1',
                      border: OutlineInputBorder(),
                      hintText: 'İlaç adı veya ID girin',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _medication2Controller,
                    decoration: const InputDecoration(
                      labelText: 'İlaç 2',
                      border: OutlineInputBorder(),
                      hintText: 'İlaç adı veya ID girin',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _checkInteractions,
                icon: const Icon(Icons.search),
                label: const Text('Etkileşimleri Kontrol Et'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_interactions.isNotEmpty)
              _buildInteractionsList()
            else if (_medication1Controller.text.isNotEmpty && _medication2Controller.text.isNotEmpty)
              const Card(
                color: Colors.grey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Etkileşim bulunamadı',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bulunan Etkileşimler (${_interactions.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._interactions.map((interaction) => _buildInteractionCard(interaction)),
      ],
    );
  }

  Widget _buildInteractionCard(DrugInteraction interaction) {
    final severityColor = _getSeverityColor(interaction.severity);
    final severityIcon = _getSeverityIcon(interaction.severity);
    final severityText = _getSeverityText(interaction.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: severityColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(severityIcon, color: severityColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    severityText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    interaction.type.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${interaction.medication1Name} + ${interaction.medication2Name}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              interaction.description,
              style: const TextStyle(fontSize: 13),
            ),
            if (interaction.mechanism.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Mekanizma: ${interaction.mechanism}',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
            if (interaction.recommendations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Öneriler:',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              ...interaction.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 12)),
                    Expanded(child: Text(rec, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
            ],
            if (interaction.monitoring.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'İzleme:',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              ...interaction.monitoring.map((mon) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 12)),
                    Expanded(child: Text(mon, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'minor':
        return Colors.blue;
      case 'moderate':
        return Colors.orange;
      case 'major':
        return Colors.red;
      case 'contraindicated':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'minor':
        return Icons.info;
      case 'moderate':
        return Icons.warning;
      case 'major':
        return Icons.error;
      case 'contraindicated':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _getSeverityText(String severity) {
    switch (severity) {
      case 'minor':
        return 'Minör Etkileşim';
      case 'moderate':
        return 'Orta Etkileşim';
      case 'major':
        return 'Majör Etkileşim';
      case 'contraindicated':
        return 'Kontrendike';
      default:
        return 'Bilinmeyen';
    }
  }

  Future<void> _checkInteractions() async {
    if (_medication1Controller.text.isEmpty || _medication2Controller.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: AI interaction checking service
      // Simulated interaction check
      await Future.delayed(const Duration(seconds: 1));
      
      final medicationService = MedicationService();
      await medicationService.initialize();
      
      final interactions = await medicationService.checkDrugInteractions(
        medicationIds: [
          _medication1Controller.text.trim(),
          _medication2Controller.text.trim(),
        ],
      );

      setState(() {
        _interactions = interactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _interactions = [];
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Etkileşim kontrolü sırasında hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _medication1Controller.dispose();
    _medication2Controller.dispose();
    super.dispose();
  }
}
