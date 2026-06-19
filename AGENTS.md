# AGENTS.md

> Инструкции для AI coding agents в репозитории **dotcore-skills**.

## Профиль

- **Тип:** monorepo Agent Skills ([agentskills.io](https://agentskills.io/specification))
- **Бренд:** DotCore (DotLearn, DotBioSite, DotMathBot, DotTraceIP)
- **Язык документации:** русский

## Структура

```text
dotcore-skills/
├── skills/<name>/     # каждый скилл - отдельная папка с SKILL.md
├── scripts/           # install.ps1, install.sh
├── docs/              # CONTRIBUTING, ADDING_SKILL
└── README.md          # каталог и установка
```

## Правила для агента

- Новый скилл - только в `skills/<kebab-name>/`, имя папки = `name` во frontmatter `SKILL.md`.
- `SKILL.md` < 500 строк; детали - в соседних `.md` или `references/`.
- В `description` frontmatter: что делает + когда применять (ключевые триггеры).
- Не ломай существующие скиллы при добавлении новых.
- После изменения скилла обнови таблицу в корневом `README.md`.

## Сборка и проверки

| Действие | Команда |
|----------|---------|
| Установить все скиллы (Windows) | `.\scripts\install.ps1` |
| Установить все скиллы (Unix) | `./scripts/install.sh` |
| Список агентов | `.\scripts\install.ps1 -ListAgents` |
| Выборочно | `.\scripts\install.ps1 -Agent cursor,agents` |
| Один скилл | `.\scripts\install.ps1 -Skill generate-readme` |
| Скопировать в проект | `.\scripts\sync-to-project.ps1 -Target <path> -AllAgents` |
| Пути агентов | [docs/AGENTS_PATHS.md](docs/AGENTS_PATHS.md) |

## Чего не делать

- Не класть скиллы в корень repo (только `skills/`).
- Не дублировать один скилл под разными именами.
- Не коммитить секреты и локальные пути пользователя в шаблонах.

## Документация

- [README.md](README.md) - каталог скиллов
- [docs/ADDING_SKILL.md](docs/ADDING_SKILL.md) - как добавить новый скилл
- [docs/AGENTS_PATHS.md](docs/AGENTS_PATHS.md) - пути Cursor, Claude, Codex, Gemini, OpenCode, Goose, Roo, Junie, Amp
- [skills/generate-readme/SKILL.md](skills/generate-readme/SKILL.md) - первый скилл
