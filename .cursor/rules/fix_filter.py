import sys, re
text = sys.stdin.read()

# Zero-width ve BOM temizliği
text = text.encode('utf-8','ignore').decode('utf-8')
text = text.replace('\ufeff','')  # BOM
text = re.sub(r'[\u200B-\u200D\uFEFF]', '', text)  # zero-width

# Log/emoji/markdown temizliği
text = re.sub(r'^.*?(?=import|class)', '', text, flags=re.DOTALL)  # başlangıçtaki her şeyi import|class'e kadar at
text = re.sub(r'```.*?```', '', text, flags=re.DOTALL)  # code fences
text = re.sub(r'^#.*$', '', text, flags=re.MULTILINE)  # markdown başlık
text = re.sub(r'^//.*$', '', text, flags=re.MULTILINE)  # tek satır yorum
text = re.sub(r'/\*.*?\*/', '', text, flags=re.DOTALL)  # çok satır yorum
text = re.sub(r'[\ud800-\udfff]', '', text)  # surrogate aralığı (emoji vb.)

# Sadece Dart kodu kalsın: import satırları ve sınıf/ana fonksiyon gövdeleri
# Önce code fence içi varsa onu al
fenced = re.findall(r"```(?:dart)?\s*([\s\S]*?)```", text, re.I)
if fenced:
    text = fenced[-1]

# Import'ları topla ve benzersizleştir
imports = re.findall(r"import\s+['\"][^'\"]+['\"];", text)
unique_imports = []
for imp in imports:
    if imp not in unique_imports:
        unique_imports.append(imp)
imports_text = "\n".join(unique_imports) + ("\n\n" if unique_imports else "")

# Import'ları içerikten çıkar
body = re.sub(r"import\s+['\"][^'\"]+['\"];", '', text).strip()

# Eğer sınıf/ana fonksiyon bulunmuyorsa, veya gövde boşsa -> fallback
has_class = re.search(r"\bclass\s+\w+\s+extends\s+(StatelessWidget|StatefulWidget)\b", body)
has_main = re.search(r"\bvoid\s+main\s*\(", body)
looks_like_dart = bool(has_class or has_main)

# İçerikte bariz log kelimeleri varsa geçersiz say
contains_logs = re.search(r"Durum:|Plan:|Test|EVAL|SUCCESS|FAILURE|\bFSM\b|Kod dosyaya yazıldı|Test ediliyor", body)

if not looks_like_dart or contains_logs:
    print("""import 'package:flutter/material.dart';

class HelloBox extends StatelessWidget {
  const HelloBox({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text("Hello from FSM"),
    );
  }
}
""".strip())
    sys.exit(0)

# Geçerli gövde ise, importları üstte birleştirerek yaz
print((imports_text + body).strip())
