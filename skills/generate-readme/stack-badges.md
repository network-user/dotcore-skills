# Бейджи - shields.io

Два разных места, две роли.

| Место | Стиль | Кол-во |
|-------|-------|--------|
| Под `# {brand}` | `<img style=flat>` в одном `<p>` (без `for-the-badge`) | 4: Runtime, Platform, Category, **LoC** (4-й, в маркерах) |
| `## Стек` | только `<img>` for-the-badge в одном `<p>` | все ключевые технологии из репо (обычно 6-12) |

Только технологии, реально присутствующие в `dependencies` / `docker` / CI / dev deps секции «Стек». Не декор.

## Header (4 flat: Runtime · Platform · Category · LoC)

| Бейдж | Откуда брать | Пример значения |
|-------|--------------|-----------------|
| Runtime | `engines`, `.nvmrc`, `pyproject`, `go.mod` | `Node.js-20%2B`, `Python-3.12` |
| Platform | где работает | `Web`, `Windows%20%7C%20Linux%20%7C%20macOS`, `Docker`, `Telegram` |
| Category | тип проекта | `Learning`, `Bot`, `CLI`, `API` |
| **LoC** | `code-counter` → `TOTAL` | 4-й бейдж, `<img>` в маркерах (см. ниже) |

**Все четыре бейджа - `<img style=flat>` внутри одного `<p>`.** GitHub-first: обёртка `<p>` гарантирует один ряд (внутри `<p>` переносы строк схлопываются в пробелы, бейджи текут инлайн и переносятся по ширине). LoC - последний, перед cover.

```markdown
<p>
  <img src="https://img.shields.io/badge/Node.js-20%2B-339933?style=flat" alt="Node.js" />
  <img src="https://img.shields.io/badge/Platform-Web%20%7C%20Docker-lightgrey?style=flat" alt="Platform" />
  <img src="https://img.shields.io/badge/Category-Learning-orange?style=flat" alt="Category" />
  <!-- loc:start --><img src="https://img.shields.io/badge/lines_of_code-211875-lightgrey?style=flat" alt="211875 lines of code" /><!-- loc:end -->
</p>

<img src="docs/cover.svg" width="720" alt="DotLearn">
```

**Важно (один ряд на GitHub):** не смешивай `![]()` и `<img>` и не оставляй бейджи голыми строками. Голые `![]()` рендерятся рядом в IDE, но на GitHub строка LoC, начинающаяся с `<!--`/`<img>`, становится отдельным HTML-блоком и уезжает вниз; голые `<img>` на отдельных строках GitHub тоже часто разбивает по строкам. Обёртка `<p>` решает оба случая - это дефолт.

## Lines of code (4-й header-бейдж)

**В** строке header-бейджей, 4-м, сразу после Category и **перед** cover. Не под cover.

| Источник | `code-counter` → `TOTAL`, без запятых в URL |
| Маркеры | `<!-- loc:start -->` … `<!-- loc:end -->` (обязательны, не удалять) |
| Формат | `<img src=".../lines_of_code-{N}-lightgrey?style=flat">` |

LoC-бейдж - **`<img>`** в маркерах, не `![]()`. Label: `lines_of_code`. Цвет: `lightgrey`. Между ним и тремя первыми бейджами нет пустой строки - иначе разорвётся на две строки при рендере.

---

## Чужой блок: бейдж аудита (только сохранять)

Бейдж security-аудита выдаёт **другой** скилл - `pre-deploy-audit`. Он кладёт в README отдельный `<p>` в маркерах `<!-- audit:start -->` … `<!-- audit:end -->` сразу после обложки/шапки: один кликабельный бейдж `security_audit` (ведёт на `docs/audit/latest.md`) + серый бейдж `date`. Сами отчёты он держит в `docs/audit/`.

generate-readme блок **не генерирует и не правит** - только **переносит дословно** при перегенерации README (как сохраняет SVG-обложку), и **не трогает каталог `docs/audit/`**. Логика - та же, что с loc-маркерами: маркеры обязательны, по ним владелец-скилл обновляет блок на месте.

| Маркеры | `<!-- audit:start -->` … `<!-- audit:end -->` (чужие, не удалять, не дублировать) |
| Владелец | `pre-deploy-audit` (см. `skills/pre-deploy-audit/badge.md`) |
| Действие generate-readme | был в старом README → перенести verbatim после cover; не было → ничего не добавлять |
| Запрещено | выдумывать блок, менять статус/дату/охват, трогать `href` или `docs/audit/`, удалять при регенерации |

Целостность: бейдж заявляет «аудит пройден на дату Y». Перенося его, не трогай дату и `href` - это дата прошлого прогона и ссылка на его отчёт. Если регенерация вызвана крупным изменением кода, заявление могло устареть - отметь это в отчёте и предложи перезапустить `pre-deploy-audit`, но сам блок не стирай.

Старый формат (пять бейджей `security_audit`/`level`/`scope`/`model`/`date` без ссылки) тоже переноси дословно, не пытаясь мигрировать - миграцию делает `pre-deploy-audit` на своём прогоне.

```markdown
<img src="docs/cover.svg" width="720" alt="Brand">

<!-- audit:start -->
<p>
  <a href="docs/audit/latest.md"><img src="https://img.shields.io/badge/security_audit-passed-3fb950?style=flat" alt="security audit passed - full, leaks + code" /></a>
  <img src="https://img.shields.io/badge/date-2026--06--28-555?style=flat" alt="audit date" />
</p>
<!-- audit:end -->
```

---

## `## Стек` - единый формат (важно)

**Запрещено смешивать:** картинки-бейджи + plain-текст `Git · setuptools · mypy` в одной секции. Выглядит рвано.

**Правило:** каждая технология в стеке - **отдельный** `<img>` с `style=for-the-badge`. Одинаковый размер для всех.

- Есть logo в Simple Icons → добавь `logo=` и `logoColor=` (см. таблицу).
- Нет logo → тот же `style=for-the-badge`, **без** `logo=`, нейтральный цвет (`555555`, `2d3748`).
- Dev-only (pytest, ruff, mypy) - тоже бейджи, можно суффикс в label: `mypy_(dev)` или отдельный цвет `4A5568`.
- Все `<img>` - **внутри одного `<p>`** (GitHub-first: иначе бейджи разъезжаются по строкам). Много бейджей - просто продолжай внутри того же `<p>`, они перенесутся по ширине.
- `<p>` без `align` - можно и нужно для группировки. Запрещён только `<p align="center">` (центрирование).

```markdown
## Стек

<p>
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/pytest-0A9EDC?style=for-the-badge&logo=pytest&logoColor=white" alt="pytest" />
  <img src="https://img.shields.io/badge/ruff-D7FF64?style=for-the-badge&logo=ruff&logoColor=black" alt="ruff" />
  <img src="https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white" alt="Git" />
  <img src="https://img.shields.io/badge/setuptools-555555?style=for-the-badge" alt="setuptools" />
  <img src="https://img.shields.io/badge/mypy-2C5282?style=for-the-badge" alt="mypy" />
</p>
```

В `## Стек` - только `<img>` for-the-badge (не `![]()`), всё внутри `<p>`.

---

## logo-map (Simple Icons → `logo=`)

| Технология | logo= | Цвет |
|------------|-------|------|
| TypeScript | `typescript` | `3178C6` |
| JavaScript | `javascript` | `F7DF1E` |
| Node.js | `nodedotjs` | `339933` |
| Python | `python` | `3776AB` |
| Git | `git` | `F05032` |
| pytest | `pytest` | `0A9EDC` |
| ruff | `ruff` | `D7FF64` |
| React | `react` | `20232A` |
| Vue | `vuedotjs` | `4FC08D` |
| Astro | `astro` | `BC52EE` |
| Vite | `vite` | `646CFF` |
| Next.js | `nextdotjs` | `000000` |
| NestJS | `nestjs` | `E0234E` |
| FastAPI | `fastapi` | `009688` |
| Django | `django` | `092E20` |
| Docker | `docker` | `2496ED` |
| PostgreSQL | `postgresql` | `4169E1` |
| Redis | `redis` | `DC382D` |
| SQLite | `sqlite` | `003B57` |
| Elasticsearch | `elasticsearch` | `005571` |
| Turborepo | `turborepo` | `EF4444` |
| pnpm | `pnpm` | `F69220` |
| npm | `npm` | `CB3837` |
| GitHub Actions | `githubactions` | `2088FF` |
| Cloudflare | `cloudflare` | `F38020` |
| Telegram / aiogram | `telegram` | `26A5E4` |
| Rust | `rust` | `000000` |
| Go | `go` | `00ADD8` |
| Tailwind CSS | `tailwindcss` | `06B6D4` |
| Monaco / VS Code | `visualstudiocode` | `007ACC` |
| Kubernetes | `kubernetes` | `326CE5` |
| Nginx | `nginx` | `009639` |
| Celery | `celery` | `37814A` |
| RabbitMQ | `rabbitmq` | `FF6600` |
| Kafka | `apachekafka` | `231F20` |
| PyTorch | `pytorch` | `EE4C2C` |
| OpenAI | `openai` | `412991` |

### Без logo в Simple Icons

Тот же `style=for-the-badge`, neutral цвет:

```markdown
<img src="https://img.shields.io/badge/Zod-3E67B1?style=for-the-badge" alt="Zod" />
<img src="https://img.shields.io/badge/setuptools-555555?style=for-the-badge" alt="setuptools" />
<img src="https://img.shields.io/badge/mypy-2C5282?style=for-the-badge" alt="mypy" />
<img src="https://img.shields.io/badge/sql.js-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="sql.js" />
```

Подчёркивание в label = пробел: `TanStack_Router`.

## Порядок

1. Язык / runtime · 2. UI / framework · 3. build / tooling · 4. backend / data · 5. infra · 6. dev (pytest, ruff…).

## Чеклист

- [ ] В `## Стек` **только** for-the-badge `<img>` внутри `<p>`, без plain-строки через `·`.
- [ ] Каждый бейдж = реальная зависимость.
- [ ] Header - 4 бейджа `<img style=flat>` внутри одного `<p>`: Runtime · Platform · Category · LoC; `for-the-badge` только в `## Стек`.
- [ ] LoC - 4-й бейдж в `<p>`-группе header, в маркерах, обновлён через `code-counter` → один ряд на GitHub.
- [ ] Cover для GitHub - `docs/cover.svg` + `<img>` (inline `<svg>` GitHub вырезает).
- [ ] `<p>` без `align`; центрирование (`align="center"`) запрещено.
- [ ] Блок `<!-- audit:start -->…<!-- audit:end -->` (если был) перенесён дословно после cover; `href` и дата не тронуты; `docs/audit/` не изменён.
