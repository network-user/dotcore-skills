# Attack classes

Каркас выбора companion-проверок для полного режима. Ordinary classes применяются
к каждому unit, если boundary подходит. Companion-файл выбирается по source-visible
границе, а не по совпадению имени пакета.

## Core discipline

- Нужны lower-trust principal, вход/действие, intended control, crossed boundary,
  affected resource и наблюдаемый security result.
- Отклонение от best practice без impact - hardening, не vulnerability.
- Prompt injection, crash, mutable dependency, missing header или открытый порт сами
  по себе не находка. Нужен достижимый control failure.
- Не предполагай proxy, browser, IAM, registry, signing или provider behavior,
  которого нет в исходниках. Это `needs_validation`.
- Severity не выше доказанного impact. Local execution только в sandbox.

## Ordinary classes

### Access control and identity

Authentication bypass, IDOR, cross-tenant read/write, confused deputy, token
validation, session lifecycle, privilege change and revocation. Трассируй principal
от entrypoint до ресурса, включая batch, queue, retry и fallback.

### Injection, execution and deserialization

SQL/NoSQL/LDAP/template/command injection, `eval`/`exec`, unsafe YAML/pickle/
serialization, shell and expression construction. Ищи source-to-sink, а не только
опасный вызов. Без контролируемого lower-trust source это hardening.

### Files, URLs and output

Path traversal, zip-slip, unsafe upload, SSRF, metadata access, open redirect,
XSS/SSTI, unsafe Markdown/HTML/template output. Проверяй canonicalization,
allowlist, scheme/host/port, size limits и sink-specific encoding.

### Data isolation and lifecycle

Tenant/owner scope, cache/search/export, backup/restore, migration, delete and
retention. Проверь альтернативные query paths, shared cache keys, soft-delete,
replication and recovery, а не только основной CRUD.

### Resource exhaustion and availability

Unbounded body/file/queue/worker/recursion/cost, retry amplification, missing
per-principal quota, cancellation or idempotency. Подтверждай impact code-level
accounting'ом, не DoS-тестом против сервиса.

### Crypto and defaults

Hardcoded keys, weak password hashing, static IV, ECB, disabled TLS verification,
debug/default credentials, overly broad CORS, public bind and error disclosure.
Разделяй real boundary failure и обычный hardening.

## Companion files

| Source-visible boundary | Файл |
|---|---|
| AI/LLM, RAG, memory, tool или MCP | [AI-AND-LLM.md](AI-AND-LLM.md) |
| Browser, DOM, webview, messaging | [CLIENT-SIDE.md](CLIENT-SIDE.md) |
| HTTP framing, cache, auth protocol | [WEB-PROTOCOL-AND-AUTH.md](WEB-PROTOCOL-AND-AUTH.md) |
| RPC, queue, broker, webhook, stream | [PROTOCOLS-RPC-AND-MESSAGING.md](PROTOCOLS-RPC-AND-MESSAGING.md) |
| CI, dependencies, release, updater, plugin | [SUPPLY-CHAIN-AND-RELEASE.md](SUPPLY-CHAIN-AND-RELEASE.md) |
| IAM, IaC, container, serverless, ingress | [CLOUD-AND-DEPLOYMENT.md](CLOUD-AND-DEPLOYMENT.md) |
| native binary, parser, memory, kernel | [MEMORY-SAFETY-AND-BINARY.md](MEMORY-SAFETY-AND-BINARY.md) |
| desktop/mobile/deep-link/local IPC | [DESKTOP-MOBILE-AND-LOCAL-IPC.md](DESKTOP-MOBILE-AND-LOCAL-IPC.md) |

Каждый companion-файл содержит core discipline, классы, universal moves и
validation rules. Если граница не подходит, запиши её в `excluded_blocks` с
source-backed причиной, не оставляй молча.
