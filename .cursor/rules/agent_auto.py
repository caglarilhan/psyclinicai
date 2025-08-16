import os
import time
import hashlib
import logging
import threading
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from datetime import datetime
from pathlib import Path
import requests
import json
import tempfile
import re
import signal

# graceful shutdown event used by signal handler
stop_event = threading.Event()

# === CONFIG ===
WATCH_DIR = "."
WATCH_FILE = "tasks.txt"
TASKS_DIR = "tasks"
PROCESSED_DIR = "processed_tasks"
LOG_DIR = "logs"
OUTPUT_FALLBACK = "outputs"

OLLAMA_API = os.environ.get("OLLAMA_API", "http://localhost:11434/api/generate")

RETRY_ATTEMPTS = int(os.environ.get("AGENT_AUTO_RETRY", "3"))
REQUEST_TIMEOUT = int(os.environ.get("AGENT_AUTO_TIMEOUT", "30"))
DEBOUNCE_SECONDS = float(os.environ.get("AGENT_AUTO_DEBOUNCE", "0.5"))

# Klasörleri oluştur (güvenli)
for d in (TASKS_DIR, PROCESSED_DIR, "lib/components", "prompts", "schemas", LOG_DIR, OUTPUT_FALLBACK):
    os.makedirs(d, exist_ok=True)

# tasks.txt yoksa yarat
tasks_path = os.path.join(WATCH_DIR, WATCH_FILE)
if not os.path.exists(tasks_path):
    open(tasks_path, "a").close()

# === LOGGING ===
logger = logging.getLogger("agent_auto")
logger.setLevel(logging.INFO)
from logging.handlers import RotatingFileHandler
rfh = RotatingFileHandler(os.path.join(LOG_DIR, "agent_auto.log"), maxBytes=5 * 1024 * 1024, backupCount=3, encoding="utf-8")
rfh.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))
logger.addHandler(rfh)
# Konsola da yaz
ch = logging.StreamHandler()
ch.setFormatter(logging.Formatter("%(message)s"))
logger.addHandler(ch)

# --- Durum cache (aynı tasks.txt içeriğini tekrar işlememek için) ---
last_tasks_hash = None

# --- Sprint satırları için üretilen görevlerin tekrarını önlemek için cache ---
GENERATED_CACHE = os.path.join(LOG_DIR, "generated_lines.json")

# In-memory set for generated lines, initialized at module load time
generated_lines = set()

# in-flight processing set to avoid double-handling
processing_lock = threading.Lock()
currently_processing = set()

# load / persist which sprint lines have already produced tasks (avoid duplicates)
def load_generated_lines():
    try:
        if os.path.exists(GENERATED_CACHE):
            with open(GENERATED_CACHE, "r", encoding="utf-8") as f:
                data = json.load(f)
                return set(data if isinstance(data, list) else [])
    except Exception as e:
        logger.warning(f"Generated lines cache load failed: {e}")
    return set()

def atomic_write(path: str, data: str):
    dirpath = os.path.dirname(path)
    os.makedirs(dirpath, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=dirpath)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as tmpf:
            tmpf.write(data)
        os.replace(tmp_path, path)
    except Exception:
        try:
            os.remove(tmp_path)
        except Exception:
            pass
        raise

def save_generated_lines(s):
    try:
        atomic_write(GENERATED_CACHE, json.dumps(list(s), indent=2, ensure_ascii=False))
    except Exception as e:
        logger.warning(f"Generated lines cache save failed: {e}")

# === YARDIMCILAR ===

def make_safe_filename(s: str) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9_\-]", "_", s.strip())
    base = cleaned.lower()
    if len(base) > 30:
        base = base[:30]
    suffix = hashlib.sha1(s.encode("utf-8")).hexdigest()[:6]
    return f"{base}_{suffix}"


def choose_model_name(prompt: str) -> str:
    p = prompt.lower()
    if "firestore" in p or "schema" in p:
        return "mistral:latest"
    if "flutter" in p or "widget" in p or "ui" in p:
        return "deepseek-coder:latest"
    return "llama3:latest"

# === Helper to create task filename with length limiting ===
def make_task_filename(line: str, idx: int, timestamp: str) -> str:
    safe_part = make_safe_filename(line)
    base = f"auto_task_{idx}_{safe_part}_{timestamp}"
    # ensure final filename length (including extension) stays reasonable (e.g., <=200)
    max_len = 200 - len(".md")
    if len(base) > max_len:
        prefix = f"auto_task_{idx}_"
        suffix = f"_{timestamp}"
        allowed_safe = max_len - len(prefix) - len(suffix)
        if allowed_safe < 5:
            # fallback to hash if too small
            safe_part = hashlib.sha1(line.encode("utf-8")).hexdigest()[:8]
            base = f"auto_task_{idx}_{safe_part}_{timestamp}"
        else:
            safe_part_trunc = safe_part[:allowed_safe]
            base = f"{prefix}{safe_part_trunc}{suffix}"
    return f"{base}.md"

# === MODEL ÇAĞRI ===

def query_model(endpoint: str, prompt: str, preferred_model: str | None = None) -> tuple[str, str]:
    session = requests.Session()
    # Build candidate model list: preferred first if given, otherwise choose based on prompt.
    if preferred_model:
        candidates = [preferred_model] + [m for m in ("llama3:latest", "mistral:latest", "deepseek-coder:latest") if m != preferred_model]
    else:
        pref = choose_model_name(prompt)
        candidates = [pref] + [m for m in ("llama3:latest", "mistral:latest", "deepseek-coder:latest") if m != pref]
    last_err = None
    for model in candidates:
        for attempt in range(1, RETRY_ATTEMPTS + 1):
            payload = {"prompt": prompt, "stream": False, "model": model}
            try:
                logger.info(f"Model çağrısı: {model} (deneme {attempt})")
                r = session.post(endpoint, json=payload, timeout=REQUEST_TIMEOUT)
                if r.status_code in (400, 404):
                    try:
                        err_json = r.json()
                        err_msg = str(err_json.get("error", "")).lower()
                        if "model" in err_msg and "not found" in err_msg:
                            logger.warning(f"Model '{model}' bulunamadı, sonraki modele geçilecek.")
                            break  # break out of retry loop to try next model
                    except ValueError:
                        pass
                r.raise_for_status()
                resp = r.json().get("response", "")
                if not resp:
                    logger.warning(f"Model '{model}' döndü ama response boş.")
                return resp, model
            except Exception as e:
                last_err = e
                wait = 2 ** (attempt - 1)
                logger.warning(f"Model çağrısı hatası ({attempt}/{RETRY_ATTEMPTS}) model='{model}': {e}. {wait}s sonra denenecek.")
                time.sleep(wait)
    logger.error(f"Tüm model çağrıları başarısız oldu: {last_err}")
    # fallback to preferred/or last candidate in logs
    fallback_model = preferred_model or candidates[0]
    return f"❌ Model hatası (tüm denemeler başarısız): {last_err}", fallback_model

# === PARSE & EXPORT ===

def parse_and_export(text: str, task_filename: str):
    base = Path(task_filename).stem
    exported_any = False

    try:
        with open(os.path.join(LOG_DIR, f"{base}_response.txt"), "w", encoding="utf-8") as f:
            f.write(text)
    except Exception as e:
        logger.warning(f"Response log yazılamadı: {e}")

    # Flutter bileşeni
    flutter_match = re.search(r"### Flutter Widget ###\s*(.*?)\s*(?=###|$)", text, re.DOTALL)
    if flutter_match:
        code = flutter_match.group(1).strip()
        code = re.sub(r"^```(?:dart)?\n?", "", code)
        code = re.sub(r"```$", "", code)
        dst = os.path.join("lib", "components", f"{base}.dart")
        try:
            with open(dst, "w", encoding="utf-8") as f:
                f.write(code + "\n")
            logger.info(f"✅ Flutter bileşeni: {dst}")
            exported_any = True
        except Exception as e:
            logger.error(f"Flutter bileşeni yazılamadı: {e}")

    # Firestore schema (JSON)
    schema_match = re.search(r"### Firestore Schema ###\s*(\{.*?\})\s*(?=###|$)", text, re.DOTALL)
    if schema_match:
        schema_json = schema_match.group(1).strip()
        try:
            parsed = json.loads(schema_json)
            pretty = json.dumps(parsed, indent=2, ensure_ascii=False)
        except Exception:
            pretty = schema_json
        dst = os.path.join("schemas", f"{base}.json")
        try:
            with open(dst, "w", encoding="utf-8") as f:
                f.write(pretty + "\n")
            logger.info(f"🔥 Schema: {dst}")
            exported_any = True
        except Exception as e:
            logger.error(f"Schema yazılamadı: {e}")

    # Prompt bölümü
    prompt_match = re.search(r"### Prompt 📋 ###\s*(.*?)\s*(?=###|$)", text, re.DOTALL)
    if prompt_match:
        prompt_text = prompt_match.group(1).strip()
        dst = os.path.join("prompts", f"{base}.txt")
        try:
            with open(dst, "w", encoding="utf-8") as f:
                f.write(prompt_text + "\n")
            logger.info(f"🧠 Prompt: {dst}")
            exported_any = True
        except Exception as e:
            logger.error(f"Prompt yazılamadı: {e}")

    # fallback
    if not exported_any:
        if "class" in text and "extends StatelessWidget" in text:
            dst = os.path.join("lib", "components", f"{base}.dart")
            try:
                with open(dst, "w", encoding="utf-8") as f:
                    f.write(text)
                logger.info(f"✅ Flutter bileşeni (fallback): {dst}")
                exported_any = True
            except Exception as e:
                logger.error(f"Fallback flutter yazılamadı: {e}")
        if "📋" in text or "Prompt" in text:
            dst = os.path.join("prompts", f"{base}.txt")
            try:
                with open(dst, "w", encoding="utf-8") as f:
                    f.write(text)
                logger.info(f"🧠 Prompt (fallback): {dst}")
                exported_any = True
            except Exception as e:
                logger.error(f"Fallback prompt yazılamadı: {e}")
        if text.strip().startswith("{") and ("clientid" in text.lower() or "schema" in text.lower()):
            dst = os.path.join("schemas", f"{base}.json")
            try:
                with open(dst, "w", encoding="utf-8") as f:
                    f.write(text)
                logger.info(f"🔥 Schema (fallback): {dst}")
                exported_any = True
            except Exception as e:
                logger.error(f"Fallback schema yazılamadı: {e}")

    if not exported_any:
        fallback_path = os.path.join(OUTPUT_FALLBACK, f"{base}_raw.txt")
        try:
            with open(fallback_path, "w", encoding="utf-8") as f:
                f.write(text)
            logger.info(f"📌 Ham çıktı yazıldı: {fallback_path}")
        except Exception as e:
            logger.error(f"Ham çıktı fallback yazılamadı: {e}")

# === GÖREV İŞLE ===

def process_task(file_path: str):
    with processing_lock:
        if file_path in currently_processing:
            logger.info(f"Zaten işleniyor, atlanıyor: {file_path}")
            return
        currently_processing.add(file_path)
    try:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                prompt = f.read()
        except Exception as e:
            logger.error(f"Görev oku hatası ({file_path}): {e}")
            return
        model_name = choose_model_name(prompt)
        logger.info(f"🔄 İşleniyor: {file_path} → {model_name}")
        result, used_model = query_model(OLLAMA_API, prompt, preferred_model=model_name)
        logger.info(f"✅ Model kullanıldı: {used_model}")
        parse_and_export(result, file_path)
        dst = os.path.join(PROCESSED_DIR, Path(file_path).name)
        try:
            os.replace(file_path, dst)
        except FileNotFoundError:
            logger.warning(f"Görev dosyası taşınamadı, bulunamadı: {file_path}")
        except Exception as e:
            logger.error(f"Görev taşınırken hata: {e}")
    finally:
        with processing_lock:
            currently_processing.discard(file_path)

# === GÖREV ÜRETİCİ ===

def generate_tasks(filepath: str):
    global last_tasks_hash
    global generated_lines
    if not (filepath.endswith(".txt") or filepath.endswith(".md")):
        return
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            text = f.read()
    except Exception as e:
        logger.error(f"Dosya okunamadı ({filepath}): {e}")
        return
    current_hash = hashlib.sha256(text.encode("utf-8")).hexdigest()
    if os.path.basename(filepath) == WATCH_FILE:
        if current_hash == last_tasks_hash:
            return
        last_tasks_hash = current_hash
    if "sprint" not in text.lower():
        return
    lines = text.splitlines()
    idx = 1
    for line in lines:
        if line.strip().lower().startswith("sprint"):
            key = hashlib.sha256(line.strip().lower().encode("utf-8")).hexdigest()
            if key in generated_lines:
                logger.info(f"✔️ Zaten işlenmiş satır, atlanıyor: {line.strip()}")
                idx += 1
                continue
            timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
            name = make_task_filename(line, idx, timestamp)
            dst = os.path.join(TASKS_DIR, name)
            content = f"# Görev: {line.strip()}\n\nLütfen üretimi tamamla.\n"
            try:
                atomic_write(dst, content)
                logger.info(f"✅ Görev oluşturuldu: {dst}")
                process_task(dst)
                generated_lines.add(key)
                save_generated_lines(generated_lines)
            except Exception as e:
                logger.error(f"Görev oluşturulurken hata: {e}")
            idx += 1

# === WATCHHANDLER ===
class WatchHandler(FileSystemEventHandler):
    def __init__(self):
        super().__init__()
        self._last_event_time = 0.0

    def on_modified(self, event):
        if event.is_directory:
            return
        now = time.time()
        if now - self._last_event_time < DEBOUNCE_SECONDS:
            return
        self._last_event_time = now
        if os.path.basename(event.src_path) == WATCH_FILE:
            logger.info(f"📝 {WATCH_FILE} değişti, görevler güncelleniyor...")
            generate_tasks(event.src_path)
        elif event.src_path.endswith('.md') and os.path.basename(os.path.dirname(event.src_path)) == TASKS_DIR:
            logger.info(f"🆕 Yeni görev dosyası algılandı: {event.src_path}")
            process_task(event.src_path)

    def on_created(self, event):
        if event.is_directory:
            return
        if os.path.basename(event.src_path) == WATCH_FILE:
            logger.info(f"📝 {WATCH_FILE} oluşturuldu, görevler üretilecek...")
            generate_tasks(event.src_path)
        elif event.src_path.endswith('.md') and os.path.basename(os.path.dirname(event.src_path)) == TASKS_DIR:
            logger.info(f"🆕 Yeni görev dosyası algılandı: {event.src_path}")
            process_task(event.src_path)

# === SAĞLIK KONTROLÜ ===

def health_check_models(endpoint: str) -> bool:
    success = False
    for model in ("llama3:latest", "mistral:latest", "deepseek-coder:latest"):
        try:
            logger.info(f"Health check: {model}")
            payload = {"prompt": "ping", "stream": False, "model": model}
            r = requests.post(endpoint, json=payload, timeout=5)
            if r.ok:
                logger.info(f"{model} yanıt verdi (status {r.status_code})")
                success = True
                break
            else:
                logger.warning(f"{model} sağlık kontrolü başarısız: status {r.status_code}")
        except Exception as e:
            logger.warning(f"{model} sağlık kontrolü sırasında hata: {e}")
    if not success:
        logger.error("Hiçbir Ollama modeli yanıt vermedi.")
    return success

# === SIGNAL HANDLER SETUP ===
def setup_signal_handlers(observer):
    def _handler(signum, frame):
        logger.info(f"Signal {signum} received, shutting down...")
        observer.stop()
        stop_event.set()
    signal.signal(signal.SIGINT, _handler)
    signal.signal(signal.SIGTERM, _handler)

# === ANA DÖNGÜ ===
if __name__ == "__main__":
    generated_lines = load_generated_lines()
    # health check
    if not health_check_models(OLLAMA_API):
        logger.warning("Ollama modellerine bağlanılamıyor; görevler model döndürmeyebilir.")
    if os.path.exists(tasks_path):
        generate_tasks(tasks_path)
    observer = Observer()
    handler = WatchHandler()
    observer.schedule(handler, WATCH_DIR, recursive=True)
    observer.start()
    setup_signal_handlers(observer)
    try:
        stop_event.wait()
    finally:
        logger.info("🛑 Durduruluyor...")
        observer.stop()
        observer.join()
        logger.info("✅ İzleyici kapatıldı.")