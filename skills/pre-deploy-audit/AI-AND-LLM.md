# AI, LLM and agent hunting

## When to use

Используй, когда модель участвует в trust-sensitive решении: chatbot, RAG,
memory, tool-calling, MCP, prompt assembly или обработка model output.

## Core discipline

- Prompt injection не является находкой без code-level boundary failure.
- Model output, memory, tool descriptions и MCP responses - untrusted input.
- Guardrail prompt не заменяет deterministic authorization, isolation и scoped
  credentials.
- Разделяй authorization и action binding: approval должен связывать normalized
  tool, полный набор аргументов, principal, resource и expiry.

## Классы

- indirect injection через document, issue, email, tool response или RAG;
- cross-session/tenant context bleed и слишком широкий cache key;
- memory poisoning и потеря provenance при summarization;
- tool-argument injection в SQL, shell, file, URL и privileged API;
- excessive agency, confused deputy и schema/dispatcher disagreement;
- unbounded delegated loops, retry/resume mutation и duplicate side effects;
- MCP server/tool identity confusion и доверие metadata как policy;
- sensitive context extraction и unsafe rendering model output.

## Validation rules

Нужны attacker, affected principal/resource, execution identity, exact action и
наблюдаемый результат. Для memory/RAG докажи и attacker-controlled write, и
последующее cross-principal read. Для action binding сравни approved object с тем,
который handler реально исполняет. Внешний provider/model/runtime факт оставляй
`needs_validation`.
