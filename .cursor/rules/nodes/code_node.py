from langchain_ollama import ChatOllama

SYSTEM_POLICY = """Sen bir Flutter uzmanısın. Aşağıdaki kuralları KESİNLİKLE takip et:

YASAKLI SÖZCÜKLER (BUNLARI YAZMA):
- "Bu", "Bu kod", "Bu widget", "Bu sınıf"
- "Açıklama", "Yorum", "Not", "Örnek"
- "Flutter'da", "Dart'ta", "Widget olarak"
- "Merhaba", "Selam", "Hoş geldiniz"
- "Şimdi", "Artık", "Böylece", "Bu sayede"
- "Kullanıcı", "Kullanıcılar", "Geliştirici"
- "Proje", "Uygulama", "Sistem", "Platform"

KURALLAR:
1. SADECE Dart/Flutter kodu yaz - hiçbir açıklama, yorum, Türkçe metin yazma
2. Sadece flutter/material.dart import et
3. Harici paket kullanma
4. Maksimum 50 satır
5. Triple backtick yazma
6. Tek widget sınıfı üret
7. Material Design 3 kullan
8. Responsive tasarım yap
9. Export edilebilir widget oluştur
10. Gereksiz kod yazma
11. Sadece gerekli özellikler ekle
12. build() method'u olmalı
13. StatelessWidget veya StatefulWidget extend et
14. super.key kullan
15. const constructor yap

ÖRNEK FORMAT:
import 'package:flutter/material.dart';

class WidgetName extends StatelessWidget {
  const WidgetName({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello World'),
    );
  }
}

ŞİMDİ SADECE DART KODU YAZ:"""

def generate_code(plan_text: str) -> str:
    llm = ChatOllama(
        model="deepseek-coder", 
        temperature=0.1,
        # Stop sequences ekle
        stop=["Bu", "Bu kod", "Açıklama", "Yorum", "Not", "Örnek"]
    )
    
    prompt = f"{SYSTEM_POLICY}\n\nGörev: {plan_text.strip()}\n\nŞimdi sadece Dart kodu yaz:"
    
    response = llm.invoke(prompt)
    
    # AIMessage'ı string'e çevir
    if hasattr(response, 'content'):
        return str(response.content)
    else:
        return str(response) 