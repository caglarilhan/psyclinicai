import 'package:flutter/material.dart';
import '../../models/medication_guide_model.dart';
import '../../utils/theme.dart';

class TreatmentProtocolPanel extends StatefulWidget {
  final MedicationModel? selectedMedication;

  const TreatmentProtocolPanel({
    super.key,
    this.selectedMedication,
  });

  @override
  State<TreatmentProtocolPanel> createState() => _TreatmentProtocolPanelState();
}

class _TreatmentProtocolPanelState extends State<TreatmentProtocolPanel> {
  final List<TreatmentProtocol> _treatmentProtocols = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isAddingProtocol = false;

  @override
  void initState() {
    super.initState();
    _loadDemoProtocols();
  }

  void _loadDemoProtocols() {
    _treatmentProtocols.addAll([
      TreatmentProtocol(
        id: '1',
        medicationId: '1', // Escitalopram
        title: 'Major Depressive Disorder - First Line Treatment',
        name: 'Major Depressive Disorder - First Line Treatment',
        diagnosis: 'Major Depressive Disorder (F32.1)',
        category: 'First Line',
        description:
            'Evidence-based first-line treatment protocol for moderate to severe major depressive disorder using SSRIs and psychotherapy.',
        protocolIndications: [
          'Major Depressive Disorder (F32.1)',
          'Moderate to severe depression',
          'First episode or recurrent depression',
        ],
        protocolContraindications: [
          'MAOI use within 14 days',
          'Known hypersensitivity to SSRIs',
          'Severe hepatic impairment',
        ],
        dosageInstructions: [
          'Start with 10mg daily',
          'Increase to 20mg if needed',
          'Take in the morning',
        ],
        monitoringParameters: [
          'PHQ-9 scores every 2-4 weeks',
          'Side effect monitoring',
          'Suicidal ideation assessment',
        ],
        adverseEffects: [
          'Nausea and vomiting',
          'Sexual dysfunction',
          'Insomnia or somnolence',
        ],
        protocolDrugInteractions: [
          'MAOIs (contraindicated)',
          'NSAIDs (increased bleeding risk)',
          'Warfarin (monitor INR)',
        ],
        specialPopulations: [
          'Elderly: Start with lower dose',
          'Pregnancy: Category C',
          'Lactation: Use with caution',
        ],
        protocolReferences: [
          'APA Practice Guidelines for MDD (2020)',
          'NICE Guidelines for Depression (2018)',
          'CANMAT Guidelines (2016)',
        ],
        protocolMedications: [
          'Escitalopram 10-20mg daily',
          'Sertraline 50-200mg daily',
          'Fluoxetine 20-60mg daily',
        ],
        nonPharmacological: [
          'Cognitive Behavioral Therapy (CBT)',
          'Interpersonal Therapy (IPT)',
          'Mindfulness-Based Cognitive Therapy (MBCT)',
        ],
        duration: '6-12 months minimum',
        frequency: 'Daily medication, weekly therapy sessions',
        monitoring: [
          'PHQ-9 scores every 2-4 weeks',
          'Side effect monitoring',
          'Suicidal ideation assessment',
        ],
        source: 'American Psychiatric Association (APA) Guidelines',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        author: 'Dr. John Smith',
        evidenceLevel: 'A',
      ),
      TreatmentProtocol(
        id: '2',
        medicationId: '2', // Alprazolam
        title: 'Generalized Anxiety Disorder - Comprehensive Protocol',
        name: 'Generalized Anxiety Disorder - Comprehensive Protocol',
        diagnosis: 'Generalized Anxiety Disorder (F41.1)',
        category: 'Comprehensive',
        description:
            'Multi-modal treatment approach combining pharmacotherapy with evidence-based psychotherapy for GAD.',
        protocolIndications: [
          'Generalized Anxiety Disorder (F41.1)',
          'Persistent anxiety symptoms',
          'Functional impairment due to anxiety',
        ],
        protocolContraindications: [
          'Uncontrolled narrow-angle glaucoma',
          'Severe renal impairment',
          'Pregnancy (third trimester)',
        ],
        dosageInstructions: [
          'Start with 0.25mg three times daily',
          'Increase gradually as needed',
          'Maximum 10mg daily',
        ],
        monitoringParameters: [
          'GAD-7 scores monthly',
          'Anxiety symptom tracking',
          'Sleep quality assessment',
        ],
        adverseEffects: [
          'Sedation and drowsiness',
          'Memory impairment',
          'Dependency risk',
        ],
        protocolDrugInteractions: [
          'Alcohol (increased sedation)',
          'Opioids (respiratory depression)',
          'Antidepressants (increased effects)',
        ],
        specialPopulations: [
          'Elderly: Reduced dose',
          'Pregnancy: Category D',
          'Lactation: Avoid',
        ],
        protocolReferences: [
          'WFSBP Guidelines for Anxiety Disorders (2018)',
          'BAP Guidelines for Anxiety (2014)',
          'CINP Guidelines (2017)',
        ],
        protocolMedications: [
          'Alprazolam 0.25-1mg three times daily',
          'Escitalopram 10-20mg daily',
          'Venlafaxine 75-225mg daily',
        ],
        nonPharmacological: [
          'Cognitive Behavioral Therapy (CBT)',
          'Acceptance and Commitment Therapy (ACT)',
          'Progressive muscle relaxation',
        ],
        duration: '12-18 months',
        frequency: 'Daily medication, bi-weekly therapy',
        monitoring: [
          'GAD-7 scores monthly',
          'Anxiety symptom tracking',
          'Sleep quality assessment',
        ],
        source: 'World Federation of Societies of Biological Psychiatry',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        author: 'Dr. Sarah Johnson',
        evidenceLevel: 'A',
      ),
    ]);
  }

  void _addNewProtocol() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen başlık ve açıklama alanlarını doldurun')),
      );
      return;
    }

    final newProtocol = TreatmentProtocol(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.selectedMedication?.id ?? '',
      title: _titleController.text,
      name: _titleController.text,
      diagnosis: 'Custom Protocol',
      category: 'Custom',
      description: _descriptionController.text,
      protocolIndications: ['Custom indication'],
      protocolContraindications: ['None specified'],
      dosageInstructions: ['Follow doctor instructions'],
      monitoringParameters: ['Regular monitoring'],
      adverseEffects: ['Monitor for side effects'],
      protocolDrugInteractions: ['Check for interactions'],
      specialPopulations: ['Use with caution'],
      protocolReferences: ['Custom protocol'],
      protocolMedications: [widget.selectedMedication?.name ?? 'Unknown'],
      nonPharmacological: ['Consult healthcare provider'],
      duration: 'As prescribed',
      frequency: 'As prescribed',
      monitoring: ['Regular follow-up'],
      source: 'Custom Protocol',
      createdAt: DateTime.now(),
      author: 'Dr. User',
      evidenceLevel: 'C',
    );

    setState(() {
      _treatmentProtocols.add(newProtocol);
      _isAddingProtocol = false;
      _titleController.clear();
      _descriptionController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni protokol eklendi')),
    );
  }

  void _deleteProtocol(String protocolId) {
    setState(() {
      _treatmentProtocols.removeWhere((protocol) => protocol.id == protocolId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Protokol silindi')),
    );
  }

  void _exportToPDF(TreatmentProtocol protocol) {
    // PDF export functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${protocol.name} PDF olarak dışa aktarılıyor...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareProtocol(TreatmentProtocol protocol) {
    // Share functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${protocol.name} paylaşılıyor...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<TreatmentProtocol> _getRelevantProtocols() {
    if (widget.selectedMedication == null) {
      return _treatmentProtocols;
    }
    return _treatmentProtocols
        .where((protocol) =>
            protocol.medicationId == widget.selectedMedication!.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final relevantProtocols = _getRelevantProtocols();

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
                Icons.medical_services,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tedavi Protokolleri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                    Text(
                      'Kanıta dayalı tedavi protokolleri ve klinik rehberler',
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
                      _isAddingProtocol = !_isAddingProtocol;
                    });
                  },
                  icon: Icon(
                    _isAddingProtocol ? Icons.close : Icons.add,
                    color: AppColors.primary,
                  ),
                  tooltip: _isAddingProtocol ? 'İptal' : 'Yeni Protokol Ekle',
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add New Protocol Form
        if (_isAddingProtocol && widget.selectedMedication != null) ...[
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
                  'Yeni Protokol Ekle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Protokol Başlığı',
                    border: OutlineInputBorder(),
                    hintText: 'Örn: Major Depressive Disorder Protocol',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Protokol Açıklaması',
                    border: OutlineInputBorder(),
                    hintText: 'Protokol açıklamasını buraya yazın...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isAddingProtocol = false;
                          _titleController.clear();
                          _descriptionController.clear();
                        });
                      },
                      child: const Text('İptal'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addNewProtocol,
                      child: const Text('Ekle'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Protocols List
        if (relevantProtocols.isNotEmpty) ...[
          Text(
            'Mevcut Protokoller (${relevantProtocols.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...relevantProtocols.map((protocol) => _buildProtocolCard(protocol)),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz protokol bulunmuyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk protokolü eklemek için yukarıdaki butona tıklayın',
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

  Widget _buildProtocolCard(TreatmentProtocol protocol) {
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
                        protocol.name,
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
                            protocol.author,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.category,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            protocol.category,
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
                        _deleteProtocol(protocol.id);
                        break;
                      case 'export':
                        _exportToPDF(protocol);
                        break;
                      case 'share':
                        _shareProtocol(protocol);
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
                // Diagnosis and Category
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          protocol.diagnosis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        protocol.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  'Açıklama:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  protocol.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                // Key Information
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Süre:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(protocol.duration),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sıklık:',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(protocol.frequency),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Evidence Level and Source
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Kanıt Seviyesi: ${protocol.evidenceLevel}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Kaynak: ${protocol.source}',
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
    _descriptionController.dispose();
    super.dispose();
  }
}
