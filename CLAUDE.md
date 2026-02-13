# Инструкции для DS-extractor-agent

> **Тип:** downstream-instrument
> **Source-of-truth:** `DP.AISYS.013` (PACK-digital-platform)
> **Upstream:** PACK-digital-platform → SPF → FPF

## Назначение

Knowledge Extractor — ИИ-система, которая трансформирует информацию в формализованные Pack-совместимые сущности.

## Процессы

Все процессы описаны в `PROCESSES.md` этого репо.
Полная карта триггеров и архитектура вызовов → `DP.AISYS.013` § 4.0.

| Процесс | Промпт | Статус |
|---------|--------|--------|
| Session-Close Extraction | `prompts/session-close.md` | Готов к тесту |
| On-Demand Extraction | `prompts/on-demand.md` | Готов к тесту |
| Bulk Extraction | `prompts/bulk-extraction.md` | Готов к тесту |
| Cross-Repo Sync | `prompts/cross-repo-sync.md` | Готов к тесту |
| Knowledge Audit | `prompts/knowledge-audit.md` | Готов к тесту |
| Inbox-Check | `prompts/inbox-check.md` | Работает (launchd 3h) |
| Ontology Sync | `prompts/ontology-sync.md` | Готов к тесту |

> **Исключение:** Мелкие правила (1-3 строки) → Claude пишет напрямую, без KE. Все остальное знание → только через KE.

## Правила

1. **Human-in-the-loop:** KE всегда предлагает, никогда не пишет без одобрения
2. **Формализация обязательна:** информация → экстракция → знание (нарушение = FM.001)
3. **Именование файлов:** `{PREFIX}.{TYPE}.{NNN}-{slug}.md` (детали в PROCESSES.md)
4. **Один пайплайн:** все процессы используют classify → route → formalize → validate
5. **Онтологическое соответствие (SPF.SPEC.002):** При экстракции — прочитай `ontology.md` целевого Pack'а. Каждый кандидат проверяется на:
   - **Соответствие:** тип сущности и термины согласованы с онтологией
   - **Развитие:** если кандидат вводит новый тип, термин или связь — предложи обновление онтологии (отдельным кандидатом в отчёте)
   - **Противоречие:** если кандидат противоречит онтологии — предупреди и предложи варианты разрешения (изменить кандидат, обновить онтологию, или reject)
6. **Владелец онтологии — Экстрактор:** Онтологию (`ontology.md`) на любом уровне изменяет **только** Knowledge Extractor. Пользователь предлагает изменения; Экстрактор формализует, валидирует привязку к SPF-понятиям и применяет
7. **Привязка к родительскому понятию (SPF.SPEC.002 § 1.2):** Каждое доменное понятие Pack'а **обязано** иметь родительское понятие из базовой онтологии SPF (U.* из SPF.SPEC.002 секция 2). При экстракции нового понятия — определи, к какому U.* оно относится, и укажи в колонке «FPF-понятие» или «Родительское понятие (SPF)»
8. **Кросс-уровневая связь (SPF.SPEC.002 § 5.9):** Понятия между уровнями связаны, не пересекаются:
   - **SPF наследует FPF** — не переопределяет, а фиксирует U.* понятия
   - **Pack расширяет SPF** — доменные понятия привязаны к U.*, собственные типы зарегистрированы
   - **Downstream ссылается на Pack + вводит реализационные** — каждое привязано к Pack-понятию
   - При изменении верхнего уровня → проверить и обновить нижние (каскадирование)
9. **Downstream ontology (SPF.SPEC.002 § 4.3):** При работе с downstream-репо:
   - **Читай** `ontology.md` downstream — проверяй актуальность ссылок на Pack
   - **Собственные понятия downstream** допустимы, но каждое привязано к Pack-понятию
   - **Тест доменности:** Новое понятие в downstream используется в других downstream? Да → предложи добавить в Pack. Нет → оставь в downstream с привязкой к Pack
   - При изменении Pack ontology → обновить downstream ontology (через cross-repo-sync)

## Связанные документы (Pack)

- `DP.AISYS.013` — паспорт ИИ-системы
- `DP.METHOD.001` — метод экстракции знаний
- `DP.WP.001` — отчёт экстракции
- `DP.FM.001` — failure mode: информация как знание

## Автоматизация

| Скрипт | Назначение |
|--------|-----------|
| `scripts/extractor.sh` | Основной runner (аналог strategist.sh) |
| `scripts/launchd/com.extractor.inbox-check.plist` | launchd: inbox-check каждые 3h |

**Уведомления:** Делегированы Синхронизатору (`DS-synchronizer/scripts/notify.sh extractor <scenario>`).

**Workspace:** `~/Github` (root — доступ ко всем Pack-репо).
**Логи:** `~/logs/extractor/`.
**Отчёты:** `DS-my-strategy/inbox/extraction-reports/`.

**Установка launchd:**
```bash
chmod +x scripts/extractor.sh
cp scripts/launchd/com.extractor.inbox-check.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.extractor.inbox-check.plist
```

## Конвенция именования агентов

Репозитории ИИ-систем: `DS-{slug}` (пример: `DS-strategist`, `DS-extractor-agent`).
Привязка к Pack через `source-of-truth` в CLAUDE.md, не через имя репо.

## SOTA: AI-Accelerated Ontology Engineering (DP.SOTA.007)

> Экстрактор — реализация AI-Accelerated OE: LLM делает first pass, человек валидирует.

- detect = ontology gap detection
- classify = concept classification
- route = ontology placement
- formalize = concept formalization with frontmatter
- validate = consistency check (F-G-R trust model)
- При bulk extraction: LLM-assisted draft → human review → accept/reject

---

*Последнее обновление: 2026-02-13*
