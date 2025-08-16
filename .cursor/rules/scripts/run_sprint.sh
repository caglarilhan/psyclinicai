#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage(){
  cat <<EOF
Usage: $0 "<sprint line>" [model]
Example: $0 "Sprint 3: Mood entry UI + Firestore yazma yapısını kur; mood + not kaydedilsin." llama3:latest
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

SPRINT_LINE=$1
MODEL=${2:-""}

# Python binary (virtualenv varsa active et ya da sistemden al)
PYTHON=$(command -v python3 || command -v python)
if [[ -z "$PYTHON" ]]; then
  echo "python3 bulunamadı."
  exit 1
fi

# Bridge script'i bul
BRIDGE=$(find . -type f -name goose_sprint_bridge.py | head -n1)
if [[ -z "$BRIDGE" ]]; then
  echo "goose_sprint_bridge.py bulunamadı. Doğru dizindesin mi?" >&2
  exit 1
fi

# Opsiyonel olarak çevresel değişken ile override edilebilir
export OLLAMA_URL=${OLLAMA_URL:-http://localhost:11434/api/generate}

echo "🚀 Sprint çalıştırılıyor: '$SPRINT_LINE' model override: '${MODEL:-<otomatik>}'"
if [[ -n "$MODEL" ]]; then
  CMD=("$PYTHON" "$BRIDGE" --sprint-line "$SPRINT_LINE" --model="$MODEL")
else
  CMD=("$PYTHON" "$BRIDGE" --sprint-line "$SPRINT_LINE")
fi

# Çalıştır ve çıktıyı yakala
set +e
OUTPUT=$("${CMD[@]}" 2>&1)
EXIT_CODE=$?
set -e

echo "$OUTPUT" > last_sprint_output.txt

if [[ $EXIT_CODE -ne 0 ]]; then
  echo "❌ Bridge script hata ile döndü (code=$EXIT_CODE). Çıktı:" >&2
  echo "$OUTPUT" >&2
  exit $EXIT_CODE
fi

# Çıktıyı işle
if [[ -f consume_sprint_output.py ]]; then
  echo "🔧 Çıktı işleniyor (consume_sprint_output.py)..."
  "$PYTHON" consume_sprint_output.py
else
  echo "⚠️ consume_sprint_output.py bulunamadı; manuel olarak çıktıya bakmalısın."
fi

echo "✅ Sprint tamamlandı ve çıktı işlendi." 