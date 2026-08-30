# sepia

Скилл DotCore из monorepo [dotcore-skills](../../README.md): **de-AI writing**. Порт [Nanako0129/sepia](https://github.com/Nanako0129/sepia) (MIT, v0.2.0) под наш каталог и русский регистр.

Художественный текст чинит нарративную архитектуру (StoryScope) до лексики. Профессиональная проза идёт через правила площадки. Четыре операции: **write**, **review** (только диагноз), **refactor** (минимальные правки), **recreate** (переписка с голого списка фактов).

Что добавлено относительно апстрима:

- маршруты для README / AGENTS.md / SKILL.md, коммитов и ответов в чате
- [ru-register.md](references/ru-register.md) - длинное тире, русские маркеры, тон агента
- упаковка как обычный скилл монорепо (без plugin-marketplace апстрима)

Канон метода и reference-файлы проходов - как в исходном репозитории. Атрибуция: [NOTICE.md](NOTICE.md).

## Операции

| Операция | Что делает |
|----------|------------|
| write | Новый текст, домен читается до черновика |
| review | Список дефектов, правок нет |
| refactor | Правка на месте от списка дефектов, глубокий слой первым |
| recreate | Факты в список, затем заново |

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Routing, операции, калибровка |
| [references/narrative-pass.md](references/narrative-pass.md) | Художественное: архитектура |
| [references/discourse-pass.md](references/discourse-pass.md) | Поток абзацев |
| [references/style-pass.md](references/style-pass.md) | Поверхностный стиль |
| [references/professional-pass.md](references/professional-pass.md) | Общий non-fiction слой |
| [references/rubric.md](references/rubric.md) | 30 фич диагноза fiction |
| [references/model-fingerprints.md](references/model-fingerprints.md) | Поправки по моделям |
| [references/ru-register.md](references/ru-register.md) | Русский слой DotCore |
| [references/domains/](references/domains/) | Жанры, включая docs / commits / chat |
| [NOTICE.md](NOTICE.md) | MIT-атрибуция |
| [codex-prompt.md](codex-prompt.md) | `/sepia` для Codex |

## Установка

### Из dotcore-skills (рекомендуется)

```powershell
cd path\to\dotcore-skills
.\scripts\install.ps1 -Skill sepia
.\scripts\install.ps1 -Skill sepia -Agent cursor,claude
```

```bash
./scripts/install.sh sepia
AGENTS=cursor,claude ./scripts/install.sh sepia
```

При разработке: `.\scripts\install.ps1 -Skill sepia -Link`.

Поддерживаемые агенты и пути - [docs/AGENTS_PATHS.md](../../docs/AGENTS_PATHS.md).

### В целевом проекте

```text
your-repo/.cursor/skills/sepia/
```

Полная копия папки (включая `references/`), опционально `.claude/skills/sepia/`.

## Триггеры

«убери ИИ-слог», «humanize», «de-AI», «unslop», «перепиши по-человечески», «чтобы не звучало как нейросеть», `/sepia` (Codex).

## Тест

1. Дай абзац с «безусловно», длинным тире и «в заключение» - операция review: диагноз с цитатами, текста не переписывать.
2. Тот же абзац - refactor: тире и маркеры сняты, факты на месте, объём не вырос.
3. «Напиши релиз-ноты» без номеров PR и метрик - write обязан спросить или оставить TODO, не выдумать цифры.
