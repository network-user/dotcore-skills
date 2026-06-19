# Пути установки Agent Skills

DotCore-skills следует [Agent Skills spec](https://agentskills.io/specification) и ставит каждый скилл как папку `<name>/SKILL.md`.

Канонический конфиг путей: [scripts/agents.targets.json](../scripts/agents.targets.json).

## User-level (глобально)

| ID | Агент | Каталог | Примечание |
|----|-------|---------|------------|
| `cursor` | Cursor | `~/.cursor/skills/<name>/` | [Cursor Skills](https://cursor.com/docs/skills) |
| `claude` | Claude Code | `~/.claude/skills/<name>/` | |
| `codex` | OpenAI Codex | `~/.codex/skills/<name>/` | + `~/.codex/prompts/<name>.md` если есть `codex-prompt.md` |
| `gemini` | Gemini CLI | `~/.gemini/skills/<name>/` | также читает `.agents/skills/` |
| `agents` | Universal | `~/.agents/skills/<name>/` | Gemini, OpenCode, Amp и др. |
| `opencode` | OpenCode | `~/.config/opencode/skills/<name>/` | |
| `goose` | Goose | `~/.config/goose/skills/<name>/` | |
| `roo` | Roo Code | `~/.roo/skills/<name>/` | |
| `junie` | Junie | `~/.junie/skills/<name>/` | |
| `amp` | Amp | `~/.config/agents/skills/<name>/` | |

Windows: `~` = `%USERPROFILE%`.

## Project-level (в репозитории)

| ID | Агент | Каталог |
|----|-------|---------|
| `cursor` | Cursor | `.cursor/skills/<name>/` |
| `claude` | Claude Code | `.claude/skills/<name>/` |
| `codex` | Codex | `.codex/skills/<name>/` |
| `agents` | Universal | `.agents/skills/<name>/` |
| `gemini` | Gemini CLI | `.gemini/skills/<name>/` |
| `opencode` | OpenCode | `.opencode/skills/<name>/` |
| `goose` | Goose | `.goose/skills/<name>/` |
| `roo` | Roo Code | `.roo/skills/<name>/` |
| `junie` | Junie | `.junie/skills/<name>/` |

## Установка

```powershell
# все агенты
.\scripts\install.ps1

# выборочно
.\scripts\install.ps1 -Agent cursor,claude,agents

# список ID
.\scripts\install.ps1 -ListAgents

# в проект - все project-level пути
.\scripts\sync-to-project.ps1 -Target C:\path\to\repo -AllAgents -Link
```

```bash
./scripts/install.sh
AGENTS=cursor,claude,agents ./scripts/install.sh
./scripts/install.sh --list-agents
ALL_AGENTS=1 ./scripts/sync-to-project.sh /path/to/repo
```

## Рекомендация для нескольких агентов

1. **Разработка скиллов:** `.\scripts\install.ps1 -Link` - junction/symlink на monorepo.
2. **Минимум для совместимости:** установи в `agents` + свой основной агент (`cursor` или `claude`).
3. **Проект self-contained:** `sync-to-project -AllAgents` или только `cursor` + `agents`.

## Другие совместимые клиенты

Любой клиент со [skills.sh](https://skills.sh) / agentskills.io обычно ищет:

- нативный каталог клиента (см. таблицу)
- `~/.agents/skills/` или `.agents/skills/` (кросс-клиент)

Добавление нового агента: PR с строкой в `agents.targets.json` + обновление этой таблицы.
