# Лицензия

Канон режимов. Вопрос задаёт [depth.md](depth.md) в том же окне, что уровень и иллюстрации. Пока сообщение пользователя уже не назвало режим, вопрос не пропускай и файл `LICENSE` не пиши.

Это шаблон разрешения для репозитория, не заключение юриста. Режим «личное пользование» и «ознакомление» не open source: опубликованный код сам по себе прав не даёт.

`PROMPT.md` повторяет тексты, потому что его копируют без соседних файлов. Меняешь формулировку прав: правь и его.

## Что делает скилл

1. Спрашивает режим. Окно закрыто без ответа: файл `LICENSE` уже есть - оставь его. Файла нет - поставь «ознакомление» и назови это в отчёте.
2. Пишет корневой `LICENSE` и футер `## Лицензия` последней секцией README, после `## Архитектура`.
3. Режим «оставить текущую» файл не перезаписывает. Футер всё равно описывает тот файл, который лежит в репо, а не чужой режим.
4. Смена режима при существующем `CHANGELOG` добавляет туда одну строку. Новый `CHANGELOG` не создавай.

Объём «только README» правила агентов не трогает. `LICENSE` при этом пишется по выбранному режиму. «Оставить текущую» и отказ от окна при уже существующем файле его не перезаписывают.

## Подстановки

- `{year}` - текущий год из даты сессии.
- `{author}` - правообладатель из репо (`LICENSE`, `package.json` author, git user). Для DotCore по умолчанию `DotCore`. Чужие имена не подставляй.

## Режимы

| id | Когда |
|----|--------|
| `view` | Ознакомление. Читать можно. Запуск, копия, правка и любое использование только с письменного согласия |
| `personal` | Личное пользование. Исходники открыты. Частное лицо может пользоваться кодом для себя. Бизнес и всё остальное только с письменного согласия |
| `mit` | MIT. Только если этот пункт выбрали |
| `apache-2.0` | Apache-2.0. Только если этот пункт выбрали |
| `gpl-3.0` | GPL-3.0. Только если этот пункт выбрали |
| `keep` | Файл уже есть, пользователь оставил его. Нет файла: этот режим недоступен |

«Open source», «свободная лицензия» без имени MIT, Apache или GPL: до записи спроси, какая из трёх. Второй вопрос закрыт без ответа: свободную лицензию не ставь. Дальше как при закрытом окне.

Не называй `personal` и `view` open source. Не подставляй MIT, Apache или GPL молча.

### Личное пользование

Разрешено частному лицу, для себя, без оплаты и не для работы: запускать программу, хранить свою копию, править её у себя.

Только с предварительного письменного согласия автора: бизнес и коммерция, компания и другая организация, работа по найму, работа на заказчика, публикация, распространение, продажа, сервис на базе этого кода.

### Оставить текущую

Файл не переписывай. Футер:

- текст совпал с шаблоном `view` или `personal` (год и автор не в счёт) - футер этого режима;
- в файле MIT, Apache-2.0 или GPL-3.0 - короткий футер этой лицензии;
- иначе одна строка: «Условия в [LICENSE](LICENSE). Этот прогон файл не менял.» Права своими словами не пересказывай.

## Шаблон `view`

```text
Copyright (c) {year} {author}. All Rights Reserved.

This software and its source code are proprietary and confidential.
No permission is granted to any person to use, copy, modify, merge,
publish, distribute, sublicense, or sell any part of the Software.

The source is provided for viewing and reference only. Any other use
requires the prior written permission of the copyright holder.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.
```

Футер:

```markdown
## Лицензия

© {year} {author}. Все права защищены.

Проприетарный код. Использование, копирование, изменение и распространение запрещены без письменного разрешения автора. Исходный код открыт только для ознакомления. См. [LICENSE](LICENSE).
```

## Шаблон `personal`

```text
Copyright (c) {year} {author}. All Rights Reserved.

The source code is published so it can be read. This is not an open-source
license. No rights are granted except the personal permission below.

Permission is granted to a private individual to use, copy, and modify the
Software for that person's own personal, non-commercial purposes. This
includes running it and keeping a private local copy.

Any other use requires the prior written permission of the copyright holder.
That includes commercial use, business use, use by a company or other
organization, use for an employer or a client, and any publishing,
distribution, sublicensing, sale, or offering of the Software as a service.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.
```

Футер:

```markdown
## Лицензия

© {year} {author}.

Исходный код открыт. Личное некоммерческое использование разрешено: запуск, локальная копия и правка для себя. Бизнес, коммерция, использование в организации или для заказчика, публикация и распространение требуют предварительного письменного согласия автора. Это не open source. См. [LICENSE](LICENSE).
```

## Шаблон `mit`

Текст ниже не сокращай.

```text
MIT License

Copyright (c) {year} {author}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Футер:

```markdown
## Лицензия

© {year} {author}. MIT License. См. [LICENSE](LICENSE).
```

## `apache-2.0` и `gpl-3.0`

Канонический текст, без пересказа и без сокращения.

- Apache-2.0: `https://www.apache.org/licenses/LICENSE-2.0.txt`. Перед ним строка `Copyright {year} {author}`.
- GPL-3.0: `https://www.gnu.org/licenses/gpl-3.0.txt`. В начале блок copyright с `{year}` и `{author}`, затем полный текст.

Адрес не открылся: `LICENSE` не выдумывай. Файл уже есть - оставь его. Файла нет - поставь `view` и напиши, что канонический текст не получен.

Футеры:

```markdown
## Лицензия

© {year} {author}. Apache License 2.0. См. [LICENSE](LICENSE).
```

```markdown
## Лицензия

© {year} {author}. GNU GPL v3. См. [LICENSE](LICENSE).
```

## Чеклист

- [ ] Режим спрошен, либо он уже был в сообщении, либо в отчёте назван отказ от окна.
- [ ] `LICENSE` и футер совпадают с режимом. `{year}` и `{author}` подставлены из репо.
- [ ] Футер - последняя секция README и ссылается на [LICENSE](LICENSE).
- [ ] `keep` не перезаписал файл. Неизвестный текст не пересказан.
- [ ] MIT, Apache-2.0 и GPL-3.0 не поставлены без явного выбора. Их текст не сокращён.
- [ ] `personal` и `view` нигде не названы open source.
