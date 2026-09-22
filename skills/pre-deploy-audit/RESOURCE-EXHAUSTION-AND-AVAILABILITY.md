# Resource exhaustion and availability hunting

## When to use

Используй для body/file limits, queues, workers, recursion, retries, fan-out,
quotas, cancellation и operator/API spend.

## Классы

- unbounded input, decompression/parser amplification и recursive expansion;
- retry storm, duplicate queue work, missing idempotency и batch fan-out;
- per-user quota отсутствует при shared resource или paid operation;
- worker/process/file descriptor leak и cancellation race;
- маленький запрос вызывает непропорциональный durable state или cost.

## Validation rules

Докажи accounting path и affected shared resource через source или bounded local
fixture. Не исчерпывай сервис и не создавай live load. Общий «может упасть» без
reachable amplification остается hardening или `needs_validation`.
