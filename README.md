# bot-portfolio

Портфолио автоматизаций: Telegram-боты, n8n-воркфлоу, интеграции API.

## Стек

- **n8n** — визуальный конструктор воркфлоу (в Docker)
- **Telegram Bot API** — через @BotFather
- **Salebot / Puzzlebot** — конструкторы ботов для клиентских кейсов
- **Postman** — исследование чужих API

## Запуск n8n локально

```bash
docker compose up -d
```

Открыть: http://localhost:5678
Логин/пароль — из `docker-compose.yml` (по умолчанию `admin` / `change_me_before_first_run`, **обязательно поменять**).

Остановить:

```bash
docker compose down
```

## Структура

- `docker-compose.yml` — n8n в контейнере
- `.env.example` — шаблон переменных окружения (скопировать в `.env`, вписать токены)
- `workflows/` — экспорты воркфлоу n8n (JSON)
- `bots/` — исходники ботов (если пишутся кодом, а не в конструкторе)
