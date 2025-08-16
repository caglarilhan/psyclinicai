import os
import re
import json
import time
import argparse
import logging
import hashlib
from datetime import datetime
from pathlib import Path
import requests

# === CONFIG ===
# This script assumes a single Ollama HTTP endpoint that multiplexes multiple models by passing the desired model name
# in the payload (e.g., "llama3:latest", "mistral:latest", "deepseek-coder:latest"). You do NOT need separate Ollama instances on different ports unless you want isolation.
OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434/api/generate")
RETRY_ATTEMPTS = int(os.environ.get("AGENT_BRIDGE_RETRY", "3"))
TIMEOUT = int(os.environ.get("AGENT_BRIDGE_TIMEOUT", "120"))

# fallback ordering when primary fails
FALLBACK_CHAINS = {
    "deepseek-coder:latest": ["llama3:latest", "mistral:latest"],
    "mistral:latest": ["llama3:latest", "deepseek-coder:latest"],
    "llama3:latest": ["deepseek-coder:latest", "mistral:latest"],
}

# logger setup
logger = logging.getLogger("goose_sprint_bridge")
if not logger.hasHandlers():
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)

# === HELPERS ===

def choose_model(sprint_line: str) -> str:
    p = sprint_line.lower()
    if "flutter" in p or "widget" in p or "ui" in p:
        return "deepseek-coder:latest"
    if "firestore" in p or "schema" in p:
        return "mistral:latest"
    return "llama3:latest"


def make_safe_filename(s: str, max_len: int = 60) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9_\\-]", "_", s.strip())
    cleaned = re.sub(r"_+", "_", cleaned)  # collapse repeats
    prefix = cleaned[:max_len]
    short_hash = hashlib.sha1(s.encode("utf-8")).hexdigest()[:8]
    return f"{prefix}_{short_hash}".lower().rstrip("_")


def build_prompt(sprint_line: str) -> str:
    return f"""You are an AI development assistant building PsyClinic AI. The sprint line is:
\"{sprint_line}\"

Tasks:
1. Generate Flutter code for the described UI (session screen, appointment calendar) using a design system with light/dark theme.
2. Output Firestore JSON schemas for 'sessions' and 'appointments'.
3. Provide an internal prompt to convert session notes into a DSM/ICD-compatible summary with fields: affect, theme, icdSuggestion.
4. Describe how to export that summary to PDF in Flutter (include a concise code example or approach).

Output sections clearly delimited:

### Flutter Widget ###
...dart code...

### Firestore Schema ###
...valid JSON object for the 'sessions' and 'appointments' schemas...

### AI Summary Prompt ###
...the prompt to feed into the LLM to get the structured summary...

### PDF Export Instructions ###
...short example snippet or explanation for creating the PDF from the summary..."""


def call_ollama(model: str, prompt: str) -> dict:
    payload = {"model": model, "prompt": prompt, "stream": False}
    last_err = None
    session = requests.Session()
    for attempt in range(1, RETRY_ATTEMPTS + 1):
        try:
            logger.info(f"Ollama çağrısı: model={model} deneme={attempt}")
            r = session.post(OLLAMA_URL, json=payload, timeout=TIMEOUT)
            # handle explicit model-not-found error in body
            if r.status_code == 400:
                try:
                    j = r.json()
                    err = str(j.get("error", "")).lower()
                    if "model" in err and "not found" in err:
                        raise RuntimeError(f"Model not found: {err}")
                except ValueError:
                    pass
            r.raise_for_status()
            data = r.json()
            return data
        except Exception as e:
            last_err = e
            wait = 2 ** (attempt - 1)
            logger.warning(f"⚠️ Ollama çağrısı hatası ({attempt}/{RETRY_ATTEMPTS}): {e}; {wait}s sonra yeniden denenecek.")
            time.sleep(wait)
    raise RuntimeError(f"Tüm Ollama denemeleri başarısız oldu: {last_err}")


def try_with_fallbacks(primary: str, prompt: str) -> dict:
    order = [primary] + FALLBACK_CHAINS.get(primary, [])
    last_exc = None
    for model in order:
        try:
            result = call_ollama(model, prompt)
            result.setdefault("used_model", model)
            return result
        except Exception as e:
            last_exc = e
            logger.warning(f"Model '{model}' ile başarısız: {e}")
    raise RuntimeError(f"Hiçbir model başarılı olamadı. Son hata: {last_exc}")


def validate_and_annotate_schema(full_text: str) -> str:
    schema_pattern = re.compile(r"(### Firestore Schema ###\s*)(\{.*?\})(?=###|$)", re.DOTALL)
    def replacer(match):
        prefix = match.group(1)
        body = match.group(2)
        try:
            parsed = json.loads(body)
            pretty = json.dumps(parsed, indent=2, ensure_ascii=False)
            return f"{prefix}{pretty}"
        except Exception:
            warning = "\n// WARNING: Şema JSON geçerli değil veya parse edilemedi.\n"
            return f"{prefix}{body}{warning}"
    return schema_pattern.sub(replacer, full_text)


def atomic_write(path: Path, data: str):
    tmp = path.with_suffix(path.suffix + ".tmp")
    try:
        with open(tmp, "w", encoding="utf-8") as f:
            f.write(data)
        os.replace(tmp, path)
    except Exception:
        try:
            tmp.unlink()
        except Exception:
            pass
        raise

# === MAIN ===

def main():
    parser = argparse.ArgumentParser(
        description="Bridge script for Goose sprint processing (single Ollama endpoint, model passed dynamically)"
    )
    parser.add_argument("--sprint-line", required=True, help="Sprint line to process")
    parser.add_argument(
        "--model",
        required=False,
        help="Optional override of model to use instead of inferring from sprint line (e.g., llama3:latest, mistral:latest, deepseek-coder:latest)",
    )
    args = parser.parse_args()
    sprint_line = args.sprint_line.strip()

    # determine model: explicit override wins, otherwise infer from sprint line
    if args.model:
        model_choice = args.model
    else:
        model_choice = choose_model(sprint_line)
    logger.info(f"Seçilen model: {model_choice}")
    prompt = build_prompt(sprint_line)

    try:
        response_json = try_with_fallbacks(model_choice, prompt)
        text = response_json.get("response", "")
        used_model = response_json.get("used_model", model_choice)
    except Exception as e:
        text = f"❌ Model hatası: {e}"
        used_model = model_choice
        logger.error(f"Tüm modellerle başarısız oldu: {e}")

    full_output = validate_and_annotate_schema(text)
    safe = make_safe_filename(sprint_line, max_len=50)
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    base = f"{safe}_{timestamp}"

    out_dir = Path("outputs")
    out_dir.mkdir(parents=True, exist_ok=True)
    raw_path = out_dir / f"{base}_raw.txt"
    try:
        content = f"# Used model: {used_model}\n\n" + full_output
        atomic_write(raw_path, content)
        logger.info(f"📌 Ham çıktı yazıldı: {raw_path}")
    except Exception as e:
        logger.error(f"⚠️ Ham çıktı yazılamadı: {e}")

    # User-visible summary
    header = f"### Sprint line: {sprint_line}\n### Model used: {used_model}\n"
    print(header)
    print(full_output)


if __name__ == "__main__":
    main()