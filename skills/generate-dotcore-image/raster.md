# Raster: image generation

В Cursor вызывай GenerateImage. В других агентах - их аналог, если умеет принимать референс-файлы и текстовый промпт. Нет инструмента - не симулируй, переходи к [svg.md](svg.md).

## Вызов (Cursor)

- `description` - промпт ниже, без markdown-заборов.
- `filename` - basename целевого файла (`agent-map.png`).
- `aspect_ratio` - одно из: `1:1`, `4:3`, `3:4`, `16:9`, `9:16`.
- `reference_image_paths` - абсолютные пути:
  - режим A: `…/references/style-illustration.png`, `…/references/style-brand.png`
  - режим B: пути вложений пользователя, затем оба style-PNG

После успеха: файл должен оказаться в пути из шага Intent. Клиент часто кладёт сгенерированное сам - если путь другой, перенеси содержимое (копия файла), не перегенерируй.

Один ретрай только если кадр цветной, фотореалистичный или проигнорировал стиль. Иначе SVG.

## Каркас промпта (режим A)

Подставь `{subject}`, `{frame}`, `{signature}`. `{signature}` = `tiny low-contrast gray ".ядро" caption at the bottom edge, almost invisible` **или** `no captions, no watermarks, no .ядро` если отключили.

```
Minimalist technical illustration, DotCore house style, not concept art.

Style lock (match the attached style references, ignore their subject matter):
monochrome only; deep black / charcoal background; faint blueprint square grid at ~5% opacity;
thin crisp white line-art; objects reduced to outlines; no fills except small node dots and letterforms;
soft white radial glow only on a few focal nodes or the main glyph; dashed straight connectors;
circular nodes = ring + center dot + quiet halo; generous negative space; calm, modern, not ornate.

Subject: {subject}

Framing: {frame}. Flat schematic, 2D (a slight isometric glyph is ok). Centered, balanced.

Typography if any text is requested: geometric bold sans, white, sparse. Secondary text muted gray.

Must include: {signature}

Must not: color, neon, rainbow, photorealism, skin texture, cloth texture, cinematic lighting,
bokeh, fog, octane, unreal engine, chrome, glass caustics, busy UI chrome, stock AI-art look,
heavy drop shadows, watercolor, glitch, decorative ornaments.
```

`{frame}` примеры: `wide 16:9 editorial frame` / `square icon frame` / `portrait poster`.

## Каркас промпта (режим B)

```
Restyle the attached source image(s) into DotCore house style. The style references show the look;
the source image(s) define the subject.

Keep from source: subject identity, pose, camera angle, silhouette, spatial layout.
Replace: all color with monochrome; photographic texture with thin white outlines;
background with dark charcoal plus a faint grid; highlights with a few white node glows.

Style lock: same as DotCore - thin line-art, quiet grid, soft white halos on focal points,
dashed connectors only if they clarify structure, generous empty space, modern and restrained.

Must include: {signature}

Must not: keep the source's colors or photo look; copy the style-reference scenes (desk person,
CURSOR wordmark) unless they are the source; neon, photoreal skin, cinematic grade, ornaments.
```

## Соотношения

| Запрос | `aspect_ratio` |
|--------|----------------|
| не сказано, широкая картинка / docs | `16:9` |
| иконка, аватар, знак | `1:1` |
| сторис / телефон | `9:16` |
| постер вертикальный | `3:4` |
| «как фото 4:3» | `4:3` |

Инструмент других размеров не принимает - бери ближайшее.
