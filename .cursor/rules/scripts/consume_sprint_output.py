#!/usr/bin/env python3
import re
import json
import hashlib
from datetime import datetime
from pathlib import Path
import sys

def make_safe_base(s: str, max_len: int = 50) -> str:
    cleaned = re.sub(r"[^a-zA-Z0-9_\\-]", "_", s)
    cleaned = re.sub(r"_+", "_", cleaned)
    prefix = cleaned[:max_len]
    short_hash = hashlib.sha1(s.encode("utf-8")).hexdigest()[:8]
    return f"{prefix}_{short_hash}".lower().rstrip("_")

def main():
    path = Path("last_sprint_output.txt")
    if not path.exists():
        print("last_sprint_output.txt yok.", file=sys.stderr)
        sys.exit(1)
    text = path.read_text(encoding="utf-8")

    m = re.search(r'Sprint line: "(.*)"', text)
    sprint_line = m.group(1) if m else "sprint"
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    base = f"{make_safe_base(sprint_line)}_{timestamp}"

    # Flutter widget
    flutter = re.search(r"### Flutter Widget ###\s*(.*?)\s*(?=###|$)", text, re.DOTALL)
    if flutter:
        code = flutter.group(1)
        code = re.sub(r"^```(?:dart)?\n?", "", code)
        code = re.sub(r"```$", "", code)
        dst = Path("lib/components") / f"{base}.dart"
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(code.strip() + "\n", encoding="utf-8")
        print(f"✅ Flutter widget yazıldı: {dst}")

    # Firestore schema
    schema = re.search(r"### Firestore Schema ###\s*(\{.*?\})\s*(?=###|$)", text, re.DOTALL)
    if schema:
        schema_json = schema.group(1)
        try:
            parsed = json.loads(schema_json)
            pretty = json.dumps(parsed, indent=2, ensure_ascii=False)
        except Exception:
            pretty = schema_json
        dst = Path("schemas") / f"{base}.json"
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(pretty + "\n", encoding="utf-8")
        print(f"✅ Schema yazıldı: {dst}")

    # AI Summary Prompt
    ai_prompt = re.search(r"### AI Summary Prompt ###\s*(.*?)\s*(?=###|$)", text, re.DOTALL)
    if ai_prompt:
        prompt_text = ai_prompt.group(1).strip()
        dst = Path("prompts") / f"{base}_ai_summary.txt"
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(prompt_text + "\n", encoding="utf-8")
        print(f"✅ AI Summary Prompt yazıldı: {dst}")

    # PDF Export Instructions
    pdf_instructions = re.search(r"### PDF Export Instructions ###\s*(.*?)\s*(?=###|$)", text, re.DOTALL)
    if pdf_instructions:
        instructions_text = pdf_instructions.group(1).strip()
        dst = Path("prompts") / f"{base}_pdf_export.txt"
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_text(instructions_text + "\n", encoding="utf-8")
        print(f"✅ PDF Export Instructions yazıldı: {dst}")

if __name__ == "__main__":
    main() 