# Security Audit · Iron Ledger · 2026-09-22

| Поле | Значение |
|------|----------|
| Статус | **PASSED WITH WARNINGS** |
| Прогон | iron-ledger |
| Уровень | deep/full |
| Охват | leaks + code |
| Аудируемый ref | `4df12bd0500bdce5331496414f25400c722e9e2a` |
| Дата | 2026-09-22 |
| Оркестрация | Codex sequential fallback; target-controlled code не запускался |
| Coverage | 14 covered / 0 candidate / 0 blocked / 0 deferred / 0 out_of_scope |

> Аудит выполнен по коммиту `4df12bd`. Четыре пользовательских untracked-артефакта не входят в source ref и не были включены в verdict: `.claude/`, `_tmp_whisper_stills.py`, `docs/internal-cloud-platform.svg`, `skills/sepia.zip`. Перед публикацией их нужно либо отдельно проверить, либо исключить из release context.

## Сводка

```
Трек A · Секреты/ключи:        0  (Crit 0 / High 0)
Трек A · PII/экспозиция:       0  (high-confidence pattern scan)
Трек A · История git (28):     0  (high-confidence secret matches)
Трек B · Инъекции/exec:        0
Трек B · Path/reparse/traversal: 0 подтверждённых
Трек B · Authz/крипто:         0
Трек B · Зависимости:          1 hardening warning
Инфра/CI:                      1 hardening warning

Severity: Crit 0 · High 0 · Med 1 · Low 1 · Info 0
Readiness: 9/10
Findings: confirmed 2 · needs_validation 2 · rejected 0
Вердикт: PASSED WITH WARNINGS
```

Гейт пройден: Critical/High и обязательные coverage units отсутствуют. Жёлтый audit-бейдж означает, что Medium hardening-рекомендация ещё не закрыта.

## Покрытие

| Unit | Проверенный контур | Статус |
|------|--------------------|--------|
| install-ps1 | PowerShell installer, target boundary, reparse points | covered |
| install-sh | Bash installer, target boundary, symlink handling | covered |
| sync-ps1 | PowerShell project sync, target boundary, promptSource | covered |
| sync-sh | Bash project sync, target boundary, promptSource | covered |
| github-actions | workflow triggers, permissions, checkout credentials | covered |
| agents-targets | agent/path configuration integrity | covered |
| findings-validator | schema, path/text checks, descriptor read | covered |
| coverage-validator | canonical IDs, final status gate, descriptor read | covered |
| report-schema | findings contract and visible-text controls | covered |
| pre-deploy-audit | six-phase orchestration and no-live-execution boundary | covered |
| agent-skills | `.env*` and secret-named file handling in documentation | covered |
| html-motion-demo | autonomous browser runtime and external-asset surface | covered |
| git-history | tree, history, sensitive paths, symlink inventory | covered |
| dependencies-and-license | docs tooling, CI baseline, Cloudflare attribution | covered |

## Findings

| Severity | Fingerprint | Файл:строка | Описание | Рекомендация |
|----------|-------------|-------------|----------|--------------|
| Medium | `supply-chain:code-counter-doc-install` | `skills/generate-readme/SKILL.md:127` | Документация предлагает `pip install code-counter-ntwusr` без версии и hash. Это developer-tool supply-chain риск, не runtime-зависимость проекта. | Зафиксировать reviewed version и hash в controlled tooling manifest либо описать approved preinstalled toolchain. |
| Low | `ci:mutable-runner-label` | `.github/workflows/validate-skills.yml:11` | CI использует движущийся label `ubuntu-latest`, поэтому системный toolchain меняется вне ревью репозитория. | Зафиксировать runner image и явно объявить требуемый Node/Python runtime, если нужна воспроизводимость. |

Значения секретов и чувствительные улики в отчёт не выводятся.

## Needs validation

Эти записи не являются подтверждёнными уязвимостями и не получают severity:

| Fingerprint | Причина | Что проверить |
|-------------|---------|---------------|
| `runtime:os-sandbox-retention` | OS-enforced sandbox, network policy и retention находятся у runtime хоста. | Перед live use проверить filesystem boundary, network policy, process isolation и retention артефактов. |
| `release:provenance-settings` | GitHub release settings не представлены в локальном репозитории. | Проверить protected branches, signed tags, provenance attestations и SBOM в hosting platform. |

## Что было закрыто до этого прогона

- `4d7d9b6` - Cloudflare-style full workflow объединён с `pre-deploy-audit`: два трека, coverage ledger, findings schema, adversarial verification и redacted reports.
- `c9f5f10` - закрыты обходы границ через PowerShell reparse points, source symlinks и `promptSource`; усилены validators, CI trigger и checkout credentials; удалён мёртвый опасный helper; добавлено лицензирование адаптации.
- `2e7f25a` - browser QA в `html-motion` ограничен изолированным временным профилем без cookies/storage/credentials и без внешней сети по умолчанию.
- `4df12bd` - текущий DotCore default для `html-motion` и автономный demo просмотрены в составе audited ref. В runtime demo не обнаружены fetch, WebSocket, storage/cookie access, eval, innerHTML или внешние asset URLs.

## Проверки

- `node --check skills/pre-deploy-audit/validate-findings.cjs` - pass.
- `node --check skills/pre-deploy-audit/validate-coverage-ledger.cjs` - pass.
- `node skills/pre-deploy-audit/validate-findings.test.cjs` - `ok`.
- `node skills/pre-deploy-audit/validate-coverage-ledger.test.cjs` - `ok`.
- Final coverage ledger validation - `14/14 covered; open_statuses=0`.
- Findings contract validation - `confirmed=2; needs_validation=2; open_candidates=0`.
- PowerShell parser для обоих установщиков - pass.
- `bash -n scripts/install.sh scripts/sync-to-project.sh` - pass.
- Windows и Bash smoke `--list-agents` для обоих установщиков - pass.
- JSON parse для `report-schema.json` и `scripts/agents.targets.json` - pass.
- Tree/history scan: high-confidence private-key, GitHub token, AWS key и JWT matches - 0; tracked sensitive-named paths - 0; tracked symlinks - 0.

## Ограничения

- Из-за лимита agent threads веер full-аудита выполнен Codex последовательно по тому же coverage contract; target-controlled build, tests, browser и live network не запускались.
- Реальные GitHub permissions, release provenance, hosted-runner image и runtime sandbox нельзя доказать локальным исходным кодом; они оставлены в `needs_validation`.
- Untracked-файлы из шапки не входят в этот verdict. Если любой из них попадёт в release, нужен отдельный прогон по фактическому release tree.

