# Changelog

Формат основан на [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added

- Скилл `pre-deploy-audit` - аудит репозитория перед деплоем/публикацией: два трека (утечки - секреты/ключи/PII/история git; код - инъекции, eval/exec, десериализация, authz, крипто), три уровня глубины, severity-гейт (Critical/High = провал); на PASS - отчёт в `docs/audit/` (снимок по дате + `latest.md`) и кликабельный на него бейдж аудита в README (блок `<!-- audit:start/end -->`)
- Скилл `sync-project-rules` - лёгкая регенерация только правил проекта (`AGENTS.md` + `.cursor/rules/dotcore-project.mdc` + `CLAUDE.md` + `GEMINI.md`), без README, обложки, LoC и аудита
- `.cursor/rules/dotcore-project.mdc`, `CLAUDE.md` - правила проекта для агентов
- `skills/generate-readme/license.md` - политика строгой лицензии в скилле
- `docs/audit/` - отчёты `pre-deploy-audit`: снимки по схеме `{дата}-{кодовое-слово}.md` (несколько прогонов за день не затирают друг друга) + `latest.md`. Полный аудит репозитория 2026-07-01: `first-pass` → PASSED WITH WARNINGS (2 Medium path-traversal), после фикса `iron-gate` → PASSED
- CI: шаг проверки, что все ссылки бейджа аудита в README ведут на существующие отчёты; `permissions: contents: read` и пиннинг `actions/checkout` по SHA в `validate-skills.yml`

### Security

- Установщики (`install.ps1`/`install.sh`/`sync-to-project.ps1`/`sync-to-project.sh`): закрыт path-traversal через поле `dir` из `agents.targets.json` и через имя скилла из CLI - нормализация целевого пути + строгая проверка вхождения в границу (`$HOME`/`$TargetRoot`) до любого рекурсивного удаления, whitelist имени скилла `^[A-Za-z0-9._-]+$`
- `.gitignore` расширен паттернами секретов (`.env*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `secrets*.json`, `credentials*.json`, `service-account*.json`)

### Changed

- `generate-readme` сохраняет блок бейджей аудита `<!-- audit:start/end -->` при перегенерации README (интеграция с `pre-deploy-audit`: переносит чужой блок дословно, не выдумывает и не правит)
- `generate-readme` делегирует правила проекта подскиллу `sync-project-rules` (шаг 5); `project-rules.md` оставлен зеркалом-fallback
- README перегенерирован по стандарту DotCore: inline SVG-обложка, flat-бейджи, LoC-бейдж, ASCII-архитектура
- `AGENTS.md` перегенерирован (профиль monorepo-tool, команды из `scripts/`)
- LoC-бейдж перенесён в строку header (4-м), пересчитан честно: 582
- GitHub-first: бейджи header и стек обёрнуты в `<p>` (один ряд на GitHub), обложка - `docs/cover.svg` + `<img>` вместо inline `<svg>`
- Скилл `generate-readme`: LoC в header (`<p>`), GitHub-first обложка/бейджи, строгая лицензия (LICENSE + футер), файл правил агента запуска, правило README-sync на глобальные изменения

### Added (docs)

- `docs/cover.svg` - SVG-обложка DotBioSite (terminal-глиф)

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
