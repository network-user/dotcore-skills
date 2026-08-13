# generate-dotcore-image

Скилл DotCore из monorepo [dotcore-skills](../../README.md): **изображения в стиле DotCore**. Сюжет любой. Два режима: генерация с нуля и restyle любого референса (фото, скрин, лого, рисунок). Raster через image generation агента; если модели нет - SVG.

Обложки README (`docs/cover.svg`) этот скилл не заменяет - их пишет `generate-readme`.

## Режимы

| Режим | Когда | Выход |
|-------|--------|--------|
| A. Генерация | описали картинку | PNG (если есть модель) или SVG |
| B. Restyle | прислали референс | тот же сюжет в языке DotCore |

Подпись `.ядро` - по умолчанию, мелко и низкоконтрастно. Убрать по просьбе.

## Что создаётся в целевом проекте

Файл, который попросили, обычно `docs/<slug>.png` или `docs/<slug>.svg`. `docs/cover.svg` не трогается без явного пути.

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Workflow |
| [style.md](style.md) | Визуальный язык |
| [raster.md](raster.md) | Промпт image generation |
| [svg.md](svg.md) | SVG fallback |
| [PROMPT.md](PROMPT.md) | Standalone без skills |
| [codex-prompt.md](codex-prompt.md) | `/generate-dotcore-image` для Codex |
| [references/style-illustration.png](references/style-illustration.png) | Канон сцены |
| [references/style-brand.png](references/style-brand.png) | Канон локапа |

## Установка

### Из dotcore-skills (рекомендуется)

```powershell
cd path\to\dotcore-skills
.\scripts\install.ps1 -Skill generate-dotcore-image
.\scripts\install.ps1 -Skill generate-dotcore-image -Agent cursor,claude
```

```bash
./scripts/install.sh generate-dotcore-image
AGENTS=cursor,claude ./scripts/install.sh generate-dotcore-image
```

При разработке: `.\scripts\install.ps1 -Skill generate-dotcore-image -Link`.

Поддерживаемые агенты и пути - [docs/AGENTS_PATHS.md](../../docs/AGENTS_PATHS.md).

### В целевом проекте

```text
your-repo/.cursor/skills/generate-dotcore-image/
```

Полная копия папки (включая `references/`), опционально `.claude/skills/generate-dotcore-image/`.

## Триггеры

«картинка в стиле dotcore», «перерисуй в .ядро», «сгенерируй иллюстрацию / svg / png в этом стиле», `/generate-dotcore-image` (Codex).

## Тест

1. «Нарисуй схему из трёх агентов вокруг редактора, стиль dotcore» - без вложения: режим A, raster или SVG.
2. Пришли фото и «перерисуй в dotcore» - режим B, силуэт источника узнаваем, цвет исчез.
3. «Без подписи .ядро» - подписи нет.
4. В агенте без image generation - только SVG, файл валидный, без `<script>`/`<use>`.
