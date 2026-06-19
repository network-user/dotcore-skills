# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [1.1.0] - 2026-06-19

### Added

- Поддержка 10 coding-агентов: Cursor, Claude Code, Codex, Gemini CLI, OpenCode, Goose, Roo Code, Junie, Amp, universal `.agents/`
- `scripts/agents.targets.json` - единый конфиг user/project путей
- `docs/AGENTS_PATHS.md` - таблица путей и примеры
- `install.ps1 -Agent`, `-ListAgents`; `sync-to-project -AllAgents`, `-Agent`

### Changed

- `install.sh` / `sync-to-project.sh` читают `agents.targets.json` (Python 3)
- `sync-to-project`: `-ClaudeMirror` заменён на `-AllAgents` / `-Agent`

## [1.0.0] - 2026-06-19

### Added

- Monorepo `dotcore-skills` для Agent Skills экосистемы DotCore
- Скилл `generate-readme` v2: README DotCore + `AGENTS.md` + `.cursor/rules/dotcore-project.mdc` + `CLAUDE.md`
- Классификация проекта (`project-classify.md`), аудит 1-10 (`audit.md`)
- `scripts/install.ps1`, `scripts/install.sh` - установка в Cursor / Claude Code / Codex
- `scripts/sync-to-project.ps1`, `scripts/sync-to-project.sh` - копия скиллов в `.cursor/skills/` проекта
- `skills/_template/` - заготовка нового скилла
- CI `.github/workflows/validate-skills.yml` - проверка frontmatter
- `docs/ADDING_SKILL.md`, корневой `AGENTS.md`

[1.1.0]: https://github.com/network-user/dotcore-skills/releases/tag/v1.1.0
[1.0.0]: https://github.com/network-user/dotcore-skills/releases/tag/v1.0.0
