# Vulnerability Hunting

Фаза 2 полного режима. Parent назначает `planned` units из ledger отдельным
изолированным hunter'ам. Hunter не пишет исходники, общий ledger или retained
artifacts. Один агент может взять близкие units одной подсистемы, но поверхность
или trust boundary нельзя молча пропустить из-за лимита агентов.

## Приоритет

Сначала проверяй:

1. unauthenticated и cross-tenant surfaces;
2. sinks с высоким impact: code execution, authz, secrets, data export, release;
3. новые или измененные paths;
4. retry, queue, batch, resume, fallback и error paths;
5. hardening и positive patterns после boundary-sensitive работы.

Каждому unit передавай ordinary attack class и только применимые companion-блоки.
Не выбирай файл только по названию зависимости: нужен source-visible boundary из
его секции `When to use this file`.

## Контракт hunter'а

Hunter возвращает ровно один JSON-объект, без prose:

```json
{
  "agent_id": "hunter-1",
  "checks": [
    {
      "coverage_id": "...",
      "reviewed_paths": ["src/router.ts"],
      "method": "source",
      "artifact": null,
      "invariant": "Каждый объект проверяет owner или tenant.",
      "result": "Проверка отсутствует на delete path."
    }
  ],
  "candidates": [
    {
      "fingerprint": "src-router-delete-missing-owner",
      "verdict": "needs_validation",
      "title": "Проверка owner отсутствует на delete path",
      "trace": [{"kind":"entrypoint","file":"src/router.ts","line":42,"scope":"deleteUser","description":"Принимает id пользователя."}],
      "evidence": [{"file":"src/router.ts","line":47,"description":"Вызывает delete без видимой проверки владельца."}],
      "blockers": ["Deployment authentication middleware не виден в репозитории."],
      "validation_plan": {"local":"Вызвать handler с двумя dummy principals и двумя dummy records."}
    }
  ],
  "hardening": ["Проверка tenant scope единообразна в read path."]
}
```

`confirmed` допускается только при полном source trace и bounded local result.
Если decisive fact находится в hosted proxy, identity provider, registry или
runtime, оставь `needs_validation` с точным blocker. Generic «похоже опасно» не
является находкой.

## Coverage critic

После волны parent запускает свежего critic'а. Он проверяет:

- каждый unit получил check или точную причину `blocked`/`deferred`;
- `reviewed_paths` и local artifacts принадлежат текущему owner;
- no silent overlap и no silent omission;
- для каждой surface были рассмотрены relevant attack classes и lifecycle paths;
- candidate fingerprint стабилен и не скрывает вторую root cause.

Критик может создать новые units или вернуть unit в очередь. Перед повторным
назначением сохрани предыдущую попытку в `attempts`, назначь свежего owner и не
переноси его evidence в live state. Запусти `validate-coverage-ledger.cjs`.

## Безопасность запуска

Target-controlled build/test/process разрешен только в sandbox с no external
network, empty allowlisted environment, read-only target/toolchain, scratch-only
writes и явными CPU/memory/process/file/disk/time limits. Данные только dummy.
Если это нельзя обеспечить, не запускай код и фиксируй `needs_validation`.
