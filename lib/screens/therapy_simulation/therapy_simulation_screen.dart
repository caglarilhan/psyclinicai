import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../models/therapy_simulation_model.dart';
import '../../widgets/therapy_simulation/simulation_scenario_panel.dart';
import '../../widgets/therapy_simulation/ai_client_panel.dart';
import '../../widgets/therapy_simulation/session_notes_panel.dart';

class TherapySimulationScreen extends StatefulWidget {
  const TherapySimulationScreen({super.key});

  @override
  State<TherapySimulationScreen> createState() =>
      _TherapySimulationScreenState();
}

class _TherapySimulationScreenState extends State<TherapySimulationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<SimulationScenario> _scenarios = [];
  SimulationScenario? _selectedScenario;
  bool _isSessionActive = false;
  List<SessionMessage> _sessionMessages = [];
  String _sessionNotes = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDemoScenarios();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDemoScenarios() {
    setState(() {
      _scenarios = [
        SimulationScenario(
          id: '1',
          title: 'Depresyon Vakası: Ahmet',
          description:
              '35 yaşında erkek, son 6 aydır depresif belirtiler gösteriyor. İş kaybı ve evlilik problemleri yaşıyor.',
          difficulty: ScenarioDifficulty.intermediate,
          category: 'Depresyon',
          clientProfile: ClientProfile(
            name: 'Ahmet',
            age: 35,
            gender: 'Erkek',
            presentingProblem: 'Depresyon, iş kaybı, evlilik problemleri',
            background: 'Mühendis, 2 çocuk babası, son 6 aydır işsiz',
            symptoms: [
              'Üzgün ruh hali',
              'Uyku problemleri',
              'İştah kaybı',
              'Konsantrasyon güçlüğü'
            ],
            goals: 'Depresyonu yönetmek, iş bulmak, evliliği iyileştirmek',
          ),
          therapeuticApproach: 'CBT + Problem Solving Therapy',
          estimatedDuration: 45,
          tags: ['depresyon', 'iş kaybı', 'evlilik', 'CBT'],
        ),
        SimulationScenario(
          id: '2',
          title: 'Anksiyete Vakası: Zeynep',
          description:
              '28 yaşında kadın, sosyal anksiyete ve panik atak belirtileri. Topluluk önünde konuşma korkusu.',
          difficulty: ScenarioDifficulty.beginner,
          category: 'Anksiyete',
          clientProfile: ClientProfile(
            name: 'Zeynep',
            age: 28,
            gender: 'Kadın',
            presentingProblem: 'Sosyal anksiyete, panik atak',
            background:
                'Öğretmen, bekar, sosyal ortamlarda kendini rahatsız hissediyor',
            symptoms: [
              'Sosyal ortamlarda kaygı',
              'Panik atak',
              'Kaçınma davranışları',
              'Fiziksel belirtiler'
            ],
            goals: 'Sosyal anksiyeteyi azaltmak, panik atakları yönetmek',
          ),
          therapeuticApproach: 'Exposure Therapy + Relaxation Techniques',
          estimatedDuration: 40,
          tags: ['anksiyete', 'sosyal fobi', 'panik atak', 'exposure'],
        ),
        SimulationScenario(
          id: '3',
          title: 'Travma Vakası: Mehmet',
          description:
              '42 yaşında erkek, trafik kazası sonrası TSSB belirtileri. Flashback\'ler ve uyku problemleri.',
          difficulty: ScenarioDifficulty.advanced,
          category: 'Travma',
          clientProfile: ClientProfile(
            name: 'Mehmet',
            age: 42,
            gender: 'Erkek',
            presentingProblem: 'TSSB, trafik kazası sonrası',
            background: 'Şoför, 3 ay önce ciddi trafik kazası geçirdi',
            symptoms: [
              'Flashback\'ler',
              'Uyku problemleri',
              'Kaçınma davranışları',
              'Aşırı uyarılma'
            ],
            goals: 'Travma belirtilerini azaltmak, normal hayata dönmek',
          ),
          therapeuticApproach: 'EMDR + Trauma-Focused CBT',
          estimatedDuration: 60,
          tags: ['travma', 'TSSB', 'EMDR', 'flashback'],
        ),
      ];
    });
  }

  void _startSimulation(SimulationScenario scenario) {
    setState(() {
      _selectedScenario = scenario;
      _isSessionActive = true;
      _sessionMessages = [];
      _sessionNotes = '';

      // AI danışanın ilk mesajını ekle
      _sessionMessages.add(SessionMessage(
        id: '1',
        sender: MessageSender.client,
        content: _generateInitialClientMessage(scenario),
        timestamp: DateTime.now(),
      ));
    });

    _tabController.animateTo(1); // AI Client tab'ına geç
  }

  void _endSimulation() {
    setState(() {
      _isSessionActive = false;
      _selectedScenario = null;
    });

    _tabController.animateTo(0); // Scenarios tab'ına dön
  }

  void _addTherapistMessage(String content) {
    if (content.trim().isEmpty) return;

    setState(() {
      _sessionMessages.add(SessionMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.therapist,
        content: content,
        timestamp: DateTime.now(),
      ));
    });

    // AI danışanın yanıtını simüle et
    _simulateAIResponse(content);
  }

  void _simulateAIResponse(String therapistMessage) {
    // AI yanıt simülasyonu
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _selectedScenario != null) {
        final aiResponse =
            _generateAIResponse(therapistMessage, _selectedScenario!);
        setState(() {
          _sessionMessages.add(SessionMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sender: MessageSender.client,
            content: aiResponse,
            timestamp: DateTime.now(),
          ));
        });
      }
    });
  }

  String _generateInitialClientMessage(SimulationScenario scenario) {
    switch (scenario.id) {
      case '1': // Ahmet - Depresyon
        return 'Merhaba doktor... Son zamanlarda kendimi çok kötü hissediyorum. İşimi kaybettikten sonra hiçbir şey yapmak istemiyorum. Karım da sürekli beni eleştiriyor. Sanki hiçbir değerim yok gibi...';
      case '2': // Zeynep - Anksiyete
        return 'Doktor bey, size gelmek bile çok zordu. Kalbim hala hızlı atıyor. Topluluk önünde konuşmam gerektiğinde neredeyse bayılıyorum. Bu durum beni çok yoruyor...';
      case '3': // Mehmet - Travma
        return 'Doktor... O kazayı hala görebiliyorum. Her gece aynı rüyayı görüyorum. Arabaya binmek bile imkansız. Sürekli tetikteyim, en ufak ses bile beni korkutuyor...';
      default:
        return 'Merhaba doktor, size yardım etmenizi umuyorum...';
    }
  }

  String _generateAIResponse(
      String therapistMessage, SimulationScenario scenario) {
    final message = therapistMessage.toLowerCase();

    // Depresyon vakası için yanıtlar
    if (scenario.id == '1') {
      if (message.contains('nasıl hissediyorsun') ||
          message.contains('duygu')) {
        return 'Kendimi çok boş hissediyorum... Sanki hiçbir şey beni mutlu edemiyor. Bazen ölmek istediğimi bile düşünüyorum...';
      } else if (message.contains('iş') || message.contains('kariyer')) {
        return 'İş bulmaya çalışıyorum ama hiç umudum yok. Her mülakatta reddediliyorum. Artık denemek istemiyorum...';
      } else if (message.contains('evlilik') || message.contains('karı')) {
        return 'Karım sürekli beni suçluyor. "Sen işsizsin, para kazanamıyorsun" diyor. Haklı da... Ben değersiz biriyim...';
      }
    }

    // Anksiyete vakası için yanıtlar
    if (scenario.id == '2') {
      if (message.contains('kaygı') || message.contains('korku')) {
        return 'Kalp atışlarım hızlanıyor, nefes alamıyorum... Sanki öleceğim gibi hissediyorum. Bu çok korkunç...';
      } else if (message.contains('sosyal') || message.contains('topluluk')) {
        return 'İnsanların beni yargılayacağını düşünüyorum. "Ya yanlış bir şey söylersem?" diye sürekli endişeleniyorum...';
      }
    }

    // Travma vakası için yanıtlar
    if (scenario.id == '3') {
      if (message.contains('kaz') || message.contains('travma')) {
        return 'O anı tekrar yaşıyorum... Cam kırıkları, sesler, acı... Uyuyamıyorum, sürekli tetikteyim...';
      } else if (message.contains('ara') || message.contains('bin')) {
        return 'Arabaya binmek imkansız! Her seferinde o kazayı hatırlıyorum. Kalbim hızla atıyor, terliyorum...';
      }
    }

    // Genel yanıtlar
    if (message.contains('nasıl') || message.contains('ne düşünüyorsun')) {
      return 'Bilmiyorum... Bazen iyi hissediyorum ama çoğunlukla kötüyüm. Size yardım etmenizi umuyorum...';
    }

    return 'Anlıyorum... Bu konuda daha fazla konuşmak istiyorum...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terapi Simülasyonu'),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.theater_comedy), text: 'Senaryolar'),
            Tab(icon: Icon(Icons.chat), text: 'AI Danışan'),
            Tab(icon: Icon(Icons.notes), text: 'Seans Notları'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Senaryolar
          SimulationScenarioPanel(
            scenarios: _scenarios,
            onScenarioSelected: _startSimulation,
            isSessionActive: _isSessionActive,
          ),

          // Tab 2: AI Danışan
          if (_selectedScenario != null && _isSessionActive)
            AIClientPanel(
              scenario: _selectedScenario!,
              messages: _sessionMessages,
              onMessageSent: _addTherapistMessage,
              onEndSession: _endSimulation,
            )
          else
            const Center(
              child: Text('Lütfen bir senaryo seçin'),
            ),

          // Tab 3: Seans Notları
          SessionNotesPanel(
            sessionNotes: _sessionNotes,
            onNotesChanged: (notes) {
              setState(() {
                _sessionNotes = notes;
              });
            },
            onSaveNotes: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Seans notları kaydedildi'),
                  backgroundColor: AppTheme.accentColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
