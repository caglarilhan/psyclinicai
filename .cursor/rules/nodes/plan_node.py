from langchain_ollama import OllamaLLM

def plan_task(input_text):
    llm = OllamaLLM(model="mistral:latest")
    prompt = f"""Bu Flutter görevini basit adımlara böl:

GÖREV: {input_text}

Sadece 2-3 ana adım yaz, çok detaylı olmasın:"""
    
    return llm.invoke(prompt) 