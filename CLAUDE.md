# Claude Code

Прочитай [AGENTS.md](AGENTS.md) перед любой задачей в этом репозитории.

## Приоритет контекста

1. Явный запрос пользователя
2. [AGENTS.md](AGENTS.md)
3. [README.md](README.md)
4. Код в затронутых файлах и `scripts/agents.targets.json`

## Триггеры

- «Обнови README» / «сгенерируй README» → скилл `generate-readme`
- Правки документации → стандарт DotCore (см. AGENTS.md)
- Новый агент или скилл → `agents.targets.json` + `docs/`, оба установщика

Не дублируй содержимое AGENTS.md здесь - обновляй AGENTS.md через скилл.
