---
description: DotCore pre-deploy-audit - аудит репозитория перед деплоем/публикацией
---

Прочитай скилл `pre-deploy-audit` из установленного dotcore-skills:

- `~/.codex/skills/pre-deploy-audit/SKILL.md`
- или `skills/pre-deploy-audit/SKILL.md` в клоне dotcore-skills
- или `.cursor/skills/pre-deploy-audit/SKILL.md` в проекте

Аргумент - уровень и/или фокус: `поверхностный` / `средний` / `полный`, `quick` / `standard` / `deep`, `утечки` / `код` / оба. Не задано - средний, оба трека; «перед публикацией / public» - полный по треку утечек с историей git. Явный «полный аудит безопасности / найди уязвимости / pen-test» - full security-audit engine с coverage ledger.

Выполни workflow (SKILL.md):

1. **Scope** - уровень и трек(и) по запросу ([levels.md](levels.md)). Не смешивай «утечки» (трек A) и «аудит кода» (трек B).
2. **Recon** - `git ls-files`, стек, конфиги, `.gitignore`, `LICENSE`, CI. Secret-named файлы не открывать.
3. **Audit** - трек A ([track-leaks.md](track-leaks.md)) и/или трек B ([track-code.md](track-code.md)) по уровню. В полном security-аудите выполни recon, создай `architecture.md` и `coverage-ledger.json`, выбери attack classes по [ATTACK-CLASSES.md](ATTACK-CLASSES.md), проведи hunting waves и coverage critic ([RECONNAISSANCE.md](RECONNAISSANCE.md), [HUNTING.md](HUNTING.md)); Codex без подагентов - последовательно, с теми же unit'ами.
4. **Validate** - свежий verifier на каждый candidate; parent пишет `findings.json` со статусами `confirmed` / `needs_validation` / `rejected` и запускает `node validate-findings.cjs` + `node validate-coverage-ledger.cjs`.
5. **Verify records** - отдельный свежий verifier проверяет каждый финальный `confirmed` и `needs_validation`; material replacement перепроверяется ещё раз. Для incomplete/deferred coverage не заявляй clean PASS.
6. **Verdict** - severity + готовность + гейт ([report.md](report.md)). Critical/High = FAILED; incomplete run = INCOMPLETE без бейджа.
7. **Stamp** - только на PASS или PASS WITH WARNINGS: запиши отчёт `docs/audit/{дата}-{слово}.md` + `docs/audit/latest.md` и впиши в README блок `<!-- audit:start/end -->` - кликабельный `security_audit` (→ `latest.md`) + кликабельный `date` (→ снимок) ([badge.md](badge.md)), без картинки. Старый 5-бейджевый блок мигрируй в новый формат.

Жёстко: не выводи значения секретов (маска); не правь историю git и не удаляй файлы автоматически (только рекомендация); минимальный diff - кроме блока бейджа в README и файлов `docs/audit/` на PASS код не трогать.

В конце выведи отчёт ([report.md](report.md)) и список изменённых файлов. Не выполняй target-controlled code без sandbox с no external network, empty allowlisted environment, read-only target/toolchain, scratch-only writes и ресурсными лимитами. Не читай secret-named файлы и не выводи секреты.
