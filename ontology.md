# Онтология: Knowledge Extractor

> **Тип:** Downstream-instrument
> **Upstream:** spf-digital-platform-pack
> **Базовая онтология:** [SPF/ontology.md](../SPF/ontology.md) (SPF.SPEC.002)
>
> Downstream ссылается на понятия Pack'ов и SPF. Новых онтологических понятий не вводит (SPF.SPEC.002 § 4.3).

---

## 1. Upstream-зависимости

| Уровень | Источник | Что используется |
|---------|----------|------------------|
| Pack | [spf-digital-platform-pack](../spf-digital-platform-pack/) | Паспорт ИИ-системы, метод экстракции, рабочий продукт, failure mode |
| SPF | [SPF/ontology.md](../SPF/ontology.md) | Базовая онтология (U.*), виды сущностей, правила наследования |
| FPF | Через SPF | Мета-онтология |

---

## 2. Используемые понятия из Pack

| Понятие | ID в Pack | FPF-понятие | Как используется |
|---------|-----------|-------------|------------------|
| ИИ-система | DP.AISYS.013 | U.System + U.Capability | Паспорт Knowledge Extractor |
| Метод экстракции знаний | DP.METHOD.001 | U.Method | Алгоритм classify → route → formalize → validate |
| Отчёт экстракции | DP.WP.001 | U.Work + U.Episteme | Extraction Report (результат session-close) |
| FM: Информация как знание | DP.FM.001 | — | Обнаружение нарушения: информация записана без формализации |
| Экстракция знаний | — | U.Method | Процесс трансформации информации в Pack-сущности |

---

## 3. Типы сущностей, с которыми работает Экстрактор

> Экстрактор создаёт сущности этих типов в целевых Pack'ах.
> Типы определены в SPF (SPF.SPEC.002 § 3), Экстрактор только использует их.

| Код | Вид | SPF-понятие | Что создаёт Экстрактор |
|-----|-----|-------------|------------------------|
| `M` | Метод | U.Method | Файл в `03-methods/` |
| `WP` | Рабочий продукт | U.Work + U.Episteme | Файл в `04-work-products/` |
| `FM` | Режим ошибки | — | Файл в `05-failure-modes/` |
| `D` | Различение | A.7 Strict Distinction | Секция в `01B-distinctions.md` |
| `CHR` | Характеристика | U.Characteristic | Файл в `06-characteristics/` |
| `SOTA` | SoTA-аннотация | — | Файл в `08-sota/` |

---

## 4. Терминология реализации

| Термин в реализации | Понятие Pack/SPF | Описание |
|---------------------|------------------|----------|
| Кандидат | — | Единица знания, обнаруженная в сессии, до валидации |
| Extraction Report | DP.WP.001 | Структурированный отчёт со списком кандидатов |
| Маршрутизация | — | Определение целевого Pack'а и директории для кандидата |
| Формализация | — | Создание файла по шаблону SPF с frontmatter и привязкой к U.* |
| Валидация | — | Проверка: frontmatter, тип, дубликат, bounded context, онтология |
| Совместимость | — | Результат проверки кандидата vs существующее знание |

---

## 5. Связанные документы

- [DP.AISYS.013](../spf-digital-platform-pack/pack/digital-platform/02-domain-entities/DP.AISYS.013-knowledge-extractor/) — паспорт ИИ-системы
- [DP.METHOD.001](../spf-digital-platform-pack/pack/digital-platform/03-methods/DP.METHOD.001-knowledge-extraction.md) — метод экстракции
- [SPF/ontology.md](../SPF/ontology.md) — базовая онтология (SPF.SPEC.002)
