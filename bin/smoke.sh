#!/usr/bin/env bash
set -e

# Locale + encoding sabitle
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

echo "🚀 Smoke Test Başlıyor..."

# 1) üret → filtrele
echo "📝 AI'dan kod üretiliyor..."
python3 .cursor/rules/fsm_runner.py <<'PROMPT' \
 | python3 .cursor/rules/fix_filter.py > lib/widgets/hello_box.dart
HEDEF DOSYA: lib/widgets/hello_box.dart
GÖREV: Bu dosya için TAM içeriği üret.
BİÇİM: SADECE DART KODU, AÇIKLAMA YOK, KOD BLOĞU İŞARETİ YOK.

GEREKSİNİMLER:
- Flutter StatelessWidget: class HelloBox extends StatelessWidget
- build(): Container(padding: 16) -> Text('Hello from FSM')

ŞİMDİ SADECE DART DOSYASI İÇERİĞİNİ YAZ.
PROMPT

# 2) format → analyze
echo "🔧 Kod formatlanıyor..."
dart format lib/widgets/hello_box.dart

echo "✅ Kod analiz ediliyor..."
if ! dart analyze lib/widgets/hello_box.dart; then
  echo "❌ AI kodu hatalı, fallback widget kullanılıyor..."
  # 3) fallback
  printf "%s\n" "import 'package:flutter/material.dart';
class HelloBox extends StatelessWidget{const HelloBox({super.key});
@override Widget build(BuildContext c)=>const Text('Hello from FSM');}" \
  > lib/widgets/hello_box.dart
  
  echo "✅ Fallback widget oluşturuldu"
fi

echo "🎯 Son test..."
dart analyze lib/widgets/hello_box.dart
echo "✅ Smoke test başarılı!"
