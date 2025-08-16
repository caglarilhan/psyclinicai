import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/education_model.dart';
import '../../widgets/education/education_catalog.dart';
import '../../widgets/education/ai_recommendation_panel.dart';
import '../../widgets/education/learning_progress_panel.dart';
import '../../widgets/education/certificate_panel.dart';
import '../../widgets/education/badge_panel.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<EducationModel> _allContent = [];
  List<EducationModel> _recommendedContent = [];
  List<EducationModel> _userProgress = [];
  bool _isGeneratingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDemoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoData() {
    // Demo eğitim içerikleri
    setState(() {
      _allContent = [
        EducationModel(
          id: '1',
          title: 'Depresyon Hakkında Temel Bilgiler',
          description:
              'Depresyonun nedenleri, belirtileri ve tedavi yöntemleri hakkında kapsamlı rehber',
          category: 'Depresyon',
          type: EducationType.video,
          duration: 15,
          difficulty: EducationDifficulty.beginner,
          tags: ['depresyon', 'mood', 'tedavi', 'psikoloji'],
          thumbnail: 'assets/images/depression_thumb.jpg',
          contentUrl: 'https://example.com/depression_video.mp4',
          author: 'Dr. Ayşe Yılmaz',
          rating: 4.8,
          viewCount: 1250,
          isPremium: false,
        ),
        EducationModel(
          id: '2',
          title: 'Anksiyete ile Başa Çıkma Teknikleri',
          description:
              'Günlük hayatta anksiyete ile başa çıkmak için pratik teknikler ve egzersizler',
          category: 'Anksiyete',
          type: EducationType.interactive,
          duration: 25,
          difficulty: EducationDifficulty.intermediate,
          tags: ['anksiyete', 'stres', 'relaksasyon', 'nefes'],
          thumbnail: 'assets/images/anxiety_thumb.jpg',
          contentUrl: 'https://example.com/anxiety_interactive.html',
          author: 'Dr. Mehmet Demir',
          rating: 4.9,
          viewCount: 2100,
          isPremium: true,
        ),
        EducationModel(
          id: '3',
          title: 'Mindfulness ve Meditasyon Rehberi',
          description:
              'Mindfulness pratikleri ve meditasyon teknikleri ile iç huzuru bulma',
          category: 'Mindfulness',
          type: EducationType.pdf,
          duration: 45,
          difficulty: EducationDifficulty.beginner,
          tags: ['mindfulness', 'meditasyon', 'huzur', 'farkındalık'],
          thumbnail: 'assets/images/mindfulness_thumb.jpg',
          contentUrl: 'https://example.com/mindfulness_guide.pdf',
          author: 'Dr. Fatma Kaya',
          rating: 4.7,
          viewCount: 890,
          isPremium: false,
        ),
        EducationModel(
          id: '4',
          title: 'Bipolar Bozukluk: Tanı ve Tedavi',
          description:
              'Bipolar bozukluğun klinik özellikleri ve modern tedavi yaklaşımları',
          category: 'Bipolar',
          type: EducationType.video,
          duration: 30,
          difficulty: EducationDifficulty.advanced,
          tags: ['bipolar', 'mood disorder', 'tedavi', 'psikiyatri'],
          thumbnail: 'assets/images/bipolar_thumb.jpg',
          contentUrl: 'https://example.com/bipolar_video.mp4',
          author: 'Prof. Dr. Ali Özkan',
          rating: 4.6,
          viewCount: 650,
          isPremium: true,
        ),
        EducationModel(
          id: '5',
          title: 'İlişki Problemleri ve Çözüm Yolları',
          description: 'Sağlıklı ilişkiler kurma ve problem çözme becerileri',
          category: 'İlişkiler',
          type: EducationType.interactive,
          duration: 20,
          difficulty: EducationDifficulty.intermediate,
          tags: ['ilişki', 'iletişim', 'problem çözme', 'empati'],
          thumbnail: 'assets/images/relationships_thumb.jpg',
          contentUrl: 'https://example.com/relationships_interactive.html',
          author: 'Dr. Zeynep Arslan',
          rating: 4.8,
          viewCount: 1800,
          isPremium: false,
        ),
        EducationModel(
          id: '6',
          title: 'Travma Sonrası Stres Bozukluğu (TSSB)',
          description:
              'TSSB tanısı, belirtileri ve EMDR, PE gibi tedavi yöntemleri',
          category: 'Travma',
          type: EducationType.video,
          duration: 35,
          difficulty: EducationDifficulty.advanced,
          tags: ['travma', 'TSSB', 'EMDR', 'PE', 'tedavi'],
          thumbnail: 'assets/images/trauma_thumb.jpg',
          contentUrl: 'https://example.com/trauma_video.mp4',
          author: 'Prof. Dr. Selin Yıldız',
          rating: 4.9,
          viewCount: 1200,
          isPremium: true,
        ),
        EducationModel(
          id: '7',
          title: 'Çocuk ve Ergen Terapisi Temelleri',
          description:
              'Gelişim dönemlerine göre terapi yaklaşımları ve oyun terapisi',
          category: 'Çocuk & Ergen',
          type: EducationType.interactive,
          duration: 40,
          difficulty: EducationDifficulty.intermediate,
          tags: ['çocuk', 'ergen', 'oyun terapisi', 'gelişim'],
          thumbnail: 'assets/images/child_therapy_thumb.jpg',
          contentUrl: 'https://example.com/child_therapy_interactive.html',
          author: 'Dr. Emre Kaya',
          rating: 4.7,
          viewCount: 950,
          isPremium: false,
        ),
        EducationModel(
          id: '8',
          title: 'Bilişsel Davranışçı Terapi (CBT) Uygulamaları',
          description:
              'CBT teknikleri, otomatik düşünceler ve davranış değişimi',
          category: 'CBT',
          type: EducationType.video,
          duration: 50,
          difficulty: EducationDifficulty.advanced,
          tags: ['CBT', 'bilişsel', 'davranışçı', 'teknikler'],
          thumbnail: 'assets/images/cbt_thumb.jpg',
          contentUrl: 'https://example.com/cbt_video.mp4',
          author: 'Dr. Ayşe Demir',
          rating: 4.8,
          viewCount: 2100,
          isPremium: true,
        ),
        EducationModel(
          id: '9',
          title: 'Aile Terapisi ve Sistem Yaklaşımı',
          description:
              'Aile dinamikleri, iletişim kalıpları ve sistemik müdahale',
          category: 'Aile Terapisi',
          type: EducationType.pdf,
          duration: 60,
          difficulty: EducationDifficulty.advanced,
          tags: ['aile', 'sistem', 'dinamik', 'iletişim'],
          thumbnail: 'assets/images/family_therapy_thumb.jpg',
          contentUrl: 'https://example.com/family_therapy_guide.pdf',
          author: 'Dr. Mehmet Özkan',
          rating: 4.6,
          viewCount: 780,
          isPremium: true,
        ),
        EducationModel(
          id: '10',
          title: 'Mindfulness Quiz: Farkındalık Seviyenizi Test Edin',
          description:
              'Mindfulness pratiklerinizi değerlendiren interaktif quiz',
          category: 'Quiz',
          type: EducationType.quiz,
          duration: 15,
          difficulty: EducationDifficulty.beginner,
          tags: ['mindfulness', 'quiz', 'test', 'farkındalık'],
          thumbnail: 'assets/images/mindfulness_quiz_thumb.jpg',
          contentUrl: 'https://example.com/mindfulness_quiz.html',
          author: 'Dr. Fatma Kaya',
          rating: 4.5,
          viewCount: 1500,
          isPremium: false,
        ),
      ];

      // Demo kullanıcı ilerlemesi
      _userProgress = [
        _allContent[0].copyWith(
          progress: 0.8,
          lastAccessed: DateTime.now().subtract(const Duration(hours: 2)),
          completedSections: ['Giriş', 'Belirtiler', 'Nedenler'],
          remainingSections: ['Tedavi Yöntemleri', 'Özet'],
        ),
        _allContent[2].copyWith(
          progress: 0.3,
          lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
          completedSections: ['Giriş'],
          remainingSections: [
            'Temel Teknikler',
            'Günlük Pratikler',
            'İleri Seviye'
          ],
        ),
        _allContent[5].copyWith(
          progress: 1.0,
          lastAccessed: DateTime.now().subtract(const Duration(days: 3)),
          completedSections: [
            'Giriş',
            'TSSB Tanısı',
            'EMDR Tekniği',
            'PE Protokolü',
            'Vaka Örnekleri'
          ],
          remainingSections: [],
        ),
        _allContent[7].copyWith(
          progress: 0.6,
          lastAccessed: DateTime.now().subtract(const Duration(hours: 6)),
          completedSections: ['Giriş', 'CBT Temelleri', 'Otomatik Düşünceler'],
          remainingSections: ['Davranış Değişimi', 'Vaka Çalışması'],
        ),
        _allContent[9].copyWith(
          progress: 0.9,
          lastAccessed: DateTime.now().subtract(const Duration(hours: 1)),
          completedSections: ['Giriş', 'Quiz Soruları 1-8'],
          remainingSections: ['Son Değerlendirme'],
        ),
      ];

      _recommendedContent = _allContent
          .where((content) =>
              content.category == 'Depresyon' ||
              content.category == 'Mindfulness')
          .toList();
    });
  }

  Future<void> _generateAIRecommendations(
      String userInterests, List<String> completedTopics) async {
    setState(() => _isGeneratingRecommendations = true);

    try {
      // TODO: AI recommendation service
      await Future.delayed(const Duration(seconds: 3));

      // Demo AI önerileri
      final recommendations = _allContent.where((content) {
        // Kullanıcının ilgi alanlarına göre filtrele
        if (userInterests.toLowerCase().contains('depresyon') &&
            content.category == 'Depresyon') return true;
        if (userInterests.toLowerCase().contains('anksiyete') &&
            content.category == 'Anksiyete') return true;
        if (userInterests.toLowerCase().contains('mindfulness') &&
            content.category == 'Mindfulness') return true;

        // Tamamlanan konulara göre ileri seviye öneriler
        if (completedTopics.contains('Depresyon') &&
            content.category == 'Bipolar' &&
            content.difficulty == 'İleri') return true;

        return false;
      }).toList();

      setState(() {
        _recommendedContent = recommendations;
        _isGeneratingRecommendations = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${recommendations.length} kişiselleştirilmiş öneri bulundu!'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingRecommendations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI önerisi hatası: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitim Kitaplığı'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.school), text: 'Katalog'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Öneri'),
            Tab(icon: Icon(Icons.trending_up), text: 'İlerleme'),
            Tab(icon: Icon(Icons.verified), text: 'Sertifikalar'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Rozetler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Eğitim Kataloğu
          EducationCatalog(
            content: _allContent,
            onContentSelected: (content) {
              // TODO: İçerik detayını göster
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${content.title} açılıyor...'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
          ),

          // Tab 2: AI Öneri
          AIRecommendationPanel(
            allContent: _allContent,
            userProgress: _userProgress,
          ),

          // Tab 3: Öğrenme İlerlemesi
          LearningProgressPanel(
            userProgress: _userProgress,
          ),

          // Tab 4: Sertifikalar
          CertificatePanel(
            userProgress: _userProgress,
          ),

          // Tab 5: Rozetler
          BadgePanel(
            userProgress: _userProgress,
          ),
        ],
      ),
    );
  }
}
