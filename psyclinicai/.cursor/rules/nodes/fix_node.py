from langchain_ollama import ChatOllama

def fix_code(code: str, error_msg: str) -> str:
    llm = ChatOllama(model="openai/gpt-oss-20b", temperature=0.1)
    
    prompt = f"""Bu Flutter kodunda hata var. Hatayı düzelt ve SADECE düzeltilmiş Dart kodu yaz.

Hata: {error_msg}

Hatalı kod:
{code}

Kurallar:
- Sadece flutter/material.dart import et
- Tek widget sınıfı üret
- StatelessWidget veya StatefulWidget extend et
- build() method'u olmalı
- super.key kullan
- const constructor yap
- Maksimum 50 satır
- Hiçbir açıklama yazma

Şimdi düzeltilmiş Dart kodu yaz:"""

    response = llm.invoke(prompt)
    
    # AIMessage'ı string'e çevir
    if hasattr(response, 'content'):
        return str(response.content)
    else:
        return str(response)
