import 'package:flutter/material.dart';
import '../../models/mbc_models.dart';
import '../../services/assessment_service.dart';
import '../../utils/theme.dart';

class GAD7Form extends StatefulWidget {
  final String clientName;
  const GAD7Form({super.key, required this.clientName});

  @override
  State<GAD7Form> createState() => _GAD7FormState();
}

class _GAD7FormState extends State<GAD7Form> {
  final List<String> _questions = const [
    'Sinirlilik, huzursuzluk',
    'Endişeyi kontrol etmede güçlük',
    'Çeşitli şeyler için fazla endişe',
    'Rahatlayamama',
    'Huzursuzluk/yerinde duramama',
    'Kolay kızma/irritabilite',
    'Korku – kötü bir şey olacak gibi'
  ];

  final List<int> _answers = List<int>.filled(7, 0);
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final total = AssessmentScoring.calculateTotal(_answers);
    final severity = AssessmentScoring.gad7Severity(total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GAD-7', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Son iki hafta boyunca, aşağıdaki sorunlar sizi ne kadar sıklıkla rahatsız etti?'),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _questions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildQuestion(context, index),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Chip(label: Text('Toplam: $total')),
            const SizedBox(width: 8),
            Chip(label: Text('Şiddet: $severity')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : () => _save(total),
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save),
            label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildQuestion(BuildContext context, int index) {
    const options = ['Hiç değil (0)', 'Birkaç gün (1)', 'Yarısından çok (2)', 'Hemen her gün (3)'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${index + 1}. ${_questions[index]}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(4, (v) {
              final selected = _answers[index] == v;
              return ChoiceChip(
                label: Text(options[v]),
                selected: selected,
                onSelected: (_) => setState(() => _answers[index] = v),
              );
            }),
          )
        ],
      ),
    );
  }

  Future<void> _save(int total) async {
    setState(() => _saving = true);
    try {
      final items = List<AssessmentItem>.generate(
        _questions.length,
        (i) => AssessmentItem(index: i + 1, question: _questions[i], answer: _answers[i]),
      );
      final result = AssessmentResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AssessmentType.gad7,
        clientName: widget.clientName,
        createdAt: DateTime.now(),
        items: items,
        totalScore: total,
      );
      await AssessmentService().saveResult(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GAD-7 kaydedildi: toplam $total')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}


