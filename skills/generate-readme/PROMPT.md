# Универсальный промпт - README + правила проекта

Для агентов без поддержки скиллов (ChatGPT, Gemini, веб-чат). Скопируй блок между маркерами.

---START---

Сгенерируй или обнови документацию репозитория в стандарте **DotCore**.

## Задача

1. **README.md** - плоский технический документ для разработчика
2. **AGENTS.md** - инструкции для coding-агентов (build, test, conventions)
3. **.cursor/rules/dotcore-project.mdc** - правило Cursor
4. **CLAUDE.md** - обёртка со ссылкой на AGENTS.md
5. **Файл правил агента запуска** - создай нативный файл/папку агента, из которого работаешь, если его нет
6. **LICENSE** - строгий All Rights Reserved (см. блок «Лицензия» ниже)
7. **docs/portfolio-draft.md** - только если проект для портфолио DotBioSite

## Правила

- Язык русский (если проект не EN-only). Тон internal doc, не marketing.
- Читай репозиторий: команды из package.json/Makefile/pyproject, deps из манифестов и env-имена только из явно переданного sanitized списка или безопасной конфигурации. Не открывай `.env*`, включая `.env.example`; значения не запрашивай и не выводи. Ничего не выдумывай. Код важнее старого README.
- Запрещено в README: `<details>`, centered hero, emoji, длинное тире, LLM-маркеры, mermaid вместо ASCII-дерева, marketing-буллеты.

## Workflow

Если рядом лежит `depth.md`, он главнее разделов «Спроси» и «Бюджет текста».

1. **Scan** - runtime, scripts, deps, структура, CI, remote, существующие AGENTS.md/CLAUDE.md
2. **Classify** - тип (learning/web-app/cli/library/bot/…), аудитория (internal/oss/portfolio), distribution (github/local/docker/…). `walkthrough=yes`, если человек проходит шаги в продукте
3. **Спроси** - одно окно или одно сообщение, до записи файлов. Четыре вопроса: уровень (карточка / обычный / полный), степень иллюстраций (без рисунка / схема / анимация), обложка (оставить / перерисовать), объём (только README / README и правила). Ответ уже есть в сообщении: этот вопрос не повторяй. Окно закрыто без ответа: бери рекомендацию. Уровень - обычный, а при словах «полный прогон» или «полный режим» - полный. Степень - без рисунка на карточке. На обычном - схема, если фактов больше шести, иначе без рисунка. На полном - анимация при walkthrough, иначе схема. Обложку оставляй, если файл уже есть. Объём - README и правила
4. **Cover** - GitHub → `docs/cover.svg` + `<img width="720">`; IDE → inline `<svg>`; есть preview.png → используй. «Оставить» не перезаписывает существующий файл. Генерация изображений SVG-обложку не заменяет
5. **Write README** - структура и бюджет ниже. Связную прозу прогони text-naturalizer, затем sepia. Они не раздувают пункт до двух предложений. Таблицы, команды, дерево, бейджи и блок аудита не переписывай
6. **Write rules** - если объём включает правила: AGENTS.md (80-150 строк), dotcore-project.mdc, CLAUDE.md (обёртка)
7. **LoC** - `code-counter .` → TOTAL в бейдж между `<!-- loc:start -->` / `<!-- loc:end -->`
8. **Audit** - оценка 1-10, минимум 8. В отчёте назови Depth, Visual, Walkthrough

## Структура README

```
# {brand}
[4 flat badges: Runtime, Platform, Category, LoC]   LoC = 4-й, в маркерах, без пустой строки перед ним
[cover]
[audit badges]   ОПЦ. - блок <!-- audit:start -->…<!-- audit:end --> от pre-deploy-audit; если был в старом README, перенести дословно
{intro - до 2 предложений}

## Что внутри     ОПЦ. Карточка эту секцию не пишет. Иначе до 6 коротких пунктов
## Запуск
## Команды        | Команда | Назначение |
## Стек            только <img for-the-badge>. На карточке секции нет
## Тесты / …       если есть. На карточке секции нет
## Архитектура     последняя содержательная: абзац до 2 предложений + ASCII-дерево + 3-5 инвариантов по одной строке
## Лицензия        футер: © {year} {author}, все права защищены + ссылка на LICENSE
```

## Бюджет текста

Пункт списка: `**ключ**: одно предложение`, одно ограничение, не больше трёх имён. Абзац не длиннее двух предложений. Пары «возможность и предел» пиши таблицей и не дублируй списком. Факты сверх шести пунктов идут на рисунок или в строку `Подробности:` со ссылками на docs, которые уже есть.

Схема: `docs/readme/inside.svg`, карта возможностей, не вторая обложка. Анимация: тот же SVG плюс `docs/readme/inside.html` по скиллу `html-motion`, 3-7 шагов человека из кода, ссылка «Открыть анимацию» под картинкой. HTML внутрь README не вставляй. Нет обхода и пользователь сам не выбрал анимацию: сцены нет. Старые файлы `docs/readme/inside.*` не удаляй. При «без рисунка» убери на них ссылки.

LoC-бейдж стоит 4-м в группе header (с Runtime · Platform · Category), не под cover. GitHub-first: все четыре - `<img style=flat>` внутри одного `<p>` (иначе на GitHub бейджи разъезжаются по строкам). Стек - тоже `<img>` в `<p>`. Обложка - `docs/cover.svg` + `<img src="docs/cover.svg" width="720">` (inline `<svg>` GitHub вырезает).

**Бейджи аудита (обратная совместимость).** Если в текущем README есть блок `<!-- audit:start -->…<!-- audit:end -->` (его ставит скилл аудита `pre-deploy-audit` на PASS), перенеси его **дословно вместе с маркерами** после обложки, перед intro. Перегенерация README не должна стирать бейджи аудита. Не выдумывай этот блок и не меняй его содержимое (статус, уровень, охват, модель, дата) - только перенос. Нет блока - ничего не добавляй.

## AGENTS.md (кратко)

Секции: Профиль проекта · Быстрый старт · Сборка и проверки (таблица команд) · Структура (ASCII) · Соглашения · Env (имена) · Что делать / Чего не делать · Документация · DotCore. Без marketing. Команды только реальные.

## .cursor/rules/dotcore-project.mdc

YAML: `description`, `globs: ["**/*"]`, `alwaysApply: true`. Тело: ссылка на AGENTS.md, краткие install/dev/test, правила DotCore.

## CLAUDE.md

15-25 строк: «Прочитай AGENTS.md», приоритет контекста, триггер generate-readme. Не дублируй AGENTS.md.

## SVG cover (DotBioSite, tagline на русском)

GitHub: сохрани в `docs/cover.svg`, в README `<img src="docs/cover.svg" width="720">`.

Skeleton (замени {p}, {brand}, {name}, {tagline}, {glyph}):

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="720" viewBox="0 0 1600 900" role="img" aria-label="{name}">
  <defs>
    <linearGradient id="{p}-bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#0a0b0d"/><stop offset="1" stop-color="#14161a"/>
    </linearGradient>
    <radialGradient id="{p}-glow" cx="72%" cy="22%" r="60%">
      <stop offset="0" stop-color="#ffffff" stop-opacity="0.12"/><stop offset="1" stop-color="#ffffff" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="1600" height="900" fill="url(#{p}-bg)"/>
  <rect width="1600" height="900" fill="url(#{p}-glow)"/>
  <g opacity="0.05" stroke="#ffffff" stroke-width="1"><path d="M0 300H1600M0 600H1600M533 0V900M1067 0V900"/></g>
  <svg x="980" y="250" width="400" height="400" viewBox="0 0 48 48">
    <g opacity="0.1" fill="none" stroke="#ffffff" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">{glyph}</g>
  </svg>
  <svg x="140" y="120" width="86" height="86" viewBox="0 0 48 48">
    <g fill="none" stroke="#f3f3f1" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">{glyph}</g>
  </svg>
  <text x="138" y="408" font-family="Inter, Arial, sans-serif" font-size="132" font-weight="800" fill="#f3f3f1" letter-spacing="-3">{brand}</text>
  <text x="146" y="470" font-family="Inter, Arial, sans-serif" font-size="34" font-weight="700" fill="#f3f3f1">{name}</text>
  <text x="146" y="516" font-family="Inter, Arial, sans-serif" font-size="26" fill="#a6a7ab">{tagline}</text>
</svg>
```

## LoC badge (4-й в строке header)

```markdown
<!-- loc:start --><img src="https://img.shields.io/badge/lines_of_code-{N}-lightgrey?style=flat" alt="{N} lines of code" /><!-- loc:end -->
```

Ставится сразу после трёх flat-бейджей, без пустой строки между ними.

## Лицензия (строгий All Rights Reserved)

Файл `LICENSE` (замени `{year}`, `{author}` - год сессии и автор/бренд из репо; по умолчанию для DotCore - `DotCore`):

```text
Copyright (c) {year} {author}. All Rights Reserved.

This software and its source code are proprietary and confidential.
No permission is granted to any person to use, copy, modify, merge,
publish, distribute, sublicense, or sell any part of the Software.

The source is provided for viewing and reference only. Any other use
requires the prior written permission of the copyright holder.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```

Футер README:

```markdown
## Лицензия

© {year} {author}. Все права защищены. Использование, копирование, изменение и распространение запрещены без письменного разрешения автора. Исходный код открыт только для ознакомления. См. [LICENSE](LICENSE).
```

Не предлагай open-source лицензию по умолчанию. Прежнюю лицензию (MIT и т.п.) заменяй.

## README-sync

В AGENTS.md/CLAUDE.md/.mdc впиши: при глобальных изменениях (новые/удалённые команды, модули, зависимости, смена архитектуры или runtime) агент обновляет README через этот промпт/скилл, включая пересчёт LoC. Мелкие правки README не трогают.

## Self-check

- [ ] README создан. AGENTS.md, mdc, CLAUDE.md и файл агента запуска обновлены, если объём включает правила
- [ ] Команды и пути существуют; LoC обновлён, стоит 4-м бейджем в header
- [ ] Cover по среде; нет битых img; архитектура - последняя содержательная, лицензия - футер
- [ ] Блок аудита `<!-- audit:start -->…<!-- audit:end -->` (если был в старом README) перенесён дословно после обложки
- [ ] `LICENSE` создан (строгий All Rights Reserved); прежняя лицензия заменена
- [ ] AGENTS.md не дублирует README; CLAUDE.md - обёртка; есть правило README-sync
- [ ] Аудит ≥ 8/10
- [ ] Уровень и степень иллюстраций названы. Пункт «Что внутри» не длиннее одного предложения

Выведи краткий отчёт аудита и список изменённых файлов.

---END---
