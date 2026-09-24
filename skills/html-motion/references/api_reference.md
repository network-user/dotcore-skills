# API contract for video-ready HTML

Этот reference содержит только устойчивый интерфейс между HTML-анимацией и
покадровым capture/export. Загружай его, когда пользователь просит запись в
MP4, frame-exact preview или воспроизводимый тест времени.

## Window contract

```js
window.__duration = 8.4;
window.__ready = Promise.resolve();
window.__renderAt = (timeMs) => {
  // canonical time-based renderer used by preview and seek
};
window.__seek = (seconds) => {
  // 1. stop preview/RAF playback
  // 2. clamp seconds to [0, __duration]
  // 3. pause WAAPI animations before setting currentTime
  // 4. call __renderAt(seconds * 1000)
};
```

`__renderAt(timeMs)` - источник истины для preview и export. Preview передаёт ему
elapsed time из RAF, а `__seek(t)` сначала останавливает свободное движение и
вызывает его с абсолютным временем. `__seek(t)` должен быть идемпотентным: два
вызова с одним `t` дают одинаковую сцену. До первого seek дождись
`document.fonts.ready`, изображений и других визуальных ресурсов. В
export-контуре зафиксируй viewport, device scale factor, seed и цветовые токены.

`__ready` должен разрешиться после загрузки шрифтов, изображений и инициализации
сцены. После каждого seek capture ждёт два RAF, чтобы браузер применил стили и
отрисовал новый кадр.

## Timeline rules

- Не пытайся заморозить running animation назначением `currentTime`: сначала
  `pause()`, затем `currentTime`.
- Не рассчитывай сцену от числа вызванных кадров. Используй абсолютный `t` и
  ограничивай `delta` после скрытия вкладки.
- Один элемент не должен иметь несколько независимых анимаций, которые пишут в
  одну CSS-собственность.
- Проверяй `t=0`, каждый beat, середину handoff, финал и повторный вызов того же
  времени.
- Сделай smoke-test capture минимум для `t=0`, середины и финала: кадры не пустые,
  повторный вызов того же времени совпадает по геометрии и не содержит NaN.

## Export handoff

Передай отдельному exporter только проверенный HTML. Проверь metadata MP4:
codec, width/height, fps и duration. Для web playback обычно полезны `yuv420p` и
`+faststart`; silent audio track нужен только если этого требует платформа.

Этот файл не требует конкретного Puppeteer/Playwright/ffmpeg runner. Выбирай
инструмент из существующего проекта и не добавляй зависимость ради одного
preview, если достаточно браузерного просмотра.
