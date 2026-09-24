# Web protocol and authentication hunting

## When to use

Используй для HTTP parser, proxy/origin boundary, cache, cookies, sessions,
headers, CORS и token-based authentication.

## Классы

- request smuggling, framing disagreement и parser differential между слоями;
- cache poisoning/deception, key confusion, unkeyed headers и cross-user cache;
- origin/host/scheme confusion, CORS и trusted proxy header;
- session fixation, token audience/issuer/expiry и logout/revocation gaps;
- password reset/recovery, CSRF, replay, nonce и method override;
- upload/content-type/redirect/header injection с реальным downstream effect.

## Validation rules

Назови каждый parser/proxy слой и докажи разное понимание одного сообщения.
Deployment-only proxy behavior не угадывай. Для auth claims проверь effective
principal, resource authorization и replay/expiry condition; неизвестную
конфигурацию отправь в `needs_validation`.
