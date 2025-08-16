cat <<'EOF' > run_sprint.sh
#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <sprint line> [model]"
  exit 1
fi

sprint_line="$1"
model="${2:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BRIDGE="$SCRIPT_DIR/goose_sprint_bridge.py"

if [[ ! -f "$BRIDGE" ]]; then
  echo "❌ goose_sprint_bridge.py bulunamadı: $BRIDGE"
  exit 1
fi

model_arg=""
if [[ -n "$model" ]]; then
  model_arg="--model=$model"
fi

echo "🚀 Sprint çalıştırılıyor: '$sprint_line' model override: '${model:-<infer>}'"
python3 "$BRIDGE" --sprint-line "$sprint_line" $model_arg | tee last_sprint_output.txt

if [[ -f "$SCRIPT_DIR/consume_sprint_output.py" ]]; then
  echo "🔧 Çıktı işleniyor (consume_sprint_output.py)..."
  python3 "$SCRIPT_DIR/consume_sprint_output.py" last_sprint_output.txt
fi
EOF

chmod +x run_sprint.sh