# agent_multi.py
import time
import os
import subprocess
from datetime import datetime

TASK_FILE = "tasks.txt"
OUTPUT_DIR = "outputs"
LOG_FILE = "agent_log.txt"
MODEL_NAME = "llama3"  # Değiştirilebilir: goose, qwen3, deepseek

def read_tasks():
    if not os.path.exists(TASK_FILE):
        print(f"\n❌ Hata: {TASK_FILE} dosyası bulunamadı.")
        return []
    with open(TASK_FILE, "r", encoding="utf-8") as file:
        tasks = [line.strip() for line in file if line.strip() and not line.startswith("#")]
        return tasks

def run_model(task_prompt):
    try:
        result = subprocess.run(
            ["ollama", "run", MODEL_NAME, task_prompt],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"❌ AI model hatası: {e.stderr.strip()}"

def save_output(task, content, index):
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"task_{index}_{timestamp}.md"
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    full_path = os.path.join(OUTPUT_DIR, filename)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(f"# Görev: {task}\n\n")
        f.write(content)
    return filename

def log_result(task, filename):
    with open(LOG_FILE, "a", encoding="utf-8") as log:
        log.write(f"[{datetime.now()}] Görev işlendi: {task} -> {filename}\n")

def main():
    tasks = read_tasks()
    if not tasks:
        print("\n⚠️ İşlenecek görev bulunamadı.")
        return

    print(f"\n🧠 {len(tasks)} görev bulundu. İşleniyor...\n")
    for idx, task in enumerate(tasks, start=1):
        print(f"\n🚀 Görev {idx}/{len(tasks)}: {task}")
        time.sleep(1)
        result = run_model(task)
        filename = save_output(task, result, idx)
        log_result(task, filename)
        print(f"✅ Kayıt tamamlandı: {filename}\n")
        time.sleep(1)

    print("\n🎉 Tüm görevler başarıyla tamamlandı.")

if __name__ == "__main__":
    main()
