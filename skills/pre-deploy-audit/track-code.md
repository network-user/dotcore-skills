# Трек B - безопасность кода

Цель: найти **уязвимости в логике**. Метод - чтение кода и разбор потока данных (source → sink), не только греп. Это «проверка всего кода на проблемы с безопасностью».

Дорогой трек. Не запускай вглубь, когда просили только утечки (трек A). На полном уровне - веер подагентов по модулям и категориям ([orchestration.md](orchestration.md)).

В полном режиме это coverage-led source-first аудит, а не длинный grep. Сначала
зафиксируй lower-trust principal, accepted input/action, intended control,
crossed boundary, affected resource и concrete result. Затем создай unit
`surface × boundary × subsystem × attack_class` и выбери применимые companion
правила из [ATTACK-CLASSES.md](ATTACK-CLASSES.md). Prompt injection, crash,
mutable dependency или missing header без boundary impact остаются hardening.

## Подход: source → sink

Уязвимость = недоверенный ввод (**source**) доходит до опасной операции (**sink**) без санитизации. Для каждой категории ищи sink, затем трассируй назад до source.

- **Source**: HTTP-параметры, тело запроса, заголовки, query, аргументы CLI, переменные окружения от пользователя, содержимое загруженных файлов, ответы внешних API, данные из БД, записанные пользователем.
- **Sink**: SQL-запрос, shell-команда, путь файла, URL для серверного запроса, шаблонизатор, десериализатор, генерация HTML.

## Категории

### 1. Инъекции

| Тип | Sink-паттерны |
|-----|---------------|
| SQL | конкатенация/`f"… {var}"`/`%`-формат в запрос; `.query(... + ...)`; raw SQL без параметров |
| Command | `os.system`, `subprocess(..., shell=True)`, `child_process.exec`, backticks, `Runtime.exec` с вводом |
| Template (SSTI) | пользовательский ввод в `render_template_string`, Jinja/Handlebars из строки |
| NoSQL | пользовательский объект напрямую в `find()`/`$where` |
| LDAP / XPath / header | ввод в фильтр/путь/заголовок без экранирования |

### 2. Исполнение кода и десериализация

`eval`, `exec`, `Function()`, `vm.runInContext`; `pickle.loads`, `yaml.load` (без `SafeLoader`), `marshal`, Java/PHP unserialize, `.NET BinaryFormatter` на недоверенных данных. Любой такой sink с source = High/Critical.

### 3. Path traversal и файлы

Пользовательский ввод в путь файла без нормализации (`../`), zip-slip при распаковке, неограниченная загрузка файлов (тип/размер/путь), запись по контролируемому пути.

### 4. SSRF и внешние запросы

Пользовательский URL/хост → серверный `fetch`/`requests.get`/`curl` без allowlist. Доступ к метаданным облака (`169.254.169.254`), внутренней сети.

### 5. Аутентификация и авторизация

- Отсутствие проверки доступа на эндпоинте; **IDOR** (объект по id без проверки владельца).
- Сломанная сессия, предсказуемые токены (`Math.random()`, `time()` для секрета).
- Hardcoded учётки, бэкдор-условия, обход по флагу.
- JWT: `alg: none`, отсутствие проверки подписи, секрет в коде.

### 6. Криптография

Слабые алгоритмы для паролей (`MD5`/`SHA1` без соли вместо bcrypt/argon2), ECB-режим, статический IV/соль, hardcoded ключ, самодельное шифрование, `http://` там где нужен TLS, отключённая проверка сертификата (`verify=False`, `rejectUnauthorized:false`).

### 7. Небезопасные дефолты и конфиг

`DEBUG=True`/`development` в проде, CORS `*` с credentials, открытая привязка `0.0.0.0` без необходимости, дефолтные пароли, listing директорий, подробные стектрейсы наружу, отключённые security-заголовки.

### 8. Веб-вывод (XSS)

Неэкранированный пользовательский ввод в HTML, `dangerouslySetInnerHTML`, `innerHTML`/`v-html`/`eval`-шаблоны, `document.write` с данными.

### 9. Зависимости и supply chain

Известные уязвимости (если доступны - `npm audit`, `pip-audit`, `osv`; иначе - сверка версий с публичными advisories), устаревшие пакеты, typosquat-имена, `postinstall`-скрипты, незакреплённые версии, целостность lockfile.

### 10. Инфраструктура и CI (полный)

- **Dockerfile**: запуск от root, секреты в `ARG`/слоях/`ENV`, `latest`-теги, лишние пакеты, проброс `.env` в образ.
- **CI**: `pull_request_target` с checkout кода PR, эхо секретов в лог, инъекция в `run:` через `${{ github.event.* }}` от недоверенного источника, избыточные права `GITHUB_TOKEN`.

### 11. Бизнес-логика и state machine

- обход intended workflow через повтор, пропуск шага, смену статуса или replay;
- second-order/chained path: безопасный на входе объект становится опасным после
  storage, import, preview, export, search или webhook;
- feature abuse: массовый экспорт, приглашение, восстановление, preview, dry-run,
  bulk и fallback выполняют действие с другой authority;
- race между проверкой и side effect, queue/retry/resume, duplicate operation и
  stale authorization.

Не называй бизнес-правило уязвимостью без affected principal/resource и
наблюдаемого нарушения intended invariant.

### 12. Специализированные поверхности

Если recon показывает соответствующую границу, добавь companion-файл:

- AI/LLM/RAG/tool/MCP - [AI-AND-LLM.md](AI-AND-LLM.md);
- browser/DOM/webview - [CLIENT-SIDE.md](CLIENT-SIDE.md);
- HTTP parser/cache/auth - [WEB-PROTOCOL-AND-AUTH.md](WEB-PROTOCOL-AND-AUTH.md);
- RPC/queue/broker/webhook - [PROTOCOLS-RPC-AND-MESSAGING.md](PROTOCOLS-RPC-AND-MESSAGING.md);
- dependencies/CI/release/update - [SUPPLY-CHAIN-AND-RELEASE.md](SUPPLY-CHAIN-AND-RELEASE.md);
- cloud/IAM/IaC/container/serverless - [CLOUD-AND-DEPLOYMENT.md](CLOUD-AND-DEPLOYMENT.md);
- data isolation/lifecycle - [DATA-ISOLATION-AND-LIFECYCLE.md](DATA-ISOLATION-AND-LIFECYCLE.md);
- native/binary/FFI - [MEMORY-SAFETY-AND-BINARY.md](MEMORY-SAFETY-AND-BINARY.md);
- desktop/mobile/local IPC - [DESKTOP-MOBILE-AND-LOCAL-IPC.md](DESKTOP-MOBILE-AND-LOCAL-IPC.md).

## Уровни трека B

- **Поверхностный**: только греп явных sink (категории 1-2, 6-7 - hardcoded/`eval`/`shell=True`/`verify=False`). Без трассировки.
- **Средний**: ревью **критичных и изменённых** областей (точки входа, auth, ввод, БД/файлы/сеть) по категориям 1-8 + зависимости (9).
- **Полный**: **вся кодовая база** по модулям, трассировка source→sink по всем категориям + инфра/CI (10). Веер подагентов, затем adversarial-проверка находок Critical/High.

В полном security-аудите результат не считается complete без ledger: каждый unit
имеет terminal status, `reviewed_paths` и `local_checks`, а deferred/blocked/
out_of_scope раскрыты в отчёте. Уникальные candidates получают
`confirmed`/`needs_validation`/`rejected`, затем финальные records проходят
отдельную проверку. Контракт и валидаторы: [report-schema.json](report-schema.json),
[validate-findings.cjs](validate-findings.cjs),
[validate-coverage-ledger.cjs](validate-coverage-ledger.cjs).

## Замечания

- Привязывай находку к языку/фреймворку проекта - не репортуй питоновский `pickle` в Node-проекте.
- Для каждой High/Critical нужен правдоподобный путь эксплуатации (source → sink). Нет пути - это Medium/Low или false positive, проверь на шаге verify.
- Не «чини» код по ходу аудита (минимальный diff). Находка = описание + рекомендация, правки - отдельным запросом пользователя.
