# Client-side and browser hunting

## When to use

Используй для DOM, browser messaging, webview, UI redress, client-side storage,
prototype pollution и обработчиков внешних URL.

## Классы

- DOM XSS через `innerHTML`, template sinks, URL/hash/message и unsafe Markdown;
- postMessage/origin confusion, wildcard target и отсутствие source binding;
- clickjacking/UI redress, opener/tabnabbing и небезопасные redirects;
- prototype pollution через merge/query/parser до security-sensitive consumer;
- webview bridge и custom scheme с лишней native authority;
- токены в local storage, cache или error surface при доказанном cross-principal
  чтении.

## Validation rules

Trace input до executing sink и докажи affected principal. Auto-escaping,
Trusted Types, CSP, origin check и sanitizer учитывай на реальном path. Наличие
неэкранированной строки без достижимого render context - не подтверждение.
