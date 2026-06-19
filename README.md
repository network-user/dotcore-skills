# dotcore-skills

Monorepo Agent Skills для экосистемы **DotCore** ([Agent Skills spec](https://agentskills.io/specification)). Скиллы ставятся в Cursor, Claude Code, Codex и копируются в `.cursor/skills/` целевых проектов.

## Скиллы

| Скилл | Назначение | Триггеры |
|-------|------------|----------|
| [generate-readme](skills/generate-readme/) | README DotCore + `AGENTS.md`, Cursor rule, `CLAUDE.md` | «обнови README», «настрой правила проекта» |
| [_template](skills/_template/) | Заготовка нового скилла (не устанавливается) | - |

Новый скилл: [docs/ADDING_SKILL.md](docs/ADDING_SKILL.md).

## Быстрая установка

Клонируй репозиторий и установи все скиллы в user-level каталоги агентов:

```powershell
git clone https://github.com/network-user/dotcore-skills.git
cd dotcore-skills
.\scripts\install.ps1
```

macOS / Linux:

```bash
git clone https://github.com/network-user/dotcore-skills.git
cd dotcore-skills
chmod +x scripts/install.sh
./scripts/install.sh
```

Один скилл:

```powershell
.\scripts\install.ps1 -Skill generate-readme
```

Junction/symlink вместо копии (удобно при разработке скиллов):

```powershell
.\scripts\install.ps1 -Link
```

```bash
LINK=1 ./scripts/install.sh
```

### Куда ставится

| Агент | Каталог |
|-------|---------|
| Cursor | `~/.cursor/skills/<name>/` |
| Claude Code | `~/.claude/skills/<name>/` |
| Codex | `~/.codex/skills/<name>/` + `~/.codex/prompts/<name>.md` |

### Установка в проект

Скопируй нужную папку в репозиторий (self-contained для клонов):

```text
your-repo/.cursor/skills/generate-readme/
```

Скрипт из monorepo:

```powershell
.\scripts\sync-to-project.ps1 -Target C:\path\to\your-repo
.\scripts\sync-to-project.ps1 -Target . -Skill generate-readme -Link -ClaudeMirror
```

```bash
./scripts/sync-to-project.sh /path/to/your-repo generate-readme
LINK=1 CLAUDE=1 ./scripts/sync-to-project.sh .
```

Опционально зеркало для Claude Code:

```text
your-repo/.claude/skills/generate-readme/
```

## Структура репозитория

```text
dotcore-skills/
├── AGENTS.md
├── CHANGELOG.md
├── LICENSE
├── README.md
├── docs/
│   └── ADDING_SKILL.md
├── scripts/
│   ├── install.ps1
│   ├── install.sh
│   ├── sync-to-project.ps1
│   └── sync-to-project.sh
├── skills/
│   ├── _template/            # заготовка нового скилла
│   └── generate-readme/
└── .github/workflows/
    └── validate-skills.yml
```

## Разработка

1. Правь файлы в `skills/<name>/`.
2. `.\scripts\install.ps1 -Link` - изменения сразу видны агентам.
3. Тестируй в целевом DotCore-репозитории: «обнови README и правила проекта».
4. Коммит + push; CI проверит frontmatter.

## Связанные стандарты

- [Agent Skills](https://agentskills.io/specification)
- [AGENTS.md](https://agents.md/) - генерируется скиллом `generate-readme`
- [Cursor Skills](https://cursor.com/docs/skills)

## Лицензия

MIT - см. [LICENSE](LICENSE).
