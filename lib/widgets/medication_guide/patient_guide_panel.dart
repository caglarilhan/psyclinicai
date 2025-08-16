import 'package:flutter/material.dart';
import '../../models/medication_guide_model.dart';
import '../../utils/theme.dart';

class PatientGuidePanel extends StatefulWidget {
  final MedicationModel? selectedMedication;

  const PatientGuidePanel({
    super.key,
    this.selectedMedication,
  });

  @override
  State<PatientGuidePanel> createState() => _PatientGuidePanelState();
}

class _PatientGuidePanelState extends State<PatientGuidePanel> {
  final List<PatientGuide> _patientGuides = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isAddingGuide = false;

  @override
  void initState() {
    super.initState();
    _loadDemoGuides();
  }

  void _loadDemoGuides() {
    _patientGuides.addAll([
      PatientGuide(
        id: '1',
        medicationId: '1', // Escitalopram
        title: 'Escitalopram (Lexapro) - Danışan Rehberi',
        content: '''
Bu rehber, Escitalopram kullanımı hakkında önemli bilgileri içermektedir. Lütfen dikkatlice okuyun ve sorularınız varsa doktorunuza danışın.

**İlacınızı Nasıl Kullanmalısınız?**

• Her gün aynı saatte alın
• Yemekle birlikte veya yemeksiz alabilirsiniz
• Tabletleri çiğnemeyin, bütün olarak yutun
• Doktorunuzun önerdiği dozu aşmayın

**Ne Zaman Almalısınız?**

• Sabah veya akşam, size uygun olan saati seçin
• Düzenli kullanım önemlidir
• Bir dozu kaçırırsanız, bir sonraki doz zamanında alın
• İki dozu birden almayın

**Yan Etkiler ve Dikkat Edilmesi Gerekenler**

• İlk haftalarda mide bulantısı olabilir
• Uyku düzeniniz değişebilir
• Cinsel istek azalabilir
• Bu yan etkiler genellikle zamanla azalır

**Acil Durumlar**

Aşağıdaki belirtilerden herhangi birini yaşarsanız hemen doktorunuza başvurun:
• Şiddetli baş ağrısı
• Görme bozukluğu
• Nöbet geçirme
• Kalp çarpıntısı
• Aşırı terleme ve titreme

**Önemli Uyarılar**

• Alkol kullanımını sınırlayın
• Araç kullanırken dikkatli olun
• İlacınızı aniden kesmeyin
• Gebelik planınız varsa doktorunuza bildirin
        ''',
        sections: ['Kullanım', 'Yan Etkiler', 'Acil Durumlar', 'Uyarılar'],
        keyPoints: [
          'Her gün aynı saatte alın',
          'Yan etkiler ilk haftalarda normaldir',
          'İlacı aniden kesmeyin',
          'Alkol kullanımını sınırlayın',
          'Düzenli doktor kontrolü yapın'
        ],
        patientWarnings: [
          'Serotonin sendromu belirtilerini izleyin',
          '18 yaş altında intihar düşüncesi artabilir',
          'Gebelik ve emzirme döneminde dikkatli olun',
          'Diğer ilaçlarla etkileşim olabilir'
        ],
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        author: 'Dr. Ahmet Yılmaz',
        version: '1.0',
      ),
      PatientGuide(
        id: '2',
        medicationId: '2', // Alprazolam
        title: 'Alprazolam (Xanax) - Danışan Rehberi',
        content: '''
Bu rehber, Alprazolam kullanımı hakkında önemli bilgileri içermektedir. Bu ilaç sadece doktor reçetesi ile kullanılmalıdır.

**İlacınızı Nasıl Kullanmalısınız?**

• Doktorunuzun önerdiği dozda alın
• Gerektiğinde veya düzenli olarak kullanın
• Tabletleri çiğnemeyin, bütün olarak yutun
• Dozu kendiniz artırmayın

**Ne Zaman Almalısınız?**

• Anksiyete belirtileri başladığında
• Panik atak öncesinde
• Doktorunuzun önerdiği programda
• Gereksiz kullanımdan kaçının

**Yan Etkiler ve Dikkat Edilmesi Gerekenler**

• Uyku hali ve sersemlik
• Hafıza problemleri
• Koordinasyon bozukluğu
• Bağımlılık riski

**Acil Durumlar**

Aşağıdaki belirtilerden herhangi birini yaşarsanız hemen doktorunuza başvurun:
• Aşırı uyku hali
• Solunum güçlüğü
• Bilinç kaybı
• Şiddetli baş dönmesi

**Önemli Uyarılar**

• Bağımlılık riski yüksektir
• İlacı aniden kesmeyin
• Araç kullanmayın
• Alkol ile birlikte almayın
        ''',
        sections: ['Kullanım', 'Yan Etkiler', 'Acil Durumlar', 'Uyarılar'],
        keyPoints: [
          'Sadece gerektiğinde kullanın',
          'Bağımlılık riski vardır',
          'Araç kullanmayın',
          'Alkol ile birlikte almayın',
          'Doktor kontrolünde kullanın'
        ],
        patientWarnings: [
          'Bağımlılık gelişebilir',
          'Uzun süreli kullanımda dikkatli olun',
          'Aniden kesmeyin',
          'Diğer ilaçlarla etkileşim olabilir'
        ],
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        author: 'Dr. Fatma Demir',
        version: '1.0',
      ),
      PatientGuide(
        id: '3',
        medicationId: '3', // Risperidone
        title: 'Risperidone (Risperdal) - Danışan Rehberi',
        content: '''
Bu rehber, Risperidone kullanımı hakkında önemli bilgileri içermektedir. Bu ilaç psikotik bozuklukların tedavisinde kullanılır.

**İlacınızı Nasıl Kullanmalısınız?**

• Her gün aynı saatte alın
• Yemekle birlikte veya yemeksiz alabilirsiniz
• Tabletleri çiğnemeyin, bütün olarak yutun
• Doktorunuzun önerdiği dozu aşmayın

**Ne Zaman Almalısınız?**

• Düzenli olarak her gün
• Doktorunuzun belirlediği programda
• Bir dozu kaçırırsanız, bir sonraki doz zamanında alın
• İki dozu birden almayın

**Yan Etkiler ve Dikkat Edilmesi Gerekenler**

• Prolaktin seviyesi artabilir
• Metabolik değişiklikler olabilir
• Ekstrapiramidal belirtiler
• Kilo artışı
• Sedasyon

**Acil Durumlar**

Aşağıdaki belirtilerden herhangi birini yaşarsanız hemen doktorunuza başvurun:
• Şiddetli baş ağrısı
• Görme bozukluğu
• Nöbet geçirme
• Kalp çarpıntısı

**Önemli Uyarılar**

• Metabolik parametreleri düzenli kontrol edin
• Prolaktin seviyesini izleyin
• Kardiyovasküler risk faktörlerini değerlendirin
• Ekstrapiramidal belirtileri takip edin
        ''',
        sections: ['Kullanım', 'Yan Etkiler', 'Acil Durumlar', 'Uyarılar'],
        keyPoints: [
          'Düzenli kullanım önemli',
          'Metabolik takip gerekli',
          'Prolaktin seviyesi izlenmeli',
          'Kardiyovasküler risk değerlendirilmeli',
          'Ekstrapiramidal belirtiler takip edilmeli'
        ],
        patientWarnings: [
          'Metabolik sendrom riski',
          'Prolaktinoma gelişebilir',
          'Kardiyovasküler risk artabilir',
          'Ekstrapiramidal yan etkiler olabilir'
        ],
        language: 'tr',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        author: 'Dr. Mehmet Kaya',
        version: '1.0',
      ),
    ]);
  }

  void _addNewGuide() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen başlık ve içerik alanlarını doldurun')),
      );
      return;
    }

    final newGuide = PatientGuide(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.selectedMedication?.id ?? '',
      title: _titleController.text,
      content: _contentController.text,
      sections: ['Genel', 'Kullanım', 'Yan Etkiler'],
      keyPoints: [
        'Doktor reçetesi ile kullanın',
        'Düzenli kontrol yapın',
        'Yan etkileri izleyin'
      ],
      patientWarnings: [
        'Doktor kontrolü gerekli',
        'Yan etkileri takip edin',
        'Gebelik planınız varsa bildirin'
      ],
      language: 'tr',
      createdAt: DateTime.now(),
      author: 'Dr. Kullanıcı',
      version: '1.0',
    );

    setState(() {
      _patientGuides.add(newGuide);
      _isAddingGuide = false;
      _titleController.clear();
      _contentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni rehber eklendi')),
    );
  }

  void _deleteGuide(String guideId) {
    setState(() {
      _patientGuides.removeWhere((guide) => guide.id == guideId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rehber silindi')),
    );
  }

  void _exportToPDF(PatientGuide guide) {
    // PDF export functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${guide.title} PDF olarak dışa aktarılıyor...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareGuide(PatientGuide guide) {
    // Share functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${guide.title} paylaşılıyor...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<PatientGuide> _getRelevantGuides() {
    if (widget.selectedMedication == null) {
      return _patientGuides;
    }
    return _patientGuides
        .where((guide) => guide.medicationId == widget.selectedMedication!.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final relevantGuides = _getRelevantGuides();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.book,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danışan Rehberleri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    Text(
                      'İlaç kullanımı hakkında detaylı bilgiler ve öneriler',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (widget.selectedMedication != null)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isAddingGuide = !_isAddingGuide;
                    });
                  },
                  icon: Icon(
                    _isAddingGuide ? Icons.close : Icons.add,
                    color: AppColors.primary,
                  ),
                  tooltip: _isAddingGuide ? 'İptal' : 'Yeni Rehber Ekle',
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add New Guide Form
        if (_isAddingGuide && widget.selectedMedication != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Rehber Ekle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Rehber Başlığı',
                    border: OutlineInputBorder(),
                    hintText: 'Örn: Escitalopram Kullanım Rehberi',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Rehber İçeriği',
                    border: OutlineInputBorder(),
                    hintText: 'Rehber içeriğini buraya yazın...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAddingGuide = false;
                          _titleController.clear();
                          _contentController.clear();
                        });
                      },
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addNewGuide,
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Guides List
        if (relevantGuides.isNotEmpty) ...[
          Text(
            'Mevcut Rehberler (${relevantGuides.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...relevantGuides.map((guide) => _buildGuideCard(guide)),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz rehber bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk rehberi eklemek için yukarıdaki butona tıklayın',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGuideCard(PatientGuide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            guide.author,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Oluşturulma: ${guide.createdAt.day}/${guide.createdAt.month}/${guide.createdAt.year}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        // Edit functionality would be implemented here
                        break;
                      case 'delete':
                        _deleteGuide(guide.id);
                        break;
                      case 'export':
                        _exportToPDF(guide);
                        break;
                      case 'share':
                        _shareGuide(guide);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Düzenle'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.download, size: 20),
                          SizedBox(width: 8),
                          Text('PDF İndir'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 20),
                          SizedBox(width: 8),
                          Text('Paylaş'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          Text('Sil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Key Points
                if (guide.keyPoints.isNotEmpty) ...[
                  Text(
                    'Ana Noktalar:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...guide.keyPoints.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Warnings
                if (guide.patientWarnings.isNotEmpty) ...[
                  Text(
                    'Önemli Uyarılar:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...guide.patientWarnings.map((warning) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              warning,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.warning,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Content Preview
                Text(
                  'İçerik Önizlemesi:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    guide.content.length > 200
                        ? '${guide.content.substring(0, 200)}...'
                        : guide.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                const SizedBox(height: 16),

                // Footer
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        guide.language.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'v${guide.version}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${guide.sections.length} bölüm',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
