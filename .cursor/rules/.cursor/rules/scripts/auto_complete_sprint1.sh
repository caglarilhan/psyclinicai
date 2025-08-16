#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <sprint line> [model]"
  exit 1
fi

SPRINT_LINE="$1"
MODEL="${2:-mistral:latest}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"  # adjust if needed

echo "🚀 Otomatik Sprint 1 başlatılıyor: '$SPRINT_LINE' model: '$MODEL'"

# 1. Mevcut sprint sistemini çalıştır
cd "$SCRIPT_DIR"
./run_sprint.sh "$SPRINT_LINE" "$MODEL"

# 2. Gerekli temel dosyaları PRD uyarınca yerleştir

# 2a. Design system
DS_PATH="$REPO_ROOT/lib/design_system.dart"
if [ ! -f "$DS_PATH" ]; then
  mkdir -p "$(dirname "$DS_PATH")"
  cat <<'EOF' > "$DS_PATH"
import 'package:flutter/material.dart';

class DesignSystem {
  static const double padding = 16.0;
  static const TextStyle heading = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  static const TextStyle body = TextStyle(fontSize: 16);
}

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.light),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(bodyMedium: DesignSystem.body),
);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.black,
  textTheme: const TextTheme(bodyMedium: DesignSystem.body),
);
EOF
  echo "[auto] design_system.dart eklendi."
fi

# 2b. SessionScreen şablonu (eğer yoksa)
SS_PATH="$REPO_ROOT/lib/screens/session_screen.dart"
if [ ! -f "$SS_PATH" ]; then
  mkdir -p "$(dirname "$SS_PATH")"
  cat <<'EOF' > "$SS_PATH"
import 'package:flutter/material.dart';
import '../design_system.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _patient;
  DateTime _sessionDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();

  void _saveSession() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Firestore'a yaz, AI özet modülünü tetikle, PDF dışa aktar
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seans kaydedildi (placeholder)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seans')),
      body: Padding(
        padding: const EdgeInsets.all(DesignSystem.padding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Danışan seç'),
                items: const [
                  DropdownMenuItem(value: 'danisan1', child: Text('Danışan 1')),
                  DropdownMenuItem(value: 'danisan2', child: Text('Danışan 2')),
                ],
                onChanged: (v) => _patient = v,
                validator: (v) => v == null ? 'Danışan seçmelisin' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tarih',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _sessionDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _sessionDate = picked;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(text: _sessionDate.toLocal().toString().split(' ')[0]),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Seans notları',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Not gir' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSession,
                child: const Text('Kaydet ve AI özeti al'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF
  echo "[auto] session_screen.dart şablonu eklendi."
fi

# 3. Firestore JSON schema'ları
SCHEMA_DIR="$SCRIPT_DIR/schemas"
mkdir -p "$SCHEMA_DIR"

if [ ! -f "$SCHEMA_DIR/sessions.json" ]; then
  cat <<'EOF' > "$SCHEMA_DIR/sessions.json"
{
  "clientId": { "type": "string" },
  "therapistId": { "type": "string" },
  "sessionDateTime": { "type": "timestamp" },
  "notes": { "type": "string" },
  "aiSummary": {
    "affect": { "type": "string" },
    "theme": { "type": "string" },
    "icdSuggestion": { "type": "string" }
  },
  "createdAt": { "type": "timestamp" },
  "updatedAt": { "type": "timestamp" }
}
EOF
  echo "[auto] sessions.json eklendi."
fi

if [ ! -f "$SCHEMA_DIR/appointments.json" ]; then
  cat <<'EOF' > "$SCHEMA_DIR/appointments.json"
{
  "clientId": { "type": "string" },
  "therapistId": { "type": "string" },
  "appointmentDateTime": { "type": "timestamp" },
  "status": { "type": "string" },
  "noShowProbability": { "type": "double" },
  "createdAt": { "type": "timestamp" },
  "updatedAt": { "type": "timestamp" }
}
EOF
  echo "[auto] appointments.json eklendi."
fi

# 4. Flutter analiz
if command -v flutter >/dev/null && [ -f "$REPO_ROOT/pubspec.yaml" ]; then
  pushd "$REPO_ROOT" >/dev/null
  echo "[auto] flutter analyze çalıştırılıyor..."
  flutter analyze || echo "[auto] analyze uyarısı oldu ama devam ediyor."
  popd >/dev/null
fi

echo "[auto] Tamamlama bitti. Çıktıları kontrol et: lib/screens/session_screen.dart, lib/design_system.dart, $SCHEMA_DIR/"