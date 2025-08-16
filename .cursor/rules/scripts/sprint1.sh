#!/bin/bash
set -euo pipefail

SPRINT_LINE="Sprint 1: PsyClinic AI için Flutter'da seans ekranı (danışan seçimi, tarih ve seans notu girişi) + randevu takvimi ekranı (takvim görünümü, zaman seçici, no-show tahmini placeholder) oluştur. Seans notlarını alıp AI özetine çeviren ve PDF olarak dışa aktarabilen modül ekle. Firestore şemaları: sessions ve appointments. Light/dark tema ve design system constants kullanılsın."

echo "🚀 Sprint 1 başlatılıyor: PsyClinic AI Seans Ekranı + Randevu Takvimi"
echo "📝 Sprint: $SPRINT_LINE"
echo ""

cd "$(dirname "$0")"

# Sprint'i çalıştır
./run_sprint.sh "$SPRINT_LINE" mistral:latest

echo ""
echo "🔧 Üretilen dosyalar kontrol ediliyor..."

# Dosyaları kontrol et
if [[ -f "lib/components/"*".dart" ]]; then
    echo "✅ Flutter widget'ları oluşturuldu"
    ls -1 lib/components/*.dart
fi

if [[ -f "schemas/"*".json" ]]; then
    echo "✅ Firestore schema'ları oluşturuldu"
    ls -1 schemas/*.json
fi

if [[ -f "prompts/"*".txt" ]]; then
    echo "✅ AI prompt'ları oluşturuldu"
    ls -1 prompts/*.txt
fi

echo ""
echo "🎯 Sprint 1 tamamlandı! Üretilen dosyaları kontrol et:"
echo "   - lib/components/ (Flutter widget'ları)"
echo "   - schemas/ (Firestore schema'ları)"
echo "   - prompts/ (AI prompt'ları)"
echo ""
echo "📋 Sonraki adımlar:"
echo "   1. Widget'ları main.dart'a entegre et"
echo "   2. Firestore schema'larını uygula"
echo "   3. AI özet modülünü aktifleştir"
echo "   4. PDF export fonksiyonunu ekle" 