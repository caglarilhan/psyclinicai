import 'package:flutter/material.dart';
import '../../models/erx_models.dart';
import '../../services/erx_service.dart';
import '../../utils/theme.dart';

class ERxForm extends StatefulWidget {
  final String clientName;
  final String therapistName;
  const ERxForm({super.key, required this.clientName, required this.therapistName});

  @override
  State<ERxForm> createState() => _ERxFormState();
}

class _ERxFormState extends State<ERxForm> {
  final _service = ERxService();
  final _drugController = TextEditingController();
  final _dosageController = TextEditingController(text: '1x1');
  final _routeController = TextEditingController(text: 'PO');
  final _freqController = TextEditingController(text: 'daily');
  final _durationController = TextEditingController(text: '7');
  final _notesController = TextEditingController();
  final List<PrescriptionItem> _items = [];
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-Reçete', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _drugController, decoration: const InputDecoration(labelText: 'İlaç adı'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _dosageController, decoration: const InputDecoration(labelText: 'Doz (1x1)'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: TextField(controller: _routeController, decoration: const InputDecoration(labelText: 'Yol (PO/IM)'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _freqController, decoration: const InputDecoration(labelText: 'Sıklık (daily/bid)'))),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _durationController, decoration: const InputDecoration(labelText: 'Gün (7)'))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text('Ekle'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
          ),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _items.map((e) => Chip(label: Text(e.drug.name))).toList()),
        const SizedBox(height: 12),
        TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(labelText: 'Notlar')),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _items.isEmpty || _saving ? null : _save,
            icon: _saving ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.medication),
            label: Text(_saving ? 'Kaydediliyor...' : 'Reçete Oluştur'),
          ),
        )
      ],
    );
  }

  void _addItem() {
    final name = _drugController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 7;
    if (name.isEmpty) return;
    final drug = Drug(code: name.toLowerCase().replaceAll(' ', '_'), name: name, strength: '', form: 'tablet');
    setState(() {
      _items.add(PrescriptionItem(drug: drug, dosage: _dosageController.text.trim(), route: _routeController.text.trim(), frequency: _freqController.text.trim(), durationDays: duration));
    });
    _drugController.clear();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final interactions = await _service.checkInteractions(_items);
      final severe = interactions.where((i) => i.severity == 'major' || i.severity == 'contraindicated').toList();
      if (severe.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uyarı: ciddi etkileşim bulundu')));
      }
      final p = Prescription(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientName: widget.clientName,
        therapistName: widget.therapistName,
        createdAt: DateTime.now(),
        items: _items,
        notes: _notesController.text.trim(),
      );
      await _service.savePrescription(p);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reçete kaydedildi')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}


