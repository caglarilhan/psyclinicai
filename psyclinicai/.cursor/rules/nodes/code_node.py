from langchain_ollama import ChatOllama

def generate_code(plan_text: str) -> str:
    llm = ChatOllama(model="deepseek-coder", temperature=0.1)
    
    prompt = f"""SADECE Dart/Flutter kodu yaz. Hiçbir açıklama, yorum, Türkçe metin yazma.

Görev: {plan_text}

Kurallar:
- Sadece flutter/material.dart import et
- Tek widget sınıfı üret
- StatelessWidget veya StatefulWidget extend et
- build() method'u olmalı
- super.key kullan
- const constructor yap
- Maksimum 50 satır

Örnek format:
import 'package:flutter/material.dart';

class WidgetName extends StatelessWidget {{
  const WidgetName({{super.key}});

  @override
  Widget build(BuildContext context) {{
    return Container(
      child: Text('Hello World'),
    );
  }}
}}

Şimdi sadece Dart kodu yaz:"""

    response = llm.invoke(prompt)
    
    # AIMessage'ı string'e çevir
    if hasattr(response, 'content'):
        return str(response.content)
    else:
        return str(response)
