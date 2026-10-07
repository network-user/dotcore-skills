---
description: DotCore generate-readme - README + AGENTS.md + правила проекта
---

Прочитай скилл `generate-readme` из установленного dotcore-skills:

- `~/.codex/skills/generate-readme/SKILL.md`
- или `skills/generate-readme/SKILL.md` в клоне dotcore-skills
- или `.cursor/skills/generate-readme/SKILL.md` в проекте

Выполни полный workflow (SKILL.md):

1. Scan репозитория
2. Classify (project-classify.md), включая walkthrough из depth.md
3. Спроси (depth.md): уровень, степень иллюстраций, обложка, объём. Не записывай файлы, пока нет ответа или отказа от окна
4. Cover mode (logo-cover.md). «Оставить» не перезаписывает существующую обложку
5. Write README.md по бюджету depth.md. LoC - 4-й бейдж в header, лицензия - футер
6. Правила проекта additive (project-rules.md), если объём это включает: AGENTS.md, файл правил агента запуска, .cursor/rules/dotcore-project.mdc, CLAUDE.md - нет файла создай, есть дополни (не переписывай авторское)
7. Write LICENSE - строгий All Rights Reserved (license.md). При объёме «только README» создай файл, только если его ещё нет
8. Validate (audit.md, минимум 8/10)
9. LoC через code-counter

Факты только из кода. README перегенерируй целиком; правила проекта (AGENTS.md, CLAUDE.md, .mdc) - additive, не переписывая авторское. Сохрани SVG-обложку, LoC-бейдж (в header), строгую лицензию, правило README-sync и - если был в старом README - блок бейджей аудита `<!-- audit:start -->…<!-- audit:end -->` от `pre-deploy-audit` (перенеси дословно после обложки, не выдумывай и не меняй). Прозу README прогони через text-naturalizer, затем sepia. Картинку вместо SVG не ставь, пока человек сам не попросил скриншот.

В конце выведи отчёт аудита и список изменённых файлов.
