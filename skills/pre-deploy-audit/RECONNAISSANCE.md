# Reconnaissance

Фаза 1 полного режима. Цель - построить карту архитектуры и детерминированный
план покрытия до поиска уязвимостей. Разведка читает исходники, тесты и локальные
конфиги. Она не обращается к развернутым endpoint'ам, облачным API, registry,
identity provider или общим сервисам.

## Четыре независимых прохода

Запускай их параллельно там, где платформа поддерживает подагентов. Каждый
возвращает факты с `file:line`, не пишет в общий каталог и не запускает target code.

### 1. Продукт и локальная эксплуатация

- назначение продукта, пользователи, операторы и чувствительные действия;
- языки, фреймворки, сборка, runtime и видимые варианты запуска;
- точки входа, подсистемы и границы;
- офлайн-команды тестов/сборки, их каталоги записи и обрабатываемые входы;
- отсутствующие локальные toolchain/runtime-факты, блокирующие проверку.

### 2. Principals, authority и controls

- каждый lower-trust principal и разрешенные действия;
- аутентификация на каждой поверхности;
- проверка прав на ресурс, tenant/owner scope;
- authority процесса, браузера, CI, plugin, модели/tool и local IPC;
- повышение/отзыв привилегий, подтверждение, recovery и fallback;
- какие controls видны в исходниках, а какие зависят от deployment.

### 3. Entry surfaces, copies и sinks

Инвентаризируй HTTP/browser, RPC/message, файлы/архивы, CLI/env/config,
plugins/dependencies/CI, cloud events/IAM, model/tool arguments, mobile/deep-link,
webview и local IPC. Для каждой поверхности пройди основные преобразования,
сохраненные копии, параллельные пути и security-relevant sinks.

### 4. Локальное выполнение и deployment visibility

- offline fixtures и маленькие тесты с dummy principals;
- допустимый isolated loopback без внешней сети;
- команды, которые скачивают зависимости, публикуют артефакты или меняют shared state;
- не наблюдаемые в репозитории deployment controls;
- возможность enforce'ить read-only target, empty allowlisted environment,
  scratch-only writes, resource limits и безопасную promotion артефактов.

Если обязательный проход не помещается в бюджет, не скрывай дыру: создай unit со
статусом `deferred` и причиной `budget_cannot_reserve_critics_and_validation`.

## Архитектура

Родительский агент пишет `architecture.md` не длиннее примерно 1000 слов:

1. продукт, principals, нормальная authority и защищаемые ресурсы;
2. стек, source-visible deployment paths и ограничения офлайн-проверки;
3. surfaces и важные source-to-sink/lifecycle paths;
4. trust boundaries и самый сильный видимый control на каждой границе;
5. стартовые пути и пробелы прошлых прогонов;
6. выбранные companion-файлы из [ATTACK-CLASSES.md](ATTACK-CLASSES.md).

Не называй `auth reviewed` покрытием. Покрытие доказывается только unit ledger и
его `reviewed_paths`/`local_checks`.

## Prior runs

До назначения hunter'ов прочитай совместимые `coverage-ledger.json` и
`findings.json` прошлых запусков:

- unchanged `confirmed` переносится в текущие candidates только после проверки
  текущего source и условий, а затем проходит новую независимую верификацию;
- changed-source, `needs_validation`, `blocked`, `deferred` и `out_of_scope` всегда
  становятся текущей работой;
- `rejected` подавляет только тот же самый опровергнутый claim, а не coverage unit;
- несовместимый или отсутствующий ledger фиксируется как ограничение, а не как
  «пустое покрытие».

## Coverage ledger

Ledger - JSON-массив unit'ов. Один unit соответствует существенной комбинации
`surface × boundary × subsystem × attack_class` и, если нужно, `lifecycle`.
`coverage_id` строится из canonical refs через RFC 3986 percent-encoding:

```text
encode(surface)::encode(boundary)::encode(subsystem)::encode(attack_class)[::encode(lifecycle)]
```

Не включай в ID номер волны, агента, severity или номер строки. Поля и допустимые
статусы проверяет `validate-coverage-ledger.cjs` после создания и после каждого
изменения ledger.
