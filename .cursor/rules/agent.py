import subprocess

def start_llama3():
    print("🤖 Llama3 başlatılıyor...")
    subprocess.Popen(["ollama", "run", "llama3"])

def prompt_to_llama(prompt):
    print("📤 Mesaj gönderiliyor...")
    result = subprocess.run(
        ["ollama", "run", "llama3"],
        input=prompt.encode(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    return result.stdout.decode()

if __name__ == "__main__":
    prd = """
    PsyClinic AI – MVP için ilk sprint hedefi:
    1. Kullanıcı kayıt ve giriş sistemi (email, Google, Apple)
    2. Randevu modülü (psikolog seçimi, tarih, saat)
    3. Seans ekranı (AI destekli not alma)
    4. PDF çıktısı (terapi notları)
    5. Firestore backend bağlantısı

    🔧 Bu sprint için en uygun görev planlamasını çıkar ve her görev için adım adım yapılacakları yaz.
    """
    
    print("🚀 AI ajan göreve başlıyor...\n")
    response = prompt_to_llama(prd)
    print("📥 Gelen yanıt:\n")
    print(response)