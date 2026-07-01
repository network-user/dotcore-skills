---
description: DotCore pre-deploy-audit - аудит репозитория перед деплоем/публикацией
---

Прочитай скилл `pre-deploy-audit` из установленного dotcore-skills:

- `~/.codex/skills/pre-deploy-audit/SKILL.md`
- или `skills/pre-deploy-audit/SKILL.md` в клоне dotcore-skills
- или `.cursor/skills/pre-deploy-audit/SKILL.md` в проекте

Аргумент - уровень и/или фокус: `поверхностный` / `средний` / `полный`, `утечки` / `код` / оба. Не задано - средний, оба трека; «перед публикацией / public» - полный по треку утечек с историей git.

Выполни workflow (SKILL.md):

1. **Scope** - уровень и трек(и) по запросу ([levels.md](levels.md)). Не смешивай «утечки» (трек A) и «аудит кода» (трек B).
2. **Recon** - `git ls-files`, стек, конфиги, `.gitignore`, `LICENSE`, CI. Secret-named файлы не открывать.
3. **Audit** - трек A ([track-leaks.md](track-leaks.md)) и/или трек B ([track-code.md](track-code.md)) по уровню. Средний/полный - подагенты веером по измерениям ([orchestration.md](orchestration.md)); Codex без подагентов - последовательно, схема находок та же.
4. **Verify** - adversarial-проверка каждой находки Critical/High.
5. **Verdict** - severity + готовность + гейт ([report.md](report.md)). Critical/High = FAILED.
6. **Stamp** - только на PASS: запиши отчёт `docs/audit/{дата}-{слово}.md` + `docs/audit/latest.md` и впиши в README блок `<!-- audit:start/end -->` - кликабельный `security_audit` (→ `latest.md`) + кликабельный `date` (→ снимок) ([badge.md](badge.md)), без картинки. Старый 5-бейджевый блок мигрируй в новый формат.

Жёстко: не выводи значения секретов (маска); не правь историю git и не удаляй файлы автоматически (только рекомендация); минимальный diff - кроме блока бейджа в README и файлов `docs/audit/` на PASS код не трогать.

В конце выведи отчёт ([report.md](report.md)) и список изменённых файлов.
