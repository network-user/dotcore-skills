# Security Audit · First Pass · 2026-07-01

| Поле | Значение |
|------|----------|
| Статус | PASSED WITH WARNINGS |
| Прогон | first-pass |
| Уровень | full |
| Охват | leaks + code |
| Модель | Claude Opus 4.8 |
| Дата | 2026-07-01 |

> Два Medium path-traversal ниже **исправлены** в следующем прогоне того же дня - см. [2026-07-01-iron-gate.md](2026-07-01-iron-gate.md). Этот снимок сохранён как история (демонстрация нескольких прогонов за день).

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

Гейт Critical/High = 0 - блокеров для деплоя нет. Открытые Medium → PASSED WITH WARNINGS.

## Находки

| Severity | Категория | Файл:строка | Описание | Рекомендация |
|----------|-----------|-------------|----------|--------------|
| Medium | path traversal | `scripts/install.sh:94-105`, `scripts/install.ps1:103-106` | `dir` из `agents.targets.json` может содержать `..`/абсолютный путь → рекурсивное удаление вне `$HOME`. | Нормализовать путь и проверить границу `$HOME`/`$TargetRoot`; отклонять `..`, ведущий `/`, `:`. |
| Medium | path traversal | `scripts/install.ps1:55`, `scripts/install.sh:67-68` | Имя скилла из CLI без валидации уводит путь за `skills/`. | Whitelist `^[A-Za-z0-9._-]+$` + проверка границы. |
| Low | gitignore-coverage | `.gitignore` | Нет правил для `.env*`/`*.pem`/`*.key`/`*.p12`/`*.pfx`/`secrets*`/`credentials*`. | Добавить блок игнора секретов. |
| Low | symlink/junction | `scripts/install.ps1:88`, `scripts/install.sh:58` | `-Link`/`LINK=1` junction на контролируемую цель в связке с traversal. | Закрыть защитой путей; проверять `IsReparsePoint`. |
| Low | rm -rf guard | `scripts/install.sh:56` | `rm -rf "$dst"` без guard на пустой `target_dir`. | Guard `[[ -n "$target_dir" && -n "$name" ]]`. |
| Low | action pinning | `.github/workflows/validate-skills.yml:14` | `actions/checkout@v4` по мутабельному тегу. | Запиннить по SHA. |
| Info | CI permissions | `.github/workflows/validate-skills.yml` | Нет `permissions:`. | `permissions: contents: read`. |
| Info | trust boundary | установщики, `agents.targets.json` | Полное доверие конфигу; при внешней редактируемости → High. | Валидация путей закрывает превентивно. |
| Info | supply chain | репозиторий | Внешних зависимостей нет, поверхность ~0. | - |

## Приоритет ремедиации

1. Нормализация целевых путей + whitelist имени скилла - закрывает обе Medium.
2. Расширить `.gitignore` секретными паттернами.
3. CI: `permissions: contents: read`; пиннинг `checkout` по SHA.

Значения секретов в отчёт не выводятся - найденных секретов нет.
