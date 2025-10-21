import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/region_service.dart';

class RegionSettingsScreen extends StatelessWidget {
  const RegionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<RegionService>();
    final code = svc.currentRegionCode;
    return Scaffold(
      appBar: AppBar(title: const Text('Bölge Ayarları')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kılavuzlar ve ilaç verileri bölgeye göre değişebilir.'),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Bölge', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: code,
                  items: const [
                    DropdownMenuItem(value: 'TR', child: Text('TR - Türkiye')),
                    DropdownMenuItem(value: 'EU', child: Text('EU - Avrupa')),
                    DropdownMenuItem(value: 'US', child: Text('US - Amerika')),
                  ],
                  onChanged: (v) async {
                    if (v != null) {
                      await context.read<RegionService>().setRegion(v);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bölge güncellendi')));
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Aktif Bölge: ${svc.currentRegionCode}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}



