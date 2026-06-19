# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

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

[1.0.0]: https://github.com/network-user/dotcore-skills/releases/tag/v1.0.0
