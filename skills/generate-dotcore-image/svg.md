# SVG fallback

Пиши SVG как текст. Это не трассировка PNG и не вставка raster. Цель - тот же стиль, меньше узлов, читаемый файл.

## Жёсткие правила

- `xmlns="http://www.w3.org/2000/svg"`, `role="img"`, `aria-label` по сюжету, `<title>`
- `id` градиентов с префиксом (`dci-bg`, `dci-glow`) - без голых `bg`/`glow`
- Без `<script>`, `<use>`, `foreignObject`, внешних `href`/`xlink:href`, без `<image>`
- Без фильтров-монстров; glow = `radialGradient`, не цепочка `feGaussianBlur` на весь кадр
- UTF-8 в `<text>`. Подпись `.ядро` - кириллица

## ViewBox

| Кадр | viewBox / width×height |
|------|------------------------|
| 16:9 | `0 0 1600 900` |
| 1:1 | `0 0 1080 1080` |
| 4:3 | `0 0 1600 1200` |
| 3:4 | `0 0 1200 1600` |
| 9:16 | `0 0 900 1600` |

## Слои (порядок)

1. Фон: linear `#0a0b0d` → `#14161a` → `#0b0c0e`
2. Glow: radial белый, opacity 0.12–0.14, смещён к фокусу
3. Сетка: `opacity="0.045"` stroke white; квадраты или оси как в каноне
4. Сюжет: `fill="none"` stroke `#f3f3f1` stroke-width ~2, round cap/join
5. Узлы (если система/сеть/акцент): круг + точка + halo-circle fill gradient
6. Текст сюжета (если просили)
7. Подпись: `<text>` `.ядро`, fill `#4a4b50`, font-size 14 на 1600-кадре, `text-anchor="middle"` у нижнего края (~`y="height-24"`)

## Каркас 16:9

Замени `{label}`, `{art}` (группы линий сюжета), при отключённой подписи удали последний `<text>`.

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 900" width="1600" height="900" role="img" aria-label="{label}">
  <title>{label}</title>
  <defs>
    <linearGradient id="dci-bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0a0b0d"/>
      <stop offset="0.5" stop-color="#14161a"/>
      <stop offset="1" stop-color="#0b0c0e"/>
    </linearGradient>
    <radialGradient id="dci-glow" cx="50%" cy="42%" r="55%">
      <stop offset="0" stop-color="#ffffff" stop-opacity="0.12"/>
      <stop offset="1" stop-color="#ffffff" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="dci-halo" cx="50%" cy="50%" r="50%">
      <stop offset="0" stop-color="#ffffff" stop-opacity="0.16"/>
      <stop offset="1" stop-color="#ffffff" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="1600" height="900" fill="url(#dci-bg)"/>
  <rect width="1600" height="900" fill="url(#dci-glow)"/>
  <g opacity="0.045" stroke="#ffffff" stroke-width="1">
    <path d="M0 180H1600M0 360H1600M0 540H1600M0 720H1600M320 0V900M640 0V900M960 0V900M1280 0V900"/>
  </g>
  {art}
  <text x="800" y="876" text-anchor="middle" font-family="Inter, Arial, sans-serif" font-size="14" fill="#4a4b50">.ядро</text>
</svg>
```

Узел (повтор с другими cx, cy):

```xml
<g>
  <circle cx="1200" cy="280" r="28" fill="url(#dci-halo)"/>
  <circle cx="1200" cy="280" r="7" fill="none" stroke="#f3f3f1" stroke-width="1.6"/>
  <circle cx="1200" cy="280" r="2.2" fill="#f3f3f1"/>
</g>
```

Коннектор: `<line x1="…" y1="…" x2="…" y2="…" stroke="#f3f3f1" stroke-width="1.2" stroke-dasharray="6 7"/>`

## Как рисовать сюжет

Сведи объект к 5–15 путям. Человек = овал головы + линия плеч. Стол = одна горизонталь + две ноги. Лого = простой геометрический знак. Не трассируй фото попиксельно.

Restyle в SVG: посмотри референс, назови 3–7 главных форм, нарисуй их контуром в тех же относительных местах кадра. Фон фото выкинь.

## Оптимизация

- Нет неиспользуемых `defs`
- Повторяющиеся узлы - копируй `<g>`, не усложняй символами (`<use>` запрещён)
- stroke-width один на сцену (1.6–2.4)
- Файл целиком обозримый: лучше 80 строк ясных путей, чем 800
