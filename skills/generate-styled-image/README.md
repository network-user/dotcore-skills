# generate-styled-image

Скилл DotCore из monorepo [dotcore-skills](../../README.md): **иллюстрация в стиле, который задан в запросе**.

Канон приходит файлом или вставленным текстом. Сюжет берётся из текущего фрагмента. Люди, одежда и предметы из других кадров не переносятся. Картинка настроения, если канон её назвал, задаёт свет и материал, не композицию.

Стиль DotCore (сетка, line-art, подпись `.ядро`) делает `generate-dotcore-image`, не этот скилл.

## Что создаётся

Файл по пути из запроса. Новая папка, если пользователь просил отдельную папку. Соотношение из запроса, иначе 16:9.

## Файлы скилла

| Файл | Назначение |
|------|------------|
| [SKILL.md](SKILL.md) | Workflow |
| [codex-prompt.md](codex-prompt.md) | `/generate-styled-image` для Codex |

## Установка

### Из dotcore-skills

```powershell
cd path\to\dotcore-skills
.\scripts\install.ps1 -Skill generate-styled-image
.\scripts\install.ps1 -Skill generate-styled-image -Agent grok
```

```bash
./scripts/install.sh generate-styled-image
AGENTS=grok ./scripts/install.sh generate-styled-image
```

При разработке: `.\scripts\install.ps1 -Skill generate-styled-image -Link`.

Поддерживаемые агенты и пути: [docs/AGENTS_PATHS.md](../../docs/AGENTS_PATHS.md).

## Триггеры

«В этом стиле», «по канону», «иллюстрация к этому фрагменту», «несколько вариантов», файл стиля в запросе, `/generate-styled-image`.

Не триггер: «в стиле dotcore», «перерисуй в .ядро».
