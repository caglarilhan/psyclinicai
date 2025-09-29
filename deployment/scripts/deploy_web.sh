#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy_web.sh /path/to/build/web
BUILD_DIR=${1:-"../build/web"}
DEST_DIR=~/psyclinicai_web

mkdir -p "$DEST_DIR"
rsync -av --delete "$BUILD_DIR"/ "$DEST_DIR"/

cd ~/psyclinicai/deployment
docker compose up -d psyclinicai-web

echo "Deploy completed."

