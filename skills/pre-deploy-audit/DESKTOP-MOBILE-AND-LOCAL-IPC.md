# Desktop, mobile and local IPC hunting

## When to use

Используй для deep links, exported components, webviews, helper/daemon,
named pipes, Unix sockets, local files и same-device IPC.

## Классы

- deep-link/path/query injection до privileged action;
- exported activity/service, custom URL scheme и missing caller verification;
- local socket/pipe message identity, permissions и request correlation;
- webview-to-native bridge с лишними capabilities;
- helper update/launch, local config и symlink/path confusion;
- cross-user/device profile data leakage.

## Validation rules

Назови local attacker principal, OS boundary, effective identity и target resource.
Permissions, packaging и platform defaults, не видимые в репозитории, не угадывай.
Используй dummy profile и bounded local fixture.
