# Inbox-Check (Проверка inbox)

> Этот промпт выполняется headless (launchd, каждые 3 часа) или вручную.
> Режим: **без одобрения** — только генерация отчёта. Применение — в интерактивной сессии.

## Роль

Ты — Knowledge Extractor в режиме Inbox-Check. Проверь inbox на pending captures, формализуй кандидаты и сохрани отчёт.

## Когда вызывается

- launchd: каждые 3 часа (автоматически)
- Вручную: `extractor.sh inbox-check`

## Алгоритм

### Шаг 1: Проверить inbox

1. Прочитай `~/Github/DS-my-strategy/inbox/captures.md`
2. Найди все pending записи (секции `### ...` с содержимым, без метки `[processed]`)
3. Если pending записей нет → напиши в лог `No pending captures in inbox` и **заверши работу**

### Шаг 2: Прочитать контекст

Для маршрутизации и формализации прочитай:

| Файл | Зачем |
|------|-------|
| Pack-манифесты (`00-pack-manifest.md`) | Bounded context Pack'ов |
| Существующие сущности целевых директорий Pack'ов | Назначение ID, проверка дубликатов |
| `ontology.md` целевых Pack'ов | Согласование терминов |
| `01B-distinctions.md` целевых Pack'ов | Проверка конфликтов |

Pack-репо и их пути:

| Домен | Pack | Путь |
|-------|------|------|
| Платформа, ИТ, ИИ-системы | PACK-digital-platform | `~/Github/PACK-digital-platform/pack/digital-platform/` |
| Созидатель, развитие | PACK-personal | `~/Github/PACK-personal/pack/personal/` |
| Экосистема, клуб | PACK-ecosystem | `~/Github/PACK-ecosystem/pack/ecosystem/` |
| Мастерская (MIM) | PACK-MIM | `~/Github/PACK-MIM/pack/mim/` |

### Шаг 3: Обработать каждый capture

Для каждого pending capture выполни стандартный пайплайн:

**3a. Классификация:**

| Тип | Признак | Код |
|-----|---------|-----|
| Доменная сущность | Компонент, архитектура | `entity` |
| Различение | Пара «A ≠ B» | `distinction` |
| Метод | Способ действия, IPO | `method` |
| Рабочий продукт | Тип артефакта | `wp` |
| Failure mode | Типовая ошибка | `fm` |
| Правило | Ограничение, 1-3 строки | `rule` |

**3b. Маршрутизация:**

Определи Pack по домену (таблица выше) и директорию по типу:

| Тип | Директория |
|-----|-----------|
| `entity` | `02-domain-entities/` |
| `distinction` | `01-domain-contract/01B-distinctions.md` |
| `method` | `03-methods/` |
| `wp` | `04-work-products/` |
| `fm` | `05-failure-modes/` |
| `rule` | `CLAUDE.md` или `memory/` |

**3c. Формализация:**

1. Прочитай целевую директорию → найди существующие файлы → назначь ID (max + 1)
2. Имя файла: `{PREFIX}.{TYPE}.{NNN}-{slug}.md`
3. Привяжи к родительскому понятию SPF (прочитай `SPF/ontology.md` секция 2)
4. Создай содержимое по шаблону (шаблоны — в `prompts/session-close.md`, шаг 4d)

**3d. Валидация:**

- [ ] Есть frontmatter?
- [ ] Правильная директория?
- [ ] Нет дубликата?
- [ ] Соответствует bounded context?
- [ ] Не governance-контент?
- [ ] Онтология: термины согласованы?

### Шаг 4: Сгенерировать Extraction Report

Создай файл отчёта: `~/Github/DS-my-strategy/inbox/extraction-reports/{YYYY-MM-DD}-inbox-check.md`

Если файл с таким именем уже существует (повторный запуск за день), добавь суффикс: `{YYYY-MM-DD}-inbox-check-2.md`.

**Формат отчёта:**

```markdown
---
type: extraction-report
source: inbox-check
date: {YYYY-MM-DD}
status: pending-review
---

# Extraction Report (Inbox-Check)

**Дата:** {YYYY-MM-DD}
**Источник:** DS-my-strategy/inbox/captures.md
**Обработано captures:** N

---

## Кандидат #1

**Источник capture:** {заголовок из captures.md}
**Сырой текст:** «{цитата из capture}»
**Классификация:** {тип}

**Куда записать:**
- **Репо:** {~/Github/PACK-digital-platform}
- **Файл:** {pack/digital-platform/05-failure-modes/DP.FM.003-slug.md}
- **Действие:** создать файл / добавить секцию / добавить строки

**Совместимость:**
- **Результат:** {совместим / уточняет / противоречит / дубликат}
- **Проверено:** {список файлов}
- **Конфликт:** {нет / описание}

**Готовый текст (ready-to-commit):**

~~~markdown
{ПОЛНЫЙ текст файла с frontmatter — ничего не пропущено}
~~~

**Вердикт:** accept / reject / defer
**Обоснование:** {почему}

---

## Кандидат #2
...

---

## Сводка

| Метрика | Значение |
|---------|----------|
| Captures обработано | N |
| Всего кандидатов | N |
| Accept | N |
| Reject | N |
| Defer | N |
```

### Шаг 5: Пометить обработанные captures

В `DS-my-strategy/inbox/captures.md` — для каждого обработанного capture добавь метку `[processed YYYY-MM-DD]` к заголовку:

**Было:** `### Паттерн X`
**Стало:** `### Паттерн X [processed 2026-02-12]`

Это предотвращает повторную обработку при следующем inbox-check.

### Шаг 6: Закоммитить

1. Закоммить `DS-my-strategy/inbox/extraction-reports/{date}-inbox-check.md` (новый отчёт)
2. Закоммить `DS-my-strategy/inbox/captures.md` (метки processed)
3. Запушить DS-my-strategy

**Сообщение коммита:** `inbox-check: N captures → extraction report {date}`

## Что НЕ делать

- **НЕ записывай в Pack** — только генерируй отчёт. Запись в Pack = только в интерактивной сессии после одобрения
- Не удаляй captures из captures.md — только помечай [processed]
- Не создавай файлы без frontmatter
- Не экстрагируй governance-контент (планы, статусы, дедлайны)
- Не путай bounded context Pack'ов
- Не дублируй существующие сущности

## Применение отчёта (отдельная сессия)

> Когда пользователь в интерактивной сессии говорит «review extraction report» или «apply KE report»:

1. Прочитай последний отчёт из `DS-my-strategy/inbox/extraction-reports/`
2. Покажи каждый кандидат пользователю
3. Пользователь одобряет (accept), отклоняет (reject) или откладывает (defer)
4. Для accept — создай файл **ровно по тексту из «Готовый текст»**, закоммить в целевой Pack
5. Для defer — оставь в отчёте, обработай в следующем цикле
6. Обнови статус отчёта: `status: applied` (в frontmatter)
