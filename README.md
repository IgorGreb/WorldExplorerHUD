# World Explorer HUD

Аддон для **WoW Forever** (Interface 16001): облік досліджених зон, місць, таємниць і зданих квестів.
Інтерфейс англійською та українською.

*An exploration tracker for WoW Forever: explored areas, secrets and turned-in quests, in English and Ukrainian.*

Повний опис для CurseForge (EN + UA): [DESCRIPTION.md](DESCRIPTION.md).

## Можливості
- HUD-віджет із прогресом поточної зони (місця / квести / таємниці).
- Точки дослідження на карті світу та мінікарті (HereBeDragons), відстеження відстані до точки.
- «Журнал дослідника» — усі зони за континентами з прогрес-барами.
- Спливаючі сповіщення про нові місця, таємниці та повністю досліджені зони.
- Власні точки (`/we addpin Назва`) та обмін ними рядком (`/we share`).
- Облік окремо для персонажа або для всього акаунта.

## Команди
| Команда | Дія |
|---|---|
| `/we` | панель налаштувань |
| `/we journal` | Журнал дослідника |
| `/we share` | імпорт / експорт власних точок |
| `/we addpin Назва` | власна точка на поточних координатах |
| `/we clear` | скасувати відстеження точки |
| `/we help` | усі команди |

## Розробка
```bash
luacheck .                       # статичний аналіз
lua5.1 tests/run_tests.lua       # тести з емуляцією WoW API
lua5.1 tests/hbd_smoke.lua       # перевірка справжньої HereBeDragons
```
`Libs/` містить вбудовані бібліотеки (LibStub, CallbackHandler-1.0, HereBeDragons, LibDataBroker-1.1).
**LibDBIcon-1.0** не зберігається в репозиторії: його підтягує BigWigs packager (див. `.pkgmeta`).
Без нього аддон використовує власну кнопку біля мінікарти.

## Релізи
Релізи збирає [BigWigs packager](https://github.com/BigWigsMods/packager) через GitHub Actions.

1. Один раз: додайте в `WorldExplorerHUD.toc` ID проєктів
   `## X-Curse-Project-ID: <id>` і `## X-Wago-ID: <id>`,
   а в **Settings → Secrets and variables → Actions** репозиторію — секрети `CF_API_KEY` і `WAGO_API_TOKEN`.
2. Оновіть `CHANGELOG.md`.
3. Створіть і запуште тег:
   ```bash
   git tag v0.7.0 && git push origin v0.7.0
   ```
   Workflow `Release` прожене luacheck і тести, збере zip (версія з тегу замість `@project-version@`)
   і завантажить його на GitHub Releases, CurseForge та Wago.

## Формат рядка точок
`!WEP1!<зона>~<x>~<y>~<назва>;...!<контрольна сума>` — зона задається ключем бази або `map:<uiMapID>`,
тому рядки працюють на клієнтах з будь-якою мовою.

## Ліцензія
All Rights Reserved — див. [LICENSE](LICENSE). Бібліотеки в `Libs/` мають власні ліцензії.
