---
description: DotCore sync-project-rules - дополняет AGENTS.md и правила агентов (additive, без README)
---

Прочитай скилл `sync-project-rules` из установленного dotcore-skills:

- `~/.codex/skills/sync-project-rules/SKILL.md`
- или `skills/sync-project-rules/SKILL.md` в клоне dotcore-skills
- или `.cursor/skills/sync-project-rules/SKILL.md` в проекте

Выполни workflow (SKILL.md), **additive - дополняй, не переписывай**:

1. Scan репозитория (только rules-relevant: команды, deps, структура, существующие правила)
2. Определи агента запуска
3. `AGENTS.md`: нет файла - создай каркас по templates.md; есть - не переписывай, добавь недостающие DotCore-блоки и точечно почини факты, расходящиеся с кодом
4. `.cursor/rules/dotcore-project.mdc`, `CLAUDE.md`, `GEMINI.md` - те, что нужны: создай или дополни, не переписывая авторское
5. Встрой правило README-sync, если его ещё нет

Факты только из кода. README, обложку, бейджи, LoC и LICENSE **не трогай** - это `generate-readme`. Существующие авторские правила и секции сохрани дословно (дополняй, не затирай).

В конце выведи список изменённых файлов.
