import 'package:flutter/material.dart';
import '../../utils/theme.dart';

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
  List<String> _interactions = [];
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkInteractions();
  }

  @override
  void didUpdateWidget(InteractionChecker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.medications != widget.medications) {
      _checkInteractions();
    }
  }

  Future<void> _checkInteractions() async {
    if (widget.medications.length < 2) {
      setState(() => _interactions = []);
      return;
    }

    setState(() => _isChecking = true);

    try {
      // TODO: AI interaction checking service
      await Future.delayed(const Duration(seconds: 2));

      final interactions = _simulateInteractionCheck(widget.medications);
      setState(() => _interactions = interactions);

      widget.onInteractionsFound(interactions);
    } catch (e) {
      setState(
          () => _interactions = ['Etkileşim kontrolü hatası: ${e.toString()}']);
    } finally {
      setState(() => _isChecking = false);
    }
  }

  List<String> _simulateInteractionCheck(List<String> medications) {
    final interactions = <String>[];
    final lowerMeds = medications.map((m) => m.toLowerCase()).toList();

    // SSRI + MAOI kontrolü
    if (lowerMeds.any((m) =>
            m.contains('ssri') ||
            m.contains('escitalopram') ||
            m.contains('sertraline')) &&
        lowerMeds.any((m) =>
            m.contains('maoi') ||
            m.contains('phenelzine') ||
            m.contains('tranylcypromine'))) {
      interactions
          .add('SSRI + MAOI: Serotonin sendromu riski - birlikte kullanmayın');
    }

    // Benzodiazepin + Alkol kontrolü
    if (lowerMeds.any((m) =>
            m.contains('alprazolam') ||
            m.contains('diazepam') ||
            m.contains('lorazepam')) &&
        lowerMeds.any((m) => m.contains('alkol'))) {
      interactions.add(
          'Benzodiazepin + Alkol: Merkezi sinir sistemi baskılanması riski');
    }

    // Lithium + NSAID kontrolü
    if (lowerMeds.any((m) => m.contains('lithium')) &&
        lowerMeds
            .any((m) => m.contains('ibuprofen') || m.contains('naproxen'))) {
      interactions.add(
          'Lithium + NSAID: Lithium seviyesi artabilir, dikkatli takip gerekli');
    }

    // Antidepresan + St. John\'s Wort kontrolü
    if (lowerMeds.any((m) => m.contains('ssri') || m.contains('snri')) &&
        lowerMeds
            .any((m) => m.contains('st. john') || m.contains('hypericum'))) {
      interactions
          .add('Antidepresan + St. John\'s Wort: Serotonin sendromu riski');
    }

    // Güvenli kombinasyonlar
    if (lowerMeds.any((m) => m.contains('escitalopram')) &&
        lowerMeds.any((m) => m.contains('bupropion'))) {
      interactions.add('✅ Escitalopram + Bupropion: Güvenli kombinasyon');
    }

    if (lowerMeds.any((m) => m.contains('sertraline')) &&
        lowerMeds.any((m) => m.contains('mirtazapine'))) {
      interactions.add('✅ Sertraline + Mirtazapine: Güvenli kombinasyon');
    }

    return interactions;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medications.length < 2) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Etkileşim kontrolü için en az 2 ilaç gerekli',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _interactions.any((i) => i.contains('❌') || i.contains('⚠️'))
              ? AppTheme.warningColor
              : AppTheme.accentColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                _isChecking ? Icons.hourglass_empty : Icons.medication,
                color: _isChecking
                    ? Colors.grey[600]
                    : (_interactions
                            .any((i) => i.contains('❌') || i.contains('⚠️'))
                        ? AppTheme.warningColor
                        : AppTheme.accentColor),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isChecking
                    ? 'Etkileşimler Kontrol Ediliyor...'
                    : 'İlaç Etkileşimleri',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isChecking
                          ? Colors.grey[600]
                          : (_interactions.any(
                                  (i) => i.contains('❌') || i.contains('⚠️'))
                              ? AppTheme.warningColor
                              : AppTheme.accentColor),
                    ),
              ),
              if (_isChecking) ...[
                const Spacer(),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),

          if (!_isChecking && _interactions.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Etkileşim listesi
            ..._interactions.map(
              (interaction) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _getInteractionColor(interaction).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getInteractionColor(interaction)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getInteractionIcon(interaction),
                      color: _getInteractionColor(interaction),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        interaction.replaceAll(RegExp(r'[✅⚠️❌]'), '').trim(),
                        style: TextStyle(
                          color: _getInteractionColor(interaction),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Yeniden kontrol butonu
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _checkInteractions,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeniden Kontrol Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getInteractionColor(String interaction) {
    if (interaction.contains('❌')) return AppTheme.errorColor;
    if (interaction.contains('⚠️')) return AppTheme.warningColor;
    if (interaction.contains('✅')) return AppTheme.accentColor;
    return AppTheme.primaryColor;
  }

  IconData _getInteractionIcon(String interaction) {
    if (interaction.contains('❌')) return Icons.dangerous;
    if (interaction.contains('⚠️')) return Icons.warning;
    if (interaction.contains('✅')) return Icons.check_circle;
    return Icons.info;
  }
}
