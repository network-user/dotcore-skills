# Как добавить новый скилл

## 1. Создай папку

```text
skills/<kebab-name>/
├── SKILL.md              # обязательно
├── README.md             # описание для людей
└── ...                   # references, PROMPT.md, scripts/ - по необходимости
```

Имя папки **должно совпадать** с полем `name` в YAML frontmatter.

## 2. Frontmatter SKILL.md

```yaml
---
name: my-skill
description: >-
  Что делает скилл. Use when пользователь просит X, Y или Z.
---
```

- `name`: lowercase, hyphens, max 64 символа
- `description`: что + когда (триггеры), max 1024 символа
- Спецификация: https://agentskills.io/specification

## 3. Тело SKILL.md

- Workflow по шагам
- Self-check в конце
- Ссылки на supporting files одним уровнем (`[file.md](file.md)`)
- Держи < 500 строк

## 4. Обнови monorepo

1. Добавь строку в таблицу скиллов в [README.md](../README.md)
2. Если нужен Codex slash - добавь `codex-prompt.md` и `promptSource` в [agents.targets.json](../scripts/agents.targets.json)
3. Новый агент - пути в `agents.targets.json` и [AGENTS_PATHS.md](../docs/AGENTS_PATHS.md)
4. Запусти `.\scripts\install.ps1` локально для проверки

## 5. Шаблон для копирования

Скопируй структуру [skills/generate-readme/](../skills/generate-readme/) и замени содержимое.

## Чеклист PR

- [ ] `skills/<name>/SKILL.md` с валидным frontmatter
- [ ] `name` в frontmatter = имя папки
- [ ] README скилла описывает триггеры и установку
- [ ] Корневой README.md обновлён
- [ ] Нет секретов и machine-specific путей
