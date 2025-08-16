cat <<'EOF' > consume_sprint_output.py
#!/usr/bin/env python3
import sys, pathlib, json, re
from pathlib import Path

def main():
    if len(sys.argv) < 2:
        print("Usage: consume_sprint_output.py <output_file>")
        return
    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8")
    timestamp = ""
    base = path.stem

    # Widget (dart) yakala
    widget_match = re.search(r"### Flutter Widget ###\\s*(```dart(.*?)```)", text, re.S)
    if widget_match:
        code = widget_match.group(2).strip()
        comp_dir = Path("../../lib/components")
        comp_dir.mkdir(parents=True, exist_ok=True)
        widget_file = comp_dir / f"{base}_{timestamp}.dart"
        widget_file.write_text(code, encoding="utf-8")
        print(f"Yazıldı: {widget_file}")

    # Firestore schema yakala
    schema_match = re.search(r"### Firestore Schema ###\\s*(```json\\s*(\\{.*?\\})\\s*```)", text, re.S)
    if schema_match:
        schema_text = schema_match.group(2)
        schemas_dir = Path("schemas")
        schemas_dir.mkdir(exist_ok=True)
        schema_file = schemas_dir / f"{base}_{timestamp}.json"
        try:
            parsed = json.loads(schema_text)
            schema_file.write_text(json.dumps(parsed, indent=2, ensure_ascii=False), encoding="utf-8")
        except:
            schema_file.write_text(schema_text, encoding="utf-8")
        print(f"Yazıldı: {schema_file}")

    # Prompt yakala
    prompt_match = re.search(r"### Prompt 📋 ###\\s*(```\\s*(.*?)```)", text, re.S)
    if prompt_match:
        prompt_text = prompt_match.group(2).strip()
        prompts_dir = Path("prompts")
        prompts_dir.mkdir(exist_ok=True)
        prompt_file = prompts_dir / f"{base}_{timestamp}.txt"
        prompt_file.write_text(prompt_text, encoding="utf-8")
        print(f"Yazıldı: {prompt_file}")

    # Kopyala özet
    Path("last_sprint_output.txt").write_text(text, encoding="utf-8")

if __name__ == "__main__":
    main()
EOF

chmod +x consume_sprint_output.py