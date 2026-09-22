# html-motion

Скилл DotCore из [dotcore-skills](../../README.md) для генерации и доработки
автономных HTML-анимаций. Базовое направление - плавный минимализм: узкая
монохромная палитра, один-два акцента, точная типографика, воздух и один
предметный motion-мотив. Скилл не навязывает сетку, точки или маркировку DotCore.

## Что создаёт

- single-file HTML для browser animation, hero, explainer, title sequence, UI
  transition или loop;
- responsive сцену с inline CSS/JS без обязательного build step;
- по запросу - video-ready timeline с детерминированным `__seek`/`__duration`
  контрактом для покадровой записи и экспорта.

## Установка

Из dotcore-skills:

```powershell
cd path\to\dotcore-skills
.\scripts\install.ps1 -Skill html-motion
```

```bash
./scripts/install.sh html-motion
```

При разработке:

```powershell
.\scripts\install.ps1 -Skill html-motion -Link
```

Триггеры: «сгенерируй HTML-анимацию», «сделай плавный animated hero»,
«монохромная motion-сцена», «анимация для записи в видео», «улучши плавность
HTML-анимации», `animation page`, `kinetic typography`, `explainer HTML`.

## Файлы

- [SKILL.md](SKILL.md) - workflow и критерии результата;
- [references/motion-craft.md](references/motion-craft.md) - визуальная система и
  режиссура движения;
- [references/qa.md](references/qa.md) - browser, performance, accessibility и
  video-ready QA;
- [references/api_reference.md](references/api_reference.md) - контракт seekable
  timeline для покадрового экспорта;
- [demo/index.html](demo/index.html) - автономная анимация, которая объясняет
  сам скилл и демонстрирует его video-ready контракт;
- [agents/openai.yaml](agents/openai.yaml) - UI-метаданные скилла.
