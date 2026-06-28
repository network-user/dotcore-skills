# AGENTS.md

> Инструкции для AI coding agents. Человеческий обзор - в [README.md](README.md).
> Перегенерировано скиллом `generate-readme`. Источник правды - код репозитория.

## Профиль проекта

- **Тип:** monorepo-tool (каталог Agent Skills + установщики)
- **Аудитория:** internal (экосистема DotCore)
- **Runtime:** PowerShell 5.1+ / Bash + Python 3
- **Монорепо:** да (`skills/<name>/`)
- **Сборка/пакетный менеджер:** нет; контент - markdown, логика - скрипты

## Быстрый старт

```powershell
.\scripts\install.ps1 -ListAgents     # ID агентов и пути
.\scripts\install.ps1 -Link           # установить все скиллы junction'ами (dev)
```

```bash
AGENTS=cursor,claude,agents ./scripts/install.sh   # нужен Python 3
```

## Сборка и проверки

| Действие | Команда |
|----------|---------|
| Установка (Windows) | `.\scripts\install.ps1` |
| Установка (Unix) | `./scripts/install.sh` |
| Выборочно по агентам | `.\scripts\install.ps1 -Agent cursor,claude` / `AGENTS=… ./scripts/install.sh` |
| Один скилл | `.\scripts\install.ps1 -Skill generate-readme` / `./scripts/install.sh generate-readme` |
| В проект | `.\scripts\sync-to-project.ps1 -Target <path> -AllAgents` / `ALL_AGENTS=1 ./scripts/sync-to-project.sh <path>` |
| Список агентов | `.\scripts\install.ps1 -ListAgents` / `./scripts/install.sh --list-agents` |
| Тесты | нет; CI валидирует frontmatter (`.github/workflows/validate-skills.yml`) |
| Lint / build | — |

Команды - только из `scripts/` и CI. Конфиг путей: `scripts/agents.targets.json`.

## Структура репозитория

```text
dotcore-skills/
├── skills/<name>/          # скилл = папка с SKILL.md + references; _* не ставятся
├── scripts/
│   ├── agents.targets.json # user/project пути всех агентов - источник правды
│   ├── install.{ps1,sh}    # user-level установка
│   └── sync-to-project.{ps1,sh}  # копия в .<agent>/skills/ репозитория
├── docs/                   # ADDING_SKILL.md, AGENTS_PATHS.md
└── .github/workflows/validate-skills.yml
```

## Соглашения

- **Язык документации:** русский. README и AGENTS.md - один язык; SKILL.md - как в скилле.
- **Скилл:** только в `skills/<kebab-name>/`; имя папки **обязано** совпадать с `name` во frontmatter `SKILL.md` (проверяет CI).
- **`SKILL.md`:** < 500 строк; детали - в соседних `.md`, ссылки одним уровнем `[file.md](file.md)`.
- **`description` frontmatter:** что делает + когда применять (триггеры), max 1024 символа.
- **Пути агентов:** добавляй/меняй только в `agents.targets.json`; оба установщика читают его, дублировать в коде нельзя.
- **`_`-папки** (`_template`) - не контент: пропускаются установщиками и CI.
- **Bash-установщики** парсят JSON через `python3` - не вводи зависимость от `jq`.

## Что делать агенту

- Перед правками прочитай затронутые файлы и `agents.targets.json`.
- Меняешь скилл - обнови таблицу скиллов в `README.md`.
- Добавляешь агента - строка в `agents.targets.json` + строка в `docs/AGENTS_PATHS.md`; проверь оба установщика.
- Правки PowerShell и bash держи согласованными (одинаковое поведение флагов).
- После изменений прогони `.\scripts\install.ps1 -ListAgents` / `--list-agents` как smoke-проверку конфига.
- **README-sync:** при глобальных изменениях (новый скилл, новые флаги/команды установщиков, новый агент, смена структуры) обнови README и AGENTS.md скиллом `generate-readme`, включая пересчёт LoC. Мелкие правки README не трогают.
- Не латай разметку README вручную - перегенерируй скиллом.
- Минимальный diff - не рефактори несвязанное.

## Чего не делать

- Не класть скиллы в корень репозитория (только `skills/`).
- Не дублировать один скилл под разными именами.
- Не хардкодить пути агентов в скриптах в обход `agents.targets.json`.
- Не выдумывать команды, флаги, пути, зависимости.
- Не менять `LICENSE` и текст лицензии без явного запроса пользователя.
- Не коммитить секреты, токены, machine-specific пути пользователя в скиллах и шаблонах.
- Не удалять маркеры `<!-- loc:start -->` / `<!-- loc:end -->` в README.

## Документация

- [README.md](README.md) - установка, команды, стек, архитектура
- [docs/ADDING_SKILL.md](docs/ADDING_SKILL.md) - как добавить новый скилл
- [docs/AGENTS_PATHS.md](docs/AGENTS_PATHS.md) - пути всех поддерживаемых агентов
- [skills/generate-readme/SKILL.md](skills/generate-readme/SKILL.md) - README + правила (делегирует sync-project-rules)
- [skills/sync-project-rules/SKILL.md](skills/sync-project-rules/SKILL.md) - только правила проекта (AGENTS.md + rule-файлы)
- [skills/pre-deploy-audit/SKILL.md](skills/pre-deploy-audit/SKILL.md) - аудит перед деплоем/публикацией: утечки + код, 3 уровня, бейдж на PASS

## DotCore

Проект следует стандарту DotCore: плоский технический README, SVG-обложка DotBioSite, LoC-бейдж. При запросе «обнови README» используй скилл `generate-readme`.
