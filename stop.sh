#!/usr/bin/env bash
set -e
PROJECT_DIR="$HOME/Desktop/bot-portfolio"
DOCKER_BIN="$HOME/.docker/bin/docker"
cd "$PROJECT_DIR"

echo "=== cloudflared ==="
pkill -f "cloudflared tunnel" && echo "убит" || echo "не был запущен"

echo
echo "=== n8n ==="
"$DOCKER_BIN" compose down

echo
echo "Готово. Docker Desktop оставляю запущенным — закрой сам, если нужно."
