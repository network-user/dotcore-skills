---
description: DotCore sepia - de-AI writing, humanize / review / refactor / recreate
---

Прочитай скилл `sepia` из установленного dotcore-skills:

- `~/.codex/skills/sepia/SKILL.md`
- или `skills/sepia/SKILL.md` в клоне dotcore-skills
- или `.cursor/skills/sepia/SKILL.md` в проекте

Выполни workflow (SKILL.md):

1. **Route** - тип текста и операция write / review / refactor / recreate. Не задано: есть исходник - refactor, нет - write.
2. **Venue** - 2–3 свежих человеческих образца той же площадки, иначе baseline домена.
3. **Load** - доменные файлы из таблицы routing *до* черновика или правок. Русский текст - ещё `references/ru-register.md`.
4. **Act** - по контракту операции. Review не редактирует. Refactor/recreate начинаются со списка дефектов.
5. **Self-check** - факты не выдуманы, цитаты не приглажены, длинного тире нет.

Не применять на код, конфиги, команды и verbatim пользователя. Не выдумывать версии, числа, timestamps.
