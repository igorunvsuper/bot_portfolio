#!/usr/bin/env bash
set -e

PROJECT_DIR="$HOME/Desktop/bot-portfolio"
DOCKER_BIN="$HOME/.docker/bin/docker"
CLOUDFLARED_BIN="$PROJECT_DIR/tools/cloudflared"
CF_LOG="/tmp/cf.log"
ENV_FILE="$PROJECT_DIR/.env"

cd "$PROJECT_DIR"

echo "=== 1/5. Docker Desktop ==="
if ! "$DOCKER_BIN" info >/dev/null 2>&1; then
  echo "Docker Desktop не запущен, стартую..."
  open -a Docker
  for i in $(seq 1 60); do
    if "$DOCKER_BIN" info >/dev/null 2>&1; then
      echo "Docker поднялся (${i}s)"
      break
    fi
    sleep 1
  done
  if ! "$DOCKER_BIN" info >/dev/null 2>&1; then
    echo "Docker так и не поднялся за минуту. Открой Docker Desktop вручную и запусти скрипт снова."
    exit 1
  fi
else
  echo "уже запущен"
fi

echo
echo "=== 2/5. cloudflared ==="
pkill -f "cloudflared tunnel" 2>/dev/null || true
sleep 1
"$CLOUDFLARED_BIN" tunnel --url http://localhost:5678 > "$CF_LOG" 2>&1 &
disown
echo "жду URL..."
URL=""
for i in $(seq 1 20); do
  URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$CF_LOG" 2>/dev/null | head -1)
  [ -n "$URL" ] && break
  sleep 1
done
if [ -z "$URL" ]; then
  echo "URL не пришёл. Смотри $CF_LOG"
  tail -20 "$CF_LOG"
  exit 1
fi
echo "URL: $URL"

echo
echo "=== 3/5. .env ==="
python3 - <<PY
import re, pathlib
p = pathlib.Path("$ENV_FILE")
text = p.read_text() if p.exists() else ""
lines = [l for l in text.splitlines() if not l.startswith("WEBHOOK_URL=")]
lines.append(f"WEBHOOK_URL=$URL/")
p.write_text("\n".join(lines) + "\n")
print("WEBHOOK_URL записан")
PY

echo
echo "=== 4/5. n8n ==="
"$DOCKER_BIN" compose up -d 2>&1 | tail -3
for i in $(seq 1 30); do
  code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 2>/dev/null || echo 000)
  if [ "$code" = "200" ]; then
    echo "n8n готов (HTTP 200)"
    break
  fi
  sleep 1
done

echo
echo "=== 5/5. Готово ==="
echo
echo "Tunnel URL:  $URL"
echo "n8n editor:  http://localhost:5678"
echo "  логин:     admin"
echo "  пароль:    из $ENV_FILE  (grep N8N_BASIC_AUTH_PASSWORD)"
echo
echo "Не забудь: открыть workflow → Publish (заново, чтобы webhook переехал на новый URL)."
