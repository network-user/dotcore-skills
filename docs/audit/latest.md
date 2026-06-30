> Последний прогон. Снимок: [2026-07-01.md](2026-07-01.md) · история: [docs/audit/](.)

# Security Audit - 2026-07-01

| Поле | Значение |
|------|----------|
| Статус | PASSED WITH WARNINGS |
| Уровень | full |
| Охват | leaks + code |
| Модель | Claude Opus 4.8 |
| Дата | 2026-07-01 |

## Сводка

```
Трек A · Секреты/ключи:        0  (Crit 0 / High 0)
Трек A · PII/экспозиция:        0
Трек A · История git (11):      0
Трек B · Инъекции/exec:         0
Трек B · Path traversal:        2  (Medium)
Трек B · Symlink/удаление:      2  (Low)
Зависимости/supply chain:       0
Инфра/CI:                       3  (Low/Info)

Severity: Crit 0 · High 0 · Med 2 · Low 4 · Info 6
Вердикт: PASSED WITH WARNINGS
```

Гейт Critical/High = 0 - блокеров для деплоя нет. Открытые Medium → PASSED WITH WARNINGS: для подготовки к public рекомендуется закрыть.

## Находки

| Severity | Категория | Файл:строка | Описание | Рекомендация |
|----------|-----------|-------------|----------|--------------|
| Medium | path traversal | `scripts/install.sh:94-105`, `scripts/install.ps1:103-106` | `dir` из `agents.targets.json` может содержать `..` или абсолютный путь; затем по этому пути идёт рекурсивное удаление существующего `dst` (`shutil.rmtree`/`Remove-Item -Recurse -Force`/`rm -rf`). При подменённом конфиге - удаление вне `$HOME`. | Нормализовать целевой путь (`realpath`/`Resolve-Path`) и проверить, что он строго внутри `$HOME` (install) / `$TargetRoot` (sync); отклонять `dir` с `..`, ведущим `/`, `:`/`\`. |
| Medium | path traversal | `scripts/install.ps1:55`, `scripts/install.sh:67-68`, `scripts/sync-to-project.*` | Имя скилла из CLI (`-Skill`/`$1`) подставляется в путь без валидации; `..`-значение уводит `src`/`dst` за пределы `skills/`. Смягчено проверкой существования `src` перед удалением. | Валидировать имя скилла `^[A-Za-z0-9._-]+$` и сверять со списком реальных директорий `skills/`. |
| Low | gitignore-coverage | `.gitignore` | Нет правил для `.env`/`.env.*`/`*.pem`/`*.key`/`*.p12`/`*.pfx`/`secrets*`/`credentials*`. Сейчас таких файлов нет, но перед public отсутствие игнора повышает риск случайного коммита секрета. | Добавить блок игнора секретных артефактов. |
| Low | symlink/junction | `scripts/install.ps1:88`, `scripts/install.sh:58`, `scripts/sync-to-project.*` | В режиме `-Link`/`LINK=1` junction/symlink на цель, зависящую от имени скилла/конфига; в связке с traversal - линк в произвольной директории. Bash-ветка снимает линк через `os.unlink` (корректно), PS вызывает `Remove-Item -Recurse -Force`. | После защиты путей риск закрыт; дополнительно проверять `IsReparsePoint` перед рекурсивным удалением в PS. |
| Low | rm -rf guard | `scripts/install.sh:56` | `rm -rf "$dst"`, где `dst="$target_dir/$name"`; при пустом `target_dir` (будущая правка логики) получится `rm -rf "/$name"`. Защищает `set -euo pipefail` и непустые поля. | Guard `[[ -n "$target_dir" && -n "$name" ]]` перед `rm -rf`. |
| Low | action pinning | `.github/workflows/validate-skills.yml:14` | `actions/checkout@v4` пиннингован по мутабельному тегу, не по commit SHA. | Запиннить по SHA (`actions/checkout@<sha> # v4`) либо принять риск (first-party экшн). |
| Info | CI permissions | `.github/workflows/validate-skills.yml` | Нет блока `permissions:`; `GITHUB_TOKEN` получает дефолтные права. Workflow только читает. | Добавить `permissions: contents: read` (least-privilege). |
| Info | trust boundary | установщики, `agents.targets.json` | Полное доверие конфигу как границе: поля `dir`/`id`/`promptsDir` подставляются в пути без валидации. Сейчас конфиг версионируется и доверен (Info). Станет редактируемым извне → поднимается до High. | Валидация путей (см. Medium) закрывает превентивно. |
| Info | supply chain | репозиторий | Нет `package.json`/`requirements.txt`/lockfile/Dockerfile, нет `curl\|bash`, нет скачивания исполняемого. Единственная внешняя зависимость CI - `actions/checkout`. Поверхность ~0. | Действий не требуется. |
| Info | injections | `scripts/install.sh`, `scripts/sync-to-project.sh` | Командной инъекции и небезопасного парсинга нет: Python через heredoc с позиционными аргументами, JSON через `json.load`, переменные квотированы, `eval`/`Invoke-Expression`/`sh -c` отсутствуют. Сильная сторона. | - |

## Заметка о классификации

Path-traversal помечен **Medium как defense-in-depth**: в штатном использовании источник (CLI-аргумент пользователя, версионируемый `agents.targets.json`) доверенный, недоверенной runtime-границы нет, привилегий сверх запуска самого скрипта traversal не даёт (запуск установщика из недоверенного репозитория и так = исполнение чужого кода). Поэтому это не блокер (гейт Critical/High = 0), но для подготовки к public закрыть стоит.

## Приоритет ремедиации

1. Нормализация целевых путей + whitelist имени скилла - закрывает обе Medium разом.
2. Расширить `.gitignore` секретными паттернами (Low).
3. CI: `permissions: contents: read`; пиннинг `checkout` по SHA (Low/Info).

Значения секретов в отчёт не выводятся - найденных секретов нет.
