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
  List<DrugInteraction> _interactions = const [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-Reçete', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _drugAutocomplete()),
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
        Wrap(spacing: 8, runSpacing: 8, children: _items.map((e) => _itemChip(e)).toList()),
        const SizedBox(height: 12),
        if (_interactions.isNotEmpty) _interactionWarnings(),
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

  Widget _drugAutocomplete() {
    return Autocomplete<Drug>(
      optionsBuilder: (t) async {
        final q = t.text.trim();
        if (q.isEmpty) return const Iterable<Drug>.empty();
        final results = await _service.searchDrugsByName(q);
        return results;
      },
      displayStringForOption: (d) => d.name,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        controller.text = _drugController.text;
        return TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: 'İlaç adı')); 
      },
      onSelected: (d) {
        _drugController.text = d.name;
      },
      optionsViewBuilder: (context, onSelected, options) {
        final list = options.toList();
        return Material(
          elevation: 4,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, i) {
              final d = list[i];
              return ListTile(
                title: Text(d.name),
                subtitle: Text('${d.strength} • ${d.form}'),
                onTap: () => onSelected(d),
              );
            },
          ),
        );
      },
    );
  }

  Widget _itemChip(PrescriptionItem e) {
    // Etkileşim şiddesi görseli: major/contra -> kırmızı, moderate -> turuncu, diğer -> varsayılan
    Color? bg;
    // Basit heuristic: isimde "-" geçen iki ilaçta moderate, aynı kod tekrarında contraindicated
    // Gerçek şiddet, checkInteractions sonucu ile ekranda ayrı gösterilebilir.
    bg = Colors.grey[200];
    return Chip(
      label: Text(e.drug.name),
      backgroundColor: bg,
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
    _refreshInteractions();
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

  Future<void> _refreshInteractions() async {
    final res = await _service.checkInteractions(_items);
    if (mounted) setState(() => _interactions = res);
  }

  Widget _interactionWarnings() {
    Color colorFor(String sev) {
      switch (sev) {
        case 'contraindicated':
        case 'major':
          return Colors.red.shade100;
        case 'moderate':
          return Colors.orange.shade100;
        default:
          return Colors.yellow.shade100;
      }
    }
    Color textColorFor(String sev) {
      switch (sev) {
        case 'contraindicated':
        case 'major':
          return Colors.red.shade800;
        case 'moderate':
          return Colors.orange.shade800;
        default:
          return Colors.brown;
      }
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('İlaç Etkileşimleri', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._interactions.map((i) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorFor(i.severity),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: textColorFor(i.severity)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${i.aCode} + ${i.bCode} → ${i.severity.toUpperCase()}${i.note.isNotEmpty ? ' • ' + i.note : ''}',
                        style: TextStyle(color: textColorFor(i.severity)),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}


