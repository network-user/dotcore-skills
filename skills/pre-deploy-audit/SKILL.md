---
name: pre-deploy-audit
description: >-
  Единый аудит репозитория перед деплоем, релизом или сменой видимости на public.
  Трек УТЕЧКИ ищет секреты, ключи, PII и историю git; трек КОД проверяет trust
  boundaries и уязвимости. Полный режим добавляет coverage-led workflow Cloudflare:
  recon, ledger, hunting, независимую валидацию, findings.json и target-neutral
  отчёты. Секреты не печатаются; Critical/High или незавершённое покрытие не дают
  PASS. Use when просят аудит безопасности, найти уязвимости, проверить утечки,
  репозиторий перед деплоем/релизом или публикацией.
---

# Pre-Deploy Audit

Проверка репозитория перед деплоем или публикацией: что нельзя выкатывать (утечки) и что в коде небезопасно (уязвимости). Результат - вердикт и, на PASS или PASS WITH WARNINGS, отчёт в `docs/audit/` (снимок «дата-кодовое-слово» + `latest.md`) плюс кликабельные на него бейджи аудита в README.

Главное правило: **читай репозиторий, не выдумывай**. Источник правды - сам код, конфиги, история git. Не выводи значения секретов - детект по факту и маске (см. [Безопасность данных аудита](#безопасность-данных-аудита)).

## Режимы работы

- **Guidance** - вопрос по одной уязвимости или узкой области. Читай только
  применимые части, не создавай полный run и не запускай весь workflow.
- **Pre-deploy** - проверка перед деплоем/релизом: по умолчанию оба трека на
  среднем уровне, итогом остаются локальные Markdown-отчёт и бейдж только на PASS
  или PASS WITH WARNINGS.
- **Full security audit** - явный запрос «полный аудит», «проверь весь код»,
  «найди уязвимости», «pen-test» или запрос машинных артефактов. Запускай все
  шесть фаз из [RECONNAISSANCE.md](RECONNAISSANCE.md), [HUNTING.md](HUNTING.md) и
  [VALIDATION-AND-REPORTING.md](VALIDATION-AND-REPORTING.md).

Если запрос неясен между guidance и полным аудитом, уточни это одним вопросом до
создания артефактов. Для узкого запроса не запускай дорогой полный проход.

## Безопасность выполнения

Исходники читаются read-only. Target-controlled build, test, process, browser,
fuzzer и fixture разрешены только в OS-enforced sandbox со всеми условиями:

- внешняя сеть отключена; допустим только изолированный loopback;
- empty environment с явным allowlist, dummy principals и dummy secrets;
- target и toolchain read-only, запись только в назначенный `scratch/`;
- явные лимиты CPU, памяти, процессов, файлов, диска и времени;
- зависимости не устанавливаются и не скачиваются;
- live endpoints, production identities, shared services, paid API и release
  control plane не трогаются.

Если хотя бы один контроль нельзя обеспечить, код не запускай. Зафиксируй точный
blocker как `needs_validation` и предложи безопасный owner-observed план.

В полном режиме общий run-каталог находится вне target по умолчанию. Внутри
репозитория его можно выбрать только явно и только после проверки, что весь путь
игнорируется системой контроля версий. Parent - единственный писатель общих файлов:
`run-metadata.json`, `architecture.md`, `coverage-ledger.json`, `findings.json`,
`REPORT.md`, `FINDINGS-DETAIL.md`, `NEEDS-VALIDATION.md`. Правила scratch,
artifact promotion и безопасность запуска подробно описаны в [execution-safety.md](execution-safety.md)
и [VALIDATION-AND-REPORTING.md](VALIDATION-AND-REPORTING.md).

## Два трека (это разное)

Не смешивай две задачи - у них разная цена и метод:

- **Трек A. Утечки и экспозиция данных** - секреты, приватные ключи, токены, credentials, PII, machine-paths, закоммиченные `.env`, **история git**. Детект по паттернам и путям, **не требует понимания логики кода**. Это ответ на «проверь на утечки» и «перед сменой видимости на public». Детали: [track-leaks.md](track-leaks.md).
- **Трек B. Безопасность кода** - уязвимости в логике: инъекции, `eval`/`exec`, небезопасная десериализация, SSRF, path traversal, authz/IDOR, крипто-мисюз, небезопасные дефолты. **Требует чтения и понимания кода.** Это ответ на «проверь весь код на проблемы с безопасностью». Детали: [track-code.md](track-code.md).

«Проверить на утечки» ≠ «проаудитить весь код». Не гоняй дорогой трек B, когда просят только трек A, и не ограничивайся паттерн-сканом, когда просят аудит кода.

## Три уровня (глубина)

| Уровень | Трек A (утечки) | Трек B (код) | Подагенты |
|---------|-----------------|--------------|-----------|
| **Поверхностный** | working tree: секреты, ключи, `.env`, `.gitignore`, machine-paths | только явные флаги (`eval`/`exec`, hardcoded creds), без глубокого чтения | нет, линейно |
| **Средний** | working tree целиком + экспозиция (порты, CORS, дефолты) | ревью критичных и изменённых областей + зависимости | 2-4 параллельно |
| **Полный** | + **история git** + PII + supply chain | **вся кодовая база** по coverage units, семантический source-to-sink разбор + инфра/CI | веер 6-10 + candidate и record verify |

Полная матрица и тайминги: [levels.md](levels.md).

## Фокус: как выбрать уровень и трек

| Запрос пользователя | Трек | Уровень |
|---------------------|------|---------|
| «проверь на утечки», «нет ли секретов» | A | поверхностный или средний |
| «делаю репо публичным», «меняю видимость на public» | A (обязательно с **историей git**) | полный по треку A; код - по желанию |
| «быстро глянь перед деплоем» | A + B (явные флаги) | поверхностный |
| «проверь перед релизом» | A + B | средний (дефолт) |
| «полный аудит безопасности», «проверь весь код» | A + B | полный |

Уровень не задан явно - **по умолчанию средний** (оба трека). Для смены видимости на public всегда включай историю git (секрет, удалённый из рабочего дерева, остаётся в истории и утечёт). Если запрос неоднозначен между «утечки» и «весь код» - уточни одним вопросом, не угадывай.

## Workflow

1. **Scope** - определи уровень и фокус (таблица выше). Зафиксируй: что проверяем (треки) и насколько глубоко.
2. **Recon** - инвентарь: `git ls-files`, языки/стек, точки входа, конфиги, `.gitignore`, `LICENSE`, CI. Без чтения secret-named файлов.
3. **Audit** - прогон треков по уровню. Средний/полный - **веер подагентов по измерениям** ([orchestration.md](orchestration.md)). Каждый record структурирован: verdict, fingerprint, trace, file:line, категория, **маскированная** улика, рекомендация; `needs_validation` severity не получает.
4. **Verify** (средний/полный) - adversarial-проверка каждой находки Critical/High. В
   полном security-аудите свежий verifier получает каждый уникальный candidate,
   затем отдельный verifier проверяет каждый финальный `confirmed` и
   `needs_validation`. Material replacement проходит ещё одну независимую проверку.
5. **Verdict** - severity + готовность по [report.md](report.md). Гейт:
   **Critical/High = провал**; незакрытые обязательные units, candidate без
   verifier или incomplete run не маскируются под PASS.
6. **Stamp** (только на PASS или PASS WITH WARNINGS) - запиши снимок `docs/audit/{дата}-{слово}.md` + `docs/audit/latest.md` и впиши в README блок: кликабельный бейдж `security_audit` (→ `latest.md`) + кликабельный `date` (→ снимок), по [badge.md](badge.md). Если в README старый 5-бейджевый блок - мигрируй его в новый формат (см. badge.md). Картинки нет.

## Полный security-аудит: шесть фаз

1. **Recon** - parent фиксирует `run-metadata.json`, source ref, dirty state,
   scope, profile и budget; четыре независимых прохода строят `architecture.md`.
2. **Coverage** - parent создаёт и валидирует `coverage-ledger.json` с unit'ами
   `surface × boundary × subsystem × attack_class`. Перед promotion запускай
   `validate-coverage-ledger.cjs --final`: открытые `planned`, `in_progress`,
   `candidate` и `blocked` units запрещены.
3. **Hunting** - hunter waves проверяют units, coverage critic находит пропуски и
   возвращает незакрытые области в очередь или в `deferred`.
4. **Candidate validation** - свежий verifier решает `confirmed`,
   `needs_validation` или `rejected` для каждого уникального fingerprint.
5. **Record verification** - независимые verifier'ы перепроверяют финальные records;
   schema и ledger валидируются после каждой замены.
6. **Reporting** - из проверенных JSON строятся три target-neutral отчёта. Только
   завершённый проход с закрытым обязательным покрытием может дать локальный PASS.

Машинные контракты: [report-schema.json](report-schema.json),
[validate-findings.cjs](validate-findings.cjs),
[validate-coverage-ledger.cjs](validate-coverage-ledger.cjs). Доменные классы
выбираются по recon из [ATTACK-CLASSES.md](ATTACK-CLASSES.md) и companion-файлов.

## Подагенты (Claude Code и Cursor)

Аудит делится на независимые измерения - **запускай подагентов параллельно**, не последовательно. Это прямое правило, а не опция.

- **Когда веером:** средний - 2-4 подагента, полный - 6-10 + проверочные. Поверхностный и крошечный репозиторий (< ~20 файлов) - линейно, без подагентов.
- **Деление по измерениям:** секреты, история git, PII, инъекции, десериализация/exec, authz/крипто, зависимости/supply chain, инфра/CI. В полном режиме дополнительно назначай coverage units `surface × boundary × subsystem × attack_class`. Одно измерение или близкая группа units - один подагент, все независимые вызовы в одном сообщении.
- **Claude Code:** инструмент Task/Agent; для тяжёлого поиска - Explore. Параллельные вызовы в одном сообщении, при желании `run_in_background`.
- **Cursor:** нет примитива подагентов - гоняй измерения последовательно в один проход (или background-агентами, если доступны), но с той же структурой находок и проверочным шагом.
- **Codex / прочие:** последовательный fallback, структура находок та же.

Схемы вызова, parent-only writes и adversarial-проверка: [orchestration.md](orchestration.md).

## Severity и гейт

| Severity | Что это | Влияние на бейдж |
|----------|---------|------------------|
| **Critical** | живой секрет/ключ в дереве или истории; RCE; публичный доступ к данным | провал, бейджа нет |
| **High** | вероятная уязвимость с реальным impact (инъекция, authz-обход) | провал, бейджа нет |
| **Medium** | слабое место без прямого impact; небезопасный дефолт | PASS WITH WARNINGS |
| **Low / Info** | гигиена, hardening, рекомендации | PASS |

Для публикации (`public`): любой секрет в рабочем дереве **или истории** = Critical автоматически, даже если выглядит «тестовым». Подробно: [report.md](report.md).

## Безопасность данных аудита

Жёсткие правила (перекрывают удобство):

- **Не открывай** файлы, в имени/пути которых есть `secret`, `token`, `credential`, `password`, `private`, а также `.env*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`. Детект - по факту существования + паттерну, без чтения содержимого.
- **Никогда не выводи значение секрета.** В улике - маска: первые/последние 2 символа, остальное `…`. В отчёт идёт `file:line` + категория, не сам секрет.
- **Не правь историю git и не удаляй файлы автоматически.** Только рекомендация пользователю (ротация ключа в первую очередь, затем `git filter-repo`/BFG вручную).
- **Не выполняй live-проверки.** Отсутствие sandbox, внешняя deployment policy или недоступный provider - blocker для `needs_validation`, а не повод угадать ответ.
- **Не принимай вывод агента как артефакт.** Scratch принадлежит конкретному агенту; parent продвигает только заранее объявленный regular file с проверенным относительным путём и размером.
- **Минимальный diff.** Аудит читает; не рефактори и не «чини» код по ходу. Правки - только блок бейджа в README и файлы `docs/audit/` на PASS.

## Self-check

- [ ] Уровень и фокус (треки) определены по запросу; для `public` включена история git
- [ ] Трек A и трек B не смешаны; дорогой код-аудит не запущен там, где просили только утечки
- [ ] Средний/полный - подагенты веером по измерениям, не линейно; full использует coverage units
- [ ] Critical/High прошли adversarial-проверку; full проверил каждый candidate и финальный record
- [ ] Ни одно значение секрета не выведено; улики маскированы
- [ ] Вердикт по [report.md](report.md); гейт Critical/High соблюдён
- [ ] Full: `findings.json` и `coverage-ledger.json` прошли zero-dependency validators
- [ ] Full: `confirmed`, `needs_validation`, `rejected` не смешаны; incomplete и deferred раскрыты
- [ ] Бейдж и `docs/audit/latest.md` выданы только на PASS или PASS WITH WARNINGS; при FAILED/INCOMPLETE бейдж снят, `latest.md` не записан
- [ ] Старый 5-бейджевый блок (если был) мигрирован в новый формат: кликабельный `security_audit` + `date`
- [ ] Правок кода нет; изменены только README (блок бейджа в маркерах) и файлы `docs/audit/` на PASS

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Workflow (этот файл) |
| [levels.md](levels.md) | Три уровня × два трека: матрица, фокус, тайминги |
| [track-leaks.md](track-leaks.md) | Трек A: утечки, секреты, ключи, PII, история git, pre-public |
| [track-code.md](track-code.md) | Трек B: уязвимости кода по категориям |
| [orchestration.md](orchestration.md) | Подагенты: веер, схема находок, adversarial-проверка (Claude/Cursor) |
| [report.md](report.md) | Severity, готовность, гейт, формат отчёта |
| [badge.md](badge.md) | Цветные flat-бейджи аудита, вставка в README |
| [RECONNAISSANCE.md](RECONNAISSANCE.md) | Full: архитектура, trust boundaries, prior runs, coverage ledger |
| [HUNTING.md](HUNTING.md) | Full: hunting waves, structured hunter contract, coverage critic |
| [VALIDATION-AND-REPORTING.md](VALIDATION-AND-REPORTING.md) | Full: candidate/record verification, artifacts, target-neutral reports |
| [execution-safety.md](execution-safety.md) | Sandbox, scratch, artifact promotion и запрет live-проверок |
| [ATTACK-CLASSES.md](ATTACK-CLASSES.md) | Ordinary и companion attack classes; выбор по source-visible boundary |
| [report-schema.json](report-schema.json) | Контракт `confirmed` / `needs_validation` / `rejected` |
| [validate-findings.cjs](validate-findings.cjs) | Zero-dependency validator `findings.json` |
| [validate-coverage-ledger.cjs](validate-coverage-ledger.cjs) | Zero-dependency validator coverage ledger |
| [NOTICE.md](NOTICE.md) | MIT-атрибуция Cloudflare и границы локальной адаптации |
| [README.md](README.md) | Описание для людей, установка, триггеры |
| [codex-prompt.md](codex-prompt.md) | Промпт `/pre-deploy-audit` для Codex |
