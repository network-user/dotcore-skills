# dotcore-skills

Monorepo Agent Skills для экосистемы **DotCore** ([Agent Skills spec](https://agentskills.io/specification)). Скиллы ставятся в **10+ coding-агентов** (Cursor, Claude Code, Codex, Gemini CLI, OpenCode, Goose, Roo Code, Junie, Amp, universal `.agents/`) и синхронизируются в проекты.

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

Только нужные агенты:

```powershell
.\scripts\install.ps1 -Agent cursor,claude,agents
.\scripts\install.ps1 -ListAgents
```

Junction/symlink вместо копии (удобно при разработке скиллов):

```powershell
.\scripts\install.ps1 -Link
```

```bash
LINK=1 ./scripts/install.sh
```

```bash
AGENTS=cursor,claude,agents ./scripts/install.sh
./scripts/install.sh --list-agents
```

### Куда ставится

Полная таблица: [docs/AGENTS_PATHS.md](docs/AGENTS_PATHS.md). Кратко (user-level):

| ID | Агент | Каталог |
|----|-------|---------|
| `cursor` | Cursor | `~/.cursor/skills/<name>/` |
| `claude` | Claude Code | `~/.claude/skills/<name>/` |
| `codex` | OpenAI Codex | `~/.codex/skills/<name>/` + `~/.codex/prompts/<name>.md` |
| `gemini` | Gemini CLI | `~/.gemini/skills/<name>/` |
| `agents` | Universal | `~/.agents/skills/<name>/` (Gemini, OpenCode, Amp, …) |
| `opencode` | OpenCode | `~/.config/opencode/skills/<name>/` |
| `goose` | Goose | `~/.config/goose/skills/<name>/` |
| `roo` | Roo Code | `~/.roo/skills/<name>/` |
| `junie` | Junie | `~/.junie/skills/<name>/` |
| `amp` | Amp | `~/.config/agents/skills/<name>/` |

Конфиг путей: [scripts/agents.targets.json](scripts/agents.targets.json).

### Установка в проект

Скопируй нужную папку в репозиторий (self-contained для клонов):

```text
your-repo/.cursor/skills/generate-readme/
```

Скрипт из monorepo:

```powershell
.\scripts\sync-to-project.ps1 -Target C:\path\to\your-repo
.\scripts\sync-to-project.ps1 -Target . -AllAgents -Link
.\scripts\sync-to-project.ps1 -Target . -Agent cursor,agents -Skill generate-readme
```

```bash
./scripts/sync-to-project.sh /path/to/your-repo generate-readme
ALL_AGENTS=1 LINK=1 ./scripts/sync-to-project.sh .
AGENTS=cursor,claude,agents ./scripts/sync-to-project.sh .
```

По умолчанию `sync-to-project` ставит только в `.cursor/skills/`. Флаг `-AllAgents` / `ALL_AGENTS=1` - во все project-level каталоги из [agents.targets.json](scripts/agents.targets.json).

## Структура репозитория

```text
dotcore-skills/
├── AGENTS.md
├── CHANGELOG.md
├── LICENSE
├── README.md
├── docs/
│   ├── ADDING_SKILL.md
│   └── AGENTS_PATHS.md
├── scripts/
│   ├── agents.targets.json   # пути всех агентов
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
