import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/role_service.dart';

class SpecialtySelectScreen extends StatelessWidget {
  const SpecialtySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final specialties = const [
      'Psikiyatrist',
      'Psikolog',
      'Hemşire',
      'Sekreter',
      'Hasta',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzmanlık Seçimi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hangi uzmanlıkla devam etmek istersiniz?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: specialties.map((s) {
                    return _SpecialtyChip(label: s, color: colorScheme.primary);
                  }).toList(),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Devam Et'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SpecialtyChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isSelected = context.watch<RoleService>().currentRole == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => context.read<RoleService>().setRole(label),
      selectedColor: color.withOpacity(0.15),
    );
  }
}


