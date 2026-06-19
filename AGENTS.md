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
| Один скилл | `.\scripts\install.ps1 -Skill generate-readme` |
| Скопировать в проект | `.\scripts\sync-to-project.ps1 -Target <path>` |
| Проверка frontmatter | `.github/workflows/validate-skills.yml` |

## Чего не делать

- Не класть скиллы в корень repo (только `skills/`).
- Не дублировать один скилл под разными именами.
- Не коммитить секреты и локальные пути пользователя в шаблонах.

## Документация

- [README.md](README.md) - каталог скиллов
- [docs/ADDING_SKILL.md](docs/ADDING_SKILL.md) - как добавить новый скилл
- [skills/generate-readme/SKILL.md](skills/generate-readme/SKILL.md) - первый скилл
