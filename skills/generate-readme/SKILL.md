---
name: generate-readme
description: >-
  Создаёт или обновляет README.md в стандарте DotCore (русский internal doc, SVG-обложка
  DotBioSite, flat-бейджи, LoC через code-counter, ASCII-архитектура) и правила проекта
  (additive): AGENTS.md, .cursor/rules/dotcore-project.mdc, CLAUDE.md. Перед записью
  спрашивает уровень (карточка, обычный, полный) и степень иллюстраций. Текст секций
  короткий: «Что внутри» не складывает несколько фактов в один пункт. Полный режим
  добавляет схему или анимацию, если есть обход действий.
  Прозу проводит через text-naturalizer, затем sepia. Факты только из репозитория.
  Cursor, Claude Code, Codex, Grok. Use when creating or updating README, AGENTS.md,
  or project documentation.
---

# Generate README + Project Rules

Единый скилл DotCore: **README для человека** + **правила для агентов** в каждом репозитории, где он запущен.

Главное правило: **читай репозиторий, не выдумывай**. Источник правды - `package.json`, `Makefile`, `pyproject.toml`, `docker-compose.yml`, CI, код. Старый README / AGENTS.md / CLAUDE.md - не авторитет; при расхождении верь коду.

Перед записью файлов спроси уровень и степень иллюстраций. Длина текста и рисунок функционала - [depth.md](depth.md).

## Когда применять

- Создать или обновить `README.md`
- Обновить (additive) `AGENTS.md`, `.cursor/rules/dotcore-project.mdc`, `CLAUDE.md`
- Привести документацию к стандарту DotCore после рефакторинга
- Запросы: «обнови README», «сгенерируй документацию», «настрой правила проекта»

При обновлении README - **перегенерируй**, не латай: убери centered hero, `<details>`, битые `<img>`, устаревшие команды. Правила проекта (AGENTS.md и rule-файлы), наоборот, обновляй **additive** - см. шаг 6. Объём «только README» из [depth.md](depth.md) этот шаг пропускает.

**Исключение - блок security-аудита.** Если в текущем README есть блок `<!-- audit:start -->…<!-- audit:end -->` (артефакт скилла `pre-deploy-audit`), перенеси его **дословно** в новый README - перегенерация не должна стирать бейджи аудита. Не выдумывай этот блок и не меняй его содержимое (статус, уровень, охват, модель, дата). См. шаг 5.

## Язык и тон

- **Русский**, если проект не целиком на английском. Пакеты и техтермины - как в коде.
- Тон сухой, как internal doc. Не marketing, не landing page, не storytelling.
- README и AGENTS.md - один язык; CLAUDE.md и `.mdc` - кратко на том же языке.

## Workflow (8 шагов)

### 1. Scan

Собери факты (как readme-crafter / project-documenter - только из репо):

| Категория | Где смотреть |
|-----------|--------------|
| Runtime | `engines`, `.nvmrc`, `pyproject.toml`, `go.mod`, `Cargo.toml` |
| Команды | `scripts`, `Makefile`, `pyproject` scripts, `composer.json` |
| Зависимости | `dependencies`, `devDependencies`, `requirements` |
| Окружение | `docker-compose.yml`, `Dockerfile`; `.env*` не открывать, имена переменных принимать только из явно переданного sanitized списка |
| Тесты / lint | CI `.github/workflows/`, `pytest.ini`, `eslint.config` |
| Структура | `apps/`, `packages/`, `src/`, `topics/` - считай модули по факту |
| Строки кода | `code-counter` (см. ниже) |
| Обложка | `docs/preview.png`, `docs/cover.svg` |
| Существующие правила | `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `CONTRIBUTING.md` |
| Бейджи аудита | блок `<!-- audit:start -->…<!-- audit:end -->` в текущем README (от `pre-deploy-audit`) - захвати дословно для переноса |
| Remote | `git remote -v` → github/gitlab или local |

Спорное - проверь по коду. Запиши черновик классификации (шаг 2).

### 2. Classify

Определи профиль по [project-classify.md](project-classify.md): `project_type`, `audience`, `distribution`, `cover_mode`, `walkthrough`. Обход функционала описан в [depth.md](depth.md).

### 3. Ask

Одно окно по [depth.md](depth.md): уровень, степень иллюстраций, обложка, объём. Рекомендация зависит от `walkthrough` и числа фактов. Файлы пиши после ответа или после закрытия окна без ответа.

### 4. Cover mode

SVG-обложка DotBioSite - агент пишет текстом. Детали: [logo-cover.md](logo-cover.md). Ответ «оставить» не перезаписывает существующий `docs/cover.svg`. «Перерисовать» и отсутствие файла идут по logo-cover. `docs/preview.png` остаётся обложкой.

**Дефолт - GitHub-first: `file`.** README в первую очередь смотрят на github.com, а GitHub **вырезает inline `<svg>`** из markdown - обложки не будет. Поэтому пиши SVG в `docs/cover.svg` и ставь `<img src="docs/cover.svg" width="720">`. `inline` - только для IDE-only репозитория по явному запросу.

| cover_mode | Действие |
|------------|----------|
| `file` (дефолт) | `docs/cover.svg` + `<img width="720">` в README - рендерится и на GitHub, и в IDE |
| `inline` | inline `<svg>` после badges - **только IDE**, на GitHub не виден |
| `preview` | `<img src="docs/preview.png">`, SVG не трогать |

### 5. Write README

Структура (порядок строгий):

```
# {brand}
[4 flat badges]     Runtime · Platform · Category · LoC
                    LoC = 4-й бейдж В ТОЙ ЖЕ строке header, в маркерах <!-- loc:start -->…<!-- loc:end -->
[cover]
[audit badges]      ОПЦ. - блок <!-- audit:start -->…<!-- audit:end --> от pre-deploy-audit; перенести дословно, если был в старом README
{intro}             до 2 предложений

## Что внутри       ОПЦ. - потолок и рисунок в depth.md, уместность в project-classify.md
## Запуск
## Команды          таблица из scripts
## Стек             for-the-badge <img> только
## Тесты / …        если есть в репо
## Архитектура      последняя содержательная: абзац до 2 предложений + ASCII-дерево + 3-5 инвариантов
## Лицензия         футер: строгий All Rights Reserved (см. license.md)
```

Карточка убирает `## Что внутри`, `## Стек` и `## Тесты`. Остальной порядок тот же. Длина блоков и рисунок - [depth.md](depth.md).

- **intro** - что это + одно ключевое решение, до 2 предложений. Без tagline-абзаца и маркетинговых буллетов.
- **Что внутри, длина секций и рисунок функционала** - [depth.md](depth.md). [project-classify.md](project-classify.md) решает, уместна ли секция. На карточке её нет.
- **Архитектура** - ASCII, не mermaid если дерева хватает. После неё - только футер `## Лицензия`.
- **Лицензия** - всегда присутствует; по умолчанию строгий All Rights Reserved + файл `LICENSE`. См. [license.md](license.md).
- **Бейджи аудита** - если в старом README был блок `<!-- audit:start -->…<!-- audit:end -->` (артефакт `pre-deploy-audit`), перенеси его **дословно вместе с маркерами** сразу после обложки, перед intro. Это чужой блок: не выдумывай, не дополняй и не правь его (статус, уровень, охват, модель, дата) - только перенос. Нет блока в исходном README - ничего не добавляй. Если регенерация вызвана крупным изменением кода (новые модули/зависимости/архитектура), в отчёте отметь, что бейджи аудита могли устареть и стоит перезапустить `pre-deploy-audit`; сам блок при этом не удаляй. Детали маркеров - [stack-badges.md](stack-badges.md).

Связную прозу (intro и абзацы секций) после черновика прогони дважды. Таблицы, команды, дерево, бейджи, маркеры LoC, блок аудита и футер лицензии стилем не трогай.

1. `text-naturalizer`, режим `light-edit`, если секции уже совпадают со стандартом. Профиль `author-voice` или `VOICE.md` передай, только если такой файл уже есть.
2. `sepia`, операция `refactor`. Маршрут: `professional-pass.md`, `references/domains/docs.md`, `ru-register.md`. Sepia чинит слог. Набор секций и потолок длины задаёт [depth.md](depth.md), не sepia. Раздутый пункт верни к одному предложению.

Нет этих скиллов - поставь их и прочитай `SKILL.md` до прозы:

```powershell
.\scripts\install.ps1 -Skill sepia,text-naturalizer
```

```bash
./scripts/install.sh sepia,text-naturalizer
```

Корень `dotcore-skills` ищи по `scripts/install.ps1`. Нет клона - клонируй `https://github.com/network-user/dotcore-skills` во временный каталог и ставь оттуда. Текстовые скиллы не встали - README не выпускай.

Бейджи и LoC: [stack-badges.md](stack-badges.md). Лицензия: [license.md](license.md). Эталон: [reference.md](reference.md).

### 6. Write project rules

Объём «только README» этот шаг пропускает. `LICENSE` тогда создаётся, только если файла ещё нет.

Правила проекта (`AGENTS.md` + нативные rule-файлы агентов) генерирует **подскилл [`sync-project-rules`](../sync-project-rules/SKILL.md)** - он владеет шаблонами. Вызови его и выполни его workflow:

1. `AGENTS.md` - канон для всех агентов (Codex, Cursor, Claude, Copilot, Gemini). **Всегда.**
2. **Rule-файл агента запуска** - `.cursor/rules/dotcore-project.mdc` / `CLAUDE.md` / `GEMINI.md`; создай файл и папку, если их нет.
3. README-sync: при глобальных изменениях агент обновляет README через `generate-readme`, правила - через `sync-project-rules`.

Если `sync-project-rules` не установлен, его шаблоны зеркалированы здесь в [project-rules.md](project-rules.md) (fallback для автономной работы) - используй их.

Сверх правил `generate-readme` добавляет то, что вне scope подскилла:

4. `docs/portfolio-draft.md` - только если `audience=portfolio` (см. [project-rules.md](project-rules.md))
5. Лицензия: `LICENSE` + футер `## Лицензия` (см. [license.md](license.md))

Правила - **additive**: существующие `AGENTS.md`/`CLAUDE.md` не переписывай и не реструктурируй. Добавь недостающие DotCore-блоки и точечно почини устаревшие факты; авторский текст и секции сохрани дословно.

### 7. Validate

Self-check (ниже) + аудит [audit.md](audit.md). Минимум **8/10**. Исправь замечания до отчёта.

### 8. LoC finalize

В конце сессии:

```bash
code-counter .
```

Нет команды - один раз поставь `code-counter-ntwusr` (Python 3.12+ и git) и запусти счётчик снова. Обнови `{N}` в LoC-бейдже между `<!-- loc:start -->` и `<!-- loc:end -->`. Число без запятых, бери `TOTAL`.

## Счётчик строк кода

LoC - **4-й бейдж в группе header**, на одном уровне с Runtime · Platform · Category (а не под cover). Чтобы все четыре были в один ряд на GitHub, **все header-бейджи - `<img style=flat>` внутри одного `<p>`** (см. [stack-badges.md](stack-badges.md)). LoC - последним в `<p>`, перед обложкой.

```markdown
<p>
  <img src="https://img.shields.io/badge/Runtime-...-339933?style=flat" alt="Runtime" />
  <img src="https://img.shields.io/badge/Platform-...-555?style=flat" alt="Platform" />
  <img src="https://img.shields.io/badge/Category-...-orange?style=flat" alt="Category" />
  <!-- loc:start --><img src="https://img.shields.io/badge/lines_of_code-{N}-lightgrey?style=flat" alt="{N} lines of code" /><!-- loc:end -->
</p>
```

Маркеры `<!-- loc:start -->` / `<!-- loc:end -->` обязательны - по ним идёт обновление LoC, не удаляй их. Если `code-counter` недоступен - посчитай по git и укажи метод. Не выдумывай.

## Чего не делать

- marketing, `<details>`, centered hero, emoji, длинное тире, LLM-маркеры
- несколько фактов или два предложения в одном пункте «Что внутри»
- HTML-сцена внутрь README. На GitHub остаётся SVG, сцена открывается ссылкой
- анимация дерева файлов. Дерево живёт в «Архитектуре»
- mermaid вместо ASCII-дерева где хватает дерева
- for-the-badge в header; plain-text в `## Стек`
- выдуманные команды, пути, env, версии, LoC
- удалять при перегенерации блок `<!-- audit:start -->…<!-- audit:end -->` (бейджи аудита от `pre-deploy-audit`) - переноси дословно
- выдумывать или «обновлять» блок аудита - он чужой; generate-readme только сохраняет существующий
- `<img>` на несуществующий файл; `docs/readme-hero.svg`
- дублировать README в AGENTS.md; секреты в любых файлах
- «Generated with AI» / «Powered by» трейлеры

## Human voice

- Одно точное предложение лучше трёх с водой
- Буллеты: `**ключ**: значение`
- Числа сверяй с репо
- README - для разработчика; AGENTS.md - для агента (build/test/conventions)
- Длина секций и рисунок функционала - [depth.md](depth.md)

## Чего не включать в README

- Contributing - только если уже значим в репо (Лицензия - всегда, футером, см. license.md)
- Roadmap, бенчмарки, star-hunting
- Длинные operational-инструкции для агентов (они в AGENTS.md)
- Бейджи технологий без deps

## Self-check

**README**

- [ ] Русский (или EN-only); тон internal doc
- [ ] Cover по режиму; SVG tagline на русском; нет битых img
- [ ] Header: 4 бейджа `<img style=flat>` внутри одного `<p>` - Runtime · Platform · Category · **LoC (4-й, в маркерах)** - один ряд на GitHub, перед cover
- [ ] Cover для GitHub - `docs/cover.svg` + `<img>` (inline `<svg>` GitHub вырезает); стек - `<img>` for-the-badge в `<p>` (на карточке секции нет)
- [ ] Команды из scripts; стек из deps; архитектура - последняя содержательная
- [ ] `## Лицензия` футером (строгий All Rights Reserved), есть файл `LICENSE`
- [ ] Уровень и степень иллюстраций соблюдены, бюджет текста не раздут ([depth.md](depth.md))
- [ ] Блок аудита `<!-- audit:start -->…<!-- audit:end -->` (если был в старом README) перенесён дословно после обложки, без правок
- [ ] Связная проза прогнана через text-naturalizer и sepia; команды, дерево, бейджи, лицензия и бюджет depth.md после этого те же

**Project rules**

- [ ] `AGENTS.md` создан или дополнен (additive, не переписан), команды проверены. Объём «только README» файлы правил не трогает
- [ ] Rule-файл агента запуска создан (папка создана, если её не было)
- [ ] `AGENTS.md`/`CLAUDE.md`/`.mdc` содержат правило README-sync (обновлять README при глобальных изменениях)
- [ ] `.cursor/rules/dotcore-project.mdc` существует
- [ ] `CLAUDE.md` → AGENTS.md, без дубля
- [ ] `docs/portfolio-draft.md` только для portfolio

**Аудит**

- [ ] Оценка ≥ 8/10 по [audit.md](audit.md)

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Workflow (этот файл) |
| [project-classify.md](project-classify.md) | Тип, аудитория, cover mode |
| [depth.md](depth.md) | Окно вопросов, уровень, бюджет текста, схема и анимация |
| [project-rules.md](project-rules.md) | Зеркало/fallback правил (канон - подскилл `sync-project-rules`): AGENTS.md, .mdc, CLAUDE.md, portfolio, агент запуска, README-sync |
| [license.md](license.md) | Лицензия (строгий All Rights Reserved), LICENSE + футер |
| [logo-cover.md](logo-cover.md) | SVG DotBioSite |
| [stack-badges.md](stack-badges.md) | Shields, LoC в header |
| [audit.md](audit.md) | Оценка 1-10 |
| [reference.md](reference.md) | Пример README (DotLearn) |
| [PROMPT.md](PROMPT.md) | Standalone без skills |
| [codex-prompt.md](codex-prompt.md) | Промпт `/generate-readme` для Codex |
| [README.md](README.md) | Установка Cursor / Claude / Codex / проект |
