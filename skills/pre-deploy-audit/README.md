# pre-deploy-audit

Скилл DotCore из monorepo [dotcore-skills](../../README.md): **аудит репозитория перед деплоем или сменой видимости на public**. Три уровня глубины, два независимых трека, цветные бейджи аудита в README на PASS.

Различает две разные задачи и не смешивает их:

- **Трек A - утечки**: секреты, ключи, credentials, PII, история git. Паттерн-скан, не требует понимания логики. Это «проверка на утечки» и подготовка к публикации.
- **Трек B - код**: уязвимости в логике (инъекции, eval/exec, десериализация, SSRF, authz, крипто). Семантический разбор кода. Это «аудит всего кода на проблемы с безопасностью».

## Уровни

| Уровень | Трек A (утечки) | Трек B (код) | Подагенты |
|---------|-----------------|--------------|-----------|
| Поверхностный | working tree, секреты, `.gitignore` | явные флаги (`eval`/`exec`, creds) | нет |
| Средний | + экспозиция, дефолты | критичные области + зависимости | 2-4 |
| Полный | + **история git**, PII, supply chain | **вся кодовая база** + инфра/CI | веер + verify |

Полный уровень трека A - режим «перед сменой видимости на public» (с проверкой истории git).

## Что создаётся в целевом проекте (на PASS)

| Файл | Назначение |
|------|------------|
| блок `<!-- audit:start/end -->` в `README.md` | Цветные flat-бейджи аудита: статус, уровень, охват, модель, дата (additive, в маркерах) |

На FAILED бейджи не создаются; устаревший блок снимается. Картинки нет, только бейджи.

Так выглядит ряд бейджей аудита:

<p>
  <img src="https://img.shields.io/badge/security_audit-passed-3fb950?style=flat" alt="security audit passed" />
  <img src="https://img.shields.io/badge/level-full-8957e5?style=flat" alt="level full" />
  <img src="https://img.shields.io/badge/scope-leaks_%2B_code-bf3989?style=flat" alt="scope leaks and code" />
  <img src="https://img.shields.io/badge/model-Claude_Opus_4.8-555?style=flat" alt="model" />
  <img src="https://img.shields.io/badge/date-2026--06--27-555?style=flat" alt="date" />
</p>

Цвет кодирует смысл: статус зелёный, уровень и охват - свой цвет по значению (таблица в [badge.md](badge.md)), модель и дата - серые.

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Workflow (точка входа) |
| [levels.md](levels.md) | Три уровня × два трека, фокус, тайминги |
| [track-leaks.md](track-leaks.md) | Трек A: утечки, секреты, ключи, PII, история git |
| [track-code.md](track-code.md) | Трек B: уязвимости кода по категориям |
| [orchestration.md](orchestration.md) | Подагенты: веер, схема находок, adversarial-проверка |
| [report.md](report.md) | Severity, готовность, гейт, формат отчёта |
| [badge.md](badge.md) | Цветные flat-бейджи аудита, вставка в README |
| [codex-prompt.md](codex-prompt.md) | Промпт `/pre-deploy-audit` для Codex |

## Установка

### Из dotcore-skills (рекомендуется)

```powershell
cd path\to\dotcore-skills
.\scripts\install.ps1 -Skill pre-deploy-audit          # все агенты
.\scripts\install.ps1 -Skill pre-deploy-audit -Agent cursor,claude
.\scripts\install.ps1 -ListAgents
```

```bash
./scripts/install.sh pre-deploy-audit
AGENTS=cursor,claude ./scripts/install.sh pre-deploy-audit
```

При разработке: `.\scripts\install.ps1 -Skill pre-deploy-audit -Link`.

Поддерживаемые агенты и пути - [docs/AGENTS_PATHS.md](../../docs/AGENTS_PATHS.md).

### В целевом проекте

```text
your-repo/.cursor/skills/pre-deploy-audit/
```

Полная копия папки (self-contained), опционально `.claude/skills/pre-deploy-audit/`.

## Триггеры

«проверь перед деплоем», «аудит перед релизом», «проверь на утечки», «делаю репозиторий публичным - проверь безопасность», «полный аудит безопасности кода», `/pre-deploy-audit` (Codex).

## Тест

1. Открой целевой репозиторий.
2. «Проведи аудит перед деплоем» (уровень - поверхностный/средний/полный) или «проверь на утечки перед публикацией».
3. Проверь: уровень и трек(и) выбраны по запросу; Critical/High прошли verify; значения секретов не выведены; вердикт по [report.md](report.md); бейдж - только на PASS.
