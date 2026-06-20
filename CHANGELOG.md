# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- `.cursor/rules/dotcore-project.mdc`, `CLAUDE.md` - правила проекта для агентов
- `skills/generate-readme/license.md` - политика строгой лицензии в скилле

### Changed

- README перегенерирован по стандарту DotCore: inline SVG-обложка, flat-бейджи, LoC-бейдж, ASCII-архитектура
- `AGENTS.md` перегенерирован (профиль monorepo-tool, команды из `scripts/`)
- LoC-бейдж перенесён в строку header (4-м), пересчитан честно: 582
- Скилл `generate-readme`: LoC в header, строгая лицензия (LICENSE + футер), файл правил агента запуска, правило README-sync на глобальные изменения

### Removed

- Лицензия MIT заменена на строгий All Rights Reserved (проприетарная, все права у автора)

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
