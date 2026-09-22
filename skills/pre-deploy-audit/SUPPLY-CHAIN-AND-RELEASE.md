# Supply chain and release hunting

## When to use

Используй, когда проект разрешает зависимости, CI contributions, build artifacts,
signing, publication, plugins или self-update.

## Классы

- namespace confusion, fallback registry и dependency substitution;
- mutable branch/tag/action/container/download без trusted identity;
- generated source, vendored archive и build context с лишними данными;
- untrusted PR/issue/dependency event в privileged workflow;
- command/expression injection через branch, message, matrix, artifact или path;
- cache/artifact/workspace trust mixing и over-broad CI identity;
- build-to-promotion substitution, weak signing binding и rollback confusion;
- plugin/update hook до проверки publisher, capability и authenticity.

## Validation rules

Назови lower-trust writer, consuming trusted job/updater и конкретный unauthorized
publication, code inclusion, secret disclosure или privileged execution. Mutable
dependency сам по себе не finding. Registry, hosted runner и signing facts, не
наблюдаемые локально, остаются `needs_validation`. Не публикуй и не меняй real
release, используй harmless fixture и dummy credential marker.
