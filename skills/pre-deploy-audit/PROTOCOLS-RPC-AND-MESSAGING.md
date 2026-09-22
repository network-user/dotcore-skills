# Protocols, RPC and messaging hunting

## When to use

Используй для RPC, serialization, queue, broker, webhook, streaming и message
dispatch boundaries.

## Классы

- parser differential, duplicate fields, type confusion и unsafe deserialization;
- missing request correlation, channel/tenant confusion и response mix-up;
- webhook signature/replay, timestamp, canonicalization и secret scope;
- queue visibility, ack/retry, duplicate delivery и poison message;
- broker topic/consumer ACL, wildcard routing и cross-tenant subscription;
- stream backpressure, partial frame, cancellation и resource amplification.

## Validation rules

Отследи authenticated channel, message identity, correlation и effective consumer.
Покажи, как lower-trust sender доходит до чужого handler/resource. Брокерные ACL
и managed-service defaults, не видимые в репозитории, фиксируй как blocker.
