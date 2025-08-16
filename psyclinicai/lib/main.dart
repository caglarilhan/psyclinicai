import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';
import 'auth/auth_screen.dart';
import 'design_system.dart';
import 'widgets/generated/test_profile_card.dart';
import 'widgets/generated/simple_text_widget.dart';
// Modül sayfalarını import edeceğiz (dummy olarak)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(PsyClinicApp());
}

class PsyClinicApp extends StatefulWidget {
  @override
  State<PsyClinicApp> createState() => _PsyClinicAppState();
}

class _PsyClinicAppState extends State<PsyClinicApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PsyClinic AI',
      theme: _isDarkMode ? AppTheme.dark : AppTheme.light,
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Authentication wrapper
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen(onThemeToggle: () {}, isDarkMode: false);
        }
        
        if (snapshot.hasData) {
          // Kullanıcı giriş yapmış
          return MainNavigation();
        }
        
        // Kullanıcı giriş yapmamış
        return AuthScreen();
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  
  const SplashScreen({required this.onThemeToggle, required this.isDarkMode});
  
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainNavigation()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'PsyClinic AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  
  const HomePage({required this.onThemeToggle, required this.isDarkMode});

  final List<_HomeModule> modules = const [
    _HomeModule('Seans Notu', Icons.edit_note, null), // SessionNoteScreen will be passed dynamically
    _HomeModule('Randevu', Icons.calendar_today, null),
    _HomeModule('Tanı Arama', Icons.search, null),
    _HomeModule('Reçete', Icons.medication, null),
    _HomeModule('Eğitim', Icons.school, null),
    _HomeModule('Simülasyon', Icons.psychology, null),
    _HomeModule('Vaka', Icons.folder_shared, null),
    _HomeModule('Süpervizör', Icons.supervisor_account, null),
    _HomeModule('Finans', Icons.attach_money, null),
    _HomeModule('Mesajlaşma', Icons.message, null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PsyClinic AI'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onThemeToggle,
            tooltip: isDarkMode ? 'Açık tema' : 'Koyu tema',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Card Test
            ProfileCard(
              name: "Dr. Ahmet Yılmaz",
              bio: "Psikiyatrist - 15 yıl deneyim",
              avatarUrl: null,
            ),
            SizedBox(height: 16),
            // Simple Text Widget Test
            SimpleTextWidget(text: "Merhaba Flutter!"),
            SizedBox(height: 24),
            // Modules Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: modules.map((m) => _ModuleCard(module: m)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final _HomeModule module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (module.title == 'Seans Notu') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SessionNoteScreen()),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => Placeholder()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(module.icon, size: 40, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 16),
              Text(
                module.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeModule {
  final String title;
  final IconData icon;
  final Widget? page;
  const _HomeModule(this.title, this.icon, this.page);
}

// Seans Notu ekranı (önceki haliyle)
class SessionNoteScreen extends StatefulWidget {
  @override
  State<SessionNoteScreen> createState() => _SessionNoteScreenState();
}

class _SessionNoteScreenState extends State<SessionNoteScreen> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _aiSummary;

  @override
  void dispose() {
    _clientNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Seans notu kaydedildi!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seans Notu'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Danışan Adı',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _clientNameController,
                  decoration: InputDecoration(
                    hintText: 'Ad Soyad',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Seans Notu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  minLines: 6,
                  maxLines: 12,
                  decoration: InputDecoration(
                    hintText: 'Bugünkü görüşmede...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: Icon(Icons.save),
                  label: Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 32),
                Divider(),
                SizedBox(height: 16),
                Text(
                  'AI Seans Özeti (yakında)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _aiSummary ?? 'AI özet çıktısı burada görünecek.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
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
