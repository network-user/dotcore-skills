# Validation, Structured Output and Reporting

Фазы 3-6 полного режима. Они отделяют candidate от confirmed и не позволяют
красивому тексту hunter'а стать доказательством.

## Фаза 3. Независимая проверка candidates

Каждую уникальную candidate по fingerprint получает свежий verifier, который не
искал её. Он заново читает все cited `file:line`, восстанавливает полный путь,
проверяет identity/authz/normalization/containment controls и воспроизводит только
минимальный безопасный local result.

Решения:

- `confirmed` - source trace и bounded result подтверждают реальный boundary failure;
- `needs_validation` - конкретный decisive fact находится вне source/local scope;
- `rejected` - trace, control, prerequisite или impact опровергает claim.

`needs_validation` не получает severity и не называется уязвимостью. Это точный
lead для владельца, а не контейнер для догадок.

## Фаза 4. findings.json

Parent единолично пишет `findings.json`, сортирует записи по fingerprint и сразу
запускает:

```text
node <skill-dir>/validate-findings.cjs <run-dir>/findings.json
node <skill-dir>/validate-coverage-ledger.cjs <run-dir>/coverage-ledger.json
```

Контракт описан в [report-schema.json](report-schema.json). Ветки не смешиваются:

| verdict | Обязательная суть | Запрещено добавлять |
|---|---|---|
| `confirmed` | root cause, trace, evidence, execution, remediation, severity, confidence | blockers и validation_plan |
| `needs_validation` | claimed root cause, trace, evidence, blockers, validation plan | severity и execution |
| `rejected` | claimed root cause, trace, evidence, reason | severity и remediation |

Схема использует `additionalProperties: false`. Malformed JSON, prose вокруг
объекта, чужие wrapper-поля, небезопасные пути и записи без boundary должны быть
отброшены и перезапущены свежим verifier'ом, а не «починены» parent'ом молча.

## Фаза 5. Независимая проверка финальных records

После валидатора запусти отдельного `research` verifier на каждый финальный
`confirmed` и `needs_validation`. Он проверяет сам record, а не write-up hunter'а:

1. все пути, номера строк, scope и описанные операции;
2. настоящий entry interface и форму локального ввода;
3. controls, условия и observed result;
4. affected principal/resource и demonstrated impact;
5. соответствие severity impact и минимальность remediation;
6. точность blocker и validation plan для `needs_validation`.

`verified` оставляет record. `replace` должен снова пройти валидатор. Любая
замена, которая усиливает verdict, меняет root cause/trace/impact/severity или
добавляет decisive result, требует еще одного свежего verifier'а. Если его нет,
record убирается из findings, unit остается unresolved, run становится
`incomplete`.

## Фаза 6. Отчеты

Только после независимой проверки derive из финальных records и ledger:

- `REPORT.md` - профиль, scope, budget, source ref, sandbox policy, coverage,
  confirmed table, отдельная таблица needs validation, hardening и positive patterns;
- `FINDINGS-DETAIL.md` - полный trace и bounded reproduction для Medium/High/Critical;
- `NEEDS-VALIDATION.md` - blocker и безопасный local/owner-observed план без severity.

В отчете не называй `rejected` findings. `quick`, scoped, budget-limited и
incomplete run прямо помечаются частичным охватом. Один запуск никогда не
объявляется исчерпывающим только из-за отсутствия подтвержденных находок.

## Promotion artifacts

Agent и target code пишут только в собственный `scratch/`. Parent может продвинуть
только заранее объявленный regular file в `artifacts/` после завершения процесса:

1. проверить относительный путь без `..`, абсолютных компонентов и symlink;
2. открыть leaf без follow и проверить regular file, link count 1 и byte limits;
3. прочитать ровно проверенный размер и повторить проверку identity/size;
4. создать destination leaf эксклюзивно, без follow, и скопировать из уже открытых
   дескрипторов;
5. при недоступности race-safe проверки отбросить artifact и оставить blocker.

Нельзя glob/recursive-copy scratch, извлекать архивы, принимать FIFO/socket/device,
hard link или changing file как evidence. Это правило действует и для hunter'ов,
и для verifier'ов.
