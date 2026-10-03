# Security Audit · Quiet Harbor · 2026-10-03

| Поле | Значение |
|------|----------|
| Статус | PASSED WITH WARNINGS |
| Прогон | quiet-harbor |
| Уровень | full |
| Охват | leaks + code |
| Профиль | standard |
| Модель | Grok |
| Источник | 714d442, рабочее дерево с незакоммиченными правками |
| Дата | 2026-10-03 |

## Сводка

Трек A · Секреты/ключи:   0  (Crit 0 / High 0)
Трек A · PII/экспозиция:   0
Трек A · История git:      0  (34 коммита, красный сканер)
Трек B · Инъекции/exec:    1 Medium, 1 needs_validation
Трек B · Authz/крипто:     0
Трек B · Зависимости:      0 подтвержденных
Инфра/CI:                  0

Severity: Crit 0 · High 0 · Med 1 · Low 0 · Info 0
Findings: confirmed 1 · needs_validation 1 · rejected 0
Готовность: 8/10
Вердикт: PASSED WITH WARNINGS

Покрытие: 11 units, все `covered`. Открытых units нет. Прошлого `coverage-ledger.json` не было. Машинные `findings.json` и ledger лежат вне репозитория.

`code-counter` посчитал 1959 строк. Markdown и PowerShell в это число не входят.

## Находки

| Severity | Категория | Файл:строка | Описание | Рекомендация |
|----------|-----------|-------------|----------|--------------|
| Medium | path-traversal | `scripts/install.sh:165` | Если `dir` равен `.` и имя скилла тоже `.`, `shutil.rmtree` получает `realpath` домашнего каталога и удаляет его. Текущие `userTargets` вложенные, поэтому обычный запуск сюда не попадает. Проверено на временном каталоге, не на живом профиле. | Отклонять сегмент `.` так же, как `..`, и не вызывать `rmtree`, когда путь совпадает с границей. |

## Needs validation

У этих записей нет severity. Это не подтвержденная уязвимость.

| Тема | Файл:строка | Что не закрыто |
|------|-------------|----------------|
| `install.sh` копирует цель symlink | `scripts/install.sh:170` | Живой Python вызывает `shutil.copytree` и не использует `contains_links`. Эта функция осталась в невызываемом `install_skill`. PowerShell и `sync-to-project.sh` такой скилл отклоняют. На этом хосте symlink не создается (`WinError 1314`), поэтому копирование цели не наблюдалось. |

## Hardening

- `ubuntu-latest` в `.github/workflows/validate-skills.yml` остается плавающим label. Входа из title или branch в shell нет, checkout запинен по SHA.
- `skills/generate-readme/README.md` все еще показывает `pip install code-counter-ntwusr` без версии. `SKILL.md` эту команду больше не задает.
- Имя скилла `.` в PowerShell и в sync может стереть каталог скиллов внутри границы, но не родительский корень на текущих `dir`.
- Мертвая функция `install_skill` в `scripts/install.sh` не вызывается.

## Трек A

Секретных имен в индексе нет. `.gitignore` закрывает `.env*`, ключи и файлы credentials. Маркеры ключей и примеры `C:\Users\` / `/home/` нашлись только в `skills/pre-deploy-audit/track-leaks.md` и `levels.md`, где они описаны как паттерны. Email, частные IP и префиксы живых токенов не найдены ни в дереве, ни в 34 коммитах. Значения секретов в отчет не выводились.
