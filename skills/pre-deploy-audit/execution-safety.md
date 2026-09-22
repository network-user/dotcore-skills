# Execution safety

Этот файл применяется к любому запуску target-controlled code в полном режиме.
Source inspection остаётся read-only и не требует выполнения проекта.

## Обязательные controls

- no external network; только изолированный loopback для локальной client/server
  проверки;
- empty environment из явного allowlist, отдельные `HOME`, temp и cache;
- read-only target и toolchain, запись target-controlled процесса только в его
  `scratch/`;
- низкие лимиты CPU, memory, process count, file size, disk и wall-clock;
- локальные dummy principals, fixtures и secrets;
- зависимости не скачиваются и не устанавливаются.

## Запрещено

Не проверяй deployed endpoints, production identities, shared infrastructure,
чужие данные, paid API, live release, cloud control plane или availability
общего процесса. Не давай target code доступ к host home, credentials, sockets,
другим agent directories или retained artifacts.

Если control отсутствует, target code не запускается. Запиши точный blocker и
bounded plan для владельца в `needs_validation`.

## Scratch и artifacts

Каждый agent получает отдельные `agents/<id>/scratch/` и `artifacts/`. Agent и
target code могут писать только в scratch. Parent после завершения процесса может
продвинуть только заранее объявленный relative regular file, проверив no-follow
path traversal, link count 1, stable identity и per-file/cumulative byte limits.
Symlink, FIFO, socket, device, directory, hard link, changing file и archive
recursive copy не являются evidence.

Это не заменяется `.gitignore`, временной папкой хоста или обещанием агента «не
трогать сеть». При невозможности enforce'ить правило результат не подтверждается.
