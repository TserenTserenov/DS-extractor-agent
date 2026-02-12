#!/bin/bash
# Отправка результатов Knowledge Extractor в Telegram
# Использование: ./notify_telegram.sh <process>
# Env vars: TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID

set -e

PROCESS="$1"
REPORTS_DIR="$HOME/Github/DS-my-strategy/inbox/extraction-reports"
DATE=$(date +%Y-%m-%d)

# Загрузка env
ENV_FILE="$HOME/.config/aist/env"
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# Проверка env vars
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "SKIP: TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set"
    exit 0
fi

# Находим последний отчёт за сегодня
find_report() {
    ls -t "$REPORTS_DIR"/${DATE}-*.md 2>/dev/null | head -1
}

# Извлекаем сводку из отчёта
extract_summary() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "Отчёт не найден"
        return 1
    fi

    local candidates
    candidates=$(grep -c '^## Кандидат' "$file" 2>/dev/null || echo "0")

    local accept
    accept=$(grep -c 'Вердикт.*accept' "$file" 2>/dev/null || echo "0")

    local reject
    reject=$(grep -c 'Вердикт.*reject' "$file" 2>/dev/null || echo "0")

    local defer
    defer=$(grep -c 'Вердикт.*defer' "$file" 2>/dev/null || echo "0")

    printf "<b>🔍 Knowledge Extractor: %s</b>\n\n" "$PROCESS"
    printf "📅 %s\n\n" "$DATE"
    printf "📊 <b>Результат:</b>\n"
    printf "  Кандидатов: %s\n" "$candidates"
    printf "  ✅ Accept: %s\n" "$accept"
    printf "  ❌ Reject: %s\n" "$reject"
    printf "  ⏸ Defer: %s\n\n" "$defer"

    if [ "$candidates" -gt 0 ]; then
        printf "Отчёт: <code>inbox/extraction-reports/%s</code>\n" "$(basename "$file")"
        printf "Для применения: в сессии Claude скажите «review extraction report»"
    else
        printf "Inbox пуст, новых captures нет."
    fi
}

# Отправка в Telegram
send_telegram() {
    local text="$1"

    # Обрезаем до 4000 символов
    text="${text:0:4000}"

    local escaped_text
    escaped_text=$(printf '%s' "$text" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

    local json_body
    json_body=$(printf '{"chat_id":"%s","text":%s,"parse_mode":"HTML","disable_web_page_preview":true}' \
        "$TELEGRAM_CHAT_ID" "$escaped_text")

    local response
    response=$(curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "$json_body")

    local ok
    ok=$(echo "$response" | python3 -c 'import sys,json; print(json.loads(sys.stdin.read()).get("ok",""))' 2>/dev/null || echo "")

    if [ "$ok" = "True" ]; then
        echo "Telegram notification sent for: $PROCESS"
    else
        echo "Telegram send FAILED for: $PROCESS"
        echo "Response: $response"
    fi
}

# Основной поток
case "$PROCESS" in
    "inbox-check")
        REPORT=$(find_report)
        if [ -z "$REPORT" ]; then
            # Inbox был пуст, нет отчёта — не уведомляем
            echo "No report found for today, skip notification"
            exit 0
        fi
        SUMMARY=$(extract_summary "$REPORT")
        send_telegram "$SUMMARY"
        ;;

    "audit")
        SUMMARY=$(printf "<b>🔍 Knowledge Extractor: audit</b>\n\n📅 %s\n\nАудит Pack'ов завершён. Проверьте лог: ~/logs/extractor/%s.log" "$DATE" "$DATE")
        send_telegram "$SUMMARY"
        ;;

    *)
        echo "Usage: $0 {inbox-check|audit}"
        exit 1
        ;;
esac
