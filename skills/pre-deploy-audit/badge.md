# Бейджи аудита

Выдаются **только на PASSED** (или PASSED WITH WARNINGS). На FAILED бейджей нет; существующий блок от прошлого PASS - снять.

Артефакт - ряд **flat-бейджей** в README, **без картинки**: статус, уровень, охват, модель, дата. Машиночитаемо, в общем стиле header-бейджей README.

## Поля и цвета

`style=flat`, в одном `<p>` (GitHub-first - иначе разъезжаются). Цвет кодирует смысл: статус, тип уровня и охват - цветные; модель и дата - нейтральный серый.

| Бейдж | Значение | Цвет |
|-------|----------|------|
| `security_audit` | `passed` | `3fb950` зелёный |
| | `passed_with_warnings` | `dbab09` жёлтый |
| `level` | `surface` | `1f6feb` синий |
| | `medium` | `d29922` янтарный |
| | `full` | `8957e5` фиолетовый |
| `scope` | `leaks` | `1fb6a8` бирюзовый |
| | `code` | `0598bc` голубой |
| | `leaks_%2B_code` | `bf3989` розовый |
| `model` | любое | `555` серый |
| `date` | любое | `555` серый |

Логика: уровень - холодный → тёплый → глубокий (surface синий, medium янтарный, full фиолетовый); охват - по покрытию (утечки бирюзовый, код голубой, оба розовый). Модель и дата - факты, не «типы», поэтому серые.

FAILED - бейджи не выдаются (нужен явный провал - первый бейдж `failed` цветом `f85149`, но по умолчанию блок снимается).

Экранирование значений: `-` → `--`, пробел → `_`, `+` → `%2B`.

## Скелет

```markdown
<p>
  <img src="https://img.shields.io/badge/security_audit-passed-3fb950?style=flat" alt="security audit passed" />
  <img src="https://img.shields.io/badge/level-{LEVEL_EN}-{LEVEL_COLOR}?style=flat" alt="level" />
  <img src="https://img.shields.io/badge/scope-{SCOPE}-{SCOPE_COLOR}?style=flat" alt="scope" />
  <img src="https://img.shields.io/badge/model-{MODEL}-555?style=flat" alt="model" />
  <img src="https://img.shields.io/badge/date-{DATE}-555?style=flat" alt="date" />
</p>
```

`{LEVEL_EN}` = `surface` / `medium` / `full`; `{SCOPE}` = `leaks` / `code` / `leaks_%2B_code`; `{LEVEL_COLOR}` и `{SCOPE_COLOR}` - из таблицы выше.

## Вставка в README

Блок **additive**, в маркерах - чтобы перезапуск аудита обновлял его на месте, не дублируя (как `loc:start/end` в generate-readme). Размести после обложки/шапки. Картинки нет, только бейджи.

```markdown
<!-- audit:start -->
<p>
  <img src="https://img.shields.io/badge/security_audit-passed-3fb950?style=flat" alt="security audit passed" />
  <img src="https://img.shields.io/badge/level-full-8957e5?style=flat" alt="level full" />
  <img src="https://img.shields.io/badge/scope-leaks_%2B_code-bf3989?style=flat" alt="scope leaks and code" />
  <img src="https://img.shields.io/badge/model-Claude_Opus_4.8-555?style=flat" alt="model" />
  <img src="https://img.shields.io/badge/date-2026--06--27-555?style=flat" alt="date" />
</p>
<!-- audit:end -->
```

- Маркеры `<!-- audit:start -->` / `<!-- audit:end -->` обязательны и принадлежат этому скиллу (как loc-маркеры - generate-readme). Не удалять.
- Перезапуск аудита: перепиши содержимое между маркерами, не плоди второй блок.
- Совместимость с `generate-readme`: при полной перегенерации README тот скилл **переносит этот блок дословно** (не выдумывает и не правит) - см. `skills/generate-readme/stack-badges.md`. Поэтому бейджи аудита переживают регенерацию README.

## Целостность (важно)

Бейджи - заявление «аудит уровня X пройден на дату Y». Они не должны врать:

- **Только на PASS.** FAILED - не выдавать; если блок уже есть - удалить вместе с маркерами.
- **Дата - дня аудита.** Не переноси старую дату на новый прогон.
- **Охват честный.** Трек A → `scope=leaks` (бирюзовый); не пиши `leaks_%2B_code`, если код не аудировали. Цвет охвата следует значению.
- Существенные изменения кода после выдачи обесценивают бейджи - перезапусти аудит и обнови дату.
