from langchain_ollama import OllamaLLM

def fix_code(code, error_message):
    llm = OllamaLLM(model="deepseek-coder:latest")
    
    prompt = f"""Sen bir Flutter kod düzelticisisin. Aşağıdaki hatayı düzelt:

HATALI KOD:
```dart
{code}
```

HATA: {error_message}

KURALLAR:
1. Sadece düzeltilmiş Dart kodu yaz
2. Açıklama ekleme
3. Import'ları dahil et
4. Widget'ı export edilebilir yap
5. Basit ve temiz kod yaz

DÜZELTİLMİŞ KOD:"""

    response = llm.invoke(prompt)
    return response
