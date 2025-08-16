# Otomatik Sprint Sistemi (Goose + Qwen/LLM) — Kullanım

## 🚀 Sistem Bileşenleri

### 1. Sprint Planı (tasks.txt)
- 16 haftalık sprint planı
- Her sprint için detaylı görevler
- Model önerileri (deepseek-coder, llama3, mistral)

### 2. Çalıştırma Script'i (run_sprint.sh)
```bash
# Kullanım
./run_sprint.sh "Sprint açıklaması" [model_adı]

# Örnekler
./run_sprint.sh "Sprint 1: Flutter projesi oluştur ve temel ThemeData ile light/dark tema yapılandırmasını yap." deepseek-coder:latest
./run_sprint.sh "Sprint 2: Firebase Authentication ile e-posta tabanlı kayıt/giriş akışını kur ve rumuz seçimini ekle." deepseek-coder:latest
```

### 3. Goose Sprint Bridge (goose_sprint_bridge.py)
- Ollama entegrasyonu
- Model fallback sistemi
- Otomatik çıktı kaydetme

### 4. Post-Processing (consume_sprint_output.py)
- Çıktıyı otomatik ayrıştırma
- Flutter widget'ları `lib/components/` altına yazma
- Firestore schema'ları `schemas/` altına yazma
- Prompt'ları `prompts/` altına yazma

## 📋 Sprint Planı

### Sprint 1 - Temel Altyapı ✅
- [x] Flutter projesi oluştur ve temel ThemeData ile light/dark tema yapılandırmasını yap
- [x] Tab bar navigasyon iskeletini oluştur: Feed, Mood, AI Chat, Bildirim, Profil
- [x] Placeholder ekranlar ile "Under Construction" detaylarını koy ve başlangıçta temel state management setup'u ekle

### Sprint 2 - Authentication & Onboarding ✅
- [x] Firebase Authentication ile e-posta tabanlı kayıt/giriş akışını kur ve rumuz seçimini ekle
- [ ] Onboarding slaytlarını kodla ve "atla" fonksiyonunu ekle
- [ ] Kullanıcı ilgi alanı tercihi ekranı oluştur

### Sprint 3 - Mood Tracking
- [ ] Mood entry UI + Firestore yazma yapısını kur; mood + not kaydedilsin
- [ ] Geçmiş mood girişlerini listeleyen ekran oluştur
- [ ] Mood trend grafiğini çizen chart component'ini ekle

### Sprint 4 - Community Feed
- [ ] Post paylaşma ekranı ve Firestore posts koleksiyonu yazma
- [ ] Feed ekranında realtime post listener kur
- [ ] Yorum sistemi implementasyonu (comment ekleme ve listeleme)
- [ ] Gönderi/yorum için rapor et butonu ve report kaydı
- [ ] Basit küfür filtresiyle flagged post'ları işaretle

### Sprint 5 - AI Chat & Analytics
- [ ] AI sohbet botu UI ve backend (Cloud Function) entegrasyonu kur
- [ ] Yeni moodEntry geldiğinde AI analizi yapan function yaz
- [ ] Rozet ve puan sistemini tetikleyen logic yaz; kullanıcı profilinde göster
- [ ] Çoklu dil altyapısı için sabit metinleri lokalize edecek l10n dosyalarını oluştur

### Sprint 6 - Crisis Mode & Security
- [ ] Kriz modu UI akışı ve nefes egzersizi ekranı oluştur
- [ ] Kriz durumunu moderatöre alert olarak yazan Cloud Function yaz
- [ ] Firestore security rules yaz (kendi mood'larını sadece kendi okuyabilecek, raporlar moderator görebilsin)

### Sprint 7 - Testing & Admin
- [ ] Unit test altyapısı kur ve kritik fonksiyonlar için test yaz
- [ ] Admin paneli oluştur (moderatör uyarıları, kriz durumları listesi)
- [ ] Beta kullanıcı testi için feedback sistemi kur

### Sprint 8 - Launch Preparation
- [ ] Erişilebilirlik kontrolleri ve iyileştirmeleri yap
- [ ] App store metadata ve yayın hazırlığı
- [ ] Monitoring ve crash reporting entegrasyonu

## 🛠️ Kurulum

### 1. Ollama Kurulumu
```bash
# Ollama'yi kur
brew install ollama

# Modelleri indir
ollama pull deepseek-coder:latest
ollama pull llama3:latest
ollama pull mistral:latest
```

### 2. Python Dependencies
```bash
# Virtual environment oluştur
python3 -m venv sprint_env
source sprint_env/bin/activate

# Dependencies yükle
pip install requests
```

### 3. Flutter Dependencies
```bash
cd psyclinicai
flutter pub get
```

### 4. Script'leri Çalıştırılabilir Yap
```bash
chmod +x .cursor/rules/scripts/run_sprint.sh
chmod +x .cursor/rules/scripts/consume_sprint_output.py
```

## 🔧 Kullanım

### Sprint Çalıştırma
```bash
cd .cursor/rules/scripts
./run_sprint.sh "Sprint açıklaması" [model]
```

### Çıktıları Kontrol Etme
```bash
# Çıktı dosyalarını listele
ls -la outputs/

# Son çıktıyı oku
cat outputs/son_olusturulan_dosya.txt
```

### Model Seçimi
- **deepseek-coder:latest**: Flutter/UI işleri için
- **mistral:latest**: Firestore/schema işleri için  
- **llama3:latest**: Genel işler için

## 📁 Dosya Yapısı

```
psyclinicai/
├── lib/
│   ├── main.dart              # Ana uygulama
│   ├── navigation.dart        # Tab bar navigasyon
│   ├── components/            # Otomatik oluşturulan widget'lar
│   └── auth/
│       └── auth_screen.dart   # Authentication ekranı
├── .cursor/rules/
│   ├── tasks.txt              # Sprint planı
│   ├── scripts/
│   │   ├── run_sprint.sh      # Çalıştırma script'i
│   │   ├── consume_sprint_output.py  # Post-processing
│   │   ├── agent-extension.ts # Cursor extension stub
│   │   ├── outputs/           # Çıktı dosyaları
│   │   ├── lib/components/    # Otomatik oluşturulan Flutter widget'ları
│   │   ├── schemas/           # Firestore schema'ları
│   │   └── prompts/           # AI prompt'ları
│   └── sprint_env/            # Python virtual environment
```

## 🎯 Cursor Custom Command

### Kurulum
Cursor'da "Command Palette" açın (Cmd+Shift+P) ve şu custom command'i ekleyin:

**Komut Adı**: `Run Goose Sprint Line`

**Komut**: 
```bash
.cursor/rules/scripts/run_sprint.sh "<SELECTED_TEXT>" llama3:latest
```

**Kullanım**:
1. tasks.txt'den bir sprint satırını seçin
2. Cmd+Shift+P ile "Run Goose Sprint Line" komutunu çalıştırın
3. Otomatik olarak:
   - Sprint çalıştırılır
   - Flutter widget'ları `lib/components/` altına yazılır
   - Firestore schema'ları `schemas/` altına yazılır
   - Prompt'lar `prompts/` altına yazılır

### Alternatif: Kısayol Tuşu
Cursor'da kısayol tuşu atayabilirsiniz:
- **Mac**: Cmd+Shift+S
- **Windows/Linux**: Ctrl+Shift+S

## 🎯 Örnek Kullanım

### 1. Yeni Sprint Ekleme
```bash
# tasks.txt'ye yeni sprint ekle
echo "Sprint 3: Mood entry UI + Firestore yazma yapısını kur; mood + not kaydedilsin." >> .cursor/rules/tasks.txt
```

### 2. Sprint Çalıştırma
```bash
./run_sprint.sh "Sprint 3: Mood entry UI + Firestore yazma yapısını kur; mood + not kaydedilsin." deepseek-coder:latest
```

### 3. Çıktıyı Uygulama
- Çıktı dosyasını oku
- Flutter widget'ları ilgili dosyalara ekle
- Firestore schema'ları uygula
- Test et ve commit et

## 🔍 Sorun Giderme

### Ollama Bağlantı Hatası
```bash
# Ollama servisini kontrol et
ollama list

# Servisi yeniden başlat
ollama serve
```

### Python Import Hatası
```bash
# Virtual environment'ı aktifleştir
source sprint_env/bin/activate

# Dependencies'i kontrol et
pip list
```

### Flutter Build Hatası
```bash
# Dependencies'i güncelle
flutter pub get

# Clean build
flutter clean
flutter pub get
```

### Post-Processing Hatası
```bash
# Çıktı dosyasını kontrol et
cat .cursor/rules/scripts/last_sprint_output.txt

# Manuel post-processing
python3 .cursor/rules/scripts/consume_sprint_output.py
```

### Bridge Script Hatası
```bash
# Bridge script'i bul
find . -name "goose_sprint_bridge.py"

# Script'i test et
python3 .cursor/rules/scripts/.cursor/rules/scripts/goose_sprint_bridge.py --help
```

## 📈 İlerleme Takibi

Her sprint tamamlandığında:
1. ✅ tasks.txt'de işaretle
2. 📝 Çıktı dosyasını incele
3. 🔧 Kodu uygula
4. 🧪 Test et
5. 💾 Commit et

## 🎉 Başarı Kriterleri

- [ ] Tüm sprint'ler tamamlandı
- [ ] Light/dark tema çalışıyor
- [ ] Authentication sistemi aktif
- [ ] Tab bar navigasyon çalışıyor
- [ ] Firestore bağlantısı kuruldu
- [ ] AI entegrasyonu hazır
- [ ] Test coverage %80+
- [ ] App store'a hazır

## 🚀 Otomatik Sistem Özellikleri

### ✅ Tamamlanan
- [x] Sprint çalıştırma script'i
- [x] Post-processing sistemi
- [x] Otomatik dosya oluşturma
- [x] Model fallback sistemi
- [x] Cursor custom command desteği
- [x] Hata yakalama ve bildirim
- [x] Otomatik dosya ayrıştırma

### 🔄 Geliştirilecek
- [ ] Cursor extension (TypeScript)
- [ ] Otomatik dosya açma
- [ ] Preview sistemi
- [ ] Test otomasyonu
- [ ] CI/CD entegrasyonu

## 🎯 Son Test Komutu

```bash
cd .cursor/rules/scripts
./run_sprint.sh "Sprint 4: Post paylaşma ekranı ve Firestore posts koleksiyonu yazma." mistral:latest

Sonra kontrol et:
ls -la lib/components/ | tail -3
ls -la prompts/
ls -la schemas/
```

---

**Not**: Bu sistem sürekli geliştirilmektedir. Yeni özellikler ve iyileştirmeler için PR'lar kabul edilir. 