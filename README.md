# bot-portfolio

Портфолио автоматизаций: Telegram-боты, n8n-воркфлоу, интеграции API.

## Стек

- **n8n** в Docker — визуальный конструктор воркфлоу
- **cloudflared** (quick tunnel) — публичный HTTPS для локального n8n, чтобы Telegram мог достучаться до вебхука в разработке
- **Telegram Bot API** — через @BotFather

## Быстрый старт

Предварительно: установлены Docker Desktop и Git.

```bash
git clone git@github.com:igorunvsuper/bot_portfolio.git
cd bot_portfolio
cp .env.example .env    # вписать TELEGRAM_BOT_TOKEN и пароль для n8n
```

Скачать cloudflared (один раз, кладём вне git):

```bash
mkdir -p tools
curl -L -o /tmp/cloudflared.tgz \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz
tar -xzf /tmp/cloudflared.tgz -C tools/
chmod +x tools/cloudflared
```

*(на Intel-маке замените `arm64` на `amd64`)*

Запуск всего разом:

```bash
./start.sh
```

Он поднимает Docker → n8n → cloudflared → пишет свежий HTTPS-URL в `.env` → перезапускает n8n с новым `WEBHOOK_URL`. Дальше зайти в http://localhost:5678, открыть workflow и нажать **Publish** — Telegram-webhook переедет на новый URL.

Остановить:

```bash
./stop.sh
```

## Структура

- `docker-compose.yml` — n8n в контейнере
- `start.sh` / `stop.sh` — управление всей связкой
- `.env.example` — шаблон переменных окружения
- `workflows/` — экспорты воркфлоу n8n (JSON)
- `bots/` — исходники ботов, написанных кодом (не в конструкторе)
- `tools/` — cloudflared и прочий сторонний софт (в git не хранится, ставится по инструкции выше)

## Воркфлоу

| Файл | Что делает |
|------|-----------|
| [echo-bot.json](workflows/echo-bot.json) | Простой эхо-бот: принимает сообщение и отвечает `Привет, <имя>! Ты написал: <текст>`. Демо-кейс, показывает связку Telegram Trigger → Send Message |
