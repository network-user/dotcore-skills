---
name: sepia
description: >-
  Делает текст человеческим: чинит нарративную архитектуру художественного
  текста (StoryScope, arXiv:2604.03136) и проводит профессиональную прозу через
  правила жанра. Четыре операции: write, review (диагноз без правок), refactor
  (минимальные правки), recreate (полная переписка). В контексте DotCore -
  README, AGENTS.md, SKILL.md, коммиты, ответы в чате, PR/issue, релиз-ноты.
  Use when просят humanize, de-AI, unslop, убрать ИИ-слог, переписать «чтобы не
  звучало как нейросеть», или когда выход не должен читаться как машинный.
---

# Sepia - de-AI writing

Порт [Nanako0129/sepia](https://github.com/Nanako0129/sepia) (MIT) под DotCore. Канон метода не менялся: сначала архитектура, потом дискурс, стиль в конце. Поверх - русский регистр и жанры, которые мы пишем каждый день.

Каждое правило стоит на измеренном разрыве человек/ИИ. В художественном тексте классификатор только по **нарративной структуре** ловит ИИ с 93.2% macro-F1, правка лексики почти ничего не даёт. В профессиональной прозе другие маркеры: вода, отсутствие позиции, chatbot-хвосты, чужой регистр, штампованная вёрстка. Сначала маршрут, потом операция.

## Когда применять

- «убери ИИ-слог», «humanize», «de-AI», «unslop», «перепиши по-человечески»
- черновик звучит как нейросеть: симметрия секций, похвала в начале, «в заключение»
- пишем или правим README / AGENTS.md / SKILL.md / релиз-ноты / PR-ответ / коммит
- ответ агента в чате не должен читаться как шаблон

Не применять на код, конфиги, команды, цитаты и verbatim-фрагменты пользователя.

## Routing

| Тип текста | Читать по порядку |
|---|---|
| Художественное / истории / нарративное эссе | [narrative-pass.md](references/narrative-pass.md) → [discourse-pass.md](references/discourse-pass.md) → [style-pass.md](references/style-pass.md); диагноз [rubric.md](references/rubric.md) |
| README, AGENTS.md, SKILL.md, docs DotCore | [professional-pass.md](references/professional-pass.md) + [docs.md](references/domains/docs.md) + [ru-register.md](references/ru-register.md) |
| Сообщения коммитов | [professional-pass.md](references/professional-pass.md) + [commits.md](references/domains/commits.md) |
| Ответы в чате / пояснения агента | [professional-pass.md](references/professional-pass.md) + [chat.md](references/domains/chat.md) + [ru-register.md](references/ru-register.md) |
| Релиз-ноты, changelog, анонсы | [professional-pass.md](references/professional-pass.md) + [release-notes.md](references/domains/release-notes.md) |
| Ответы в PR/issue, review-комментарии | [professional-pass.md](references/professional-pass.md) + [dev-replies.md](references/domains/dev-replies.md) |
| Postmortem / RCA | [professional-pass.md](references/professional-pass.md) + [postmortems.md](references/domains/postmortems.md) |
| Тикеты, work orders, баг-репорты | [professional-pass.md](references/professional-pass.md) + [tickets.md](references/domains/tickets.md) |
| Статьи, блог, туториалы | [professional-pass.md](references/professional-pass.md) + [tech-articles.md](references/domains/tech-articles.md) + [discourse-pass.md](references/discourse-pass.md) §1–3 |
| Любая другая проза | [professional-pass.md](references/professional-pass.md) + [style-pass.md](references/style-pass.md) + [ru-register.md](references/ru-register.md) |

Каждый non-fiction маршрут заканчивается сканом лексики/синтаксиса в [style-pass.md](references/style-pass.md) §2–3 (таблицу fiction-slop пропускать) и проходом [ru-register.md](references/ru-register.md), если текст на русском. Длинная профессиональная проза берёт весь style pass. Если известна модель-источник - добавь [model-fingerprints.md](references/model-fingerprints.md) как prior.

## Operations

Любой запрос сводится к одной из четырёх операций:

| Операция | Контракт |
|---|---|
| **write** | Новый текст. Сначала доменный файл - архитектура и регистр дешевле выбрать до черновика, чем чинить потом. Для художественного - Workflow A ниже. |
| **review** | Только диагноз, без правок. Список дефектов (художественное: отчёт по rubric; профессиональное: чеклист с цитатами) и стоп. Ничего не применять, пока не попросят. |
| **refactor** | Минимальная правка на месте: структура, голос, смысл те же. Два этапа: полный список дефектов, затем фикс по одному, с самого глубокого слоя. Replace/delete важнее insert (измеренное соотношение редактора 74/18/8). |
| **recreate** | Полная переписка. Выписать факты, тезисы и намерение в голый список; проверить, что ничего не выдумано; писать заново по правилам домена. Когда дефекты структурные и текст короткий - дешевле собрать заново, чем оперировать. |

Двухэтапный протокол для refactor/recreate обязателен: парафраз без списка дефектов делает отпечаток ИИ *заметнее* (измерено на экспертных детекторах).

Не задана операция - по умолчанию **refactor**, если есть исходный текст; **write**, если просят написать с нуля.

## Fiction workflows

**A - новый текст:** (1) premise, жанр, длина - жанр задаёт калибровку; (2) заполнить architecture sheet в [narrative-pass.md](references/narrative-pass.md); (3) выбрать 3–5 human-leaning ходов + один rarity move; (4) outline, проверки outline/QUD в [discourse-pass.md](references/discourse-pass.md) и echo test в narrative-pass §2; (5) черновик; (6) самодиагноз по [rubric.md](references/rubric.md), одна группа за проход; (7) style pass последним.

**B - правка существующего:** (1) полный диагноз (rubric → discourse → style), без правок; (2) triage - архитектурные дефекты требуют хирургии на уровне сцен, скажи насколько глубоко до того, как резать; (3) чинить с самого глубокого; (4) verify: пересчитать затронутые группы rubric, прочитать ключевые куски вслух, echo-test на любой добавленный твист.

## Калибровка

| Принцип | Смысл |
|---|---|
| Целиться в полосу, не в противоположный полюс | Человеческие значения умеренные (хронологический разрыв 2.4/5, не 5). Инверсия каждого маркера ИИ даёт новый отпечаток. В профессиональной прозе то же: попасть в регистр площадки, не свалиться в нарочитую разговорность. |
| Выбирать, не копить | Художественное: 3–5 ходов на историю, под premise, разные от работы к работе. Профессиональное: чинить то, что реально флагнул чеклист, и ничего сверх. |
| Оставлять слабину | Обычные предложения, недожатая мысль, плоский абзац. Не шлифовать каждую поверхность. |

## Жёсткие ограничения

- **Не выдумывать конкретику.** Художественное: интертекст, бренды, места - только реальные и верные. Профессиональное: версии, числа, timestamps, бенчмарки, цитаты - из фактического изменения/инцидента/данных. Нет факта - спроси или оставь явный TODO. Уверенная ложь сама по себе топ-маркер.
- **Удаление важнее добавления** (74% replace / 18% delete / 8% insert). Единственная аддитивная правка - настоящая конкретика.
- **Голос автора и корпус площадки.** Сначала привычки из образцов пользователя или свежих артефактов репозитория; править *к этому* профилю. Манеру, которую человек реально использует, не вычищать.
- **Цитаты и quoted material не нормализовать.**
- **Whitelist до флага.** [style-pass.md](references/style-pass.md) §7, [professional-pass.md](references/professional-pass.md) последний раздел: чистая грамматика, формальный тон на формальной площадке, привычные шаблоны (Keep a Changelog, Conventional Commits) - не улика.
- **Русский DotCore.** Длинное тире не использовать (короткое `-` или перестроить фразу). Это жёстче, чем whitelist исходного sepia про одиночный em-dash. Маркеры из [ru-register.md](references/ru-register.md) считаются кластером, не одиночным попаданием - кроме длинного тире: его вычищать всегда.

## Workflow

1. **Route** - тип текста и операция (таблица выше). Зафиксируй, какие файлы читаешь.
2. **Venue** - 2–3 свежих человеческих образца той же площадки (прошлые README, ответы мейнтейнера, последние коммиты). Нет корпуса - baseline доменного файла.
3. **Load** - прочитай маршрутные файлы *до* черновика или правок.
4. **Act** - write / review / refactor / recreate по контракту операции.
5. **Self-check** - чеклист ниже. На русском - ещё раз [ru-register.md](references/ru-register.md).

## Self-check

- [ ] Маршрут и операция выбраны, доменный файл прочитан до письма
- [ ] Review остановился на диагнозе; refactor шёл от списка дефектов, не от парафраза
- [ ] Факты не выдуманы; цитаты не приглажены
- [ ] Нет кластера slop из professional-pass / style-pass
- [ ] Русский: нет длинного тире, нет маркеров из ru-register, нет похвалы в зачине
- [ ] Калибровка: чинили флаги, не инвертировали каждый маркер

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Routing, операции, калибровка |
| [ru-register.md](references/ru-register.md) | Русский слой: тире, маркеры, тон чата |
| [docs.md](references/domains/docs.md) | README / AGENTS.md / SKILL.md |
| [commits.md](references/domains/commits.md) | Сообщения коммитов |
| [chat.md](references/domains/chat.md) | Ответы агента в чате |
| [NOTICE.md](NOTICE.md) | MIT-атрибуция исходного sepia |
| [codex-prompt.md](codex-prompt.md) | `/sepia` для Codex |
