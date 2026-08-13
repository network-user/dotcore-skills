---
description: DotCore generate-dotcore-image - PNG/SVG в стиле .ядро
---

Прочитай скилл `generate-dotcore-image` из установленного dotcore-skills:

- `~/.codex/skills/generate-dotcore-image/SKILL.md`
- или `skills/generate-dotcore-image/SKILL.md` в клоне dotcore-skills
- или `.cursor/skills/generate-dotcore-image/SKILL.md` в проекте

Выполни полный workflow (SKILL.md):

1. Intent - режим A (генерация) или B (restyle любого референса)
2. Style lock - style.md + `references/style-illustration.png` и `references/style-brand.png`
3. Raster, если в агенте есть image generation (raster.md)
4. Иначе SVG (svg.md)
5. Self-check

Сюжет любой, стиль один. Подпись `.ядро` по умолчанию, незаметно; убрать по просьбе. Не трогать `docs/cover.svg` без явного пути. Обложки README - не этот скилл (`generate-readme`).
