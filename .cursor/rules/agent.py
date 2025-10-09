import subprocess
import shutil
import sys
import argparse
from typing import Optional

def _check_ollama_available() -> bool:
    return shutil.which("ollama") is not None


def start_llama3(model: str = "llama3") -> None:
    if not _check_ollama_available():
        print("❌ Hata: 'ollama' komutu bulunamadı. Lütfen Ollama'yı kurun: https://ollama.com")
        return
    print(f"🤖 {model} başlatılıyor...")
    try:
        subprocess.Popen(["ollama", "run", model])
    except Exception as exc:
        print(f"❌ Model başlatılırken hata: {exc}")

def prompt_to_llama(prompt: str, model: str = "llama3", timeout_sec: int = 120) -> str:
    if not _check_ollama_available():
        return "Hata: Ollama yüklü değil veya PATH'te bulunamadı."
    print("📤 Mesaj gönderiliyor...")
    try:
        result = subprocess.run(
            ["ollama", "run", model],
            input=prompt.encode(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=timeout_sec,
        )
        if result.returncode != 0:
            err = result.stderr.decode(errors="ignore")
            return f"Model çalıştırma hatası (code={result.returncode}): {err.strip()}"
        return result.stdout.decode()
    except subprocess.TimeoutExpired:
        return "Zaman aşımı: Model yanıtı belirtilen süre içinde gelmedi."
    except Exception as exc:
        return f"Beklenmeyen hata: {exc}"

def _build_default_prompt() -> str:
    return (
        "PsyClinic AI – MVP için ilk sprint hedefi:\n"
        "1. Kullanıcı kayıt ve giriş sistemi (email, Google, Apple)\n"
        "2. Randevu modülü (psikolog seçimi, tarih, saat)\n"
        "3. Seans ekranı (AI destekli not alma)\n"
        "4. PDF çıktısı (terapi notları)\n"
        "5. Firestore backend bağlantısı\n\n "
        "🔧 Bu sprint için en uygun görev planlamasını çıkar ve her görev için adım adım yapılacakları yaz."
    )


def main(argv: Optional[list[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="PsyClinicAI ajanı")
    parser.add_argument("--model", default="llama3", help="Ollama model adı (örn. llama3, llama3.1, qwen2)")
    parser.add_argument("--prompt", default=None, help="Özel prompt (boşsa varsayılan kullanılır)")
    parser.add_argument("--timeout", type=int, default=120, help="Yanıt için zaman aşımı (saniye)")
    parser.add_argument("--start-only", action="store_true", help="Sadece modeli başlat, prompt gönderme")

    args = parser.parse_args(argv)

    if args.start_only:
        start_llama3(args.model)
        return 0

    prompt = args.prompt or _build_default_prompt()
    print("🚀 AI ajan göreve başlıyor...\n")
    response = prompt_to_llama(prompt, model=args.model, timeout_sec=args.timeout)
    print("📥 Gelen yanıt:\n")
    print(response)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())